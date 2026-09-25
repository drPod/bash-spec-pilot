#!/usr/bin/env python3
"""Independent completion/provenance checks for the evaluation refinement artifact."""
from datetime import datetime,timezone
import hashlib
import json
from pathlib import Path
from analyze import HERE,ROOT


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def read(name):return json.loads((HERE/name).read_text())


def main():
    revised=read('revised-summary.json');additional=read('additional-baselines.json');frontier=read('frontier-full-comparison.json')
    assert revised['complete'] and revised['observed_cases']==revised['expected_cases']==410
    assert revised['reference_controls']==4
    assert all(additional['complete'].values()) and all(frontier['complete'].values())
    assert frontier['expected_processed']==422 and additional['expected_programs']==422
    for result in (revised,additional):
        for name,digest in result['input_sha256'].items():assert sha(HERE/name)==digest,(name,'stale')
    for name,digest in additional['runner_sha256'].items():assert sha(HERE/name)==digest,(name,'changed baseline runner')
    for name,digest in frontier['frozen_input_sha256'].items():assert sha(ROOT/name)==digest,(name,'stale')
    for name,digest in frontier['output_sha256'].items():assert sha(ROOT/name)==digest,(name,'stale')
    for source in (frontier,additional):
        for variant,methods in source['metrics'].items():
            for name,m in methods.items():
                assert sum(m[k] for k in ('accepted_pass','accepted_fail','rejected_pass','rejected_fail','unavailable_pass','unavailable_fail'))==422,(variant,name)
    frozen=read('revised-frozen.json')
    for name,digest in frozen['source_sha256'].items():assert sha(HERE/name)==digest,(name,'changed during experiment')
    controls=[json.loads(s) for s in (HERE/'revised-controls.jsonl').read_text().splitlines()]
    for c in controls:
        assert c['status']=='observed' and c['after'].get('strict_oracle',c['after']['old_oracle'])
        if c['task_id']=='a17':assert c['before']['fixture_password_still_matches']==(c['scenario']=='baseline')
    duplicates=read('duplicates.json')
    assert duplicates['programs']==422 and sum(c['n'] for c in duplicates['clusters'])==422
    assert len({sid for c in duplicates['clusters'] for sid in c['samples']})==422
    assert not duplicates['mixed_label_clusters']
    figures=read('figures/manifest.json')
    for name,digest in figures['input_sha256'].items():assert sha(HERE/name)==digest,(name,'stale figure input')
    for name,digest in figures['files'].items():assert sha(HERE/'figures'/name)==digest,(name,'changed plot')
    optional={}
    for name in ('common-dsl-checks.json','common-all-checks.json'):
        path=HERE/name
        if not path.exists():continue
        data=read(name);assert data['complete'];n=data['common_programs']
        for rs in data['samples'].values():assert len(rs)==n==len({r['sample_id'] for r in rs})
        for methods in data['metrics'].values():
            for m in methods.values():assert sum(m[k] for k in ('accepted_pass','accepted_fail','rejected_pass','rejected_fail','unavailable_pass','unavailable_fail'))==n
        optional[name]={'programs':n,'sha256':sha(path)}
    for directory in ('figures-dsl-checks','figures-all-checks','figures-pipeline'):
        path=HERE/directory/'manifest.json'
        if not path.exists():continue
        data=json.loads(path.read_text());assert sha(Path(data['source']))==data['input_sha256']
        for name,digest in data['files'].items():assert sha(path.parent/name)==digest
        optional[directory]={'files':len(data['files']),'manifest_sha256':sha(path)}
    paper=HERE/'figures-paper/manifest.json'
    if paper.exists():
        data=json.loads(paper.read_text())
        for name,digest in data['input_sha256'].items():assert sha(Path(name))==digest
        for name,digest in data['files'].items():assert sha(paper.parent/name)==digest
        optional['figures-paper']={'files':len(data['files']),'manifest_sha256':sha(paper)}
    context=HERE/'context-sensitivity.json'
    if context.exists():
        data=json.loads(context.read_text());assert data['processed_programs']==86
        for name,digest in data['input_sha256'].items():assert sha(HERE/name)==digest
        optional['context-sensitivity']={'programs':86,'sha256':sha(context)}
    inventory=HERE/'python-check-source-inventory.json'
    if inventory.exists():
        data=json.loads(inventory.read_text());assert data['successful_sources']==data['expected_generations']==16
        for row in data['records']:
            prediction=ROOT/row['prediction_file'];assert sha(prediction)==row['prediction_sha256']
            assert hashlib.sha256(json.loads(prediction.read_text())['extracted'].encode()).hexdigest()==row['source_sha256']
        optional['python-source-review']={'sources':16,'inventory_sha256':sha(inventory),'manual_review_sha256':sha(HERE/'PYTHON-CHECK-REVIEW.md')}
    result={'checked_at':datetime.now(timezone.utc).isoformat(),'status':'passed',
            'revised_unique_cases':410,'revised_infrastructure_retries':revised['infrastructure_retries'],
            'reference_controls':4,'native_syntax_candidates':422,'debian_metadata_candidates':422,
            'frontier_predictions':{'gpt6':422,'opus55':422},'structural_groups':duplicates['unique_structures'],
            'figure_artifacts':len(figures['files']),'additional_checks':optional,
            'scope':'Completion and provenance, not proof of gold-label correctness or unseen-task accuracy.',
            'source_sha256':{p.name:sha(p) for p in [HERE/'revised-summary.json',HERE/'additional-baselines.json',HERE/'frontier-full-comparison.json',HERE/'figures/manifest.json']}}
    (HERE/'audit.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__=='__main__':main()
