# Does the leakage actually inflate the score?

> ## ⚠️ The causal claim on this page is WITHDRAWN
>
> This page asked whether BashBench 2026's self-leakage inflates its headline score, and answered
> yes: 99.4% on leaked tasks vs 21.9% on clean ones, holding up under difficulty-matching and
> prompt-deduplication. **That interpretation is wrong**, and `benchmark-validity.md` shows why:
> the benchmark's `func_pass` **does not depend on the generated code at all**. The harness writes
> the candidate to `solution.sh` and then runs a test script that never reads it.
>
> So every number below is a property of the benchmark's *test scripts*, not of the model. The
> leaked/clean gap says test scripts for leaked tasks exit 0 at 99.4% and test scripts for clean
> tasks exit 0 at 21.9% — most likely because the clean tasks are much more complex (3.5× longer
> reference solutions, 8× the pipes, as measured below) and their generated tests reach for
> external tools that are absent from the bare sandbox. My difficulty-matching used
> reference-solution complexity as a proxy, which does not control for test-script fragility, so
> it did not rescue the claim.
>
> **What survives:** the leakage itself (91.7% identical after whitespace normalization, `bashbench-2026-audit.md`) — that
> is a hash match and is unaffected. The recitation signature below — that is measured on
> generated text, not on the harness, and also unaffected. What dies is "the leakage inflates the
> score," because on this benchmark *nothing* the model does can change the score.
>
> The rest of this page is kept as recorded, since the measurements are correct as measurements
> and the one useful thing they show is that **the clean subset is largely untestable**.

---

`bashbench-2026-audit.md` established that **709 of BashBench 2026's 773 scored single-line
benchmark tasks (91.7%) appear (after whitespace normalization) in the SFT file shipped in its own release**, against
an explicit claim of being "completely isolated from all training data."

Contamination existing is not the same as contamination mattering. This measures whether it does,
using the authors' own released per-task scores — no new model runs, nothing re-executed.

## The raw split

`test_results/single-line/ours/singleline_eval_20251222_022036.json` gives per-task `func_pass` /
`full_pass` for all 773 scored tasks. Partitioning by whether the task's `input` appears in
`sft_command.json`:

| group | n | FuncRate (95% Wilson) | FullRate |
|---|---|---|---|
| leaked into SFT | 709 | **99.4%** [98.6, 99.8] | 96.3% [94.7, 97.5] |
| clean of SFT | 64 | **21.9%** [13.5, 33.4] | 20.3% [12.3, 31.7] |
| leaked into SFT or GRPO | 715 | 99.4% | 96.4% |
| clean of both | 58 | **13.8%** [7.2, 24.9] | 12.1% [6.0, 22.9] |

Gap: **+77.6 points** FuncRate (Fisher exact p < 1e-40); **+85.6 points** against the
clean-of-both group.

The published headline is FuncRate **93.01%** (719/773) and FullRate **90.04%** (696/773). Those
numbers are arithmetically correct — they are just averages over a task set that is 91.7%
memorizable.

## Ruling out the obvious confound

A +77pt gap is also exactly what you would see if the non-leaked tasks were simply harder. They
**are** harder, substantially:

| | leaked (709) | clean (64) |
|---|---|---|
| reference solution length | 104 chars | **362 chars** |
| pipes + redirects + `&&` + `;` | 1.6 | **13.1** |
| prompt length | 62 chars | 85 chars |

So the raw gap cannot be read as memorization on its own. Matching on difficulty settles it:

| reference-solution complexity | leaked n | leaked FuncRate | clean n | clean FuncRate |
|---|---|---|---|---|
| 0 (no pipes/redirects) | 320 | 99.1% | 4 | 100.0% |
| 1–2 | 180 | 99.4% | 14 | **14.3%** |
| 3–5 | 181 | 100.0% | 11 | **27.3%** |
| 6–9 | 21 | 100.0% | 3 | **33.3%** |
| 10–14 | 4 | 100.0% | 20 | **0.0%** |
| 15+ | 3 | 100.0% | 12 | **33.3%** |

**Leaked tasks score 99–100% in every complexity band.** Clean tasks collapse as soon as the task
stops being trivial. On the one band where difficulty is genuinely equalized and both groups have
usable n — reference solutions at or above the clean set's median length — leaked scores **98.1%
(n=54)** and clean scores **12.5% (n=32)**.

Difficulty is therefore not the explanation. At matched difficulty the entire gap survives.

Note the band-0 row: on trivial tasks both groups score ~100%. That is the expected shape — leakage
buys nothing where the task is solvable without it — and it is a useful internal sanity check that
the partition is not just separating "good records" from "bad records."

## Ruling out the second confound: the records are not independent

The 773 tasks are only **606 distinct prompts**, and the clean group is only **27 distinct prompts**
of the 64 records — one prompt appears 16 times, and it fails all 16. So the record-level 21.9%
is partly one bad task counted sixteen times. Three progressively more conservative cuts:

| cut | leaked | clean |
|---|---|---|
| record level (as published) | 99.4% (705/709) | 21.9% (14/64) |
| drop the ×16 repeated prompt entirely | 99.4% (705/709) | **29.2%** (14/48) |
| prompt level, one vote per distinct prompt | 99.5% (576/579) | **37.0%** (10/27) |
| prompt level **and** length-matched | **99.4%** (175/176) [96.9, 99.9] | **28.6%** (4/14) [11.7, 54.6] |

The last row is the one to quote: deduplicated *and* difficulty-matched, the gap is **+70.8 points**
with confidence intervals nowhere near overlapping. Every way of being conservative about it leaves
the effect intact.

## A recitation signature, independent of the pass rates

For a leaked task there are **two** reference answers: the one in the SFT training file and the one
in the benchmark. The audit found these are never identical (0 shared input+output pairs). So which
one the model reproduces is diagnostic, and it can be measured without executing anything.

| on leaked tasks (n=709) | vs benchmark reference | vs SFT training answer |
|---|---|---|
| reproduced verbatim | 5.9% | **13.8%** |
| mean similarity | 0.562 | **0.692** |

The model reproduces the *training* answer more than twice as often as the benchmark's own reference
answer, and is measurably closer to it. On clean tasks it reproduces the benchmark reference **0%**
of the time, at mean similarity 0.325.

One honest qualification: pass rate does **not** track recitation. Leaked tasks where the model
reproduced the SFT answer verbatim pass 99.0%; leaked tasks where it did not pass 99.5%. So verbatim
recall is not the mechanism — the model does not need to recite to pass a task it was trained on.
The signature shows the training answers are in there; the pass-rate gap is what shows they matter.

## What this means

**Superseded — see the banner at the top.** What I concluded here was that the reported 93.01%
FuncRate is a weighted average of ~99% recall on the memorized 91.7% and ~29% capability on the
rest, implying real performance near 30%. That inference required `func_pass` to be a function of
the generated code, and it is not.

The correct reading of the split: **the 64 "clean" records are largely untestable** — their test
scripts fail in the sandbox 78% of the time on their own. That is worth knowing if anyone tries to
salvage a held-out subset from this benchmark, and it is the opposite of a capability estimate.

## Open question: the multi-line half — RESOLVED

**Resolved in `benchmark-validity.md`, and neither reading below was right.** The multi-line half
is genuinely held out — a near-duplicate scan (`data/neardup.py`) puts its mean
nearest-training-neighbour similarity at 0.135, against 0.118 for same-generator training items
compared to each other and 1.000 for the known-leaked control, so reading 1's premise holds and
reading 2 is unsupported. But its 93.9% is not capability either: **every model tested scores
93.3–94.1% once its code is extractable**, because the multi-line tests are candidate-independent
in exactly the same way. The section below is kept for the record.

### (as recorded before the resolution)

The 179 multi-line tasks are clean of the released script-side SFT and GRPO sets, and BashCoder-R1
scores **93.9%** on them (168/179). That does not fit a simple memorization story and is the
strongest evidence *against* the reading above — a genuinely held-out split scoring 93.9% suggests
real capability.

Two readings, not distinguished:
1. The model genuinely generalizes on multi-line tasks, and the single-line gap reflects something
   about the single-line clean subset specifically.
2. The multi-line tasks leaked at a different training stage. The release also ships a **4.3 GB
   continued-pretraining corpus** (`data/cpt/bash_cpt_with_general.jsonl`) that no contamination
   check would normally look at, because it is a pretraining corpus rather than a labelled set.

**Reading 2 was tested and the test came back uninformative.** `data/cpt_scan.py` streams that
corpus and Aho-Corasick-searches it for all 179 multi-line prompts and the 27 distinct clean
single-line prompts, with 58 known-leaked prompts as a positive control on the scanner:

| needle group | found in the CPT corpus |
|---|---|
| multi-line benchmark prompts (179) | 0 |
| clean single-line prompts (27) | 0 |
| **known-leaked prompts (58) — positive control** | **1 (1.7%)** |

The control essentially failed, which is the expected outcome in hindsight: the CPT corpus is raw
Bash text and documentation, not instruction prompts, so a *task prompt* would not appear there
verbatim even for tasks we know leaked into SFT. **A 0% here therefore cannot be read as "the
multi-line half is clean at the pretraining stage"** — it only says this method cannot see that kind
of leakage. Testing reading 2 properly would need a semantic or code-side match against the CPT
corpus rather than a prompt-string match. (Coverage caveat: the stream ended after 3.21 GB of the
listed 4.29 GB, so ~75% of the corpus was scanned. Given the control failed, more coverage would not
have changed the conclusion.)

So the multi-line anomaly stands unexplained, and the claim above is scoped to the single-line
benchmark.

## Caveats

- "Clean" here means absent from `sft_command.json`. Only 64 of 773 records — 27 distinct prompts —
  qualify, so the clean-side rates carry wide intervals (reported above). This is the binding
  limitation on the result: the effect is large and robust, but it rests on 27 held-out tasks.
- Leaked-side n is small in the top complexity bands (4 and 3). The prompt-deduplicated
  length-matched comparison (n=176 vs 14) is the one to quote.
- Leakage is task-level, not record-level — no benchmark task shares an identical (input, output)
  pair with the SFT set. The questions leaked; the reference answers did not. The effect measured
  here happens anyway.
- Near-duplicate check: 0 of the 64 clean prompts match an SFT prompt after lowercasing or as a bag
  of words, so the clean set is not an artifact of whitespace-sensitive hashing.

## Reproducing

`data/leak_effect.py` (the split + Fisher tests), `data/leak_controls.py` (difficulty proxies,
near-duplicate check, multi-line comparison), `data/leak_matched.py` (the matched-difficulty table).
They need the archive's evaluation/SFT/GRPO JSONs and the single-line `test_results` file, pulled
from <https://zenodo.org/records/18408692> via `data/pull_results.py`.
