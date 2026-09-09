# Source and proof boundary

The phase 5 source path uses CompCert 3.15's `clightgen -normalize`, rather than
the project's earlier restricted parser or a manually entered Clight program.
The tool's [upstream description](https://github.com/AbsInt/CompCert/blob/v3.15/export/README.md)
calls it an experimental C-to-Coq AST generator. Generating a `.v` file is not a
theorem that the input text and AST are equivalent.

## Relay configuration

Input is the unchanged `../phase2/relay.c`, SHA-256
`c5abc06f53474d90ff7927aa485a03316e267fe758593a411f70a6d22f1afe68`.
The configured compiler target is x86-64 Linux, little-endian, LP64. CompCert's
own `stddef.h` supplies `size_t`; `relay/include/unistd.h` is an explicit local
declaration adapter supplying signed-long `ssize_t` and the two syscall-shaped
function declarations. It supplies neither executable libc code nor behavioral
specifications. Behavior must come from separately stated external-call contracts.

Preprocessing should exclude ambient system include directories (`-nostdinc`),
then explicitly include the adapter and the installed CompCert header directory.
Keep the preprocessed input, header hashes, exact compiler options, compiler
identity and generated Clight file. Check that the generated types have 64-bit
`size_t`/`ssize_t`, the signed error tests precede unsigned conversions, and
the retry passes the offset pointer and remaining byte count.

The supported input for the experiment is this frozen translation unit under
these headers and options. It uses a fixed byte array, scalar integer/pointer
operations, loops, branches and direct external calls. Successful translation
does not establish arbitrary GNU C, the glibc header configuration, other ABIs,
undefined-behavior freedom or the semantics of every C construct supported by
CompCert. Those are distinct questions from the selected source's proof.

## Trust accounting

The preprocessing, parsing/elaboration and Coq AST export path is not certified
by this experiment. Source and AST hashes establish identity and replayability,
not translation correctness. VST proofs will quantify over the generated Clight
program and the specified memory/external environment. Record the exact theorem
and its assumptions; `semax_body` is a modular partial-correctness/safety result,
not by itself a termination theorem or a complete OS execution theorem.

Actual host `read`/`write`, libc wrappers, kernel behavior, process startup/exit,
Bash parsing/composition and natural-language intent remain separate boundaries.
The existing Lean model is an independently checked reference; no checked
Rocq-to-Lean theorem import currently connects the two assistants.

## Toolchain checks

The actual prebuilt Coq version is 8.20.1, not phase 4's prospective 8.20.0.
Released VST 2.15 opam metadata accepts Coq >=8.19 and <8.21 and pins CompCert
3.15. Its released build recipe itself passes `IGNORECOQVERSION=true`; this is
not a claim that no version-check bypass exists. Compatibility is based on the
released package constraints and must still be demonstrated by a successful
build and checked proofs. Do not use that flag to justify arbitrary versions.

`run_vst.py` executes one command in the already configured persistent container,
uses the shared compiler lock, refuses overlap with an existing container job,
and records elapsed time, maximum child RSS and exit status outside the repository.
It does not interpret exit zero as proof coverage. VST installation and source
proofs are still pending at this document's initial creation.
