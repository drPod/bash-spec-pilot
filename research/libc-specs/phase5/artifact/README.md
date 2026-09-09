# Single-command artifact replay

```sh
python3 replay.py               # checkpointed: skip entries with an unchanged, already-passing receipt
python3 replay.py --fresh       # truly fresh: re-run every entry from scratch (proves reproducibility)
python3 replay.py --only <id1,id2>   # run just specific entries (for iterating on one)
```

Exit status 0 iff every `required` entry passed. `current` entries may FAIL, SKIP or PASS
without failing the overall replay (but never silently pass without a real receipt); `pending`
entries are never executed (versioned placeholders for work still being authored elsewhere, see
below); `experimental` entries are informational only.

## What each category means

- **required**: fresh-copy Lean/C builds with no shared-container dependency. Must pass.
- **current**: real, checked evidence, but scoped or dependent on the shared `phase5-vst`
  container's current (possibly sibling-owned) state. Several are now genuinely fresh,
  dependency-ordered, no-stale-`.vo` recompiles of entire multi-file Coq chains (not just an
  in-place single-file check against a cached dependency `.vo`) -- see each entry's
  `description` in `manifest.json` for exactly what's fresh vs. what's a fast smoke-check.
- **pending**: a real requirement whose source is still being authored by a live sibling
  worker, not yet accepted. Listed explicitly so it's visible in the manifest and never
  confused with "done" -- never executed, never counted as passing. Replace with a real entry
  once accepted upstream.
- **experimental**: informational, e.g. an honest `missing_environment` record.

## How the fresh multi-file Coq chains work (`run_named_chain` in `replay.py`)

1. Hash-verify every source file against the repository checkout (or, for entries under active
   sibling edit, against the live repo directly rather than a container mirror) -- SKIP, never
   force-pass, on any divergence.
2. Stage a brand-new, uniquely-named scratch directory in the container (plain `docker cp`/
   `docker exec cp`, no lock needed for that -- copying isn't compiling).
3. Compile file-by-file, in a manually-extracted-and-cross-validated dependency order (grep the
   real `Require` graph, cross-check against historical per-file receipts where they exist --
   see each entry's `description`). **Each file's `coqc` call gets its own `run_vst.py` lock
   acquire/release** (`coqc_one_file`) -- never one lock held for a whole chain, so a long chain
   never monopolizes the shared container against live sibling proof workers. Lock contention
   (`BlockingIOError` from `run_vst.py`'s non-blocking `flock`) triggers a short bounded retry
   with a real `docker top` idle check, not a blind sleep; a genuine compiler error aborts the
   chain immediately (never retried, never masked).
4. Clean up the scratch directory, always (even on failure).

## Checkpoint/resume -- DISABLED for chain entries as of artifact-finish-12

The caching machinery (`entry_fingerprint`/`find_cached_pass`/`CHECK_ONLY_CAPABLE`) still exists
in `replay.py` but `CHECK_ONLY_CAPABLE` is now an empty set: **every entry always executes
fresh**, `--fresh` and the default mode behave identically. This was a deliberate downgrade, not
an oversight -- root review's negative-testing went through three rounds (fabricated receipts,
then a scratch-path-prefix + `-Q`-count check, then a scratch-path-prefix + `-Q`-count check
again with a different reproducer) and established that TRUE exact command/workdir provenance
against a specific past receipt is not achievable with this architecture: every real chain
execution stages into a brand-new **randomly named** scratch directory
(`uuid.uuid4().hex[:8]`), so there is no fixed "the expected exact argv/workdir" a cached
receipt could ever be compared against -- only structural plausibility (right prefix, right
`-Q` count), which root correctly judged insufficient to call a real provenance guarantee.
Root's own guidance when this happens: "if cache cannot establish provenance reliably, disable
affected caching and execute fresh rather than claim validation." That's what this is. If a
future worker wants caching back, it needs a genuinely deterministic scratch-naming scheme
(e.g. content-addressed from the entry fingerprint) so a past receipt's exact expected command
CAN be reconstructed and compared byte-for-byte -- not another heuristic plausibility check.

## Adding a new chain entry

1. Find the files' real `Require` statements (`grep -H '^Require' *.v`) to get the true
   dependency order; cross-check against any existing individual per-file receipts under
   `~/agent-jobs/astra-research/phase5/runs/*.json` if they exist (much stronger evidence than
   guessing).
2. Compute `sha256` for every source file, add a manifest entry with `container`, the relevant
   `container_*_dir` fields, and a `{filename: sha256}` dict per source group.
3. Write a replayer function using `run_named_chain(entry, receipts, steps)` -- see
   `replay_shell_bridge_chain`/`replay_relay_full_chain`/`replay_universal_full_chain` for the
   pattern (each `step` is one physical source directory with its own `-Q` flag closure).
4. Register it in `REPLAYERS`. Test with `--only <your_id> --fresh` before trusting it in the
   full manifest.

## check_v2 63-check replay (artifact-v2-checks-13)

`calculus_bytes_check_v2_replay` freshly builds the patched interpreter from
`calculus-resume-3`, generates the 49 EXPECT unit-run jsonl files plus 14
`fixtures/v2/neg` lowering records, and runs original `check_v2.py` with `V2`
redirected to a private directory outside the repo. This is **not** the
2086-positive + 7-mutant `compare_bytes.py` corpus (`calculus_bytes_corpus_comparison_replay`).
Historical `calculus-bytes/results/v2/` is left untouched. Caching stays disabled.
Run only this entry with:

```sh
python3 replay.py --only calculus_bytes_check_v2_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/artifact-v2-checks-13/artifact-replay
```


## CalculusBody archive replay (calculus-body-artifact-15)

`lean_calculus_body_replay` rebuilds the accepted CalculusBody module from the **immutable**
tree `archive/calculus-body13/` (complete Lean source closure + exact
`export_input__byte_relay_exec.tsv` snapshot). Distinct from
`archive/CalculusNested.evaluation-frozen.lean`. Caching stays disabled. Run **only this
entry**, not the full manifest:

```sh
python3 replay.py --only lean_calculus_body_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/calculus-body-artifact-15/artifact-replay
```

Honest scope: kernel-checked whole `write_block` plus one `relay_inner_step`. Not relay-loop
termination, not general OCaml correspondence. Receipts `#eval` are finite text-token checks.
Coverage accounting: last full 17-entry run + targeted 63-check + this body run — never a
full-fresh-all claim from this session.



## Calculus outer-loop archive replay (accepted-proof-artifact-28)

`lean_calculus_outer_replay` rebuilds calculus-correspondence-14 `accepted-outer-loop` from
immutable `archive/calculus-outer14/` (7 Lean files; entry-specific lakefile, not the original
integration lakefile). Distinct from `lean_calculus_body_replay` and from the evaluation-frozen
CalculusNested (`36525e18…`). Caching stays disabled. Run **only this entry** (with juicy-dry):

```sh
python3 replay.py --only lean_calculus_outer_replay,utility_juicy_dry_chain_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/accepted-proof-artifact-28/artifact-replay
```

Scope: `runEntry` fuel `2*|input|+108`, status `{0,1,2}`. Not general lowering / type soundness.

## Juicy-dry spec archive replay (accepted-proof-artifact-28)

`utility_juicy_dry_chain_replay` recompiles the 13 accepted-juicy-dry sources plus Audit13Specs
from `archive/juicy-dry13/`, with archived relay/IOWorld/IOSpecs deps hash-checked against the
live read-only repo. Stages from the archive, never live `utility-reuse/adequacy` (utility-14
edits EmbedPre). Scope: `iow_juicy_dry_post` / `iow_juicy_dry_specs` / `mem_evolve` only.
Not a full 21-entry replay; historical 19-entry coverage is unchanged.


## Utility PRE+dryPOST archive replay (accepted-artifact-35)

`utility_pre_drypost_chain_replay` recompiles utility-leaf-adequacy-14 PRE+dryPOST from
immutable `archive/utility-pre14/` (review31 accepted-snapshot; not live adequacy).
Relay/IOWorld/errno-world deps from existing juicy-dry13 hashes. Four snapshot audits only;
AuditPost/AuditSpecs/AuditEmbed/AuditEmbedPre were not in the snapshot and are reported
missing (not live-copied). Caching stays disabled. Run **only** with the spec15 entry:

```sh
python3 replay.py --only utility_pre_drypost_chain_replay,lean_calculus_spec15_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/accepted-artifact-35/artifact-replay
```

Scope: PRE transport + dry POST chaining. Not relay juicy POST / whole program / funspec_sub.
Not a full replay. The last full run is root-artifact-full19, 20260908T104047Z: 19 entries, 18 PASS and one experimental host skip. Artifact28 and this job added two targeted entries each; 23 are now listed, with no full23 replay.

## Calc15 exact-relay correspondence archive replay (accepted-artifact-35)

`lean_calculus_spec15_replay` rebuilds `CalculusRelaySpec` from immutable
`archive/calculus-spec15/` (calc15 accepted-candidate + review30 BufferRelay/MemoryTransfer).
Tokenizer omitted (not an import of CalculusRelaySpec). Does **not** replace
`archive/calculus-outer14/` (`CalculusRelayOuter` hashes differ). Scope: status + OuterExact
five fields vs `BufferRelay.run`. Not schedules / general types / lowering.

## Raising/exception archive replay (final-artifact-integration-163)

`lean_calculus_raising153_replay` rebuilds the 16-module CalculusRelayRaising closure from
immutable `archive/calculus-raising153/` (private 153, root162 accepted). Kernel `#print axioms`
on the 28 named theorems in `CalculusRelayRaisingAxioms.lean`. Adapter is isolated; existing
helpers including tokenizer134 are unchanged. Targeted `--only` replay only — not a full 29
manifest run. Existing 153 targeted PASS 20260908T212423Z; root review of that shared install
is pending.

```sh
python3 replay.py --only lean_calculus_raising153_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/final-artifact-integration-163/artifact-replay
```

## Shell-frontend archive replay (shell-shared-integration-168)

`lean_calculus_shellfrontend142_replay` rebuilds the 20-module supported-text frontend from
immutable `archive/calculus-shellfrontend142/` (private 142, root164 accepted — not 162/163).
66 named axiom audits + 38 fixtures. Isolated adapter; raw Lean argv through `run_real`
(3GiB / 60s / shared lock / lock-only retry). Namespace qualification (161). Existing 29
archives including raising153 and tokenizer134 unchanged. Targeted `--only` only — not a
full 30-entry run. Ready for a later full-manifest run after this targeted PASS.

```sh
python3 replay.py --only lean_calculus_shellfrontend142_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/shell-shared-integration-168/artifact-replay
```
