#!/usr/bin/env python3
"""Recognize canonical reference queries in the actual constrained-output grammar.

GBNF subset -> Lark Earley recognizer, preserving literal spaces and character
classes. Acceptance is a generation-coverage check, never an FQL correctness oracle.
Only formatting and quoting of bare absolute paths are canonicalized; upstream AST
identity is checked separately to ensure canonicalization did not alter the query.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
from lark import Lark,UnexpectedInput

ROOT=Path(__file__).resolve().parents[1]


def to_lark(source):
    lines=[]
    for line in source.splitlines():
        if not line.strip() or line.lstrip().startswith('#'): continue
        name,body=line.split('::=',1)
        out=''; i=0
        while i<len(body):
            c=body[i]
            if c=='"':
                start=i; i+=1
                while i<len(body):
                    if body[i]=='\\': i+=2; continue
                    if body[i]=='"': i+=1; break
                    i+=1
                out+=body[start:i]
            elif c=='[':
                start=i; i+=1
                while i<len(body):
                    if body[i]=='\\': i+=2; continue
                    if body[i]==']': i+=1; break
                    i+=1
                out+='/'+body[start:i].replace('/','\\/')+'/'
            else: out+=c; i+=1
        lines.append(name.strip().replace('-','_')+':'+out)
    # GBNF permits hyphens in rule names; Lark uses underscores. Do not change
    # character classes or quoted text, which can contain meaningful hyphens.
    lines=[re.sub(r'\bcondition-spec\b','condition_spec',line) for line in lines]
    return '\n'.join(lines)


def canonical(text):
    tokens=re.findall(r'"[^"]*"|[;.,=]|[^\s;.,="]+',text)
    out=''
    for token in tokens:
        if token.startswith('/'):
            token=json.dumps(token)
        if token in [';',',','.']:
            out=out.rstrip()+token+' '
        elif token=='=':
            out=out.rstrip()+'='
        else:
            if out and not out.endswith((' ','=')): out+=' '
            out+=token
    return out.strip()


def main():
    p=argparse.ArgumentParser(); p.add_argument('--grammar',default='experiments/fql-subset.gbnf')
    p.add_argument('--out',default='reports/grammar-coverage-v1.json'); a=p.parse_args()
    source=(ROOT/a.grammar).read_text()
    parser=Lark(to_lark(source),start='root',parser='earley',lexer='dynamic',ambiguity='resolve')
    results=[]
    for b in json.loads((ROOT/'benchmarks/original.json').read_text()):
        query=canonical(b['formal_query'])
        try: parser.parse(query); accepted=True; error=None
        except UnexpectedInput as e: accepted=False; error=str(e).splitlines()[0]
        results.append({'task_id':b['id'],'original_query':b['formal_query'],
                        'canonical_query':query,'grammar_accepts':accepted,'error':error})
    report={'grammar':a.grammar,'grammar_sha256':hashlib.sha256(source.encode()).hexdigest(),
            'recognized':sum(r['grammar_accepts'] for r in results),'total':len(results),
            'results':results}
    (ROOT/a.out).write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='results'}))
    for r in results:
        if not r['grammar_accepts']: print(r['task_id'],r['error'])


if __name__=='__main__': main()
