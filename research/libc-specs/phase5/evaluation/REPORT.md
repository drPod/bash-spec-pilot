# REPORT — bounded non-UTF8 proof-regeneration diagnostic (2026-09-07)

Measured conclusion first. Twelve first-pass, fresh-context attempts by `xai/grok-4.6` (Pi
0.84.2, no tools, 120 s wall each) on three frozen, already-checked Lean theorems: **7 of 12
accepted** by the checker for the frozen tasks. Every model call finished in 6–23 s; no timeouts; every
response contained a code block. The diagnostic is unpowered (two attempts per cell) and
says nothing about C, libc, OS, Bash parsing, Coq/VST or model superiority.

Model calls ran 08:34:21–08:36:54 UTC. Tasks were frozen at 08:31 UTC
(`tasks/manifest.json`). Receipts: `~/agent-jobs/astra-research/phase5/claude-resume/evaluation/`
(`attempts.jsonl`, `attempts/*/`, `checks/*.json`, build logs). Compiled: `results.json`.

## Results

| Task (theorem) | Condition | Accepted | Model time (s) | Failure category |
|---|---|---|---|---|
| shell_status (`ShellObservation.query_transfer`) | helper (`command_refines` present) | 2/2 | 6.9, 6.1 | — |
| shell_status | base (`command_refines` removed) | 2/2 | 23.0, 18.0 | — |
| byte_relay (`RelayComposition.fragment_refines`) | helper (`primitive_eq`, `primitive_refines` present) | 2/2 | 8.3, 7.4 | — |
| byte_relay | base (both removed) | 0/2 | 13.3, 13.8 | compiler error while re-proving `PrimitiveRefines` (`cases`/`subst` on the `graph` equation; `simp ... at hc` then `rw run_detailed_eq` pattern not found) |
| partial_error (`BufferRelay.run_write_failure_residual`) | helper (`run_conservation` present) | 0/2 | 11.0, 11.4 | `omega could not prove the goal` after `simp [run, runDetailed]` |
| partial_error | base (`run_conservation` removed) | 1/2 | 9.0, 8.2 | a1: same `omega` failure; a2 added an intermediate `remaining.length ≤ input.length` bound |

All seven accepted proofs: axioms ⊆ {propext, Classical.choice, Quot.sound}; `#check` output
byte-identical to the type recorded from the unchanged repository build; template and all
baseline sources byte-identical to the repository. Token usage per attempt is in
`results.json`: Pi reports 32,284 input, 5,632 cache-read and 8,118 output tokens,
46,034 total across the twelve calls. Reported input per call ranges from 1,344 to
5,429 tokens. The separately reported 6,111 reasoning tokens are not added again
to that total.

Post-run independent review found a diagnostic-label bug: the historical checker's
`errors` field also captured informational lines containing theorem names such as
`error_preserves_state`. Compiler exit status and acceptance gates were unaffected.
The current checker matches error diagnostics explicitly. Original receipts and
results remain intact; this reporting-only correction does not constitute new trials.

## What the accepted proofs did (reuse accounting)

- **`command_refines` reused unchanged.** Both `byte_relay/helper` proofs and both
  `shell_status/helper` proofs invoke `ShellObservation.command_refines` as a black box (with
  `Eq` and `primitive_refines` for the relay instantiation). This is the reuse condition the
  Pi readiness audit asked for; it was met by the model, not only by the original author.
- **Re-derivation when the helper is absent.** Both `shell_status/base` proofs re-prove the
  simulation inline (`have sim … induction h`) with all six `Exec` constructors, taking ~3×
  the model time of the helper cells. Both `byte_relay/base` proofs tried the same
  re-derivation of `PrimitiveRefines` and failed on Lean's dependent elimination of the
  `graph` equation — the exact step the reviewed `primitive_refines` lemma encapsulates.
- **The `partial_error` helper manipulation was ineffective.** None of the four submissions
  used `run_conservation`; all four went through `execute_contract`, which stays in both
  conditions because later definitions and downstream modules depend on it. The 0/2 vs 1/2
  split is therefore noise around a single hard step (a length inequality after unfolding),
  not a library effect. Record this as a design limitation of task 3.

## Checker controls (receipts `checks/control2-*.json`)

| Control | Expected | Observed |
|---|---|---|
| Original proof, helper cell (×3) | accept | accept 3/3 |
| Original proof, base cell (×3) | reject (uses removed helper) | reject 3/3, build failed |
| `by sorry` | reject | lexical guard |
| `by native_decide` | reject | lexical guard |
| `by simp` | reject | build failed |

A first control round (`checks/control-*.json`) exposed a harness bug: `lake env lean`
under the 3 GiB address-space limit needs `-s16384`, otherwise "failed to create thread"
made the axiom gate fail on correct proofs. Fixed before any model attempt.

## Deviations and interventions (complete list)

1. **Shared compiler lock.** The orchestrator's note (read 08:36 UTC) requires host Lean to
   take `~/.cache/bash-spec-pilot/phase3-compiler.lock`. Attempts 1–10 had already been
   checked without it (each check ≤ 2 s; no contention was observed, but that is not proof
   none occurred). The checker was patched at 08:36; attempts 11–12 and a re-check of all
   seven accepted submissions (`checks/recheck-*.json`, all accepted, zero lock wait) ran
   under the lock. The accepted set did not change.
2. **No submission was edited.** The harness only re-indents lines by two spaces. No feedback
   round, no second-pass, no human or agent repair. Failed cases are preserved verbatim.
3. **Roles.** Task selection, freeze, checker, prompt and this report: Claude evaluation
   worker. Proof attempts: grok-4.6 via Pi. Coordination correction: orchestrator. Human: none.

## Non-claims

No VST/CompCert body evidence (that is the relay worker's `Body.v`, reported separately), no
OS or file-descriptor semantics, no Coq–Lean connection, no Bash parser fidelity, no second
real utility, no UTF-8 content, no proof-success-rate estimate beyond these 12 cells, no
statement about other models. Memorisation of the private phase2/phase3 sources by the model
cannot be excluded by this protocol; the base-cell failures argue against verbatim recall
of `primitive_refines`, but that is an observation, not a control.

## Metadata corrections noted for later integration (not edited here)

- Calibration job (`claude-resume/calibration`): supervisor `process.json`/`exit.json` give
  08:06:59.68–08:25:58.36 UTC, exit 0. Its REPORT header "08:07–08:56" and the rows "Failed
  by deadline" should read: worker exited ~30 min before the 08:56:24 deadline; the VST body
  theorem and gettext caller transfer were **not attempted** (bounded `Abort` probes only),
  not disproved or timed out. The orchestrator reports having corrected the repo
  `calibration/RESULTS.md`/`results.json`; `RESULTS.md` line 5 now carries the actual times.
- Supplementary Pi tests (`pi-reviews/utf8-controls-1`, 08:22:09–08:23:50 UTC) have their own
  receipts and are not part of the frozen 1,190,417-line corpus.
- Integration worker REPORT/STATUS headers carry end times (09:00Z, 08:42Z) written before
  those times; use `exit.json` when it appears.
