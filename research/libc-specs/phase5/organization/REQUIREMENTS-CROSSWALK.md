# REQUIREMENTS.md -> catalog.json crosswalk

> Historical catalog crosswalk. This file records the earlier inventory and does not describe current completion status. See [the current requirements ledger](../REQUIREMENTS.md) and [completion audit](../COMPLETION-AUDIT.md).

The table maps requirement names at the initial catalog checkpoint to `catalog.json` record IDs. Its outstanding-work column describes that checkpoint; later results are recorded in the current ledger linked above.

| REQUIREMENTS.md row | Catalog evidence | Still open (per REQUIREMENTS.md / this catalog) |
|---|---|---|
| Existing-library reuse decision | PH5-RELAY-001, PH5-UTIL-001, PH5-UTIL-003 | Measured reusable-contract transfer across MULTIPLE distinct utilities beyond one relay theorem: partially answered by PH5-CASE-001 (IOWorld.SafeRead/FullWrite reused unchanged into head_bytes/wc_lines), but those bodies are not yet closed |
| Trustworthy C representation | PH5-RELAY-001, PH5-RELAY-002 | Functional source theorem beyond AST-hash identity; see PH5-RELAY-007/008 for the functional/termination side |
| Byte-bearing memory and I/O | PH5-RELAY-005, PH5-RELAY-006 | Returned-status functional consequence and termination: NOW CLOSED by PH5-RELAY-007 (witness) and PH5-RELAY-008 (universal) -- both post-date REQUIREMENTS.md's "remains open" wording for this row; Jsub itself remains an unresolved library boundary for the safety-side theorems (PH5-RELAY-005) even though PH5-RELAY-007/008 do not need it |
| Nonvacuity and progress | PH5-RELAY-003, PH5-RELAY-007, PH5-RELAY-008 | Universal termination is now checked (PH5-RELAY-008) within the stated scheduled-environment model; termination against non-scheduled/host-OS environments remains out of scope by construction |
| Source-as-specification | PH5-RELAY-001, PH5-UTIL-001, PH5-CASE-001 | Source-preserving utility SUMMARY theorem (may still preserve source bugs) not attempted as a distinct artifact |
| Independent correctness calibration | PH5-UTF8-001 | C conformance and gettext caller transfer: explicitly NOT established; preserved as a stated negative result, not silently re-extended |
| Reuse beyond purpose-built relay | PH5-UTIL-001, PH5-UTIL-002, PH5-UTIL-003, PH5-CASE-001 | Generalized leaf adequacy / funspec specialization beyond the 4 linked TUs; CatFragmentVSU's own two export-wrapper Gprog-mismatches were fixed by lifting, not by specializing a general lemma |
| Aaron's frontend integration | PH5-INTEG-001, PH5-CALC-001, PH5-CALC-002, PH5-CALC-003, PH5-CALC-004 | General lowering/type/state correctness and a Bash text path through Aaron's OWN spec-language parser remain open; PH5-CALC-004 (the assignment aimed squarely at this row) produced NO artifact before a rate-limit interruption |
| Shell/query connection | PH5-SHELL-001, PH5-SHELL-002, PH5-SHELL-003, PH5-SHELL-004, PH5-RELAY-007 (ShellExit.v), PH5-RELAY-008 (UniversalShell.v) | Grammar-to-real-Bash fidelity and concrete C primitive execution connection are finite/inspected, not universal; PH5-SHELL-004's text frontend has no soundness proof |
| Final proof-assistant boundary | PH5-RELAY-005..008, PH5-SHELL-001 | Coq subchain single-kernel; Lean stays an independently checked reference (PH5-CALC-003); no checked Coq/Lean import exists anywhere in this catalog |
| Automation improvement | PH5-EVAL-001, PH5-EVAL-002, PH5-EVAL-003 | PH5-EVAL-002 is the "larger, independently designed evaluation" REQUIREMENTS.md asked for (90 cells, 3 models, 5 attempts/cell, effective helper ablation this time) -- 22/90 (24.4%) accepted; this demonstrates the evaluation now runs at the requested scale, not that automation "works" in general. Assisted/collaborative accounting (PH5-EVAL-003) is 1 cell only, not yet a meaningful sample |
| Paper contribution and artifact | PH5-ARTIFACT-001 | Single-command replay covers a representative cross-section (4/5 entries; VST behavioral proofs and the 90-cell matrix itself are NOT in the replay by design); manuscript files (`evaluation/DRAFT-PAPER.md`, `EVIDENCE-UPDATE.md`) exist but a consolidated reproducible artifact/manuscript reflecting ALL final results (esp. PH5-RELAY-008's universal result and PH5-EVAL-002's 90-cell matrix, both later than the manuscript's last refresh by pi-reviews/manuscript-evidence-refresh-1) has not been re-assembled |

## Rows in REQUIREMENTS.md's "Active workstreams" table, mapped to what actually shipped

| REQUIREMENTS.md assignment | What shipped (catalog ID) |
|---|---|
| Universal concrete C execution -> Claude universal-relay-4 | PH5-RELAY-008 (shipped; universal, Jsub-free, for both relay_main.prog and relay_exit.prog, plus UniversalShell.v) |
| Shell expansion -> Sonnet shell-expansion-4 | PH5-SHELL-002 (pipes, shipped), PH5-SHELL-003 (redirection, shipped), PH5-SHELL-004 (text frontend, partial only) |
| General calculus correspondence -> Sonnet calculus-correspondence-4 | PH5-CALC-004 -- NOT shipped; worker interrupted by an account rate limit after 158 turns with zero artifacts written |
| Additional non-UTF8 case studies -> Sonnet nonutf8-cases-4 | PH5-CASE-001 -- math relations shipped, C body proofs NOT closed for either case |
| Larger comparative evaluation -> Sonnet evaluation-artifact-4 | PH5-EVAL-002 shipped (90/90 matrix complete, tallied here for the first time from raw matrix.log) |
| Reproducible artifact and manuscript -> Sonnet evaluation-artifact-4 | PH5-ARTIFACT-001 shipped (partial by design); manuscript NOT re-consolidated against PH5-RELAY-008/PH5-EVAL-002 |
| UTF-8 calibration -> closed bounded experiment | PH5-UTF8-001 (closed as a negative result, per the project's own stop rule) |

No row above is marked complete in an absolute sense; REQUIREMENTS.md's own framing (a green bounded pilot is not completion of the research program) still governs. This crosswalk only says which catalog IDs are the current evidence for each row, and flags where catalog evidence is now MORE RECENT than REQUIREMENTS.md's own last-written text (the Byte-bearing-memory row and the Nonvacuity/progress row, both closed by PH5-RELAY-007/008 after REQUIREMENTS.md's "remains open" wording was written on 2026-09-07 ~09:00 UTC, before the 19:31-22:25 UTC adequacy-resume-3/universal-relay-4 sessions).
