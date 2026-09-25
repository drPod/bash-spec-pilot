#!/usr/bin/env python3
"""One retry only for a recorded Docker/Go startup thread-allocation failure.

Original attempts remain untouched. Never retry candidate execution failures,
timeouts, malformed outputs, or behavior-check failures under this policy.
"""
import hashlib
import json
from run_revised import HERE,ROOT,execute


def main():
    config=json.loads((HERE/'revised-frozen.json').read_text())
    primary=[json.loads(s) for s in (HERE/'revised-execution.jsonl').read_text().splitlines()]
    output=HERE/'revised-infra-retries.jsonl'
    previous=[json.loads(s) for s in output.read_text().splitlines()] if output.exists() else []
    done={(r['sample_id'],r['scenario']) for r in previous}
    samples={s['sample_id']:s for s in config['samples']}
    with output.open('a') as f:
        for r in primary:
            key=r['sample_id'],r['scenario']
            if key in done or r['status']!='harness_error' or 'runtime/cgo: pthread_create failed' not in r.get('error',''):continue
            assert 'candidate_sha256' not in r
            s=samples[r['sample_id']];artifact=s['response']
            retried=execute((s['sample_id'],s['task_id'],r['scenario'],ROOT/artifact['path'],artifact['sha256']),config['image_id'])
            retried['retry_of_sha256']=hashlib.sha256(json.dumps(r,sort_keys=True).encode()).hexdigest()
            retried['retry_reason']='Docker/Go startup pthread allocation failure; no candidate observation was returned.'
            retried['retry_policy']='One retry; infrastructure-only; primary attempt preserved.'
            f.write(json.dumps(retried)+'\n');f.flush()
            print(s['sample_id'],r['scenario'],retried['status'],flush=True)


if __name__=='__main__':main()
