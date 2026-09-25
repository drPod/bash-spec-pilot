# Astrogator resubmission work

**Latest research:** start with [the phase2 research brief](phase2/RESEARCH-BRIEF.md), [the main figure](phase2/evaluation/figures-paper/paper-contribution.pdf), and [the evidence map](phase2/README.md). This phase connects generated FQL to the actual verifier across all 21 original tasks and adds stronger-model baselines, benchmark audits, and bounded repairs.

The rest of this README describes the **first-phase artifact and its reproduction**. Its historical results remain in [the original report](reports/RESULTS.md) and [task review page](reports/review.html); they are not the latest comparison.

This directory implements all three requested workstreams: benchmark expansion,
natural-language-to-FQL experiments, and comparisons with LLM-generated tests and
direct LLM judgments. It contains actual executions and model outputs, not just a plan.
The work is local and has not been sent to Aaron or published.

## What is here

- **70 task records:** the supplied 21 plus 49 authored additions in eight families.
  Every addition has two initial states, a reference, independent state checks, and
  a selected incorrect variant. All 49 references pass both states and a repeated run;
  all 49 selected incorrect variants are caught in at least one state.
- **Real Astrogator integration:** pinned upstream source, explicit compiler shims,
  parser/semantic/codegen diagnostics, and a verifier sweep across all 2,238 processed
  programs. The 72 missing processed outputs remain in the 2,310-attempt manifest.
- **Actual model experiments:** zero-shot, three-shot, and grammar-constrained FQL
  generation; direct judgments; generated Python tests; generated read-only JSON checks.
  Inputs, outputs, model identity, token usage and stage results are retained.
- **Comparisons:** six reference/mutant task pairs, plus eight supplied programs with
  independently executed local checks. A frozen extension covers all 422 processed
  programs on four original tasks. All 844 state executions, 422 judge predictions,
  and the configured heuristic sweep are complete.
  See [scoped disagreements](reports/DISAGREEMENTS.md) before interpreting labels.

Runtime validity, formal-language support, and intent fidelity are separate gates.
31 of the 49 new candidate queries pass upstream parsing, semantic analysis and
module-language code generation. The remaining 18 identify implementation gaps.
None of the new queries has independent human review; passing these stages does
not make an underspecified query a complete specification.

## Reproduce

Prerequisites: Python 3.12+, `uv`, Docker. Everything that changes accounts, packages,
services or system files runs inside bounded disposable containers, never on the host.
Commands below assume this directory as the working directory.

```sh
uv sync
uv run python scripts/audit.py
uv run python scripts/build_benchmarks.py
uv run python -m unittest discover -s tests -v
```

The source archives are included. `audit.py` checks archive path shapes and writes only
regular, whitelisted sample files to ignored `data/corpus/`. The normalized CSV fields
are separate from the byte-preserved input. No blanket string unescaping is performed.

The two lab images used locally are recorded in [environment.json](reports/environment.json).
To build on a fresh machine:

```sh
sh scripts/bootstrap.sh
```

The bootstrap creates a bounded `astrogator-lab-build` container, installs the listed
compiler/runtime dependencies, builds the pinned source, and commits a local image.
It does not delete or modify an existing build container. The base image digest and
direct opam package versions are pinned; resolved OS/opam packages are recorded in
`reports/dpkg-lock.txt` and `reports/opam-lock.txt`. Debian repositories are not a frozen
snapshot, so future rebuilds are not guaranteed byte-identical to the recorded image.

Run the expansion and actual verifier:

```sh
uv run python scripts/validate_expansion.py --output reports/expansion-execution-reproduced.jsonl
docker run --rm --network=none --memory=512m --cpus=1 --pids-limit=96 \
  -v "$PWD:/suite:ro" astrogator-lab:20260924-v2 \
  python3 /suite/scripts/upstream_eval.py queries > reports/fql-queries.jsonl
docker run --rm --network=none --memory=512m --cpus=1 --pids-limit=96 \
  -v "$PWD:/suite:ro" astrogator-lab:20260924-v2 \
  python3 /suite/scripts/upstream_eval.py corpus > reports/corpus-verifier.jsonl
docker run --rm --network=none --memory=512m --cpus=1 --pids-limit=96 \
  -v "$PWD:/suite:ro" astrogator-lab:20260924-v2 \
  python3 /suite/scripts/upstream_eval.py expansion > reports/expansion-verifier.jsonl
```

The validation runner caps concurrency at two; each container has its own memory,
CPU, process and time limits. For this shared VPS, host orchestration was additionally
run through `systemd-run --user --slice=agent-jobs.slice -p MemoryMax=256M -p CPUQuota=50%`.
Do not run multiple container sweeps concurrently on a memory-constrained host.

## Model experiments

`llm_pilot.py` calls a llama.cpp HTTP endpoint inside a configurable existing Docker
container. It uses `docker exec … curl`; it neither launches agents nor reads credentials.
The recorded model was `Qwen2.5-1.5B-Instruct-Q4_K_M.gguf`, served by build 10830.
The default container `brancher-llm` is specific to this workspace; use `--container`
for another llama.cpp server exposing port 8081 internally. These experiments do not
require or use OpenAI API keys. These first-phase runs use the small local model; frontier-model results are in [phase2](phase2/README.md).

```sh
# Default: six development tasks. Explicitly list a01 ... a21 for the full sweep.
uv run python scripts/llm_pilot.py fql --shots 0 --diverse-demos --run my-run
uv run python scripts/llm_pilot.py fql --shots 3 --diverse-demos --run my-run
uv run python scripts/llm_pilot.py fql --shots 3 --diverse-demos --constrained --run my-run
uv run python scripts/llm_pilot.py judge
uv run python scripts/llm_pilot.py tests
uv run python scripts/llm_pilot.py checks
uv run python scripts/llm_pilot.py checks --schema
uv run python scripts/evaluate_generated_tests.py
uv run python scripts/evaluate_generated_tests.py --schema-only
uv run python scripts/original_pilot.py llm
uv run python scripts/original_pilot.py execute
docker run --rm --network=none --memory=256m --cpus=1 --pids-limit=64 \
  -v "$PWD:/suite:ro" astrogator-lab:20260924-v2 \
  python3 /suite/scripts/upstream_eval.py translations > reports/fql-translations.jsonl
uv run python scripts/report.py
```

Existing model-response files are never overwritten. Use a new `--run` to obtain
fresh FQL/model samples. `original_pilot.py` preserves its fixed small selection and
skips existing response files. The generated-test execution script currently evaluates
the named `qwen-local-pilot` runs; alternate model deployments should use separate
artifact directories and adjust this explicit selection rather than pool results.

`report.py` merges the recorded initial expansion run with its explicit environment-fix
reruns by task/scenario/variant. It does not silently use unrelated reproduction files.
All failed initial runs are retained. A fresh full rerun can be assessed directly from
the summary emitted alongside its chosen output file.

## Review before a paper claim

The corrected generation grammar is `experiments/fql-subset-v2.gbnf`; pass it using
`llm_pilot.py --grammar experiments/fql-subset-v2.gbnf` with the other FQL options.
The earlier grammar excluded four supplied references. Recheck coverage with
`uv run --no-project --with lark==1.2.2 python scripts/check_grammar_coverage.py --help`.
The protocol records the canonicalization check and one-retry condition.

`retrieval_fql.py` runs a fixed original-only versus expanded-pool four-shot
retrieval ablation; both allow same-family examples and exclude the target ID.
`generated_query_verification.py` runs inside the lab container and evaluates the
repaired queries against the supplied corpus. `summarize_query_transfer.py`
produces its transition tables. [Translation review](reports/TRANSLATION-REVIEW.md)
explains the completed end-to-end result and its limits.

`scripts/corpus_ground_truth.py` resumes the frozen four-task execution run;
`scripts/corpus_judge.py` resumes its independent judge run. Check existing process
handles before resuming: do not run duplicate writers against the same artifact.
Both reject changes to frozen configurations. `scripts/paired_comparison.py`
refreshes the paired snapshot; it includes incomplete cases explicitly.

`corpus_tests.py generate` records task-level declarative tests; `controls` checks
their validity and runs known-good references, and `execute` runs candidates only
for eligible tasks. The current four generated check sets all fail this gate.
Their baseline therefore abstains rather than inferring labels from faulty tests.

`scripts/evaluate_effects.py` runs inside the lab image like `upstream_eval.py` and
emits readable semantic comparisons. Fresh image builds include `fql_json.exe`;
the recorded v2 image uses the locally compiled `.cache/bin/fql_json.exe` override.
The source and normalization controls are retained; the binary is not in the zip.

1. Review the new natural-language specifications and FQL for intended behavior,
   especially preservation, “only if,” and constraints on additional effects.
2. Decide which of the 18 current formal-language gaps to implement. The review page
   includes the exact upstream diagnostic for each candidate.
3. Obtain or reconstruct the original multi-OS setup/tests and independent labels.
   The public executor references VM snapshots and reference directories that are not
   present in the supplied files or this checkout.
4. Repeat the frozen experiments with stronger, pinned models and multiple samples,
   then evaluate the end-to-end effect of generated FQL on verification decisions.

The detailed [protocol](experiments/protocol.md), [source references](reports/sources.md)
and complete logs are part of the artifact. Treat this as an inspectable starting point
for those decisions, not as an already adjudicated paper benchmark.
