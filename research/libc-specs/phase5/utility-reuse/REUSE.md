# Reuse manifest: relay development items reused literally vs newly authored

Produced from `grep` over `coq/*.v` (qualified references), 2026-09-07. "Literal"
means the relay object is referenced by its qualified name from the compiled
`../relay` development; nothing was copied or re-proved.

## Reused literally from `../relay` (16 objects)

| Relay object | Kind | Used in |
|---|---|---|
| `Specs.byte_array` | memory predicate (`data_at sh (tarray tuchar (Zlength bs)) (map Vubyte bs) p`) | IOSpecs (`Notation byte_array`), all funspecs, FullWriteBody |
| `Specs.CompSpecs` | compspecs instance | IOSpecs (`Existing Instance`), every body file (`cenv_ok` by `reflexivity`) |
| `Specs.buffer_prefix` | fixed-32 relay predicate | IOSpecs.`buffer_prefix_relay` (see below) |
| `Body.byte_array_split` | split `byte_array` at an offset | FullWriteBody (4 uses: partial-write pointer `ptr += n_rw`) |
| `Body.tuchar_subarray_offset` | sub-array address arithmetic | IOSpecs.`buffer_prefix_n_forget` |
| `Protocol.RelayProtocol.action` | schedule head with fallback | IOWorld (`read_n`, `write_n`) |
| `Protocol.RelayProtocol.prefix` | `sublist 0 n` | IOWorld |
| `Protocol.RelayProtocol.suffix` | `sublist n (Zlength xs)` | IOWorld, FullWriteBody |
| `Protocol.RelayProtocol.min_bounds` | lemma | IOWorld (5 uses) |
| `Protocol.RelayProtocol.max_one_positive` | lemma | IOWorld (2) |
| `Protocol.RelayProtocol.prefix_length` | lemma | IOWorld (2), FullWriteBody (1) |
| `Protocol.RelayProtocol.prefix_suffix` | lemma | IOWorld (1) |
| `Protocol.RelayProtocol.valid_tail` | lemma | IOWorld (2) |
| `Conservation.RelayConservation.suffix_length` | lemma | FullWriteBody (4) |
| `Conservation.RelayConservation.suffix_zero` | lemma | FullWriteBody (2) |
| `Conservation.RelayConservation.suffix_end` | lemma | FullWriteBody (2) |

Specialization evidence at the predicate level: `IOSpecs.buffer_prefix_relay`
(`Specs.buffer_prefix sh p bs = buffer_prefix_n sh p 32 bs`, by `reflexivity`)
shows the relay's fixed-32 buffer predicate is the `n = 32` instance of the
generalized one. **No funspec-level specialization theorem was proved**: the
relay's `read_spec`/`write_spec` fix fd and count = 32 over the relay world, and
the generalized world here (`IOW.world`: `unread`, `delivered`, `in_fd`,
`out_fd`, `diagnostics`, `reads`, `writes`) is a new record; the relation to the
relay world is by construction of `read_n`/`write_n` on the same
`RelayProtocol.action`/`prefix`/`suffix` primitives, not by a proved embedding.

Body files `SafeReadBody.v`, `SafeWriteBody.v`, `CatBody.v` reference no relay
object directly; they use the relay only through `IOSpecs`/`IOWorld`.

## Newly authored in this directory

- `IOWorld.v` (module `IOW`): constants `EINTR`, `EINVAL`, `ENOSPC`,
  `SYS_BUFSIZE_MAX`; records `world`, `read_result`, `write_result`;
  definitions `valid_reads`, `valid_writes`, `valid_world`, `after_read`,
  `after_write`, `report`, `read_amount`, `read_n`, `write_n`; inductive
  relations `SafeRead`, `SafeWrite`, `FullWrite`, `CatLoop`, `CatOutcome`; 38
  lemmas/theorems: `SYS_BUFSIZE_MAX_eq`, `read_amount_bounds`,
  `read_amount_positive`, `read_ret_bounds`, `read_success_length`,
  `read_conservation`, `read_frame`, `read_zero_only_empty`,
  `read_error_shape`, `read_error_errno`, `read_valid`, `write_ret_bounds`,
  `write_frame`, `write_success_prefix`, `write_error_shape`,
  `write_error_errno`, `write_valid`, `SafeRead_ret_bounds`,
  `SafeRead_length`, `SafeRead_conservation`, `SafeRead_valid`,
  `SafeRead_zero`, `SafeRead_fail`, `SafeWrite_ret_bounds`,
  `SafeWrite_effect`, `SafeWrite_valid`, `SafeWrite_fail`, `suffix_suffix`,
  `prefix_app_suffix`, `FullWrite_total_bounds`, `FullWrite_effect`,
  `FullWrite_complete`, `FullWrite_valid`, `CatLoop_conservation`,
  `CatLoop_valid`, `CatOutcome_inv`, `cat_true_copies_all`,
  `cat_false_reports`.
- `IOSpecs.v`: `errno_at`, `buffer_prefix_n`; lemmas `buffer_prefix_relay`,
  `buffer_prefix_n_forget`, `sem_add_ptr_long_tschar`; tactic `norm_cmp`;
  funspecs `read_spec`, `write_spec`, `safe_read_spec`, `safe_write_spec`,
  `full_write_spec`, `quotearg_spec`, `error_spec`, `write_error_spec`,
  `simple_cat_spec` (all parametric in the TU's identifiers).
- `SafeReadBody.v`: `cenv_ok`, `body_safe_read`.
- `SafeWriteBody.v` (this session): `cenv_ok`, `body_safe_write` — the checked
  `SafeReadBody.v` script transferred to the write model (generated
  `f_safe_write` is `f_safe_read` modulo the names `read`/`write`,
  `safe_read`/`safe_write`; see `diff generated/safe_read.v generated/safe_write.v`).
- `FullWriteBody.v`: `cenv_ok`, `suffix_nonempty`, `sem_add_tptr_tschar_tulong`
  (this session), `body_full_write`.
- `CatBody.v`: `cenv_ok`, `body_simple_cat`.
- `Summary.v` (this session): `errno_ident_agree`, `safe_read_ident_agree`,
  `safe_write_ident_agree`, `full_write_ident_agree`, `safe_read_spec_agree`,
  `safe_write_spec_agree`, `full_write_spec_agree`, `wrapper_chain`.

## VSU linking (2026-09-07, resumed Claude worker `utility-linking-4`)

Four per-TU `VSU`s (`SafeReadVSU.v`, `SafeWriteVSU.v`, `FullWriteVSU.v`,
`CatFragmentVSU.v`) each reuse their TU's already-accepted `body_*` lemma
**unchanged** via VST's own `solve_SF_internal`/`mkVSU` (bullets 1-9 of
`mkComponent`, VST's stock automation, unmodified) plus one hand-written
bullet (see `CatFragmentVSU.v`'s header comment for why: `mkComponent`'s own
GP-entailment automation hangs/OOMs on this one TU's larger global set,
`CatFragmentVSU_diag*.v`/`CatFrag_gp_*.v` are the bisection receipts, not
evidence). `LinkAll.v` then combines all four via VST's real `linkVSUs`
(`floyd/VSU.v`, which itself invokes CompCert's `QPlink_progs` to merge the
four Clight ASTs into one `QP.program` — an actual program-level link, not
a statement that the specs merely agree): `AllVSU : VSU [] [read_spec
(safe_read._read); write_spec (safe_write._write); quotearg_spec; error_spec;
write_error_spec] <merged p> [safe_read_spec; safe_write_spec; full_write_spec;
simple_cat_spec; simple_cat_entry_spec] (SafeRead_GP * (SafeWrite_GP *
FullWrite_GP) * CatFragment_GP)`. `Print Assumptions AllVSU` lists only the
same standard classical/functional-extensionality axioms as everything
else in this directory — no project axioms, no `Admitted`.

New reuse mechanism, not previously used in this directory: **`CatBody.v`'s
`body_simple_cat` and `CatEntryBody.v`'s `body_simple_cat_entry` are reused
literally (zero edits, same sha256 as RESULTS.md already records) inside
`CatFragmentVSU.v`**, lifted from their original (narrower) Gprogs to the
VSU's combined 7-entry Gprog via VST's own Gprog-weakening lemmas
(`floyd/forward.v`: `semax_body_subsumption`, `tycontext_sub_Gprog_app1`/
`app2`) rather than by re-proving or by widening the original files' Gprog
definitions. This is sound because neither original proof used any spec
outside its own narrower Gprog (`simple_cat` never calls
`simple_cat_entry`), so the two new lemmas `body_simple_cat_lifted`/
`body_simple_cat_entry_lifted` in `CatFragmentVSU.v` are pure widenings,
formally checked (two `list_norepet` side conditions each, by
`compute_list_norepet_e; reflexivity`), not restatements of what was
already proved.

## Generalizations relative to the relay contracts (new semantics, not unchanged reuse)

- fd is the world's `in_fd`/`out_fd` (relay: fixed descriptors); count is a
  parameter `n`/`Zlength bs` bounded by `SYS_BUFSIZE_MAX` (relay: 32).
- errno is modeled as a plain global cell `errno_at (gv _errno) e` (adapter
  `include/errno.h`: `extern int errno`; host TLS errno is not modeled).
- `read_spec` on success yields `buffer_prefix_n` (first `r` bytes are the
  consumed stream bytes, rest uninitialized); `write_spec` keeps `byte_array`.
- Wrapper relations `SafeRead`/`SafeWrite`/`FullWrite` encode gnulib's retry on
  `EINTR`, the `(size_t)-1` error sentinel, `ENOSPC` on a zero-byte write, and
  exclude the `EINVAL` shrink branch by the count bound (out of domain).
