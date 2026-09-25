# Specification adequacy: controlled challenges and a concrete code-generation fix

This contribution found and patched a concrete FQL permission-code-generation defect. It also demonstrates why parsing, reference acceptance, and killing one mutation are insufficient evidence of query adequacy. It does **not** claim a new general mutation-testing method, universal verifier unsoundness, or independently reviewed benchmark truth.

## Concrete finding and patch

For a22, the intent is a private directory with exact mode 0700. The original FQL query specifies owner read/write/directory-list permissions. Its code generator emits `u=rwX`, omitting empty group/other classes. The Ansible module model stores the provided mode as an opaque string. Consequently:

| Program mode | Actual a22 behavior in both fixture states | Original verifier | Patched verifier |
|---|---|---|---|
| `0700` | passes | rejects | rejects |
| `u=rwx,g=,o=` | passes | rejects | rejects |
| `u=rwX` | fails | accepts with residuals | rejects |
| `u=rwX,g=,o=` | passes | rejects | accepts with residuals |

For a67, setting an existing executable to exact 0700, `u=rwx` passes the initial 0600 state but fails the initial 0777 state because it preserves group/other bits. The original verifier accepts it. The patch rejects it and accepts `u=rwx,g=,o=`, which passes both runtime states. Numeric 0700 still rejects.

The minimal patch changes `lib/fql/codegen.ml` to emit all three classes when permissions are explicitly specified, including `g=` and `o=` when empty. If *no* permission fields are specified it still emits no mode update. Eight actual OCaml code-generation regression tests cover those distinctions, conditional `X`, explicit empty permissions, and special bits. The patch includes these tests in upstream's test directory.

This is a deliberately narrow correction to the documented code-generation convention that specifying permissions determines the whole permission set. It does **not** implement canonical permission semantics. Numeric modes, equivalent symbolic spellings, and state-dependent symbolic operations still need a principled model; replacing every symbolic string with a number without considering initial state would be wrong.

`permission-classes.patch` applies cleanly to pinned upstream commit `7c62afa51986d87033af5112cdccd3b104b1c120`. It was built in the pinned lab image and all 8 OCaml regressions passed. A paired rerun of 158 broader challenge/query combinations had no categorical outcome changes. The 7-case targeted panel exhibits the 4 intended changes above. This finite regression evidence is not a proof of global compatibility. Full verifier stdout, including initial-state assumptions and residual effects, is preserved.

Independent review and 6 additional runtime checks are in `../benchmark_audit/PERMISSION-CROSSCHECK.md`.

## Adequacy screen

The frozen protocol uses 49 authored candidate tasks and their pre-existing reference/mutant pair. These tasks, queries, and mutation results were already seen before this study; this is an audit, not an unbiased held-out estimate. Gate results:

| Stage/outcome | Tasks |
|---|---:|
| Query cannot complete semantic processing/code generation |18|
| Reference implementation cannot be lowered |2|
| Reference implementation is rejected |8|
| Reference and known fault are both accepted |7|
| Reference accepted and discovery fault rejected |14|

The 8 rejected references are a22,a23,a24,a26,a47,a53,a63,a67. The 2 unavailable references are a31,a69. These categories must stay separate: unsupported syntax is not a detected error, and a rejection of a known-good local reference does not establish query adequacy.

Ten deliberately weakened queries provide positive controls for omitted obligations. Nine pass the reference gate; eight of those also accept the discovery mutant. The remaining one, a27's weakened query `create directory at /work/dest`, **passes the entire single-mutation screen**: it accepts the reference and rejects the old mutant, which forgot the destination prerequisite. But it accepts both fresh challenges that create the destination and omit the copy. Both challenges fail independent runtime checks in both states. The unweakened query rejects those same challenges.

This is a concrete counterexample to treating one killed mutant as adequate query validation. The challenge set must cover separate requirements, here directory creation *and* file copying. No query was repaired using these outcomes.

## Challenge integrity

Twenty parameter/sequence variants were frozen before their runtime outcomes. Byte audit found five exact copies of old mutants and one exact copy of a reference. These 6 are replication controls, **not held-out examples**. Of 14 distinct implementations,13 fail the existing local checks and 1 passes. All 40 execution cases were retained. The passing variant is not counted as a killed fault simply because the generator intended mutation.

“Held out” here means the distinct challenge implementations were not used by the discovery screen. They are authored by the same investigator, may share fault classes, and do not provide an independently sampled generalization estimate. Runtime checks are inherited narrow author-written checks, not universal ground truth; the separate benchmark audit exposes omitted checks. The permission panel was designed *after* observing the incompatibility and is explicitly a diagnostic regression panel.

## Files and reproduction

- `frozen-design.json`, `cases/`, `build.py`: frozen candidate/omission-query study, including source hashes.
- `verifier.jsonl`, `execution.jsonl`, `summary.json`:158 real verifier calls and 40 two-state execution cases.
- `mode-design.json`, `mode-cases/`, `mode-verifier.jsonl`, `mode-execution.jsonl`:7 targeted mode implementations and 14 runtime cases.
- `permission-classes.patch`, `patched-source/`, `patch-provenance.json`: reviewable upstream change and original/patched source hashes.
- `permission_regression.ml`, `patch-regression.txt`:8 actual OCaml regressions.
- `patched-verifier.jsonl`, `patch-summary.json`:165 calls after the patch, including the targeted panel.
- `build_patch.sh`: rebuilds the patch in a disposable bounded container; `.cache/bin/` contains generated binaries and can be omitted from distribution.

Run `build_patch.sh` from a resource-limited `agent-jobs.slice` job. The script supplies Docker CPU/memory/network limits. `run_execution.py` executes only inside disposable containers; never execute challenge playbooks directly on the host. `summarize.py` validates case counts, source hashes, duplicate controls, and runtime candidate hashes before rebuilding summaries. `verify_patch.py` is an in-container driver with `/suite` mounted to the artifact root.

Initial build attempt failed because the older image lacked the optional `fql_json` target. The corrected build uses only existing verifier/probe targets and the new regression target. No verifier algorithm, module model, original source checkout, earlier reports, or corpus files were modified.
