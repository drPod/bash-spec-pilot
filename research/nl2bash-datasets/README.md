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
| `benchmark-validity.md` | **That the same benchmark's tests never execute the model's code** — so neither half works as an eval. Supersedes the causal claim in `leakage-effect.md`. |
| `leakage-effect.md` | The leaked-vs-clean score split, and the correction to what it means. |
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

**0. Half the Bash benchmarks in common use are not held-out data, and which half is predictable
from how they were built.** Measured against the union of the seven corpora most HuggingFace Bash
datasets descend from (78,441 unique commands):

| | gold commands | in the union |
|---|---|---|
| `westenfelder/InterCode-Corrections` | 192 | **100.0%** |
| `epinnock/intercode-nl2bash-curated` | 196 | **63.8%** |
| *every generic NL→command corpus, as a baseline* | | *10.4 – 100%* |
| `ia03/terminal-bench` (oracle solutions) | 13,855 | **0.2%** |
| `tiararodney/posix-sdc` | 5,597 | **0.1%** |

Benchmarks assembled by sampling an existing corpus are contaminated *by construction* — the
InterCode line was drawn from NL2Bash, so filtering cannot repair it. Benchmarks authored against an
execution environment come out ~500× cleaner, because their commands are bound to concrete
environment state and cannot coincide with generic one-liners. A verification success rate reported
on the InterCode/NL2Bash line measures memorization as much as capability.

The controls matter here: an earlier draft got these same 0% figures *for the wrong reason* (it had
compared English task descriptions against command hashes) and had to be withdrawn and re-measured
from actual oracle solutions. `contamination.md` documents that, the positive/baseline controls that
now back the numbers, the two benchmarks that ship no gold command and so cannot be audited at all,
and the second failure mode — a benchmark leaking against its *own* released training data.

**1. BashBench (BashCoder-R1, arXiv 2606.27733, 2026) looked like the best fit, and its tests turn
out not to test anything.** 952 tasks split **773 single-line / 179 multi-line**, each with an
executable test suite — the only dataset publishing an explicit single/multi split *and* per-task
tests. Release: <https://zenodo.org/records/18408692> (1.1 GB, CC-BY-4.0).

⛔ **Do not use it as an evaluation — either half.** The harness writes the model's script to
`solution.sh` and then runs the task's `test.sh`, and **none of the 1,081 released test scripts
reads `solution.sh`**. Each test re-runs the *reference* commands inline, so `func_pass` is
independent of the generated code. Three checks against the authors' own released results confirm
it (`benchmark-validity.md`, `data/candidate_independence.py`):

| | |
|---|---|
| tasks where 7 models spanning 3B–32B get an identical verdict | **178/179 = 99.4%** |
| FuncRate once code is extractable — *every* model, incl. deepseek-coder-6.7b | **93.3 – 94.1%** |
| duplicated prompts where the model wrote different code, same verdict anyway | **67/68 = 98.5%** |
| `corr(SyntaxPass, FuncRate)` across all 19 scored models | **+0.9966** |

The published FuncRate spread (6.7% → 93.9%) is the rate at which each model emitted a parseable
fenced code block; a failed extraction short-circuits the harness to `func_pass=False`. The paper's
actual headline margin (RobustPass 79.3% vs 33.0%) reduces to `shellcheck_pass` — a linter.

It remains useful as **data**: 952 NL prompts with reference solutions and a real single/multi
split. Just not as an eval, and its reference solutions are themselves LLM-generated.

The methodological lesson generalizes past this benchmark and is the one to carry into our own
work: an LLM asked to write a test for a task will happily write one that tests the *reference*
implementation. It runs, it exits 0, and all 1,081 here are stamped `validated: true`. Nothing in
that pipeline checks that a test's verdict depends on the code under test — which is one mutation
away (run the suite against a deliberately wrong program, require failure). Direct analogue of the
Lean pipeline's anti-cheat gates: a spec no program can violate is worth what a test no program can
fail is worth.

**On the contamination, which is a separate matter and still stands:**

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
support "completely isolated." The **179 multi-line tasks are genuinely clean**, confirmed against
paraphrase leakage too: their mean nearest-training-neighbour similarity is 0.135, indistinguishable
from the 0.118 that same-generator training items score against *each other*, and far from the 1.000
the known-leaked single-line control returns through the same retriever (`data/neardup.py`).

Note the ordering of the two findings: contamination is why the single-line half is unusable as
held-out data, and the harness defect above is why *neither* half is usable as an eval. An earlier
version of this README claimed the leakage inflated the reported score by measuring 99.4% on leaked
vs 21.9% on clean tasks. **That claim is withdrawn** — since `func_pass` ignores the generated code,
that gap measures test-script executability, not memorization. `leakage-effect.md` carries the
correction and what survives it (the recitation signature does; the causal claim does not).

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
| BashBench 2026 | 179 eval + 5,329 SFT | ships tests, but they **don't test the candidate** — see above |
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
