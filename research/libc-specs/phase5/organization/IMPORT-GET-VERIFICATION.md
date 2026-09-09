# Import GET verification (organization-validate-7)

UTC: **2026-09-08T06:02:05Z**.

GET `http://127.0.0.1:4097/provenance?project=prj_fa7ceb0639254b3dba5833834ce25366` after finishing the 311 missing `job_dir_file` POSTs:

- summary: 2242 nodes, 2348 edges, `orphan_edges: 0` (recomputed from `from`/`to` vs node ids: 0)
- all 2178 intended labels from `catalog.json` (27 records + 17 audits) + 2 repair-6 source nodes + 2132 `artifacts.jsonl` rows are present
- this is **inventory-import coverage**, not a claim that all phase5 research is complete
- 26 pre-existing duplicate labels (earlier import generations of PH5-* claims / handoff log); not created by this finish pass
- 1444 nodes carry `contentHash`; 1228 unique (216 extra hash collisions are repeated file bytes across job dirs, not ID collisions)
- Atlas UUID `b64557ae-2fc9-4576-9a1c-3df774a03269` was **not** written; no Atlas client on this host

## Independent content check

2026-09-08T06:05:22.310023+00:00

Independent full-file hash follow-up: all1444 nodes carrying contentHash resolved to real files using documented repo-root, tilde, and inventory JOBROOT path conventions. 1437 match current bytes;7 differ: older catalog/artifact versions, three ORCHESTRATION versions, evaluation attempts.jsonl (additional trials after snapshot), evaluation-finalize6/FROM-ORCHESTRATOR. Full per-ID expected/current hashes in private pi-reviews/organization-validate-7/root-fullhash-check.json. Thus label coverage is complete for the frozen inventory, but current-state synchronization is NOT complete and seven versioned hashes must not be advertised as current matches. Source snapshots/history should be preserved while new versions/new work appended in next sync.


# Overlay GET verification (organization-current-evidence-8)

UTC: **2026-09-08T06:17:37Z**.

GET `http://127.0.0.1:4097/provenance?project=prj_fa7ceb0639254b3dba5833834ce25366` after bounded freeze+import of new finalized evidence:

- summary: 2332 nodes, 2436 edges, `orphan_edges: 0`
- kinds: artifact 1524, run 698, source 12, claim 98
- freeze `2026-09-08T06:15:27Z`: 76 files (20 explicit + 56 run receipts); all 76 content hashes present on GET nodes (0 missing)
- new catalog claims PH5-EVAL-004, PH5-CASE-002/003/004 and four PI-* audits posted; older catalog records and 2178 validate-7 labels left in graph
- historical `case-differential7-*` / `case-replay7-*` receipts imported with `historical_not_current_code`; current hashes live in RESULTS.json `validator_followup.current_replay_sha256` plus replay8 receipt_sha256
- attempts.jsonl current 96-row hash imported as versioned row; frozen original 90 trials not rewritten; no model-proof-completion claim
- Atlas UUID not written

Independent full-file rehash of freeze list after POST matched freeze bytes (import refused drift).
