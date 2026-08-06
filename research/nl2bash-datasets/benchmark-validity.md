# BashBench 2026's functional metrics do not test the generated code

This is the load-bearing finding about the benchmark we were about to recommend, and it
supersedes the causal reading in `leakage-effect.md` (corrected there).

**The evaluation harness never runs the model's script.** It writes the candidate to
`solution.sh` in a sandbox, then runs the task's `test.sh` in that sandbox and takes
`func_pass = (test.sh exit code == 0)`. Not one of the **1,081 released test scripts reads
`solution.sh`** — or obtains the candidate by any other route. Each test script instead
re-executes the *reference* commands inline and checks their output.

So `FuncRate` is a measurement of the benchmark's own test scripts. The model is a spectator.

## The harness, from the release

`test/test_our_script.py` (multi-line) and `test/test_our_command.py` (single-line) are
byte-for-byte equivalent on this path:

```python
script_path = test_sandbox / 'solution.sh'      # the model's code goes here
script_path.write_text(script)
test_path = test_sandbox / 'test.sh'
test_path.write_text(test_script)
result = subprocess.run(['bash', str(test_path)], cwd=str(test_sandbox), ...)
return result.returncode == 0                   # <- this is func_pass
```

There is no substitution step, no argument passed, no template placeholder. And in the test
scripts themselves:

| how a test script could reach the candidate | multi-line (154) | single-line (927) |
|---|---|---|
| references `solution.sh` | **0** | **0** |
| globs `*.sh` | 0 | 0 |
| reads `$1` / `$@` (never supplied by the harness anyway) | 36 | 44 |
| `cd`s into a *fresh* `mktemp -d`, i.e. away from the sandbox entirely | 40 | 715 |

A typical single-line test, in full — note that the reference command is hardcoded:

```bash
TEST_DIR=$(mktemp -d); trap "rm -rf $TEST_DIR" EXIT; cd $TEST_DIR
touch visible.txt; touch .hidden; mkdir normal_dir; mkdir .hidden_dir
OUTPUT=$(ls -a)                       # <- the REFERENCE command, not the model's
if echo "$OUTPUT" | grep -q "visible.txt" && ... ; then exit 0; else exit 1; fi
```

Whatever the model wrote, this exits 0.

## Three independent confirmations from the released results

Static reading could be wrong, so each of these is a falsifiable prediction of
candidate-independence, checked against data the authors published. No re-execution.

**1. Different models, same verdict.** Across 7 models spanning 3B–32B and wildly different
ability, restricted to tasks where each model's code was successfully extracted:

| | tasks |
|---|---|
| identical `func_pass` verdict for **every** model | **178 / 179 = 99.4%** |
| any disagreement | 1 / 179 = 0.6% |

A functional test cannot behave this way. A 3B model and a 32B model do not write the same
script, so they must not receive the same verdict on 99.4% of tasks.

**2. Conditional on extraction, every model scores the same.** The published FuncRate spread
(6.7% → 93.9%) looks like a capability ranking. It is not — it is the rate at which the model
emitted a parseable fenced code block, because a failed extraction short-circuits the harness to
`func_pass=False`:

| model | code extracted | published FuncRate | **FuncRate given extraction** |
|---|---|---|---|
| BashCoder-R1 (theirs) | 100.0% | 93.9% | **93.9%** |
| Qwen2.5-Coder-14B-Instruct | 100.0% | 93.3% | **93.3%** |
| Qwen2.5-Coder-32B-Instruct | 99.4% | 92.7% | **93.3%** |
| Qwen2.5-32B-Instruct | 95.0% | 89.4% | **94.1%** |
| deepseek-coder-6.7b-instruct | 89.4% | 83.8% | **93.8%** |
| CodeLlama-13b-Instruct-hf | 8.9% | 8.9% | 100.0% *(n=16)* |
| Qwen3-8B | 7.8% | 6.7% | 85.7% *(n=14)* |

Every model with usable n lands in **93.3–94.1%**. The ~6% that fails is the same set of tasks
for everyone, and the recorded reasons are environment failures, not wrong logic —
`jq is required but not installed`, `python2: command not found`, `Python is not installed or
not in PATH`. Those are the benchmark's own tests failing in the benchmark's own sandbox.

Consistent with this, across all **19** scored models `corr(SyntaxPass, FuncRate) = +0.9966`,
mean absolute difference 3.2 points. The two metrics are the same measurement.

**3. Same model, different code, same verdict.** Within the single-line results, 131 prompts
appear more than once. On the 68 where BashCoder-R1 actually wrote *different* code for the
same prompt:

| | |
|---|---|
| same `func_pass` verdict anyway | **67 / 68 = 98.5%** |
| verdict differed | 1 / 68 = 1.5% |

## What the reported metrics therefore measure

| metric | definition in the harness | what it actually measures |
|---|---|---|
| `SyntaxPass` | `bash -n` on the extracted block | output-format compliance, then syntax |
| `FuncRate` | test.sh exits 0 | **nothing about the candidate** — format compliance × whether the benchmark's own test runs |
| `RobustPass` | `syntax_pass and shellcheck_pass` | ShellCheck-clean style |
| `FullRate` | `syntax_pass and shellcheck_pass and func_pass` | ShellCheck-clean style, ×0.94 |

The paper's headline margin is **RobustPass 79.3% vs 32.96% for the best baseline** and
**FullRate 73.2% vs 31.3%**. Both reduce to `shellcheck_pass` — the model was trained to write
scripts a linter likes. That is a real and reproducible difference; it is just not functional
correctness, and the benchmark contains no metric that measures functional correctness.

## Consequences

- **BashBench 2026 cannot be used as an evaluation** — neither half. The earlier
  recommendation here ("use the 179 multi-line tasks, they're clean") is withdrawn. They are
  clean of leakage and still do not test anything.
- The **179 multi-line tasks and 773 single-line tasks are still valuable as *data*** — NL
  prompt + reference solution, with a genuine single/multi split. It is the *tests* that are
  void, so treat it as an unevaluated corpus, and note the reference solutions were themselves
  LLM-generated.
- **It resolves the anomaly** that motivated this. The multi-line half scored 93.9% while
  looking genuinely held out. It is held out — a near-duplicate scan (`data/neardup.py`) puts
  its nearest-training-neighbour similarity at 0.135 mean, statistically indistinguishable from
  the 0.118 that same-generator *sibling* training items show each other, against 1.000 for the
  known-leaked single-line control. The 93.9% simply was never a capability measurement.
- **It generalizes past this benchmark.** LLM-generated test cases are now a standard way to
  scale a code benchmark. Here the generator was asked to write a test for a task, and produced
  a self-contained script that tests the reference implementation — plausible-looking, it runs,
  it exits 0, and `validated: true` is stamped on all 1,081. Nothing in the pipeline checks the
  one property that matters: **that the test's verdict depends on the code under test.** That
  check is one mutation — run the suite against a deliberately wrong program and require it to
  fail — and it is cheap. For the Lean pipeline this is the direct analogue of our anti-cheat
  gates: a spec no program can violate is worth exactly as much as a test no program can fail.

## Reproducing

- `data/pull_ml.py` — range-requests the harness source and the baseline scores out of the
  1.1 GB archive (never download it whole).
- `data/candidate_independence.py` — confirmations 1 and 2, plus the failure-reason breakdown.
- `data/neardup.py`, `data/neardup_effect.py` — the near-duplicate scan and its controls.
- `data/baseline-summaries/` — the 19 per-model summary reports, as shipped.

The placeholder scan (confirmation 3 and the routes table) is a few lines over
`test_cases__{script,command}_test_cases_validated.json`; both files come from
`data/bashbench_audit.py`'s extraction step.
