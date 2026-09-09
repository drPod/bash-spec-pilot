# Next steps for the case-studies pair (after case-proofs-9, 2026-09-08)

Read `RESULTS.md` first. Both body theorems (`body_head_bytes`,
`body_wc_lines`) are checked and replayed; what follows is what is still
open, plus the VST traps met while closing `wc_lines` (so a successor does
not rediscover them).

## 1. Open items

1. `wc_lines_null_spec` (`CaseSpecs.v`, checked funspec): prove it as a
   second `semax_body` for `f_wc_lines` (separate `Gprog` since one id can
   carry one spec per Gprog). `destruct (eq_dec lp nullval)` first; in the
   `lp <> nullval` case the SEP `if` reduces to `data_at_` and gives the
   `valid_pointer` the `!lines_out` test needs; the `!lp` test itself is
   reduced by VST to `true = false` / `false = true` style facts
   (`bool_contra` in `WcLinesBody.v` handles them).
2. VSU components for the two TUs (template: `utility-reuse/coq/*VSU.v`);
   linking leaves `safe_read`, `error`, `quotearg`/`quoteaf`,
   `xwrite_stdout`, `rawmemchr` as explicit imports.
3. `Print Assumptions` for `wc_lines_null_spec`'s body once it exists;
   extend `CaseAudit.v`, fresh replay, update `RESULTS.md`/`case-results.json`.
4. Trust-boundary contracts (`xwrite_stdout`/fwrite, `rawmemchr`, `error`,
   `quoteaf`/`quotearg`) remain assumed; none is body-verified.
5. `REQUIREMENTS.md` items (frontend translation theorem, Coq/Lean
   connection, returned-outcome/termination, calibration-as-negative) are
   untouched by this work.
6. The Pi differential tests mock `xwrite`/`rawmemchr` and do not exercise
   uintmax_t wrap-around.

## 2. VST traps met in `WcLinesBody.v` (and their fixes, all in the file)

- `forward_call` with the fused `Scall; Sset` pattern hangs in
  `after_forward_call`: `repeat simple apply seq_assoc1` first (as in
  `HeadBytesBody.v`, `CatBody.v`).
- Buffer split leaves a nested `A * B` in one SEP slot: `flatten_sepcon_in_SEP`
  after `rewrite buf_split` / `unfold buffer_prefix_n`.
- VST turns the unsigned `bytes_read > 0` test into
  `Int64.unsigned (Int64.repr 0) >= Int64.unsigned (Int64.repr r)`; the
  `r = -1` case is closed by `change (Int64.unsigned (Int64.repr (-1))) with
  18446744073709551615`.
- Pointer temps: VST's canonical load/store form is
  `field_address (tarray tschar 16385) [ArraySubsc i] buf`; after any
  pointer arithmetic or cast VST re-unfolds it into
  `if field_compatible_dec … then offset_val (0 + 1 * i) … else Vundef` or
  `offset_val (nested_field_offset …)`. Restore with `rewrite if_true by
  <field_compatible_cons_Tarray>`, `replace (0 + 1 * i) with i`, and
  `rewrite <- (field_address_offset …)` / `rewrite <- buf_fa` BEFORE the next
  `forward`, otherwise loads fail ("cannot find data_at").
- `p + 1` is `force_val (sem_binary_operation' Oadd (tptr tschar) tint …)`
  (`buf_ptr_succ'`), and in the re-established invariant VST shows it as
  `offset_val (j + sizeof tschar) buf` (`buf_fa` + `simpl; lia`).
- `end = buf + bytes_read` is `force_val (sem_binary_operation' Oadd (tarray
  tschar 16385) tulong …)` (`buf_end_addr`, via `sem_add_ptr_long_tschar`).
- Pointer `!=` in `forward_while`: VST already reduces the hypothesis to
  `HRE : field_address … i … <> / = field_address … r …` (index injectivity:
  `buf_fa_inj`). Pointer `<` in `forward_if`: hypotheses stay as
  `typed_true/false tint (match sem_cmp_pp Clt (offset_val (0+1*j) …) … with …)`;
  normalise and rewrite with `buf_cmp_lt'` (`sem_cmp_pp` is
  `option_map bool2val (Val.cmplu_bool true2 …)`, block test `eq_block`),
  then `typed_true_of_bool`/`Z.ltb_lt`. The tc side goal
  `denote_tc_test_order` is discharged by `buf_test_order_from_valid` with
  `sepcon_valid_pointer1` peeling the frame.
- Loads of `tschar` need `is_int I8 Signed (Znth k vl)`; rewrite with
  `app_Znth1`/`Znth_map` (instance-agnostic) and `is_int8_Vbyte`.
- `lines += *p++ == '\n'` evaluates to
  `Int64.add (Int64.repr L) (Int64.repr (Int.signed (Int.repr (Z.b2z (Int.eq (Int.repr (Byte.signed c)) (Int.repr 10))))))`
  (`lines_step`, `int_eq_nl`).
- Ltac: `oo` is VST's composition keyword (not a binder name); local
  hypothesis names cannot appear inside `match goal` patterns (use `?pv`);
  `(char *)` inside a comment terminates it; `rewrite !lemma` with side
  conditions rewrites one instance only (rewrite each explicitly);
  `ltac:(lia)`/`ltac:(assumption)` argument holes run before unification
  (pass explicit hypotheses).
