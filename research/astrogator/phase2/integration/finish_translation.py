#!/usr/bin/env python3
"""Run one inference pool at a time; release Python execution before handbook."""
import os
os.environ["GOMAXPROCS"] = "2"

import json
from pathlib import Path
from orchestration import run, wait_success
from frontier import ROOT, save, sha
from settle_transport import main as settle

HERE=Path(__file__).resolve().parent

def checked(argv):run(argv,check=True)

def diagnose(run_name,dest):
    with dest.open('w') as output:
        run(['docker','run','--rm','--init','--network=none','--memory=192m','--cpus=.5','--pids-limit=64',
            '-v',f'{ROOT}:/suite:ro','astrogator-lab:20260924-v2','python3','/suite/phase2/integration/frontier_diagnostics.py','--run',run_name],stdout=output,check=True)

wait_success('astrogator-phase2-finish-inference.service')
settle(HERE/'frontier');settle(HERE/'frontier-full-judge')
# Execution-order amendment only: prompts, cohorts, models and retries unchanged.
checked([str(ROOT/'.venv/bin/python'),str(HERE/'python_generation.py'),'run','--workers','4'])
settle(HERE/'frontier-python')
config=HERE/'frontier-python/frozen-inputs.json'
cfg=json.loads(config.read_text())
outputs={}
for model in cfg['models']:
    for task in cfg['tasks']:
        path=HERE/'frontier-python'/model/(task['id']+'.json')
        record=json.loads(path.read_text())
        assert record['task']==task and record['frozen_input_sha256']==sha(config.read_bytes())
        outputs[str(path.relative_to(ROOT))]=sha(path.read_bytes())
save(HERE/'python-inference-complete.json',{'frozen_input_sha256':sha(config.read_bytes()),'outputs':outputs,
    'meaning':'All 16 Python inference records terminal after declared recovery; invalid records remain invalid. Releases execution while handbook inference runs.'})
checked([str(ROOT/'.venv/bin/python'),str(ROOT/'phase2/translation_method/run.py'),'run','--workers','4'])
settle(ROOT/'phase2/translation_method/runs')
diagnose('phase2/integration/frontier',HERE/'frontier-diagnostics.jsonl')
diagnose('phase2/translation_method/runs',ROOT/'phase2/translation_method/diagnostics.jsonl')
checked([str(ROOT/'.venv/bin/python'),str(HERE/'summarize_translation.py')])

from orchestration import mark_success
mark_success('astrogator-phase2-finish-translation.service')
