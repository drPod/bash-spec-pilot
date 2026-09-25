#!/usr/bin/env python3
"""One sequential recovery pass for proven client-startup resource failures.

Protocol amendment: scheduler concurrency hit the host's 256-task cgroup cap.
Retry only records with no answer AND an explicit startup resource diagnostic.
Never retry a generated answer, invalid query, uncertain verdict, refusal,
model timeout, or API failure. Preserve every attempt and immutable prompt.
"""
import json
from pathlib import Path
import frontier as f

ROOT=Path(__file__).resolve().parent

def main(directory):
    f.OUT=directory; cfg=json.loads((directory/'frozen-inputs.json').read_text())
    protocol={'reason':'Host cgroup task-limit saturation; serial recovery after parallel generation.',
              'eligibility':'No answer and explicit BlockingIOError/pthread/threadpool/Bun client-startup resource failure.',
              'maximum_additional_attempts':1,'selection_uses_prediction_verdict':False,
              'source_sha256':f.sha(Path(__file__).read_bytes())}
    path=directory/'serial-recovery-protocol.json'
    if path.exists(): assert json.loads(path.read_text())==protocol
    else: f.save(path,protocol)
    for model in f.MODELS:
        for task in cfg['tasks']:
            p=directory/model/(task['id']+'.json')
            if not p.exists(): continue
            r=json.loads(p.read_text()); diag=str(r.get('error',''))+'\n'+r.get('stderr','')
            if r.get('text') or r['status']=='ok': continue
            if not any(s in diag for s in ['BlockingIOError','pthread_create','ThreadPoolBuildError','failed to spawn thread','Resource temporarily unavailable']): continue
            archive=directory/'serial-recovery-attempts'/model/(task['id']+'.before.json')
            if archive.exists(): continue
            archive.parent.mkdir(parents=True,exist_ok=True);p.rename(archive)
            f.infer(model,task)
            out=json.loads(p.read_text()); out['serial_recovery_previous_sha256']=f.sha(archive.read_bytes());f.save(p,out)
            print(directory.name,model,task['id'],out['status'],flush=True)

if __name__=='__main__':
    import sys
    main(Path(sys.argv[1]).resolve())
