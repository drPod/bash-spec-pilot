# `prompts/adversarial/`

Reserved slot for the adversarial-test prompt variant (man page → Bash tests
designed to surface known LLM failure modes from `docs/research/taxonomy.md` §4–§5).

Empty for now. Populated by the wave-4 adversarial pipeline; see
`docs/research/decisions.md` and the wave-4 PR for design.

The baseline (non-adversarial) man page → Rust impl + happy-path Bash tests
lives in `../baseline/`.
