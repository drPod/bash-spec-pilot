#!/usr/bin/env python3
"""Prospectively frozen extension from the identity sample to all 422 programs.

Existing 86 predictions/model are retained without regeneration; this extension
requests only the remaining 336/model, using exactly the same prompt constructor.
"""
import argparse
import json
import re
from pathlib import Path
import frontier as f

HERE=Path(__file__).resolve().parent

def main():
    p=argparse.ArgumentParser(); p.add_argument('mode',choices=['prepare','run']); p.add_argument('--workers',type=int,default=3); a=p.parse_args()
    base=json.loads((f.OUT/'frozen-inputs.json').read_text())
    previous={t['sample_id'] for t in base['tasks'] if t['mode']=='judge'}
    originals={r['id']:r for r in json.loads((f.ROOT/'benchmarks/original.json').read_text())}
    rows=[json.loads(l) for l in (f.ROOT/'data/manifest.jsonl').read_text().splitlines()]
    tasks=[]
    selected=[r for r in rows if r['task_id'] in f.CASES and r['sample_id'] not in previous and 'response' in r['artifacts']]
    for r in selected:
        art=r['artifacts']['response']; data=(f.ROOT/art['path']).read_bytes(); assert f.sha(data)==art['sha256']
        blinded=re.sub(r'^- name:.*$', '- name: Candidate playbook',data.decode(),flags=re.M)
        tasks.append({'id':'judge-'+r['sample_id'].replace('/','-'),'mode':'judge','task_id':r['task_id'],
            'sample_id':r['sample_id'],'code_sha256':art['sha256'],'messages':[
                {'role':'system','content':f.JUDGE_SYSTEM}, {'role':'user','content':
                f"Request: {originals[r['task_id']]['natural_language']}\nInitial states: {f.CASES[r['task_id']][2]}\nPlaybook:\n{blinded}"}]})
    assert len(tasks)==336
    config={'version':1,'tasks':tasks,'models':f.MODELS,'initial_selection_sha256':f.sha((f.OUT/'frozen-inputs.json').read_bytes()),
            'source_sha256':{p.name:f.sha(p.read_bytes()) for p in [Path(__file__),Path(f.__file__)]},
            'design':'All remaining processed programs on same four tasks; no outcome-based selection. Same generation prompt and settings. Join initial86+remaining336 only after complete.'}
    f.OUT=HERE/'frontier-full-judge'
    path=f.OUT/'frozen-inputs.json'
    if path.exists(): assert json.loads(path.read_text())==config
    else: f.save(path,config)
    if a.mode=='run': f.run(argparse.Namespace(models=list(f.MODELS),modes=['judge'],workers=a.workers))
    else: print(len(tasks),'additional programs/model frozen',f.sha(path.read_bytes()))

if __name__=='__main__': main()
