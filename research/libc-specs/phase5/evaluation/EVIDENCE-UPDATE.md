# Historical manuscript crosswalk (2026-09-07)

**Not current paper status.** This file records a 2026-09-07 rewrite of then-stale claims in `DRAFT-PAPER.md` against then-checked artifacts. Later work (exit-wrapper termination, universal execution, VSU linking, 90-cell evaluation, packaging) superseded several “still missing” rows. Current claims: [`DRAFT-PAPER.md`](DRAFT-PAPER.md), [`../FINAL-DELIVERY.md`](../FINAL-DELIVERY.md). This is a crosswalk, not a receipt. No new verification was performed for this refresh.

## Stale draft claim → claim as of 2026-09-07

| Then-stale draft | Correction then applied | Source |
|---|---|---|
| Only one purpose-built relay and a three-operator fragment | Extra layers existed: generated body + `semax_prog`, dry memory/safety, restricted shell text, GNU modular bodies, spec-language lowering. Still not end-to-end Bash/cat | `relay/README.md`; `shell-bridge/README.md`; `utility-reuse/RESULTS.md`; `calculus-bytes/README.md` |
| `Main.v` in progress | `body_main` / `prog_correct` accepted | `relay-main-coqc-4` |
| Byte-bearing I/O missing dry/safety | `Dry.v` / `Safety.v` `relay_dry_safety` checked; **Jsub** explicit | `adequacy-dry-coqc-20`, `adequacy-safety-coqc-2` |
| Implied returned outcome / termination from body | **Then:** no accepted Trace theorem. **Later:** `Terminate.v` / `TerminateMain.v` (see current `relay/README.md`) | then: `ORCHESTRATOR-REVIEW.md` |
| Reuse beyond relay empty | Then: `body_safe_read`, `body_simple_cat` exit 0; `body_full_write` failed. **Later:** `body_full_write` and VSUs checked (`utility-reuse/RESULTS.md`) | then receipts `pi-utility-direct-*` |
| Unchanged 32-byte syscall contracts on GNU code | Contracts generalized (fd/count/errno) | `utility-reuse/RESULTS.md` |
| Aaron frontend lowering TODO | Bounded lowering `adapter/lower.ml`; 2,046 matches + 90 Coq examples | `calculus-bytes/` |
| Shell/query only Lean | Coq `shell-bridge` lexer/parser soundness; not pipes/full Bash | `shell-bridge/README.md` |
| Calibration body “not attempted” | Bounded **negative**: no C conformance / caller transfer | `calibration/RESULTS.md` |
| Evaluation 7/12, ineffective partial-error ablation | Unchanged as a local diagnostic; later 23/90 in `evaluation-expanded/` | `evaluation/REPORT.md` |

## Requirements that remain out of scope (still true in the paper)

Host syscall / OS / fd semantics; GNU cat CLI/`main`; Coq↔Lean import; C-conformance UTF-8 theorem; full Bash pipes as OS processes. Do not treat this table’s “missing replay / larger evaluation” rows as current: packaging and the 90-cell study closed those as of [`../FINAL-DELIVERY.md`](../FINAL-DELIVERY.md).
