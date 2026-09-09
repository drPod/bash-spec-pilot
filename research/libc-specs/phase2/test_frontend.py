"""Whole-unit fail-closed frontend regressions; no C execution or Lean build."""
from pathlib import Path
import unittest
from frontend import EXPECTED_AST, Parser, Rejected, translate

SOURCE = Path(__file__).with_name('relay.c').read_text()


class FrontendTests(unittest.TestCase):
    def test_reference_schema(self):
        result = translate(SOURCE.encode())
        self.assertEqual(result['ast'], EXPECTED_AST)
        self.assertFalse(result['translation_verified'])

    def test_nonsemantic_variants(self):
        base = translate(SOURCE.encode())
        variants = [SOURCE.replace('off = 0;', 'off /* gap */ = (0);'),
                    SOURCE.replace('buf + off', '(buf + (off))'),
                    '\n\t' + SOURCE + '\n// tail comment\n',
                    SOURCE.replace('\n', '\r\n'),
                    SOURCE.replace('off = off + (size_t)w;', 'off = (off + (size_t)w);')]
        for variant in variants:
            with self.subTest(source=variant):
                result = translate(variant.encode())
                self.assertEqual(base['ast_sha256'], result['ast_sha256'])
                self.assertNotEqual(base['source_sha256'], result['source_sha256'])

    def test_semantic_mutations_rejected(self):
        substitutions = [
            ('buf[32]', 'buf[31]'), ('read(0, buf, 32)', 'read(0, buf, 33)'),
            ('read(0, buf, 32)', 'read(1, buf, 32)'),
            ('write(1,', 'write(2,'), ('buf + off', 'buf'),
            ('(size_t)n - off', '(size_t)n'), ('off = 0;', 'off = 1;'),
            ('off < (size_t)n', 'off <= (size_t)n'), ('w <= 0', 'w < 0'),
            ('n < 0', 'n <= 0'), ('n == 0', 'n != 0'), ('return 1;', 'return 0;'),
            ('return 2;', 'return 0;'), ('off + (size_t)w', 'off + (size_t)n'),
            ('ssize_t w;', 'size_t w;'), ('unsigned char buf', 'int buf'),
            ('while (1)', 'while (0)'), ('(size_t)n - off', '(size_t)(n - off)'),
            ('off = 0;', 'off = read(0, buf, 32);')]
        for old, new in substitutions:
            with self.subTest(old=old, new=new):
                self.assertIn(old, SOURCE)
                with self.assertRaises(Rejected):
                    translate(SOURCE.replace(old, new).encode())

    def test_unsupported_or_extra_unit_rejected(self):
        variants = [
            '#define read fake_read\n' + SOURCE,
            '#if 0\n' + SOURCE + '\n#endif',
            SOURCE + '\nint another(void) { return 0; }',
            SOURCE.replace('off = 0;', 'off = 0; write(1, buf, 32);'),
            SOURCE.replace('off = off + (size_t)w;', 'off += (size_t)w;'),
            SOURCE.replace('return 2;', 'return 2; else return 0;'),
            SOURCE.replace('buf[32]', 'buf[032]'),
            SOURCE.replace('buf[32]', 'buf[0x20]'),
            SOURCE.replace('while (1)', 'while (1U)'),
            SOURCE.replace('n = read', 'n = re\\\nad'),
            SOURCE.replace('buf[32]', 'buf??(32??)'),
            SOURCE + '\n/* unterminated', SOURCE + '\x00',
            SOURCE.replace('size_t off;', 'size_t off; __attribute__((unused));'),
            SOURCE.replace('#include <stddef.h>\n', '#include <stddef.h>\v'),
            SOURCE.replace('off = 0;', 'off\x1c= 0;'),
            SOURCE.replace('off = 0;', 'off = "0";'),
            SOURCE.replace('size_t off;', 'size_t off; size_t off;'),
            SOURCE + '\n#pragma once',
            SOURCE.replace('off = 0;', 'off = 0; // hidden\rreturn 0;'),
            SOURCE.replace('off = 0;', 'off = 0; // hidden\r#define write fake_write'),
            SOURCE.replace('off = 0;', 'off = 0; // hidden\r\r\nreturn 0;'),
        ]
        for variant in variants:
            with self.subTest(source=variant):
                with self.assertRaises(Rejected):
                    translate(variant.encode())

    def test_precedence_not_flat_token_comparison(self):
        left = Parser(SOURCE.replace('off + (size_t)w', 'off + (size_t)w - 1')).parse()
        right = Parser(SOURCE.replace('off + (size_t)w', 'off + ((size_t)w - 1)')).parse()
        self.assertNotEqual(left, right)


if __name__ == '__main__':
    unittest.main()
