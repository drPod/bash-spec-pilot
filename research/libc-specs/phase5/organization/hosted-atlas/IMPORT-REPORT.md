# Hosted Atlas import (client 11)

This pass did not complete research. It did not publish anything. It did not create dummy nodes. It did not edit existing nodes.

## Schema from official package

`@synsci/atlas` 0.14.1 was downloaded with `npm pack --ignore-scripts` and installed to a private prefix with `--ignore-scripts`. `node:create` is `POST /nodes/commit-new`. Official `note:add` uses `kind=insight` and does not send `sharing_mode`. README states sharing lives on the project root and that `node:share` is the publish step. That is enough to treat create as private.

Prepared catalog ids (31) plus overview and CURRENT-EVIDENCE match the frozen catalog and evidence freeze dates above.

## Writes

One overview record was created first, GET-verified private with marker `PH5-ATLAS-IMPORT-9/CATALOG-OVERVIEW`. The remaining 32 records were created as private insight children of that overview. Each create returned HTTP 201. Each GET returned HTTP 200, `sharing_mode=private`, `kind=insight`, and the intended marker in title/summary/content.

Final listing: 260 unique nodes, 260 private. Import markers on the live graph: 33. Prior graph size 227 plus 33 new nodes. No public writes. No `/api/cli/sync`.

Verified hosted writes: 33. Remaining intended private records: 0. Existing graph nodes preserved: 227. Duplicate import markers before write: 0.

## Remaining research gaps (unchanged)

Finite tests are not C proofs. Compiled models and specs can still have open bodies. Universal relay claims stay under explicit assumptions. GNU imports are generalized. Atlas and catalog prose do not restore missing paper PDF or git objects.

Sanitized mapping is `id-url-hash-mapping.json`. Full receipts stay in the private job directory.
