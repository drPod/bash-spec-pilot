# Bounded calibration decision: gnulib UTF-8 decoding

Decision: run one small calibration after the shared VST environment is ready, alongside
the existing Bash/State Calculus research. This is not a pivot to a codec-verification
paper. The external-I/O relay and real-utility connection remain primary milestones.

## Why this target

Select `u8_mbtoucr` at gnulib revision
`e9c1d94f58eaacee919bb2015da490b980a5eedf`, referenced by gettext v0.23.1. The
[existing C source](https://raw.githubusercontent.com/coreutils/gnulib/e9c1d94f58eaacee919bb2015da490b980a5eedf/lib/unistr/u8-mbtoucr.c)
is one139-line, loop-free decoder. Its branches use byte indexing, shifts, masks, length
guards and an output pointer. This isolates source translation, memory/arithmetic and
functional proof from syscall assumptions and complicated utility option behavior.
It does not test loops, allocation, I/O, pipelines or whole-stream decoding.

The independent semantic authority is Unicode16.0, section3.9.3 and Tables3-6/3-7.
[Unicode chapter3](https://www.unicode.org/versions/Unicode16.0.0/core-spec/chapter-3/).
API return/error conventions come separately from the
[frozen gnulib declaration](https://raw.githubusercontent.com/coreutils/gnulib/e9c1d94f58eaacee919bb2015da490b980a5eedf/lib/unistr.in.h).
Preserving C behavior and proving conformance to these independent requirements are
separate obligations. A source-preserving result could preserve a decoder bug.

There is an actual utility consumer: gettext's `mbfile_getc` invokes the decoder on an
iconv-produced buffer, checks its consumed count, and records character validity.
[Existing caller](https://raw.githubusercontent.com/autotools-mirror/gettext/v0.23.1/gettext-tools/src/read-po-lex.c).
This code belongs to libgettextsrc used by msgfmt. Source inclusion is not binary identity:
module configuration may select external libunistring, so freeze the source selection
and inspect preprocessing/linking before claiming a particular executable uses our target.

## Contract to freeze before proof attempts

Define a relation `Enc(scalar, bytes)` from the Unicode tables, not the C decision tree.
For nonempty supplied input:

- Success returns the length1..4 and scalar of the first complete legal encoding;
  later suffix bytes are irrelevant to this operation.
- Incomplete input is a nonempty proper prefix of a legal encoding, with no complete
  first encoding: return-2 and write U+FFFD.
- Otherwise return-1 and write U+FFFD. An already forbidden second byte is invalid,
  even when the total buffer is shorter than the nominal encoding length.

Own initialized input and a separated output cell; preserve input ownership/contents,
update only output. Make the ABI, lengths, alignment and nonaliasing conditions explicit.
Zero length is outside this API's n>0 precondition, not an empty-input success case.
Begin with all input lists of lengths1..4, universally quantified in the theorem; a
sampled corpus is not that theorem. Prove suffix/framing generalization before claiming
arbitrary n>0 or using it in a caller with larger scratch buffers.

Controls include NUL, boundary scalars, surrogate and overlong forms, invalid leaders,
upper-range overflow and every truncation depth. Particularly useful independent cases:
E2 82 incomplete; E0 9F invalid; ED A0 invalid; F4 90 invalid; C2 A2 FF decodes the first
character successfully. Test buffers of exact length, not just padded memory.

## Reuse and measurement

Use the selected VST/CompCert infrastructure and its array ownership and integer libraries.
Generate Clight from frozen source; keep headers/preprocessing/AST identities. Do not
substitute a handwritten AST or implement another C semantics. Coq8.20.1 is the actual
prebuilt environment, within VST2.15's released dependency range; final installation
and proof results remain pending. No verification result is claimed by this assessment.

Freeze the mathematical relation and independent oracle from standard/API provenance
before proof-generation trials. Upstream decoder tests are supplementary. Encoder/decoder
round trips cannot replace that reference. Record the exact provenance and review history;
separate construction does not establish statistical independence.

First develop one baseline with all interventions logged. Then, if suitable frozen tasks
exist, use three tasks (legal decode, malformed/truncated behavior, source-contract
integration), two library conditions (standard VST; standard VST plus reviewed reusable
lemmas), and two fresh-context attempts per condition: twelve attempts total. Match model,
time and feedback budgets. This is diagnostic evidence, not a powered general LLM study.
Never count collaborative baseline development as autonomous proof success.

Measure source/theorem coverage, assumptions, first-pass/assisted outcomes, reusable versus
new lemmas, resource cost and failure category. Record actual human intervention separately
from agent/orchestrator repairs; do not label agent runtime as human expert minutes.
Keep specification/theorem types outside editable proof regions. Changing a contract
starts a new task version. A timeout is not evidence that the claim is false.

## Transfer and stop rule

Budget at most two hours of dedicated calibration authoring/verification after the shared
toolchain is available, plus the twelve bounded trials only if baseline tasks are ready.
Log the start and exclusions; do not silently extend by cycling through other codecs.
A failed translation, excessive new infrastructure or lack of independent oracle is a
reason to stop early and record the limitation.

The transfer target is the actual generated Clight caller fragment in gettext, using the
same proved decoder contract. Prove the result/count comparison's local validity effect
under explicit scratch-buffer hypotheses. Preserve source/AST linkage; a rewritten toy
caller is not transfer. Record unchanged contracts, added obligations and intervention.
This does not prove iconv, complete malformed-file handling or whole-msgfmt behavior.

If the decoder succeeds but caller transfer is not established, report backend calibration
only and return to the relay. Expansion requires demonstrated help with the Bash/utility
milestone. A final semantic consequence and a separate termination argument are required;
a VST body theorem alone is not the whole source-execution result. The Lean connection
remains explicitly unresolved. No substantial objective change or contact with Aaron is
implied or performed.

## Why not the other brainstormed candidates now

QOI adds persistent pixel/index state and whole-image completion; existing Stainless and
Dafny QOI verification makes it unsuitable for a simple novelty claim. Full zlib/miniz
DEFLATE brings bit buffers, Huffman structures and history windows, obscuring this first
calibration. Storage targets remain underspecified. These are scope judgments for this
experiment, not claims those projects lack valuable research problems.

Primary prior-art references include
[Ciobâcă and Gratie's Dafny QOI case study](https://profs.info.uaic.ro/stefan.ciobaca/dafny-qoi-ifm2024.pdf)
and the [EPFL verified-QOI report](https://infoscience.epfl.ch/record/298831/files/verified-qoi.pdf).
The Dafny paper describes separating semantic compression/decompression from byte
serialization, a useful design precedent for separating our mathematical contract
from C memory representation. We have not replayed either QOI artifact.
The local Delphi query returned unrelated existing corpus fragments; indexing the
downloaded Dafny paper failed on a NUL-character extraction error. Consequently,
the assessment uses direct primary-source inspection, not a claim that Delphi
performed a comprehensive prior-art search or successfully indexed this paper.
