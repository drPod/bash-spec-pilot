#!/usr/bin/env python3
"""Drive the frozen 90-cell first-pass matrix (3 tasks x 2 conditions x 3 models x 5 attempts)
by shelling out to run_attempt.py for each cell, one model process at a time. Resumable: skips
any (task, condition, model, attempt) whose attempt directory already exists. Writes progress
to stdout and a running matrix_progress.json for STATUS updates without re-reading attempts.jsonl.
"""
import json
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
JOB = Path.home() / 'agent-jobs/astra-research/phase5/claude-resume/evaluation-artifact-4'

TASKS = ['nested_frame', 'nested_add_attrs', 'nested_remove_frame']
CONDITIONS = ['helper', 'base']
MODELS = ['pi:xai/grok-4.6', 'claude:sonnet', 'claude:fable']
ATTEMPTS = 5
SECONDS = 150


def attempt_dir_exists(task, condition, model):
    model_tag = model.replace('/', '_').replace(':', '-')
    return lambda a: (JOB / 'attempts' / f'{task}-{condition}-{model_tag}-a{a}').exists()


def main():
    cells = [(t, c, m) for t in TASKS for c in CONDITIONS for m in MODELS]
    total = len(cells) * ATTEMPTS
    done = 0
    t0 = time.time()
    progress_path = JOB / 'matrix_progress.json'
    for task, condition, model in cells:
        exists = attempt_dir_exists(task, condition, model)
        for attempt in range(ATTEMPTS):
            done += 1
            if exists(attempt):
                print(f'[{done}/{total}] SKIP (exists) {task} {condition} {model} a{attempt}', flush=True)
                continue
            cmd = [sys.executable, str(HERE / 'run_attempt.py'), '--task', task, '--condition', condition,
                   '--attempt', str(attempt), '--model', model, '--seconds', str(SECONDS)]
            t_cell = time.time()
            cp = subprocess.run(cmd, capture_output=True, text=True)
            elapsed = time.time() - t_cell
            out = cp.stdout.strip().splitlines()[-1] if cp.stdout.strip() else ''
            print(f'[{done}/{total}] {task} {condition} {model} a{attempt} '
                  f'({elapsed:.1f}s) {out or cp.stderr[-300:]}', flush=True)
            progress_path.write_text(json.dumps(dict(done=done, total=total,
                                                      elapsed_seconds=round(time.time() - t0, 1)), indent=2))
    print(f'MATRIX COMPLETE: {done}/{total} in {round(time.time() - t0, 1)}s', flush=True)


if __name__ == '__main__':
    main()
