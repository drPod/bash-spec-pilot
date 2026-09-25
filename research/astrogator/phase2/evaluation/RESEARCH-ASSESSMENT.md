# What the stronger evaluation contributes

The main result is an end-to-end formalization intervention: compiler-grounded guidance improves query compilation and preserves substantially more supplied-query decisions over all 21 tasks and 2,238 programs. The paired experiment retains all repetitions and separates decision preservation from correctness. A concrete contents-versus-directory deletion counterexample demonstrates why a valid generated query can still verify the wrong behavior. See [the complete findings](../EVALUATION-FINDINGS.md) and [main figure](figures-paper/paper-contribution.png).

The four-task execution study then asks what verification contributes relative to strong judges and generated checks. It exposes complementary errors, coverage gaps, and oracle-dependent rankings rather than supporting unconditional superiority.

All verifier counts here use the pinned upstream default permission semantics. The experimental constant-mode guard is evaluated separately under `phase2/permission_semantics`.

## Findings established without frontier-model results

1. **Standard syntax checking leaves most observed defects untouched.** On the complete 422-program slice, native Ansible syntax checking rejects six locally failing programs and accepts the other 133. All 283 local passes also pass syntax checking. In the original execution study, 75 programs have an execution error and 64 fail only behavioral checks. Base Astrogator rejects 51 of the 64 behavior-only failures; configured heuristics reject 60. This supports investigating semantic value beyond ordinary syntax checks, while retaining the model and oracle qualifications.

2. **Unavailable programs are not a random remainder.** All 74 verifier-unavailable programs fail locally. Base verification rejects 56 of all 139 failures, not 56 of an implicitly complete population. A deployment that blocks unsupported programs prevents their acceptance, but this is a policy benefit rather than evidence of a proof of incorrectness. The distinction changes interpretation of decided-only agreement.

3. **Five apparent heuristic false alarms have an experimentally confirmed scope cause.** Restricting only heuristic metadata to Debian rows flips exactly five www-data programs from rejection to acceptance. All other outcomes remain the same across 422 actual-verifier runs. The verifier's OS branches were not changed. This confirms a metadata-scope explanation; it does not prove a general reduction in verifier false positives.

4. **The original password oracle admitted malformed account data.** The observed granite/p10/4 output has eleven shadow fields, with a hash string in an aging field, yet passed a marker-prefix-only check. The strengthened account-integrity interpretation rejects it. All 106 a17 processed programs were rerun, with actual hash verification before execution. The real hash alone changes no labels; the structural requirement changes exactly this one program. These refinements were motivated by observed weaknesses, so any subsequent perfect agreement is not fresh confirmatory evidence.

5. **Repeated structures change the pooled picture.** Removing only inserted top-level play names and canonicalizing YAML conservatively leaves 233 structures from 422 programs. Giving each structure equal total weight changes base accepted-failure risk from 3.1% to 6.5%, and the small judge's from 32.3% to 44.1%, under the original checks. The repetition-heavy easy directory task contributes disproportionately to program-weighted agreement. This does not make the four-task slice representative, but it exposes a concrete weighting sensitivity.

6. **A small string-interpretation choice changes the apparent errors.** Rerunning all 99 a06 programs and permitting one final newline only when creating the requested file changes eight program labels from failure to pass. Seven of those are verifier rejections and one is unsupported. Thus the tolerant interpretation creates seven apparent verifier false alarms, while the exact-byte interpretation treats those rejections as correct. Neither choice should be silently declared gold; this is direct evidence that natural-language intent, FQL string semantics, and the executable oracle must agree.

## How this connects to the paper

The evaluation should state a contract for each task: intended behavior, modeled operating systems, admissible initial states, execution environment, oracle interpretation, and treatment of residuals. Query translation and verification can then be evaluated against that contract at separate stages. Otherwise a model can be blamed for an oracle ambiguity, a verifier can be blamed for checking broader environments, and a parser rejection can be credited as semantic reasoning.

The complete frontier comparison uses the full 422-program cohort and explicit abstentions. GPT rejects 62 of 64 original behavior-only failures, compared with base verification51 and configured heuristics60. Under strict labels the verifier uniquely rejects one GPT-accepted failure, the malformed shadow entry; three other GPT-accepted failures are verifier-unavailable, not detected. A retrospective Debian-heuristic/GPT conjunction accepts282passes, rejects137failures, and leaves3failures unavailable, with no observed accepted failures. This is a development-suite policy, not a validated risk guarantee.

Generated DSL checks are compared on a common420-program cohort, excluding the same2unresolved programs from every method. All repetitions and label sensitivities remain separate. The frontier comparison belongs alongside these controls, using the full common cohort and explicit abstentions. Its final results are in FRONTIER-FULL-COMPARISON.md; per-task figures, paired discordance, generator-cluster sensitivity, and exhaustive disagreement reasons accompany it. No conclusion about strong-model superiority should be drawn from incomplete files or from the earlier small-model judge.

## Claims that remain unsupported

- General accuracy over Ansible workloads: only four selected tasks have these execution labels.
- Unconditional correctness from VERIFIED: printed assumptions and effects have not been independently discharged.
- Human-approved gold specifications or label interpretations: those need reviewer input.
- Matched-cost or matched-token superiority over frontier judges: provider inference budgets differ.
- Full login-security behavior from password-hash checks: PAM, SSH configuration, and alternative authentication are outside this fixture.

The most useful discussion with Aaron is whether this contract-oriented evaluation, combined with the new query-quality experiments, strengthens the central paper claim. It should not be presented as a collection of favorable benchmark percentages.
