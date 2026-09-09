# Query AST compiler (root92)

Compile Lean query ASTs over status, cumulative counters, five root-list lengths, integer comparisons and Boolean operations into Nested gets/assignments/conditions.

Root92 independently accepted cp7 CalculusQuery, SHA256 `0162c7938bac5e1cd73c56dc1f12c6f813978c7ea6234f5f9dcce2b9e0906c59`. Fresh direct Lean: Lowering 3.022s, Query 2.500s, QueryExportLink 0.404s; 17 query audits use standard Lean axioms; exported mark identity is axiom-free. Universal witnesses cover `relay&&mark` and `relay||mark` under Related initial state, syntactic counter budget and action identities. `MarkSpec` is discharged for the actual exported mark body, independently linked to accepted `CalculusLowering.markBody` by `rfl`. The cp7 source comment cites stale Lowering hash `5a994b4b`; actual checked Lowering is `45a2bae4`, preserved unchanged.

This closes the bounded AST-to-calculus command/query proof **at this receipt**.

Not a query-text parser, exact-byte query language, general Bash frontend, OCaml-source theorem or cross-kernel bridge.

**Historical vs current.** “Full-text tokenizer and full artifact replay remain open” was true at root92. Later: tokenizer identities root117; harness133; full30 replay174; packaging [../../FINAL-DELIVERY.md](../../FINAL-DELIVERY.md).

Receipt: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-query-review-92/ROOT-REVIEW.json`.
