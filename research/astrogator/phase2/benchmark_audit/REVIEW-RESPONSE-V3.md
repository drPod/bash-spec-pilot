# Oracle v3: second review response

The second independent model review predicted two further survivors of v2: a Git skip-worktree flag hiding changes to a tracked file, and a destination directory replaced with a symlink to the source after copying unrelated destination files into it. These predictions are evaluated in `review-case-results-v3.jsonl`, separately from the review text. V2, including its patch, inputs and results, is preserved under `v2/`; v1 remains under `v1/`.

## Changes

**a53: direct tracked-byte expectations.** Setup enumerates the expected commit's tracked regular files and reads their blob bytes before candidate execution. For an existing checkout it independently confirms that the worktree bytes match that snapshot; the fixture therefore requires clean tracked bytes even if Git index flags suppress `diff`. The postcondition directly reads every expected tracked regular file and compares its bytes. HEAD equality, the original `version` check and the supplementary Git diff check remain. Tracked symlinks/submodules are explicitly outside the fixture contract, while untracked files are allowed. Merely setting skip-worktree without modifying content is a valid control.

**a70: direct roots and explicit preservation scope.** Both `/work/source` and `/work/dest` must remain direct directories according to `lstat`, preventing a symlinked destination root from passing leaf checks. The source's set of entries must remain unchanged, and the earlier per-file byte and per-directory type checks remain. This adopts an **unchanged-source-tree contract**, stronger than merely preserving all existing file bytes. The task wording should be reviewed by Aaron before adopting that stronger contract as gold. A source-extra-file case is explicitly marked interpretive in the design; it is not evidence that adding a file necessarily violates every reasonable reading of the original prose. Same-path destination file overwrites remain supported; unrelated destination files/directories remain preserved.

## Evidence layout

- `oracle-adequacy.patch`, `patched-suite/`, `build_patches_v3.py`: current proposal.
- `review-case-design-v3.json`: prior 14 cases plus six round2 cases, including valid controls.
- `review-cases-v3/`: complete Ansible programs.
- `review-case-results-v3.jsonl`: paired v2/v3 checks on identical execution states, with hashes and logs.
- `review-case-summary-v3.json`: checked totals and explicit interpretive-case separation.
- `patch-validation.jsonl`: rerun of the original 48 regression cases against v3; prior versions retained in archives.

This is targeted oracle repair, not a completeness proof. Both review rounds show why passing chosen mutation tests cannot establish complete benchmark ground truth. The current patch remains a reviewable proposal with explicit fixture assumptions and interpretations.

## Executed paired result

All 20 cases completed, totaling 32 successful Ansible executions. V3 accepted all 12 declared-valid cases and rejected all 8 declared contract violations. V2 accepted both independently predicted survivors: skip-worktree followed by a tracked-byte edit, and the symlinked destination. It also accepted the source-addition case, which is reported separately because its rejection depends on the explicitly stronger unchanged-source-tree contract. Excluding that interpretive case leaves 19 cases: v3 accepts 12 and rejects 7; v2 accepts the two predicted violations. The valid skip-worktree-only program passes both versions after two runs.

The v3 48-case regression also completed: all 16 reference/state controls pass twice; all eight original mutants remain detected in at least one state; all eight first-round challenge programs are rejected in both states. The panel contains 66 successful Ansible executions. Input hashes match the current patch, `git apply --check` succeeds, and all 294 original expanded-benchmark files remain unchanged.
