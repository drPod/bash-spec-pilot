#!/usr/bin/env python3
"""Execute after all Python predictions settle; overlap handbook inference."""
import json
import os
os.environ["GOMAXPROCS"] = "2"

from pathlib import Path
import time
from orchestration import run
from frontier import ROOT, sha

HERE=Path(__file__).resolve().parent
marker=HERE/'python-inference-complete.json'
while not marker.exists():
    p=run(['systemctl','--user','is-active','--quiet','astrogator-phase2-finish-translation.service'])
    if p.returncode:
        raise RuntimeError('Translation/Python-generation launcher ended before completion marker')
    time.sleep(5)
record=json.loads(marker.read_text())
assert record['frozen_input_sha256']==sha((HERE/'frontier-python/frozen-inputs.json').read_bytes())
for name,digest in record['outputs'].items():assert sha((ROOT/name).read_bytes())==digest
run([str(ROOT/'.venv/bin/python'),str(HERE/'run_python_tests.py'),'--full','--workers','3'],check=True)
import summarize_tests
summarize_tests.DEST=HERE/'python-tests'
summarize_tests.main()

from orchestration import mark_success
mark_success('astrogator-phase2-python-baseline.service')
