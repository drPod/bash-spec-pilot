# Accepted milestones 64

Two private Atlas insight nodes were created and individually fetched back with exact title/summary/content SHA256 verification. A final paginated GET returned **279 nodes, all private**. Mapping and content are saved here; full before/after exports and request receipts are in the runtime directory `pi-reviews/root-milestones-64` with mode 0600.

- Stateful55: actual schedule consumption in the Lean reference composition; 18 standard Lean assumption outputs. The saved receipt log replays the preceding successful build; it is not a new fresh build. This milestone is not artifact-packaged and does not establish a checked Coq-to-Lean/C bridge.
- Head/wc wrappers: callee lifting and wrapper proof under common Gprog per translation unit; all 19 fresh targeted replay files and four assumption audits verified. Last full artifact replay remains 19 entries followed by five targeted additions; no full24 replay is claimed.

The initial request to 127.0.0.1:4097 failed. Root subsequently located the existing OpenScience service on **4096**. After verifying the project ID, repository directory and a known prior milestone/hosted-ID pair, both local claims were imported and fetched back with exact metadata/content hashes. GET now reports **2351 nodes (117 claims), 2436 edges, zero orphan edges**. No service was restarted, and reconciliation made no hosted requests. `local-pending.json` now records imported-and-verified status; `local4096-reconciliation.json` contains receipts. Hosted imports remain idempotent by marker/title and exact content hash. No unaccepted tokenizer/type work was included.

`EVIDENCE-VERIFICATION.json` records source and receipt hashes checked before either hosted write. Runtime `hosted-post-get-verification.json` records both POST/GET outcomes; `import-summary.json` contains GET-derived totals.
