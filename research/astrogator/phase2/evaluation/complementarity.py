#!/usr/bin/env python3
"""Identity-level error complementarity, with abstention separated from rejection."""
import hashlib,json
from analyze import HERE,stats

def main():
    paths=[HERE/p for p in ('frontier-full-comparison.json','additional-baselines.json','revised-summary.json')]
    f,e,r=[json.loads(p.read_text())for p in paths];assert all(f['complete'].values())and all(e['complete'].values())and r['complete']
    extra={x['sample_id']:x for x in e['samples']};labels={x['sample_id']:x['strict_integrity'] for x in r['samples']};rows=[]
    for x in f['samples']:
        q={**x,'local_label':labels.get(x['sample_id'],x['local_label']),'debian_metadata_heuristics':extra[x['sample_id']]['debian_metadata_heuristics']}
        assert q['code_sha256']==extra[x['sample_id']]['code_sha256']
        for m in ('gpt6','opus55'):
            a,b=q['debian_metadata_heuristics'],q[m]
            q['debian_and_'+m]='reject' if 'reject' in (a,b) else 'accept' if a==b=='accept' else 'unavailable'
        rows.append(q)
    detail={}
    for v in ('astrogator','astrogator_configured_heuristics','debian_metadata_heuristics'):
        for m in ('gpt6','opus55'):
            fail=[x for x in rows if x['local_label']=='failed_local_checks_or_execution']
            sets={'verifier_rejects_judge_accepts':[x['sample_id']for x in fail if x[v]=='reject'and x[m]=='accept'],
                  'verifier_unavailable_judge_accepts':[x['sample_id']for x in fail if x[v]not in('accept','reject')and x[m]=='accept'],
                  'judge_rejects_verifier_accepts':[x['sample_id']for x in fail if x[v]=='accept'and x[m]=='reject'],
                  'judge_rejects_verifier_unavailable':[x['sample_id']for x in fail if x[v]not in('accept','reject')and x[m]=='reject'],
                  'both_accept_failures':[x['sample_id']for x in fail if x[v]==x[m]=='accept']}
            detail[v+' vs '+m]=sets
    policies={m:stats(rows,m) for m in ('debian_and_gpt6','debian_and_opus55')}
    out={'complete':True,'n':422,'label_variant':'strict_integrity','pairs':detail,'posthoc_policy':'Reject if either rejects; accept only if both accept; otherwise unavailable. Deterministic retrospective composition of existing predictions; no new inference or equal-cost claim.','posthoc_metrics':policies,'posthoc_samples':[{k:x[k]for k in('sample_id','task_id','code_sha256','local_label','debian_and_gpt6','debian_and_opus55')}for x in rows],'input_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in paths},'limitations':['Strict integrity is an outcome-informed sensitivity, not independently reviewed gold.','Verifier rejection is a modeled mismatch; not a proof of concrete universal incorrectness.','Unavailable must not be counted as verifier detection.']}
    (HERE/'complementarity.json').write_text(json.dumps(out,indent=2)+'\n')
    lines=['# What does the verifier add to the strong judges?','','Strict-integrity labels on the same422programs. Every identity is retained in JSON. Rejection and abstention are separated.','','| Verifier vs judge | Verifier rejects / judge accepts failures | Verifier unavailable / judge accepts failures | Judge rejects / verifier accepts failures | Both accept failures |','|---|---:|---:|---:|---:|']
    for name,z in detail.items():lines.append('| '+name+' | '+' | '.join(str(len(z[k]))for k in ('verifier_rejects_judge_accepts','verifier_unavailable_judge_accepts','judge_rejects_verifier_accepts','both_accept_failures'))+' |')
    lines+=['','## Complementary rejection identities','']
    for name,z in detail.items():lines.append('- '+name+': '+(', '.join('`'+s+'`'for s in z['verifier_rejects_judge_accepts'])or'none')+'.')
    lines+=['','## Retrospective conjunction','',out['posthoc_policy'],'','| Policy | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |','|---|---:|---:|---:|---:|---:|']
    for name,s in policies.items():lines.append(f"| {name} | {s['accepted_pass']} | {s['accepted_fail']} | {s['rejected_pass']} | {s['rejected_fail']} | {s['unavailable_pass']+s['unavailable_fail']} |")
    lines+=['','These development-suite compositions were examined after seeing outcomes. Zero observed accepted failures is not a validated risk guarantee. The corpus, model budgets, environmental scope, and oracle interpretations remain fixed.']
    (HERE/'COMPLEMENTARITY.md').write_text('\n'.join(lines)+'\n');print('\n'.join(lines))
if __name__=='__main__':main()
