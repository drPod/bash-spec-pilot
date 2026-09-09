# Frontend integration: pinned State Calculus implementation

Build the pinned `counc009/state_based` `bash` branch, run its parser, semantic analysis and calculus interpreter on fixtures, and connect an interpreter fragment to the checked phase3 shell grammar. Nothing here is a Bash parser, a Bash verifier or an end-to-end theorem.

**Finding (this directory, 2026-09-07).** The pinned commit builds on OCaml 4.13 only with documented shims. Parser accepts a byte-buffer protocol spec and rejects Bash/C input. Analyzer stops at expressions (`Semant.analyze_expr = failwith "TODO"`). Interpreter executes an encoded shell fragment as the phase3 grammar predicts on 12 programs. Later byte-bearing execution lives in [../calculus-bytes](../calculus-bytes/README.md); bounded shell text→AST in `../shell-bridge/`; Lean-final composition in [lean-final/README.md](lean-final/README.md). Whole-program status: [../FINAL-DELIVERY.md](../FINAL-DELIVERY.md).

No theorem about OCaml code. Print/parse round trip fails for programs with integer literals at this commit. Later directories close some gaps listed historically in [COMPLETION-AUDIT.md](COMPLETION-AUDIT.md); those closures are local-stage results unless cited from FINAL-DELIVERY.

## Source identity

| Item | Value |
|---|---|
| Repository / branch | `https://github.com/counc009/state_based`, branch `bash` |
| Commit | `190dd8491b258d8a0ee29f79629908540236b332` (2026-09-04) |
| Tree | `292a37c9848e8f9a1cc679a8c3f1e28dfcffd116` |
| Project | `bash-verifier/` (27 files); phase3 mirror blob SHAs identical |
| Build host | shared `phase5-vst`: OCaml 4.13.1+flambda, dune 3.21.1, menhir 20250912, gcc |
| Extra dependency | `stdint` 0.7.2, sha256 `1560198d…977e6`, vendored |

Upstream `bin/main.ml` needs `clap` (not installed); it only parses and pretty-prints.

## Build changes (private copy; upstream files untouched)

| Change | Reason | Effect on semantics |
|---|---|---|
| `dune-project.patch`: `(lang dune 3.23)` → `3.21` | container dune 3.21.1 | none |
| `frontend_list.ml`, `frontend_map.ml`, `calculus_map.ml` | `List.is_empty`, `Map.of_list`, `Map.to_list` are OCaml ≥ 5.1 | standard definitions |
| `frontend_iarray.ml`, `calculus_iarray.ml` | `Stdlib.Iarray` is OCaml ≥ 5.4 | immutable arrays as arrays; only `of_list`, `of_seq`, `length`, `get`, `init` |
| `generator.patch`: `'v iarray` → `'v Iarray.t` (2 lines) | type constructor OCaml ≥ 5.4 | none; `generator.ml` unused by fixtures |
| `--profile release` | dune dev profile treats warning 8 as error | none; match is upstream WIP |

The pinned commit does not build as-is on OCaml 4.13, and does not build in dune’s default profile because `Semant.analyze_stmt` is non-exhaustive.

## Build and run record

Receipts under `~/agent-jobs/astra-research/phase5/runs/integration-*.json`. Builds 1–5 failed (project-scoped libraries, OCaml 5 APIs, warning 8). `integration-dune-build-6` success, release profile, 7.12 s, 109,888 KiB peak RSS; `-build-7` after driver exception handling, 0.50 s. First parse/semant runs stopped on `Invalid_argument("Uint64.of_string")`; `-parse-2`, `-semant-2`, `-interp-1`, `-reparse-1` complete in `results/`.

```sh
uv run --no-project python research/libc-specs/phase5/run_vst.py --name integration-dune-build-NEW --seconds 600 --workdir /home/coq/phase5/integration -- dune build --profile release ./bash-verifier/fixtures/sc_fixtures.exe --display short
uv run --no-project python research/libc-specs/phase5/run_vst.py --name integration-fixtures-interp-NEW --seconds 60 --workdir /home/coq/phase5/integration -- ./_build/default/bash-verifier/fixtures/sc_fixtures.exe interp
```

## Fixture results

### Parser and pretty-printer (`results/parse.jsonl`, `results/reparse.jsonl`)

| Fixture | Outcome |
|---|---|
| `pinned_filesys.sc` | parsed, 10 decls; print → parse → print is a fixpoint |
| `byte_relay_plain.sc` | parsed, 14 decls incl. `fn relay`; **printed output does not re-parse** |
| `byte_relay.sc` (`0u64`) | **pinned lexer raises `Invalid_argument("Uint64.of_string")`** |
| `byte_relay_raise_semicolon.sc` | parse error at 40:56: no `;` after argument-carrying `raise` |
| `shell_fragment.sc` | parsed, 5 decls; printed output does not re-parse |
| `decls_only.sc`, `decls_errors.sc` | parsed; fixpoint |
| `unsupported_bash.sc` | lexer error at 1:1 (`#`) |
| `unsupported_c_for.sc` | parse error at 4:7 |
| `unterminated_comment.sc` | lexer error, unterminated comment |

Pretty-printer emits typed literals such as `0i64`; lexer suffixed-literal rules pass the whole lexeme to `Int64.of_string`, which raises. Printer also emits `raise ReadError(code);` (grammar rejects), normalizes `eof` to `eof()`, and adds `_ => {}`. Round trip holds only for programs without integer literals (upstream `filesys.sc`).

### Semantic analysis (`results/semant.jsonl`)

| Fixture | Outcome |
|---|---|
| `decls_only.sc` | `ok` |
| `decls_errors.sc` | 6 errors with positions |
| any file with a statement inside a function body | `Failure "TODO"` |

There is **no lowering** from parsed/analyzed AST to `Calculus.Ast` at this commit. A later adapter lowering is [../calculus-bytes/MAPPING.md](../calculus-bytes/MAPPING.md).

### Interpreter (`results/interp_ocaml.jsonl`)

`sc_fixtures.ml` instantiates `Calculus.Interp.InterpConcrete` with a small builtin module. Actions append to root attribute `stdout` and `Return` an integer status; phase3 `;`, `&&`, `||` encoded as `Seq`/`Cond` over `rc`. All 11 commands run with expected status and stdout (e.g. `relay_late_error && mark` → rc 1, stdout `abc`; `relay_late_error || mark` → rc 0, stdout `abc!`). Four negative controls reach `Failure`.

## Lean connection (`lean/`, `compare_interp.py`)

`CalculusFragment.lean` transcribes `Pass`, `Seq`, `Cond`, `Action`, root `Add`/`Get`, `Return`, `Eq`/`ConcatStr` and proves, for every action alphabet, definition and fuel:

- `run_iff_exec` (`run_sound`, `run_complete`): functional `run` of phase3 `ShellObservation.Command` agrees with `ShellObservation.Exec`.
- `encode_run`: transcribed interpreter on the calculus encoding ends in `Continue` with `rc` and state `t`.
- `encode_exec` combines the two.

Lean 4.31.0, `-DwarningAsError=true`; `results/lean_axioms.txt`: `propext`, `Classical.choice`, `Quot.sound`, no `sorryAx`. Asynchronous elaboration disabled (`-DElab.async=false`) for the 3 GiB cap. Fixture-specific values checked by execution, not `decide` (Lean 4.31 string literals).

Transcription is not extracted from OCaml. `fragment-json` vs OCaml: 12 compared, 0 mismatches. Three remaining OCaml records are interpreter-only negative controls.

```sh
L=~/.cache/bash-spec-pilot/phase5-integration-lean; mkdir -p $L
cp research/libc-specs/memory-experiment/MemoryTransfer.lean research/libc-specs/phase2/BufferRelay.lean research/libc-specs/phase3/ShellObservation.lean research/libc-specs/phase5/integration/lean/* $L/
cd $L && LEAN_NUM_THREADS=1 LEAN_STACK_SIZE_KB=16384 flock ~/.cache/bash-spec-pilot/phase3-compiler.lock timeout 300s prlimit --as=3221225472 lake build
lake env lean -j1 -s16384 -DElab.async=false Axioms.lean
./.lake/build/bin/fragment-json > research/libc-specs/phase5/integration/results/interp_lean.jsonl
python3 research/libc-specs/phase5/integration/compare_interp.py
```

See [PROOF-CHAIN.md](PROOF-CHAIN.md) for trusted boundaries.
