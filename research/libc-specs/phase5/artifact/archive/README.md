# Immutable evaluation-source archive

`CalculusNested.evaluation-frozen.lean` (mode 444, read-only) is a byte-exact archived copy of
`integration/lean/CalculusNested.lean` as it stood at `evaluation-expanded/protocol.json`'s
freeze timestamp (`2026-09-07T21:51:36Z`), sha256 `36525e18cde92225dcaef9d30077565f1124a7c96782b22ef3e3366c75783587`.

## Why this exists (artifact-finish-12, 2026-09-08)

The live file `integration/lean/CalculusNested.lean` began diverging from this frozen hash
during artifact-finish-11 (observed 3 different live hashes within ~15 minutes) — this is
**authorized ongoing development** by the `calculus-correspondence` worker lineage, not a bug,
and this archive does NOT revert or freeze the live file. But `evaluation-finalize-8`'s frozen
`evaluation-expanded/` deliverable (93 model calls, 90 scored, the whole accepted/rejected
ledger in `evaluation-artifact-4/REPORT.md`) is defined relative to the EXACT source at that
freeze timestamp — the live file drifting away from it does not change what was actually
measured, but it does mean `lean_calculus_nested_real`'s replay entry needs a stable source to
keep validating against, independent of unrelated ongoing work in the same file.

## Recovery and verification (not invented, not asserted from memory)

Found two independent copies with a byte-identical sha256 match to the original frozen hash:

1. `~/.cache/bash-spec-pilot/phase5-evaluation-expanded/baseline/CalculusNested.lean.frozen-source`
   — a pre-existing cache artifact from the original evaluation harness's own `check_attempt.py`
   BASELINE setup (predates this job entirely), named specifically for this purpose. **This is
   the file copied here.**
2. `~/.cache/bash-spec-pilot/phase5-artifact-replay/lean-nested-real-51cfee1aa8/CalculusNested.lean`
   — a leftover scratch copy from a prior `lean_calculus_nested_real` replay run (this tool's
   own history), independently confirming the same sha256.

Both matched `36525e18cde92225dcaef9d30077565f1124a7c96782b22ef3e3366c75783587` exactly before
either was used. `lean_calculus_nested_real` in `../manifest.json` now has an `archive_source`
field pointing here; `replay.py`'s `replay_lean_calculus_nested_real` prefers it over the live
repo path when present. The `evaluation-expanded/` protocol, trial data, and numbers themselves
were NOT altered, re-frozen, or re-derived by this change — only the artifact-replay tool's own
source pointer for this one entry.

## What this does NOT do

- Does not touch, revert, or lock `integration/lean/CalculusNested.lean` (the live file).
- Does not re-freeze or modify `evaluation-expanded/protocol.json`, `tasks/manifest.json`, or any
  of the 96 rows in `evaluation-artifact-4/attempts.jsonl`.
- Is not a claim that ongoing `calculus-correspondence` work is invalid or should stop.
- A separate "current development" replay entry for the live, evolving file should be added by a
  future worker once that lineage reports terminal — not bundled into this evaluation-era entry.


## calculus-outer14 (accepted-proof-artifact-28)

Byte copies of calculus-correspondence-14 `accepted-outer-loop` Lean sources + toolchain/lakefile
snapshot. Evaluation-frozen CalculusNested (`36525e18…`) is a different file and is not this tree.
`CalculusNested.lean` here matches calculus-body13 (`e2a7cffb…`), not the evaluation freeze.

## juicy-dry13 (accepted-proof-artifact-28)

Byte copies of utility-leaf-adequacy-13 `accepted-juicy-dry` (13 `.v`) plus `Audit13Specs.v` and
hash-verified relay/IOWorld/IOSpecs deps. Do not confuse with live `utility-reuse/adequacy`.


## utility-pre14 (accepted-artifact-35)

Byte copies of utility-leaf-adequacy-14 PRE+dryPOST from review31 `accepted-snapshot`
(not live `utility-reuse/adequacy`). Deps from juicy-dry13. Snapshot lacked
AuditPost/AuditSpecs/AuditEmbed/AuditEmbedPre — not live-copied.

## calculus-spec15 (accepted-artifact-35)

Calc15 accepted-candidate exact-relay closure + review30 BufferRelay/MemoryTransfer.
Tokenizer omitted. Does not replace calculus-outer14 (`CalculusRelayOuter` hashes differ).

## calculus-query-guards95 (query-guards-artifact-95)

Byte copies of accepted Commands87, Guards82, guard-integration89, Query92 plus matching typed77/stateful hashes for the import closure. Does not replace calculus-typed-shared77. Tokenizer omitted. Query comment hash 5a994b4b left byte-identical; PROVENANCE records actual Lowering 45a2bae4.


## calculus-tokenizer134 (tokenizer-artifact-134)

Accepted tokenizer117 + CLI133: generic Tokenize 5193c045, full literals, 16 chunk modules, corrected Chunks ef2baca1, CopyEq/CopyAudit, CompareTotalMain/ExportTotalMain. Older CompareMain 6b917746 pinned unused as CLI. Explicit 33-pair manifest. Does not package Bash text or raising.

## calculus-raising153 (final-artifact-integration-163)

Byte copies of accepted private raising-artifact-private-153 (root-raising-seven-review-151 sources, root-exception-artifact-review-162 accepted). 16-module exception/raising closure + lean-toolchain. Does not replace calculus-tokenizer134 or calculus-query-guards95. CompareMain remains 6b917746 (CLI unused here). CalculusNested matches calculus-body13 (`e2a7cffb…`), not the evaluation freeze.

## calculus-shellfrontend142 (shell-shared-integration-168)

Byte copies of private 142 20-module supported-text frontend + 135 fixtures.json (root164 accepted).
Does not replace calculus-raising153 or calculus-tokenizer134. Scope: TOKEN grammar + actual lex;
not character-lexer / full Bash / query-text parser.
