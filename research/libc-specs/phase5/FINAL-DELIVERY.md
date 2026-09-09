# Final research delivery

The source artifact was independently verified on 8 September 2026. It contains the completed prototype, experiments and evidence at their documented scope. The [current paper (PDF)](evaluation/paper.pdf) explains the findings; the frozen archive retains the earlier manuscript.

The research and PDF were subsequently committed and pushed in `2a7f061`. The archive is a separately hashed snapshot. Full Bash, host-OS behavior and GNU `main` remain outside the demonstrated fragment; novelty and conference acceptance are not established.

## Archive

- File: [libc-specs-source.tar.gz](deliverables/release-212/libc-specs-source.tar.gz)
- SHA-256: `1977a2c25794acfbdd02a01d9929c2471439359c4771784d92daaa8de1fdf6db`
- 2,465 payload files; root and independent audit213 rehashed every file with zero mismatches.
- HEAD authenticates the exact inventory JSONL.
- Release209 is superseded after its inventory metadata defect was fixed and regression-tested in 211.

The archive contains the September 8 manuscript and its HTML rendering, source, frozen closures, results and acceptance receipts. Full30 replay174: 29 PASS plus one experimental host OCaml skip; pinned-container counterpart PASS. Separate supplements 191/198 (23 Lean modules) and 196/203 (18 Lean modules, 18 axiom reports, 17 generator fixtures) passed fresh replays. These supplements are not part of the frozen 30-entry manifest. No proof bytes were changed for packaging.

Catalog verification is recorded in [CATALOG-RECEIPT.json](deliverables/release-212/CATALOG-RECEIPT.json).

## Demonstrated fragment

The supported Lean script fragment has relay and a modeled `mark` atom, sequencing, `&&`, `||` and parentheses, finite schedules and sufficient fuel/integer headroom. Only relay has the generated-C-source connection in Lean. Head/wc are additional Coq/VST body and wrapper case studies. UTF-8 calibration is a preserved negative result, not a C-conformance theorem.

## Trusted boundaries

CompCert C-to-Clight frontend; syntax-directed Python dump; reviewed Lean transcription of the used Clight/Cop subset (not a CompCert step-preservation theorem); scheduled read/write contracts; empirical OCaml frontend correspondence; unproved character-level lexer; independent Coq and Lean proofs without proof import; modeled `mark` with no C source. Total-byte memory does not prove CompCert Vundef behavior. Prior lost bytes are a calculus ghost accumulator.

## Reproduction

Requires documented Lean 4.31.0 and Docker `phase5-vst` toolchain. Supplemental runners currently name this host's absolute Lean installation path; adapt that path on other hosts while retaining the pinned toolchain. Toolchain installations/container images are prerequisites, not bundled binaries.

Repository copy: [deliverables/release-212](deliverables/release-212/README.md). The original build remains at `/home/coder/agent-jobs/astra-research/phase5/deliverables/release-212`.

Catalog verification: 308 private Atlas nodes; 2380 OpenScience nodes and 2436 edges. Milestone215 title/summary/content verified by hosted GET and local content hash verified after write. See `organization/milestones215/import-summary.json`.

The frozen tar intentionally predates these final sidecars; its SHA-256 is unchanged. `COMPLETION-CLOSURE.json` beside the archive closes every matrix200 requirement and preserves the original evidence and boundaries.
