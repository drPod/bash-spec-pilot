# Calculus typed/shared/export snapshot (calculus-typed-shared77)

Immutable copy of the accepted Lean import closure for CalculusRelaySchedules, CalculusRelayShared, typing/lowering/typecheck, and SpecAstExport.

Frozen deps (Nested/Export/Body/Simulation/Loop/Outer/Spec/CompareMain/BufferRelay/MemoryTransfer/ScheduleConsumption) match prior accepted hashes. Tokenizer and command/query/range drafts are excluded.

`export/byte_relay_exec.ast.sexp` and `export/sexp_to_lean.py` are the trusted export-boundary inputs. Regenerating SpecAstExport.lean from those files is in-scope; a fresh OCaml parser/printer build is not.

Lake is recorded for identity only. Replay uses sequential direct Lean, not `lake build`.
