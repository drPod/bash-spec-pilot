# Bounded calibration: gnulib UTF-8 decoding

After the shared VST environment is available, run one small independent-correctness calibration alongside the Bash/State Calculus work. The primary milestones remain the external-I/O relay and the real-utility connection. This is not a codec-verification paper.

**Finding (current paper phase).** Testing and specification work completed; the intended VST C-conformance proof and caller-transfer proof did not. Preserve this as a negative calibration result. See [FINAL-DELIVERY.md](FINAL-DELIVERY.md) and [evaluation/DRAFT-PAPER.md](evaluation/DRAFT-PAPER.md).

The target is loop-free single-character decoding, not whole-stream decoding, I/O, allocation, pipelines, or gettext/msgfmt as a program.

## Target

Select `u8_mbtoucr` at gnulib revision `e9c1d94f58eaacee919bb2015da490b980a5eedf`, referenced by gettext v0.23.1. Source: [u8-mbtoucr.c](https://raw.githubusercontent.com/coreutils/gnulib/e9c1d94f58eaacee919bb2015da490b980a5eedf/lib/unistr/u8-mbtoucr.c) (139 lines, loop-free). Branches use byte indexing, shifts, masks, length guards and an output pointer. This isolates source translation, memory/arithmetic and functional proof from syscall assumptions and utility option behavior.

Independent semantic authority: Unicode 16.0, §3.9.3 and Tables 3-6/3-7 ([chapter 3](https://www.unicode.org/versions/Unicode16.0.0/core-spec/chapter-3/)). API return/error conventions come from the [frozen gnulib declaration](https://raw.githubusercontent.com/coreutils/gnulib/e9c1d94f58eaacee919bb2015da490b980a5eedf/lib/unistr.in.h). Preserving C behavior and proving conformance to these independent requirements are separate obligations; a source-preserving result can preserve a decoder bug.

Consumer: gettext's `mbfile_getc` invokes the decoder on an iconv-produced buffer ([read-po-lex.c](https://raw.githubusercontent.com/autotools-mirror/gettext/v0.23.1/gettext-tools/src/read-po-lex.c)). Source inclusion is not binary identity: module configuration may select external libunistring. Freeze the source selection and inspect preprocessing/linking before claiming a particular executable uses this target.

## Contract to freeze before proof attempts

Define a relation `Enc(scalar, bytes)` from the Unicode tables, not the C decision tree. For nonempty supplied input:

- Success returns the length 1..4 and scalar of the first complete legal encoding; later suffix bytes are irrelevant to this operation.
- Incomplete input is a nonempty proper prefix of a legal encoding, with no complete first encoding: return −2 and write U+FFFD.
- Otherwise return −1 and write U+FFFD. An already forbidden second byte is invalid, even when the total buffer is shorter than the nominal encoding length.

Own initialized input and a separated output cell; preserve input ownership/contents; update only output. Make ABI, lengths, alignment and nonaliasing conditions explicit. Zero length is outside this API's `n>0` precondition, not an empty-input success case. Begin with all input lists of lengths 1..4, universally quantified in the theorem; a sampled corpus is not that theorem. Prove suffix/framing generalization before claiming arbitrary `n>0` or using it in a caller with larger scratch buffers.

Controls include NUL, boundary scalars, surrogate and overlong forms, invalid leaders, upper-range overflow and every truncation depth. Useful independent cases: `E2 82` incomplete; `E0 9F` invalid; `ED A0` invalid; `F4 90` invalid; `C2 A2 FF` decodes the first character successfully. Test buffers of exact length, not only padded memory.

## Reuse and measurement

Use the selected VST/CompCert infrastructure and its array-ownership and integer libraries. Generate Clight from frozen source; keep headers/preprocessing/AST identities. Do not substitute a handwritten AST or implement another C semantics. Coq 8.20.1 is the prebuilt environment, within VST 2.15's released dependency range.

Freeze the mathematical relation and independent oracle from standard/API provenance before proof-generation trials. Upstream decoder tests are supplementary. Encoder/decoder round trips cannot replace that reference.

Diagnostic LLM protocol (only if baseline tasks exist): three tasks (legal decode, malformed/truncated behavior, source-contract integration), two library conditions (standard VST; standard VST plus reviewed reusable lemmas), two fresh-context attempts per condition: twelve attempts. Match model, time and feedback budgets. Never count collaborative baseline development as autonomous proof success. Keep specification/theorem types outside editable proof regions. Changing a contract starts a new task version. A timeout is not evidence that the claim is false.

## Transfer and stop rule

Budget at most two hours of dedicated calibration authoring/verification after the shared toolchain is available, plus the twelve bounded trials only if baseline tasks are ready. A failed translation, excessive new infrastructure or lack of independent oracle is a reason to stop early.

The transfer target is the actual generated Clight caller fragment in gettext, using the same proved decoder contract. Prove the result/count comparison's local validity effect under explicit scratch-buffer hypotheses. A rewritten toy caller is not transfer. This does not prove iconv, complete malformed-file handling or whole-msgfmt behavior.

If the decoder succeeds but caller transfer is not established, report backend calibration only. A VST body theorem alone is not the whole source-execution result. The Lean connection remains unresolved.

**Recorded outcome.** Baseline comparison: 1,190,417 finite cases plus directed checks; the worker stopped by the stop rule without a VST proof that the C decoder implements the specification or a proof about its caller (`calibration/RESULTS.md`).

## Why not other candidates

QOI adds persistent pixel/index state and whole-image completion; existing Stainless and Dafny QOI verification makes it unsuitable for a simple novelty claim. Full zlib/miniz DEFLATE brings bit buffers, Huffman structures and history windows. These are scope judgments for this experiment.

Prior-art references:

- [Ciobâcă and Gratie, Dafny QOI](https://profs.info.uaic.ro/stefan.ciobaca/dafny-qoi-ifm2024.pdf)
- [EPFL verified-QOI report](https://infoscience.epfl.ch/record/298831/files/verified-qoi.pdf)

The Dafny paper separates semantic compression/decompression from byte serialization, a useful design precedent. Those artifacts were not replayed here.
