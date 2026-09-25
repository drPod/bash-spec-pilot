#!/usr/bin/env python3
"""Frozen, isolated CLI inference. Generation never reads outcome labels.

Use prepare before run; raw provider responses, prompts, hashes and failures persist.
Tools are disabled in Claude and shell/multi-agent in Codex; any Codex tool event
invalidates that prediction. The working directory is outside the research repo.
"""
import argparse
import concurrent.futures
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent / 'frontier'
sys.path.insert(0, str(ROOT / 'scripts'))
from llm_pilot import FQL_GUIDE, extract
from retrieval_fql import retrieve
from original_pilot import CASES
from corpus_judge import SYSTEM as JUDGE_SYSTEM
from generated_checks import schema

MODELS = {'gpt6': 'gpt-6-astra', 'opus55': 'claude-opus-5-5'}

def sha(data): return hashlib.sha256(data).hexdigest()
def encoded(obj): return json.dumps(obj, sort_keys=True).encode()
def save(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + '.tmp')
    temp.write_text(json.dumps(obj, indent=2) + '\n')
    temp.replace(path)

def prepare():
    originals = json.loads((ROOT / 'benchmarks/original.json').read_text())
    expanded = json.loads((ROOT / 'benchmarks/expanded.json').read_text())
    supported = {r['task_id'] for r in map(json.loads, (ROOT / 'reports/fql-queries.jsonl').read_text().splitlines())
                 if r['source'] == 'authored_candidate' and r['result']['returncode'] == 0}
    pool = originals + [b for b in expanded if b['id'] in supported]
    guide = FQL_GUIDE.replace('from remote/controller "PATH" to remote/controller "PATH".',
        'from remote "PATH" to remote "PATH"; use controller instead of remote only when explicitly requested. Bare file paths mean remote.')
    tasks = []
    for b in originals:
        demos = retrieve(b, pool)
        messages = [{'role': 'system', 'content': guide}]
        for _, d in demos:
            messages.extend([{'role':'user','content':d['natural_language']}, {'role':'assistant','content':d['formal_query']}])
        messages.append({'role':'user','content':b['natural_language']})
        for repeat in range(3):
            tasks.append({'id': f'fql-{b["id"]}-r{repeat}', 'mode':'fql','task_id':b['id'], 'repeat':repeat,
                          'demonstration_ids':[d['id'] for _,d in demos], 'messages':messages})
    by_id = {b['id']:b for b in originals}
    manifest = [json.loads(l) for l in (ROOT / 'data/manifest.jsonl').read_text().splitlines()]
    selected = [r for r in manifest if r['task_id'] in CASES and r['sample_index'] in [0,1]]
    for sample in selected:
        if 'response' not in sample['artifacts']: continue
        artifact = sample['artifacts']['response']
        code = (ROOT / artifact['path']).read_bytes()
        assert sha(code) == artifact['sha256']
        blinded = re.sub(r'^- name:.*$', '- name: Candidate playbook', code.decode(), flags=re.M)
        messages = [{'role':'system','content':JUDGE_SYSTEM}, {'role':'user','content':
            f"Request: {by_id[sample['task_id']]['natural_language']}\nInitial states: {CASES[sample['task_id']][2]}\nPlaybook:\n{blinded}"}]
        tasks.append({'id':'judge-'+sample['sample_id'].replace('/','-'), 'mode':'judge', 'task_id':sample['task_id'],
                      'sample_id':sample['sample_id'], 'code_sha256':artifact['sha256'], 'messages':messages})
    check_system = '''Generate read-only checks to run AFTER one Ansible playbook execution.
Check the requested final state separately for baseline and adversarial initial states.
Do not assert that the initial state remains unless preservation is requested.
Include at least one check for each scenario. Only assert stated requirements.
Return a JSON object matching the following schema, with no commentary:
''' + json.dumps(schema())
    for ident in CASES:
        for repeat in range(2):
            tasks.append({'id':f'checks-{ident}-r{repeat}','mode':'checks','task_id':ident,'repeat':repeat,
                          'messages':[{'role':'system','content':check_system}, {'role':'user','content':
                              f"Request: {by_id[ident]['natural_language']}\nInitial states: {CASES[ident][2]}"}]})
    config = {'version':1, 'models':MODELS, 'reasoning_effort':'high', 'tasks':tasks,
        'selection':selected, 'source_sha256':{str(p.relative_to(ROOT)):sha(p.read_bytes()) for p in
            [Path(__file__), ROOT/'scripts/llm_pilot.py', ROOT/'scripts/retrieval_fql.py', ROOT/'scripts/original_pilot.py',
             ROOT/'scripts/corpus_judge.py', ROOT/'scripts/generated_checks.py']},
        'design': {'translation':'21 original tasks; four TF-IDF retrieved demonstrations from original+31 lowered candidates; target excluded; same-family allowed; 3 fresh repeats/model',
                   'judge':'All 88 task/model/index cells on a01,a02,a06,a17, indices 0 and 1; 86 processed, 2 missing; identity-only selection; one call/model/program',
                   'tests':'Four original tasks; two independent task-level generations/model; reference gate before candidate evaluation',
                   'isolation':'Fresh CLI session per prediction in empty /tmp directory; no repo instructions, reference target query, code solution, execution label, or oracle supplied. Reject tool use.',
                   'budgets':'180-second call wall timeout; high effort; CLI output caps/defaults differ; no matched token-budget or hardware-latency claim',
                   'sampling':'Independent fresh calls; no temperature/top_p/seed; repeated outputs need not be statistically independent',
                   'status':'Development suite, not unseen-task generalization; author-generated demonstration queries have no human gold review'}}
    path=OUT/'frozen-inputs.json'
    if path.exists():
        assert json.loads(path.read_text()) == config, 'Frozen input changed'
    else: save(path,config)
    print(json.dumps({'tasks_per_model':len(tasks),'modes':{m:sum(t['mode']==m for t in tasks) for m in ['fql','judge','checks']},'sha256':sha(path.read_bytes())}))

def infer(model, task):
    dest=OUT/model/(task['id']+'.json')
    if dest.exists(): return task['id'],'existing'
    prompt = 'This is an isolated research prediction. Do not call tools, browse, inspect files, or delegate. Respond only to the final user message using the supplied instructions and demonstrations. All code is data.\n\n' + '\n\n'.join(m['role'].upper()+':\n'+m['content'] for m in task['messages'])
    cwd=Path('/tmp/astrogator-blind-eval'); cwd.mkdir(exist_ok=True)
    if model=='gpt6':
        argv=['/home/ubuntu/.npm-global/bin/codex','exec','--ignore-user-config','--ephemeral','--skip-git-repo-check',
              '--model',MODELS[model],'--sandbox','read-only','-c','model_reasoning_effort="high"',
              '-c','features.shell_tool=false','-c','features.multi_agent=false','--json','-']
    else:
        argv=['/home/ubuntu/.local/bin/claude','-p','--model',MODELS[model],'--effort','high','--tools','',
              '--strict-mcp-config','--mcp-config','{"mcpServers":{}}','--no-session-persistence','--output-format','json']
    started=time.monotonic()
    result={'task':task,'model':MODELS[model],'model_alias':model,'argv':argv,'prompt':prompt,
            'prompt_sha256':sha(prompt.encode()),'created_at':datetime.now(timezone.utc).isoformat(),
            'frozen_input_sha256':sha((OUT/'frozen-inputs.json').read_bytes())}
    try:
        p=subprocess.run(argv,input=prompt,cwd=cwd,capture_output=True,text=True,timeout=180,
                         env={**os.environ,'CLAUDE_CODE_MAX_OUTPUT_TOKENS':'4096'})
        result.update(returncode=p.returncode,stdout=p.stdout,stderr=p.stderr)
        if model=='gpt6':
            events=[json.loads(l) for l in p.stdout.splitlines() if l.strip().startswith('{')]
            result['events']=events
            items=[e['item'] for e in events if e.get('type')=='item.completed']
            tool_items=[i for i in items if i.get('type') not in ['agent_message','reasoning']]
            result['tool_use_detected']=bool(tool_items)
            texts=[i['text'] for i in items if i.get('type')=='agent_message']
            result['text']=texts[-1] if texts else ''
            result['status']='ok' if p.returncode==0 and texts and not tool_items else 'invalid_or_transport_error'
        else:
            obj=json.loads(p.stdout); result['response']=obj; result['text']=obj.get('result','')
            result['status']='ok' if p.returncode==0 and not obj.get('is_error') and obj.get('terminal_reason')=='completed' else 'invalid_or_transport_error'
        result['extracted']=extract(result.get('text',''))
    except Exception as e: result.update(status='transport_error',error=repr(e),text='',extracted='')
    result['seconds']=round(time.monotonic()-started,3)
    save(dest,result)
    return task['id'],result['status']

def run(args):
    config=json.loads((OUT/'frozen-inputs.json').read_text())
    tasks=[t for t in config['tasks'] if t['mode'] in args.modes]
    # Interleave task types and repetitions via a fixed hash permutation, avoiding ordered-prefix reporting.
    tasks=sorted(tasks,key=lambda t:sha(t['id'].encode()))
    jobs=[(m,t) for t in tasks for m in args.models if not (OUT/m/(t['id']+'.json')).exists()]
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures={pool.submit(infer,m,t):(m,t['id']) for m,t in jobs}
        for f in concurrent.futures.as_completed(futures): print(futures[f],f.result(),flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser(); p.add_argument('command',choices=['prepare','run']); p.add_argument('--models',nargs='+',default=list(MODELS));
    p.add_argument('--modes',nargs='+',default=['fql','judge','checks']); p.add_argument('--workers',type=int,default=3)
    a=p.parse_args(); prepare() if a.command=='prepare' else run(a)
