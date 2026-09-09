# organization/milestones14 — sanitized mapping (2026-09-08T09:54:50Z preflight)

Versioned pointers only. Not whole-program CLI. Not a Bash OS proof. No full-research
completion claim. Live calculus13 / utility11 files were excluded; calc12 and utility10
records are **historicalversion** (terminal runtime evidence), not snapshots of current
mutable sources.

## Scope / sources / time

| marker | terminal source | receipt / time |
|---|---|---|
| PH5-MILESTONE-14/artifact-replay | artifact-finish-12 `ROOT-FINAL-REPLAY-AUDIT.json` (summary `20260908T092059Z`); Pi artifact-v2-checks-13 `ROOT-RECEIPT-AUDIT.json` (`20260908T094129Z` targeted) | 16 real + 1 skip = full17; targeted 63-check adds 18th; **not** full-18 fresh |
| PH5-MILESTONE-14/calculus12 | calculus-correspondence-12 `REPORT.md`/`NEXT.md` | lake 25/25; six theorems; axioms `[propext]` or `[propext, Quot.sound]`; remaining 5 obligations |
| PH5-MILESTONE-14/utility10 | utility-leaf-adequacy-10 | `utility-leaf10-replay-20260908T094137Z-ErrnoBridge` exit 0 1.33s; log_sha256 `0ff9726c…582e0b`; **ErrnoBridge partial only**, no juicy PRE/POST |
| PH5-MILESTONE-14/consolidation9 | research-consolidation-9 four docs + `ROOT-POST-REVIEW.md` | wc_lines pointer stores, **no FullWrite import** (Gprog 371–374); historical REPORT retained |

Import UTC (GET-first preflight): **2026-09-08T09:54:50Z**.
Official `POST /api/v1/nodes/commit-new` then GET; no `/api/cli/sync`; no original-node edits.

## Hosted Atlas (private)

- Preflight: **264** private (original **227** + 33 `PH5-ATLAS-IMPORT-9` + 4 `PH5-MILESTONE-12`); 0 `PH5-MILESTONE-14`.
- After: **268** private; same 33 import-9; same 4 milestone-12; **4** new milestone-14.
- Dedup GET-first. Max 4 new hosted nodes (this run: 4). All GET-confirmed `sharing_mode=private`, `kind=insight`.

See `id-url-hash-mapping.json` for node_id / url / content_sha256 / sharing_mode.

## Local OpenScience `prj_fa7ceb0639254b3dba5833834ce25366`

Preflight 2336 nodes / 2436 edges / 102 claims.
After 2340 nodes / 2436 edges / 106 claims (4 claim POSTs; old nodes preserved).

| marker | local claim id |
|---|---|
| PH5-MILESTONE-14/artifact-replay | 225fb6d5d8cdb36b |
| PH5-MILESTONE-14/calculus12 | bcbe6d1a424232f5 |
| PH5-MILESTONE-14/utility10 | 5e14963a765b8472 |
| PH5-MILESTONE-14/consolidation9 | 3b7ca40cca58766d |

## Checked vs finite vs still missing

- **Checked (historicalversion):** calc12 six Lean theorems (standard Lean axioms subset, no sorryAx at terminal audit); utility10 `errno_at_address_mapsto` only.
- **Finite / replay:** artifact 16+1 skip full17; Pi targeted 63/0 as 18th entry, not a fresh full-18.
- **Docs only:** consolidation-9 four-file factual corrections + ROOT-POST-REVIEW wc_lines/noFullWrite.
- **Still missing:** full 18-entry fresh artifact; juicy PRE/POST; write_block remaining asserts / relay while / Stmt.WF / lowering; GNU CLI; VSU linking; no requirement newly closed.

Private preflight backup mode 0600 outside the repo (`phase5/private-exports/milestones-14`).
