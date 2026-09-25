# Independent review: phase2 `adequacy/` and `benchmark_audit/`

Reviewer stance: a skeptical PL reviewer, working from upstream source at
`/tmp/astrogator-upstream` (HEAD `7c62afa`, which matches `patch-provenance.json`) and the
retained artifacts. I executed nothing. Counterexamples marked **(predicted)** come from reading
the source and must be run before anyone cites them. `phase2/evaluation/` and the frontier runs
are still in progress, so I did not review them.

## Verdict

The central permission finding is real and correctly localized. The code generator (`lib/fql/codegen.ml:117-171`)
drops empty classes, and `modules/file.type` stores `mode` as an opaque string. Together these let
`u=rwX` stand in for "exact 0700". The oracle-audit counterexamples are also real. Four things
need correcting before any of this reaches Aaron or a paper:

1. The patch's "158 paired records, no categorical change" regression evidence is **vacuous by construction**.
2. The patch **silently changes the semantics of special-bit-only queries**, and the regression suite enshrines that change: `sticky=false` becomes mode 0000.
3. The opaque-string model remains **unsound for relative (`X`) modes even after the patch**. There is a concrete program shape the patch does not address.
4. The a53 oracle patch **drops an obligation the original check enforced**, and the a24/a68 patches are defeated by symlinks.

## 1. Permission patch (`adequacy/permission-classes.patch`)

### 1a. The broad regression rerun cannot detect a change (major; rewrite the claim)

Across all queries in the repo, the patch changes emitted mode strings for exactly four tasks:
a22 (`u=rwX`→`u=rwX,g=,o=`), a23 (`u=rwX,g=rwXs`→`…,o=`), a47 (same as a22), and a67 (`u=rwx`→`u=rwx,g=,o=`).
a24, a26, a32 and upstream `playbooks/bench/query04.txt` already emit all three classes, so the patch cannot affect them.

Every reference, discovery mutant and held-out challenge on those four tasks uses a **numeric** mode
(`0700`, `2770`, `0755`, `0701`, `0770`, `1770`, `0600`, `0777`; see `benchmarks/expanded/*/reference.yml`,
`mutant.yml` and `adequacy/cases/*`). A numeric string can never equal a symbolic one, before or
after the patch. So "158/158 unchanged" was guaranteed in advance and says nothing about compatibility.

- **Correction:** delete "A paired rerun of 158 … had no categorical outcome changes" as evidence. At most, note that it confirms the patch touches no numeric-mode program. Also state that the patch touches no query in upstream's own benchmark, which is a genuine and useful low-risk point.
- a23 and a47 change but are **absent from the targeted panel**. Add `u=rwX,g=rwXs,o=` and `u=rwX,g=rwXs` for a23, and the a22 pair for a47. The setgid case is the one where Ansible's `=` handling of special bits matters.

### 1b. Behavior change for special-bit-only queries (major; decide or revert)

`semant.ml:64-75` produces `setuid`/`setgid`/`sticky : bool option` directly from `=true`/`=false`.

- **Upstream:** `sticky=false` alone produces an all-empty string, so no mode assignment (no constraint).
- **Patched:** the same query produces `u=,g=,o=`, i.e. **mode 0000**. The test "explicit false special bit is not an unspecified mode" asserts exactly this.
- **Example:** `create directory at /d with sticky=false` now requires an inaccessible directory.
- Similarly, `setgid=true` alone goes from `g=s` to `u=,g=s,o=` (mode 2000). Upstream's `g=s` already wiped group rwx. The patch extends that damage to all classes.

The README describes the convention ("specifying permissions determines the whole permission set")
as documented. Its only source is the in-code comment at `codegen.ml:115-116`, and the code
disagrees with that comment. Whether FQL permissions are total or partial is a language-design
question for Aaron, not a bug fix.

**Actionable:**
- Either emit `g=`/`o=` only when at least one r/w/x/list field is present (special bits alone keep upstream behavior), or flag the change explicitly.
- Remove or relabel the two regression cases that lock in 0000 and 7000 as "intended".
- Reword "concrete defect … patched" as "concrete defect; a proposed fix under the total-permission reading of FQL".

### 1c. The model stays unsound for relative symbolic modes after the patch (major; add to limitations and test)

`file.type:80-81,97-99` sets `fs(p).mode = mode`, overwriting history. This is sound only when the
spec's mode string is an *absolute* operation. Once a mode contains `X`, its result on a regular
file depends on the prior execute bits, and the model has discarded those bits.

**Counterexample (predicted), a32** (`u=rwX,g=rX,o=rX`, recursive, unaffected by the patch):
1. `file: path=/work/tree recurse=yes mode=a+x`
2. `file: path=/work/tree recurse=yes mode=u=rwX,g=rX,o=rX`

The final modeled string equals the spec, so a final-state verifier should accept. At runtime,
`/work/tree/sub/data` becomes 0755. That violates "without making initially nonexecutable regular
files executable", and the patched oracle would reject it.

The same pattern works on the original codegen for a22, with `mode: '0777'` followed by
`mode: 'u=rwX'`, which is a second route to the reported a22 bug. After the patch, a22 and a67 are
safe only because `X` on a directory, and a mode with no `X`, are absolute.

**Actionable:** run this two-task program through the verifier and a runtime state. If confirmed,
it is a stronger and more general finding than the codegen patch. It sets the precise soundness
condition to state: string equality is sound only for absolute modes.

### 1d. Accurate but under-emphasized

- The patched verifier still rejects 2 of 3 correct a22 spellings (`0700`, `u=rwx,g=,o=`). Other semantically identical spellings (`go=,u=rwX`, `u=rwX,go=`, `a=,u=rwX`) will also be rejected (predicted). The patch swaps which single spelling is accepted; it does not make the verifier complete. The README table shows this, but the prose ("the patch rejects/accepts") reads as a fix.
- In the adequacy screen, **6 of 8 "reference rejected" tasks (a22, a23, a24, a26, a47, a67) share one root cause**: the numeric-versus-symbolic string mismatch. Report it as one incompleteness, not six. It is the dominant verifier incompleteness in this sample.

## 2. Adequacy screen design (`adequacy/`)

- **Most challenge evidence carries no information about the candidate query.** Of 14 distinct challenges, 9 are on tasks whose candidate query rejects the known-good reference (a22, a23, a24, a26, a47, a63, a67). Their "candidate: verification_rejected" entries are not detections. Only a27 (2), a64 (2) and a45 (1, passes local checks) exercise a query that accepts its reference. State this denominator explicitly.
- The **a27 counterexample holds** and is the strongest result here. The weakened query accepts the reference, rejects the old mutant, and accepts both copy-omitting challenges, which fail at runtime in both states. One caveat: the old a27 mutant was "killed" at runtime only by an `execution_error` in baseline; it *passed* the adversarial check. So the discovery screen's own mutant is weak evidence too. Mention this.
- For the permission tasks, the omission-control results ("8 of 9 accept the discovery mutant") follow by construction: a query without a mode obligation cannot see mode faults. They are fine as sanity controls but are not findings.

## 3. Oracle patches (`benchmark_audit/oracle-adequacy.patch`)

The eight counterexamples to the *original* checks are legitimate. The patches have these problems:

| Task | Problem | Concrete survivor (predicted) | Fix |
|---|---|---|---|
| **a53** | **Regression.** The patch *replaces* `read(version)=='main'` with a HEAD-commit check, so working-tree content is no longer checked. | Adversarial state: after the reference, `copy: remote_src=yes src=/fixtures/repo/version dest=/work/checkout/version`. HEAD is unchanged, so the new check passes, but `version`=`new-main`, so the old check fails. Baseline: clone, then overwrite `version`. | Keep both assertions and add `git status --porcelain` empty. Then add this program to `patch-validation`. The claim "adds missing necessary checks" is currently false for a53. |
| a24 | `is_dir()` and `mode()` (`container_case.py:30`, `os.stat`) follow symlinks. | Replace `/work/spool` with a symlink to `/tmp`, a 1777 directory. | Use `os.lstat` and `stat.S_ISDIR`, plus `not is_symlink()`. |
| a68 | Same symlink hole in the adversarial branch. | Adversarial state: `/work/cache -> /tmp`. | Add a `lexists`/`lstat` directory check. |
| a70 | Files only: empty source directories and symlinks are not required in the destination. If a fixture ever has a destination file at a copied relative path, the two loops assert contradictory bytes and the check becomes unsatisfiable. | Omit empty source subdirectories. | Compare directory sets too, and assert that the prestate source and destination paths are disjoint in setup. |
| a64 | Only children with `is_file()` are covered. The NL says "files", so this is acceptable, but a nested child directory's ownership is unchecked. | — | Optional: cover every `lstat` entry. |
| a32 | The expected mode for initially executable files hard-codes Ansible's `X` result (0755). The NL ("grant … everyone read") does not require world-execute, so a 0744 result from a correct non-`X` program would be rejected. No current fixture has such a file, so it is latent. | — | Say the oracle encodes `X` semantics, or accept either result. |
| a58 | Adequate for the stated fault. An extra unnamed active duplicate job would still pass. | — | Minor. |

The a34 source-preservation obligation is correctly flagged as interpretive. The a70 held-out
note (don't vary fixtures without varying the expected results) is correct and worth keeping.

## 4. Claims to fix (short list)

1. `adequacy/README.md`: remove the 158-rerun claim as compatibility evidence (1a).
2. `adequacy/README.md`: disclose the special-bit-only behavior change, and reframe the patch as depending on the chosen FQL semantics (1b).
3. `adequacy/README.md`: add the relative-mode (`X`) unsoundness of the opaque-string model as the general limitation, with the a32 two-step test (1c).
4. `adequacy/README.md`: attribute 6 of 8 reference rejections to one cause (1d), and give the informative challenge denominator (§2).
5. `benchmark_audit/README.md`: the a53 patch weakens the oracle. Fix it, and harden a24/a68 against symlinks before claiming "all eight new challenges are rejected" means the gaps are closed.

## What is solid

- The permission mechanism is correctly localized and independently cross-checked at runtime in `PERMISSION-CROSSCHECK.md`.
- The a27 single-mutant-inadequacy counterexample is solid.
- All eight old-oracle survivors are genuine.
- The artifacts are honest about who authored them and about the meaning of "held-out".
- The patch applies to the pinned commit and touches nothing in upstream's own benchmark.
