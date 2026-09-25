# Astrogator resubmission research: second phase

This phase investigates whether the specification, Ansible semantics, execution checks, and evaluation environment agree. It builds on the 70-task candidate suite and original 2,238-program corpus reconstruction. It is a research artifact for review, not a claim that all candidate tasks or proposed language semantics have been independently approved.

Start with [the paper-level contribution](PAPER-ADVANCEMENT.md), then [the research brief](RESEARCH-BRIEF.md). The [Aaron message](MESSAGE-TO-AARON.md) is an unsent draft. The [meeting guide](MEETING-GUIDE.md) explains the main findings and questions.

## Evidence map

| Question | Reviewable evidence |
|---|---|
| Does generated FQL preserve the verifier's behavior? | [End-to-end experiment](end_to_end/README.md) |
| Do expanded benchmark checks reject plausible wrong programs? | [Oracle audit and repaired checks](benchmark_audit/README.md), [second independent-review response](benchmark_audit/REVIEW-RESPONSE-V3.md) |
| Does a plausible formal query capture every requirement? | [Adequacy study, counterexamples, and code-generation patch](adequacy/README.md) |
| Can the compiler reject silently discarded deletion descriptors? | [Description guard and 273-query compatibility replay](description_guard/README.md) |
| Can permission representations be reconciled safely? | [Opt-in normalizer, supported subset, differential tests, corpus coverage cost](permission_semantics/README.md) |
| Can a model translate requests using the actual FQL interface? | [Source-handbook intervention](translation_method/README.md), [paired translation results](integration/TRANSLATION.md) |
| How do stronger judges and generated tests compare? | [Full frontier comparison](evaluation/FRONTIER-FULL-COMPARISON.md), [declarative checks](integration/generated-tests/RESULTS.md), [Python tests](integration/python-tests/RESULTS.md) |
| How sensitive are results to checks, duplication, or environment? | [Evaluation analysis](evaluation/EVALUATION.md), [oracle sensitivity](evaluation/ORACLE-SENSITIVITY.md), [additional baselines](evaluation/ADDITIONAL-BASELINES.md) |
| Were inputs, retries, and outputs tracked? | [Final integration audit](integration_audit/AUDIT-FINAL.md), [independent Opus review](independent_review/OPUS-REVIEW.md), [second review](independent_review/OPUS-REVIEW-V2.md) |

All scheduled cohorts have terminal records. Four Python-test programs and two different declarative-test programs have unresolved execution labels; the joint test comparison uses the 416-program intersection. Reports distinguish terminal completeness from usable labels. Raw errors and superseded patch versions are retained. Original benchmark and corpus files are not replaced by the proposed patches.
