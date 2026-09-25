#!/usr/bin/env python3
"""Task-paired translation ablation; repeated generations are not new tasks."""
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
from frontier import ROOT, save

HERE=Path(__file__).resolve().parent
ARMS={'compact':HERE/'frontier-diagnostics.jsonl','handbook':ROOT/'phase2/translation_method/diagnostics.jsonl'}

def flags(row):
    stages=row['diagnostics'].get('stages',{})
    return {'parsed':stages.get('parse',{}).get('status')=='ok',
            'lowered':row['diagnostics'].get('returncode')==0,
            'effect_match':row['effect_match']}

def main():
    groups=defaultdict(list); cells={}; hashes={}
    for arm,path in ARMS.items():
        if not path.exists(): continue
        hashes[str(path.relative_to(ROOT))]=hashlib.sha256(path.read_bytes()).hexdigest()
        for row in map(json.loads,path.read_text().splitlines()):
            key=(arm,row['model'],row['task_id'],row['repeat']); assert key not in cells
            cells[key]=row; groups[arm,row['model']].append(row)
    summary={}; by_task={}
    for (arm,model),rs in groups.items():
        k=arm+'/'+model
        complete=len(rs)==63 and len({(r['task_id'],r['repeat']) for r in rs})==63
        summary[k]={'complete':complete,'observed':len(rs),'expected':63,
                    'generation_statuses':dict(Counter(r['generation_status'] for r in rs))}
        if not complete: continue
        summary[k]['counts']={name:sum(flags(r)[name] for r in rs) for name in ['parsed','lowered','effect_match']}
        summary[k]['per_repeat']={str(i):{name:sum(flags(r)[name] for r in rs if r['repeat']==i) for name in ['parsed','lowered','effect_match']} for i in range(3)}
        by_task[k]={t:{name:sum(flags(r)[name] for r in rs if r['task_id']==t) for name in ['parsed','lowered','effect_match']} for t in sorted({r['task_id'] for r in rs})}
    paired={}
    for model in ['gpt-6-astra','claude-opus-5-5']:
        a='compact/'+model;b='handbook/'+model
        if a not in by_task or b not in by_task: continue
        paired[model]={'by_task':{},'direction_counts':{}}
        for t in by_task[a]:
            paired[model]['by_task'][t]={k:by_task[b][t][k]-by_task[a][t][k] for k in ['parsed','lowered','effect_match']}
        for k in ['parsed','lowered','effect_match']:
            values=[r[k] for r in paired[model]['by_task'].values()]
            paired[model]['direction_counts'][k]={'improved_tasks':sum(v>0 for v in values),'tied_tasks':sum(v==0 for v in values),'worsened_tasks':sum(v<0 for v in values),'net_generations':sum(values)}
    result={'arms':summary,'by_task':by_task,'paired':paired,'input_sha256':hashes,
            'unit':'21 tasks, three fresh generations per task/model/arm; 63 outputs are not63independentproblems.',
            'limitations':['Normalized semantic-effect matching is a reference-agreement proxy, not proof of intent fidelity.',
                'Same four demonstrations and targets; handbook changes both information content and prompt length.',
                'Existing source KB is task-related domain engineering; no unseen-domain claim.',
                'Fresh calls lack matched random seeds; paired cells share tasks, not generation randomness.',
                'No gold target FQL or parser feedback supplied to either generation arm.',
                'Code generation validated with original pinned source; code patches are evaluated separately.']}
    save(HERE/'translation-summary.json',result)
    lines=['# Strong-model NL to FQL: matched source-handbook ablation','',
           '| Prompt | Model | Complete | Parsed | Lowered | Reference-effect matches |','|---|---|---|---:|---:|---:|']
    for name,s in summary.items():
        arm,model=name.split('/'); c=s.get('counts',{})
        lines.append(f'| {arm} | {model} | {s["complete"]} | {c.get("parsed","pending")}/63 | {c.get("lowered","pending")}/63 | {c.get("effect_match","pending")}/63 |')
    lines+=['',result['unit'],'']+['- '+s for s in result['limitations']]
    (HERE/'TRANSLATION.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps(summary,indent=2))

if __name__=='__main__': main()
