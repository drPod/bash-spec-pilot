# Wrapper-ident transfer (`head_bytes` / `wc_lines`)

Link each fragment’s export wrapper to the already-checked body, analogously to `body_simple_cat_entry` + `semax_body_subsumption`. Not GNU `main`, not `wc_lines_null_spec`, not FullWrite on `XWrite`.

Separate files, one `CompSpecs` per translation unit:

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

Callee and wrapper are `semax_body` in one Gprog (body library + imports + wrapper ident). No new imports, no VSU, no GNU main, no `wc_lines_null_spec`. Body files untouched (`HeadBytesBody.v` `34a0d006…`, `WcLinesBody.v` `998e78e7…`). No `Admitted`.

Not a VSU / `mkComponent` whole-TU theorem; not `semax_func` of both functions together; not whole-program adequacy; not a Lean theorem. A cat-VSU analogue (`Component`/`VSU` per fragment TU) is item 2 of [`NEXT.md`](NEXT.md), outside this wrapper-ident bound.

## Why an earlier `CaseTransfer.v` did not compose

A pre-edit snapshot (sha256 `f8bdf808…`, `pi-reviews/case-transfer-finish-44/snapshot/CaseTransfer.v`) proved two wrapper `semax_body`s against a narrow Gprog `[callee_spec; entry_spec]` without importing `HeadBytesBody` / `WcLinesBody`. `forward_call` therefore used the callee funspec as an assumed import. Compiling the wrapper does not compose with `body_head_bytes` / `body_wc_lines`. Requiring both Clight TUs inside one `Module` also leaks `CompSpecs` (`f_wc_lines` expected `compspecs`).
