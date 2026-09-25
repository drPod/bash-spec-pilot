# Source-grounded FQL translation

This is a matched prompt-support intervention: expose the language's actual semantic interface, rather than ask a model to infer that interface from a short guide and four examples. It requires no change to Astrogator, no model training, and no target reference query at prediction time.

The source-derived handbook documents all supported action families; argument names and value forms; statement and conditional scope; case-sensitive OS refinement; and the complete pinned `Knowledge.Example` resource/package/service catalog. Those semantic constraints cannot be guaranteed by a syntax grammar alone. The hypothesis is that explicit semantic interface documentation improves compiler validity and intent capture beyond the existing compact-guide baseline. Results may contradict this hypothesis; all predictions must be retained.

## Frozen matched design

`runs/frozen-inputs.json` copies the 63 translation cells (21 tasks × three repetitions) from `../integration/frontier/frozen-inputs.json`. Only the first system message changes. Demonstration IDs, demonstration queries, their order, and final user description are byte-equivalent in the parsed message records. The two model aliases and transport implementation are inherited. Transport is the same isolated CLI mechanism as the baseline, including tool restrictions and detection. `run.py prepare` refuses to overwrite a different existing freeze.

Run with the existing research environment:

```
research/astrogator/.venv/bin/python research/astrogator/phase2/translation_method/run.py prepare
research/astrogator/.venv/bin/python research/astrogator/phase2/translation_method/run.py run --models gpt6 opus55 --workers 2
```

Inference must be launched by the coordinating agent under the workspace resource limits; this arm's author has not launched model calls. Output cells have the same IDs as baseline in their own `runs/MODEL/` directories. Analyze using the same parser, semantic/codegen, and normalized semantic-effect pipeline as baseline. Do not compare only successful records or discard unfavorable repeats.

## Provenance and leakage boundary

The author read only the source files `lib/fql/parser.mly`, `lexer.mll`, `semant.ml`, and `knowledge.ml` in `/tmp/astrogator-upstream`, plus the existing inference runner and probe driver. Source hashes are recorded in the freeze. The existing pinned upstream commit is `7c62afa51986d87033af5112cdccd3b104b1c120`.

No frontier model outputs, target reference queries, or semantic-difference reports were read to construct this handbook. The preparation program reads the existing baseline frozen input solely to copy demonstration messages and targets; it does not extract benchmark target references or outcomes. The handbook is deliberately global and identical for every target. This is outcome-blind method design, not a claim that the underlying benchmark or KB is unseen.

The existing Example KB itself reflects the original project's domain and contains resources overlapping benchmark tasks. Exposing this source is a legitimate engineering intervention but NOT evidence of generalization to a new domain, a learned KB, or independently held-out specifications. The handbook is manually summarized from source, not an automatically extracted specification. Prompt length is larger than the baseline, so this is not a token-budget-matched ablation. Independent calls/repetitions have no matched sampling seeds.

## Validation and limits

`check_handbook.py` creates 48 generic, source-derived signature smoke cases with neutral `/probe/` paths and probe users. None are copied from target benchmark references. `handbook-checks.json` records every query and actual upstream parse, semantic, and code-generation diagnostics. **All 48 pass all three processing stages.** These cover every major action form and the KB/OS features highlighted by the handbook; they do not prove the manual reference is exhaustive or semantically correct for arbitrary requests.

`design-audit.json` verifies preservation of all 63 baseline demonstration/target message sequences and guide identity. `handbook.md` and the frozen input contain matching guide bytes.

Higher parsing/lowering rates alone are not higher intent accuracy. Normalized effect equality is also a proxy, and syntactically valid unsupported requests must not be silently weakened. A proper report should show per-task changes, repeated-call variation, missing/error outcomes, and remaining obligation failures. Do not attribute any improvement uniquely to the KB catalog versus action signatures versus self-check instructions: they are bundled in this intervention.
