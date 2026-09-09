# Typing and lowering relation (root74 / root77)

Type preservation over `interp` and a checked lowering of the exported nine bodies.

**Typing61 accepted at root74** (`root-typing-review-74/ROOT-REVIEW.json`): four fresh module compiles and 13 exact audits establish general result-shape/type preservation (explicit failure allowed), checker soundness and nine concrete exported-body typings. The initial lowering relation used a hand-transcribed AST. **Export75 accepted at root77** (`root-spec-export-review-77/ROOT-REVIEW.json`) adds deterministic machine-exported parser AST identity and its kernel-checked lowering to nine bodies.

The acceptance receipt independently checks source and log hashes and all 13 audit names. Compiler outputs and exact source snapshots are under `root-typing-review-74/project`; the source input transcription is retained as an explicit boundary.

Parser/printer/generator execution remains a trusted boundary. General range/nonfailure soundness and OCaml-source correspondence remain open. Native worker quota exhaustion does not invalidate these compiler results.
