# A bounded permission semantics repair, with an explicit coverage boundary

This adds an **opt-in** constant-mode normalizer and unsupported-mode boundary to Astrogator. It resolves numeric-versus-symbolic false rejections in a controlled supported subset and prevents one reproduced history-dependent permission counterexample from being reported as verified. It is a reviewable research prototype, not a proof that the whole verifier is sound or an improvement in overall corpus accuracy.

Apply `../adequacy/permission-classes.patch` first, then `permission-normalization.patch`. Both apply cleanly to pinned upstream `7c62afa51986d87033af5112cdccd3b104b1c120`; the resulting files were checked byte-for-byte against `source/`. Run the verifier with **`--constant-modes`** to activate this extension. Without the flag, the binary retains the revised narrow-patch behavior. The underlying ordinary-permission interpretation still needs Aaron's language-design review; special-bit-only behavior is preserved by the revised base patch.

## Supported subset and why it is bounded

The shared OCaml normalizer accepts:

- Quoted octal strings containing three or four octal digits, canonicalized to four digits.
- Exactly one `u=`, `g=`, and `o=` clause, in any order, with explicit constant `r`, `w`, `x`, and class-appropriate special bits.
- The same complete assignments containing `X` **only when every affected object is known to be a directory**. The Ansible integration requires explicit `state: directory` and absent or literal-false `recurse`; the FQL integration supplies that fact only for `CreateDir`.

Partial assignments, `+`/`-`, copied permissions, omitted classes, dynamic values, and regular-file/recursive `X` are not converted to a constant. With the flag enabled, these become an explicit **unsupported Ansible-lowering result**, not a verification rejection or evidence that the program is wrong. This boundary applies to the six upstream mode-bearing built-ins: file, copy, get_url, uri, lineinfile, and blockinfile. Tasks without `mode` preserve their prior behavior.

Bare YAML numeric values are conservatively unsupported in this integration: the upstream YAML parser represents them as `Float`, losing the integer-versus-float distinction needed here. A valid unquoted `0755` program can therefore become unavailable. The pure normalizer also has a bounded integer helper, but the Ansible integration deliberately does not use it to guess lost YAML types. Correctly preserving numeric scalar types is a separate parser improvement.

### Local semantic argument

For the supported symbolic subset, the assignment masks are disjoint: user `04700`, group `02070`, and other `01007`; their union is `07777`. Each `=` operation clears its mask and writes constant bits contained in that mask. With all three classes present, the resulting mode is the union of those constant bits, independent of initial mode and clause order. `X` satisfies this argument only under the directory premise; otherwise its bit contribution depends on prior execute permissions. Copied permissions and relative operations likewise violate the constant-bit premise.

This argument concerns Ansible's permission-operation semantics and the supported subset, not arbitrary playbooks, operating systems, the verifier's residual assumptions, or the FQL intent interpretation.

## Executed evidence

- **36,879 compiled OCaml normalizer cases**, including all 4,096 target modes, six symbolic clause orders, directory-`X` spellings, bounded integer inputs, and 15 declined boundary cases.
- **557,056 comparisons against Ansible 2.19.11's actual symbolic-mode interpreter.** Every target mode was tested across six orders, two object types, and eight initial states; directory `X` across every target and eight states; every initial mode across 16 boundary targets and both types. This is **not** the full 4,096-by-4,096 Cartesian product.
- **14 OCaml normalizer regressions and 9 revised base-patch regressions**, built from actual upstream libraries.
- **20 integration guard/control cases, 32 verifier calls**: unsupported forms across all six built-ins, unchanged no-mode controls, explicit nonrecursive-directory `X`, recursive/unknown `X`, dynamic values, and numeric scalar boundaries.
- **165 paired verifier cases**: default-disabled outcomes match the revised narrow patch. Enabled results are preserved individually; they are not all improvements.

The mode-operation comparison is against real Ansible source, not a second implementation of our normalization algorithm. The exact interpreter source and its hash are retained in `ansible-symbolic-source.txt` and `semantic-checks.json`. Runtime playbook executions are separately available in this directory and the adequacy artifact.

## Concrete effects—and counterweights

All five runtime-correct spellings in the original a22/a67 targeted panel are accepted with the option enabled, including numeric `0700` and complete symbolic assignments. The two incomplete assignments become unsupported. Added a23/setgid and a47 panels accept the complete symbolic forms and decline the incomplete forms; actual two-state execution confirms the distinction.

Six known-good numeric references (a22, a23, a24, a26, a47, a67) change from rejection to acceptance. Five corresponding discovery faults remain rejected. **The a26 `force:false` mutant also becomes accepted**, although it fails the existing-file runtime state. Its residual explicitly assumes the destination file is absent. Fixing permission representation exposes a query/precondition gap; it does not make that absent-file result a guarantee about existing files.

Independent Opus review predicted a stronger a32 counterexample: first apply recursive `a+x`, then recursive `u=rwX,g=rX,o=rX`. We executed it, and both runtime states fail because data files acquire execute permission. Original Astrogator, the narrow permission patch, and an early passive normalizer all accept it: the model stores only the final mode string and loses the relevant history. The final opt-in boundary declines this program. **It also declines the correct recursive-`X` reference**, demonstrating the coverage cost. Passive normalization alone was therefore insufficient; its code and results are retained in `archive/passive-v1/`.

## Full supplied-corpus impact

The final run covers all **2,238 processed programs**, retaining 72 missing attempts as missing.

| Outcome | Original verifier | Opt-in constant-mode boundary |
|---|---:|---:|
| Accepted with possible residuals |909|883|
| Verification rejected |619|589|
| Ansible lowering unavailable |710|766|
| Missing processed attempt |72|72|

Exactly **26 accepts and 30 verification rejections become unavailable**. No original-corpus program becomes newly accepted. There are 69 explicit unsupported-mode diagnostics in total; 13 were already unavailable. Their inspected forms comprise 56 programs with unquoted numeric modes, 2 with dynamic expressions, 8 with partial/other unsupported spellings, and 3 with conditional `X` outside the supported context.

Of the 56 changed programs, 8 have existing four-task execution labels: **7 pass those local checks and 1 fails**. The option consequently sacrifices real observed coverage; an unsupported result is not an error detection. The other 48 have no matching execution labels in that slice. This full-corpus experiment measures behavioral impact, **not accuracy improvement**. Every changed sample, its source path, mode values, original/new status, and available local label is in `corpus-summary.json`.

## Reproduction and review

`build.sh` rebuilds inside a bounded, offline Docker container. Launch it inside `agent-jobs.slice` under the workspace resource rules. `verify_integration.py`, `review_run.py verify`, and `guard_suite.py` are in-container drivers with the artifact root mounted at `/suite`; the integration driver enables `--constant-modes` unless invoked with `--off`. `review_run.py execute` invokes disposable containers and never runs Ansible on the host. The new review panel has 10 actual execution cases; the original permission panel contributes 14 more.

`final-run-inputs.json` pins final source, runner, and binary hashes. `summarize.py` validates sample identities, candidate hashes, unchanged default behavior, panel completeness, and source/binary hashes. Generated binaries live only under `.cache/` and can be rebuilt. `source-provenance.json` and `patch-application.json` record patch dependencies and validation. No upstream checkout or earlier experimental corpus was modified.

Development notes: one intermediate rebuild hit Linux's executable-in-use protection; final builds install the binary atomically, and all final runs use the frozen final binary. The complete passive-normalizer run is archived separately and is not mixed into final results. The final extension has not been merged, and the ordinary-permission interpretation has not been independently approved as FQL's intended contract.
