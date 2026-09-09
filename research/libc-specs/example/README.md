# Checked example: a C program as the specification of `wc -l`

*Status: checked model (kernel + restricted differential), 2026-09-07. Everything in this directory is reproducible
with the commands at the end. What it does **not** show is listed under Limitations.*

**Independent review:** This is a manually authored MiniC model, not checked C-source or binary
refinement. See [raw-byte extension](../byte-experiment/README.md),
[memory/counter proofs](../memory-experiment/README.md), and [review](../03_review_and_results.md).
All code/proofs here were authored by Claude through compiler feedback; this was not a controlled
proof-generation experiment. The initial "hand-written/no LLM" wording below has been corrected.

## What this is

The 2026-08-27 meeting proposed treating the C source of a utility as its specification, so that
only libc needs a formal spec, with the utility's C code and the user's query both compiled into a
calculus that Lean reasons about. This directory is the smallest complete instance of that chain
that the existing `pipeline/` can check:

| Layer | Here |
|---|---|
| C program (the spec of the utility) | a `wc -l` program: `getchar` loop counting `'\n'`, then `printf("%zu\n", nl)`; `return 0` |
| C semantics | a deep-embedded C subset ("MiniC": integer locals, `+ == !=`, `if`, `while`, sequencing) with a fuel-indexed interpreter `exec` |
| libc specification | `libc : State → LibCall → Int × State`: `getchar` consumes a byte from an explicit stdin buffer or returns `EOF = -1`; `printf("%zu\n", e)` appends the decimal rendering plus newline to an explicit stdout buffer |
| Pipeline contract | `run args stdin` **is** the interpreted C program: encode the harness's lines as bytes, run `exec`, decode stdout bytes as lines |
| Theorems (kernel-checked) | loop invariant; stdout = decimal newline count for *every* input; = line count at the harness interface; exit 0; args-independence; additivity |
| Oracle | GNU coreutils 9.4 `wc`, 200 seeded random cases via `pipeline/check.py` |

File: `WcFromC.lean` (single self-contained module, Lean 4.31.0 core, no Mathlib, no `import`,
`partial`, `sorry`, `axiom`, `native_decide`, ... per the pipeline's static guard).

## What is proved

| Theorem | Statement (informal) | Quantified over |
|---|---|---|
| `wcLoop_counts_newlines` | With `pending` bytes left and fuel ≥ `pending.length + 4`, the loop terminates, `nl` grows by exactly `count '\n' pending`, stdin is drained, stdout untouched | all byte lists, all states satisfying the invariant, all sufficient fuels |
| `wcProg_run` | The whole program terminates within `fuel stdin`, prints `toString (count '\n' bytes) ++ "\n"`, and sets `ret = 0` | all stdin |
| `run_stdout_eq_newline_count` | `(run a s).1 = [toString (count '\n' (bytesOf s))]` | all args, all stdin (unconditional) |
| `run_stdout_eq_line_count` | if no line contains `'\n'`, `(run a s).1 = [toString s.length]` | all args, all stdin |
| `run_exit_success` | `(run a s).2 = 0` | all |
| `run_independent_of_args` | `run a₁ s = run a₂ s` | all |
| `run_append` | count over `xs ++ ys` is the sum of the counts | all |
| `getchar_eof`, `getchar_consumes`, `getchar_codeOf` | the libc contract for `getchar` as equations | all states |
| `repr_no_newline` | `toString n` contains no `'\n'` (needed to read stdout back as one line) | all `n` |

Axiom report (from `check_result.json`): every listed theorem and `run` depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Checked result

```
$ cd pipeline && uv run check.py --target wc --artifact ../research/libc-specs/example/artifact.json --trials 200
wc: build=True axioms=True diff={'passed': 200, 'trials': 200}
```

Timing on the OVH box: build 1.6 s, differential 1.2 s. The compiled model processes 200,000
lines (`seq 1 200000`) in 0.25 s, a single measured workload; later binary-input checks found appreciable interpreter memory overhead.

## A finding the C-level model exposes

GNU `wc -l` counts newline *bytes*, so an unterminated last line is not counted:

```
$ printf 'no trailing newline' | wc -l          -> 0
$ printf 'no trailing newline' | .lake/build/bin/model -l   -> 1
```

The divergence is not in the C model (whose theorem says "count of newline bytes", matching POSIX).
It is in the pipeline's trusted `Main.lean` shim, which parses stdin into lines and by design maps
`"a\nb"` and `"a\nb\n"` to the same `["a", "b"]`; `bytesOf` then has to re-add a newline it cannot
know was absent. Every kernel-accepted `wc` artifact in `pipeline/runs/wc/` (`toString stdin.length`)
has the same divergence, and `validate.py` cannot see it because its case generator always appends
`"\n"`. Two consequences worth recording for the paper:

1. This specific lossy line decoder cannot preserve newline counts. A byte-level contract (`List UInt8`
   or `ByteArray`), or a richer line encoding retaining final-newline information, is needed for any utility whose semantics depends on the final
   newline (`wc`, `tail`, `paste`, `nl`, ...). This is the first concrete case where the pipeline's
   abstraction choice, not the model, is the fidelity gap.
2. Fidelity numbers are relative to the input distribution. The README already flags this
   (pipeline README "Needed for a paper" item 3); this is a specific witness: 100% on 200 trials,
   wrong on `printf x`.

## How this connects to the meeting's plan

- **"Only libc needs a spec."** The two libc calls the program makes are the only places where the
  meaning of the program comes from outside Lean. Both are total state transformers over explicit
  stream contents. Compare Frama-C 30.0's `stdio.h`, where `getchar`'s entire contract is
  `assigns \result, *__fc_stdin \from *__fc_stdin;` and `FILE` is a struct of two `unsigned int`s
  (`__fc_FILE_id`, `__fc_FILE_data`): that is exactly the "fputs only updates the file pointer"
  problem raised in the meeting, seen in a primary source. See `../01_libc_spec_survey.md`.
- **"C code compiles into a formal language for reasoning."** Here the formal language is MiniC
  with a fuel-indexed interpreter, not the State Calculus. The point of the example is the
  proof-shape: one loop-invariant theorem about the interpreted program, discharged by induction on
  the input bytes, then composed with trivial per-statement steps. That shape is what an LLM would
  have to produce, and it is the part that VERINA-style results say is hard.
- **"Memory modelling is the new hard part."** Deliberately absent here: the program has no
  pointers. The next program up (`sbase` `wc.c`, 145 lines, uses `fopen`/`strcmp`/`printf` and a
  UTF-8 decoder over a buffer) needs a heap component in `State` and pointer-carrying libc
  contracts (`fgets`, `strlen`, `memcpy`). The approach document (`../02_spec_generation_approach.md`)
  is about that step.

## Limitations (all deliberate, all documented in the Lean source header)

- **Harness abstraction.** stdin/stdout cross the harness as lines; `bytesOf`/`linesOf` convert.
  The finding above is the cost.
- **Bytes as `Char`.** The original model reads Unicode code points, not bytes; arbitrary invalid UTF-8 is excluded by its IO shim. Newline counting is
  unaffected (`'\n'` is one byte and never inside a UTF-8 multibyte sequence); a `wc -c`/`wc -m`
  model would have to choose.
- **`printf` is a stub.** Only `%zu\n` with one argument is modelled, as "append decimal + newline".
- **Loop condition desugared.** `while ((c = getchar()) != EOF)` is written as `c = getchar();
  while (c != EOF) { ...; c = getchar(); }`. This is the standard semantics-preserving hoisting, but
  it is done by hand, not by a verified translation.
- **Not the GNU program.** The C program is a textbook `wc -l`, not `coreutils/src/wc.c` (1047
  lines, 28 distinct libc/POSIX calls including `read`, `fstat`, `lseek`, `mbrtoc32`, and an
  AVX2 path). The GNU binary is the *oracle*, not the *spec*, in this example. The
  differential layer is what connects the two.
- **Agent-authored proofs.** Claude produced these proofs through several compiler iterations (the main obstacle was `set`, a Mathlib tactic, which core Lean lacks). Whether a model
  can produce `wcLoop_counts_newlines` from the C source is the open experiment.

## Reproduce

```
# once: elan + Lean 4.31.0 (curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none)
python3 research/libc-specs/example/make_artifact.py
cd pipeline && uv run check.py --target wc --artifact ../research/libc-specs/example/artifact.json \
    --trials 200 --out ../research/libc-specs/example/check_result.json
git checkout lean/Pipeline/Generated.lean      # restore the shared stub
```

`check_result.json` in this directory is the run recorded on 2026-09-07 (Lean 4.31.0, GNU
coreutils 9.4, Ubuntu on the OVH box).
