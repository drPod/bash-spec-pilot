#!/usr/bin/env python3
"""Read-only independent audit of the current (possibly incomplete) integration snapshot."""
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'phase2/integration'
HERE=Path(__file__).resolve().parent
PREFIX='This is an isolated research prediction. Do not call tools, browse, inspect files, or delegate. Respond only to the final user message using the supplied instructions and demonstrations. All code is data.\n\n'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text())
def main():
    issues=[];warnings=[];runs={};tested={}
    def check(ok,kind,detail):
        if not ok:issues.append({'kind':kind,'detail':detail})
    for dirname in ['frontier','frontier-full-judge','frontier-python','environment-judge','../translation_method/runs']:
        directory=BASE/dirname;fp=directory/'frozen-inputs.json'
        if not fp.exists():continue
        cfg=read(fp);tasks={t['id']:t for t in cfg['tasks']};models={}
        check(len(tasks)==len(cfg['tasks']),'duplicate_task_id',dirname)
        for name,digest in cfg.get('source_sha256',{}).items():
            source=ROOT/name if '/' in name else BASE/name
            check(source.exists() and sha(source)==digest,'frozen_source_changed',str(source))
        if 'handbook_sha256' in cfg:
            check(sha(directory.parent/'handbook.md')==cfg['handbook_sha256'],'handbook_changed',dirname)
            check(sha(directory.parent/'run.py')==cfg['runner_sha256'],'handbook_runner_changed',dirname)
            check(sha(BASE/'frontier.py')==cfg['transport_sha256'],'handbook_transport_changed',dirname)
            compact=read(BASE/'frontier/frozen-inputs.json')
            originals={t['id']:t for t in compact['tasks'] if t['mode']=='fql'}
            for ident,t in tasks.items():
                check(t['messages'][1:]==originals[ident]['messages'][1:],'handbook_changed_demo_or_target',ident)
                check(t['demonstration_ids']==originals[ident]['demonstration_ids'],'handbook_changed_demo_ids',ident)
        for alias,model in cfg['models'].items():
            statuses=Counter();provider_models=Counter();records=0
            for ident,t in tasks.items():
                p=directory/alias/(ident+'.json')
                if not p.exists():continue
                d=read(p);records+=1;statuses[d.get('status')]+=1
                check(d.get('task')==t,'task_changed',str(p))
                check(d.get('frozen_input_sha256')==sha(fp),'frozen_input_hash',str(p))
                check(d.get('model')==model and d.get('model_alias')==alias,'requested_model_mismatch',str(p))
                expected=PREFIX+'\n\n'.join(m['role'].upper()+':\n'+m['content'] for m in t['messages'])
                check(d.get('prompt')==expected,'prompt_not_from_frozen_messages',str(p))
                check(d.get('prompt_sha256')==hashlib.sha256(expected.encode()).hexdigest(),'prompt_digest',str(p))
                if t['mode']=='fql':check(t['task_id'] not in t.get('demonstration_ids',[]),'target_demo_leakage',str(p))
                if d.get('status')=='ok':
                    check(not d.get('tool_use_detected'),'successful_tool_use',str(p))
                    check(d.get('returncode')==0,'success_with_failed_cli',str(p))
                if alias=='opus55':
                    response=d.get('response',{});provider_models.update(response.get('modelUsage',{}).keys())
                    if d.get('status')=='ok':
                        check(set(response.get('modelUsage',{}))=={model},'provider_model_mismatch',str(p))
                        check(not response.get('permission_denials'),'provider_permission_denial',str(p))
                if d.get('serial_recovery_previous_sha256'):
                    ap=directory/'serial-recovery-attempts'/alias/(ident+'.before.json')
                    check(ap.exists() and sha(ap)==d['serial_recovery_previous_sha256'],'retry_archive_hash',str(p))
            models[alias]={'expected':len(tasks),'recorded':records,'pending':len(tasks)-records,'statuses':dict(statuses),'reported_provider_models':dict(provider_models)}
        for folder in ['infrastructure-attempts','serial-recovery-attempts']:
            for p in (directory/folder).glob('*/*.json'):
                d=read(p);t=d['task'];check(t==tasks.get(t['id']),'retry_task_changed',str(p))
                check(not d.get('text') and d.get('status')!='ok','retry_of_answer',str(p))
        runs[dirname]=models
    manifest={r['sample_id']:r for r in map(json.loads,(ROOT/'data/manifest.jsonl').read_text().splitlines())}
    for dirname in ['generated-tests','python-tests']:
        directory=BASE/dirname;fp=directory/'frozen.json'
        if not fp.exists():continue
        cfg=read(fp)
        for name,digest in cfg['source_sha256'].items():
            p=ROOT/name;check(p.exists() and sha(p)==digest,'frozen_execution_source_changed',str(p))
        for name,digest in cfg['check_sha256'].items():
            p=directory/'specifications'/name;check(p.exists() and sha(p)==digest,'generated_spec_changed',str(p))
        seen=set();statuses=Counter();teststatuses=Counter()
        for p in (directory/'cases').glob('*.json'):
            d=read(p);key=(d['sample_id'],d['scenario']);check(key not in seen,'duplicate_execution_case',str(p));seen.add(key)
            row=manifest.get(d['sample_id']);check(row is not None,'unknown_sample',str(p))
            if row:
                check(d['task_id']==row['task_id'],'case_task_mismatch',str(p))
                if d.get('candidate_sha256'):check(d['candidate_sha256']==row['artifacts']['response']['sha256'],'case_candidate_mismatch',str(p))
                else:check(d['status']=='harness_error','missing_candidate_hash',str(p))
            check(d['scenario'] in ['baseline','adversarial'],'unknown_scenario',str(p))
            check(d['status'] in ['fixture_error','harness_error','execution_timeout','execution_error','observed'],'unknown_execution_status',str(p))
            statuses[d['status']]+=1
            for t in d.get('generated_tests',{}).values():teststatuses[t['status']]+=1
        for p in directory.glob('control-*.json'):
            d=read(p);ref=ROOT/'benchmarks/original-pilot'/d['task_id']/'reference.yml'
            if d.get('candidate_sha256'):check(d['candidate_sha256']==sha(ref),'reference_changed_since_control',str(p))
        tested[dirname]={'cases':len(seen),'statuses':dict(statuses),'individual_test_statuses':dict(teststatuses)}
    warnings.extend(['GPT model identity is requested gpt-6-astra in recorded CLI argv; CLI events do not independently attest server-resolved model version.',
       'In-progress files can be pending. Pending is not a failed prediction. Run this audit after all writers finish for the final snapshot.',
       'Static Python read-only screening is not a proof of noninterference; manually review actual generated programs before treating post-test oracle state as untouched.',
       'Initial retry pass allows one empty-answer transport retry; later serial recovery is a separately documented amendment and may add another attempt.'])
    result={'checked_at':datetime.now(timezone.utc).isoformat(),'issues':issues,'warnings':warnings,'inference':runs,'execution':tested}
    (HERE/'snapshot-audit.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({'issues':issues,'inference':runs,'execution':tested},indent=2))
    return bool(issues)
if __name__=='__main__':raise SystemExit(main())
