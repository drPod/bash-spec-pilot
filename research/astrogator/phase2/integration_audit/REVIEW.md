# Independent integration audit

This is an implementation/provenance review of the phase2 integration harness, not an independent scientific validation of benchmark intent. Inference and execution were still running during the first audit. Pending predictions are not failed predictions, and intermediate counts are not final results.

Reviewed: `frontier.py`, `full_judge.py`, both generated-test runners and container cases, `summarize_tests.py`, the `finish*.py` orchestration scripts, `settle_transport.py`, `python_generation.py`, the underlying `container_case.generated_test`, and `evaluation/frontier_comparison.py` / `analyze.stats`.

## Findings and disposition

1. **Frozen source/specification validation was missing from generated-test summarization.** Candidate hashes were checked, but mutable runner/check files could otherwise be summarized against old records without a provenance assertion. Reported immediately; parent added source and generated-spec hash verification to `summarize_tests.py`. Inference comparisons already enforce frozen source, task, prompt and candidate hashes.
2. **The prospective declarative-test freeze omitted manifest and reference YAML hashes.** Active runner left unchanged so its frozen source remains valid. `phase1-integrity-sidecar.json` independently verifies the current manifest and all four reference YAML files against the exact previously delivered ZIP (SHA256 `124d50ed06f45ef78fa9c1c73a616ab6acc2e88cc673480e4bfd812d879d8387`). References also match phase1 frozen execution hashes. This is a retrospective integrity check, not a claim of phase2 preregistration. The not-yet-started Python runner now includes these hashes prospectively.
3. **Python outer wall timeout was shorter than its possible bounded inner work.** 45 seconds for the playbook plus four 10-second tests can exceed the original 75-second container cap. Reported before Python execution; parent increased its cap to 110 seconds and recorded explicit limits. Existing declarative runs retain their original cap and report infrastructure/timeouts as unavailable.
4. **Python tests can theoretically affect later tests and the oracle.** They run sequentially on the same state, before the independent oracle. The AST screen blocks many obvious mutations but is not a complete noninterference guarantee (for example, aliasing or unsupported write methods can bypass name-based checks). No generated Python outputs existed at the initial audit. Review actual generated programs before finalizing the claim that oracle observations are unaffected; the report should call the screen a declared restriction rather than a proven sandbox. Docker bounds host exposure but does not establish within-container read-only behavior.
5. **Provider identity has asymmetric evidence.** Successful Claude records inspected report `claude-opus-5-5` in `modelUsage`. GPT records request `gpt-6-astra` in saved CLI arguments; their JSON event stream does not independently attest the server-resolved model revision. State these identities at that precision.
6. **Retry provenance needs both policies described.** The first pass allows one empty-answer infrastructure/transport retry; a later serial-recovery amendment can add one recovery attempt for explicit client-startup resource failures. Archives retain previous records and serial recovery hashes. Do not summarize the complete experiment as “at most one retry” without explaining the amendment. No retry of a recorded answer was found in the snapshot audit.

## Sound handling observed

- Unknown/invalid/uncertain model outputs remain unavailable; they are not converted into rejections.
- Missing generated-test states and timeouts remain unavailable. A failing independent oracle is not borrowed as a generated-test verdict.
- Runtime playbook failure counts as rejection under an explicit execution-plus-tests policy. This must remain separate from semantic assertions detecting a successfully executed bad program.
- Known-good reference gates are applied after generation and disclosed as additional information. Two repetitions are reported individually, without choosing the better one on candidates.
- Strong-model full-cohort metrics are suppressed until all selected prediction records are terminal. Terminal infrastructure failure is an abstention, not a successful inference.
- FQL target IDs are excluded from demonstrations; same-family demonstrations are explicitly allowed. This is a development-suite experiment, not unseen-task generalization.
- Revised fixture/oracle interpretations are reported separately. Passing executable checks remains bounded evidence, not universal correctness.
- Model calls receive task descriptions and public states, without candidate labels or gold-oracle source. Candidate code is included only for the judge. Reference controls are used only after test generation.

## Repeatable final check

Run `python3 research/astrogator/phase2/integration_audit/audit_snapshot.py` after all writers finish. It validates frozen inference source digests, exact reconstructed prompts, task identity, requested/provider model fields, retry archive identity, generated-check source hashes, candidate hashes, reference hashes and unique execution IDs. The JSON records pending counts and explicit issues. An empty issue list is integrity evidence, not a proof of scientific validity or semantic correctness.

## Additional client-isolation finding

The coordinating agent found orphaned CLI/plugin-hook descendants in the research unit. Saved Claude stderr independently contains SessionEnd hook diagnostics (`claude-hook-audit.json`). Thus `--tools ''` and strict empty MCP configuration disabled model-facing tools but did **not** disable user plugin hooks. An external working directory and absence of detected tool use do not establish an empty client context. No target-label or oracle-source access by the model is demonstrated by these diagnostics, but the narrower isolation claim must replace “fully isolated/empty-context CLI.” Future clean-client replication is a separate condition; frozen transport was not silently changed. The root's cleanup ledger records resource recovery confined to orphaned research-unit descendants.

## Completed generated-Python source inspection

All 16 observed sources were manually inspected and hashed in `python-source-review.json`. None reads the repository/oracle/playbook source or mutates filesystem/account state. This supports noninterference for these particular programs without upgrading the generic screen to a proof. Three Opus outputs have explicit static-contract restrictions: a06-r0 uses harmless stdout/stderr `.write`, and both a17 outputs use variable arguments in getent lists. These abstentions must be attributed to the declared harness restrictions, not automatically to failed semantic reasoning. The a06 public prompt explicitly supplies `existing content`; GPT's exact-byte comparison is therefore not hidden fixture leakage. Opus a06 tests choose more tolerant baseline semantics and weaker preservation predicates; compare with the stated label sensitivities.
