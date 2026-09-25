#!/usr/bin/env python3
"""Context ablation follows handbook generation; only one inference pool."""
from pathlib import Path
from orchestration import run, wait_success
from frontier import ROOT
from settle_transport import main as settle

HERE=Path(__file__).resolve().parent
wait_success('astrogator-phase2-finish-translation.service')
run([str(ROOT/'.venv/bin/python'),str(HERE/'environment_judge.py'),'run','--workers','4'],check=True)
settle(HERE/'environment-judge')
