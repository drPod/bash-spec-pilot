# Bounded 12-cell proof-regeneration diagnostic (2026-09-07)

Fresh-context regeneration of three already-checked Lean theorems by `xai/grok-4.6` (Pi 0.84.2, no tools, 120 s wall).

**7 of 12** first-pass attempts accepted. Unpowered (two attempts per cell). Says nothing about C, libc, OS, Bash, Coq/VST, or model superiority. The later 90-cell study is [`../evaluation-expanded/REPORT.md`](../evaluation-expanded/REPORT.md) (23/90 scored).

Calls: 08:34:21–08:36:54 UTC. Tasks frozen 08:31 UTC (`tasks/manifest.json`). Receipts: `~/agent-jobs/astra-research/phase5/claude-resume/evaluation/`. Compiled: `results.json`.

## Results

| Task (theorem) | Condition | Accepted | Model time (s) | Failure category |
|---|---|---|---|---|
| shell_status (`ShellObservation.query_transfer`) | helper (`command_refines` present) | 2/2 | 6.9, 6.1 | — |
| shell_status | base (`command_refines` removed) | 2/2 | 23.0, 18.0 | — |
| byte_relay (`RelayComposition.fragment_refines`) | helper (`primitive_eq`, `primitive_refines` present) | 2/2 | 8.3, 7.4 | — |
| byte_relay | base (both removed) | 0/2 | 13.3, 13.8 | compiler error re-proving `PrimitiveRefines` (`cases`/`subst` on `graph`; `simp ... at hc` then `rw run_detailed_eq` not found) |
| partial_error (`BufferRelay.run_write_failure_residual`) | helper (`run_conservation` present) | 0/2 | 11.0, 11.4 | `omega could not prove the goal` after `simp [run, runDetailed]` |
| partial_error | base (`run_conservation` removed) | 1/2 | 9.0, 8.2 | a1: same `omega` failure; a2 added `remaining.length ≤ input.length` |

All seven accepted proofs: axioms ⊆ {propext, Classical.choice, Quot.sound}; `#check` byte-identical to the repository type; templates and baseline sources byte-identical. Token usage in `results.json`: Pi reports 32,284 input, 5,632 cache-read, 8,118 output, 46,034 total across twelve calls. Input per call 1,344–5,429. Reported 6,111 reasoning tokens are not added again.

Post-run review: the historical checker’s `errors` field also captured informational lines containing names such as `error_preserves_state`. Compiler exit and acceptance gates were unaffected. Original receipts unchanged.

## Reuse accounting

- Both `byte_relay/helper` and both `shell_status/helper` proofs invoke `ShellObservation.command_refines` as a black box.
- Both `shell_status/base` proofs re-prove simulation inline (`have sim … induction h`, six `Exec` constructors), ~3× helper-cell model time. Both `byte_relay/base` proofs failed on dependent elimination of the `graph` equation — the step `primitive_refines` encapsulates.
- **`partial_error` helper ablation was ineffective.** None of four submissions used `run_conservation`; all used `execute_contract`, present in both conditions. The 0/2 vs 1/2 split is noise around a length inequality, not a library effect.

## Checker controls (`checks/control2-*.json`)

| Control | Expected | Observed |
|---|---|---|
| Original proof, helper cell (×3) | accept | accept 3/3 |
| Original proof, base cell (×3) | reject | reject 3/3, build failed |
| `by sorry` | reject | lexical guard |
| `by native_decide` | reject | lexical guard |
| `by simp` | reject | build failed |

A first control round (`checks/control-*.json`) showed `lake env lean` under the 3 GiB address-space limit needs `-s16384`. Fixed before any model attempt.

## Deviations

1. Attempts 1–10 were checked without the shared compiler lock (each ≤ 2 s). Checker patched at 08:36 UTC; attempts 11–12 and re-check of seven accepted submissions (`checks/recheck-*.json`) ran under the lock. Accepted set unchanged.
2. No submission was edited beyond two-space indent. No feedback round.
3. Memorisation of private phase2/phase3 sources cannot be excluded; base-cell failures argue against verbatim recall of `primitive_refines`, not a control.

## Non-claims

No VST/CompCert body evidence, OS/fd semantics, Coq–Lean connection, Bash parser fidelity, second real utility, UTF-8 content, or a proof-success-rate beyond these 12 cells.

Calibration timing notes (worker 08:06:59–08:25:58 UTC, not a deadline timeout) live in [`../calibration/RESULTS.md`](../calibration/RESULTS.md). Supplementary Pi UTF-8 inputs are not part of the frozen 1,190,417-case corpus.
