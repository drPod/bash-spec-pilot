# Text literals (root103)

Kernel-check literal-to-character-list equalities used by later tokenizer work.

Root103 accepts only the three original literal-to-character-list equalities and their `toList`/length consequences. Source `8616210b`; nine exact audits (three literal equalities axiom-free). Fresh `genericTokenize` 1.982s, literal module 3.440s and audit 0.249s under shared lock / 3GiB. Source header was corrected before checking to remove false full-tokenizer and subsecond claims.

**Limitations (this receipt).** Six final text-to-token/AST identities remain unproved here; the module name does not imply their completion. Character-chunk gluing continues separately; no harness switch accepted at this review.

**Historical vs current.** Later root117 accepts the six full-export identities; harness133 accepts the CLI switch. Do not read root103 as current tokenizer completion.

Runtime receipt: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-text-literals-review-103/ROOT-REVIEW.json`.
