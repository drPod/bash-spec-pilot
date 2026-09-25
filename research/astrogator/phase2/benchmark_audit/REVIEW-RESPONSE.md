# Oracle patch v2 revision after independent model review

Historical v2 report: the current proposal is v3; see [REVIEW-RESPONSE-V3.md](REVIEW-RESPONSE-V3.md). All v2 files and results are preserved under `v2/`.

The first patch was not adequate. In particular, a53 introduced a regression by replacing the old working-tree content assertion with a HEAD identity assertion. Killing the chosen mutants did not prevent this regression. The first patch, its suite, README and 48-case results are preserved unchanged in `v1/`.

The archived v2 `oracle-adequacy.patch` and `patched-suite/` were built by `build_patches_v2.py`. The first generator is retained under `v1/build_patches.py` as historical evidence. The current `build_patches.py` delegates to the latest generator.

## Changes and interpretations

- **a53:** keep the original `version == main` assertion and add HEAD equality. Also reject tracked changes with `git diff --quiet HEAD`. This is scoped to fixtures whose tracked worktree is initially clean, explicitly checked in setup; untracked files are allowed. It is not an assertion that all naturally described existing checkouts must be clean.
- **a24/a68:** inspect object type with `lstat`, so symlink aliases to `/tmp` no longer satisfy the directory requirement. This adopts the direct-directory interpretation of the task. A human task reviewer should confirm that interpretation; an ordinary path-based reading of “is a directory” can permit symlinks.
- **a70:** snapshot and check empty directory structure as well as regular-file bytes. Source and destination fixtures explicitly exclude symlinks and file/directory type conflicts. Same-path regular-file collisions are supported, not forbidden: copied source bytes win, and only unrelated destination bytes are preserved. This avoids the contradictory expectations in v1.
- **a32:** check the stated necessary permissions instead of requiring a specific `X` implementation. Every object requires owner read/write and group/other read; directories require traversal; initially nonexecutable regular files must remain nonexecutable. An initially executable regular file may finish at 0744 or 0755. The oracle does not invent a requirement to revoke other preexisting write or special bits. Fixture symlinks are excluded explicitly.

These checks remain necessary-condition checks with explicit scope, not complete semantic oracles. a34 source-byte preservation remains interpretive. a64 checks regular-file children; it does not claim to preserve every directory metadata field. a58 does not yet detect every possible redundant unnamed cron entry. Passing this revision's tests does not establish completeness.

## New review cases

`review-case-design.json` freezes 14 cases and their expected validity under the declared fixture contract. `review-cases/` contains complete Ansible playbooks. `review-case-results.jsonl` compares v1 and v2 checks against the same actual execution state, with full stdout/stderr and input hashes.

The cases include directory symlink substitutions, dirty tracked `version` and a second tracked file while preserving HEAD, an allowed untracked file, omitted empty source directories, a valid overlapping destination overwrite, and an initially executable regular file finishing at valid mode 0744. References and the valid alternative execute twice; deliberate violations execute once.

The same original 48-case regression panel is rerun for v2 in `patch-validation.jsonl`; v1 results remain under `v1/`. V2 should retain all reference controls and the original/new mutation detections while correcting the independently identified false accepts and false rejects. See the machine-checked summaries for actual outcomes.

The review cases are now development cases. They cannot be represented as future unseen evaluation data or as independent human gold. The reviewer made source-level predictions without execution; this audit supplies the execution evidence separately.

## Executed review-panel result

All 14 cases completed (23 successful Ansible executions). V1 falsely accepted all five deliberate violations and rejected two of the nine valid cases (overlapping copy destination; mode0744 alternative). V2 accepted all nine declared-valid cases and rejected all five violations. The clean-tracked/untracked control passed both versions. These are selected counterexamples and controls, not population accuracy rates.

The completed v2 regression also passes: 16 reference/state controls succeed twice, all eight original mutants remain detected in at least one state, and all eight first-round challenge programs are rejected in both states. This is 48 cases and 66 successful Ansible executions. Recorded setup/check hashes match the current v2 patch. `git apply --check` succeeds; original benchmark files remain unchanged.
