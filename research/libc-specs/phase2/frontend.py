#!/usr/bin/env python3
"""Unverified, restricted C parser selecting an independently fixed AST schema; see FRONTEND.md."""
import argparse
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re

SCHEMA_VERSION = 'buffer-relay32-v1'
TYPES = {'int', 'ssize_t', 'size_t'}


class Rejected(ValueError):
    pass


@dataclass(frozen=True)
class Token:
    value: str
    line: int
    column: int


def node(kind, **fields):
    return {'kind': kind, **fields}


def var(name):
    return node('variable', name=name)


def num(value):
    return node('integer', value=value)


def binary(op, lhs, rhs):
    return node('binary', operator=op, left=lhs, right=rhs)


def cast(type_, value):
    return node('cast', type=type_, value=value)


def call(name, *args):
    return node('call', name=name, arguments=list(args))


def assign(name, value):
    return node('assign', name=name, value=value)


def block(*statements):
    return node('block', statements=list(statements))


def return_(value):
    return node('return', value=num(value))


def if_(condition, body):
    return node('if', condition=condition, body=body)


def while_(condition, body):
    return node('while', condition=condition, body=body)


# Independently specified AST schema. No candidate parsing participates in its construction.
EXPECTED_DRAIN = while_(binary('<', var('off'), cast('size_t', var('n'))), block(
    assign('w', call('write', num(1), binary('+', var('buf'), var('off')),
                    binary('-', cast('size_t', var('n')), var('off')))),
    if_(binary('<=', var('w'), num(0)), return_(2)),
    assign('off', binary('+', var('off'), cast('size_t', var('w'))))))
EXPECTED_LOOP = while_(num(1), block(
    assign('n', call('read', num(0), var('buf'), num(32))),
    if_(binary('<', var('n'), num(0)), return_(1)),
    if_(binary('==', var('n'), num(0)), return_(0)),
    assign('off', num(0)), EXPECTED_DRAIN))
EXPECTED_AST = node('translation_unit', headers=['stddef.h', 'unistd.h'],
    function=node('function', return_type='int', name='relay', parameters='void', body=block(
        node('declaration', type='unsigned char', name='buf', array=32),
        node('declaration', type='ssize_t', name='n', array=None),
        node('declaration', type='ssize_t', name='w', array=None),
        node('declaration', type='size_t', name='off', array=None), EXPECTED_LOOP)))


def lex(source):
    # Match supported GCC physical-line handling before stripping // comments.
    source = source.replace('\r\n', '\n')
    if '\r' in source:
        raise Rejected('lone carriage returns are unsupported; use LF or CRLF')
    if '\\' in source or '??' in source or '\x00' in source:
        raise Rejected('backslashes, trigraph-like sequences and NUL are unsupported')
    if any(ord(c) < 32 and c not in '\t\n\r\v\f' for c in source):
        raise Rejected('unsupported source control byte')
    if not source.isascii():
        raise Rejected('only ASCII C source is supported')
    chars = list(source)
    i = 0
    while i < len(source):
        if source.startswith('/*', i):
            end = source.find('*/', i + 2)
            if end < 0:
                raise Rejected('unterminated block comment')
            end += 2
        elif source.startswith('//', i):
            end = source.find('\n', i + 2)
            if end < 0:
                end = len(source)
        else:
            i += 1
            continue
        for j in range(i, end):
            if chars[j] != '\n':
                chars[j] = ' '
        i = end
    clean = ''.join(chars)
    headers = []
    lines = []
    code_seen = False
    physical_lines = clean.split('\n')
    for line_number, raw_line in enumerate(physical_lines):
        line = raw_line + ('\n' if line_number + 1 < len(physical_lines) else '')
        if line.lstrip().startswith('#'):
            if code_seen:
                raise Rejected('preprocessor directive after code')
            match = re.fullmatch(r'\s*#\s*include\s*<(stddef\.h|unistd\.h)>\s*', line)
            if not match:
                raise Rejected('only literal stddef.h/unistd.h includes are supported')
            headers.append(match[1])
            lines.append(''.join('\n' if c == '\n' else ' ' for c in line))
        else:
            code_seen |= bool(line.strip())
            lines.append(line)
    text = ''.join(lines)
    pattern = re.compile(r'[A-Za-z_][A-Za-z_0-9]*|[0-9]+|<=|==|!=|>=|[{}()\[\];,+\-<>=]')
    tokens = []
    i = 0
    line = column = 1
    while i < len(text):
        ch = text[i]
        if ch.isspace():
            line, column = (line + 1, 1) if ch == '\n' else (line, column + 1)
            i += 1
            continue
        match = pattern.match(text, i)
        if not match:
            raise Rejected(f'unsupported token at {line}:{column}: {ch!r}')
        value = match[0]
        if value.isdigit() and len(value) > 1 and value[0] == '0':
            raise Rejected('leading-zero/octal literals are unsupported')
        tokens.append(Token(value, line, column))
        i = match.end()
        column += len(value)
    tokens.append(Token('<eof>', line, column))
    return headers, tokens


class Parser:
    def __init__(self, source):
        self.headers, self.tokens = lex(source)
        self.pos = 0

    def peek(self, offset=0):
        return self.tokens[min(self.pos + offset, len(self.tokens) - 1)].value

    def take(self, expected=None):
        token = self.tokens[self.pos]
        if expected is not None and token.value != expected:
            raise Rejected(f'expected {expected!r}, got {token.value!r} at {token.line}:{token.column}')
        if token.value == '<eof>' and expected != '<eof>':
            raise Rejected('unexpected end of input')
        self.pos += 1
        return token.value

    def identifier(self):
        value = self.take()
        if not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', value):
            raise Rejected(f'expected identifier, got {value!r}')
        return value

    def integer(self):
        value = self.take()
        if not value.isdigit():
            raise Rejected(f'expected decimal integer, got {value!r}')
        if len(value) > 9:
            raise Rejected('integer literal exceeds supported range')
        return int(value)

    def type(self):
        if self.peek() == 'unsigned':
            self.take('unsigned')
            self.take('char')
            return 'unsigned char'
        if self.peek() not in TYPES:
            raise Rejected(f'unsupported type {self.peek()}')
        return self.take()

    def expression(self, minimum=0):
        if self.peek() == '(' and self.peek(1) in TYPES and self.peek(2) == ')':
            self.take('(')
            type_ = self.type()
            self.take(')')
            left = cast(type_, self.expression(30))
        elif self.peek() == '(':
            self.take('(')
            left = self.expression()
            self.take(')')
        elif self.peek().isdigit():
            left = num(self.integer())
        else:
            name = self.identifier()
            if self.peek() == '(':
                self.take('(')
                args = []
                if self.peek() != ')':
                    args.append(self.expression())
                    while self.peek() == ',':
                        self.take(',')
                        args.append(self.expression())
                self.take(')')
                left = call(name, *args)
            else:
                left = var(name)
        precedences = {'==': 5, '!=': 5, '<': 10, '<=': 10, '>': 10, '>=': 10, '+': 20, '-': 20}
        while self.peek() in precedences and precedences[self.peek()] >= minimum:
            op = self.take()
            right = self.expression(precedences[op] + 1)
            left = binary(op, left, right)
        return left

    def statement(self):
        if self.peek() == '{':
            self.take('{')
            statements = []
            while self.peek() != '}':
                statements.append(self.statement())
            self.take('}')
            return block(*statements)
        if self.peek() in ('while', 'if'):
            kind = self.take()
            self.take('(')
            condition = self.expression()
            self.take(')')
            return node(kind, condition=condition, body=self.statement())
        if self.peek() == 'return':
            self.take('return')
            result = node('return', value=self.expression())
            self.take(';')
            return result
        if self.peek() in TYPES or self.peek() == 'unsigned':
            type_ = self.type()
            name = self.identifier()
            array = None
            if self.peek() == '[':
                self.take('[')
                array = self.integer()
                self.take(']')
            self.take(';')
            return node('declaration', type=type_, name=name, array=array)
        name = self.identifier()
        self.take('=')
        value = self.expression()
        self.take(';')
        return assign(name, value)

    def parse(self):
        type_ = self.type()
        name = self.identifier()
        self.take('(')
        self.take('void')
        self.take(')')
        body = self.statement()
        self.take('<eof>')
        return node('translation_unit', headers=self.headers,
                    function=node('function', return_type=type_, name=name, parameters='void', body=body))


def digest(data):
    return hashlib.sha256(data).hexdigest()


def translate(data):
    try:
        source = data.decode('ascii')
    except UnicodeDecodeError as e:
        raise Rejected('non-ASCII source') from e
    ast = Parser(source).parse()
    if ast != EXPECTED_AST:
        raise Rejected('parsed C is outside the relay32-v1 schema; no model selected')
    canonical = json.dumps(ast, sort_keys=True, separators=(',', ':')).encode()
    return {'schema': SCHEMA_VERSION, 'source_sha256': digest(data), 'ast_sha256': digest(canonical),
            'ast': ast, 'selected_model': 'BufferRelay.run',
            'translation_verified': False,
            'target_assumptions': '8-bit bytes; request32 fits size_t and ssize_t; fd0/fd1 controlled protocol',
            'configuration': {'capacity': 32, 'input_fd': 0, 'output_fd': 1,
                              'read_error_status': 1, 'write_error_or_zero_status': 2}}


def binding(result):
    return f'''import BufferRelay
namespace GeneratedRelay

def sourceSHA256 : String := "{result['source_sha256']}"
def astSHA256 : String := "{result['ast_sha256']}"
def run := BufferRelay.run

-- Only checks the selected model binding. The Python C translation is unverified.
theorem binding_is_reference : run = BufferRelay.run := rfl
end GeneratedRelay
#print axioms GeneratedRelay.binding_is_reference
'''


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('source', type=Path)
    ap.add_argument('--out', required=True, type=Path, help='directory for AST JSON and Lean binding')
    args = ap.parse_args()
    try:
        result = translate(args.source.read_bytes())
    except (Rejected, OSError) as e:
        ap.exit(2, f'rejected: {e}\n')
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / 'translation.json').write_text(json.dumps(result, indent=2) + '\n')
    (args.out / 'GeneratedRelay.lean').write_text(binding(result))
    print(json.dumps({k: result[k] for k in ('schema', 'source_sha256', 'ast_sha256', 'translation_verified')}))


if __name__ == '__main__':
    main()
