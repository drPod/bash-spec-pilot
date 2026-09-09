# organization/milestones12 — sanitized mapping (2026-09-08)

Versioned pointers only. Not whole-program CLI. Not a Bash OS proof.
Live calc10 / utility9 / artifact12 mutable files were excluded.

## Hosted Atlas (private)

Preflight: 260 private nodes, 33 `PH5-ATLAS-IMPORT-9` markers, 0 `PH5-MILESTONE-12`.
After: 264 private, same 33 import-9 markers, 4 new milestone markers.
Dedup GET-first; official `POST /api/v1/nodes/commit-new`; no `/api/cli/sync`.

See `id-url-hash-mapping.json` for node_id / url / content_sha256 / sharing_mode.

## Local OpenScience `prj_fa7ceb0639254b3dba5833834ce25366`

Preflight 2332 nodes / 2436 edges / 98 claims.
After 2336 nodes / 2436 edges / 102 claims (4 claim POSTs, old nodes preserved).

| marker | local claim id |
|---|---|
| PH5-MILESTONE-12/case-head | ac1509523ae411d0 |
| PH5-MILESTONE-12/case-wc | 2ad134edf490f605 |
| PH5-MILESTONE-12/shell-compose | d64c0e4c8a06b1e6 |
| PH5-MILESTONE-12/shell-validation | 34f84d8c4a60980e |

## Checked vs finite vs still missing

- **Checked:** `body_head_bytes`, `body_wc_lines` (standard VST/CompCert axioms only); `parse_program3_sound` and 31 Closed-under-global-context Print Assumptions outputs (source has 31 commands; REPORT “30x” was an undercount).
- **Finite:** Pi 100/100 mocked case tests; 12/12 container-wrapped bash/relay observations (repair-9). `relay.c` ≠ `relay.i`.
- **Still missing:** GNU `head`/`wc` `main`/CLI; VSU linking of the two TUs; `wc_lines` null `semax_body`; fwrite/rawmemchr/error bodies; parser completeness; 3-stage pipes; redirect of compounds; Coq/Bash automated differential.

Private receipts/backups live outside the repo (`phase5/private-exports/milestones-12`, mode 600).
