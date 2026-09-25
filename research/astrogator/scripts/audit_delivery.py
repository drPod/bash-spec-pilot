#!/usr/bin/env python3
"""Check the recorded contribution's coverage; do not infer paper readiness."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path): return json.loads((ROOT / path).read_text())
def lines(path): return [json.loads(x) for x in (ROOT / path).read_text().splitlines()]


def main():
    original = read('benchmarks/original.json'); expanded = read('benchmarks/expanded.json')
    assert len(original) == 21 and len(expanded) == 49
    assert len({r['id'] for r in original + expanded}) == 70
    runtime = read('reports/expansion-final.json')
    assert all(runtime['tasks'][r['id']]['reference_validated'] and
               runtime['tasks'][r['id']]['mutant_killed'] for r in expanded)
    query_results = [r for r in lines('reports/fql-queries.jsonl') if r['source'] != 'upstream']
    assert len(query_results) == 70
    assert {r['task_id'] for r in query_results} == {r['id'] for r in original + expanded}
    translated = lines('reports/fql-translations.jsonl')
    effects = lines('reports/fql-effect-comparison.jsonl')
    outputs = sorted((ROOT / 'experiments').glob('*/fql-*/*.json'))
    output_paths = {str(p.relative_to(ROOT)) for p in outputs}
    assert len(translated) == len(effects) == len(outputs)
    assert {r['path'] for r in translated} == {r['path'] for r in effects} == output_paths
    fresh_calls = 0
    for path in outputs:
        r = json.loads(path.read_text())
        assert r['task_id'] not in r['demonstration_ids']
        assert path.with_suffix('.fql').exists()
        fresh_calls += not r.get('request_reused', False)
        if 'retrieval-expanded-constrained' in str(path):
            source = ROOT / r['source_record']
            old = json.loads(source.read_text())
            assert r['request']['messages'] == old['request']['messages']
            assert r['request']['max_tokens'] == old['request']['max_tokens']
            assert hashlib.sha256(source.read_bytes()).hexdigest() == r['source_record_sha256']
    assert read('reports/grammar-coverage-v2.json')['recognized'] == 21
    assert all(r['same_parse_AST'] for r in lines('reports/grammar-canonical-equivalence.jsonl'))
    assert all(r['passed'] for r in read('reports/effect-controls.json')['controls'])
    corpus = lines('data/manifest.jsonl')
    ids = {r['sample_id'] for r in corpus}
    candidate_hashes = {r['sample_id']: r['artifacts']['response']['sha256']
                        for r in corpus if 'response' in r['artifacts']}
    for name in ('corpus-verifier', 'corpus-heuristic-verifier', 'generated-query-verifier'):
        rs = lines('reports/' + name + '.jsonl')
        assert len(rs) == len(ids) == 2310 and {r['sample_id'] for r in rs} == ids
        assert all(r['code_sha256'] == candidate_hashes[r['sample_id']]
                   for r in rs if r['sample_id'] in candidate_hashes)
    execution = read('experiments/four-task-full-v1/summary.json')
    assert execution['complete'] and execution['observed_cases'] == 844
    paired = read('reports/four-task-comparison.json')
    assert paired['execution_complete'] and paired['heuristic_complete']
    gates = read('experiments/four-task-tests-v1/gates.json')
    assert len(gates) == 4
    report = {'checked_at': datetime.now(timezone.utc).isoformat(),
              'task_records': 70, 'new_executable_references': 49, 'selected_mutants_caught': 49,
              'queries_lowered': sum(r['result']['returncode'] == 0 for r in query_results),
              'translation_records': len(outputs), 'fresh_translation_calls': fresh_calls,
              'translation_stage_and_effect_coverage': True,
              'full_corpus_stage_sweeps': ['base', 'configured heuristics', 'repaired-query transfer'],
              'independent_local_candidate_state_executions': 844,
              'judge_complete': paired['judge_complete'], 'generated_check_gates': {t: r['status'] for t, r in gates.items()},
              'required_before_final_snapshot': [] if paired['judge_complete'] else ['Finish frozen judge run and refresh paired report'],
              'not_established': ['Publication-ready independent specification review',
                  'Universal correctness from local checks', 'Multi-OS execution accuracy',
                  'Frontier-model performance or repeated-sample statistical gains']}
    (ROOT / 'reports/delivery-audit.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__': main()
