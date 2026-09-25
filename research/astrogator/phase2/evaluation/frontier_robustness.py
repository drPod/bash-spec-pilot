#!/usr/bin/env python3
"""Descriptive duplication and error-mechanism sensitivity for complete frontier runs."""
import hashlib,json
from collections import Counter
from analyze import HERE,stats

def main():
    fp=HERE/'frontier-full-comparison.json';dp=HERE/'duplicates.json';f=json.loads(fp.read_text());d=json.loads(dp.read_text())
    assert all(f['complete'].values());rows=f['samples'];index={r['sample_id']:r for r in rows}
    methods=['astrogator','astrogator_configured_heuristics','gpt6','opus55']
    groups=d['clusters'];assert len(groups)==233
    weighted={}
    for m in methods:
        c=Counter()
        for g in groups:
            for sid in g['samples']:
                r=index[sid];c[r['local_label'],r[m]]+=1/len(g['samples'])
        ap=c['passed_local_checks','accept'];af=c['failed_local_checks_or_execution','accept']
        rf=c['failed_local_checks_or_execution','reject'];rp=c['passed_local_checks','reject']
        weighted[m]={'structural_weight':len(groups),'accepted_pass':ap,'accepted_fail':af,'rejected_pass':rp,'rejected_fail':rf,'coverage':(ap+af+rp+rf)/len(groups),'accepted_failure_risk':af/(ap+af) if ap+af else None}
    mechanisms={}
    for name in ('execution_error','behavioral_only'):
        subset=[r for r in rows if r['local_label']=='failed_local_checks_or_execution' and (('execution_error' in r['scenario_statuses'].values())==(name=='execution_error'))]
        mechanisms[name]={m:stats(subset,m) for m in methods}
    out={'complete':True,'programs':422,'label_variant':'original','duplicate_weighting':weighted,'failure_mechanisms':mechanisms,'mixed_structure_decisions':{m:[{'canonical_sha256':g['canonical_sha256'],'samples':g['samples'],'decisions':dict(Counter(index[s][m] for s in g['samples']))} for g in groups if len({index[s][m] for s in g['samples']})>1] for m in methods},'input_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (fp,dp)},'limitations':['Descriptive weighting within four selected tasks, not independence or semantic equivalence.','Execution errors are observed under one pinned environment.','No significance or unseen-task generalization claim.']}
    (HERE/'frontier-robustness.json').write_text(json.dumps(out,indent=2)+'\n')
    lines=['# Frontier robustness on original local labels','','| Method | Pooled accepted-failure risk | Equal-structure accepted-failure risk | Behavioral-only failures rejected /64 | Execution-error failures rejected /75 |','|---|---:|---:|---:|---:|']
    for m in methods:lines.append(f"| {('Qwen 2.5 1.5B judge' if m == 'judge' else m)} | {f['metrics']['original'][m]['accepted_failure_risk']:.2%} | {weighted[m]['accepted_failure_risk']:.2%} | {mechanisms['behavioral_only'][m]['rejected_fail']} | {mechanisms['execution_error'][m]['rejected_fail']} |")
    lines+=['','233 conservative YAML structures receive equal total weight. This controls one form of repetition, not task selection. Behavioral-only failures exclude any program with an execution error in either scenario; native runtime errors and behavioral failures are not interchangeable. All rates are descriptive, on original local labels.']
    (HERE/'FRONTIER-ROBUSTNESS.md').write_text('\n'.join(lines)+'\n');print('\n'.join(lines))
if __name__=='__main__':main()
