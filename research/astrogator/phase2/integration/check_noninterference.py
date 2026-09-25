#!/usr/bin/env python3
"""Executable control: faulty Python test cannot rewrite the oracle's past label."""
import json
from pathlib import Path
import subprocess
from frontier import ROOT, save
from run_python_tests import execute

HERE=Path(__file__).resolve().parent/'noninterference-control'
HERE.mkdir(exist_ok=True)
sources={
    'read_only':"from pathlib import Path\nassert Path('/etc/file.txt').read_text() == 'beginning'\n",
    # Path.open uses mode as its FIRST positional argument: an intentional
    # counterexample to the old name-based AST screen, kept out of model data.
    'mutating':"from pathlib import Path\nprint('changed by faulty test', file=Path('/etc/file.txt').open('w'))\nassert True\n",
    'after_mutation':"assert True\n"}
paths={}
for key,source in sources.items():
    p=HERE/(key+'.py');p.write_text(source);paths[key]='/suite/'+str(p.relative_to(ROOT))
image=subprocess.check_output(['docker','image','inspect','astrogator-lab:20260924-v2','--format','{{.Id}}'],text=True).strip()
r=execute('synthetic-noninterference-control','a06','baseline',ROOT/'benchmarks/original-pilot/a06/reference.yml',paths,image)
save(HERE/'result.json',r)
assert r['status']=='observed' and r['original_oracle'] is True
assert r['generated_tests']['read_only']['passed'] is True
assert r['generated_tests']['mutating']['status']=='state_mutation_invalid'
assert r['generated_tests']['after_mutation']['status']=='contaminated_state_abstention'
assert r['measured_state_contaminated'] is True
print('PASS: pre-test label retained; actual mutation detected; subsequent tests abstain.')
