# Audit: BashBench (BashCoder-R1, arXiv 2606.27733) — measured against its released artifact

BashBench is the most attractive evaluation set in this survey on paper: 952 tasks with an explicit
773 single-line / 179 multi-line split, each with a manually reviewed executable test. Before
recommending it we measured the released artifact directly. **The single-line half — 81% of the
benchmark — does not support the paper's isolation claim, and should not be used as a primary
evaluation set without repair. The multi-line half is clean.**

Everything below is measured from Zenodo record 18408692 (`BashCoder-R1.zip`, 1,108,526,600 bytes,
md5 `e2cef192c89ee8f14fe4c59152f213bf`, CC-BY-4.0). Reproduce with `data/bashbench_audit.py`.

## Reconstruction check (establishes the method is right)

The archive ships `test_cases/command_test_cases_validated.json` with **927** records, not 773.
Filtering to `validated == true` **and** a non-empty `test_case.test_script` yields **exactly 773** —
matching the paper's single-line count, and matching how the shipped harness computes `total`. The
multi-line eval file has exactly **179** records. So the reconstruction lines up with the paper
before we measure anything else.

## Finding 1 — 91.7% of the single-line benchmark is in the released training data

The paper states (§4.1): *"We built a novel evaluation benchmark, BashBench, comprising 952 tasks
that are **completely isolated from all training data**."*

Comparing benchmark task inputs against the released training files, whitespace-normalized and
compared byte-for-byte:

| Comparison | Overlap |
|---|---|
| 773 single-line benchmark tasks vs `data/sft/sft_command.json` (7,005) | **709 / 773 = 91.7%** |
| 773 single-line benchmark tasks vs `data/grpo/grpo_command.json` (812) | **204 / 773 = 26.4%** |
| 179 multi-line benchmark tasks vs `sft_script.json` + `grpo_script.json` | **0 / 179 = 0%** |

These are substantive task prompts, not boilerplate — e.g. *"Search for files modified exactly 30
days ago"*, *"Extract database.sql.zip with no password to directory projects_backup"*.

One qualification, stated because it matters: the leakage is at the **task** level, not the
record level. **Zero** benchmark tasks share an identical (input, output) pair with the SFT set —
the reference solutions differ. So a model trained on this data has seen 92% of the single-line
benchmark *questions* during training, but not these exact *answers*. Under any reading, that is
not "completely isolated from all training data."

## Finding 2 — 21.6% of the single-line benchmark is duplicated tasks

The 773 single-line tasks contain only **606 unique** prompts. 167 records are repeats:

- *"Count the number of lines of code in all source files grouped by file extension"* — **16 times**
- *"Search for files modified exactly 30 days ago"* — 5 times
- *"Extract database.sql.zip with no password to directory projects_backup"* — 4 times

Duplicates carry different reference outputs and different test scripts, so they are not exact
record duplicates — but they silently reweight the metric, giving one task 16× the influence of a
singleton on the reported pass rate. The multi-line half is clean: 179/179 unique.

## Finding 3 — most multi-line tests are not re-runnable from the archive

The reported multi-line numbers cover 179 tasks, but `test_cases/script_test_cases_validated.json`
ships only **154** test scripts, of which only **40** correspond to actual eval tasks — and only
those 40 carry `is_safe_to_execute: true`. The harness's default input file,
`merged_testable_cases.json`, is **not in the archive**. Multi-line results are therefore
reproducible from the shipped *result* files, but only ~40/179 tasks can be re-executed from
scratch against a new model.

## Finding 4 — the harness runs untrusted output on the host

Tests are executed as plain bash via Python `subprocess` in a `mktemp -d` directory. There is no
per-task Docker and no container isolation, so grading a new model means running its generated
commands with your own privileges. We checked and the *shipped* tests are not hostile — 0 of 773
touch the network (the 7 curl/wget references are mocks), 0 use `rm -rf` outside a temp dir, 0 write
to `/etc`, and 715/773 use `mktemp -d` + `trap` cleanup. The risk is from the *model output* being
graded, not from the tests. Anyone using this needs to add their own sandbox.

Two harness details worth knowing before trusting a number it prints: test cases are paired to model
outputs by positional `zip()` with only a warning on length mismatch, and if `shellcheck` is not
installed the robustness check **returns pass**, silently inflating RobustPass and FullRate.

## What reproduces cleanly

The paper's arithmetic is honest. Recomputing the headline metrics from the released per-task result
files reproduces the published table to the decimal — single-line (N=773): SyntaxPass 100.00 /
RobustPass 95.99 / FuncRate 93.01 / FullRate 90.04; multi-line (N=179): 94.97 / 79.33 / 93.85 /
73.18. The problem is not fabricated numbers; it is what the single-line number *means* given that
92% of those tasks are in the training set.

Also cleared: CC-BY-4.0 is permissive for research use with attribution. The Zenodo record is
authored "Anonymous" with an empty description and no linked repository — cite the arXiv paper. No
GitHub repo for BashCoder-R1 exists, so the harness has no issue tracker and no upstream fixes.

## Recommendation

**Do not use either half as an evaluation.** This section previously recommended the 179 multi-line
tasks as the defensible core; that is withdrawn. `benchmark-validity.md` shows the released tests
never execute the candidate — no test script reads `solution.sh` — so a passing score is not
evidence about the generated code in either split, contamination aside.

What the audit below still establishes is about the tasks as **data**, and there the two halves
differ. The 179 multi-line tasks are unique and uncontaminated, so they are usable as held-out
*prompts* with reference solutions (themselves LLM-generated). The single-line half is not: if it is
used at all, dedupe it to its **606 unique** prompts and label it *in-training-distribution*. Any
re-execution of this artifact needs container isolation regardless, since the harness runs model
output as plain bash on the host.

The contamination and duplication are properties of the *released artifact*. If the authors hold
back a clean split, that would resolve Finding 1 — but there is no repository or contact channel
attached to the record to ask through.
