# Transfer assessment (case-transfer-finish-44)

## Original requirement (quoted)

scope-audit-correction-23 `NEXT.md` item **W**:

> Still open **as feasible**: wrapper-ident link analogous to
> `body_simple_cat_entry` + `semax_body_subsumption` — **not** GNU `main`,
> **not** `wc_lines_null_spec` as user-minimum, **not** FullWrite on `XWrite`.
>
> If wrapper-link is judged infeasible, record the concrete obstacle; do not
> call bodies a wrapper link.

Bodies already give the selected-function summary (`semax_body` POST
`HeadOutcome` / `WcLines`). Wrapper ident was the remaining as-feasible
piece.

## What was wrong with the interrupted CaseTransfer.v

Pre-edit snapshot (sha256 `f8bdf808…`): two wrapper `semax_body`s against a
*narrow* Gprog `[callee_spec; entry_spec]` with **no import** of
`HeadBytesBody` / `WcLinesBody`. `forward_call` therefore used the callee
funspec as an **assumed import**, not as the checked body. That is two
unconnected Gprogs: wrapper Gprog ≠ body Gprog. Compiling the wrapper does
**not** compose with `body_head_bytes` / `body_wc_lines`.

Require-inside-`Module` of both Clight TUs also hits Coq’s
`require-in-module` fragility: `CompSpecs` from `head_bytes_fragment`
leaks into the wc module (`f_wc_lines` expected `compspecs`).

## What was proved (this job)

Separate files (one CompSpecs per TU):

| File | Theorems | Receipt | exit | elapsed |
|---|---|---|---|---|
| `coq/CaseTransfer.v` | `body_head_bytes_lifted`, `body_head_bytes_entry` | `case-transfer44-CaseTransfer-2` | 0 | 2.01 s |
| `coq/CaseTransferWc.v` | `body_wc_lines_lifted`, `body_wc_lines_entry` | `case-transfer44-CaseTransferWc` | 0 | 2.30 s |

Pattern (same as `CatFragmentVSU.v`):

```
Gprog := Body.Gprog ++ [entry_spec]
body_*_lifted : semax_body Vprog Gprog f_* (spec)
  := semax_body_subsumption Body.body_* (tycontext_sub_Gprog_app1 …)
body_*_entry  : semax_body Vprog Gprog f_*_entry (entry_spec)
```

Both callee and wrapper are `semax_body` in **one** Gprog (the body’s
library+imports, plus the wrapper ident). No new imports, no VSU, no GNU
main, no `wc_lines_null_spec`. Body `.v` files untouched
(`HeadBytesBody.v` `34a0d006…`, `WcLinesBody.v` `998e78e7…`). No `Admitted`.

## What this is / is not

- **Is:** wrapper-ident link + Gprog-weakening of the already-checked
  bodies (item W as feasible).
- **Is not:** a VSU / `mkComponent` whole-TU linking theorem; not
  `semax_func` of the two functions together; not whole-program adequacy;
  not a Lean theorem.

Remaining if someone wants the cat-VSU analogue: `Component`/`VSU` for
each fragment TU (item 2 of `case-studies/NEXT.md`), which is **out of**
item W’s “not VSU” bound.

Pre-edit snapshot: `pi-reviews/case-transfer-finish-44/snapshot/CaseTransfer.v`.
