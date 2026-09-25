#!/usr/bin/env python3
"""Finish all frozen predictions, retaining infrastructure-only retry history."""
import argparse
import json
from pathlib import Path
import subprocess
import time
import frontier as f

HERE=Path(__file__).resolve().parent

def retry_infrastructure(directory):
    old=f.OUT; f.OUT=directory
    config=json.loads((directory/'frozen-inputs.json').read_text())
    archived=[]
    for model in f.MODELS:
        for task in config['tasks']:
            path=directory/model/(task['id']+'.json')
            if not path.exists(): continue
            r=json.loads(path.read_text())
            if r['status']=='ok' or r.get('text'): continue
            # Only failures before any answer, never an unfavorable model prediction.
            archive=directory/'infrastructure-attempts'/model/(task['id']+'.attempt1.json')
            if archive.exists(): continue
            archive.parent.mkdir(parents=True,exist_ok=True); path.rename(archive)
            archived.append({'model':model,'task':task['id'],'previous_status':r['status'],
                             'previous_attempt_sha256':f.sha(archive.read_bytes())})
    if archived:
        f.save(directory/'infrastructure-retry-policy.json',{'policy':'Exactly one retry for transport/startup failure with no answer. Original errors retained. No retry of predictions, uncertain answers, syntax errors or tool use.', 'attempts':archived})
        f.run(argparse.Namespace(models=list(f.MODELS),modes=['fql','judge','checks'],workers=4))
    f.OUT=old

def main():
    while subprocess.run(['systemctl','--user','is-active','--quiet','astrogator-phase2-frontier-v2.service']).returncode==0:
        time.sleep(5)
    retry_infrastructure(HERE/'frontier')
    p=subprocess.run([str(f.ROOT/'.venv/bin/python'),str(HERE/'full_judge.py'),'run','--workers','4'])
    if p.returncode: raise SystemExit(p.returncode)
    retry_infrastructure(HERE/'frontier-full-judge')

if __name__=='__main__': main()
