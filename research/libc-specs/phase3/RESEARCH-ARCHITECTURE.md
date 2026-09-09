# From utility C to a defensible script theorem

Research architecture and obligation ledger for connecting a fixed utility source to a script-level theorem.

The running experiment is the frozen 32-byte relay from phase2. Checked phase3 results are in [RESULTS.md](RESULTS.md). This document does not claim a completed Bash verifier.

Local-stage architecture (2026-09-07). Later Lean script compilation and Coq/VST case studies are in [`../phase5/evaluation/DRAFT-PAPER.md`](../phase5/evaluation/DRAFT-PAPER.md); they do not discharge every obligation listed here.

## What the source-as-specification proposal buys

Choose a particular utility source revision as the behavioral reference. This can
avoid independently re-describing every flag and algorithm in a utility summary.
It does not establish that the reference implements the user's intended query.
Nor does it remove C semantics, undefined behavior, external calls, environmental
assumptions, source translation, or shell execution from the proof obligations.

The reusable object should be a library **contract plus its representation and
observation relation**, not just a state-transformer signature. A write contract
needs the bytes read from a valid initialized range, the bytes delivered, its
return code, and the state retained on failure. Our no-effect error contract is a
chosen environment restriction, not a universal POSIX guarantee. The positive
short-transfer and EOF distinctions come from the official
[read](https://pubs.opengroup.org/onlinepubs/9799919799/functions/read.html) and
[write](https://pubs.opengroup.org/onlinepubs/9799919799/functions/write.html)
interfaces; the exact experiment restrictions remain in [phase2's protocol](../phase2/PROTOCOL.md).

## A theorem architecture with explicit premises

Let `CExec(P, c, trace, c')` describe defined executions of a fixed C program under
a stated external-call contract. Let `UExec(U, a, rc, a')` describe its abstract
utility summary. Let `R(c,a)` relate representations. The required utility result
is a simulation: for every admissible concrete execution, a matching summary
execution has the same relevant observations and a related successor state.
Existence/termination requirements must be stated separately from safety.

The shell layer then needs a compositional transfer theorem. A primitive
simulation that preserves a successor state and exit status can be lifted through
sequencing and conditional execution. It cannot be lifted through arbitrary
contexts after forgetting observations those contexts inspect. For pipes, this
also requires a model of shared channels, EOF, scheduling, failure, and readiness.
Pure function composition over completed stdout strings is not that model.

The final query theorem is conditional on all these bridges, plus the meaning of
the accepted formal query. A proof against an LLM-generated query proves that query;
it does not prove the query faithfully represents an English request.

| Boundary | Evidence available before phase3 | Required next evidence |
|---|---|---|
| C text → selected AST | Whole-unit recognizer, rejection tests, exact hashes | Trusted parser boundary or checked translation certificate tied to a fixed C semantics |
| AST → pointer execution | No preservation theorem | Typed expression/statement semantics, casts, control flow, and source-to-machine simulation |
| Pointer execution → byte summary | Only local slice lemmas | Complete executions, reachable request safety, byte/state/status agreement; phase3's central obligation |
| Summary → command context | No shell composition theorem | State/status simulation and a declared context grammar; phase3 explores `;`, `&&`, `||` as a hand AST |
| Command context → real Bash | Differential utility tests only | Parser and shell/OS relation; actual Bash context tests remain empirical evidence |
| Query → human intent | Meeting notes and hand review | Independently adjudicated formal-query benchmark, ambiguity handling, explicit accepted assumptions |
| Mathematical library → host implementation | Controlled shim and real-I/O smoke tests | Verified implementation or explicit trusted external-call contract, with conformance tests reported separately |

Hash equality identifies an artifact. A theorem saying a generated alias equals
the selected model does not prove either of the first two boundaries.

## Connecting to the existing State Calculus

The local Astrogator draft, `POPL_2027_Astrogator.pdf`, §5.2.1/Fig.4 defines state
with attributes and nested elements, stateful function calls, return/failure,
conditionals, and foreach. §7.2/Fig.6 uses a hand-translated Bash example and
handwritten utility definitions. The public `bash` branch was inspected at commit
`190dd8491b258d8a0ee29f79629908540236b332`: its newer frontend and calculus include
while loops and state references; Return/Raise retain resulting state, unlike the
separate interpreter Failure result. See the [pinned implementation review](STATE-CALCULUS-INTEGRATION.md)
for exact files. No OCaml build or source-preservation proof is claimed.

For the relay, a candidate representation is:

| Concrete component | Candidate State Calculus representation | Obligation |
|---|---|---|
| allocation identity and capacity | `heap(block)` element with capacity | Existence/lifetime and separation from other allocations |
| initialized bytes | bounded byte-sequence attribute plus initialized prefix | Byte identity and read validity; generic strings are insufficient |
| pointer | `(block, offset)` value | Bounds/provenance, not a bare integer address |
| descriptor | `fd(number)` pointing to an open description/channel | Aliasing, shared offsets, flags and access mode |
| delivered/pending/unread | distinct byte sequences in owned resources | Conservation and correct ownership transitions |
| command exit | explicit status result | Branching, `&&`, `||`, pipeline-status policy |
| error/blocked/diverging execution | distinct relational alternatives | Do not conflate with undefined behavior, interpreter fuel exhaustion, or successful EOF |

This is a proposed encoding, not executable current State Calculus code. Before
implementing it, check whether values admit raw byte sequences, whether failure
retains modified state, and whether stateful function summaries may be recursive
or relational. The newer interpreter's recursive While case does not itself verify the relay's
arbitrary read/retry loops. A useful implementation boundary is to prove each
utility loop independently and expose a summary as a primitive, accompanied by
the simulation theorem. That still requires a sound rule for importing summaries.

The critical question is whether the calculus can preserve **partial effects with
failure**. A relay delivering `ab` then failing with `cd` pending and `ef` unread
cannot be modeled as an atomic rollback or an unconditional copy. A relay that
delivers `abc` then receives a read error cannot be modeled as success merely
because its output equals the input.

`RelayComposition` makes a deliberate process-exit projection: contexts retain
the unread stream, delivered stream and exit status, while relay-private pending
bytes, counters, memory and event traces are hidden. For `abcdef`, a read of four
bytes followed by writes `[2,0]` delivers `ab` and discards private `cd` on exit.
A fresh relay over the remaining mathematical stream sees `ef`; unconditional
sequencing therefore produces `abef`. This projection is appropriate only for
the declared context grammar. A query observing stderr diagnostics, detailed
traces, or another shared resource needs a richer state and a new simulation.
It does not describe running two eager-ingestion validation drivers on shared
host stdin: those drivers pre-read the host input before modeled execution.

The pointer machine's `n` means the initialized prefix from the last
nonempty successful read. It remains three after the EOF following `abc`, while
the C variable `n` becomes zero. No scalar-state identity with C is claimed.
The `pointer-trace` runtime emits the modeled status in JSON and exits zero when
that JSON was produced; it must not be used as the relay process in Bash status
tests. The separate Bash tests execute the controlled C relay driver.

## Reuse decisions grounded in primary sources

| Work inspected | Reusable component | Why it is not a drop-in replacement |
|---|---|---|
| [VeriFast I/O verification, ESOP 2015](https://www.willemp.be/cw/input-output-verification/esop2015-ioverif.pdf), and the [pinned buffered implementation](https://github.com/verifast/verifast/blob/8a4c11f3ded64070528924420fc3ffbff8973fce/examples/abstract_io/buffered_io/stdio.c) | Content-sensitive protocols, ownership of pending bytes, compositional I/O proofs | Custom API and lower-layer assumptions; another logic; not verified host glibc |
| [DeepWeb, CPP 2019](https://www.cis.upenn.edu/~bcpierce/papers/deepweb-cpp-2019.pdf), §§5–7 | C-to-effect-model refinement, buffer-bearing socket contracts, executable specs | Particular network application and conditional OS/library contracts; no automatic C-to-Lean utility pipeline |
| [Clight formal semantics](https://compcert.org/doc/html/compcert.cfrontend.Clight.html) | Fixed C types, statements, memory and external-call execution as a semantic reference | Coq development; translation to Lean and external-function interpretation require their own correspondence |
| [AutoCorres2 tutorial](https://isa-afp.org/browser_info/current/AFP/AutoCorres2/Chapter1_MinMax.html) | Lifting C into a simpler reasoning model with correspondence proofs | Isabelle infrastructure and its exact C input boundary; Lean interoperability remains work |
| [ACSL](https://frama-c.com/acsl.html) and [E-ACSL](https://www.frama-c.com/fc-plugins/e-acsl.html) | Memory preconditions, frame/postconditions and runtime contract checking | A partial footprint may be intentional; selected contracts must express our byte/error observations |
| [Fulminate, POPL 2025](https://www.cl.cam.ac.uk/~pes20/cn-testing-popl2025.pdf), §§2–5 | Reified ownership checks and the same contract used for runtime testing and proof | CN/Cerberus infrastructure and ownership fragment, not this Lean I/O interface |
| [Smoosh, POPL 2020](https://mgree.github.io/papers/popl2020_smoosh.pdf), §§3–6 | Executable shell semantics parameterized by OS operations; explicit expansion and command structure | POSIX-shell interpretation and implementation boundary; porting or refinement to our chosen Bash fragment is not automatic |

Borrow and adapt these semantic patterns, then prove their bridges.
Do not pursue a complete replacement libc corpus first.
Functional I/O specifications, source lifting, and testing contracts are established
prior art. The phase1 [pinned I/O review](../04_io_prior_art.md) records detailed artifact caveats.

## The bounded next C frontend decision

Continue with the same C program, but replace schema-to-alias selection with a
small typed AST whose evaluator executes the actual accepted statement tree.
Freeze integer widths/signedness, array decay, pointer addition, `ssize_t` failure
tests, conversion to `size_t` after guards, short-circuiting, and while execution.
Reject every other construct explicitly. State the semantics origin and prove
the typed AST's relation to the pointer machine; keep raw C parsing as a named
trusted boundary until independently verified. This is a feasible next proof
target, not a plan to claim general C support.

A parser and attractive generated Lean do not
justify rebuilding decades of C semantics. Adopt another ecosystem if it offers
a smaller defensible trust boundary; Lean-only novelty
is not a sufficient research reason to reject reuse.
