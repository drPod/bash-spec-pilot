#!/usr/bin/env python3
"""Conservative structural duplicate audit with cluster-weighted sensitivity.

Only top-level play names are removed, because the corpus inserts model/response
identity there. All scalar tags, task names, module parameters, and sequence order
are retained. Unique-key maps are sorted; duplicate-key maps retain order. This is NOT
semantic equivalence or proof of independent samples.
"""
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import yaml
from analyze import HERE, ROOT, METHODS, enrich


def canonical(node, top=False):
    if isinstance(node, yaml.ScalarNode): return ['scalar', node.tag, node.value]
    if isinstance(node, yaml.SequenceNode): return ['sequence', node.tag, [canonical(v, top=top) for v in node.value]]
    if isinstance(node, yaml.MappingNode):
        pairs = [[canonical(k), canonical(v)] for k,v in node.value
                 if not(top and isinstance(k,yaml.ScalarNode) and k.value=='name' and k.tag=='tag:yaml.org,2002:str')]
        keys=[json.dumps(p[0],sort_keys=True) for p in pairs]
        return ['mapping',node.tag,sorted(pairs,key=lambda p:json.dumps(p,sort_keys=True)) if len(keys)==len(set(keys)) else pairs]
    raise TypeError(type(node).__name__)


def main():
    rows = enrich(json.loads((ROOT/'reports/four-task-comparison.json').read_text())['samples'])
    manifest = {r['sample_id']:r for r in map(json.loads,(ROOT/'data/manifest.jsonl').read_text().splitlines())}
    clusters = defaultdict(list)
    for r in rows:
        p = ROOT/manifest[r['sample_id']]['artifacts']['response']['path']
        assert hashlib.sha256(p.read_bytes()).hexdigest() == r['code_sha256']
        node = yaml.compose(p.read_text())
        fingerprint = hashlib.sha256(json.dumps(canonical(node,top=True),sort_keys=True).encode()).hexdigest()
        clusters[r['task_id'],fingerprint].append(r)
    detail = [{'task_id':t,'canonical_sha256':h,'n':len(rs),'samples':[r['sample_id'] for r in rs],
               'local_labels':dict(Counter(r['local_label'] for r in rs)),
               'method_decisions':{m:dict(Counter(r[m] for r in rs)) for m in METHODS}}
              for (t,h),rs in sorted(clusters.items())]
    metrics = {}
    for m in METHODS:
        count = Counter()
        for rs in clusters.values():
            for r in rs:
                count['pass' if r['local_label']=='passed_local_checks' else 'fail',r[m]] += 1/len(rs)
        ap,af,rp,rf = [count[y,d] for y,d in [('pass','accept'),('fail','accept'),('pass','reject'),('fail','reject')]]
        n=len(clusters); fails=sum(v for (y,d),v in count.items() if y=='fail')
        metrics[m]={'effective_program_weight':n,'weighted_accept_pass':ap,'weighted_accept_fail':af,
                    'weighted_reject_pass':rp,'weighted_reject_fail':rf,
                    'coverage':(ap+af+rp+rf)/n,'accepted_failure_risk':af/(ap+af) if ap+af else None,
                    'failure_detection_recall':rf/fails if fails else None}
    out={'normalization':'YAML representation-node canonicalization; remove top-level play name only; preserve tags; sort unique-key mapping entries; preserve duplicate-key map order and sequence order.',
         'programs':len(rows),'unique_structures':len(clusters),
         'unique_by_task':dict(Counter(t for t,h in clusters)),
         'mixed_label_clusters':[d for d in detail if len(d['local_labels'])>1],
         'judge_disagreement_clusters':[d for d in detail if len(d['method_decisions']['judge'])>1],
         'cluster_weighted_metrics':metrics,'clusters':detail,
         'limitations':['Descriptive sensitivity, not semantic deduplication. Different task names remain separate.',
                        'Each structural cluster has total weight 1; within-cluster decisions are averaged, not selectively chosen.',
                        'Canonicalization ignores presentation and mapping order; mixed judge verdicts within a cluster are not necessarily repeated identical prompts.',
                        'Task mix still reflects four selected tasks; duplicate weighting does not make them representative.'],
         'source_sha256':{'comparison':hashlib.sha256((ROOT/'reports/four-task-comparison.json').read_bytes()).hexdigest(),
                          'script':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}}
    (HERE/'duplicates.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:v for k,v in out.items() if k not in ('clusters','judge_disagreement_clusters')},indent=2))


if __name__=='__main__':main()
