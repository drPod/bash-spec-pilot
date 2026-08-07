# Measurement artifacts

Every number in the writeups above is re-derivable from these scripts. Run them from this directory.

## Load order matters

`res1.json` and `res2.json` are the **raw first pass**, and they are kept as-is on purpose: four of
their entries picked the wrong command column, and that mistake is the methodological lesson the
writeups cite. Correcting them in place would erase the evidence for it.

`fix.py` re-measures exactly those four datasets with the column named manually, and writes
`res_fix.json`. The superseded entries in `res1`/`res2` carry a `superseded_by` field pointing at it.

**Anything consuming these files must load `res_fix.json` last, so the corrected entries win.** Use
`resload.load()`, which does that and re-attaches the hashes; `dupes.py`, `refoverlap.py`,
`control.py` and `remeasure.py` all go through it. It is not cosmetic: `AnishJoshi/nl2bash-custom`
is one of the four corrected datasets *and* a member of the reference union in `control.py`, so
loading only `res1`/`res2` would build the contamination baseline itself out of NL-column hashes.

| Dataset | first pass picked | actually | effect |
|---|---|---|---|
| `AnishJoshi/nl2bash-custom` | `nl_command` | `bash_code` | multi-line 0.0% → 6.6% |
| `jragsdale1/ShIO-bash-26.1` | `output` | `input` | multi-line 60.3% → 0.1% |
| `adeelahmad/bash-agent-grpo-pairs` | `answer` | `ground_truth` | multi-line 100% → 46.2% |
| `saurabh5/rlvr-code-data-bash` | `target_language` | `translated_solution` | 1 unique → 66,004 |

## Where the hashes live

The `hashes` arrays are stripped from `res1`/`res2`/`res_fix` to keep those files reviewable, and
they are committed separately in **`hashes.json.gz`** (52 datasets, 736,871 command hashes, 5 MB)
with the corrected columns already applied. `resload.load()` merges the two back together.

This file is not a convenience. Without it `dupes.py`, `refoverlap.py`, `control.py` and
`remeasure.py` do not fail, they return *empty* results, and regenerating it means re-downloading
tens of gigabytes of Parquet and re-sampling, which does not reproduce the original run. An earlier
version of this directory shipped the stripped files alone, and the first attempt to re-derive
`dupe_pairs.json` from them silently produced zero pairs.

## Pipeline

| Stage | Script | Output |
|---|---|---|
| Discover datasets on HuggingFace | `sweep.py`, `sweep2.py`, `sweep3.py` | raw index |
| Shortlist plausible candidates | `score.py`, `score2.py` | shortlist |
| Row counts via datasets-server `/size` | `probe.py` | `sizes.json` |
| Pull Parquet, pick column, hash commands | `analyze.py` | `res1.json`, `res2.json` |
| Re-measure the four bad columns | `fix.py` | `res_fix.json` |
| Merge the three, re-attach the hashes | `resload.py` | (imported, not run) |
| Dataset-vs-dataset containment | `dupes.py` | `dupe_pairs.json` |
| Overlap against the 5 canonical corpora | `refoverlap.py` | printed table |
| Contamination, with positive + baseline controls | `remeasure.py`, `control.py` | `remeasure.json` |
| Dataset-card keyword scan | `cards.py` | printed |

`sweep2.py` is kept as the record of a dead end: the HF API silently ignores its `offset`
parameter, so paginating that way returns the same page forever. `sweep3.py` paginates by varying
`search` instead, which is what took the sweep from 809 to 5,661 unique datasets.

## BashBench 2026 audit

| Purpose | Script |
|---|---|
| Contamination + duplication from the extracted Zenodo archive | `bashbench_audit.py <dir>` |
| Fetch single-line result files from the 1.1 GB zip by range request | `pull_results.py` |
| Fetch multi-line baselines + harness source the same way | `pull_ml.py` |
| Tests do not depend on the candidate (the decisive check) | `candidate_independence.py` |
| Near-duplicate scan of the multi-line split, with controls | `neardup.py`, `neardup_effect.py` |
| Leaked-vs-clean splits, difficulty matching, prompt dedup | `leak_effect.py`, `leak_matched.py`, `leak_prompt_level.py`, `leak_controls.py` |
| Verbatim-recall signature in generated text | `recitation.py` |
| Prompt search over the continued-pretraining corpus | `cpt_scan.py` |

`baseline-summaries/` holds the eight per-model evaluation reports **verbatim from the BashCoder-R1
release**. They are upstream evidence, not output of anything here: the Chinese headings, the
`FuncRate` / `FullRate` labels, and the `/data/hzr/DSL_Working/...` sandbox paths are the original
authors'. Do not clean them up. The whole point of `candidate_independence.py` is that those
`FuncRate` numbers do not mean what they are labelled, which is only demonstrable against the
untouched files.

Two of these carry results that did not survive, and both are kept with the reason recorded rather
than deleted. The `leak_*` scripts measure a real gap, but `candidate_independence.py` shows what
that gap actually reflects, so the causal reading in `leakage-effect.md` is withdrawn there.
`cpt_scan.py` returned an uninformative result: its positive control (58 prompts known to be leaked)
hit only 1 of 58, because the corpus is raw bash text rather than instruction prompts, so its 0%
findings mean nothing and must not be reported as evidence of cleanliness.
