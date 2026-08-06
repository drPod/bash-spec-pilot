# NL→Bash dataset survey

Answers Aaron's request (2026-08-06): find NL + Bash datasets for the project's evaluation, with
links, single-line vs multi-line counts, whether the dataset ships any evaluation, and which ones
are duplicates of each other.

| File | What it is |
|---|---|
| `rows-to-add.csv` | **The deliverable.** 45 rows in the sheet's exact column order (`Name / # Single Line / # Multi Line / Includes Eval? / Available? / Notes`) — paste straight in. |
| `duplicates.md` | Measured duplicate clusters, corrections to two rows already on the sheet, and what each corpus is actually made of. |
| `contamination.md` | Which benchmarks are actually held out, measured against the public training corpora. |
| `bashbench-2026-audit.md` | Why the most promising benchmark's single-line half can't be used as held-out data. |
| `data/` | Raw measurement JSON and the scripts, so any number here can be re-derived. |

## Method

Counts are measured, not copied from dataset cards.

1. **Discovery** — swept the HuggingFace dataset index via
   `https://huggingface.co/api/datasets?search=…&limit=1000&full=true` across ~40 query terms,
   yielding **5,661 unique datasets**, then filtered to 499 plausible candidates and probed 89 in
   depth. (The API's `offset` parameter is silently ignored; paginate by varying `search`.)
2. **Row counts** — datasets-server `/size` endpoint.
3. **Single vs multi-line** — download the Parquet export, pick the command column, classify each
   value by `"\n" in value.strip()`. For datasets too large to pull whole, the split is measured on
   a sample and labelled as such in the Notes.
4. **Duplicates** — MD5 of every whitespace-normalized command string, then containment
   (`|A ∩ B| / |A|`) and Jaccard against five reference corpora (NL2Bash, NL2CMD, NL2CMD-Fu,
   NL2SH-ALFA, tldr-pages).
5. **Literature and GitHub** — 2023–2026 sweep for benchmarks that never reached HuggingFace.

One caveat worth stating: automatic column detection by name (`command`, `output`, `answer`, …)
picks the wrong column often enough that every overlap figure here was re-checked by printing sample
values. Four datasets had to be re-measured after this check, and it flipped one conclusion
completely (`AnishJoshi/nl2bash-custom` looked independent, and is actually 60% ⊆ NL2Bash).

## The four things worth acting on

**0. Half the Bash benchmarks in common use are not held-out data.** Measured against the eight
corpora most HuggingFace Bash datasets descend from, contamination tracks *how the benchmark was
built*: benchmarks assembled by sampling an existing NL→command corpus are contaminated by
construction (`InterCode-Corrections` 100%, `intercode-nl2bash-curated` 64%), while benchmarks
authored against an execution environment are clean (Terminal-Bench, LHTB, `bashbench2`,
`posix-sdc`, all 0%). A verification success rate reported on the InterCode/NL2Bash line measures
memorization as much as capability. Details and the second failure mode — a benchmark leaking
against its *own* released training data — in `contamination.md`.

**1. BashBench (BashCoder-R1, arXiv 2606.27733, 2026) looked like the best fit — use only its
multi-line half.** 952 tasks split **773 single-line / 179 multi-line**, each with an executable
test suite. It is the only dataset publishing an explicit single/multi split *and* per-task tests.
Release: <https://zenodo.org/records/18408692> (1.1 GB, CC-BY-4.0).

We audited it before recommending it (`bashbench-2026-audit.md`, reproducible via
`data/bashbench_audit.py`). The paper states the tasks are *"completely isolated from all training
data."* Measured against the released artifact:

| | single-line (773) | multi-line (179) |
|---|---|---|
| appears in the released SFT file | **709 = 91.7%** | **0** |
| appears in the released GRPO file | 204 = 26.4% | 0 |
| unique prompts | **606 of 773** (one repeats 16×) | 179 of 179 |

The leakage is task-level, not record-level — no benchmark task shares an identical (input, output)
pair with the training set, so the *questions* leaked and the *answers* did not. That still does not
support "completely isolated." The **179 multi-line tasks are clean** and are the regime this
project cares about, so they are the defensible core. Two further caveats: only ~40 of the 179
multi-line tests are re-runnable from the archive, and the harness executes model output as plain
bash on the host with no container isolation.

⚠️ **Two unrelated benchmarks are both named "BashBench."** The other is Redwood Research's
(Ctrl-Z, arXiv 2504.10374): 257 multi-step sysadmin tasks graded by public + private pytest suites.
Both are on the sheet; disambiguate by year when citing.

**2. Multi-line coverage is the ecosystem's blind spot.** Almost everything in the NL2Bash lineage
is single-line one-liners. The only substantial multi-line sources found are:

| Source | Multi-line | Has tests? |
|---|---|---|
| `saurabh5/rlvr-code-data-bash` | 66,614 (100% of its bash rows) | yes |
| `ajibawa-2023/Shell-Code-Large` | ~101,390 in sample (98.4%) | no, and no NL side |
| `tiararodney/posix-sdc` | ~1,935 (65%) | yes (`checker`) |
| BashBench 2026 | 179 eval + 5,329 SFT | yes |
| MultiPL-E sh (already on the sheet) | 540 | yes |
| Terminal-Bench family | 89 + 200 + 46 + 1,530 + 637 | yes |

This matters for us specifically: multi-line is the regime where verification gets hard, and it is
also the regime where the data barely exists. That gap is a defensible motivation for the project.

**3. Roughly half the HuggingFace "bash" ecosystem is re-uploads.** Six byte-identical copies of one
5,451-command file; NL2SH-ALFA is ~half recycled from the other three corpora already on the sheet;
one dataset advertises 1M rows and has 4,618 unique values. See `duplicates.md`. Both duplicate
flags already on the sheet were confirmed by hashing, and two more rows on it need correcting.

## Also relevant to the Lean pipeline, not just to evaluation

`jragsdale1/ShIO-bash-26.1` is not an NL→Bash dataset — it is 4.8 M rows of
`command → (stdout, exit_code, environment-state-delta)` recorded from a real Ubuntu 24.04 shell
across 86 Linux utilities. That is off-the-shelf execution ground truth for the step where a
generated Lean model is differentially validated against the actual GNU binary.
