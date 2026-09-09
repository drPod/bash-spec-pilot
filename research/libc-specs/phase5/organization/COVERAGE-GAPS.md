# Coverage and gaps

## Draft source with zero build/proof evidence (corrected after cross-check with organization-audit-5)

- **`PH5-CALC-004` (calculus-correspondence-4)**: assignment was the strongest-requested item
  ("general mechanically-checked source-to-calculus correspondence", explicitly not more
  hand-picked examples). 158 turns, ~45.4M cache-read tokens, $13.17, then an account rate-limit
  exit; wrote no STATUS/REPORT/NEXT. It DID leave real draft source: `integration/lean/
  CalculusExport.lean` (733 lines, last write 23:15Z, i.e. its final act before the rate limit),
  `ExportMain.lean`, and a `lakefile.toml` edit wiring both into `defaultTargets`. A `lake build`
  was at least invoked (a build-cache copy and a partial `.setup.json` exist) but produced NO
  `.olean` for either file -- never a successful compile, let alone a proof check. Separately,
  `research/libc-specs/phase5/calculus-correspondence/` (a different path this worker's own
  prompt.txt named as its intended new area) holds only two empty subdirectories, independently
  confirmed by this cataloging worker to have mtimes inside this same worker's run window (not
  an unrelated older clone, contra a claim relayed via `organization-audit-5`'s coordination
  note -- see `PH5-CALC-004.distinctions` in `catalog.json` for the full discrepancy note).
  REQUIREMENTS.md's "General calculus correspondence" row is still open either way: draft,
  never-compiled source is not evidence of a correspondence theorem.

## Interrupted-then-resumed workers whose FIRST attempt is superseded, not evidence

- `adequacy-resume-2`, `calculus-resume-2`, `calculus-semantics`, original `utility-reuse`,
  `utility-linking-3`: all exited 1 (account spend limit) or in utility-linking-3's case exited
  claiming a background wait that had actually already terminated (container job hit a 180s
  wall limit, `exit_status: 124`). None of these five have a REPORT.md; their in-progress work
  was inspected and, where sound, carried forward by a named successor (see catalog
  `prior_or_superseded` fields on `PH5-UTIL-001`, `PH5-UTIL-002`, `PH5-CALC-002`). Do not cite
  these five job dirs directly as evidence; cite the successor catalog record instead.

## Checked-but-explicitly-partial (the proof/observation is real; do not overclaim its scope)

- `PH5-CASE-001`: neither `head_bytes` nor `wc_lines` has a closed `semax_body`. The math
  relations (`HeadOutcome`, `WcLinesShort`) are checked Coq definitions/lemmas ABOUT THEMSELVES,
  not yet connected to the compiled C bodies.
- `PH5-SHELL-004`: the pipe/redirect text frontend has 4 accept + 4 reject vm_compute checks and
  no soundness proof — the weakest-evidenced item in the shell workstream.
- `PH5-UTF8-001`: differential/oracle evidence is strong (1.19M cases); the actual VST
  C-conformance body proof and the gettext caller-transfer step were not attempted to
  completion — recorded by the project itself as a stop-rule negative result.
- `PH5-ARTIFACT-001`: single-command replay intentionally excludes the VST behavioral proof
  chain and the 90-cell evaluation matrix; it is a smoke test, not a full-coverage replay.
- `PH5-EVAL-002`/`PH5-EVAL-003`: matrix is complete (90/90) but no REPORT.md/summarize.py output
  exists yet; the assisted/collaborative sample is 1 cell, far below a usable sample size.

## Distinctions this catalog was specifically asked to preserve (see individual `distinctions` fields)

- Helper proof vs actual source body: `PH5-UTIL-001`'s four body proofs are over the real pinned
  gnulib/coreutils C; `PH5-CASE-001`'s reused `IOW.SafeRead`/`IOW.FullWrite` are the same real
  contracts, but `head_bytes`/`wc_lines` bodies are NOT yet connected to them.
- Linking vs whole CLI: `PH5-UTIL-002` is a real `linkVSUs` program-level link of 4 TUs, but it
  is not a verified `main`/CLI-argument-parsing entry point for GNU `cat`.
- Universal vs witness: `PH5-RELAY-007` is existential (one execution per world);
  `PH5-RELAY-008` is universal (bounded, all executions). Both are Jsub-free; `PH5-RELAY-005`
  (safety) still carries Jsub and is a different, weaker kind of statement (safety, not
  functional return).
- Finite OCaml crosscheck vs general proof: `PH5-CALC-001`/`PH5-CALC-002` are finite
  observational agreement (2006, 2046, 63 cases) plus a Coq oracle over a FIXED finite case
  list; `PH5-CALC-003` is 11 hand-transcribed programs with hand-predicted-then-compared
  structural agreement — none of this is a theorem about the OCaml source code itself.
- Abstract pipe scheduler vs real OS: `PH5-SHELL-002`'s pipe/SIGPIPE model is a named, stated,
  single deterministic scheduling function — not a claim about kernel pipe/process behaviour.
- AST typecheck vs behavioral proof: `PH5-UTF8-001`'s VST funspec typechecks
  (`start_function` accepts it); this is not a `semax_body` proof.

## What organization-audit-5 (parallel independent auditor) should specifically re-check

Per its own prompt.txt (read, not duplicated here): the 90-cell matrix counts (this catalog's
independent re-tally from raw `matrix.log` — 22/59/6/3 — should be cross-checked against its own
count); shell worker's claimed deliverables vs actual text-soundness/composition/Bash-check
scope (`PH5-SHELL-001..004`'s `distinctions` fields already flag the specific limitations);
`PH5-CASE-001`'s two open body proofs (must not become "wc -l verified"); `PH5-CALC-004`'s
quota-exit and lack of any artifact; `PH5-RELAY-008`'s exact quantifiers/assumptions/final
receipt/source identity (this catalog transcribed the theorem shapes from the universal-relay-4
REPORT.md verbatim — an independent re-read of `AuditUniversal.v`'s own `Print Assumptions`
output would strengthen this).
