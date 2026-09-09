# Reuse manifest: relay objects vs newly authored

“Literal” means a qualified name from compiled `../relay`; nothing copied or re-proved. Surveyed by `grep` over `coq/*.v` (2026-09-07).

## Reused literally from `../relay` (16 objects)

| Relay object | Kind | Used in |
|---|---|---|
| `Specs.byte_array` | memory predicate | IOSpecs, funspecs, FullWriteBody |
| `Specs.CompSpecs` | compspecs instance | IOSpecs, every body file (`cenv_ok` by `reflexivity`) |
| `Specs.buffer_prefix` | fixed-32 predicate | IOSpecs.`buffer_prefix_relay` |
| `Body.byte_array_split` | split at offset | FullWriteBody |
| `Body.tuchar_subarray_offset` | sub-array arithmetic | IOSpecs.`buffer_prefix_n_forget` |
| `Protocol.RelayProtocol.action` | schedule head | IOWorld (`read_n`, `write_n`) |
| `Protocol.RelayProtocol.prefix` | `sublist 0 n` | IOWorld |
| `Protocol.RelayProtocol.suffix` | `sublist n (Zlength xs)` | IOWorld, FullWriteBody |
| `Protocol.RelayProtocol.min_bounds` | lemma | IOWorld |
| `Protocol.RelayProtocol.max_one_positive` | lemma | IOWorld |
| `Protocol.RelayProtocol.prefix_length` | lemma | IOWorld, FullWriteBody |
| `Protocol.RelayProtocol.prefix_suffix` | lemma | IOWorld |
| `Protocol.RelayProtocol.valid_tail` | lemma | IOWorld |
| `Conservation.RelayConservation.suffix_length` | lemma | FullWriteBody |
| `Conservation.RelayConservation.suffix_zero` | lemma | FullWriteBody |
| `Conservation.RelayConservation.suffix_end` | lemma | FullWriteBody |

`IOSpecs.buffer_prefix_relay`: `Specs.buffer_prefix sh p bs = buffer_prefix_n sh p 32 bs` by `reflexivity`. **No funspec-level specialization** relating relay `read_spec`/`write_spec` (fixed fd, count 32) to `IOW.world`. Leaf adequacy later: [`adequacy/README.md`](adequacy/README.md).

`SafeReadBody.v`, `SafeWriteBody.v`, `CatBody.v` use relay only through `IOSpecs`/`IOWorld`.

## Newly authored

- `IOWorld.v`: `EINTR`/`EINVAL`/`ENOSPC`/`SYS_BUFSIZE_MAX`; `world`; `read_n`/`write_n`; `SafeRead`/`SafeWrite`/`FullWrite`/`CatLoop`/`CatOutcome`; 38 lemmas including `cat_true_copies_all`, `cat_false_reports`, `FullWrite_complete`.
- `IOSpecs.v`: `errno_at`, `buffer_prefix_n`, funspecs parametric in TU identifiers.
- Body files: `body_safe_read`, `body_safe_write` (script transferred; generated `f_safe_write` is `f_safe_read` modulo names), `body_full_write` (`sem_add_tptr_tschar_tulong`), `body_simple_cat`.
- `Summary.v`: identifier/funspec agreement and `wrapper_chain`.

## VSU linking

Per-TU VSUs reuse accepted `body_*` lemmas unchanged via `solve_SF_internal`/`mkVSU` except one hand-written GP-entailment bullet in `CatFragmentVSU.v` (`mkComponent` hang/OOM on extra Gvars; diagnostic files not evidence). `LinkAll.v` combines them with `linkVSUs` / CompCert `QPlink_progs`. Remaining imports: `read`, `write`, `quotearg_n_style_colon`, `error`, `write_error`.

`body_simple_cat` and `body_simple_cat_entry` are reused with zero edits via `semax_body_subsumption` / `tycontext_sub_Gprog_app1`/`app2` (narrower Gprogs lifted to the VSU’s 7-entry Gprog). Sound because neither original proof used specs outside its Gprog.

## Semantic generalizations (not unchanged reuse)

- fd is `in_fd`/`out_fd`; count parameter bounded by `SYS_BUFSIZE_MAX` (relay: 32).
- errno as global cell `errno_at` (host TLS errno not modeled).
- `read_spec` success yields `buffer_prefix_n`; `write_spec` keeps `byte_array`.
- Wrappers encode EINTR retry, `(size_t)-1` error sentinel, `ENOSPC` on zero-byte write; `EINVAL` shrink branch out of domain.
