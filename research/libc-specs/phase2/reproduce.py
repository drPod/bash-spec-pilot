#!/usr/bin/env python3
"""Serial, bounded phase2 proof and C/Python/Lean replay. No API access required."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cache',type=Path,default=Path.home()/'.cache/bash-spec-pilot/phase2-replay')
    ap.add_argument('--tier',choices=['quick','standard'],default='standard')
    args=ap.parse_args()
    cache=args.cache.expanduser().resolve()
    repository=ROOT.parents[2]
    if cache==repository or repository in cache.parents:
        ap.error('cache/build/log directory must stay outside the repository')
    cache.mkdir(parents=True,exist_ok=True)
    env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',LEAN_NUM_THREADS='1',LEAN_STACK_SIZE_KB='16384')
    metrics={}
    def command(name,argv,seconds):
        log=cache/(name+'.log');timing=cache/(name+'.time')
        with log.open('w') as stream:
            cp=subprocess.run(['/usr/bin/time','-o',str(timing),'-f',
                '{"elapsed_seconds":%e,"peak_rss_kib":%M}',
                'timeout','--kill-after=3s',str(seconds)+'s','prlimit',
                '--as=3221225472:3221225472','--cpu='+str(seconds)+':'+str(seconds),
                '--fsize=134217728:134217728','--',*argv],env=env,
                stdout=stream,stderr=subprocess.STDOUT)
        if cp.returncode:
            raise RuntimeError(f'{name} exited {cp.returncode}; inspect {log}')
        metrics[name]=json.loads(timing.read_text())
        print(name+': '+json.dumps(metrics[name]),flush=True)
    check=cache/'check.json'
    command('proof',[sys.executable,'-B',str(ROOT/'run_checks.py'),
                    '--cache',str(cache/'lean-check'),'--out',str(check)],180)
    proof=json.loads(check.read_text())
    exe=proof['executable'];source=proof['staged_c_source']
    if sha(exe)!=proof['executable_sha256'] or sha(source)!=proof['source_hashes']['relay.c']:
        raise RuntimeError('staged artifact changed before differential replay')
    command('validation',[sys.executable,'-u','-B',str(ROOT/'validation/validate.py'),
                          '--source',source,'--model',exe,'--workers','1',
                          '--tier',args.tier,'--out',str(cache/'validation')],600)
    tests=json.loads((cache/'validation/results.json').read_text())
    if tests['overall']!='PASS' or tests['model']['sha256']!=proof['executable_sha256']:
        raise RuntimeError('validation/model identity did not pass')
    if tests['source']['sha256']!=proof['source_hashes']['relay.c']:
        raise RuntimeError('C snapshot identity differs')
    result={'overall':'PASS','proof_record_sha256':sha(check),
            'validation_record_sha256':sha(cache/'validation/results.json'),
            'reproduce_script_sha256':sha(__file__), 'measurements':metrics,
            'proof':proof,'validation':tests,
            'scope':'Pure Lean model checked; C parsing/lowering, native runtime, primitives and shell composition unverified.'}
    target=cache/'result.json';target.write_text(json.dumps(result,indent=2)+'\n')
    print('Result: '+str(target))

if __name__=='__main__':
    main()
