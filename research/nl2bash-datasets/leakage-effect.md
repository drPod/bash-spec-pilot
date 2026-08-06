# Does the leakage actually inflate the score?

`bashbench-2026-audit.md` established that **709 of BashBench 2026's 773 scored single-line
benchmark tasks (91.7%) appear byte-identically in the SFT file shipped in its own release**, against
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

## What this means

The reported 93.01% FuncRate is not an estimate of how well BashCoder-R1 writes Bash. It is
approximately a weighted average of ~99% recall on the 91.7% of tasks it was trained on and ~29%
capability on the remainder. **The generalizing performance implied by these numbers is roughly
30%, not 93%** — taking the most conservative (deduplicated, difficulty-matched) estimate.

That reframes the paper's headline comparison against baselines, none of which were trained on this
SFT set, so none of which get the recall term.

## Open question: the multi-line half

The 179 multi-line tasks are clean of the released script-side SFT and GRPO sets, and BashCoder-R1
scores **93.9%** on them (168/179). That does not fit a simple memorization story and is the
strongest evidence *against* the reading above — a genuinely held-out split scoring 93.9% suggests
real capability.

Two readings, not yet distinguished:
1. The model genuinely generalizes on multi-line tasks, and the single-line gap reflects something
   about the single-line clean subset specifically.
2. The multi-line tasks leaked at a different training stage. The release also ships a **4.3 GB
   continued-pretraining corpus** (`data/cpt/bash_cpt_with_general.jsonl`) that no contamination
   check would normally look at, because it is a pretraining corpus rather than a labelled set.

`data/cpt_scan.py` streams that corpus and Aho-Corasick-searches it for all 179 multi-line prompts
and all 64 clean single-line prompts, with 60 known-leaked prompts included as a positive control on
the scanner. Result in `data/cpt_scan.json` once it lands. Until then this section is open, and the
claim above is scoped to the single-line benchmark.

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
