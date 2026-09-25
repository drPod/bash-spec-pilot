# Forall: related tooling to revisit

Added 2026-09-25 at Darsh's request; separate from the current Astrogator resubmission experiments.

[Forall (Astrio)](https://github.com/astrio-labs/forall) describes a coding-agent workflow that connects requirements, generated code, contracts, and verification evidence. Its README distinguishes four evidence levels: specification tracking, property testing, written contracts, and discharged proofs. It offers a CLI and a hosted verification MCP interface, with language-dependent capabilities. These are the project's descriptions, not results we have independently reproduced. [Source: repository README](https://github.com/astrio-labs/forall#readme), accessed 2026-09-25.

**Relevance to our earlier Lean/Bash and libc work:** its requirement-to-evidence reporting may inform how we separate a checked model theorem from empirical agreement with a foreign binary. It is also a tool/workflow reference for spec-driven code generation. The README does not establish that it verifies Bash utilities, closes our model-to-binary gap, or proves that a generated specification captures the user's intent.

When revisiting this direction, inspect which backend checks each claimed proof, what source code and contracts are covered, and how unsupported or unproved obligations are reported. Compare one small existing example before considering integration. No installation, evaluation, or adoption was performed for this note.
