#!/usr/bin/env python3
"""Freeze query-blind parameter mutation challenges before observing their outcomes."""
import copy,hashlib,json,re
from pathlib import Path
import yaml
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x): p.write_text(json.dumps(x,indent=2)+'\n')
# Deliberately selected controls: omission of permissions/content/identity, and sequence suffix.
# Selection based on task structures and previously recorded reference verifier coverage.
SPEC={
'a22':(' with ',{'mode':'0755'},{'mode':'0701'}),
'a23':(' with ',{'mode':'0770'},{'mode':'1770'}),
'a24':(' with ',{'mode':'0777'},{'mode':'0770'}),
'a26':(' with ',{'content':'WRONG\n'},{'content':'Authorized users only'}),
'a47':(' with ',{'owner':'root','group':'root'},{'mode':'0755'}),
'a63':(' in ',{'groups':'deploy'},{'group':'deploy'}),
'a64':(' with ',{'owner':'root'},{'group':'root'}),
'a67':(' to ',{'mode':'0600'},{'mode':'0777'}),
'a27':(';',None,None),
'a45':(';',None,None),
}
def main():
 rows=[]
 for b in json.loads((ROOT/'benchmarks/expanded.json').read_text()):
  d=ROOT/'benchmarks/expanded'/b['id']; out=HERE/'cases'/b['id'];out.mkdir(parents=True,exist_ok=True)
  q=b['formal_query']; queries={'candidate':q}
  programs={'reference':str((d/'reference.yml').relative_to(ROOT)),'discovery_mutant':str((d/'mutant.yml').relative_to(ROOT))}
  if b['id'] in SPEC:
   sep,m1,m2=SPEC[b['id']];queries['omission_control']=q.split(sep,1)[0]
   for n,patch in enumerate([m1,m2],1):
    plays=yaml.safe_load((d/'reference.yml').read_text())
    if patch:
     module=next(k for k in plays[0]['tasks'][-1] if k.startswith('ansible.builtin.'))
     plays[0]['tasks'][-1][module].update(patch)
    else:
     if n==1: plays[0]['tasks']=plays[0]['tasks'][:1]
     else:
      # Preserve requested prefix, replace missing suffix by unrelated benign action.
      plays[0]['tasks']=plays[0]['tasks'][:1]+[{'ansible.builtin.file':{'path':'/work/unrelated','state':'directory'}}]
    p=out/f'heldout_{n}.yml';p.write_text(yaml.safe_dump(plays,sort_keys=False));programs[f'heldout_{n}']=str(p.relative_to(ROOT))
  rows.append({'task_id':b['id'],'natural_language':b['natural_language'],'queries':queries,'programs':programs,
  'inputs_sha256':{str(p.relative_to(ROOT)):sha(p) for p in [d/'task.json',d/'setup.py',d/'check.py',*[ROOT/v for v in programs.values()]]}})
 dump(HERE/'frozen-design.json',{'protocol':'Candidate queries and existing mutants were previously observed. Two new challenge implementations per selected task frozen before outcomes. No post-selection or repair. Heldout means unused for screening, not independent external data; some share discovery fault classes. All local execution oracles remain author-written and imperfect.','selected_tasks':list(SPEC),'image':'astrogator-lab:20260924-v2','script_sha256':sha(Path(__file__)),'cases':rows})
if __name__=='__main__': main()
