#!/usr/bin/env python3
"""Frozen, resume-safe whole-task rerun for oracle sensitivity; no selected relabeling."""
import argparse
import concurrent.futures
import hashlib
import json
from pathlib import Path
import subprocess
import uuid

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
IMAGE = 'astrogator-lab:20260924-v2'


def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()


def execute(case, image):
    sample, task, scenario, path, digest = case
    assert sha(path) == digest
    name = 'astro-oracle-v2-' + uuid.uuid4().hex[:12]
    command = ['docker', 'run', '--rm', '--init', '--name', name, '--network=none',
               '--memory=320m', '--cpus=0.50', '--pids-limit=96', '--cap-drop=NET_RAW',
               '-v', f'{ROOT}:/suite:ro', image, 'python3', '/suite/phase2/evaluation/revised_case.py',
               task, scenario, '/suite/' + str(path.relative_to(ROOT))]
    try:
        p = subprocess.run(command, capture_output=True, text=True, timeout=70)
        if p.returncode: raise RuntimeError(p.stderr[-2000:])
        result = json.loads(p.stdout)
        assert result['candidate_sha256'] == digest
    except Exception as e:
        result = {'status': 'harness_error', 'error': repr(e), 'task_id': task, 'scenario': scenario}
    finally:
        subprocess.run(['docker', 'rm', '-f', name], capture_output=True)
    return {**result, 'sample_id': sample, 'image_id': image}


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--workers', type=int, default=1)
    args = ap.parse_args(); assert 1 <= args.workers <= 2
    records = [json.loads(s) for s in (ROOT / 'data/manifest.jsonl').read_text().splitlines()]
    selected = [r for r in records if r['task_id'] in ('a06', 'a17')]
    image = subprocess.check_output(['docker', 'image', 'inspect', IMAGE, '--format', '{{.Id}}'], text=True).strip()
    config = {'tasks': ['a06', 'a17'], 'scenario_names': ['baseline', 'adversarial'], 'image_id': image,
              'source_sha256': {p.name: sha(p) for p in [HERE/'revised_case.py', Path(__file__)]},
              'samples': [{'sample_id': r['sample_id'], 'task_id': r['task_id'],
                           'response': r['artifacts'].get('response')} for r in selected],
              'label_policy': 'Preserve execution failures; whole-task new-version observations. No automatic replacement of original labels.',
              'password_scope': 'Real crypt hash verification plus structural account integrity, NOT PAM/SSH authentication.',
              'newline_scope': 'Allow one final newline only on newly created a06 file; existing file must be preserved exactly.'}
    frozen = HERE/'revised-frozen.json'
    if frozen.exists(): assert json.loads(frozen.read_text()) == config
    else: frozen.write_text(json.dumps(config, indent=2)+'\n')
    controls = HERE/'revised-controls.jsonl'
    if not controls.exists():
        with controls.open('w') as f:
            for task in config['tasks']:
                p = ROOT/'benchmarks/original-pilot'/task/'reference.yml'
                for scenario in config['scenario_names']:
                    r = execute(('reference/'+task, task, scenario, p, sha(p)), image)
                    f.write(json.dumps(r)+'\n'); f.flush()
    checks = [json.loads(s) for s in controls.read_text().splitlines()]
    assert len(checks) == 4
    assert all(r['status'] == 'observed' and r['after'].get('strict_oracle', r['after']['old_oracle']) for r in checks), checks
    output = HERE/'revised-execution.jsonl'
    done = [json.loads(s) for s in output.read_text().splitlines()] if output.exists() else []
    keys = {(r['sample_id'], r['scenario']) for r in done}; assert len(keys) == len(done)
    cases = [(r['sample_id'], r['task_id'], s, ROOT/r['response']['path'], r['response']['sha256'])
             for r in config['samples'] if r['response'] for s in config['scenario_names'] if (r['sample_id'], s) not in keys]
    with output.open('a') as f, concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
        for r in pool.map(lambda c: execute(c, image), cases):
            f.write(json.dumps(r)+'\n'); f.flush()
            print(r['sample_id'], r['scenario'], r['status'], flush=True)


if __name__ == '__main__': main()
