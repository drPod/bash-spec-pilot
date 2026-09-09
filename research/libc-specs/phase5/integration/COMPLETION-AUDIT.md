> Final delivery closure (release212, audit213, catalog215): all required work is complete at the documented research bounds. See [final delivery receipt](../FINAL-DELIVERY.md). Historical pending-package statements below describe the frozen pre-release snapshot.

# Full-scope completion audit (integration view)

**Current overlay (full30-174/183; audit179 historical empirical-only bar; root197 bounded source connection).** The numbered Priority list below is a
**historical 2026-09-07 snapshot** and is not current-status. Do not read present-tense claims
there as still true.

Current accepted bounds (root reviews, not worker reports): **all original proofs at documented
scope accepted**, not whole research-goal completion. Frozen full27 historical at root121
(26 PASS + 1 experimental host skip / container pass). **Current shared manifest 30.** Full30
replay174 terminal exit 0 (`run20260908T213227Z`, summary
`165a63d40cdf862605142d368c61a057a3571e4ae9d29f6c81e1b95b2f347aee`): 29 PASS + 1 experimental
host-OCaml skip, container PASS, fresh true, nofilter. Root183 accepted artifact replay;
independent177 passed; root receipt recheck passed. Full30 does **not** include source197 or
supplementals. Shared exception170 and shell173
accepted; private 162/164 no longer pending. Tokenizer identities117 + harness133
(universal copy equality, corrected CLI, 1,593 + 12 negatives). Parser135 (supported Lean
text parser, independent TOKEN-grammar soundness, Nested connector, 38 fixtures; **not**
character-lexer grammar / host-Bash equivalence / full Bash / completeness / query-text).
Raising151 actual raising/caught initialState exact status+seven fields; 147 general-st
same-post. Scope-audit-152: **no arbitrary-Related raising mandate**. Historical 131/138/146
are not active pending-proof claims. Audit108's original-scope parser gap is now bounded by parser135; do not invent
NL parser or Coq-importer obligations. Audit179's bar against empirical Coq/Lean agreement as
discharge is preserved (no narrowing). Root197 **accepts** generated `fRelay`→`BufferRelay`→
Nested initial/shared script relay atom under explicit TCB (clightgen / Python dump / reviewed
Lean Clight subset / libc contracts). **Not** CompCert `step*` / Vundef / full Bash.
Historical `lost` is ghost; current pending is memory. Independent195 of cp17; promoted
cp18/cp19/cp20 after root delta/hash review. `ClightRelayLink` src
`cc02a88c4ec8ddadb2344d8df77c04bebbbad8390af3d70bac4aeb3542fdc467`. Supplemental188 +
fresh198: 23 modules, 9 axioms, not full30. Fresh196 accepted203 (`run20260908T224120Z`, 18 modules, 18 axioms, 17 fixtures, summary `89527fb4b6a09dd7ba01cf1f26ab8d1e46372bc40b4fc014977e6314a9b1693d`); Claude200 original-requirement matrix terminal (no mandated proof gaps; 9 TCB boundaries). Goal is not packaging-only. Evaluation frozen (93 first-pass / 90 scored / 23 accepts; no new
trials). Paper206 reviewed/rendered (source b515b98b… HTML 0f8135f…); do not edit paper. Catalog205: Atlas **307** private, local **2379** nodes / **2436** edges.
Bounded proofs and accepted replays stand. Remaining delivery gate is package-202 archive build / extract / hash verify / final receipt catalog. No goal-complete declaration before tar verified. Research is not complete.

Historical snapshot begins here.

# Full-scope completion audit (integration view), 2026-09-07 (historical)

Independently derived from the ledger in `../REQUIREMENTS.md`, the phase3-5 records and the
built pinned frontend. Ordered by how much each item blocks the paper's central claim
("LLM-generated Bash is checked against C-source-as-specification by a proof kernel").
Effort is a rough single-person estimate; "blocked" names the concrete dependency.

## Priority 1: obligations without which the central claim cannot be stated

1. **A Bash frontend.** None exists in the pinned repository: `bash-verifier` parses Aaron's
   *specification language*, not Bash. Issue #34 "Bash to State Calculus Compiler" is open.
   The phase3 grammar (`;`, `&&`, `||` over calls) is checked only for a hand AST; today it can
   be produced from text by nobody. Options: (i) wait for #34; (ii) an in-repo Bash subset
   parser (POSIX shell grammar for lists/pipelines/simple commands, no expansion) emitting the
   phase3 `Command` type in JSON, validated against `bash -n` and against actual `bash`
   execution status on the phase3 30-context corpus. (ii) is 2-4 days and does not touch
   Aaron's code. Either way the parser is a trusted boundary unless verified.
2. **Spec-language to calculus lowering.** `Semant.analyze_expr = failwith "TODO"`; no
   `Calculus.Ast` is ever produced from text. Until upstream implements it, every calculus
   program is hand-built in OCaml (as in `sc_fixtures.ml`). Blocked on upstream (#26/#27/#32).
3. **The C body theorem (VST `semax_body` for the relay).** Owned by the relay worker. Without
   it the C side is Clight identity plus protocol lemmas.
4. **Coq/Lean alignment (link 4 of `PROOF-CHAIN.md`).** Choose Coq-final or Lean-final and
   implement the shared executable oracle over the existing 962-case corpus. 1-2 days.

## Priority 2: fidelity of the objects already in the chain

5. **Byte-bearing state in the calculus.** The fixtures use a `string` attribute for stdout.
   The phase3 handoff asked for a block-indexed element with capacity 32, initialized length
   and `list<u8>` contents plus NUL/255 round trips. The parser accepts `list::<u8>` types
   (fixture `byte_relay_plain.sc`) but nothing executes them. Requires either the upstream
   lowering or a hand-built calculus program plus a builtin module with byte lists. 1 day.
6. **Pinned frontend defects to report upstream** (author statements needed; do not fix in
   place): suffixed integer literals crash the lexer (`Invalid_argument`), the pretty-printer
   emits `0i64`-style literals and `raise X(args);`, both unparseable, so print/parse round
   trips fail for any program with integer literals; `Semant.analyze_stmt` non-exhaustive.
7. **Interpreter transcription fidelity.** Link 7 is 12 records. Add: `Raise`/`TryCatch`
   (the phase3 handoff's partial-effects path), nested elements, `While` with fuel, and a
   randomized comparison driver that generates calculus programs and compares OCaml vs Lean
   on thousands of cases. 1-2 days. Ideally replace by extraction of the OCaml interpreter's
   semantics, which is not available.
8. **Nonvacuity for the shell-level theorem.** Phase3 has reachability witnesses for the
   relay; the calculus encoding has none beyond the fixtures. Add a Lean witness that
   `run fixActDef 0 c s` is `some` for every fixture command (mechanical).

## Priority 3: evaluation and paper

9. **Frozen automation tasks.** The ledger requires frozen tasks, repeated attempts and
   manual-intervention accounting. The integration produced zero LLM attempts; all fixtures
   and proofs were written by the worker. Define tasks now: (a) given `relay.c` and the
   VST contracts, produce the body proof; (b) given a shell command in the phase3 grammar and
   primitive contracts, produce the `Exec` derivation and query proof; (c) given a spec-language
   file, produce the calculus program. Record pass@k per task with the pinned GPT-5.5 snapshot.
10. **Second utility.** Reuse of contracts across distinct utilities is unmet. *Corrected
    2026-09-07:* a second purpose-built `cat`-like relay written for this project does NOT
    count as a distinct real utility; the ledger requires actual frozen upstream code. The
    candidate under independent assessment (Pi review `utility-reuse-target-1`, exit 0) is GNU
    coreutils v9.4 `simple_cat` (commit `9530a14420fc1a267e90d45e8a0d710c3668382d`,
    `src/cat.c` sha256 `f52880ce…6983`, gnulib `safe_read`/`full_write`). That review found
    the current `read_spec`/`write_spec` cannot be reused unchanged (fixed fd 0/1, count 32,
    signed `long`, no EINTR retry, no `full_write` completion): a generalization of the leaf
    libc contracts must precede any reuse claim. `wc -l` in `../../example` is a C-as-spec
    example, not upstream utility code either.
11. **Independent calibration** is owned by the calibration worker; its transfer result must
    be cited, not re-derived.
12. **Manuscript.** No draft exists. Required sections with evidence today: problem and prior
    art (`../../04_io_prior_art.md`, phase3 PAPER-CRITERIA), the two-kernel arrangement
    (`PROOF-CHAIN.md`), relay case study (phases 2-5), frontend integration (this directory),
    threats to validity (every trusted boundary above). Missing: any evaluation table.
    The MLSys end-of-October date seen in Slack is unverified against the CFP.

## Explicit non-claims after this work

- No Bash text was parsed by anything checked.
- No theorem mentions the OCaml program; `CalculusFragment` is a transcription.
- The pinned commit was modified in a private copy to build (five shims, two patches); the
  upstream files are byte-identical to the mirror and no upstream change is proposed here.
- Authorship (corrected 2026-09-07 by the shell-bridge worker): every artifact in this
  directory was produced by a Claude CLI worker under human/orchestrator direction, i.e.
  collaborative agent development. What did *not* happen is a controlled generation trial:
  no frozen task, no repeated autonomous attempts, no pass@k accounting, no independent
  criteria. The earlier sentence "No LLM was involved in producing any artifact in this
  directory" was false and is withdrawn.
- Session accounting (source of truth `process.json`/`exit.json` of the integration job):
  started 08:06:59 UTC, exited 08:32:56 UTC with exit code 0, i.e. about 26 minutes of
  actual elapsed session. The "08:06Z-09:00Z" header of the worker's REPORT.md was a
  forward estimate, not the elapsed time.
- Assumption audits must be current: any claim that a Coq or Lean theorem is closed must be
  backed by a `Print Assumptions` (Coq) or `#print axioms` (Lean) run on the *currently
  accepted* file, cited by receipt name. Stale audits of an earlier revision do not count.
