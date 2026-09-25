#!/usr/bin/env python3
"""Fixed lexical retrieval ablation: original-only versus expanded demo pool."""
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import re
from llm_pilot import request, extract, FQL_GUIDE

ROOT = Path(__file__).resolve().parents[1]


def tokens(text):
    stop = {'a', 'an', 'the', 'to', 'of', 'and', 'is', 'in', 'on', 'for', 'with', 'it', 'be'}
    return Counter(w for w in re.findall(r'[a-z]+', text.lower()) if w not in stop)


def retrieve(target, pool, count=4):
    candidates = [b for b in pool if b['id'] != target['id']]
    docs = [tokens(b['natural_language']) for b in candidates]
    query = tokens(target['natural_language'])
    df = Counter(w for d in docs for w in d)
    def vector(d): return {w: n * (math.log((len(docs) + 1) / (df[w] + 1)) + 1) for w, n in d.items()}
    q = vector(query); qnorm = math.sqrt(sum(v*v for v in q.values()))
    scores = []
    for b, doc in zip(candidates, docs):
        v = vector(doc); norm = math.sqrt(sum(x*x for x in v.values()))
        score = sum(x * q.get(w, 0) for w, x in v.items()) / (norm*qnorm) if norm*qnorm else 0
        scores.append((score, b))
    return sorted(scores, key=lambda item: (-item[0], item[1]['id']))[:count]


def main():
    originals = json.loads((ROOT / 'benchmarks/original.json').read_text())
    expanded = json.loads((ROOT / 'benchmarks/expanded.json').read_text())
    supported = {r['task_id'] for r in map(json.loads,
        (ROOT / 'reports/fql-queries.jsonl').read_text().splitlines())
        if r['source'] == 'authored_candidate' and r['result']['returncode'] == 0}
    guide = FQL_GUIDE.replace('from remote/controller "PATH" to remote/controller "PATH".',
        'from remote "PATH" to remote "PATH"; use controller instead of remote only when explicitly requested. Bare file paths mean remote.')
    for name, pool in [('original', originals), ('expanded', originals + [b for b in expanded if b['id'] in supported])]:
        out = ROOT / f'experiments/qwen-retrieval-{name}/fql-4shot-retrieved'
        out.mkdir(parents=True, exist_ok=True)
        for target in originals:
            file = out / (target['id'] + '-query.json')
            if file.exists(): continue
            demos = retrieve(target, pool)
            messages = [{'role': 'system', 'content': guide}]
            for _, demo in demos:
                messages.extend([{'role': 'user', 'content': demo['natural_language']},
                                 {'role': 'assistant', 'content': demo['formal_query']}])
            messages.append({'role': 'user', 'content': target['natural_language']})
            r = request(messages, 'brancher-llm', 320)
            r.update(task_id=target['id'], variant='query', mode='fql', shots=4,
                     constrained=False, diverse_demos=False, demonstration_ids=[b['id'] for _, b in demos],
                     retrieval_scores=[score for score, _ in demos], demo_pool_size=len(pool)-1,
                     condition='Lexical TF-IDF retrieval; target task excluded; same-family examples allowed; no grammar constraint',
                     pool=name, source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                     prompt_sha256=hashlib.sha256(json.dumps(messages, sort_keys=True).encode()).hexdigest(),
                     limitation='Expanded candidates pass lowering but lack independent intent review; exploratory non-holdout ablation')
            file.write_text(json.dumps(r, indent=2) + '\n')
            file.with_suffix('.fql').write_text(extract(r['text']) + '\n')
            print(name, target['id'], r.get('finish_reason', r.get('error')), flush=True)


if __name__ == '__main__': main()
