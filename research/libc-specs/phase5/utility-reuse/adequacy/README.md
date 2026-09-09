# Generalized leaf adequacy and funspec specialization

Relate gnulib-parametric `IOSpecs.read_spec`/`write_spec` to relay’s fixed-fd, count-32 contracts: pure-function specialization, dry PRE/POST, `juicy_dry_ext_spec` for `IOW_Espec`, and external-call correspondence. Ledger row: “Reuse beyond purpose-built relay”. The source definitions are in `../coq/*.v` and `../../relay/`.

Pure specialization (`read_n_specializes_read32` / `write_n_specializes_write_block`), full `iow_juicy_dry_specs`, PRE/POST dry chaining on the records (`relay_*_call_iow_dry_pre`/`_post`). **No `funspec_sub`** (errno resource). No linked `main` for `IOW_Espec`. Job 12 quota-failed with no POST theorem ([`terminal12-audit.md`](terminal12-audit.md)); later jobs closed POST.

Not whole-program adequacy; not POST-side juicy transport back to `Relay_Espec` (relay has no errno cell). `JuicyPostWrite.v` is a separate file; nothing here depends on it.

## Specialization vs subsumption

Pure-function: does `read_n`/`write_n` at n=32 along `embed` compute `read32`/`write_block`? **Yes.** Funspec: does the generalized `DECLARE` subsume relay’s via `funspec_sub`? **Not claimed** — extras below.

## Extras over relay32

1. **errno** `SEP` plus existential `e'` (unconstrained on success). A stronger spec cannot demand a resource relay callers lack.
2. **fd** parametric vs `Int.zero`/`Int.one`; equal only under `embed`.
3. **count** `0 <= n <= SYS_BUFSIZE_MAX` vs literal 32 (relay write has strict `0 <`).
4. **GLOBALS (gv)** to locate errno; relay has none.
5. **quotearg/error/write_error** — wrapper trust boundary with no relay counterpart.

`has_ext` is typed to `OK_ty`. `Relay_Espec` vs `IOW_Espec` are different ghost PCMs; `embed` is not a ghost coercion.

`MemAdequacy.v` restates `Dry.v` PRE definitions locally: importing `Dry.v` OOMs (`utility-leaf8-memadeq-1`, exit 134, ~2.87 GiB).

## Accepted claim

For a relay `read`/`write` juicy PRE witness, a dry memory `m'` extending `m_dry jm` by a fresh 4-byte errno cell, and `errno_id |-> eb`: (i) IOW juicy PRE holds at constructed `jmJ`; (ii) `iow_dry_spec` PRE holds at `m'`; (iii) generalized dry POST at n=32 forces oracle `embed` of relay’s new world and yields relay dry POST up to the errno store; (iv) juicy memory from that dry POST satisfies IOW juicy POST.

**Still open:** relay-side juicy POST witness (would change relay’s contract); whole-program `prog_correct` for `IOW_Espec`.

## Files (role)

`Specialize.v`, `MemAdequacy.v`, `DryPost.v`, `AssertionBridge.v`, `JuicyDry.v`, `ErrnoBridge.v`, `ErrnoLoad.v`, `JuicyPre.v`, `PostLemmas.v`/`2`/`3`, `JuicyPost.v`, `JuicyDrySpecs.v`, `EmbedBridge.v`, `EmbedPre.v`/`EmbedPre2.v`, `EmbedJuicy.v`/`2`/`3`.

POST residual recorded on `utility-leaf11-probe-post-1` was closed in `JuicyPost.v` using `rebuild_store2'` because the errno store acts on memory only `mem_equiv` to the buffer store.

## Receipts

`run_vst.py` from `/home/coq/phase5/utility-reuse/adequacy`. Job-13 replay `utility-leaf13-replay-20260908T114429Z-NN-*` (01–13 + audits). Job-14 `utility-leaf14-replay-20260908T122521Z-*` and full `utility-leaf14-full-20260908T124833Z-{01..27}`: 27/27 exit 0.

| File | Theorem(s) | Replay | sha256 (16) |
|---|---|---|---|
| `Specialize.v` | `read_n_specializes_read32`, `write_n_specializes_write_block`, `embed_valid` | `...-01-Specialize` | `d3216a1e1a325eab` |
| `MemAdequacy.v` | dry PRE specializes | `...-02-MemAdequacy` | `b87e9e61acbc8009` |
| `DryPost.v` | dry POST specializes | `...-03-DryPost` | `828b7b2c786eb6cf` |
| `AssertionBridge.v` | params/buffer/errno bridges | `...-04-AssertionBridge` | `36cf021d8773475d` |
| `JuicyDry.v` | `iow_espec_ok_ty`, `dry_spec_mem`, `dry_spec_exit` | `...-05-JuicyDry` | `fc9f3af39e36b3ff` |
| `ErrnoBridge.v` | `errno_at_address_mapsto` | `...-06-ErrnoBridge` | `7f3229c34373753d` |
| `ErrnoLoad.v` | `errno_at_dry_pre` | `...-07-ErrnoLoad` | `4cbe7ee6d713f045` |
| `JuicyPre.v` | `iow_juicy_dry_pre` | `...-08-JuicyPre` | `ec7c9bccde3dfad4` |
| `PostLemmas.v` | rebuild/inflate | `...-09-PostLemmas` | `ad34391192db123d` |
| `PostLemmas2.v` | `errno_at_inflate_store` | `...-10-PostLemmas2` | `9c19879b04549b66` |
| `PostLemmas3.v` | `rebuild_store2'` | `...-11-PostLemmas3` | `ea3b2bd8c6922fce` |
| `JuicyPost.v` | `iow_juicy_dry_post` | `...-12-JuicyPost` | `262db94f97ff7125` |
| `JuicyDrySpecs.v` | `iow_juicy_dry_specs` | `...-13-JuicyDrySpecs` | `1105fbd4404719ef` |
| `EmbedBridge.v` | dry/ghost embed | `replay2-…-01-EmbedBridge` | `386dab85de318fcc` |
| `EmbedPre.v` | `read_pre_relay_to_iow` | `replay2-…-02-EmbedPre` | `2cf7b406924a5507` |
| `EmbedPre2.v` | `write_pre_relay_to_iow` | `leaf14-…-01-EmbedPre2` | `e49d7af1a1d5ff8b` |
| `EmbedJuicy.v` | `read_juicy_pre_relay_to_iow` | `leaf14-…-02-EmbedJuicy` | `56c6caeeba5f8708` |
| `EmbedJuicy2.v` | write juicy PRE + dry PRE calls | `leaf14-…-03-EmbedJuicy2` | `93bebfdbb5662688` |
| `EmbedJuicy3.v` | `relay_*_call_iow_dry_post` | `leaf14-replay3-…-01-EmbedJuicy3` | `05302c7fd74c3b39` |

`Print Assumptions`: standard classical/FE axioms; `eq_rect_eq` on theorems that invert ghost joins. `grep Admitted\|^Axiom` empty in this directory.
