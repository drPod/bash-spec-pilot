# Catalog checkpoint 32

Historical import snapshot. Counts, accepted results and outstanding items below refer to this checkpoint. See the [final delivery](../../FINAL-DELIVERY.md) for the completed artifact.

The records concern bounded results, not whole-program or host-OS correctness. GET-first dedup; originals unmodified; at most three new private hosted
nodes (`commit-new` then GET title/summary/content SHA + privacy). Kernel compile ≠ complete.

## Scope / sources / time

| marker | terminal source | accepted vs outstanding |
|---|---|---|
| PH5-MILESTONE-32/utility14-transport | Pi `utility-transport-audit-31` + `ROOT-FULL27-RECEIPT-AUDIT.json` | **Accepted:** PRE + dry POST world transport with fresh errno (`mem_cell_ext`); 27 receipts status/timing 0. **Not:** whole linked main / `funspec_sub` / juicy reverse to `Relay_Espec`. |
| PH5-MILESTONE-32/calc15-five-fields | Pi `shell-calculus-audit-30` snapshot calc15 | **Accepted:** exact return + five root fields with input-length headroom. **Not:** residual schedules / general types / lowering / full tokenizer. **calc16 live excluded.** |
| PH5-MILESTONE-32/fd24-finite-table | Pi `shell-calculus-audit-30` FdTable v3 | **Accepted:** finite live-table gating/freshness/bidirectional adequacy. **LeanFinal24:** conditional composition + one fixed-success nonvacuity only; **not** original Lean-final complete. Empty-path open-failure mismatch → **shell25 live excluded.** |

Import UTC (GET-first preflight): **2026-09-08T13:02:00Z**.
Official `POST /api/v1/nodes/commit-new` then GET; no `/api/cli/sync`; no original-node edits.

Artifact still **21 = full19 + 2 targeted**; excludes these milestones.

## Hosted Atlas (private)

- Preflight: **274** private (original **227** + 33 import-9 + 4 ms12 + 4 ms14 + 3 ms19 + 3 ms27); 0 `PH5-MILESTONE-32`.
- After: **277** private; same prior families; **3** new milestone-32.
- Dedup GET-first. Max 3 new hosted nodes (this run: 3). All GET-confirmed `sharing_mode=private`, `kind=insight`.

See `id-url-hash-mapping.json` for node_id / url / title+summary+content SHA / sharing_mode.

## Local OpenScience `prj_fa7ceb0639254b3dba5833834ce25366`

Preflight 2346 nodes / 2436 edges / 112 claims.
After 2349 nodes / 2436 edges / 115 claims (3 claim POSTs; old nodes preserved).

| marker | local claim id |
|---|---|
| PH5-MILESTONE-32/utility14-transport | 0bdba8903dd50ad0 |
| PH5-MILESTONE-32/calc15-five-fields | d16088596663a655 |
| PH5-MILESTONE-32/fd24-finite-table | e4d463f0d1e106c6 |

## Hosted node ids

| marker | node_id |
|---|---|
| PH5-MILESTONE-32/utility14-transport | cc3cad78-4159-4bcd-ae4f-ff7a86e3b419 |
| PH5-MILESTONE-32/calc15-five-fields | dba9c5f1-c266-4625-ba46-7d9a16cb013f |
| PH5-MILESTONE-32/fd24-finite-table | 0ac9680c-b4f3-4ef1-9e5d-41b648ad3c26 |

Evaluation remains bounded complete; UTF-8 closed negative preserved.
Private preflight backup mode 0600 outside the repo (`phase5/private-exports/milestones-32`).
