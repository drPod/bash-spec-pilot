# Pointer-memory utility refinement and command observations

Complete the buffer relay's execution-level Lean refinement and validate compiled C call events against independent Python and Lean models. A checked composition fragment preserves state and exit status through sequencing and conditionals.

The standard replay passed 112 audited declarations, 962 shared cases and 30 actual Bash contexts in 47.40 seconds on OVH. Start with [RESULTS.md](RESULTS.md) for precise claims.

Bounded local-stage prototype (2026-09-07), not a full C/Bash verifier. C-to-AST preservation and real Bash semantics are not proved by these Lean-to-Lean results or finite tests. Later whole-program compilation is in [`../phase5/evaluation/DRAFT-PAPER.md`](../phase5/evaluation/DRAFT-PAPER.md).

From the repository root, with existing Lean 4.31.0, Python 3, GCC and GNU tools:

```sh
uv run --no-project python -B research/libc-specs/phase3/reproduce.py --tier standard
```

Use `--tier quick` for the 177-case diagnostic corpus. Builds are serialized and commands
have memory/time limits. Logs and caches default to `~/.cache/bash-spec-pilot/phase3-replay`,
outside mirrored source. A nonzero command or mismatched result/hash fails the replay.
No dependencies are installed and no network calls are made by this command.

| Artifact | Purpose |
|---|---|
| [POINTER.md](POINTER.md), [PointerCore.lean](PointerCore.lean), [PointerRelay.lean](PointerRelay.lean) | Physical buffer evaluator, reachable safety/effects, execution refinement and nonvacuity |
| [ShellObservation.lean](ShellObservation.lean), [RelayComposition.lean](RelayComposition.lean) | Generic state/status transfer and actual relay instantiation |
| [check.py](check.py), Pointer/Shell/CompositionAxioms.lean | Measured compilation and 112 explicit declaration audits |
| [validation/README.md](validation/README.md) | Independent C/Python pointer traces, hand cases, invariants and mutations |
| [TraceMain.lean](TraceMain.lean), [compare_lean.py](compare_lean.py) | Native Lean JSON trace projection compared against the same corpus |
| [shell_contexts.py](shell_contexts.py) | Actual Bash context evidence, including empirical pipeline cases |
| [RESEARCH-ARCHITECTURE.md](RESEARCH-ARCHITECTURE.md) | Semantic boundaries and primary-source reuse decisions |
| [STATE-CALCULUS-INTEGRATION.md](STATE-CALCULUS-INTEGRATION.md) | Located public parser/calculus branch and concrete next handoff |
| [PAPER-CRITERIA.md](PAPER-CRITERIA.md) | Falsifiable contribution and submission evidence gates |

The original C source and phases 1/2 results remain separate.
