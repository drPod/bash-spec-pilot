# Open items after the checked `head_bytes` / `wc_lines` bodies

Both `body_head_bytes` and `body_wc_lines` are checked (`RESULTS.md`). Remaining work and VST pitfalls from `WcLinesBody.v` are recorded so they are not rediscovered.

## Open items

1. Prove `wc_lines_null_spec` (`CaseSpecs.v`, checked funspec) as a second `semax_body` for `f_wc_lines` (separate `Gprog`: one identifier carries one spec per Gprog). `destruct (eq_dec lp nullval)` first; in `lp <> nullval` the SEP `if` reduces to `data_at_` and supplies `valid_pointer` for `!lines_out`. The `!lp` test reduces to `true = false` / `false = true` (`bool_contra` in `WcLinesBody.v`).
2. VSU components for the two translation units (template: `../utility-reuse/coq/*VSU.v`). Linking leaves `safe_read`, `error`, `quotearg`/`quoteaf`, `xwrite_stdout`, `rawmemchr` as explicit imports.
3. `Print Assumptions` for a `wc_lines_null_spec` body once it exists; extend `CaseAudit.v`, replay, update `RESULTS.md` / `case-results.json`.
4. Trust-boundary contracts (`xwrite_stdout`/fwrite, `rawmemchr`, `error`, `quoteaf`/`quotearg`) remain assumed; none is body-verified.
5. Items in `../REQUIREMENTS.md` (frontend translation theorem, Coq/Lean connection, returned-outcome/termination, calibration-as-negative) are independent of this pair.
6. Differential tests (`tests/`) mock `xwrite`/`rawmemchr` and do not exercise uintmax_t wrap-around.

These Coq/VST bodies are local case studies. They are not the Lean script-fragment connection described in [`../evaluation/DRAFT-PAPER.md`](../evaluation/DRAFT-PAPER.md) and [`../FINAL-DELIVERY.md`](../FINAL-DELIVERY.md).

## VST traps in `WcLinesBody.v` (fixes already in the file)

| Trap | Fix |
|---|---|
| `forward_call` on fused `Scall; Sset` hangs in `after_forward_call` | `repeat simple apply seq_assoc1` first (`HeadBytesBody.v`, `CatBody.v`) |
| Nested `A * B` in one SEP slot after buffer split | `flatten_sepcon_in_SEP` after `rewrite buf_split` / `unfold buffer_prefix_n` |
| Unsigned `bytes_read > 0` becomes `Int64.unsigned (Int64.repr 0) >= Int64.unsigned (Int64.repr r)` | `r = -1` closed by `change (Int64.unsigned (Int64.repr (-1))) with 18446744073709551615` |
| Pointer temps leave `field_address` as `if field_compatible_dec … then offset_val … else Vundef` | Restore `field_address (tarray tschar 16385) [ArraySubsc i] buf` with `rewrite if_true`, `replace (0 + 1 * i) with i`, `rewrite <- field_address_offset` / `buf_fa` **before** the next `forward` |
| `p + 1` as `force_val (sem_binary_operation' Oadd …)` | `buf_ptr_succ'`; invariant shows `offset_val (j + sizeof tschar) buf` (`buf_fa`; `simpl; lia`) |
| `end = buf + bytes_read` | `buf_end_addr` via `sem_add_ptr_long_tschar` |
| Pointer `!=` in `forward_while` | Hypothesis already `field_address … i … <> / = field_address … r …` (`buf_fa_inj`) |
| Pointer `<` in `forward_if` | Normalize `sem_cmp_pp` with `buf_cmp_lt'`, then `typed_true_of_bool` / `Z.ltb_lt`; `denote_tc_test_order` via `buf_test_order_from_valid` and `sepcon_valid_pointer1` |
| Loads of `tschar` need `is_int I8 Signed (Znth k vl)` | `app_Znth1` / `Znth_map` and `is_int8_Vbyte` |
| `lines += *p++ == '\n'` | `lines_step`, `int_eq_nl` |
| Ltac | `oo` is VST composition, not a binder; no local hyp names in `match goal` (use `?pv`); `(char *)` in a comment terminates it; `rewrite !lemma` with side conditions rewrites one instance; `ltac:(lia)` holes run before unification |
