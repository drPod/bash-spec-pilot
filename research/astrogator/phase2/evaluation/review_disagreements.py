#!/usr/bin/env python3
"""Export every full-frontier/local-label disagreement for specification review.

No model verdict is relabeled by the author. Reasons are quoted as model output,
not endorsed. Selection is exhaustive conditional on disagreement, not random.
"""
from collections import Counter
import json
from analyze import HERE,ROOT


def main():
    report=json.loads((HERE/'frontier-full-comparison.json').read_text())
    revised=json.loads((HERE/'revised-summary.json').read_text())
    assert all(report['complete'].values()) and revised['complete']
    changes={r['sample_id']:r for r in revised['samples']}
    result=[]
    for r in report['samples']:
        labels={'original':r['local_label']}
        for field in ('strict_integrity','newline_sensitivity'):
            labels[field]=changes[r['sample_id']][field] if r['sample_id'] in changes else r['local_label']
        for model in ('gpt6','opus55'):
            decision=r[model]
            if decision not in ('accept','reject'):continue
            disagreement=[v for v,label in labels.items() if decision != ('accept' if label=='passed_local_checks' else 'reject')]
            if not disagreement:continue
            filename='judge-'+r['sample_id'].replace('/','-')+'.json'
            paths=[ROOT/'phase2/integration'/d/model/filename for d in ('frontier','frontier-full-judge')]
            matches=[p for p in paths if p.exists()];assert len(matches)==1
            response=json.loads(matches[0].read_text())
            parsed=json.loads(response['extracted']) if isinstance(response['extracted'],str) else response['extracted']
            result.append({'sample_id':r['sample_id'],'task_id':r['task_id'],'model':model,'decision':decision,
                           'label_variants':labels,'disagreement_variants':disagreement,
                           'quoted_model_reason':parsed['reason'],'prediction_file':str(matches[0].relative_to(ROOT)),
                           'code_sha256':r['code_sha256']})
    out={'selection':'Every terminal accept/reject prediction disagreeing with at least one declared local-label variant; not a random sample.',
         'model_variant_counts':{m:{v:sum(r['model']==m and v in r['disagreement_variants'] for r in result)
                                  for v in ('original','strict_integrity','newline_sensitivity')} for m in ('gpt6','opus55')},
         'records':result,'limitations':['Disagreement with a narrow oracle is not automatically a model error.',
                                        'Quoted reasons are model outputs, not independent annotations.',
                                        'Uncertain/invalid predictions are excluded from this disagreement file but retained in coverage tables.']}
    (HERE/'frontier-disagreements.json').write_text(json.dumps(out,indent=2)+'\n')
    lines=['# Strong-model disagreements requiring review','',out['selection'],'',
           'These are disagreements with declared local checks, not automatically model errors. Reasons below are model-generated text. All raw predictions remain linked by path in frontier-disagreements.json.','',
           '| Model | Sample | Decision | Disagrees with labels | Model reason (excerpt) |','|---|---|---|---|---|']
    for r in result:
        reason=r['quoted_model_reason'].replace('|','\\|').replace('\n',' ')
        if len(reason)>300:reason=reason[:297]+'...'
        lines.append(f"| {r['model']} | {r['sample_id']} | {r['decision']} | {', '.join(r['disagreement_variants'])} | {reason} |")
    (HERE/'FRONTIER-DISAGREEMENTS.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps(out['model_variant_counts'],indent=2))


if __name__=='__main__':main()
