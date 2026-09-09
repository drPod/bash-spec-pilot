# Verification results (2026-09-07; final replay 19:01-19:02 UTC, resumed Claude worker `utility-resume-2`)

Claude authored the source adapters, generalized contracts and body proofs
(sessions `utility-reuse` and `utility-resume-2`); Grok/Pi ran intermediate
isolated checks and one bounded, unsuccessful repair attempt on
`body_full_write`; the orchestrator inspected raw receipts. No human proof
authoring is implied. Every receipt below is one `coqc` invoked directly by
`run_vst.py` (no pipe, no loop); `exit_status` is coqc's own exit code.
Receipts: `~/agent-jobs/astra-research/phase5/runs/<name>.{json,log}`.

## Checked theorems (all accepted; final replay `utility-resume2-replay-*`, 19:01-19:02 UTC)

| Theorem | File | Statement | Replay receipt (exit) |
|---|---|---|---|
| `body_safe_read` | `SafeReadBody.v` | `semax_body Vprog Gprog f_safe_read (safe_read_spec _errno _safe_read)` | `utility-resume2-replay-SafeReadBody` (0) |
| `body_safe_write` | `SafeWriteBody.v` | `semax_body Vprog Gprog f_safe_write (safe_write_spec _errno _safe_write)` | `utility-resume2-replay-SafeWriteBody` (0) |
| `body_full_write` | `FullWriteBody.v` | `semax_body Vprog Gprog f_full_write (full_write_spec _errno _full_write)` (statement line sha256 `0b326945cf6a9f85dda4bf73980bcb650de81acd8efb1cbaf4334b5c5ebdc426`, unchanged since the frozen original) | `utility-resume2-replay-FullWriteBody` (0) |
| `body_simple_cat` | `CatBody.v` | `semax_body Vprog Gprog f_simple_cat (simple_cat_spec _errno _simple_cat _input_desc _infile)` | `utility-resume2-replay-CatBody` (0) |
| `wrapper_chain` | `Summary.v` | conjunction of the four body theorems | `utility-resume2-replay-Summary` (0) |
| `*_ident_agree`, `*_spec_agree` | `Summary.v` | identifiers/funspec instances proved in one TU equal those assumed in the caller's TU (by `reflexivity`) | same |
| `cat_true_copies_all`, `cat_false_reports`, `FullWrite_complete` | `IOWorld.v` | functional consequences of the protocol relations (closed, no axioms) | `utility-resume2-replay-IOWorld` (0) |

Replay order and exit statuses (12 separate receipts, all `exit_status: 0`):
`safe_read`, `safe_write`, `full_write`, `cat_fragment` (generated TUs), `IOWorld`,
`IOSpecs`, `SafeReadBody`, `SafeWriteBody`, `FullWriteBody`, `CatBody`, `Summary`,
`Audit`. Container `.vo` mtimes 19:01:15-19:02:08 UTC match the receipts. The
container sources compiled are hash-identical to `coq/*.v` (checked after the
replay; hashes below).

Development receipts this session (also direct, all exit 0):
`utility-resume2-FullWriteBody-1` (18:54:50 UTC, with goal-printing
diagnostics), `utility-resume2-FullWriteBody-2` (cleaned proof),
`utility-resume2-SafeWriteBody-1`, `utility-resume2-Summary-1`,
`utility-resume2-Audit-1`. No compiler run failed in this session.

### Assumption audit (`Audit.v`, receipt `utility-resume2-replay-Audit`, exit 0)

`Print Assumptions` for the four body theorems and `wrapper_chain` lists only
the standard axioms VST/CompCert already depend on: `Classical_Prop.classic`,
`Axioms.prop_ext`, `FunctionalExtensionality.functional_extensionality_dep`,
`Eqdep.Eq_rect_eq.eq_rect_eq`, `Ensembles.Extensionality_Ensembles`,
`ClassicalDedekindReals.sig_not_dec`, `ClassicalDedekindReals.sig_forall_dec`.
The three functional theorems and the four `cenv_ok` lemmas are "Closed under
the global context". No `Admitted`, no project axioms (`grep -n "Admitted\|Axiom"
coq/*.v` is empty).

### How `body_full_write` was closed (previous blocker)

Pi's receipt `pi-utility-direct-FullWriteBody-1` failed at `split3` (line 144)
because the first goal `entailer!` left in the loop-continue case was the
`temp _count` value equality `Vlong (Int64.repr (Zlength bs - off - r)) =
Vlong (Int64.repr (Zlength bs - (off + r)))`, not the PROP conjunction the
positional brace assumed. The fix normalizes the three updated temps before
`Exists`: new lemma `sem_add_tptr_tschar_tulong` (the Clight `Oadd (tptr
tschar) tulong` pointer bump equals `offset_val`), then `offset_offset_val`,
`add64_repr`, `sub64_repr` and `replace ... by lia`. After that `entailer!`
leaves exactly the invariant-continuation obligation (observed with the
diagnostic run). No injectivity of `Int64.repr` is involved, as the
orchestrator review stated; the theorem statement is unchanged.

## Scope (what the theorems say and do not say)

- **Source-preserving**: the gnulib `.c`/`.h` files are byte-identical to the
  pinned upstream; the `simple_cat` fragment is a byte slice of `cat.c`
  (`src/tu/FRAGMENT.json`, token-checked). Adapters are declaration-only
  (`PROVENANCE.md`: fixed-arity `error`, external `write_error`, static-function
  retention wrapper `simple_cat_entry`, plain `errno` cell, LP64 constants).
- **Modular**: each translation unit is verified against funspecs from
  `IOSpecs.v`; `Summary.v` checks the composition premise (identifier and
  funspec-instance agreement across TUs). VST whole-program (VSU) linking is
  **not** done; `simple_cat_entry` is unverified.
- **Trust boundary / assumptions**: `read_spec`, `write_spec` (libc syscalls over
  the schedule world `IOW.world`), `quotearg_spec` (pure), `error_spec`
  (records a diagnostic, exit status 0 returns), `write_error_spec`
  (non-returning). Host syscall behaviour is not proved.
- **Domain**: counts `<= SYS_BUFSIZE_MAX`; the `EINVAL` shrink branch of
  `safe_rw` (count larger than that) is outside the contract domain.
- **Partial correctness** in VST's logic: the schedule lists (`reads`,
  `writes`) may make the loops run arbitrarily long (e.g. unbounded `EINTR`);
  termination is not claimed.
- **Not** a verification of GNU cat's CLI/binary, of `copy_cat`, `cat`, or
  `main`, nor a translation-correctness theorem for `clightgen`
  (`../FRONTEND.md`).
- Byte-array post-forgetting in `simple_cat_spec` (`data_at_` after the loop)
  is a memory abstraction only; the output bytes are carried by `CatOutcome`
  (`cat_true_copies_all`: `delivered t = delivered s ++ unread s`).

## Reuse vs new (details in `REUSE.md`)

16 relay objects referenced literally (6 definitions, 10 lemmas). The
fd/count/errno-parametric contracts, the wrapper relations and all body
proofs are new. The relay's fixed-32 `buffer_prefix` is the `n = 32` instance
of `buffer_prefix_n` (`buffer_prefix_relay`, by `reflexivity`); no
funspec-level specialization theorem relating the relay world to `IOW.world`
was proved.

## Differential tests (complement, not replacement)

`tests/run_tests.py --cases 2000 --seed 20260907` rerun 19:02:53 UTC under the
shared compiler lock with host gcc 13.3.0 (Ubuntu 24.04), output outside the
repo (`~/agent-jobs/astra-research/phase5/claude-resume/utility-resume-2/tests/results.jsonl`,
sha256 `3f6f5f80a522da88014fc3c3dd7a7ba42ccea5ebf6ac2fcc027973a8a4638b8a`,
byte-identical to the earlier 09:38 run). 2012 records, 0 mismatches between
the compiled frozen C and the Python transliteration of `IOWorld.v`: 909
`true`, 447 `false` (read error reported), 656 `write_error`; schedules with
`EINTR` reads 1107, `EINTR` writes 1062, short writes 1532, zero-byte writes
414. Only fd 0 -> fd 1 is exercisable (static `input_desc`). Finite agreement;
it does not discharge the wrapper/environment assumptions.

## Identities of the proof development (sha256)

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

Source and frontend identities: `PROVENANCE.md`; `sha256sum -c` on
`src/pinned/SHA256SUMS` (12), `src/tu/SHA256SUMS` (17), `generated/SHA256SUMS`
(8) all OK at 19:02 UTC. Frontend replay `utility-resume2-clightgen-replay`
(19:07:53 UTC, exit 0, `set -e`): regenerating the four TUs with the recorded
`clightgen` command reproduced all eight `generated/` hashes (4 `.v`, 4 `.i`);
`clightgen` binary sha256 `7219a47562eb2e99c75a7d9dc52ef2b7e9f174cbece2f3fdeff5340de344672f`
as in `PROVENANCE.md`.

## VSU linking (2026-09-07, resumed Claude worker `utility-linking-4`, replay 20:33-20:38 UTC)

NEXT.md item 1 ("VSU linking of the four TUs") is now checked, not just
scoped. `CatEntryBody.v`'s `body_simple_cat_entry` (the retention wrapper
`simple_cat_entry`, PROVENANCE.md item 3) is verified — a one-`forward_call`
transfer of `simple_cat_spec` to the wrapper's identifier, `linking3-CatEntryBody-3`,
exit 0. Four per-TU `VSU`s (`SafeReadVSU`, `SafeWriteVSU`, `FullWriteVSU`,
`CatFragmentVSU`) and their whole-linked-TU-chain composition (`LinkAll.v`,
`AllVSU := linkVSUs (linkVSUs SafeReadVSU (linkVSUs SafeWriteVSU
FullWriteVSU)) CatFragmentVSU`) are all checked by a from-scratch replay
(all `.vo`/`.glob` removed from the container first, `linking4-replay-01`
through `-18`, 18/18 `exit_status: 0`, container/repo sha256 equal — see
table below).

| Theorem | File | Statement | Replay receipt (exit) |
|---|---|---|---|
| `body_simple_cat_entry` | `CatEntryBody.v` | `semax_body Vprog Gprog f_simple_cat_entry (simple_cat_entry_spec _errno _simple_cat_entry _input_desc _infile)` | `linking4-replay-11-CatEntryBody` (0) |
| `SafeReadVSU` | `SafeReadVSU.v` | `@VSU NullExtension.Espec nil [read_spec] SafeRead_p [safe_read_spec] SafeRead_GP` | `linking4-replay-12-SafeReadVSU` (0) |
| `SafeWriteVSU` | `SafeWriteVSU.v` | imports `[write_spec]`, exports `[safe_write_spec]` | `linking4-replay-13-SafeWriteVSU` (0) |
| `FullWriteVSU` | `FullWriteVSU.v` | imports `[safe_write_spec]`, exports `[full_write_spec]` | `linking4-replay-14-FullWriteVSU` (0) |
| `CatFragmentVSU` | `CatFragmentVSU.v` | imports 5 leaf/external specs, exports `[simple_cat_spec; simple_cat_entry_spec]` | `linking4-replay-15-CatFragmentVSU` (0) |
| `AllVSU` | `LinkAll.v` | `@VSU _ [] [read_spec;write_spec;quotearg_spec;error_spec;write_error_spec] <QPlink_progs-merged p> [safe_read_spec;safe_write_spec;full_write_spec;simple_cat_spec;simple_cat_entry_spec] (SafeRead_GP*(SafeWrite_GP*FullWrite_GP)*CatFragment_GP)` | `linking4-replay-16-LinkAll` (0) |

`Print Assumptions AllVSU` (in `LinkAll.v`, run both standalone
`linking4-LinkAll-1` and in the full replay `linking4-replay-16-LinkAll`,
identical output both times): only the same standard classical/
functional-extensionality axioms already listed above for the body
theorems — no project axioms, no `Admitted`. `grep -n "Admitted\|Axiom"
coq/*.v` outside the clearly-marked diagnostic files (`CatFragmentVSU_diag*.v`,
`CatFrag_gp_*.v`, `FlushProbe.v` — bisection-only, never cited as evidence,
see below) is empty.

**What `AllVSU`'s type says, precisely**: linking merged the four TUs' own
compiled Clight programs (CompCert's `QPlink_progs`, a real AST-level
program link, not a specs-only agreement check) into one `QP.program`, and
the resulting component's only remaining imports are exactly the five
already-declared trust-boundary identifiers (`read`, `write`,
`quotearg_n_style_colon`, `error`, `write_error`) — i.e. every internal
wiring between the four TUs (`safe_write`'s import satisfied by
`safe_read`+`safe_write`+`full_write`'s composition, `safe_read_spec`/
`full_write_spec` imports of `cat_fragment` satisfied by the wrapper TUs)
is now resolved by the link, not merely asserted. **Not claimed**: this is
still not a whole *program* (no `main`), not a termination result, and does
not discharge the five remaining leaf/external assumptions (same scope
statement as before, restated below unchanged).

**Diagnosis, not a raised timeout**: the earlier `CatFragmentVSU.v` hang
(`linking3-CatFragmentVSU-2`, 180s wall, exit 124) was bisected (inlining
VST's own `mkComponent` script with `idtac` markers between each of its 10
bulleted proof obligations, `CatFragmentVSU_diag.v`, `linking4-diag-2`,
exit 124) to bullet 10 alone (the `Comp_MkInitPred` GP-entailment
obligation) — bullets 1-9 all finish in under a second. Isolated
single-tactic runs pinned it further: `apply derives_refl` alone hangs
(`linking4-gpderives-1`, >40s); `vm_compute`-forcing the same entailment
terminates but **OOMs** (2.87GiB against the 3GiB cap, `linking4-gpvmeq-1`,
exit 134) trying to unfold the `InitGPred` *mpred* value itself. The TU has
4 Gvars (including a compiled string literal, `___stringlit_1`, one
`Init_int8` per byte) against 1 (`_errno`) for the three leaf TUs this same
automation closes in ~1.2s each — the extra Gvars are the scaling factor.
Fixed (`CatFragmentVSU.v`, bullet 10 only, `linking4-CatFragmentVSU-3`,
1.36s, exit 0) by proving the cheap first-order fact `Vardefs p = Vardefs
CatFragment_p` (`vm_compute; reflexivity` — plain list data, no
separation-logic model touched) and `rewrite`ing it so the entailment
becomes a same-term `derives_refl`, never asking Coq to compare the two
`InitGPred` *values*.

A second, independent gap `mkVSU`'s automation exposed once bullet 10 was
fixed: `CatBody.v`'s `body_simple_cat` (Gprog: 6 entries, no
`simple_cat_entry_spec` — it didn't exist when CatBody.v was written) and
`CatEntryBody.v`'s `body_simple_cat_entry` (Gprog: 2 entries, no imports)
don't match the VSU's actual combined 7-entry Gprog exactly, so
`solve_SF_internal`'s exact-match check rejects them directly (fast
failure, ~1s, not a hang: `linking4-CatFragmentVSU-1`). Fixed **without
editing either accepted file** by lifting each along VST's own
`semax_body_subsumption`/`tycontext_sub_Gprog_app1`/`app2` (see REUSE.md's
"VSU linking" section for the full argument and why it's sound).

## History

The earlier `utility-coqc-*` loops piped coqc into grep without preserving
its exit status; they are development logs, not acceptance receipts. Pi's
isolated direct checks (`pi-utility-direct-*`, `~/agent-jobs/.../pi-reviews/
utility-receipt-recovery-1/receipts/`) accepted `body_safe_read` and
`body_simple_cat` and rejected the original `body_full_write`; the bounded
`fullwrite-arithmetic-1` follow-up (five direct attempts) did not fix it and
its patch was archived outside the repository with the original restored.
