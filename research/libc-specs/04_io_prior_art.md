# I/O prior-art review — 2026-09-07

The survey's categorical absence claims are incorrect. Functional I/O specifications, compositional verification of I/O-using C, and executable formal I/O models all have directly relevant prior art. The defensible remaining question is which **scoped contracts, representations, and proof boundaries can be reused in Lean**, not whether substantive I/O specifications exist.

This review inspected primary papers and pinned code; it did not reproduce historical builds.
The initial survey has been corrected. Local literature filenames and hashes are recorded in
`literature/README.md`. Delphi now indexes the retrieved PDFs locally for navigation; citations
and claims remain grounded in the primary papers and source files.

## Penninckx, Jacobs, Piessens — ESOP 2015

**Primary citation:** [Sound, Modular and Compositional Verification of the Input/Output Behavior of Programs](https://www.willemp.be/cw/input-output-verification/esop2015-ioverif.pdf), ESOP 2015, pp. 158–182, [DOI](https://doi.org/10.1007/978-3-662-46669-8_7). Author PDF pagination is 1–25. The KU Leuven author-list PDF link now returns 404; this first-author mirror works.

Read §2, §3.1, §4/Theorem 1 (PDF p.15), §5.1/tee, §5.5 (p.20), and limitations. The development uses separation logic over Petri nets to constrain allowed I/O values and order, composing higher-level actions from basic actions. It covers terminating and nonterminating executions but proves no liveness; required output is guaranteed upon termination. The soundness theorem concerns a small language, not all C. Basic actions may be unverified library calls or syscalls. The paper reports VeriFast verification of C examples, including tee with buffering flexibility. Therefore it is direct prior art for content-sensitive modular I/O verification, not a complete verified libc.

The [author's artifact page](https://www.willemp.be/cw/input-output-verification/) separately links a 2016 Coq soundness development and explicitly says its proof rules do not support verifying nonterminating executions, despite the step semantics supporting such runs. Do not silently attribute identical coverage to every artifact/version.

## VeriFast artifacts: concrete reuse and restrictions

Pinned repository revision: `8a4c11f3ded64070528924420fc3ffbff8973fce` (resolved 2026-09-07).

- [`bin/stdio_simple.h`](https://github.com/verifast/verifast/blob/8a4c11f3ded64070528924420fc3ffbff8973fce/bin/stdio_simple.h): an alternative header explicitly intended for specifying I/O behavior. `read_char_io`/`write_char_io` carry stream, character, success, and pre/post places. `getchar` relates its return to the specified character and advances an owned token. Its introduction explicitly restricts `fopen` modes, excludes buffering/read-ahead and `fread`/`fwrite`, and includes read/write failure. It declares `fclose` as `void`, another reason not to treat it as a drop-in full ISO C API model.
- [`examples/io/hello_world/hello_world.c`](https://github.com/verifast/verifast/blob/8a4c11f3ded64070528924420fc3ffbff8973fce/examples/io/hello_world/hello_world.c): the required transitions carry `'h'`, then `'i'`; this is output-content/order information, absent from a mere ownership footprint. The success placeholders are unconstrained, so avoid paraphrasing it as guaranteed successful delivery of both characters.
- [`examples/io/tee/tee_unbuffered.c`](https://github.com/verifast/verifast/blob/8a4c11f3ded64070528924420fc3ffbff8973fce/examples/io/tee/tee_unbuffered.c): `tee_io` relates successful reads to the head of an input list and then invokes a composed output action. This directly resembles the utility-level composition needed here, under its simplified API.
- [`examples/abstract_io/buffered_io/stdio.c`](https://github.com/verifast/verifast/blob/8a4c11f3ded64070528924420fc3ffbff8973fce/examples/abstract_io/buffered_io/stdio.c#L27): `stdout_buffer` owns the actual buffered character list. `putchar_core` stores bytes and calls `write_stdout` when full; `flush_core` writes pending contents and empties the buffer. This is an inspectable specification/implementation layering pattern. It has a custom `void putchar(char)` surface and lower `write_stdout` dependency; do not call it verified glibc stdio.

## Koh et al. — CPP 2019

**Primary citation:** [From C to Interaction Trees: Specifying, Verifying, and Testing a Networked Server](https://www.cis.upenn.edu/~bcpierce/papers/deepweb-cpp-2019.pdf), CPP 2019, pp. 234–248, DOI 10.1145/3293880.3294106; [arXiv record](https://arxiv.org/abs/1811.11911).

Read §§2, 5–7 and Figs. 4, 14, 15. Its main theorem connects CompCert C behavior to an ITree implementation model and a simpler specification through network refinement. The development also executes specifications for testing, including tests against C. Fig.14 specifies `recv` with received bytes, user-buffer ownership, socket state, and an ITree continuation; failures need not advance the continuation.

The theorem is conditional on axiomatized OS/library operations. The paper explicitly says its proof is not formally connected to CertiKOS correctness; the `recv` bridge is partial, other operations remain unconnected, and TCP is unverified (§2, PDF p.4; §7, pp.10–11). Its safety-style network refinement allows stalled behavior, rather than establishing liveness. This is strong prior art for the proposed architecture, but not proof that a particular host libc implements all assumed contracts.

## Inspectable DeepSpec code, with a version warning

The accessible [DeepSpec/dsss18 repository](https://github.com/DeepSpec/dsss18/tree/1d472606b89f93912497b64e3ee15ddf798aa48a) is pinned at `1d472606b89f93912497b64e3ee15ddf798aa48a`. It is a summer-school demo snapshot, not established here as the final CPP 2019 artifact.

- [`charIO/IO/io_specs.v`](https://github.com/DeepSpec/dsss18/blob/1d472606b89f93912497b64e3ee15ddf798aa48a/charIO/IO/io_specs.v): `putchar_spec` consumes `ITREE (write c ;; k)` and returns `ITREE k`; `getchar_spec` advances the continuation using the returned integer. These are formal behavior contracts, not just footprints. But `putchar` always succeeds and `getchar` constrains signed results to −128…127, so it is not an adequate full libc getchar contract for arbitrary unsigned-byte input. Borrow the protocol structure, review the values/errors.
- [`dw/DeepWeb/Spec/Vst/SocketSpecs.v`](https://github.com/DeepSpec/dsss18/blob/1d472606b89f93912497b64e3ee15ddf798aa48a/dw/DeepWeb/Spec/Vst/SocketSpecs.v#L524): `send_spec` allows prefixes; `recv_spec` relates result length to actual buffer contents and branches for positive/zero/error results. `SOCKAPI` is abstract; the file also has explicit representation axioms.
- [`dw/DeepWeb/Proofs/TopLevelProof.v`](https://github.com/DeepSpec/dsss18/blob/1d472606b89f93912497b64e3ee15ddf798aa48a/dw/DeepWeb/Proofs/TopLevelProof.v): top-level results contain `admit`/`Admitted`. This inspection does **not** independently reproduce the published completion claim, nor refute a later completed artifact.

## Xia et al. — POPL 2020

**Primary citation:** [Interaction Trees: Representing Recursive and Impure Programs in Coq](https://arxiv.org/pdf/1906.00046), POPL 2020, article 51, DOI 10.1145/3371119. Read §§2–3, 6–7, 9.

`Ret`, `Tau`, and visible events with continuations support effectful and potentially divergent computations. Handlers interpret events compositionally. §6/PDF pp.20–21 demonstrates executable extraction and external handlers; this directly defeats a general claim that formal executable effect models do not exist. The paper also identifies an external-driver boundary and warns about extracted continuation typing; its simple example maps naturals to OCaml integers. Execution is not automatically preservation of every source-level semantic guarantee.

§9/PDF p.28 identifies nontrivial portability work and notes Lean's then-lack of built-in coinductive types. Treat this as the paper's 2020 observation, not a checked claim about every present Lean library. ITrees supplies semantic infrastructure, not the whole libc corpus.

## Bounded reusable lesson and experiment

The relevant decomposition is: fixed program semantics; allowed external-action protocol; concrete heap/buffer relation; refinement between abstraction layers; and an implementation-dependent boundary validated separately. “Executable deterministic transformer” is one possible instantiation, not a prerequisite imposed by prior art or by nondeterministic I/O.

A useful next experiment is one byte-output operation plus buffering: specify a byte-bearing write event with explicit success/failure, define a one-slot buffered writer and flush, and prove that successful flush yields the same ordered byte trace as an unbuffered writer. Keep pending buffer ownership distinct from bytes already delivered. Freeze both specifications before asking an LLM for proof. Test empty flush, one byte, two bytes crossing the flush boundary, and injected write failure against a small controlled adapter. Report separately (1) the kernel theorem between formal layers and (2) evidence that the adapter realizes the primitive contract. This is a bounded exercise in adapting the discovered specification patterns; it is not evidence of novelty or verification of host libc.
