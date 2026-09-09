# Bounded proof-regeneration diagnostic (12-cell, single model)

[Research paper (PDF)](paper.pdf) · [Manuscript source](DRAFT-PAPER.md)

The paper describes the completed prototype and its limits. This directory is the **earlier, smaller** Lean-to-Lean diagnostic (7 of 12 accepted). The expanded 90-cell study is [`../evaluation-expanded/`](../evaluation-expanded/). Whole-program delivery bounds: [`../FINAL-DELIVERY.md`](../FINAL-DELIVERY.md).

Can a bounded, fresh-context model regenerate three already-checked phase2/phase3 Lean theorems, and does a reviewed helper change the outcome?

7 of 12 first-pass attempts by `xai/grok-4.6` accepted. Unpowered (two attempts per cell). Not C/Bash verification, not a model ranking.

| Read | Content |
|---|---|
| [REPORT.md](REPORT.md) | results, failure categories, controls, deviations, non-claims |
| [protocol.json](protocol.json) | frozen design |
| [results.json](results.json) | attempts and controls |
| [tasks/manifest.json](tasks/manifest.json) | templates, statements, removed helpers |
| [DRAFT-PAPER.md](DRAFT-PAPER.md) | manuscript for the whole phase5 program |
| [EVIDENCE-UPDATE.md](EVIDENCE-UPDATE.md) | historical 2026-09-07 draft crosswalk; not current paper status |

## Tasks (frozen 2026-09-07 08:31 UTC, before first model call 08:34:21 UTC)

| Task | Theorem | Facet | Removed in `base` |
|---|---|---|---|
| `shell_status` | `ShellObservation.query_transfer` | status + residual state through `;` `&&` `\|\|` | `command_refines` |
| `byte_relay` | `RelayComposition.fragment_refines` | pointer-memory relay vs list model | `primitive_eq`, `primitive_refines` |
| `partial_error` | `BufferRelay.run_write_failure_residual` | write failure leaves pending bytes | `run_conservation` |

`helper` keeps reviewed lemmas; `base` deletes them. Original proofs held out.

## Replay

Lean 4.31.0 (`elan`), no network. Model attempts need Pi authenticated for `xai/grok-4.6`. Writes outside the repository (`~/.cache/bash-spec-pilot/phase5-evaluation/`). Shared compiler lock `~/.cache/bash-spec-pilot/phase3-compiler.lock`.

```sh
B=~/.cache/bash-spec-pilot/phase5-evaluation/baseline; mkdir -p $B
for f in memory-experiment/MemoryTransfer.lean phase2/BufferRelay.lean phase3/{PointerCore,PointerRelay,ShellObservation,RelayComposition,TraceMain,PointerAxioms,ShellAxioms,CompositionAxioms}.lean phase3/lakefile.toml phase3/lean-toolchain; do cp research/libc-specs/$f $B/; done
(cd $B && LEAN_NUM_THREADS=1 lake build && LEAN_NUM_THREADS=1 lake build ShellObservation RelayComposition)
python3 research/libc-specs/phase5/evaluation/make_tasks.py
python3 research/libc-specs/phase5/evaluation/check_attempt.py --task shell_status --condition helper --submission /path/to/proof.lean --name FRESH-NAME
python3 research/libc-specs/phase5/evaluation/run_attempt.py --task byte_relay --condition base --attempt 3
python3 research/libc-specs/phase5/evaluation/summarize.py
```

`check_attempt.py` refuses to overwrite a receipt, checks baseline identity, rejects `sorry`/`admit`/`axiom`/new declarations/`native_decide`, builds the target in a private copy (single thread, 120 s, 3 GiB), requires axioms ⊆ `{propext, Classical.choice, Quot.sound}`, and requires `#check` to match `tasks/*/expected_check.txt`. Exit code 0 alone is never acceptance.
