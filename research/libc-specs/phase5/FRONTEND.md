# Source and proof boundary

Phase 5 obtains Clight from CompCert 3.15 `clightgen -normalize`, not from a restricted project parser or a manually entered Clight program. CompCert's [export README](https://github.com/AbsInt/CompCert/blob/v3.15/export/README.md) calls this an experimental C-to-Coq AST generator. Generating a `.v` file is not a theorem that the input text and AST are equivalent.

The frozen relay translation unit is the supported input for the experiment. Source and AST hashes establish identity and replayability, not translation correctness.

Successful translation does not establish arbitrary GNU C, glibc header configuration, other ABIs, undefined-behavior freedom, or the semantics of every C construct CompCert supports.

## Relay configuration

Input is the unchanged `../phase2/relay.c`, SHA-256
`c5abc06f53474d90ff7927aa485a03316e267fe758593a411f70a6d22f1afe68`.
Compiler target: x86-64 Linux, little-endian, LP64. CompCert's `stddef.h` supplies `size_t`; `relay/include/unistd.h` is a local declaration adapter supplying signed-long `ssize_t` and two syscall-shaped function declarations. It supplies neither executable libc code nor behavioral specifications. Behavior must come from separately stated external-call contracts.

Preprocessing excludes ambient system include directories (`-nostdinc`), then includes the adapter and the installed CompCert header directory. Keep the preprocessed input, header hashes, exact compiler options, compiler identity and generated Clight file. Check that generated types have 64-bit `size_t`/`ssize_t`, that signed error tests precede unsigned conversions, and that the retry passes the offset pointer and remaining byte count.

The program uses a fixed byte array, scalar integer/pointer operations, loops, branches and direct external calls.

## Trust accounting

The preprocessing, parsing/elaboration and Coq AST export path is not certified by this experiment. VST proofs quantify over the generated Clight program and the specified memory/external environment. Record the exact theorem and its assumptions; `semax_body` is a modular partial-correctness/safety result, not by itself a termination theorem or a complete OS execution theorem.

Actual host `read`/`write`, libc wrappers, kernel behavior, process startup/exit, Bash parsing/composition and natural-language intent remain separate boundaries. The Lean model is an independently checked reference; no checked Rocq-to-Lean theorem import connects the two assistants. The later bounded generated-Clight connection in Lean is stated in [FINAL-DELIVERY.md](FINAL-DELIVERY.md) and [integration/lean/CLIGHT-SOURCE-ACCEPTANCE.md](integration/lean/CLIGHT-SOURCE-ACCEPTANCE.md); it still trusts this frontend.

## Toolchain checks

The prebuilt Coq version is 8.20.1. Released VST 2.15 opam metadata accepts Coq ≥8.19 and <8.21 and pins CompCert 3.15. Its released build recipe passes `IGNORECOQVERSION=true`; that is not a claim that no version-check bypass exists. Compatibility is based on the released package constraints and must still be demonstrated by a successful build and checked proofs.

`run_vst.py` executes one command in the configured persistent container, uses the shared compiler lock, refuses overlap with an existing container job, and records elapsed time, maximum child RSS and exit status outside the repository. Exit zero is not proof coverage.
