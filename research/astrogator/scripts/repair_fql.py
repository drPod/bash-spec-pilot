#!/usr/bin/env python3
"""One diagnostic-feedback retry, without reference FQL or correctness labels."""
import json
from pathlib import Path
from llm_pilot import request,extract

ROOT=Path(__file__).resolve().parents[1]


def main():
    source_dir=ROOT/'experiments/qwen-grammar-v2/fql-3shot-constrained'
    out=ROOT/'experiments/qwen-grammar-v2-repair/fql-3shot-constrained-repair1'
    out.mkdir(parents=True,exist_ok=True)
    diagnoses={r['path']:r['result'] for r in map(json.loads,(ROOT/'reports/fql-translations.jsonl').read_text().splitlines())}
    grammar=(ROOT/'experiments/fql-subset-v2.gbnf').read_text()
    for source in sorted(source_dir.glob('*.json')):
        dest=out/source.name
        if dest.exists(): continue
        original=json.loads(source.read_text()); key=str(source.relative_to(ROOT))
        diagnosis=diagnoses[key]
        if diagnosis['returncode']==0:
            result={**original,'repair_attempted':False,'request_reused':True}
        else:
            # Only machine diagnostics. Do not read reference queries or comparisons.
            detail=diagnosis['stdout']+diagnosis['stderr']
            messages=original['request']['messages']+[
                {'role':'assistant','content':original['text']},
                {'role':'user','content':'Your FQL query failed machine validation:\n'+detail+
                 '\nReturn one corrected FQL query only. Preserve all actions and conditions in the original request; do not drop requirements just to make the query valid.'}]
            result=request(messages,'brancher-llm',320,grammar=grammar)
            result.update({k:original[k] for k in ['task_id','variant','mode','shots','demonstration_ids','constrained','diverse_demos']})
            result.update(repair_attempted=True,request_reused=False)
        result.update(source_record=key,feedback=diagnosis,
                      condition='one diagnostic retry if parsing/semantic analysis/codegen failed; no reference query supplied')
        dest.write_text(json.dumps(result,indent=2)+'\n')
        dest.with_suffix('.fql').write_text(extract(result['text'])+'\n')
        print(original['task_id'],'repaired' if result['repair_attempted'] else 'retained',flush=True)


if __name__=='__main__': main()
