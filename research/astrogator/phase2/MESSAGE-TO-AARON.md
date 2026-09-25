# Draft message to Aaron — not sent

Hi Aaron,

I worked across all three directions and connected formal-query generation to the actual verifier, so we can evaluate that part of the proposed pipeline directly.

The main result is that a handbook derived from FQL's implementation and knowledge base recovers most verification behavior lost under the compact prompt. Across all 21 tasks and 2,238 supplied programs, 1,528 programs are decidable with the supplied queries. GPT-6's generated queries preserve 872–949 of those decisions with the compact guide and 1,525 with the handbook; Opus improves from 926 to 1,469. All three attempts are retained. This is reference-decision agreement, not a claim that every generated query captures intent.

There is also a concrete runtime failure explaining the risk: generated FQL saying “delete contents of directory at…” compiles to deleting the directory itself. A real corpus program is accepted against that query and removes the parent in both diagnostic fixtures. The supplied query and every handbook translation reject it.

The stronger judge and generated-test baselines are competitive on the four execution-tested tasks, so I don't think the resubmission should rely on the earlier small-model comparison. I included coverage, exact disagreement cases, and sensitivity to the correctness checks. The 70-task candidate catalog, strengthened benchmark checks, and permission prototype are supporting artifacts.

The research brief and main figure summarize the formalization intervention and its downstream effects. Could we review the intended FQL semantics, residual assumptions, and candidate additions, then decide which results should anchor the revised evaluation?

Darsh

<!-- Personalize before sending. Nothing has been sent. Review the final Python/context sensitivity tables alongside the main results. -->
