# Integration with the located State Calculus implementation

Source inspection: 2026-09-07, public repository `counc009/state_based`, branch `bash`,
commit `190dd8491b258d8a0ee29f79629908540236b332`. This is a pinned source review;
we did **not** build or run the OCaml project and do not claim this branch is necessarily
the exact unpublished working tree discussed in the meeting. The older `main` branch
at `7c62afa51986d87033af5112cdccd3b104b1c120` contains earlier whole-string utility sketches.
No private meeting or Slack transcript is included here.

## What is present

| Component | Inspected evidence | Consequence for our next experiment |
|---|---|---|
| Specification frontend | [parser.mly](https://github.com/counc009/state_based/blob/190dd8491b258d8a0ee29f79629908540236b332/bash-verifier/lib/frontend/parser.mly), [AST](https://github.com/counc009/state_based/blob/190dd8491b258d8a0ee29f79629908540236b332/bash-verifier/lib/frontend/ast.ml): typed integer literals, strings, state references, functions, while loops, exceptions | Target an existing syntax; do not invent a competing spec-language parser |
| Semantic analysis | [semant.ml](https://github.com/counc009/state_based/blob/190dd8491b258d8a0ee29f79629908540236b332/bash-verifier/lib/frontend/semant.ml): type representation and analysis implementation | Inspect and test the actual entry points before assuming end-to-end lowering |
| Calculus AST | [ast.ml](https://github.com/counc009/state_based/blob/190dd8491b258d8a0ee29f79629908540236b332/bash-verifier/lib/calculus/ast.ml): While, state-based attribute/element access, actions, Return, Raise | The old draft's foreach-only limitation does not describe this newer AST |
| Interpreter | [interp.ml](https://github.com/counc009/state_based/blob/190dd8491b258d8a0ee29f79629908540236b332/bash-verifier/lib/calculus/interp.ml): While repeatedly interprets body/condition; Return and Raise carry environment and state | Partial effects can survive modeled exceptions; this is source evidence, not a Lean preservation theorem |
| Failure distinction | Same interpreter: Failure is separate from Raise; invalid evaluation can produce Failure | Never encode a routine read/write error as interpreter Failure, which has no retained state payload |
| Filesystem sketch | [filesys.sc](https://github.com/counc009/state_based/blob/190dd8491b258d8a0ee29f79629908540236b332/bash-verifier/sclib/filesys.sc): nested filesystem elements, inode references, contents as string | Reusable structural example; not a memory allocation/byte-range contract |
| Exposed CLI | [main.ml](https://github.com/counc009/state_based/blob/190dd8491b258d8a0ee29f79629908540236b332/bash-verifier/bin/main.ml) invokes parsing and pretty-printing | CLI success alone would establish parsing, not typechecking, execution or verification |
| Tests | [test_bash_verifier.ml](https://github.com/counc009/state_based/blob/190dd8491b258d8a0ee29f79629908540236b332/bash-verifier/test/test_bash_verifier.ml) is empty at this commit | Add bounded parser/interpreter regression fixtures in an isolated future checkout; no claim that the parser is tested here |

The interpreter's action case restores the caller environment while retaining the
callee's resulting state for Return and Raise. TryCatch uses the state carried by
Raise. These are promising exact locations for a partial-effects simulation. While
recurses directly; a language constructor is not a proof of termination or a strategy
for verifying arbitrary loops. Parametric builtins and user-defined actions still need
an explicit interpretation and assumptions. No C memory model is supplied by merely
having state references.

## Concrete next handoff

1. Use an isolated checkout of the pinned public branch, outside mirrored build caches.
   Inspect dependency availability before any bounded, single-compiler build. Keep the
   author repository and our frozen phases unchanged.
2. Add parser fixtures for a typed byte-buffer protocol and an unsupported-input case.
   Establish separately whether parsing, semantic analysis, lowering and interpretation
   are connected; the current CLI connects only the first and printing.
3. Represent the single allocation as a state element indexed by block identity, with
   capacity32, initialized length, and byte contents. Choose an explicit byte encoding
   (`list<u8>` or indexed byte elements) and test NUL/255 round trips. Strings in the old
   examples do not establish that byte semantics is adequate.
4. Represent routine syscall outcomes by typed data/status. Use Return/Raise only with a
   documented shell-status mapping; retain delivered and consumed state on failure.
   Exercise input `abcdef`, reads `[4]`, writes `[2,0]`: output `ab`, unread `ef`, private
   pending `cd`, status2. At process exit discard private pending without restoring input.
5. Formalize the chosen calculus fragment and its representation relation to the Lean
   pointer machine. Prove each primitive and sequence/conditional lifting; compare the
   concrete OCaml interpreter empirically until its own preservation theorem exists.
6. Independently define a restricted typed C AST that executes the frozen relay statement
   tree. Prove AST-to-pointer execution preservation. Retain C text parsing, implementation
   integer ABI assumptions and unsupported constructs as explicit boundaries. Assess a
   CompCert/AutoCorres reuse route before expanding a custom C semantics.

This handoff uses located source and a checked observational contract. It supplies neither
an OCaml build result nor a theorem about the existing State Calculus implementation.
The actual source-to-source and shell/OS bridges remain central paper obligations.
