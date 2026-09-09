# Phase5 research organization: landing index

Built by the `research-inventory-5` Claude CLI worker (job dir
`~/agent-jobs/astra-research/phase5/claude-resume/research-inventory-5/`), on explicit user
request to record/organize all phase5 (and referenced predecessor) research into a
machine-readable catalog for import into OpenScience/Atlas by a sibling worker
(`openscience-atlas-import-5`). This worker made **no repo edits outside this
`organization/` directory**, ran **no compiler/model calls**, and reran **no experiments**.
Everything below is read from existing REPORT.md/RESULTS.md/STATUS.md/exit.json/REQUIREMENTS.md
files already on disk.

## Files here

- **`catalog.json`** — the primary machine-readable catalog. 27 `records` (checked proofs,
  checked-but-bounded results, negative/calibration results, one predecessor-phase summary,
  one interrupted assignment with draft-only source and zero build/proof evidence) plus 17
  `independent_audits` (Pi/Grok reviews and their outcomes). Every record has a stable `id`,
  `claim_status`, `dependencies`, cited receipts/hashes where available, and a `distinctions`
  field that states plainly what the result does NOT prove (e.g. witness vs universal, finite
  observation vs theorem, safety vs functional-return). A top-level `hash_disclaimer` and
  `approximate_timestamp_disclaimer` mark which hashes/times are independently verified by this
  worker vs quoted/estimated from an authoring worker's own prose.
- **`artifacts.jsonl`** — compact raw receipt inventory: one line per worker job-dir (its
  `exit_code`/`started_unix` from `process.json`/`exit.json`), one line per named compiler/tool
  receipt cited anywhere in `catalog.json`, one line per independent-audit pointer, file-level
  pointers into `research/libc-specs/phase2/3/4` (predecessor evidence, see `PH5-PRIOR-000`),
  and one line per INDIVIDUAL trial of the 90-cell evaluation matrix (parsed directly from
  `evaluation-artifact-4/matrix.log`, not summarized). 222 lines total.
- **`REQUIREMENTS-CROSSWALK.md`** — maps each row of `phase5/REQUIREMENTS.md` (owned by root,
  not edited here) to the `catalog.json` IDs that currently constitute its evidence, and flags
  two rows (byte-bearing I/O; nonvacuity/progress) where catalog evidence is now more recent
  and stronger than REQUIREMENTS.md's last-written "remains open" text.
- **`COVERAGE-GAPS.md`** — the honest gaps: what has no artifact at all, what is
  interrupted/incomplete, what an independent audit (organization-audit-5, running in
  parallel to this worker) should specifically re-check.
- **`READY.json`** + **`schema.json`** — the checkpoint contract for `openscience-atlas-import-5`
  (published early, per the assignment's request for an incremental checkpoint).

## How to read `claim_status`

- `checked` — a direct compiler/proof-assistant receipt with `exit_code: 0`, no `Admitted`,
  no project-local axiom (per that record's own `Print Assumptions`/`#print axioms` audit).
- `checked-*` (e.g. `checked-existential`, `checked-universal-within-stated-environment-model`,
  `checked-partial`, `checked-with-documented-private-patch`) — checked, but the suffix names
  the specific limitation; read the record's `distinctions` field before citing it.
- `checked-negative-result` / `not-established` — the work was done and is itself evidence,
  but the target theorem/proof was explicitly not achieved (e.g. `PH5-UTF8-001`'s C-conformance
  body proof, `PH5-CASE-001`'s two body proofs).
- `not-established-interrupted` — used for exactly one record (`PH5-CALC-004`): the worker was
  interrupted by an account rate limit and produced no artifact at all. This is not a negative
  proof result; it is an absence of a result.

## What this worker did and did not verify

Did: read REPORT.md/RESULTS.md/STATUS.md/NEXT.md/PROVENANCE.md across
`research/libc-specs/phase4/`, `phase5/{relay,shell-bridge,shell-expansion,calculus-bytes,
utility-reuse,integration,calibration,case-studies,evaluation,evaluation-expanded,artifact}`,
all `exit.json`/`process.json` under `~/agent-jobs/astra-research/phase5/claude-resume/*` and
`pi-reviews/*`, `phase5/REQUIREMENTS.md`, and `claude-resume/ORCHESTRATION.md`'s full
continuation history; independently re-derived the 90-cell evaluation matrix's final
accept/reject tally directly from `evaluation-artifact-4/matrix.log` (22 accepted / 59 build
failed / 6 no-code-block / 3 directory-collision) since no REPORT.md existed for that worker.

Did not: re-run any `coqc`/`clightgen`/`lake build`, re-issue any model call, inspect the
`phase5-vst` container directly, or verify that on-disk file hashes still match the hashes
quoted in each worker's own REPORT.md (those quoted hashes are taken on trust from the
authoring worker's own receipt; an independent hash re-check is exactly the kind of task
`organization-audit-5` is scoped to do, and this catalog explicitly defers to it for that).

## Repair pass: organization-repair-6 (2026-09-08)

A verified race between `openscience-atlas-import-5` (import) and `research-inventory-5` (this
catalog's own author) meant the OpenScience import read `catalog.json`/`artifacts.jsonl` 69s
*before* `research-inventory-5` finished its final revision, and so imported a stale snapshot
missing `PH5-PRIOR-000` and 121 of 222 `artifacts.jsonl` rows (see
`organization-import-verification-5/REPORT.md` for the full timestamp-proven root cause).
`organization-repair-6` (this pass) is now the SINGLE writer of this directory and of the
OpenScience graph. What changed:

- **`catalog.json` corrections** (each inline, tagged `organization-repair-6, 2026-09-08`):
  added `relay.v`'s full sha256 to `PH5-RELAY-001.independently_verified_hashes` (it was quoted
  but never actually re-verified); fixed a transcription error where the coreutils pinned commit
  was written as 41 hex chars (`9530a144420fc...`, a duplicated `4`) instead of the correct
  40-char `9530a14420fc...` (independently confirmed via `git cat-file -e`/`git log` against a
  local coreutils clone, and cross-checked against 6 other in-repo files that already had it
  right); independently recomputed and added the pre-/post-patch full hashes of
  `state.ml` for `PH5-CALC-001`'s private patch (previously only quoted as abbreviated
  prefixes); independently confirmed the `state_based` pinned commit via `git rev-parse HEAD`
  against the actual clone; and — the most substantive correction — clarified `PH5-UTIL-002`'s
  "whole-program-level linking" wording, which could be misread as "links the whole CLI": the
  actual `AllVSU` link contains no `main`/entry point and is not a runnable executable or a claim
  about GNU cat's CLI, only a real CompCert-level link of the four wrapper TUs' compiled ASTs.
- **`artifacts.jsonl` full-coverage extension**: appended 486 new `raw_compiler_receipt` rows
  (every distinct receipt under `phase5/runs/`, not just the 59 individually cited by a catalog
  record — full sha256 of both the `.json` and `.log` for each, with the embedded
  `log_sha256` field cross-checked against the actual on-disk log for all 486, zero mismatches)
  and 1424 new `job_dir_file` rows (every relevant file under `claude-resume/*/` and
  `pi-reviews/*/`, excluding the huge low-value `events.jsonl`/`launcher.log`/`stderr.log`/`*.pid`,
  the nested pinned `state_based` git clone, and its duplicated `build/vendor`+`build/bash-verifier`
  private-copy trees — those are noted as excluded subtrees, not silently dropped or copied).
  `artifacts.jsonl` is now 2132 lines (was 222). See `raw-inventory-summary.json` in this job's
  job dir for exact counts. No binary caches, credentials, or the unrelated nested repo were
  copied into this directory or into git — only paths/hashes/status were recorded.
- **Import**: re-ran the (idempotent, content-addressed) import against the same local
  OpenScience project so the graph now reflects this corrected, complete snapshot — see this
  job's own `REPORT.md` for node counts and verification steps.


## Overlay: organization-current-evidence-8 (2026-09-08T06:17:37Z)

Append-only OpenScience import of finalized evaluation-accounting-7, case-differential-7, case-replay-7, case-replay-fix-8 (two distinct 6-receipt replays = 12), RESULTS.json current+historical hashes, and attempts.jsonl 96-row current version. Frozen original 90 trials not rewritten. Historical replays not relabeled current code. Atlas not written. See CURRENT-EVIDENCE.json and IMPORT-GET-VERIFICATION.md.
