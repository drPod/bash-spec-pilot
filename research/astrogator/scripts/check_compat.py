#!/usr/bin/env python3
"""Exercise OCaml compatibility shims against an independent Python oracle."""
import itertools
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
# Do not import compat.py: its mutation is intentionally container-only.
source=(ROOT/'scripts/compat.py').read_text().split("shim='''",1)[1].split("'''",1)[0]
statements=[source+';;']
count=0
strings=[''.join(p) for n in range(4) for p in itertools.product('ab',repeat=n)]
for s in strings:
    for sub in ['', 'a','b','ab','aa','long']:
        q=lambda x:json.dumps(x)
        statements.append(f'assert (Compat_string.includes ~affix:{q(sub)} {q(s)} = {str(sub in s).lower()});;')
        count+=1
        for start in range(len(s)+1):
            idx=s.find(sub,start)
            expected='None' if idx<0 else f'Some {idx}'
            statements.append(f'assert (Compat_string.find_first ~sub:{q(sub)} ~start:{start} {q(s)} = {expected});;')
            replacement=s[:start]+s[start:].replace(sub,'X')
            statements.append(f'assert (Compat_string.replace_all ~sub:{q(sub)} ~by:"X" ~start:{start} {q(s)} = {q(replacement)});;')
            count+=2
statements.append('print_endline "compatibility checks passed";;')
result=subprocess.run(['docker','exec','-i','astrogator-lab-build','ocaml','-stdin'],
                      input='\n'.join(statements),capture_output=True,text=True,timeout=30)
record={'assertions':count,'returncode':result.returncode,'stdout':result.stdout,'stderr':result.stderr,
        'scope':'bounded independent comparison of includes, find_first and replace_all including empty patterns and offsets'}
(ROOT/'reports/compat-check.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record)); raise SystemExit(result.returncode)
