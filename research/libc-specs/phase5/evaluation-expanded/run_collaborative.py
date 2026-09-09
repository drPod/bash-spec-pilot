#!/usr/bin/env python3
"""One bounded 'agent-assisted collaborative baseline' run per task (helper condition):
claude:sonnet gets REAL Read/Edit/Bash tool access to a private scratch copy of the minimal
lake project (never the live repository) and is told to make `lake build` succeed itself,
under a wall-clock budget. This is NOT a human baseline (none was collected; see REPORT.md)
and NOT directly comparable to the frozen no-tools first-pass cells (different tool access,
self-directed iteration, no fixed attempt count). Acceptance is decided independently
afterward by running the SAME frozen check_attempt.py against whatever the run leaves behind,
not by the run's own self-report.
"""
import argparse
import datetime
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
TASKS = HERE / 'tasks'
JOB = Path.home() / 'agent-jobs/astra-research/phase5/claude-resume/evaluation-artifact-4'
SCRATCH_ROOT = Path.home() / '.cache/bash-spec-pilot/phase5-evaluation-expanded/collaborative-scratch'
LEAN_TOOLCHAIN = 'leanprover/lean4:v4.31.0\n'
LAKEFILE = ('name = "collab_scratch"\ndefaultTargets = ["CalculusNested"]\n'
           'moreLeanArgs = ["-j1", "-s16384", "-DwarningAsError=true", "-DElab.async=false"]\n'
           '[[lean_lib]]\nname = "CalculusNested"\n')

PROMPT_TEMPLATE = '''You are working in this directory only. It contains a minimal Lean 4 (v4.31.0, core
only, no Mathlib) lake project with one file, CalculusNested.lean, whose final theorem
"{theorem}" ends in `:=` with the proof missing.

Your task: edit CalculusNested.lean to complete the proof, then run `lake build
+CalculusNested:olean` yourself (a wall-clock/turn budget applies; work efficiently) until it
succeeds. Do not change the theorem statement, add sorry/admit/axiom, or add new imports/
declarations elsewhere in the file. Do not touch any file outside this directory. When the
build succeeds, stop.
'''


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--task', required=True)
    ap.add_argument('--condition', default='helper', choices=['helper', 'base'])
    ap.add_argument('--seconds', type=int, default=600)
    args = ap.parse_args()
    manifest = json.loads((TASKS / 'manifest.json').read_text())
    theorem = manifest['tasks'][args.task]['theorem']
    name = f'collab-{args.task}-{args.condition}'
    out = JOB / 'collaborative' / name
    if out.exists():
        ap.error('collaborative run directory exists; never overwritten')
    out.mkdir(parents=True)
    scratch = SCRATCH_ROOT / name
    if scratch.exists():
        shutil.rmtree(scratch)
    scratch.mkdir(parents=True)
    (scratch / 'lean-toolchain').write_text(LEAN_TOOLCHAIN)
    (scratch / 'lakefile.toml').write_text(LAKEFILE)
    template = (TASKS / args.task / f'{args.condition}.template.lean').read_text()
    # Give the agent the full frozen template with the real ' := \n\nend ' gap so it edits the
    # actual splice point, not a paraphrase.
    (scratch / 'CalculusNested.lean').write_text(template)
    prompt = PROMPT_TEMPLATE.format(theorem=theorem)
    (out / 'prompt.txt').write_text(prompt)
    cmd = ['claude', '-p', '--model', 'sonnet', '--permission-mode', 'acceptEdits',
           '--allowedTools', 'Read,Edit,Bash(lake*)', '--strict-mcp-config',
           '--mcp-config', str(Path.home() / '.cache/bash-spec-pilot/phase5-evaluation-expanded/empty-mcp.json'),
           '--no-session-persistence', '--effort', 'low', '--output-format', 'json']
    started = time.time()
    try:
        cp = subprocess.run(cmd, input=prompt, capture_output=True, text=True,
                            timeout=args.seconds, cwd=str(scratch))
        code, timed_out, stdout, stderr = cp.returncode, False, cp.stdout, cp.stderr
    except subprocess.TimeoutExpired as e:
        code, timed_out = None, True
        stdout = e.stdout or ''
        stderr = e.stderr or ''
    elapsed = time.time() - started
    (out / 'raw_stdout.json').write_text(stdout)
    (out / 'stderr.log').write_text(stderr)
    final_file = scratch / 'CalculusNested.lean'
    (out / 'final_CalculusNested.lean').write_text(final_file.read_text())
    # Extract the submitted proof body: everything the agent put between the frozen
    # signature's ':=' and 'end CalculusNested', independent of the run's own claims.
    text = final_file.read_text()
    marker = ':=\n'
    idx = text.rfind(theorem.split('.')[-1])
    check = dict(accepted=False, reject_reason='could not locate submission in edited file')
    submission_path = out / 'submission.lean'
    tail = text.split('end CalculusNested')[0]
    if ' :=' in tail:
        body = tail.rsplit(' :=', 1)[1]
        submission_path.write_text(body)
        cp2 = subprocess.run([sys.executable, str(HERE / 'check_attempt.py'), '--task', args.task,
                             '--condition', args.condition, '--submission', str(submission_path),
                             '--name', name], capture_output=True, text=True)
        if cp2.stdout.strip():
            check = json.loads(cp2.stdout.strip().splitlines()[-1])
        else:
            check = dict(accepted=False, reject_reason='checker crashed: ' + cp2.stderr[-800:])
    record = dict(schema='phase5-evaluation-expanded-collaborative/1', name=name, task=args.task,
                 condition=args.condition, model='claude:sonnet (tools: Read,Edit,Bash(lake*))',
                 label='agent-assisted collaborative baseline (NOT a human baseline, NOT a first-pass cell)',
                 wall_limit_seconds=args.seconds, started_utc=datetime.datetime.fromtimestamp(
                     started, datetime.timezone.utc).isoformat(timespec='seconds'),
                 elapsed_seconds=round(elapsed, 2), exit_status=code, timed_out=timed_out,
                 independently_rechecked=True, check=check)
    (out / 'record.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps({'name': name, 'accepted': check.get('accepted'), 'reason': check.get('reject_reason')}))


if __name__ == '__main__':
    main()
