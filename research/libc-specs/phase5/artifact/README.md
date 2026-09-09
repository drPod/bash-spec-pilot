# Single-command artifact replay

```sh
python3 replay.py               # default: every entry executes fresh (caching disabled)
python3 replay.py --fresh       # same as default
python3 replay.py --only <id1,id2>   # specific entries
```

Exit status 0 iff every `required` entry passed. `current` may FAIL, SKIP or PASS without failing overall (never silently pass without a receipt). `pending` entries are never executed. `experimental` are informational.

## Categories

- **required**: fresh-copy Lean/C builds with no shared-container dependency. Must pass.
- **current**: checked evidence that may depend on `phase5-vst`. See each `manifest.json` `description` for full chain vs smoke-check.
- **pending**: requirement whose source is not yet accepted; never executed.
- **experimental**: e.g. `missing_environment`.

## Multi-file Coq chains (`run_named_chain`)

1. Hash-verify sources against the checkout (SKIP, never force-pass, on divergence).
2. Stage a uniquely named scratch directory (`docker cp`).
3. Compile file-by-file in `Require` order. Each `coqc` takes its own `run_vst.py` lock (`coqc_one_file`). Lock contention retries with a `docker top` idle check; a compiler error aborts immediately.
4. Clean up the scratch directory.

## Caching disabled

`CHECK_ONLY_CAPABLE` is empty: every entry always executes fresh. Chains stage into a random scratch directory (`uuid.uuid4().hex[:8]`), so a cached receipt cannot be compared to a fixed argv/workdir. Restoring cache would need deterministic, content-addressed scratch names.

## Adding a chain entry

1. `grep -H '^Require' *.v` for dependency order; cross-check historical receipts under `~/agent-jobs/astra-research/phase5/runs/*.json`.
2. `sha256` every source; manifest entry with `container_*_dir` and `{filename: sha256}`.
3. Replayer via `run_named_chain` (see `replay_shell_bridge_chain` / `replay_relay_full_chain` / `replay_universal_full_chain`).
4. Register in `REPLAYERS`. Test `--only <id> --fresh`.

Targeted `--only` entries below are **local archive replays**, not a claim that every historical run is the current whole-program paper result. Current manuscript: [`../evaluation/DRAFT-PAPER.md`](../evaluation/DRAFT-PAPER.md). Delivery: [`../FINAL-DELIVERY.md`](../FINAL-DELIVERY.md).

## Named targeted replays

| Entry | Archive / scope |
|---|---|
| `calculus_bytes_check_v2_replay` | Patched interpreter from `calculus-resume-3`; 49 EXPECT jsonl + 14 `fixtures/v2/neg`. Not the 2086-positive `compare_bytes.py` corpus. |
| `lean_calculus_body_replay` | `archive/calculus-body13/`. Whole `write_block` plus one `relay_inner_step`. Not loop termination. |
| `lean_calculus_outer_replay` | `archive/calculus-outer14/` (7 Lean files). `runEntry` fuel `2*|input|+108`, status `{0,1,2}`. |
| `utility_juicy_dry_chain_replay` | `archive/juicy-dry13/`. `iow_juicy_dry_post` / specs / `mem_evolve` only. |
| `utility_pre_drypost_chain_replay` | `archive/utility-pre14/`. PRE transport + dry POST chaining. |
| `lean_calculus_spec15_replay` | `archive/calculus-spec15/`. Status + OuterExact vs `BufferRelay.run`. |
| `lean_calculus_raising153_replay` | `archive/calculus-raising153/` (16 modules; 28 named theorems). |
| `lean_calculus_shellfrontend142_replay` | `archive/calculus-shellfrontend142/` (20 modules; 66 axiom audits + 38 fixtures). |

Example:

```sh
python3 replay.py --only calculus_bytes_check_v2_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/artifact-v2-checks-13/artifact-replay
python3 replay.py --only lean_calculus_raising153_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/final-artifact-integration-163/artifact-replay
python3 replay.py --only lean_calculus_shellfrontend142_replay --out-dir ~/agent-jobs/astra-research/phase5/pi-reviews/shell-shared-integration-168/artifact-replay
```

Last recorded full run cited here: root-artifact-full19, 20260908T104047Z: 19 entries, 18 PASS and one experimental host skip. Later jobs added targeted entries; listing more ids is not a full-manifest replay.
