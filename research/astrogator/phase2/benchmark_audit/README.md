# Benchmark oracle adequacy audit

**Revision status:** the first oracle patch had a real a53 regression and additional gaps found by independent model review. The current patch is v3; v1/v2 and their results are preserved under `v1/` and `v2/`. Read [REVIEW-RESPONSE-V3.md](REVIEW-RESPONSE-V3.md) for the second review response and [REVIEW-RESPONSE.md](REVIEW-RESPONSE.md) for the first. No claim of complete oracle coverage follows from the mutation counts.

The phase-one claim that all 49 chosen mutants were killed does not establish oracle adequacy. This audit constructs eight additional, semantically distinct fault programs that the original fixture checks accept. The original files remain unchanged.

## Study design

`task-audit.json` records a source-level review of all 49 candidate tasks. Eight tasks with concrete omitted obligations were purposively selected for executable investigation. Selection was informed by reading the checks; this is a targeted counterexample study, **not an estimate of the frequency of bugs in the suite**.

Each new Ansible challenge program is the frozen reference followed by one explicit fault. Programs run through Ansible in a fresh network-disabled Debian container, not directly on the host. The original reference and challenge each run on (1) an original fixture and (2) an additional fixture authored after phase-one artifacts were frozen. Reference controls execute twice. Challenges execute once because a wrong postcondition is sufficient to establish an oracle counterexample; second-run idempotence of a faulty program is not the question.

The `original` fixture uses the original adversarial state except a68, which uses the original baseline absent-marker state. `heldout` means held out from phase-one validation; it does not mean human-authored, preregistered, hidden from this audit's author, or sampled independently. Additional states vary nested contents, binary payload, untracked Git files, unrelated cron jobs, child GIDs, and unrelated destination files.

The supplemental checks capture necessary task obligations and derive variable expectations from the prestate. They are **not claimed to be complete replacement oracles**. They are independent of the reference implementation's output, but developed by an AI author who could inspect the task and old checks. No independent-human-gold claim is made.

| Task | Newly exposed fault | Why the original check misses it |
|---|---|---|
| a24 sticky spool directory | Replace the directory with a regular file of mode 1777 | Checks mode, omits directory type |
| a32 recursive permissions | Leave root directory inaccessible to group/others at 0700 | Checks descendants, omits root |
| a34 hard link | Corrupt source bytes through the shared inode | Checks inode equality, omits contents |
| a53 preserve existing checkout | Create a new empty commit | Checks `version` file, omits commit identity |
| a58 scheduled job | Comment out the required cron entry | Checks substring rather than active parsed entry |
| a64 nonrecursive ownership | Change a child's group ownership | Checks child's UID and bytes, omits GID |
| a68 conditional directory | Create a regular file when cache must stay absent | Equates `not is_dir` with absence |
| a70 directory-content copy | Delete source hidden file after copying | Checks destination hidden file and one source nested file |

The source-byte preservation obligation in a34 is a reasonable reading of “hard link to /work/source,” but should receive explicit author review because preservation is less explicit than in a64/a70. Excluding it still leaves seven direct counterexamples to explicit obligations.

## Results and interpretation

All eight new challenge programs pass the original oracle on an original fixture. Across 16 original/additional-fixture challenge cases, 15 pass the old check and all 16 fail the supplemental obligation check. All 16 reference cases pass the supplemental check after each of two executions (48 successful Ansible executions total). One transient Docker CLI thread-allocation failure was retried without changing inputs; the initial attempt is retained in `program-results-initial.jsonl`.

See `summary.json` for checked counts and `program-results.jsonl` for full Ansible stdout/stderr, per-iteration outcomes, and input hashes. `program-protocol.json` pins the Docker image ID and runner hash. `challenge-programs/` contains the actual runnable wrong playbooks.

The additional a70 fixture deliberately changes hidden-file bytes. Its correct reference is rejected by the original, fixed-payload check but accepted by the prestate-derived check. This is **not a bug in the original check on its declared original fixture**. It demonstrates why simply varying fixture data without varying its corresponding expected result is invalid. That additional challenge is rejected by both checks and must not be counted as an old-oracle survivor.

`results.jsonl` is the retained exploratory poststate-fault run, before faults were materialized as complete Ansible programs. It is separate from the final executable-program results; do not combine its counts with them.

## Implications for the paper

1. Report mutation coverage per obligation, not a single “49/49 mutants killed” claim.
2. Treat preservation, object type, identity, scope/depth, conditional absence, and active configuration semantics as separate obligations.
3. Do not use the phase-one oracle labels as independent paper ground truth without reviewing their scope. This audit does not retrospectively relabel the separate original-corpus execution study.
4. Freeze challenge programs and reserve new faults/states for evaluation before tuning query validation or test-generation prompts. These eight faults are development examples now, not a future unseen test set.
5. Review benchmark task preconditions before generating challenges: duplicate port directives (a35), a misplaced existing allow rule (a38), and misplaced headers/settings (a65/a66) violate explicitly stated initial-state constraints and would be invalid reference counterexamples.
6. Authentication, service readiness, boot behavior, real package dependency resolution, and cross-OS behavior remain outside the narrow local fixtures. No claims about those properties follow from these tests.

## Reproduction

From the repository root, with the previously built `astrogator-lab:20260924-v2` image:

```sh
systemd-run --user --slice=agent-jobs.slice --wait --pipe --collect \
  -p MemoryMax=192M -p CPUQuota=30% \
  --working-directory="$PWD" \
  /usr/bin/python3 research/astrogator/phase2/benchmark_audit/run_programs.py
python3 research/astrogator/phase2/benchmark_audit/summarize.py
```

The runner overwrites its own result file; preserve prior runs before reproducing. Docker cases each have 384 MiB memory, 0.5 CPU, 96 PIDs, no network, an init process, and a read-only suite mount.

## Concrete oracle patch

`oracle-adequacy.patch` applies to the original eight benchmark setup/check files and passes `git apply --check`. It is **not applied** to the original artifacts. The same patched files are available in `patched-suite/` for inspection and isolated execution. `patch-input-hashes.json` pins original and patched bytes.

`validate_patches.py` mounts this replacement benchmark directory read-only over the original suite inside Docker, then exercises the frozen references, the original chosen mutants, and the eight new challenge programs from both original fixture states. `patch-validation.jsonl` retains those regression outcomes. This adds missing necessary checks; it does not establish complete coverage of every possible implementation or starting state.

Patch regression results: all 16 reference/state controls pass after both executions; all eight original mutants remain killed in at least one state (14/16 state cases); all eight new challenges are rejected in both states (16/16). The 48 cases contain 66 successful Ansible executions. All 294 original expanded-benchmark files still match the phase-one delivery manifest.
