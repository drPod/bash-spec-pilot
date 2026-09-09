# Evidence update (2026-09-07 manuscript refresh)

Scope: rewrite of stale claims in `DRAFT-PAPER.md` against **already-checked**
artifacts and the **same** original `../REQUIREMENTS.md`. No new verification,
no novelty, no completion claim. Claude workers are **not** live (account limit;
reset 13:00 UTC). Authoritative interruption notes:
`~/agent-jobs/astra-research/phase5/claude-resume/ORCHESTRATION.md` and
`claude-resume/external-adequacy/ORCHESTRATOR-REVIEW.md`.

This file is a crosswalk, not a substitute for receipts.

## Stale draft claim → corrected claim (with sources)

| Stale (prior `DRAFT-PAPER.md`) | Corrected | Source / receipt |
|---|---|---|
| Evidence supports “only one purpose-built relay and a hand-authored three-operator fragment” | Bounded extra layers exist: generated body + `semax_prog`, dry memory/safety, restricted shell **text**, GNU modular bodies, spec-language lowering. Still not end-to-end Bash/cat | `relay/README.md`; `shell-bridge/README.md`; `utility-reuse/RESULTS.md`; `calculus-bytes/README.md` |
| `Main.v` “in progress”; no whole-program theorem | `Main.v` `body_main` / `prog_correct` accepted | `relay-main-coqc-4`; `relay/README.md` “Whole-program `semax_prog`” |
| Byte-bearing I/O missing dry/safety | `Dry.v` and `Safety.v` `relay_dry_safety` checked; **Jsub** premise explicit | `adequacy-dry-coqc-20`, `adequacy-safety-coqc-2`; ORCHESTRATOR-REVIEW |
| Implied returned outcome / termination from body or progress | `Trace.v` iteration 7 timed out 600.05 s exit 124; **no** accepted Trace theorem, no returned-outcome wrapper, no C termination | `claude-resume/external-adequacy/ORCHESTRATOR-REVIEW.md` |
| “Reuse beyond the relay: —” | Direct Pi Coq: `body_safe_read`, `body_simple_cat` exit 0; `body_full_write` fails; five bounded repairs failed; original `FullWriteBody.v` restored | `utility-reuse/RESULTS.md`; `pi-reviews/utility-receipt-recovery-1/receipts/`; `fullwrite-arithmetic-1` |
| Unchanged 32-byte syscall contracts reused on GNU code | Contracts were **generalized** (fd/count/errno-parametric); memory lemmas imported | `RESULTS.md`, `PROVENANCE.md` |
| Aaron frontend: “upstream lowering is TODO”; “no spec-language→calculus path” | **New** bounded lowering `adapter/lower.ml` from pinned parser; 2,046 status/stream/call matches + block consistency; 90 closed Coq examples | `calculus-bytes/README.md`, `MAPPING.md`; receipts `calculus-bytes-*`; `PROOF-CHAIN.md` “What calculus-bytes adds” |
| Shell/query: only Lean `ShellObservation` + hand AST | Coq `shell-bridge`: lexer/parser soundness, query on `outcome`, 44 closed statements; not pipes/redirections/full Bash | `shell-bridge/README.md`; `ShellAudit.v` |
| Proof-assistant boundary: only a proposal | Coq contract-to-shell **authoritative within one kernel**; Lean independent reference, **no import** | `integration/PROOF-CHAIN.md` (Coq-final correction) |
| Calibration “not attempted” for body | Bounded **negative**: worker stopped early; aborted `start_function` probe exists; **no** C conformance / caller transfer. Avoid “no body attempt” | `calibration/RESULTS.md`; `REQUIREMENTS.md` |
| Evaluation: “no intervention logging”; helper ablation as design success | 7/12 first-pass Grok, no larger claim; partial-error ablation **ineffective = limitation**; lock/`-s16384`/label-regex interventions **logged** | `evaluation/REPORT.md`, `protocol.json` |
| Collaborative artifacts “no intervention logging” | Diagnostic submissions unedited; other workstreams log in REPORT/ORCHESTRATOR-REVIEW | same |
| Checker unmentioned | 11 integrity tests pass; 2046 corpus unchanged | ORCHESTRATION.md; `calculus-bytes/tests/test_compare_integrity.py` |
| Live workers implied | All Claude EXITED quota; no agent live by implication | ORCHESTRATION.md last paragraphs |

## Remaining original requirements (none deleted)

See `REQUIREMENTS.md` completion table. In particular still missing:

- Returned-outcome and termination for real C.
- Host syscall / OS / fd semantics.
- `full_write` body, wrapper linking, GNU cat CLI.
- Source/ABI/environment/linking boundaries (`PROVENANCE.md`: errno cell, LP64, fixed-arity `error`, nonreturning `write_error`, static-function wrapper).
- General State Calculus correctness; OCaml-source proof; short-circuit/untyped/overflow/deep-nest.
- Bash pipes/redirections; grammar-to-process fidelity.
- Coq↔Lean import.
- C conformance and gettext transfer (calibration closed negative).
- Larger evaluation; **single-command replay** of Lean and Coq artifacts; paper artifact.

## Missing evidence specifically for replay / paper / evaluation

| Need | Status |
|---|---|
| Single-command replay of the full Lean+Coq chain from a clean tree | **Missing.** Relay has a from-scratch replay note in `relay/README.md`; there is no one-command paper artifact covering all assistants |
| Larger independently designed frozen tasks | **Missing.** Only the 12-cell diagnostic |
| Effective helper ablation | Partial-error cell does not provide it |
| Consolidated manuscript with unsupported claims excluded | This refresh is a working draft only |
| New kernel checks in this job | **None.** Do not treat this file as a receipt |

## Caveat

No compiler, network, install, or agent work was performed for this refresh.
Claims cite existing READMEs, RESULTS, PROVENANCE, PROOF-CHAIN, protocol/REPORT,
and orchestrator reviews. If those receipts are later invalidated, this
crosswalk is stale.
