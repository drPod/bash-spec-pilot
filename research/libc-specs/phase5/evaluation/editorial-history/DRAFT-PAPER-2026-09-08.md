# Checked utility summaries and bounded script/query compilation

Working manuscript, 2026-09-08. The formal results below are checked at their documented
bounds. A 30-entry artifact replay is accepted at that replay's scope. A later supplemental
Lean connector, compiled against the exported mark body, is accepted separately and is not
part of the 30-entry set. A further bounded source connection is accepted separately: execution of the generated
Clight relay in the reviewed Lean subset model is kernel-proved equal in status and observables to `BufferRelay.execute`,
then connected to actual Nested relay and the supported script relay atom. That connection is
not an entry of the 30-entry set. Trusted computing base for the source link is explicit:
CompCert `clightgen`, a syntax-directed Python dump, a reviewed Lean transcription of the used
Clight/Cop subset, and scheduled libc contracts. It is not CompCert `step*` preservation, not a
`Vundef` theorem, not a proof of full Bash, and not a proof of OCaml frontend source. This draft
reports a bounded development; it does not claim that host C execution or the overall research
goal is complete. Final packaging and a closing research audit remain pending.

## Abstract

A shell script can produce plausible output while mishandling partial I/O, exit status or
state shared between commands. We investigate a verification pipeline that treats fixed C
utility implementations as the source specification, makes library contracts explicit, and
checks compositional script/query obligations in a proof kernel. The development contains a
Coq/VST chain for a byte relay and reusable GNU utility bodies, additional head_bytes and
wc_lines case studies, and a Lean proof of bounded command and query compilation into the
actual nested-state calculus interpreter. A bounded Lean connection then relates the generated
Clight relay (`runFunc fRelay`) to `BufferRelay.execute`, then to Nested/`relay` and the
supported script atom used by the text/query theorems, under explicit action-definition,
headroom and fuel premises and a 32-byte buffer and finite read/write schedules. The Lean composition
preserves input, delivered and lost bytes, residual read/write schedules and cumulative
counters; a syntactic command budget derives the integer headroom needed across calls. A
separate frozen proof-regeneration study records 22 acceptances from 90 original scheduled
calls, or 23/90 when three checker-collision calls are replaced by their three recorded
makeups. These results describe model/harness combinations on held-out Lean proofs, not
general Bash-generation accuracy. The C frontend, Python dump, reviewed Clight/Cop subset,
scheduled library contracts, executable OCaml translations and remaining cross-kernel
boundaries remain explicit trust.

## 1. Problem and scope

The intended application is checking whether an LLM-generated script satisfies a user query
against fixed utility behavior. Proof generation should not be allowed to repair its own task
by weakening the specification, changing the utility or replacing the checker. Our experiments
therefore freeze theorem statements, structural definitions and acceptance gates independently
of generated proof text. Utility verification and proof-regeneration evaluation are separate:
acceptance of a Lean proof-regeneration task supplies no new evidence about a C body.

Short-circuit control and partial I/O make stdout alone insufficient. In the supported example
`relay && mark`, successful relay execution delivers the initial input followed by the marker;
a failed relay preserves its failure status and partial effects without running mark. In
`relay || mark`, a failed relay is followed by mark, so the combined command succeeds. Read
and write schedules must be consumed across calls rather than reset for each command. Even a
relay called on empty input consumes an EOF read, so an input-length bound alone cannot bound
cumulative counters in a multi-command script.

We make three concrete contributions within the stated fragment: checked utility/protocol
proofs and contract reuse boundaries; an actual-calculus script/query compilation theorem
with shared state and derived resource premises, together with a bounded generated-Clight
connection into that same atom; and an auditable, frozen proof-regeneration diagnostic.
Novelty relative to prior work is not established by these implementation results.

## 2. Formal development and trust boundaries

The C side uses CompCert 3.15 generated Clight and Coq 8.20.1/VST 2.15. It includes relay body and
wrapper proofs, dry safety with its explicit Jsub premise, and separate Jsub-free theorems for
permitted scheduled returned outcomes. These distinct results must not be collapsed into a
claim about every host OS execution. Utility13/14 connect reusable I/O contracts and memory
worlds through juicy/dry PRE and dry POST transport under explicit fresh-errno and memory
coherence assumptions. The source-to-Clight frontend and imported external operations remain
trusted. See the [proof chain](../integration/PROOF-CHAIN.md).

The Lean side uses pinned Lean 4.31.0. CalculusNested defines the supported nested state,
control and checked-integer operations. Whole-body relay proofs are strengthened by exact
output, residual schedules and arbitrary related shared state. General type preservation and
a sound checker establish typings for nine exported bodies, but preservation explicitly
permits failure. Actual range/assert guard proofs identify facts obtained when guards pass;
read_block's range check occurs after bookkeeping updates. They do not establish general
nonfailure from types alone.

A pinned OCaml parser produces the fixture AST. A preserved S-expression export and
deterministic generator yield a Lean constructor term that is kernel-equal to the AST used
by the checked Lean lowering, which yields the nine exported bodies. This removes the
hand-transcription uncertainty for that input, while retaining the parser, printer and
generator as trusted executables. It is not a proof of OCaml lower.ml or interp.ml source.
The 1,593 saved same-input canonical comparisons are empirical agreement. All six full-export
text-to-token and text-to-AST identities are kernel checked (root117, 16 fresh modules).
Root133 accepts universal copied tokenizer equality and the actual corrected CLI drivers on
those 1,593 comparisons plus 12 negative checks (`root-tokenizer-harness-review-133/ROOT-REVIEW.json`).

### Bounded generated-Clight source connection

Root197 accepts checkpoints cp18/19/20 after an independent cp17 audit (195) and root review
of the final sources, logs and compiled outputs. Fresh replay of that package
(`20260908T224120Z`, root203) compiled 18 modules, printed 18 named axiom outputs (standard
Lean axioms only) and recorded 17 generator fixtures; summary SHA256
`89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`. The contribution is the
actual chain `runFunc fRelay` → `BufferRelay.execute` → Nested/`relay` and the script grammar
atom `CalculusCommands.atomStep .relay` used by the accepted command/query and supported-text
query theorems. Action-body identities, input-length headroom and explicit fuel remain
premises. All headroom, fuel and action-definition statements are for finite schedules under
a 32-byte memory/count cap. Current pending bytes are the live buffer suffix
(`[off, n)` on status 2); historical `lost` on the Nested/script side is a ghost accumulation,
not C RAM. Trusted: CompCert `clightgen`, the Python dump, the reviewed Lean Clight/Cop subset,
and scheduled libc contracts. Not claimed: CompCert small-step preservation, uninitialized
memory/`Vundef`, full Bash, or OCaml source. This package is supplemental to the accepted
30-entry replay. See [CLIGHT-SOURCE-ACCEPTANCE](../integration/lean/CLIGHT-SOURCE-ACCEPTANCE.md)
and [ClightRelayLink](../integration/lean/ClightRelayLink.lean).

### Exceptions and exact state correspondence

The raising and caught relay implementations now have checked correspondence to ordinary
relay through their actual prologue, loops and entry code. A read failure becomes
`ReadError(-1)` in the raising version; the catch handler restores return status 1 while
preserving the same post-state. On the standard initial state, the final theorems match the
reference return status and all seven root fields: remaining input, delivered and lost bytes,
residual read and write schedules, and both call counters. Action-body identities, input-length
headroom and explicit fuel remain premises. Root151 freshly compiled the implementation proof
and audited 28 named assumption outputs; the final results use standard Lean axioms only.
See [CalculusRelayRaising](../integration/lean/CalculusRelayRaising.lean).

### Actual-calculus command and query theorem

Commands are ASTs built from relay, mark, sequence, conjunction and disjunction. `encodeCmd`
emits actual CalculusNested action/sequence/condition statements. Its theorem does not assume
an opaque simulation relation: the relay primitive is discharged by the accepted shared-state
body theorem and mark is proved against its actual statement body. An independently checked,
axiom-free identity links the query proof's mark body to the fixture's exported mark body.
A later supplemental connector uses that exported mark body in the supported text/query
composition; it was compiled and audited separately (nine named axiom outputs, standard Lean
axioms only) and is not an entry of the 30-entry replay. Fresh replay of that supplemental
package (`20260908T223418Z`, root198) compiled 23 modules with those nine axiom prints.

Let a command contain at most b syntactic relay calls and let initial remaining input length
be at most L. The initial budget requires the current read counter plus b(L+1), and write
counter plus bL, to fit the supported integer maximum, with the corresponding lower bounds.
The proof derives the remaining budget after each call, including short-circuit branches.
Fuel is a sufficient bound derived from command/query structure and L, rather than a
hypothesis that every individual call happens to succeed.

The query AST reads status, both cumulative counters and lengths of the five state lists. It
supports integer constants, comparisons and Boolean connectives. Compilation emits real
state reads, assignments and short-circuit conditions. For every related initial state with
the budget and the explicit action-body identities, the combined encoded command and compiled
query reaches the exact resulting world and computes the query's specified Boolean value.
[CalculusCommands](../integration/lean/CalculusCommands.lean) and
[CalculusQuery](../integration/lean/CalculusQuery.lean) contain the theorems; root87/92
independently recompiled and audited them.

A checked example asks whether successful `relay && mark` leaves a nonempty delivered list;
relay alone has a counterexample on the empty initial world. Another checks that
`relay || mark` returns status 0. The separate command theorem also states exact delivered-byte
effects. Exact-byte expressions are not part of the compiled query AST, and the nonempty-list
query does not identify a particular marker byte. Query inputs are Lean AST data, not a
verified natural-language or query-text parser; that parser was never an original-scope mandate
(audit108 L2). Connecting supported Bash text to `encodeCmd` was a real original-scope gap
(audit108 L1). Root135 now bounds that gap: a supported Lean text parser, independent TOKEN-grammar
soundness, and the Nested command/query connector under explicit parse-success, action-definition,
Related and Budget premises, with 38/38 fixtures (`root-shell-parser-review-135/ROOT-REVIEW.json`).
That review does not claim an independent character-level lexer grammar, host-Bash semantic
equivalence, full Bash, completeness, or a query-text parser. Pipes/redirections are established separately
in the bounded Coq shell chain, not by this command encoder. No Coq-to-Lean proof import joins
the two chains. Alignment of GNU/VST utility bodies other than the bounded generated-Clight
relay link remains empirical. The original C-as-spec obligation is bounded for this relay
fragment under the stated TCB; it is not discharged for host execution, other utilities, or
CompCert small-step Clight.

### Additional case studies and calibration

The GNU utility development contains five body proofs and four linked VSU components under
their stated contracts. The additional head_bytes and wc_lines bodies and entry wrappers
have checked common-Gprog linkage. Both reuse SafeRead. head_bytes needs a distinct buffered
stdio XWrite contract; describing it as FullWrite reuse would be incorrect. wc_lines uses
its read/error/search contracts and output pointers, not a write routine. These are bounded
function and wrapper results, not proofs of whole GNU command-line programs.

The separate UTF-8 calibration checked an independent Unicode 16 table specification and
compared 1,190,417 finite cases against the frozen C decoder with sanitizers. Its bounded stop
rule was reached without a VST C-conformance body proof or caller proof. This is a completed
negative backend calibration, not evidence that testing established C conformance. See
[calibration results](../calibration/RESULTS.md).

## 3. Proof-regeneration experiments

The earlier diagnostic used three previously proved phase2/phase3 theorems, two helper
conditions and two fresh-context attempts per cell with one recorded Grok/Pi combination:
12 calls, seven accepted. The partial-error helper ablation was ineffective because its key
contract remained available in both conditions. These observations motivated a separate
expanded study; the two studies are not pooled.

The expanded frozen study used three nested-state frame/preservation theorems, two helper
conditions, three recorded model/harness combinations and five attempts per cell, giving 90
scheduled calls. Model calls were fresh-context and first-pass calls had no compiler-feedback
iteration. Acceptance checked frozen input identity, prohibited shortcuts, compiled the proof,
restricted printed axioms and compared the theorem's type against the frozen expected type.
The source version is preserved in an immutable archive; later proof development does not
change these tasks. The [protocol](../evaluation-expanded/protocol.json) records controls,
wall budgets and harness settings.

Model and harness are confounded: Grok used Pi, while both Claude labels used the Claude CLI.
The tasks came from the same research program and only five attempts occur in each cell.
Deleting a helper invalidates the original proof but cannot rule out alternative proofs.
These constraints prevent interpreting the observations as a general model ranking or a
causal estimate of helper reuse.

## 4. Measured results and accounting

The immutable ledger contains 90 original scheduled calls and three first-pass makeups. Three
original calls produced model responses but collided with stale checker directories. Counting
those as nonaccepts yields 22/90. Replacing them with their recorded makeups yields 23/90, with
61 build failures and six timeout/no-code-block outcomes. Both denominators are disclosed;
93 is the total number of first-pass calls, not a single scored 90-cell matrix.

| Recorded model/harness | Scored attempts | Accepted |
|---|---:|---:|
| Claude Fable / Claude CLI |30|18|
| Claude Sonnet / Claude CLI |30|2|
| Grok 4.6 / Pi |30|3|

All seven accepted helper-deleted proofs came from the Fable combination. The helper
manipulation was therefore not a hard barrier to successful proof regeneration. Three
assisted attempt records used six actual calls, all rejected, exceeding the protocol's
planned three calls; this deviation is retained rather than retroactively corrected. The
separate three-run agent-assisted collaborative baseline had one accepted proof and two
failures. It is not a human baseline and is not directly comparable to first-pass trials.

Root98 independently re-tallied the original/makeup/assisted ledger without generating new
submissions. The repository now contains the [corrected report](../evaluation-expanded/REPORT.md),
[results](../evaluation-expanded/RESULTS-CORRECTED.json) and
[accounting hashes](../evaluation-expanded/REPORT-ACCOUNTING.json). The old aggregate summary
mixes attempt classes and is not a first-pass denominator.

## 5. Interpretation, prior work and remaining limits

The evidence supports a bounded formal-development result and a small automation diagnostic.
It does not establish that models reliably generate correct user-intended Bash scripts,
that all utility contracts are adequate, or that the complete host execution is verified.
The library boundary, C frontend, Python dump, reviewed Clight/Cop subset, OCaml executable
translations, model-to-host correspondence and remaining cross-kernel alignment remain visible.
The compiled query fragment and command grammar must be stated whenever the script/query
theorem is cited.

The repository's [I/O prior-art review](../../04_io_prior_art.md) and
[paper criteria](../../phase3/PAPER-CRITERIA.md) identify compositional functional I/O
verification, C-to-interaction-tree refinement, executable shell semantics and C lifting as
relevant prior work. These works already establish I/O specification and the use of C source in formal reasoning. Its prospective contribution concerns composition and
checker discipline under explicit boundaries; a novelty claim still requires comparison
against those primary works.

The current 30-entry artifact replay (`20260908T213227Z`, summary
`165a63d40cdf862605142d368c61a057a3571e4ae9d29f6c81e1b95b2f347aee`) was run fresh, without
an entry filter. Independent receipt audit and root review accept 29 passing entries and one
experimental host-OCaml skip whose matching pinned-container check passed (root183). That
replay is an artifact-completeness result at its documented scope. It does not include the
supplemental mark connector or the Clight source-connection package. The earlier frozen
27-entry replay (root106, accepted root121) remains a historical record: 26 passing entries
and the same experimental host skip/container pass, covering the command/query/guard archive
but not later tokenizer, parser or exception work. Tokenizer, shell-text and exception
packages, including their shared integration, are included in the accepted 30-entry set.

## 6. Reproducibility and open work

The [requirements ledger](../REQUIREMENTS.md) and
[completion audit](../COMPLETION-AUDIT.md) retain the original scope and link each accepted
result to source/checker receipts. A proof is accepted after checking its exact source,
terminal compiler result and named assumption audit. Replay entries additionally record
source, log and compiled-output hashes. Frozen evaluation inputs and older proof snapshots
remain distinct from live development files. Caching is disabled for the artifact replay.

| Workstream | Accepted scope and remaining work |
|---|---|
| Bash-subset text to actual calculus | Original-scope audit108 gap is now bounded by parser135 (supported text parser, TOKEN-grammar soundness, Nested connector, 38 fixtures). Limits: no independent character-level lexer grammar, host-Bash semantic equivalence, full Bash/completeness or query-text claim. Natural-language parsers and a generic Coq importer are outside this fragment. The Coq parser is a separate checked development. |
| Full exported text parsing | Six identities accepted at root117; fail-closed harness and saved 1,593 + 12 negatives accepted at root133. |
| Exception behavior | Root151 accepts actual raising/caught entry correspondence and exact status plus seven root fields on the standard initial state. Explicit action definitions, fuel and counter headroom remain premises. The final proof uses the actual prologue and does not assume the older conditional `hwrap` lemma. The 16-module exception archive and its shared integration are included in the accepted 30-entry replay. |
| Current artifact | The 30-entry replay `20260908T213227Z` is accepted (root183): 29 PASS and one experimental host-OCaml skip, with the matching container check PASS, fresh and unfiltered. The historical 27-entry replay remains on record with 26 PASS and the same skip/container pair. The supplemental exported-mark text/query connector is accepted on its own compile and axiom audit (root188; fresh 191/198, 23 modules, nine named outputs) and is not a 30-entry item. |
| Source-to-calculus connection | Original empirical-only status is superseded for the relay fragment by a bounded kernel connection (root197; fresh 196/203, 18 modules, 18 axiom prints, 17 generator fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`). Chain: `runFunc fRelay` → `BufferRelay.execute` → Nested/`relay` atom and supported text/query. TCB: `clightgen`, Python dump, reviewed Lean Clight/Cop subset, scheduled libc contracts. Premises: action defs, headroom, fuel; cap 32; pending = current buffer suffix; prior lost is ghost. Not CompCert `step*`, not `Vundef`, not full Bash, not OCaml source. Separate from full30. Final package/audit pending. |
| Final research record | Trusted frontends, dump, subset transcription, external operations and remaining cross-kernel boundaries are stated with the receipts above. The manuscript remains a research draft; overall goal-complete and closed TCB claims are not made. |

The bounded UTF-8 calibration and expanded proof-regeneration experiment are closed under
their recorded protocols. The GNU head_bytes and wc_lines body/wrapper case-study request is
met at the stated bounded scope; whole GNU command-line programs and additional invented
wrapper obligations are not implied by that result.

Atlas and OpenScience catalog the accepted milestones and provenance. They are organizational
records, not substitutes for source files or checker receipts. The previously missing hosted
research branch and paper remain a separate recovery limitation documented in the organization
record; catalog text is not an attachment or a recovered Git commit.
