# Hosted Atlas (phase5 mapping note)

Sanitized recovery and import mapping only. The private graph export and the prepared POST bodies are not in this repository.

Stable marker family: `PH5-ATLAS-IMPORT-9/<catalog-id>` plus `CATALOG-OVERVIEW` and `CURRENT-EVIDENCE`.

Snapshot markers used for this pass:

- Catalog freeze: `generated_at_utc` 2026-09-08T03:17:51Z, schema 1.0, 31 records.
- CURRENT-EVIDENCE freeze: `freeze_utc` 2026-09-08T06:15:27Z (local provenance HTTP, not hosted Atlas).
- Hosted backup hash (private job export only): `41bd290dc13b33fc7020c9f9e86699616936fd1a45ccbaacb7e998fb94139841`.

## Write schema (official CLI 0.14.1)

Inspected `@synsci/atlas` 0.14.1 via `npm pack --ignore-scripts` (postinstall not executed). `atlas help node:create --schema` requires `payload_json` only. Official `note:add` POSTs `/nodes/commit-new` with `local_temp_node_id`, `parent_ids`, and `staged_payload` of `title`, `summary`, `content`, `kind=insight`, `outcome=completed`, `insights`. `sharing_mode` is not a create field. Visibility is graph-scoped on the project root; `node:share` PUT is required to publish. New roots default private.

## Import result

- Before: listed 227, all private, zero import markers.
- After: listed 260, all private (227 prior + 33 new).
- Verified writes: 33 GET-confirmed private insight nodes with exact markers.
- Children linked to new overview `a36821e0-c4b1-4ca3-9bd2-730992e19361` only. Prior 227 nodes were not updated or deleted.
- `/api/cli/sync` was not called.

Sanitized ID/URL/content hash table: `id-url-hash-mapping.json`. Narrative: `IMPORT-REPORT.md`.

Catalog pointers are not Coq/VST/Lean kernel receipts. Limitations kept: finite tests are not C proofs; model/spec compiled with bodies open; universal relay under explicit assumptions; generalized GNU imports; old paper prose is not missing PDF/source.
