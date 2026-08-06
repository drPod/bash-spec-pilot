# Which Bash benchmarks are actually held out?

A benchmark is only held-out data if its tasks are not in the corpora people train on. For Bash
that is checkable, because both the benchmarks and the dominant training corpora are public. We
measured it.

Method: MD5 over whitespace-normalized command strings; a benchmark task counts as contaminated if
its command appears byte-identically in a training corpus. Training side = the eight corpora that
most HuggingFace Bash datasets descend from or reproduce (NL2Bash, NL2CMD, NL2CMD-Fu, NL2SH-ALFA,
tldr-pages, NL-SHELL-MULTI, nl2bash-custom, cli-commands-explained).

## Result: contamination tracks how the benchmark was built

| Benchmark | Tasks measured | In the largest single corpus | In any of the eight |
|---|---|---|---|
| `westenfelder/InterCode-Corrections` | 192 | 100.0% (NL2SH-ALFA) | **100.0%** |
| `epinnock/intercode-nl2bash-curated` | 196 | 60.2% (NL2SH-ALFA) | **63.8%** |
| `ia03/terminal-bench` | 112 | 0.0% | **0.0%** |
| `IntelligenceLab/Long-Horizon-Terminal-Bench` | 46 | 0.0% | **0.0%** |
| `Eccentricity/bashbench2` | 637 | 0.0% | **0.0%** |
| `tiararodney/posix-sdc` | 2,367 | 0.0% | **0.0%** |
| `AISafety-Student/labeled-bashBench` | 100 | 0.0% | **0.0%** |

The split is clean, and it is not about age or quality — it is about construction method:

- **Benchmarks assembled by sampling an existing NL→command corpus are contaminated by
  construction.** The InterCode line is drawn from NL2Bash, so every task in it is, by definition,
  in the corpus that most Bash models are tuned on. There is no way to fix this by filtering; the
  benchmark *is* a subset of the training set.
- **Benchmarks built by authoring tasks against an execution environment are clean.** Terminal-Bench,
  bashbench2, LHTB and posix-sdc write new tasks around a Docker image or a state checker rather
  than sampling a corpus, and none of their commands appear in any of the eight.

## The second mode: self-contamination

BashBench (BashCoder-R1, arXiv 2606.27733) is execution-based and would be expected to land in the
clean group, but it fails a different way: **709 of its 773 single-line tasks (91.7%) appear in the
SFT file shipped in its own release**, while claiming to be "completely isolated from all training
data." Its 179 multi-line tasks are clean. Full measurement in `bashbench-2026-audit.md`.

So there are two distinct failure modes, and they need different checks:

1. *Inherited* contamination — the benchmark is a subset of a public corpus. Detect by comparing
   against the public training corpora, as in the table above.
2. *Self-* contamination — the benchmark overlaps the authors' own training data. Only detectable
   when the training set is released alongside, which is exactly when nobody checks.

## What this means for us

Evaluating on the InterCode/NL2Bash line measures memorization as much as capability, for any model
that has seen public Bash instruction data — which is essentially all of them. If we report a
verification success rate on those tasks, that number cannot be read as generalization.

The benchmarks that survive both checks: **Terminal-Bench and its family, bashbench2, posix-sdc, and
BashBench's 179 multi-line tasks.** All are execution-environment benchmarks, and all are
multi-line — which is the same regime flagged in the README as data-poor and verification-hard. The
trustworthy data and the hard data are the same small pile.

## Caveats

- Exact-match contamination is a lower bound. Near-duplicates (a renamed flag, a different path)
  are not counted, so true contamination is at least this high.
- Terminal-Bench-family rows are measured on the HuggingFace task *descriptions* available to us,
  not on full task directories.
- `saurabh5/rlvr-code-data-bash` is excluded from the table: our stored hashes for it came from the
  mis-detected column, so the figure would be meaningless. Its corrected measurement (0% overlap on
  66,624 solutions) is in `rows-to-add.csv`.

Reproduce from `data/res1.json` / `data/res2.json` — note the committed copies have the hash arrays
stripped for size, so re-run `data/analyze.py` to regenerate them.
