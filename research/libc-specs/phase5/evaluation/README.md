[Read the research paper (PDF)](paper.pdf) · [Manuscript source](DRAFT-PAPER.md)

The paper covers the completed prototype and its limitations. The diagnostic records below describe the earlier, smaller experiment; the expanded study is in `../evaluation-expanded/`.

# Bounded proof-regeneration diagnostic and evidence package (non-UTF8)

This directory holds a small, frozen, reproducible diagnostic: can a bounded, fresh-context
model regenerate the proofs of three **already-checked** phase2/phase3 Lean theorems tied to
the research objective (byte-bearing relay, partial-error behaviour, shell short-circuit and
exit-status composition), and does the presence of reviewed reusable helper lemmas change
the outcome? It also holds the requirement-by-requirement evidence audit and a conservative
paper draft for the whole phase5 program.

**What this is not.** It is Lean-to-Lean proof regeneration on theorems that were already
proved collaboratively. It is not end-to-end C/Bash verification, not a novel semantic proof,
not a benchmark, and with two attempts per cell it cannot support any claim about model
superiority. For the later formal results and their remaining trusted boundaries, see the paper and `../FINAL-DELIVERY.md`.

| Read | Content |
|---|---|
| [REPORT.md](REPORT.md) | measured results, failure categories, controls, deviations, non-claims |
| [protocol.json](protocol.json) | frozen design: tasks, conditions, budgets, gates, accounting rules |
| [results.json](results.json) | every attempt and control with hashes, durations, tokens, gate outcomes |
| [tasks/manifest.json](tasks/manifest.json) | frozen templates (SHA-256), theorem statements, removed helpers |
| [DRAFT-PAPER.md](DRAFT-PAPER.md) | conservative contribution, prior art from the inspected surveys only, limitations, completion audit |

## Tasks (frozen 2026-09-07 08:31 UTC, before the first model call at 08:34:21 UTC)

| Task | Theorem (statement byte-identical to the repo) | Facet | Removed in `base` |
|---|---|---|---|
| `shell_status` | `ShellObservation.query_transfer` | status + residual state query transfers through `;` `&&` `\|\|` | `command_refines` |
| `byte_relay` | `RelayComposition.fragment_refines` | pointer-memory relay refines the list model under the fragment | `primitive_eq`, `primitive_refines` |
| `partial_error` | `BufferRelay.run_write_failure_residual` | write failure leaves pending bytes; delivered < consumed | `run_conservation` |

Conditions: `helper` keeps the reviewed helper lemmas (with proofs) that precede the target in
the same file; `base` deletes them. Imports and definitions are identical. The model sees the
template plus statement-only signatures of the imported declarations it may need; original
proofs are held out.

## Replay

Freezing and checking need Lean 4.31.0 (`elan`) and no network. Model attempts need the Pi
CLI authenticated for `xai/grok-4.6`. Everything writes outside the repository
(`~/.cache/bash-spec-pilot/phase5-evaluation/`, `~/agent-jobs/.../evaluation/`) and takes the
shared compiler lock `~/.cache/bash-spec-pilot/phase3-compiler.lock` for every Lean command.

```sh
# 0. private baseline copy of the phase3 project (once); built from the unchanged repo files
B=~/.cache/bash-spec-pilot/phase5-evaluation/baseline; mkdir -p $B
for f in memory-experiment/MemoryTransfer.lean phase2/BufferRelay.lean phase3/{PointerCore,PointerRelay,ShellObservation,RelayComposition,TraceMain,PointerAxioms,ShellAxioms,CompositionAxioms}.lean phase3/lakefile.toml phase3/lean-toolchain; do cp research/libc-specs/$f $B/; done
(cd $B && LEAN_NUM_THREADS=1 lake build && LEAN_NUM_THREADS=1 lake build ShellObservation RelayComposition)
# 1. regenerate templates; compare hashes with tasks/manifest.json (they must not change)
python3 research/libc-specs/phase5/evaluation/make_tasks.py
# 2. checker controls (original proof must pass in helper cells and fail in base cells)
python3 research/libc-specs/phase5/evaluation/check_attempt.py --task shell_status --condition helper --submission /path/to/proof.lean --name FRESH-NAME
# 3. one bounded model attempt (120 s, no tools) followed by the checker
python3 research/libc-specs/phase5/evaluation/run_attempt.py --task byte_relay --condition base --attempt 3
# 4. compile results.json from the job-directory receipts
python3 research/libc-specs/phase5/evaluation/summarize.py
```

`check_attempt.py` refuses to overwrite a receipt, verifies that every baseline source is
byte-identical to the repository, rejects `sorry`/`admit`/`axiom`/new declarations/`native_decide`,
builds only the target module in a private copy (single thread, 120 s, 3 GiB), requires the
axiom set to be within `{propext, Classical.choice, Quot.sound}`, and requires the `#check`
output of the theorem to equal the type recorded from the unchanged repository build
(`tasks/*/expected_check.txt`). Exit code 0 alone is never treated as acceptance.
