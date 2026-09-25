# Independent review, round 2: revised permission patch, constant-mode boundary, oracle v2

Reviewer: Claude Opus 5.5 (model review, not a human review). I read the revised READMEs, both
permission patches, `REVIEW-RESPONSE.md`, the v2 checks for a24/a32/a53/a68/a70, and upstream
source at `/tmp/astrogator-upstream` (`modules/*.type`, `lib/ansible/{ast,semant}.ml`). I executed
nothing and modified nothing. Every **[source]** item is a fact read directly from code. Every
**[predicted]** item is a counterexample I derived without running it, so it must be executed
before anyone cites it.

## Verdict

The first-round findings were substantively addressed. The adequacy README no longer uses the
158-run as compatibility evidence. Single special bits keep their upstream behavior. The a32
history counterexample was executed and is now declined under the flag. a53 no longer weakens the
oracle.

The constant-mode normalizer is semantically justified *for the strings it accepts*. I found no
accepted string whose Ansible result differs from the normalized octal value. Two problems remain
before the boundary can be described as it currently is:

1. **The boundary is keyed on the argument name `mode`, not on mode-bearing effects.** `copy`'s
   `directory_mode` is modeled as a mode write and bypasses the guard entirely. So "this boundary
   applies to the six mode-bearing built-ins" is inaccurate as written.
2. **On the real corpus the flag is a pure coverage loss.** It makes zero programs newly
   accepted, 26 accepts become unavailable, and 7 of the 8 labeled losses are runtime-correct.
   The benefit shows up only on the authored panel. The README reports these numbers honestly,
   but it should draw the conclusion outright rather than leave it implicit.

Neither problem invalidates the work. Both change how it should be described.

## 1. Is the normalizer semantically justified?

**[source]** `Permission_mode.normalize` (`permission-normalization.patch`, new
`lib/modules/permission_mode.ml`) accepts only two kinds of input:

- 3–4 digit octal strings;
- exactly three comma-separated clauses of the form `c=perms`, with `c ∈ {u,g,o}` distinct, and
  `perms ⊆ {r,w,x}` plus `s` only for u/g, `t` only for o, and `X` only when `~directory`.

It declines everything else: `+`/`-`, `a`, multi-letter who (`ug=`), permission copying (`u=g`),
whitespace, `0o` prefixes, 5-digit octal, and `t` in u/g or `s` in o. All of those are valid in
Ansible, so declining them only costs coverage.

I checked this against Ansible's `=` semantics, as retained in `ansible-symbolic-source.txt`
(`_apply_operation_to_mode`, `_get_octal_mode_from_symbolic_perms`):

- The per-class `=` masks are `S_IRWXU|S_ISUID`, `S_IRWXG|S_ISGID` and `S_IRWXO|S_ISVTX`. They are
  disjoint and together cover 07777, so the README's disjoint-mask argument is correct.
- `use_umask` applies only when the who-list is empty, which the normalizer rejects.
- For octal strings, Ansible's `int(mode, 8)` path agrees on every accepted input.

**The accepted subset is sound as a function from string to final mode of the object `chmod`
touches.**

Caveat on the evidence: the 557,056-comparison differential covers only the three symbolic
helper functions. It does not exercise `set_mode_if_different`'s octal path, symlink/`lchmod`
handling, or parent-directory creation. Those match by inspection, but the README should say they
are not differentially tested.

**Directory premise on the Ansible side.** The guard requires literal `state: directory` and a
`recurse` that is absent or literal `Bool false`. **[source]** `file.type:65-116` then writes the
mode only to `path`. In real Ansible, `state: directory` either operates on a directory (following
a symlink to one) or fails ("already exists as a file/link"). So `X` is constant there.

Two consequences of how the guard reads arguments:

- A YAML `recurse: no` that parses as a string, or a templated state, falls to the declined
  branch. That is conservative.
- The guard reads raw `Parsed` args with `List.assoc_opt` (first binding wins). If the parser
  keeps duplicate YAML keys, Ansible uses the last binding. `state: directory` followed by a
  duplicate `recurse: true` would then pass the guard. **[predicted, low severity]** Depends on
  whether the parser keeps duplicates, which I did not check.

**Spec side.** **[source]** `codegen.ml` passes `~directory:true` only for `CreateDir`, which is
correct. A new inconsistency appears under the flag:

- The all-special-bits spec (`setuid=setgid=sticky=true`) still emits `u=s,g=s,o=t`. The base
  regression "special permissions retain their class" locks this in. Because it has three
  clauses, it now normalizes to **exact mode 7000**.
- One or two special bits (`g=s`, `u=s,g=s`) stay symbolic and become unmatchable.
- The same applies to `read=none` alone: it emits `u=,g=,o=` and becomes exact 0000.

Round 1 asked to relabel the 0000/7000 lock-ins. The 0000 case was fixed only for special-bit-only
input. It survives for `read=none`, and 7000 survives unchanged. These are incompleteness and
interpretation problems, not unsoundness: a program writing 7000 does set all three bits. They
belong in the list of interpretation choices Aaron must make.

## 2. The unsupported boundary has a hole: `directory_mode`

**[source]**

- The guard (`semant.ml` hunk) rewrites or rejects only `key = "mode"`.
- `copy.type:51` declares `[directory_mode: string]`.
- `copy.type:101-102,158-160` together with `copy_helper:35` assign it verbatim to
  `fs(dst).mode`.

So under `--constant-modes`, `directory_mode: "g+w"`, `"u=rwX"`, `"0o755"` or `"{{ m }}"` enter the
model as opaque strings with no diagnostic. That is exactly the behavior the flag claims to rule
out.

**How far this is exploitable [predicted]:**

- It cannot produce a false accept against a *normalized* spec. Normalized spec values are always
  4-digit octal, and only a literal 4-digit `directory_mode` can equal one. For a directory, that
  literal is constant.
- It *can* produce string-equality acceptance against any spec value that stays symbolic under
  the flag:
  - `X` outside `CreateDir`, e.g. a query like `set file permissions of /work/d to read=owner,
    write=owner, list directory=owner`;
  - special-bit-only specs (`g=s`).
- Example: `copy: remote_src=yes src=/fixtures/dir dest=/work/d directory_mode="g=s"`, with
  `/work/d` absent, satisfies a `g=s` directory spec purely by string equality. Real Ansible
  applies relative `g=s` to a umask-derived mode.
- I could not build a clean *runtime-wrong* end-to-end case in the time available. FQL only
  generates `=` clauses, and `directory_mode` only writes directories, where `=`/`X` is constant.
  So the realistic impact is small.

The claim still needs fixing:

- **Actionable:** apply the guard to `directory_mode` too (in copy it is always a directory mode,
  so `~directory:true` is justified when nonrecursive semantics hold). Add a guard case for it,
  and reword "applies to the six mode-bearing built-ins" as "applies to argument `mode` of…" until
  this is fixed.
- **[source]** Other model-side mode sources are outside the guard: `mode_of_umask(env().umask)`,
  an uninterpreted function (`fs.type:17`), and `user.type:93-95` (`copy_helper` with the old
  home's mode). Residual assumptions over `mode_of_umask` can therefore still "equal" a normalized
  constant. That is pre-existing, but it deserves a sentence.

## 3. Does the boundary actually fix the history bug?

- **With the flag on:** yes, for `mode`. Every `mode` value the program writes is either a
  constant or a lowering failure, so "final mode = last constant written" holds per object. This
  relies on `file.type:69-82` applying recursive octal to every entry of `files`, which is correct
  for Ansible's recursive chmod.
- **With the flag off:** the a32 `a+x` then `u=rwX,…` program is still accepted (confirmed by the
  authors' own run). The default verifier remains unsound for relative modes, and the flag does
  not change that. Any published verifier result must say which mode it ran in.
- **Coverage cost:** the flag also declines the correct a32 reference. No `mode` spelling can
  satisfy the a32 spec under the flag, because the spec's `X` string stays symbolic and every
  program-side `X` on files is declined. **[source-derived]** So a32 is *unverifiable* under the
  flag, not merely harder to verify. Say so.

## 4. Real-corpus effect: say the conclusion plainly

**[artifact]** 909→883 accepted, 619→589 rejected, 0 newly accepted. 56 of the 69 diagnostics are
unquoted YAML numerics, which **[source]** `parser.ml:395,544,580` turns into `Float`.

The six reference flips happen only on the authored panel. On supplied programs the flag
recovers nothing, and it discards accepts whose modes are often irrelevant to the query: the
guard is global, while a query may carry no mode obligation at all.

A stronger design:

- Lower unsupported mode writes to a fresh value that *cannot* appear in residual assumptions,
  instead of failing the whole lowering. Queries that don't constrain that object would keep
  their outcome. Queries that do would fail to verify rather than be accepted.
- Fix `Float` scalar preservation. Numeric scalars are the dominant loss.

Until then, describe the flag as "a soundness guard with net-negative coverage on the supplied
corpus", not as a repair of numeric-versus-symbolic false rejections.

## 5. Oracle v2 (`benchmark_audit/`)

- **a53:** fixed. `check.py` keeps `version == 'main'`, adds HEAD equality, and
  `git diff --quiet HEAD` covers both staged and unstaged tracked changes. Residual
  **[predicted, contrived]**: `git update-index --skip-worktree other` followed by editing `other`
  passes, because the direct `version` read covers only that file.
- **a24/a68:** `os.lstat` on the leaf closes the `/work/spool -> /tmp` survivor. Parent-path
  symlinks are not checked, but exploiting that would require replacing `/work`, so I consider it
  negligible.
- **a70: new survivor [predicted].** `check.py` `lstat`s only the leaf of each expected path and
  never checks for extra entries in `/work/source`. The following program should pass:
  1. copy the unrelated destination files into `/work/source`;
  2. replace `/work/dest` with a symlink to `/work/source`.

  Every `P('/work/dest',rel)` then resolves through the symlinked parent to a regular file with
  the right bytes (colliding paths hold source bytes, as required), and `/work/dest/source` does
  not exist. The task intent (copy into dest, leave source alone) is violated twice.
  **Fix:** `lstat('/work/dest')` must be `S_ISDIR`, and the source tree's set of entries must
  equal its prestate.
- **a32:** now checks necessary conditions only and accepts 0744/0755 for initially executable
  files. This addresses round 1.

## 6. Round-1 findings: status

| Round-1 item | Status |
|---|---|
| 1a vacuous 158-rerun | Addressed; wording now correct. a23/a47 panels added. |
| 1b special-bit semantics | Addressed for 1–2 special bits. **Not addressed:** `u=s,g=s,o=t` (7000) and `read=none` (0000) remain, and under the flag they become exact modes (§1). |
| 1c relative-mode unsoundness | Confirmed by execution. Fixed only under the opt-in flag, and incompletely (§2). Default remains unsound. |
| 1d one root cause / completeness | Addressed; the flag accepts equivalent spellings in the supported subset. |
| §2 denominators, a27 caveat | Addressed. |
| §3 a53 regression | Fixed. |
| §3 a24/a68 symlinks | Fixed for the leaf. |
| §3 a70 | Directories are now checked, but there is a new symlinked-parent survivor (§5). |

## Required changes before citing

1. Guard `directory_mode`, or narrow the boundary claim to the `mode` argument (§2).
2. State that under the flag, a32 (and any `X`-on-files spec) is unverifiable by construction (§3).
3. State that the flag has zero net benefit on the supplied corpus, with the Float parser as the
   main cause (§4).
4. List the 7000/0000 exact-mode consequences among the interpretation choices for Aaron (§1).
5. Execute the a70 symlinked-destination program. If it survives, fix the check (§5).
6. Every verifier result reported anywhere must name its mode (default vs `--constant-modes`),
   because the default remains unsound for relative modes.
