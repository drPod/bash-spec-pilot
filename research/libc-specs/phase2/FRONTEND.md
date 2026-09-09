# Supported source and frontend boundary

Document the pattern frontend that recognizes one complete C translation-unit schema and selects the reviewed `BufferRelay.run` model.

C-to-AST parsing and AST-to-model correspondence are unverified. The emitted `GeneratedRelay.binding_is_reference` is an alias equality proved by `rfl`: a provenance aid, not a C semantic preservation theorem.

This is a pattern frontend for `relay.c`, not a compiler for a general C subset. Local-stage 2026-09-07; later Clight/Lean translation in [`../phase5/evaluation/DRAFT-PAPER.md`](../phase5/evaluation/DRAFT-PAPER.md) is a separate trusted path.

The accepted schema is the complete AST of `relay.c`, independently constructed in
`EXPECTED_AST`. It fixes the two includes (in order), `int relay(void)`, local declarations,
32-byte unsigned-char array, descriptor numbers, sign checks, explicit `size_t` casts,
loop conditions, pointer/residual expressions, assignments and return statuses. Changed
capacity, renamed variables, alternative control flow and additional code are rejected,
even when a programmer could prove them equivalent.

The parser recognizes enough declarations, blocks, while/if/return statements, assignments,
integer literals, calls, casts and precedence-ranked expressions to compare this whole
unit. Recognizing an AST node does not authorize arbitrary programs using that node.
No unsupported statement is ignored. No code is inferred from comments, function names,
the presence of a call, or a matching subtree.

Accepted presentation changes include ASCII whitespace, comments, redundant expression
parentheses, and LF or CRLF line endings. Preprocessing is restricted to the exact
`<stddef.h>` then `<unistd.h>` includes before code. Other directives, backslashes,
trigraph sequences, lone CR, NUL, non-ASCII source, literal suffixes, alternate numeric
spellings, strings, extra functions/globals, trailing tokens, shadow declarations and
unsupported operators are rejected. Comments are replaced by spaces to preserve tokens.

A material lexer bug: a lone CR inside a `//` comment could hide an
early return from the recognizer while GCC treated it as a new line. The lexer now
normalizes CRLF and rejects remaining CR before stripping comments. Regressions cover
hidden statements/directives and retain accepted CRLF. This correction matters because
[GCC's documented initial processing](https://gcc.gnu.org/onlinedocs/cpp/Initial-processing.html)
recognizes CR as a line ending. Mutation tests are evidence, not proof that no other
recognizer bug exists.

The JSON output records original-byte SHA256, canonical AST SHA256, the full AST,
fixed configuration and `translation_verified: false`. These hashes identify artifacts;
they do not turn parsing into a proof. The target assumes the normal reviewed C headers,
link environment, ABI, and compiler flags; include-file resolution and external compiler
macros are outside the recognizer. Controlled tests explicitly substitute or wrap read/write.
They execute the C loop under a deterministic adapter rather than establishing host-libc
correctness.

`run_checks.py` validates source before staging or invoking a compiler, snapshots those
exact C bytes outside the repository, and binds the emitted model to the recorded identity.
The differential command uses this staged C snapshot. A rejection returns failure; callers
must honor that failure. The standalone frontend leaves any prior generated files present
on rejection, and its output pair is not a transactional write. The replay guard regression
checks that rejected input cannot cause the orchestrator to build a stale binding.

WG14's [C11 committee draft N1570](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf),
5.1.1.2 and 6.10, describes translation and preprocessing; 6.3.1.3 and 6.5.6 specify integer
conversion and pointer arithmetic. The Lean model uses mathematical integers and bounded
memory indices. The source checks signs before casts and all successful counts are at most
32, but this experiment has no theorem connecting those C operations to the Lean operations.
A later refinement must supply that semantic relation rather than strengthen the
wording attached to this alias.
