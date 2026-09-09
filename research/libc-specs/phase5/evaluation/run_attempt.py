#!/usr/bin/env python3
"""One bounded, fresh-context model attempt on a frozen task, then the frozen checker.

The model (Pi CLI, xai/grok-4.6) runs with all tools disabled, no session continuation, no
context files, and a wall limit. It sees only: the frozen template for the task/condition,
the statements (never proofs) of the imported declarations named in the manifest, and the
output rules. The response's single ```lean block is saved verbatim as the submission and
handed to check_attempt.py unchanged (the checker only re-indents lines by two spaces).
Receipts, sessions and raw events stay in the job directory, outside the repository.
"""
import argparse
import datetime
import json
from pathlib import Path
import re
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
TASKS = HERE / 'tasks'
JOB = Path.home() / 'agent-jobs/astra-research/phase5/claude-resume/evaluation'

IMPORT_STATEMENTS = {
    'shell_status': '',
    'byte_relay': '''Imported declarations you may use (statements only; proofs exist in the library):
  theorem PointerRelay.run_detailed_eq (input : List BufferRelay.Byte) (reads writes : List Int) :
      PointerRelay.observe (PointerRelay.run input reads writes).state
        = BufferRelay.runDetailed input reads writes
  theorem ShellObservation.command_refines (concrete : Primitive Atom C) (abstract : Primitive Atom A)
      (R : C → A → Prop) (hp : PrimitiveRefines concrete abstract R)
      (cmd : Command Atom) (c c' : C) (rc : Nat) (he : Exec concrete cmd c rc c') :
      ∀ a, R c a → ∃ a', Exec abstract cmd a rc a' ∧ R c' a'
  (ShellObservation.Command/Exec/Primitive/PrimitiveRefines are as in phase3 ShellObservation:
   Exec has constructors call, seq, andZero, andNonzero, orZero, orNonzero.)
''',
    'partial_error': '',
}

RULES = '''You are given a Lean 4 (v4.31.0, core only, no Mathlib) file whose final theorem ends in `:=`
with the proof missing. Everything above the final theorem is frozen and compiles.

Reply with exactly one fenced ```lean code block containing ONLY the proof that goes after the
final `:=` (start it with `by` for a tactic proof, or give a term). Do not restate the theorem,
do not add declarations, imports, options, `sorry`, `admit`, `native_decide` or `decide +kernel`.
Anything outside the code block is ignored. Keep it short; the checker re-indents your lines.
'''


def build_prompt(task, condition):
    template = (TASKS / task / f'{condition}.template.lean').read_text()
    return RULES + '\n' + IMPORT_STATEMENTS[task] + '\nFile:\n```lean\n' + template + '```\n'


def extract_block(text):
    blocks = re.findall(r'```(?:lean4?|lean)?\s*\n(.*?)```', text, re.S)
    return blocks[-1] if blocks else None


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--task', required=True)
    ap.add_argument('--condition', required=True, choices=['helper', 'base'])
    ap.add_argument('--attempt', type=int, required=True)
    ap.add_argument('--seconds', type=int, default=120)
    ap.add_argument('--model', default='xai/grok-4.6')
    args = ap.parse_args()
    name = f'{args.task}-{args.condition}-a{args.attempt}'
    out = JOB / 'attempts' / name
    if out.exists():
        ap.error('attempt directory exists; attempts are never overwritten')
    out.mkdir(parents=True)
    prompt = build_prompt(args.task, args.condition)
    (out / 'prompt.txt').write_text(prompt)
    provider, model = args.model.split('/', 1)
    cmd = ['pi', '--provider', provider, '--model', model, '--print', '--mode', 'json', '--no-tools',
           '--no-skills', '--no-prompt-templates', '--no-extensions', '--no-context-files',
           '--session-dir', str(out / 'sessions'), '@' + str(out / 'prompt.txt')]
    started = time.time()
    with (out / 'events.jsonl').open('w') as ev, (out / 'stderr.log').open('w') as err:
        try:
            cp = subprocess.run(cmd, stdout=ev, stderr=err, timeout=args.seconds, cwd=str(out))
            code, timed_out = cp.returncode, False
        except subprocess.TimeoutExpired:
            code, timed_out = None, True
    elapsed = time.time() - started
    texts = []
    for line in (out / 'events.jsonl').read_text().splitlines():
        try:
            d = json.loads(line)
        except ValueError:
            continue
        if d.get('type') == 'message_end' and d.get('message', {}).get('role') == 'assistant':
            t = '\n'.join(c.get('text', '') for c in d['message'].get('content', []) if c.get('type') == 'text')
            if t:
                texts.append(t)
    response = texts[-1] if texts else ''
    (out / 'response.md').write_text(response)
    block = extract_block(response)
    record = dict(schema='phase5-evaluation-attempt/1', name=name, task=args.task, condition=args.condition,
                  attempt=args.attempt, model=args.model, harness='pi 0.84.2 --print --mode json --no-tools',
                  thinking='pi default (not set)', wall_limit_seconds=args.seconds,
                  started_utc=datetime.datetime.fromtimestamp(started, datetime.timezone.utc).isoformat(timespec='seconds'),
                  model_elapsed_seconds=round(elapsed, 2), model_exit_status=code, timed_out=timed_out,
                  response_chars=len(response), block_found=block is not None, feedback_rounds=0,
                  interventions='none: first-pass, fresh context, no human or agent edits to the submission',
                  check=None)
    if block is not None:
        (out / 'submission.lean').write_text(block)
        cp = subprocess.run([sys.executable, str(HERE / 'check_attempt.py'), '--task', args.task,
                             '--condition', args.condition, '--submission', str(out / 'submission.lean'),
                             '--name', name], capture_output=True, text=True)
        record['check'] = json.loads(cp.stdout.strip().splitlines()[-1]) if cp.stdout.strip() else \
            dict(accepted=False, reject_reason='checker crashed: ' + cp.stderr[-500:])
    else:
        record['check'] = dict(accepted=False, reject_reason='no lean code block in response (or timeout)')
    (out / 'attempt.json').write_text(json.dumps(record, indent=2) + '\n')
    with (JOB / 'attempts.jsonl').open('a') as f:
        f.write(json.dumps(record) + '\n')
    print(json.dumps({k: record[k] for k in ('name', 'model_elapsed_seconds', 'timed_out', 'block_found')}
                     | {'accepted': record['check']['accepted'], 'reason': record['check'].get('reject_reason')}))


if __name__ == '__main__':
    main()
