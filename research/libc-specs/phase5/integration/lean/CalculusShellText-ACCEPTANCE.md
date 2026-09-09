# Supported shell-text frontend (root135)

Parse a supported Bash-fragment text language into Nested commands and connect to the command/query theorem.

Root135 accepts `CalculusShellText`, `CalculusShellTextSound`, and `CalculusShellTextQuery` after fresh compiler checks and six standard-Lean axiom outputs. Independent 38-case executable fixtures pass. Grammar covers `relay`/`mark`, sequence, equal-precedence left-associative `&&`/`||`, parentheses and optional trailing semicolon; unsupported syntax fails closed.

Soundness is relative to an independent **token grammar**, with the actual `lexString` result explicitly present. The Nested theorem retains action-definition, Related, Budget and universal query premises. Query input remains a Lean AST.

No separate character-level lexer theorem, full Bash completeness or host Bash semantic-equivalence claim.

**Historical vs current.** “Artifact packaging and the final research audit remain pending” was true at this receipt. Later closed at documented bounds: [../../FINAL-DELIVERY.md](../../FINAL-DELIVERY.md).

Receipt: `/home/coder/agent-jobs/astra-research/phase5/pi-reviews/root-shell-parser-review-135/ROOT-REVIEW.json`.
