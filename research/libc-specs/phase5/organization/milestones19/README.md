# organization/milestones19 — sanitized mapping (2026-09-08T10:52:28Z preflight)

Versioned pointers only. Not whole-program CLI. Not a Bash OS proof. No full-research
completion claim. GET-first dedup; originals unmodified; at most three new private hosted
nodes (`commit-new` then GET title/summary/content SHA + privacy).

## Scope / sources / time

| marker | terminal source | accepted vs outstanding |
|---|---|---|
| PH5-MILESTONE-19/calculus-body | Pi `calculus13-step-repair` `ROOT-LOG-AUDIT.json` + REPORT | **Accepted:** whole `write_block` success/error/assertion + `relay_inner_step`; lake CalculusBody exit 0; logs hash_matches; sorryAx false; axioms `propext` / `Classical.choice` / `Quot.sound`. **Outstanding:** relay loops, general lowering, typesoundness. |
| PH5-MILESTONE-19/utility-pre | Claude `utility-leaf-adequacy-11` `ROOT-RECEIPT-AUDIT.json` REPORT/NEXT; Pi `utility-post-write-16` `ROOT-VERIFICATION.json` REPORT/NEXT | **Accepted:** scalar errno + PRE closed; POST *support* lemmas; two write helpers only (`errno_memval_Zlength`, `address_mapsto_yes_in_range`). **Outstanding:** full POST / `juicy_dry_ext_spec` record / worldbridge; writePOST not Qed. |
| PH5-MILESTONE-19/artifact-body | Pi `calculus-body-artifact-15` `ROOT-VERIFICATION.json` REPORT + immutable `archive/calculus-body13` | **Accepted:** 19th manifest entry targeted PASS (`--only`, `full_scope_complete=false`); build/audit exit 0; source hashes match archive. **Outstanding:** full-19 replay still running / not claimed. |

Import UTC (GET-first preflight): **2026-09-08T10:52:28Z**.
Official `POST /api/v1/nodes/commit-new` then GET; no `/api/cli/sync`; no original-node edits.

## Hosted Atlas (private)

- Preflight: **268** private (original **227** + 33 `PH5-ATLAS-IMPORT-9` + 4 `PH5-MILESTONE-12` + 4 `PH5-MILESTONE-14`); 0 `PH5-MILESTONE-19`.
- After: **271** private; same 33 import-9; same 4 milestone-12; same 4 milestone-14; **3** new milestone-19.
- Dedup GET-first. Max 3 new hosted nodes (this run: 3). All GET-confirmed `sharing_mode=private`, `kind=insight`.

See `id-url-hash-mapping.json` for node_id / url / content_sha256 / sharing_mode.

## Local OpenScience `prj_fa7ceb0639254b3dba5833834ce25366`

Preflight 2340 nodes / 2436 edges / 106 claims.
After 2343 nodes / 2436 edges / 109 claims (3 claim POSTs; old nodes preserved).

| marker | local claim id |
|---|---|
| PH5-MILESTONE-19/calculus-body | 7f9c7b59871199dc |
| PH5-MILESTONE-19/utility-pre | b28a2d85dfa97648 |
| PH5-MILESTONE-19/artifact-body | f94a0b47c20325ed |

## Counts / axioms / receipts

- **Hosted:** 268 → 271 all private; original 227 implied preserved; no public nodes.
- **Calculus axioms:** `propext`, `Classical.choice`, `Quot.sound` only (no sorryAx on audited logs).
- **Utility receipts:** leaf11 ErrnoLoad/JuicyPre/PostLemmas/PostLemmas2 exit 0 hash_ok; post-write-16 source `4c669f4c…be1dee` log `b2a796b6…dfbb76`.
- **Artifact:** build log `6b66bf2b…1fdb`; receipts `4beece02…82e0`; CalculusBody archive `481d8d61…aa5c6`.

Private preflight backup mode 0600 outside the repo (`phase5/private-exports/milestones-19`).
