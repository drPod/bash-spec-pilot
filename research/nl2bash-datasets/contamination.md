# Which Bash benchmarks are actually held out?

A benchmark is held-out data only if its tasks are absent from the corpora people train on. For Bash
both sides are public, so this is directly checkable.

**Method.** MD5 over whitespace-normalized command strings. Reference side = the union of the seven
corpora most HuggingFace Bash datasets descend from or reproduce (NL2Bash, NL2CMD, NL2CMD-Fu /
LinuxCommands, NL2SH-ALFA, tldr-pages, nl2bash-custom, cli-commands-explained) = **69,597 unique
commands**. A benchmark task counts as contaminated if its gold command appears, after whitespace
normalization, in that union.

(This figure was first reported as 78,441. That was the pre-correction union, which counted 12,957
`nl_command` *English sentences* from `nl2bash-custom` as if they were commands and omitted its
12,659 real ones. Re-running `data/control.py` and `data/remeasure.py` against the corrected union
leaves every percentage below unchanged: the positive controls still return 100.0% and 63.8%, the
baseline floor is still 10.4%, and the two execution-environment benchmarks move by one hit each,
5/5,597 and 30/13,855, still 0.1% and 0.2%.) Every measurement below compares *commands against commands*; see "How this was
validated" for why that qualifier is load-bearing.

## The result

| Benchmark | Unique gold commands | In the reference union | |
|---|---|---|---|
| `westenfelder/InterCode-Corrections` | 192 | **100.0%** | corpus-sampled |
| `epinnock/intercode-nl2bash-curated` | 196 | **63.8%** | corpus-sampled |
| *(ecosystem baseline — see below)* | | *10.4 – 100%* | |
| `ia03/terminal-bench` (112 tasks, oracle solutions) | 13,855 | **0.2%** | execution-environment |
| `tiararodney/posix-sdc` (2,975 scenarios) | 5,597 | **0.1%** | execution-environment |

Contamination tracks **how the benchmark was constructed**, and the gap is about two orders of
magnitude wide.

Benchmarks assembled by sampling an existing NL→command corpus are contaminated *by construction*.
The InterCode line was drawn from NL2Bash, so every task in it is inside the corpus most Bash models
are tuned on. This is not a fixable defect — filtering cannot repair it, only re-authoring tasks
would.

Benchmarks authored against an execution environment come out effectively clean, and the mechanism
is worth naming: their commands are bound to concrete environment state (`cp
protected.tar.gz.enc /app/`, `echo 'exit 0' >> /work/tmp.sh`), so they cannot coincide with a corpus
of generic, environment-free one-liners. The cleanliness is a *consequence* of the task format, not
of curation hygiene — which is why it is reliable.

**Consequence for us:** a verification success rate reported on the InterCode/NL2Bash line measures
memorization as much as capability, for any model that has seen public Bash instruction data — which
is essentially all of them.

## How this was validated

A near-zero overlap is exactly what a broken measurement produces, so the number is only worth
anything with controls. An earlier draft of this file reported these same 0% figures and **was
wrong**: it had compared the benchmarks' English *task-description* columns against a set of
*command* hashes, and prose never matches a command hash. Those rows were withdrawn and re-measured
from the actual gold commands — pulling oracle `solution.sh` / `solution.yaml` out of the 112
Terminal-Bench task archives, and exploding `posix-sdc`'s list-valued `reference_solution` into
individual commands. Two controls then establish that the current numbers are real:

**Positive control** — known-contaminated benchmarks pushed through the identical hash function and
the identical reference union still return 100.0% and 63.8%. The union matches what it should match.

**Baseline control** — every generic NL→command corpus in the ecosystem, measured the same way,
lands between **10.4%** and **100%** overlap with the union; 10.4% is the floor, and it belongs to
the one dataset in the six-way `linux-commands` duplicate cluster. So "a Bash command dataset that
shares nothing with the reference corpora" is not a thing that otherwise occurs. 0.1–0.2% is far
outside that distribution rather than a suspicious-looking zero.

## Benchmarks that cannot be checked at all

Two benchmarks ship **no gold command in any form**, so they are neither clean nor contaminated —
they are unmeasurable from the outside:

| Benchmark | What it ships instead |
|---|---|
| `Eccentricity/bashbench2` | `dockerfile`, `tests`, `setup_script_content` — no reference solution |
| `IntelligenceLab/Long-Horizon-Terminal-Bench` | `instruction` + `docker_image`; verifiers deliberately hidden |
| `AISafety-Student/labeled-bashBench` | commands only inside recorded agent `trajectory` steps, not as task gold |

For LHTB this is intentional (hidden verifiers are the anti-gaming design), and it happens to make
contamination auditing impossible too. Worth stating plainly rather than scoring them as 0%.

## The second failure mode: self-contamination

BashBench 2026 (BashCoder-R1, arXiv 2606.27733) leaks against its *own* released training set:
**709 of its 773 single-line tasks (91.7%)** appear (after whitespace normalization) in the SFT file shipped in the
same release, against an explicit claim of being "completely isolated from all training data." Its
179 multi-line tasks are clean. Full measurement in `bashbench-2026-audit.md`, reproducible via
`data/bashbench_audit.py`.

That is a different failure mode from the InterCode one and needs a different check:

1. **Inherited** — benchmark ⊆ public corpus. Detect against public training corpora.
   (InterCode line: confirmed.)
2. **Self-** — benchmark overlaps the authors' own training data. Only detectable when the training
   set is released alongside, which is exactly the case where nobody thinks to look.
   (BashBench 2026: confirmed.)

## Caveats

- Exact-match contamination is a **lower bound**. Near-duplicates (a renamed flag, a different path)
  are not counted, so true contamination is at least as high as reported.
- The execution-environment figures count individual command lines extracted from multi-command
  solutions, so the unit is "command", not "task". A task counts as contaminated under the InterCode
  rows because there the task *is* one command.
- `saurabh5/rlvr-code-data-bash` is excluded: stored hashes for it predate a column correction. Its
  corrected measurement (0% overlap on 66,624 solutions) is in `rows-to-add.csv`.

## Reproducing

`data/remeasure.py` (gold-command extraction + measurement) and `data/control.py` (both controls),
run against `data/res1.json` / `data/res2.json`. The committed copies of those two have their hash
arrays stripped for size — re-run `data/analyze.py` to regenerate them first.

**Always print `cmd_col` and sample values before trusting an overlap figure.** Automatic
column-detection-by-name is what produced the withdrawn claim above, and it fails silently.
