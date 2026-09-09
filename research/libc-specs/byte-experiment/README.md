# Byte-preserving execution of the MiniC newline counter

`RawWc.lean` imports the unchanged `example/WcFromC.lean` definitions and generalizes its
whole-program proof from encoded line lists to arbitrary input. `runBytes` receives `List UInt8`,
injects each byte separately into a `Char` with the same numeric value, and executes the original
MiniC AST. This is **not UTF-8 decoding**. A representation lemma proves preservation of newline
counts. `Main.lean` reads raw bytes and calls precisely that function.

Kernel-checked results (Lean 4.31.0):

- `wcProg_raw`: sufficient fuel, exact decimal count followed by LF, and modeled return 0.
- `liftByte_newline` and `count_liftBytes`: byte injection preserves precisely occurrences of 10.
- `runBytes_correct`: exact modeled output/status for **every finite UInt8 list**, including
  unterminated input, NUL and malformed UTF-8.
- `runBytes_append`: newline counts compose over byte-list concatenation.
- `no_line_factorization`: no function on the **existing decoder's** `List String` output can
  recover newline counts for every string. Its kernel-checked witness is `x` versus `x\n`.
  This is a small information-loss theorem, not a claim that all line encodings are inadequate.

The new executable matched a minimal compiled C companion, GNU `wc -l` 9.4 and an independent
byte-count expectation on **1,000 corpus entries**: 38 directed, 596 exhaustive within two small
alphabets/bounds, and 366 seeded random. Compare exact stdout bytes, stderr bytes and exit status;
there is no normalization. Corpus entries may overlap between categories. Seed: 20260907.
Corpus SHA-256: `60ea637e14f0e0547ee4106a49819abfc0d8d7d106e88d2c4bee6e5a8458e82e`.
The old shim agrees on 192, adds one on 221 unterminated valid-UTF-8 entries, and rejects 587
invalid-UTF-8 entries. These proportions characterize this corpus, not typical user inputs.

The independent Claude worker tested the private prototype; Astra rebuilt the integrated sources
and reran the same corpus. `../data/phase1_results.json` records the integrated source hashes,
tool versions and measurements. Raw per-case runtime logs stay in the local cache.

## Replay

From the repository root:

```sh
uv run --no-project python research/libc-specs/check_experiments.py --only bytes
uv run --no-project python research/libc-specs/byte-experiment/validate.py
```

Builds go to `~/.cache/bash-spec-pilot/libc-experiments`; C binaries, per-case results and validation
logs go to `~/.cache/bash-spec-pilot/raw-wc-validation`. `--cache`/`--out` can select another path
outside the repository. The Lean replay requires GNU time (`gtime` on macOS) and installed Lean
4.31.0. Differential validation requires `cc` and GNU `wc` (`gwc` on macOS). Mac code paths have
not been tested in this phase; no remote Mac execution occurred.

To reproduce the old-shim comparison, pass `--old-model PATH` to a separately built original
pipeline executable. Passing that executable as `--model` instead is a negative control, expected
to fail 808/1000 on this corpus. Build shared pipeline artifacts serially or in a private copy.

## What this still does not prove

The C text and MiniC AST are manually matched; no verified C frontend or GNU source translation
exists. Integers in the original interpreter are unbounded; the separate modular-counter proof
exposes and qualifies this gap, but is **not** a simulation theorem for the original MiniC AST.
The C companion wraps `size_t`, ignores `getchar` errors and `printf` failure, and uses the host's
execution character set. The model assumes finite successful input and infallible formatted output.
Arguments, filenames, buffering, blocking, host errors and shell/process semantics are outside scope.

The executable additionally trusts Lean's compiler, runtime, core native implementations and
OS I/O. In particular `Nat.repr` uses core `implemented_by reprFast`; printed axiom reports alone
do not verify that native implementation. The generated-code guard patch does not remove trusted
core native code. `String.ofList`/output encoding and the I/O driver remain part of this boundary.

For directed inputs around 1 MiB, the prototype used roughly 58–140 MiB peak RSS. This is an
interpreter prototype with closure-based environments, not evidence of efficient large-utility
verification. Timings are single-host measurements with process/startup overhead; no comparative
performance or asymptotic benchmark claim is made. Exact 1,000-case agreement is finite evidence
about normal I/O, not a C/libc conformance proof.
