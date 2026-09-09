#!/usr/bin/env python3
"""One bounded, fresh-context model attempt on a frozen evaluation-expanded task, then the
frozen checker. Independent redesign of ../evaluation/run_attempt.py: same discipline (no
tools, no session continuation, no context files, wall limit, checker unchanged), extended to
three distinct models/harnesses and to bounded assisted feedback rounds. First-pass attempts
(--feedback-rounds 0) are directly comparable to the original 12-cell diagnostic's protocol.

Model spec is "<harness>:<model-id>", one of:
  pi:xai/grok-4.6        -> Pi 0.84.2, --no-tools, --no-context-files (as before)
  claude:sonnet          -> claude CLI, --tools "" (fresh subprocess, no repo cwd)
  claude:fable           -> claude CLI, --tools "" (fresh subprocess, no repo cwd)

Every model call runs from a private empty scratch directory (not the repository), so no
project CLAUDE.md, memory or ambient tool schema/context leaks into the frozen prompt beyond
what the harness always injects for that model (recorded, not concealed, in
harness_overhead_tokens_first_call in the summary -- this is a model+harness confound, not a
pure model comparison; see REPORT.md).
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
JOB = Path.home() / 'agent-jobs/astra-research/phase5/claude-resume/evaluation-artifact-4'
SCRATCH = Path.home() / '.cache/bash-spec-pilot/phase5-evaluation-expanded/model-scratch'

RULES = '''You are given a Lean 4 (v4.31.0, core only, no Mathlib) file whose final theorem ends in `:=`
with the proof missing. Everything above the final theorem is frozen and compiles.

Reply with exactly one fenced ```lean code block containing ONLY the proof that goes after the
final `:=` (start it with `by` for a tactic proof, or give a term). Do not restate the theorem,
do not add declarations, imports, options, `sorry`, `admit`, `native_decide` or `decide +kernel`.
Anything outside the code block is ignored. Keep it short; the checker re-indents your lines.
'''

FEEDBACK_RULES = '''Your previous submission was rejected by the checker. Reject reason and (if a build was
attempted) the compiler error tail are shown below. Reply again with exactly one fenced
```lean code block containing ONLY the corrected proof body (same rules as before: no sorry,
admit, native_decide, decide +kernel, new declarations, imports or options).
'''

SYSTEM_PROMPT = ('You take part in a frozen, controlled Lean 4 proof-regeneration evaluation. '
                  'Follow the user instructions exactly; output nothing beyond what is asked.')


def build_prompt(task, condition):
    template = (TASKS / task / f'{condition}.template.lean').read_text()
    return RULES + '\nFile:\n```lean\n' + template + '```\n'


def extract_block(text):
    blocks = re.findall(r'```(?:lean4?|lean)?\s*\n(.*?)```', text, re.S)
    return blocks[-1] if blocks else None


def call_pi(model_id, prompt, out, seconds):
    provider, model = model_id.split('/', 1)
    (out / 'prompt.txt').write_text(prompt)
    cmd = ['pi', '--provider', provider, '--model', model, '--print', '--mode', 'json', '--no-tools',
           '--no-skills', '--no-prompt-templates', '--no-extensions', '--no-context-files',
           '--session-dir', str(out / 'sessions'), '@' + str(out / 'prompt.txt')]
    started = time.time()
    with (out / 'events.jsonl').open('w') as ev, (out / 'stderr.log').open('w') as err:
        try:
            cp = subprocess.run(cmd, stdout=ev, stderr=err, timeout=seconds, cwd=str(out))
            code, timed_out = cp.returncode, False
        except subprocess.TimeoutExpired:
            code, timed_out = None, True
    elapsed = time.time() - started
    texts, usage = [], {}
    for line in (out / 'events.jsonl').read_text().splitlines():
        try:
            d = json.loads(line)
        except ValueError:
            continue
        if d.get('type') == 'message_end' and d.get('message', {}).get('role') == 'assistant':
            t = '\n'.join(c.get('text', '') for c in d['message'].get('content', []) if c.get('type') == 'text')
            if t:
                texts.append(t)
        if isinstance(d.get('usage'), dict):
            usage = d['usage']
    response = texts[-1] if texts else ''
    return dict(response=response, elapsed=elapsed, exit_status=code, timed_out=timed_out,
                usage=usage, harness=f'pi 0.84.2 --print --mode json --no-tools model={model_id}')


EMPTY_MCP_CONFIG = SCRATCH.parent / 'empty-mcp.json'


def call_claude(model_alias, prompt, out, seconds):
    scratch = SCRATCH / out.name
    scratch.mkdir(parents=True, exist_ok=True)
    EMPTY_MCP_CONFIG.parent.mkdir(parents=True, exist_ok=True)
    if not EMPTY_MCP_CONFIG.exists():
        EMPTY_MCP_CONFIG.write_text('{"mcpServers":{}}\n')
    (out / 'prompt.txt').write_text(prompt)
    # --effort low: at default effort this call runs ~9.8k thinking tokens and ~85s wall for
    # this task family (measured); default effort risks the wall budget with zero partial
    # output on a non-streaming --output-format json timeout. --strict-mcp-config with an
    # empty server list drops this account's ambient MCP tool catalog (Google Drive,
    # Higgsfield, ...) that --tools "" alone does not suppress.
    cmd = ['claude', '-p', '--model', model_alias, '--tools', '', '--no-session-persistence',
           '--strict-mcp-config', '--mcp-config', str(EMPTY_MCP_CONFIG), '--effort', 'low',
           '--system-prompt', SYSTEM_PROMPT, '--output-format', 'json']
    started = time.time()
    try:
        cp = subprocess.run(cmd, input=prompt, capture_output=True, text=True, timeout=seconds, cwd=str(scratch))
        code, timed_out = cp.returncode, False
        stdout = cp.stdout
    except subprocess.TimeoutExpired as e:
        code, timed_out = None, True
        stdout = (e.stdout or b'').decode() if isinstance(e.stdout, bytes) else (e.stdout or '')
    elapsed = time.time() - started
    (out / 'raw_stdout.json').write_text(stdout)
    response, usage, cost = '', {}, None
    try:
        d = json.loads(stdout.strip().splitlines()[-1]) if stdout.strip() else {}
        response = d.get('result', '')
        usage = d.get('usage', {})
        cost = d.get('total_cost_usd')
    except (ValueError, IndexError):
        pass
    return dict(response=response, elapsed=elapsed, exit_status=code, timed_out=timed_out,
                usage=usage, cost_usd=cost, harness=f'claude CLI -p --model {model_alias} --tools ""')


def call_model(model_spec, prompt, out, seconds):
    harness, model_id = model_spec.split(':', 1)
    if harness == 'pi':
        return call_pi(model_id, prompt, out, seconds)
    if harness == 'claude':
        return call_claude(model_id, prompt, out, seconds)
    raise ValueError('unknown harness: ' + harness)


def run_check(task, condition, submission_path, name):
    cp = subprocess.run([sys.executable, str(HERE / 'check_attempt.py'), '--task', task,
                         '--condition', condition, '--submission', str(submission_path),
                         '--name', name], capture_output=True, text=True)
    if cp.stdout.strip():
        return json.loads(cp.stdout.strip().splitlines()[-1])
    return dict(accepted=False, reject_reason='checker crashed: ' + cp.stderr[-800:])


def build_error_tail(check):
    build = (check or {}).get('gates', {}).get('build') if isinstance(check, dict) else None
    if not build:
        return ''
    return '\n'.join(build.get('errors', [])[:8])


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--task', required=True)
    ap.add_argument('--condition', required=True, choices=['helper', 'base'])
    ap.add_argument('--attempt', type=int, required=True)
    ap.add_argument('--seconds', type=int, default=120)
    ap.add_argument('--model', required=True, help='"<harness>:<model-id>", e.g. claude:sonnet')
    ap.add_argument('--feedback-rounds', type=int, default=0,
                    help='bounded assisted rounds after a rejected first pass (0 = first-pass only)')
    args = ap.parse_args()
    model_tag = args.model.replace('/', '_').replace(':', '-')
    name = f'{args.task}-{args.condition}-{model_tag}-a{args.attempt}'
    out = JOB / 'attempts' / name
    if out.exists():
        ap.error('attempt directory exists; attempts are never overwritten')
    out.mkdir(parents=True)

    prompt = build_prompt(args.task, args.condition)
    started_utc = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds')
    rounds = []
    submission_path = out / 'submission.lean'
    current_prompt = prompt
    check = None
    for round_no in range(args.feedback_rounds + 1):
        round_dir = out / f'round{round_no}'
        round_dir.mkdir()
        result = call_model(args.model, current_prompt, round_dir, args.seconds)
        (round_dir / 'response.md').write_text(result['response'])
        block = extract_block(result['response'])
        round_rec = dict(round=round_no, prompt_sha256=None, model_elapsed_seconds=round(result['elapsed'], 2),
                         model_exit_status=result['exit_status'], timed_out=result['timed_out'],
                         response_chars=len(result['response']), block_found=block is not None,
                         usage=result.get('usage'), cost_usd=result.get('cost_usd'), harness=result['harness'])
        if block is not None:
            submission_path.write_text(block)
            check = run_check(args.task, args.condition, submission_path, f'{name}-r{round_no}')
        else:
            check = dict(accepted=False, reject_reason='no lean code block in response (or timeout)')
        round_rec['check'] = check
        rounds.append(round_rec)
        if check.get('accepted') or round_no == args.feedback_rounds:
            break
        tail = build_error_tail(check)
        current_prompt = (FEEDBACK_RULES + f"\nReject reason: {check.get('reject_reason')}\n"
                          + (f"Compiler error tail:\n{tail}\n" if tail else '')
                          + '\nOriginal file:\n```lean\n' + (TASKS / args.task / f'{args.condition}.template.lean').read_text() + '```\n'
                          + f'\nYour previous submission:\n```lean\n{block or ""}\n```\n')

    record = dict(schema='phase5-evaluation-expanded-attempt/1', name=name, task=args.task,
                  condition=args.condition, attempt=args.attempt, model=args.model,
                  wall_limit_seconds=args.seconds, started_utc=started_utc,
                  feedback_rounds_used=len(rounds) - 1, feedback_rounds_budget=args.feedback_rounds,
                  interventions=('none: first-pass, fresh context' if args.feedback_rounds == 0 else
                                 f'{len(rounds) - 1} assisted feedback round(s): checker reject reason and '
                                 'compiler error tail returned to the SAME fresh model process each round; '
                                 'no human or agent edited the submission text'),
                  rounds=rounds, check=check)
    (out / 'attempt.json').write_text(json.dumps(record, indent=2) + '\n')
    with (JOB / 'attempts.jsonl').open('a') as f:
        f.write(json.dumps(record) + '\n')
    print(json.dumps({'name': name, 'rounds_used': len(rounds), 'accepted': check.get('accepted'),
                      'reason': check.get('reject_reason')}))


if __name__ == '__main__':
    main()
