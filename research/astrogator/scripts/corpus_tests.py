#!/usr/bin/env python3
"""Task-level generated checks, reference-control gate, then frozen candidates.

This is a gated declarative-test baseline, not unrestricted Python generation.
Generation never reads reference code, oracle source, or execution labels.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import uuid
from generated_checks import schema, validate
from llm_pilot import request, extract
from original_pilot import CASES

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'experiments/four-task-tests-v1'


def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()


def generate():
    OUT.mkdir(parents=True, exist_ok=True)
    originals = {r['id']: r for r in json.loads((ROOT / 'benchmarks/original.json').read_text())}
    system = '''Generate read-only checks to run AFTER one Ansible playbook execution.
Use the supplied JSON schema. Check the requested final state separately for the
baseline and adversarial initial states. Do not assert that the initial state
remains unless the request requires preservation. Use scenario=both only when
the same assertion applies to both. Include at least one check for each scenario.
Kinds: directory(path), absent(path), mode(path,value in octal), content(path,value
as exact full text), contains(path,value), not_contains(path,value), member(user,
group), package(name,version), running(name,boolean value), password_locked(user).
Only assert requirements stated by the task. Return the checks object only.'''
    config = {'script_sha256': digest(Path(__file__)),
              'request_adapter_sha256': digest(ROOT / 'scripts/llm_pilot.py'),
              'evaluator_sha256': digest(ROOT / 'scripts/generated_checks.py'),
              'public_scenarios': {t: v[2] for t, v in CASES.items()},
              'system': system, 'schema': schema(), 'max_tokens': 400,
              'gate': 'Both known-good reference states must pass; otherwise abstain for task'}
    cfg = OUT / 'generation-config.json'
    if cfg.exists():
        if json.loads(cfg.read_text()) != config: raise RuntimeError('Generation configuration changed')
    else: cfg.write_text(json.dumps(config, indent=2) + '\n')
    for task, (_, _, states) in CASES.items():
        dest = OUT / f'{task}.json'
        if dest.exists(): continue
        r = request([{'role': 'system', 'content': system}, {'role': 'user', 'content':
                     f"Request: {originals[task]['natural_language']}\nInitial states: {states}"}],
                    'brancher-llm', 400, schema=schema())
        r['task_id'] = task
        dest.write_text(json.dumps(r, indent=2) + '\n')
        dest.with_suffix('.checks.json').write_text(extract(r['text']) + '\n')
        print(task, r.get('finish_reason', r.get('error')), flush=True)


def execute(sample, task, scenario, path, image):
    name = 'astro-tests-' + uuid.uuid4().hex[:12]
    options = {'candidate': '/suite/' + str(path.relative_to(ROOT)), 'iterations': 1,
               'test': '/suite/' + str((OUT / f'{task}.checks.json').relative_to(ROOT))}
    cmd = ['docker', 'run', '--rm', '--init', '--name', name, '--network=none',
           '--memory=384m', '--cpus=.75', '--pids-limit=96', '--cap-drop=NET_RAW',
           '-v', f'{ROOT}:/suite:ro', image, 'python3', '/suite/scripts/container_case.py',
           task, scenario, 'candidate', json.dumps(options)]
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=75)
        if p.returncode: raise RuntimeError(p.stderr[-1500:])
        r = json.loads(p.stdout)
        if r['input_sha256']['candidate'] != digest(path): raise RuntimeError('Candidate hash mismatch')
    except Exception as e:
        r = {'task_id': task, 'scenario': scenario, 'status': 'harness_error', 'error': str(e)}
    finally: subprocess.run(['docker', 'rm', '-f', name], capture_output=True)
    return {**r, 'sample_id': sample, 'test_sha256': digest(OUT / f'{task}.checks.json')}


def run(candidates):
    selection = json.loads((ROOT / 'experiments/four-task-full-v1/frozen-inputs.json').read_text())
    # Use the exact image and fixture/oracle/runner bytes from the independent run.
    for path, expected in selection['source_sha256'].items():
        if digest(ROOT / path) != expected: raise RuntimeError('Execution source changed: ' + path)
    hashes = {str(p.relative_to(ROOT)): digest(p) for p in
              [Path(__file__), ROOT / 'scripts/generated_checks.py', *OUT.glob('*.checks.json')]}
    cfg = {'source_sha256': hashes, 'image_id': selection['image_id'],
           'selection_sha256': hashlib.sha256(json.dumps(selection['samples'], sort_keys=True).encode()).hexdigest()}
    frozen = OUT / 'execution-config.json'
    if frozen.exists():
        if json.loads(frozen.read_text()) != cfg: raise RuntimeError('Test inputs changed')
    else: frozen.write_text(json.dumps(cfg, indent=2) + '\n')
    gates = {}
    for task in selection['tasks']:
        try: validate(json.loads((OUT / f'{task}.checks.json').read_text()))
        except Exception as e:
            gates[task] = {'status': 'invalid', 'error': str(e)}; continue
        results = []
        for scenario in selection['scenarios']:
            dest = OUT / f'control-{task}-{scenario}.json'
            if not dest.exists():
                r = execute('reference/' + task, task, scenario,
                            ROOT / 'benchmarks/original-pilot' / task / 'reference.yml', selection['image_id'])
                dest.write_text(json.dumps(r, indent=2) + '\n')
            results.append(json.loads(dest.read_text()))
        good = all(r['status'] == 'passed' and r.get('generated_test', {}).get('status') == 'evaluated'
                   and r['generated_test'].get('passed') is True for r in results)
        gates[task] = {'status': 'eligible' if good else 'reference_control_failed',
                       'controls': [r.get('generated_test', {}) for r in results]}
    (OUT / 'gates.json').write_text(json.dumps(gates, indent=2) + '\n')
    print(json.dumps(gates), flush=True)
    if not candidates: return
    for sample in selection['samples']:
        if not sample['response'] or gates[sample['task_id']]['status'] != 'eligible': continue
        path = ROOT / sample['response']['path']
        if digest(path) != sample['response']['sha256']: raise RuntimeError('Candidate bytes changed')
        for scenario in selection['scenarios']:
            dest = OUT / (sample['sample_id'].replace('/', '-') + '-' + scenario + '.json')
            if dest.exists(): continue
            r = execute(sample['sample_id'], sample['task_id'], scenario, path, selection['image_id'])
            dest.write_text(json.dumps(r, indent=2) + '\n')
            print(sample['sample_id'], scenario, r.get('generated_test', {}).get('passed'), flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser(); p.add_argument('mode', choices=['generate', 'controls', 'execute'])
    a = p.parse_args()
    if a.mode == 'generate': generate()
    else: run(a.mode == 'execute')
