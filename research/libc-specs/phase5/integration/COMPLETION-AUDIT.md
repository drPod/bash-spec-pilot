> Final delivery closure (release212, audit213, catalog215): required work is complete at the documented research bounds. See [../FINAL-DELIVERY.md](../FINAL-DELIVERY.md). Historical pending-package statements below describe the frozen pre-release snapshot.

# Full-scope completion audit (integration view)

Integration-side index of original-plan blockers as of 2026-09-07, retained as a historical snapshot. Do not read present-tense claims in the numbered list as current.

**Current prototype.** Original proofs at documented scope accepted; not whole research-program completion. Shared manifest **30**; full30 `run20260908T213227Z` summary `165a63d40cdf862605142d368c61a057a3571e4ae9d29f6c81e1b95b2f347aee` (29 PASS + 1 experimental host-OCaml skip; container PASS). Root197 bounded source connection. Parser135, tokenizer117/133, raising151/147, Stateful55. Evaluation 23/90 scored. Packaging: [../FINAL-DELIVERY.md](../FINAL-DELIVERY.md).

Audit179’s bar against empirical-only Coq/Lean discharge is preserved. No NL parser or generic Coq importer. Full30 excludes source197 and supplementals. Historical `lost` is ghost; pending is memory.

| Later acceptance | Receipt / bound |
|---|---|
| Tokenizer identities + harness | root117; root133 (1,593 + 12 negatives) |
| Lean Bash-fragment parser | root135, 38 fixtures; TOKEN-grammar soundness; not character lexer / host-Bash / completeness / query-text |
| Raising/caught | root151 seven fields; root147 general-st same-post; no arbitrary-Related mandate (152) |
| Source connection | root197; `ClightRelayLink` src `cc02a88c4ec8ddadb2344d8df77c04bebbbad8390af3d70bac4aeb3542fdc467`; fresh196/203 |
| Supplemental | 188 + fresh198: 23 modules, 9 axioms, not full30 |

---

# Historical snapshot, 2026-09-07

Independently derived then from [../REQUIREMENTS.md](../REQUIREMENTS.md), phase3–5 records and the built pinned frontend. Effort estimates are rough single-person figures from that date.

## Priority 1 (then): obligations without which the central claim cannot be stated

1. **A Bash frontend.** Pinned `bash-verifier` parses Aaron’s specification language, not Bash. Issue #34 open. Phase3 grammar checked only for a hand AST. Options then: wait for #34, or an in-repo subset parser. Parser is a trusted boundary unless verified. **Later:** bounded Lean text parser at root135; still not full Bash.
2. **Spec-language to calculus lowering.** `Semant.analyze_expr = failwith "TODO"`. **Later:** adapter lowering in [../calculus-bytes/MAPPING.md](../calculus-bytes/MAPPING.md); Lean lowering identity at root77.
3. **C body theorem (VST `semax_body` for relay).** **Later:** accepted (`relay-body-coqc-16`).
4. **Coq/Lean alignment.** Choose Coq-final or Lean-final; shared executable oracle over the 962-case corpus. **Later:** no checked import; empirical 1,593; bounded Clight source connection 197.

## Priority 2 (then): fidelity

5. **Byte-bearing state.** Fixtures used a `string` stdout attribute. **Later:** [../calculus-bytes/README.md](../calculus-bytes/README.md) 2006/2006 then 2046/2046.
6. **Pinned frontend defects to report upstream:** suffixed integer literals crash the lexer; pretty-printer emits unparseable `0i64` and `raise X(args);`; `Semant.analyze_stmt` non-exhaustive.
7. **Interpreter transcription fidelity.** Link 7 was 12 records. **Later:** nested/while/try theorems in Lean transcription; OCaml source still unchecked.
8. **Nonvacuity for the shell-level theorem.** **Later:** Lean witnesses for supported scripts under stated premises.

## Priority 3 (then): evaluation and paper

9. **Frozen automation tasks.** Integration produced zero LLM attempts for the spec-text→calculus task. Broader evaluation program later completed at 23/90 scored — a different task.
10. **Second utility.** A purpose-built second relay does not count. Candidate: GNU coreutils v9.4 `simple_cat` (commit `9530a14420fc1a267e90d45e8a0d710c3668382d`, `src/cat.c` sha256 `f52880ce…6983`). Then-current `read_spec`/`write_spec` could not be reused unchanged. **Later:** GNU leaf bodies + head/wc with documented write-contract mismatch.
11. **Independent calibration** owned separately; transfer result must be cited. **Later:** negative UTF-8 result preserved.
12. **Manuscript.** **Later:** [../evaluation/DRAFT-PAPER.md](../evaluation/DRAFT-PAPER.md).

## Explicit non-claims after the 2026-09-07 integration work

- No Bash text was parsed by anything checked **in this directory at that date**.
- No theorem mentions the OCaml program; `CalculusFragment` is a transcription.
- Pinned commit modified in a private copy (five shims, two patches); upstream files byte-identical to the mirror.
- Artifacts were collaborative agent development, not a controlled generation trial. The earlier sentence “No LLM was involved” was false and is withdrawn.
- Session elapsed ~26 minutes (08:06:59–08:32:56 UTC, `process.json`/`exit.json`); REPORT.md “08:06Z–09:00Z” was a forward estimate.
- Assumption audits must cite `Print Assumptions` / `#print axioms` on the currently accepted file.
