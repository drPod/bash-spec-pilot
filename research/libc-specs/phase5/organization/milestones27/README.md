# Catalog checkpoint 27

Historical import snapshot. Counts, accepted results and outstanding items below refer to this checkpoint. See the [final delivery](../../FINAL-DELIVERY.md) for the completed artifact.

The records concern bounded results, not whole-program or host-OS correctness. GET-first dedup; originals unmodified; at most three new private hosted
nodes (`commit-new` then GET title/summary/content SHA + privacy).

## Scope / sources / time

| marker | terminal source | accepted vs outstanding |
|---|---|---|
| PH5-MILESTONE-27/inner-loop | Claude `calculus-correspondence-14` `ROOT-INNER-LOOP-AUDIT.json` + `accepted-inner-loop/` | **Accepted:** four inner-loop theorems (`relay_inner_lost`, `relay_inner_step_inv`, `relay_inner_loop_run`, `relay_inner_loop_terminates`); fuel+2*(r-off).toNat+30 under `InnerInv` with bytes/range/write-counter premises; finish range OR return 2; standard Lean axioms; `all_status_zero`. **Outstanding:** outer loop, general lowering, type proof. Worker14 live files not accepted. |
| PH5-MILESTONE-27/utility-juicy-dry | Claude `utility-leaf-adequacy-13` `ROOT-JUICY-DRY-AUDIT.json` + `accepted-juicy-dry/` 13 sources | **Accepted:** full `iow_juicy_dry_post` + `iow_juicy_dry_specs` PRE/POST/exit record and memory evolution; 15 ordered replay receipts status/timing 0 with log SHA; container source matches. Standard VST axioms. **Outstanding:** separate world/funspec bridge OPEN. Worker13 live files not accepted. |
| PH5-MILESTONE-27/artifact-full19 | Claude `root-artifact-full19` `ROOT-RECEIPT-AUDIT.json` + `artifact-replay/20260908T104047Z/summary.json` | **Accepted:** 18 real PASS + 1 experimental host skip; 231 refs (229 zero + 2 expected `mut_bad_byte` exit 4); 151 fresh Coq compiles; private OCaml build in container. Start 10:40:47 / end 10:52:16 from process/exit; historical `summary.started_utc` is finish. Pi `artifact-timestamps-25` `ROOT-MAIN-VALIDATION.json` is metadata-fix only (mocked main), not a new full replay. **Outstanding:** later inner-loop / utility POST not in this replay. Manifest `full_scope_complete` ≠ research completion. |

Import UTC (GET-first preflight): **2026-09-08T11:48:42Z**.
Official `POST /api/v1/nodes/commit-new` then GET; no `/api/cli/sync`; no original-node edits.

## Hosted Atlas (private)

- Preflight: **271** private (original **227** + 33 `PH5-ATLAS-IMPORT-9` + 4 `PH5-MILESTONE-12` + 4 `PH5-MILESTONE-14` + 3 `PH5-MILESTONE-19`); 0 `PH5-MILESTONE-27`.
- After: **274** private; same 33 import-9; same 4 milestone-12; same 4 milestone-14; same 3 milestone-19; **3** new milestone-27.
- Dedup GET-first. Max 3 new hosted nodes (this run: 3). All GET-confirmed `sharing_mode=private`, `kind=insight`.

See `id-url-hash-mapping.json` for node_id / url / content_sha256 / sharing_mode.

## Local OpenScience `prj_fa7ceb0639254b3dba5833834ce25366`

Preflight 2343 nodes / 2436 edges / 109 claims.
After 2346 nodes / 2436 edges / 112 claims (3 claim POSTs; old nodes preserved).

| marker | local claim id |
|---|---|
| PH5-MILESTONE-27/inner-loop | 7098bd78689f2ae2 |
| PH5-MILESTONE-27/utility-juicy-dry | e19b96acff0b77b4 |
| PH5-MILESTONE-27/artifact-full19 | ef6b4ef23dc82a77 |

## Counts / axioms / receipts

- **Hosted:** 271 → 274 all private; original 227 implied preserved; no public nodes.
- **Inner-loop axioms:** standard Lean (`propext` / `Classical.choice` / `Quot.sound`); snapshot hashes as in ROOT-INNER-LOOP-AUDIT.
- **Utility:** 15 receipts status 0; 13 sources `container_matches`; world/funspec bridge not closed.
- **Artifact:** 18 PASS + 1 host skip; 229/231 status 0; 2 expected exit 4; clocks from process/exit not `summary.started_utc`.

Private preflight backup mode 0600 outside the repo (`phase5/private-exports/milestones-27`).
