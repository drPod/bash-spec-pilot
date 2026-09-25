#!/usr/bin/env python3
"""Repeat the expanded retrieval prompts with v2 constrained decoding."""
import hashlib
import json
from pathlib import Path
from llm_pilot import request, extract

ROOT = Path(__file__).resolve().parents[1]


def main():
    source = ROOT / 'experiments/qwen-retrieval-expanded/fql-4shot-retrieved'
    out = ROOT / 'experiments/qwen-retrieval-expanded-constrained/fql-4shot-retrieved-constrained'
    out.mkdir(parents=True, exist_ok=True)
    grammar = (ROOT / 'experiments/fql-subset-v2.gbnf').read_text()
    files = sorted(source.glob('*.json'))
    if len(files) != 21: raise RuntimeError('Expected 21 complete retrieval prompts')
    for file in files:
        dest = out / file.name
        if dest.exists(): continue
        old = json.loads(file.read_text())
        r = request(old['request']['messages'], 'brancher-llm', old['request']['max_tokens'], grammar=grammar)
        r.update({k: old[k] for k in ('task_id', 'variant', 'mode', 'shots', 'diverse_demos',
                  'demonstration_ids', 'retrieval_scores', 'demo_pool_size', 'pool', 'prompt_sha256')})
        r.update(constrained=True, source_record=str(file.relative_to(ROOT)),
                 source_record_sha256=hashlib.sha256(file.read_bytes()).hexdigest(),
                 grammar_sha256=hashlib.sha256(grammar.encode()).hexdigest(),
                 condition='Same expanded-retrieval messages and token budget, plus v2 decoding grammar; single fresh sample, no matched random seed')
        dest.write_text(json.dumps(r, indent=2) + '\n')
        dest.with_suffix('.fql').write_text(extract(r['text']) + '\n')
        print(r['task_id'], r.get('finish_reason', r.get('error')), flush=True)


if __name__ == '__main__': main()
