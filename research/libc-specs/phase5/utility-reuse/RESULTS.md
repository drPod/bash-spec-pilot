# Verification results: `simple_cat` and gnulib I/O wrappers

`semax_body` and VSU linking for pinned gnulib wrappers plus a `simple_cat` fragment, against generalized scheduled I/O contracts.

All five body theorems and `AllVSU` accepted. Replay receipts under `~/agent-jobs/astra-research/phase5/runs/`. An earlier isolated check rejected `body_full_write`; the arithmetic fix is in `FullWriteBody.v` (statement line sha256 `0b326945cf6a9f85dda4bf73980bcb650de81acd8efb1cbaf4334b5c5ebdc426`, unchanged).

## Body theorems (replay `utility-resume2-replay-*`)

| Theorem | File | Statement | Replay (exit) |
|---|---|---|---|
| `body_safe_read` | `SafeReadBody.v` | `semax_body Vprog Gprog f_safe_read (safe_read_spec _errno _safe_read)` | `utility-resume2-replay-SafeReadBody` (0) |
| `body_safe_write` | `SafeWriteBody.v` | `semax_body … f_safe_write (safe_write_spec …)` | `utility-resume2-replay-SafeWriteBody` (0) |
| `body_full_write` | `FullWriteBody.v` | `semax_body … f_full_write (full_write_spec …)` | `utility-resume2-replay-FullWriteBody` (0) |
| `body_simple_cat` | `CatBody.v` | `semax_body … f_simple_cat (simple_cat_spec …)` | `utility-resume2-replay-CatBody` (0) |
| `wrapper_chain` | `Summary.v` | conjunction of the four bodies | `utility-resume2-replay-Summary` (0) |
| `*_ident_agree`, `*_spec_agree` | `Summary.v` | identifiers/funspecs equal across TUs (`reflexivity`) | same |
| `cat_true_copies_all`, `cat_false_reports`, `FullWrite_complete` | `IOWorld.v` | functional consequences (closed) | `utility-resume2-replay-IOWorld` (0) |

Order (all exit 0): generated TUs, `IOWorld`, `IOSpecs`, four bodies, `Summary`, `Audit`.

`Print Assumptions` (`utility-resume2-replay-Audit`): standard VST/CompCert axioms only (`classic`, `prop_ext`, `functional_extensionality_dep`, `eq_rect_eq`, `Extensionality_Ensembles`, `sig_not_dec`, `sig_forall_dec`). Functional theorems and `cenv_ok` closed. No `Admitted` in accepted `coq/*.v` (diagnostic files excluded).

`body_full_write` previously failed at `split3` because `entailer!` left `temp _count` value equality `Zlength bs - off - r` vs `Zlength bs - (off + r)`, not the PROP conjunction the positional brace assumed. Fix: `sem_add_tptr_tschar_tulong`, `offset_offset_val`, `add64_repr`, `sub64_repr`, `replace … by lia`. No `Int64.repr` injectivity.

## Scope

- Source-preserving fragments and declaration-only adapters ([`PROVENANCE.md`](PROVENANCE.md)).
- Trust boundary: `read_spec`/`write_spec`, `quotearg_spec`, `error_spec`, `write_error_spec` (non-returning). Host syscalls not proved.
- Domain: counts `<= SYS_BUFSIZE_MAX`; `EINVAL` shrink branch out of domain.
- Partial correctness: unbounded EINTR possible; termination not claimed.
- Not GNU cat CLI/`main`/`copy_cat`; not `clightgen` translation correctness (`../FRONTEND.md`).
- Byte-array post-forgetting in `simple_cat_spec` is memory abstraction; output bytes in `CatOutcome`.

## Differential tests

`tests/run_tests.py --cases 2000 --seed 20260907` (host gcc 13.3.0): 2012 records, 0 mismatches vs Python `IOWorld.v` transliteration (`results.jsonl` sha256 `3f6f5f80a522da88014fc3c3dd7a7ba42ccea5ebf6ac2fcc027973a8a4638b8a`). 909 `true`, 447 `false`, 656 `write_error`. Finite agreement; only fd 0→1.

## Identities (sha256)

| File | sha256 |
|---|---|
| `coq/IOWorld.v` | `3273ac627d1813e5408d40adfff1dfd88580bb3e39aa94ee91b7e3e718602c89` |
| `coq/IOSpecs.v` | `dcd7f49dcc8dbf0b72847e3bd32e473a519ab1baa9a026e708f7a7759bc5c436` |
| `coq/SafeReadBody.v` | `17ff28b58e21b3b220043175a896f285c1e964a6a971b5949d7b51e1c35ed0cb` |
| `coq/SafeWriteBody.v` | `e03bc8f6f4929628764449f53c3bfb63dbe8a3a7c4622ddf12852cbccfa82472` |
| `coq/FullWriteBody.v` | `13ca4875e7ed1bf7497630e0aeaec144dd004861b4a6ff9d5cd69628f05a10ef` |
| `coq/CatBody.v` | `18b35734738aa37022d9567960774c2f7afb9d3b7a19974e4402cf3af0680468` |
| `coq/Summary.v` | `c07784c4f40720d364bc03e9ec623ee890ffd773372eae4d5088ae35d82a0ef1` |
| `coq/Audit.v` | `0c7c68bd545510163e002e5fecae46009ff4b43fc9b2f1f812aeccc4a09f4acc` |
| `coq/CatEntryBody.v` | `06c6d7b21b0aa14a67a768f2432080865080a1a6cfaa5a3ea19420dc5f2e6b71` |
| `coq/SafeReadVSU.v` | `0a2868ba606dfd62203f5769cfceb3b4c7b87031ea975e072578a9b0574bec9e` |
| `coq/SafeWriteVSU.v` | `f330bfb97701bbc8c89df419bf32524d52d69b0fa74fab9f6a431d63d0e12e74` |
| `coq/FullWriteVSU.v` | `6f0212d8881ddf149eba1083d34fb0dfc775f9f89375fe32dea597d7fd413481` |
| `coq/CatFragmentVSU.v` | `3a4316759d0295021e20841361b6bb3bd1a8dee10673be3d1c3eceb917f989da` |
| `coq/LinkAll.v` | `d8a1cf1212328da69db351d61731041b7a5daf358e548ce88423b04b272a9bf6` |

`sha256sum -c` on pinned/TU/generated SUMS OK. Frontend replay `utility-resume2-clightgen-replay` reproduced eight `generated/` hashes.

## VSU linking (replay `linking4-replay-01`–`-18`, 18/18 exit 0)

| Theorem | File | Statement | Replay (exit) |
|---|---|---|---|
| `body_simple_cat_entry` | `CatEntryBody.v` | wrapper `semax_body` | `linking4-replay-11-CatEntryBody` (0) |
| `SafeReadVSU` | `SafeReadVSU.v` | `@VSU … [read_spec] … [safe_read_spec] …` | `linking4-replay-12-SafeReadVSU` (0) |
| `SafeWriteVSU` | `SafeWriteVSU.v` | imports `[write_spec]`, exports `[safe_write_spec]` | `linking4-replay-13-SafeWriteVSU` (0) |
| `FullWriteVSU` | `FullWriteVSU.v` | imports `[safe_write_spec]`, exports `[full_write_spec]` | `linking4-replay-14-FullWriteVSU` (0) |
| `CatFragmentVSU` | `CatFragmentVSU.v` | imports 5 leaf specs, exports cat + entry | `linking4-replay-15-CatFragmentVSU` (0) |
| `AllVSU` | `LinkAll.v` | `linkVSUs` merge; remaining imports the five leaves | `linking4-replay-16-LinkAll` (0) |

`AllVSU` merges Clight programs via `QPlink_progs`. Not a whole program (no `main`); five leaf assumptions remain.

`CatFragmentVSU` `mkComponent` bullet 10 (`Comp_MkInitPred`) hung/OOM on 4 Gvars vs 1 for leaf TUs. Fix: prove `Vardefs p = Vardefs CatFragment_p` and rewrite so `derives_refl` is same-term. Bodies lifted with `semax_body_subsumption` without editing accepted body files ([`REUSE.md`](REUSE.md)).

Piped `utility-coqc-*` loops did not preserve `coqc` exit status; they are not acceptance receipts.
