# Frontend integration: the pinned State Calculus implementation, built and exercised

Update 2026-09-07 (shell-bridge worker, after the integration worker exited at 08:32:56 UTC):
`COMPLETION-AUDIT.md` and `PROOF-CHAIN.md` carry dated corrections (authorship statement,
session accounting, second-utility recommendation, Coq-final single-kernel arrangement,
current `Print Assumptions` requirement). The shell text -> checked AST -> relay-contract
query path that this README says did not exist now exists in bounded form in
`../shell-bridge/` (its README lists what is checked and what is trusted). The statements
below about *this* directory remain accurate.

Update 2026-09-07 (calculus-bytes worker): the byte-bearing execution and the spec-language ->
calculus lowering that this README reports as missing now exist in bounded form in
`../calculus-bytes/` (its README lists identities, receipts, and what is checked vs trusted).
The pinned `ConcreteState` nested mutators were found defective by execution there; see its
"Pinned defect" section. The statements below about *this* directory remain accurate.

Date: 2026-09-07. Worker: Claude (integration). Scope of this directory: build the actual
pinned `counc009/state_based` `bash` branch, run its parser, semantic analysis and calculus
interpreter on fixtures, and connect the interpreter fragment to the checked phase3 shell
grammar. Nothing here is a Bash parser, a Bash verifier or an end-to-end theorem.

## Source identity

| Item | Value |
|---|---|
| Repository / branch | `https://github.com/counc009/state_based`, branch `bash` |
| Commit | `190dd8491b258d8a0ee29f79629908540236b332` (2026-09-04, "Work on semantic analysis of statements") |
| Tree | `292a37c9848e8f9a1cc679a8c3f1e28dfcffd116`; `git ls-remote` on 2026-09-07 still reports this head |
| Project | `bash-verifier/` (27 files); all files present in the phase3 mirror have identical blob SHAs |
| Build host | shared `phase5-vst` container: OCaml 4.13.1+flambda, dune 3.21.1, menhir 20250912, gcc |
| Extra dependency | `stdint` 0.7.2 source tarball, sha256 `1560198d…977e6` (matches opam metadata), vendored |

The upstream `bin/main.ml` needs `clap`, which is not installed; it was not built. It only
parses and pretty-prints, so nothing is lost for these fixtures.

## What had to change to build (private copy only; upstream files untouched)

The pinned source targets a newer toolchain than the container has. Every deviation is
recorded in `fixtures/shims/`:

| Change | Reason | Effect on semantics |
|---|---|---|
| `dune-project.patch`: `(lang dune 3.23)` -> `3.21` | container dune 3.21.1 | none (build metadata) |
| `frontend_list.ml`, `frontend_map.ml`, `calculus_map.ml` | `List.is_empty`, `Map.of_list`, `Map.to_list` are OCaml >= 5.1 | standard definitions |
| `frontend_iarray.ml`, `calculus_iarray.ml` | `Stdlib.Iarray` is OCaml >= 5.4 | immutable arrays as arrays; only `of_list`, `of_seq`, `length`, `get`, `init` |
| `generator.patch`: `'v iarray` -> `'v Iarray.t` (2 lines) | the `iarray` type constructor is OCaml >= 5.4 | none; `generator.ml` is not used by the fixtures |
| `--profile release` | in dune's dev profile warning 8 (non-exhaustive match in `semant.ml`) is an error | none; the match is upstream work in progress |

Consequence: the pinned commit does not build as-is on OCaml 4.13, and does not build in
dune's default profile on any OCaml because `Semant.analyze_stmt` is non-exhaustive.

## Build and run record

Container runs (receipts under `~/agent-jobs/astra-research/phase5/runs/integration-*.json`):

| Run | Result |
|---|---|
| `integration-dune-build-1` | fail: private dune libraries are project-scoped; fixtures moved inside `bash-verifier/` |
| `-build-2` | fail: `AttrMap.to_list` unbound (OCaml 5.1 API) |
| `-build-3` | fail: `iarray` type constructor (OCaml 5.4) |
| `-build-4`, `-build-5` | fail: second `iarray` occurrence; then warning 8 as error |
| `-build-6` | **success**, release profile, 7.12 s, 109,888 KiB peak RSS |
| `-build-7` | success after hardening the driver's exception handling, 0.50 s |
| `-fixtures-parse-1`, `-semant-1` | stopped by an uncaught `Invalid_argument("Uint64.of_string")` from the pinned lexer |
| `-fixtures-parse-2`, `-semant-2`, `-interp-1`, `-reparse-1` | complete; outputs in `results/` |

Replay (repository root, container idle, fresh run names):

```sh
# build tree = fixtures/ + shims applied to a checkout of the pinned commit + vendored stdint 0.7.2
uv run --no-project python research/libc-specs/phase5/run_vst.py --name integration-dune-build-NEW --seconds 600 --workdir /home/coq/phase5/integration -- dune build --profile release ./bash-verifier/fixtures/sc_fixtures.exe --display short
uv run --no-project python research/libc-specs/phase5/run_vst.py --name integration-fixtures-interp-NEW --seconds 60 --workdir /home/coq/phase5/integration -- ./_build/default/bash-verifier/fixtures/sc_fixtures.exe interp
```

## Fixture results

### Parser and pretty-printer (`results/parse.jsonl`, `results/reparse.jsonl`)

| Fixture | Outcome |
|---|---|
| `pinned_filesys.sc` (upstream `sclib/filesys.sc`) | parsed, 10 decls; print -> parse -> print is a fixpoint |
| `byte_relay_plain.sc` (typed byte-buffer relay protocol, plain literals) | parsed, 14 decls incl. `fn relay` (while/match/raise); **printed output does not re-parse** |
| `byte_relay.sc` (same with `0u64`) | **pinned lexer raises `Invalid_argument("Uint64.of_string")`**: the suffixed lexeme is handed to Stdint |
| `byte_relay_raise_semicolon.sc` (`raise X(args);`) | parse error at 40:56: the grammar has no `;` after an argument-carrying `raise` |
| `shell_fragment.sc` (`;`/`&&`/`||` as status functions) | parsed, 5 decls; printed output does not re-parse |
| `decls_only.sc`, `decls_errors.sc` | parsed; fixpoint |
| `unsupported_bash.sc` (a Bash script) | lexer error at 1:1 (`#`) |
| `unsupported_c_for.sc` (C-style `for`) | parse error at 4:7 |
| `unterminated_comment.sc` | lexer error, unterminated comment |

Re-parsing the printed files shows why the round trip breaks: the pretty-printer emits typed
literals such as `0i64`, and the lexer's suffixed-literal rules pass the whole lexeme
(`"0i64"`) to `Int64.of_string`, which raises `Invalid_argument`. The printer also emits
`raise ReadError(code);`, which the grammar rejects, and normalizes `eof` to `eof()` and adds
an explicit `_ => {}` default arm. So at this commit the print/parse round trip holds only for
programs without integer literals (the upstream `filesys.sc`).

### Semantic analysis (`results/semant.jsonl`)

| Fixture | Outcome |
|---|---|
| `decls_only.sc` | `ok` (types, values, function signatures, empty bodies) |
| `decls_errors.sc` | 6 errors with positions: duplicate type, undefined type x3, duplicate exception, duplicate argument |
| any file with a statement inside a function body | `Failure "TODO"`: `Semant.analyze_expr` is unimplemented |

There is **no lowering** from the parsed/analyzed AST to `Calculus.Ast` at this commit. The
parser and the interpreter are separate libraries connected only by the (unfinished) analyzer.

### Interpreter (`results/interp_ocaml.jsonl`)

`sc_fixtures.ml` instantiates the pinned `Calculus.Interp.InterpConcrete` functor with a small
builtin module (literals unit/bool/int/string, functions `Eq`/`ConcatStr`, actions
`relay_ok`, `relay_late_error`, `mark`, `noreturn`). Actions append to a root attribute
`stdout` and `Return` an integer status; the phase3 grammar `;`, `&&`, `||` is encoded as
`Seq`/`Cond` over variable `rc`. All 11 commands run through the actual interpreter with the
expected status and stdout (for example `relay_late_error && mark` gives rc 1, stdout `abc`;
`relay_late_error || mark` gives rc 0, stdout `abc!`). Four negative controls reach the
interpreter's `Failure`: an action body without `Return`, a non-boolean condition, `Get` of a
missing attribute, an unbound variable.

## Lean connection (`lean/`, `compare_interp.py`)

`CalculusFragment.lean` transcribes the interpreter fragment used above (`Pass`, `Seq`, `Cond`,
`Action`, root `Add`/`Get`, `Return`, `Eq`/`ConcatStr`) and proves, for every action alphabet,
action definition and fuel bound:

- `run_iff_exec` (`run_sound`, `run_complete`): a functional evaluator `run` of the phase3
  `ShellObservation.Command` grammar against primitives read off the action definitions agrees
  exactly with the phase3 relation `ShellObservation.Exec`.
- `encode_run`: whenever `run` yields status `rc` and state `t`, the transcribed interpreter,
  started in any caller environment on the calculus encoding of the command (the same
  `encode` as `sc_fixtures.ml`), ends in `Continue` with variable `rc` bound to `rc` and state `t`.
- `encode_exec` combines the two.

Lean 4.31.0 checks the file with `-DwarningAsError=true`; the axiom audit (`results/lean_axioms.txt`)
shows only `propext`, `Classical.choice`, `Quot.sound` and no `sorryAx`. Build record:
`results/lean_check.json`. Two build notes: asynchronous elaboration had to be disabled
(`-DElab.async=false`) to stay under the phase3 3 GiB address-space cap, and fixture-specific
values are not stated as `decide` theorems because Lean 4.31 string literals do not reduce
under `decide`/`rfl`; they are checked by execution instead.

The transcription is not extracted from OCaml. Its fidelity is measured, not proved:
`fragment-json` prints the Lean evaluation of the same 12 fixture programs
(`results/interp_lean.jsonl`) and `compare_interp.py` matches name, command, outcome, rc and
stdout against the OCaml output (`results/interp_ocaml.jsonl`): 12 compared, 0 mismatches.
The three remaining OCaml records are interpreter-only negative controls with no Lean twin.

Replay of the Lean side (host, Lean 4.31.0 via elan, under the shared compiler lock):

```sh
L=~/.cache/bash-spec-pilot/phase5-integration-lean; mkdir -p $L
cp research/libc-specs/memory-experiment/MemoryTransfer.lean research/libc-specs/phase2/BufferRelay.lean research/libc-specs/phase3/ShellObservation.lean research/libc-specs/phase5/integration/lean/* $L/
cd $L && LEAN_NUM_THREADS=1 LEAN_STACK_SIZE_KB=16384 flock ~/.cache/bash-spec-pilot/phase3-compiler.lock timeout 300s prlimit --as=3221225472 lake build
lake env lean -j1 -s16384 -DElab.async=false Axioms.lean
./.lake/build/bin/fragment-json > research/libc-specs/phase5/integration/results/interp_lean.jsonl
python3 research/libc-specs/phase5/integration/compare_interp.py
```

## What this does and does not establish

- Establishes: the pinned implementation exists, builds with documented shims, its parser
  accepts a byte-buffer protocol spec and rejects Bash/C input, its analyzer stops at
  expressions, and its interpreter executes the encoded shell fragment as the phase3 grammar
  predicts on 12 programs.
- Does not establish: Bash parsing, spec-language to calculus lowering, any theorem about the
  OCaml code, byte-level memory in the calculus (strings were used for stdout), or agreement
  beyond the fixtures. See `PROOF-CHAIN.md` for the trusted boundaries and
  `COMPLETION-AUDIT.md` for the prioritized remaining work.
