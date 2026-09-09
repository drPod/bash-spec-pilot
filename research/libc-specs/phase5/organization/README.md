# Research catalog and provenance

This directory indexes research results and records their import into OpenScience and Atlas. Catalog entries point to evidence; they are not substitutes for source files, proofs or compiler receipts.

For the research itself, read the [paper](../evaluation/paper.pdf). For the final artifact and scope, read the [delivery record](../FINAL-DELIVERY.md).

## Current checkpoint

The final delivery import, [milestone215](milestones215/README.md), verified 308 private Atlas nodes and 2,380 local OpenScience nodes with 2,436 edges. These are counts at that checkpoint, not a live account query. The import checked hosted content after writing and verified local content hashes.

Earlier milestone directories are dated import snapshots. Their counts and pending-work statements describe the state at import time. They should not be interpreted as current completion reports.

## Files

| File | Use |
|---|---|
| `catalog.json` | Initial catalog of 27 research records and 17 independent audits. Read each record's scope and distinctions before citing it. |
| `artifacts.jsonl` | Expanded inventory of 2,132 receipt and artifact records, including 486 compiler receipts and 1,424 job-file records added during repair. |
| `CURRENT-EVIDENCE.json` | Later evidence overlay for evaluation accounting and case-study replays. |
| [Requirements crosswalk](REQUIREMENTS-CROSSWALK.md) | Historical mapping from requirements to the initial catalog. |
| [Coverage gaps](COVERAGE-GAPS.md) | Gaps recorded during the initial inventory, not the final completion decision. |
| `schema.json`, `READY.json` | Catalog schema and initial import checkpoint. |
| `milestones*/` | Subsequent imports, mappings and verification receipts. |
| [Hosted Atlas records](hosted-atlas/README.md) | Hosted-graph organization and recovery records. |

## Status labels

`checked` identifies a result with a successful checker receipt and the assumption audit recorded for that result. Suffixes such as `checked-existential` or `checked-partial` qualify the theorem's scope. They do not make the result universal or remove its assumptions.

`checked-negative-result` and `not-established` mean that the investigation produced evidence but did not establish the target theorem. `not-established-interrupted` means that an interrupted assignment produced no result. These statuses should remain distinct.

## Inventory repair

The first OpenScience import read the inventory 69 seconds before its author finished, omitting one predecessor record and 121 receipt rows. The repair expanded the inventory, corrected a coreutils revision transcription, rechecked selected source hashes, and clarified that the linked GNU verification components contain no `main` function.

The repair also checked all 486 added compiler-log hashes, with no mismatches. It did not rerun the proofs. Later imports added finalized evaluation accounting and case-study evidence without changing the frozen trials. The JSON records and import receipts retain the detailed chronology.

Quoted hashes and approximate timestamps in the original catalog are identified as such. A catalog's presence alone does not establish that a file still exists or that an earlier proposed theorem was subsequently proved.
