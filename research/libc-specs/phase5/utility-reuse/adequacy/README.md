# Generalized leaf adequacy and funspec specialization

Owner: Claude workers `utility-leaf-adequacy-8`, `-9`, `-10`, `-11`, `-13`,
then `-14` (job dirs `~/agent-jobs/astra-research/phase5/claude-resume/
utility-leaf-adequacy-{8,9,10,11,13,14}`; `-12` was a quota exit with no Coq
added, see `terminal12-audit.md`), same continued session.
`JuicyPostWrite.v` is a separate Pi worker's file (`utility-post-write16`,
two helper lemmas, its branch attempt open); nothing here depends on it.
Scope:
`REQUIREMENTS.md`'s "Reuse beyond purpose-built relay" row, missing column:
"Generalized leaf adequacy and funspec specialization". This directory is
new; `../coq/*.v` (`IOWorld.v`, `IOSpecs.v`, the four body proofs, the four
VSUs, `LinkAll.v`) and `../../relay/**` are read-only inputs, unmodified.

## What "specialization" means here, precisely

`../IOSpecs.v`'s `read_spec`/`write_spec` generalize `../../relay/Specs.v`'s
`read_spec`/`write_spec` (fixed fd 0/1, fixed count 32, no errno) to
parametric `in_fd s`/`out_fd s`, parametric count `n <= SYS_BUFSIZE_MAX`, and
an explicit `errno_at` memory cell. `REUSE.md` already recorded that the
relay's fixed-32 `buffer_prefix` is the `n = 32` instance of the
generalized `buffer_prefix_n` (`IOSpecs.buffer_prefix_relay`, by
`reflexivity`) but that **no funspec-level specialization theorem was
proved** relating the two `world` types or the two `DECLARE`d contracts.
That is the ledger gap this directory addresses.

Two things needed distinguishing from the start (this is the "identify the
exact extras" requirement): a *pure-function* specialization (does the
generalized `read_n`/`write_n`, instantiated at n=32 and along a world
embedding, literally compute what relay's `read32`/`write_block` compute?)
versus a *funspec/contract* specialization (does the generalized `DECLARE`
imply/subsume relay's `DECLARE`, e.g. via VST's `funspec_sub`?). These are
different claims and only the first is established here.

## Files

- `Specialize.v` -- pure-math bridge. `embed : RelayProtocol.world ->
  IOW.world` (fd 0/1, empty diagnostics -- relay never calls `error()`).
  `read_n_specializes_read32` / `write_n_specializes_write_block`: at n = 32
  (read only; write needs no n at all) and along `embed`, the generalized
  primitives compute exactly the `embed`-image of relay's
  `read32`/`write_block`, given relay's own `valid_world` hypothesis. Fully
  checked (`Qed`, no `Admitted`/project axioms); receipts below.
- `MemAdequacy.v` -- CompCert dry-memory layer. Generalized
  `read_dry_pre_n`/`write_dry_pre_n` (parametric n, plus an explicit
  `errno_dry_pre` conjunct `../../relay/adequacy/Dry.v`'s `read_dry_pre`/
  `write_dry_pre` have no counterpart for at all), and one directed
  specialization theorem per primitive: relay's own dry PRE plus a fresh
  errno witness implies the generalized dry PRE at n=32/`embed`.
  **Does not `Require Import Dry`** (relay's adequacy/Dry.v): that file
  transitively pulls `relay_main Protocol Reach Main` (relay's full VST
  body/progress/audit development) and measurably OOMs coqc against this
  container's 3 GiB cap (`utility-leaf8-memadeq-1`, exit 134, peak RSS
  ~2.87 GiB -- receipt in `STATUS.md`, a real resource-budget finding, not
  a style choice). Instead `MemAdequacy.v` restates `Dry.v`'s
  `read_dry_pre`/`write_dry_pre`/`bytes_to_memvals` verbatim under local
  names (`relay_read_dry_pre`/`relay_write_dry_pre`/`bytes_to_memvals`,
  diffable line-for-line against `relay/adequacy/Dry.v`, modulo dropping
  the `sh : share` witness component both original definitions leave
  unused in their body). This is a restatement of plain `Prop`-valued
  `Definition`s for a lighter import, not a re-proof of anything from
  `Dry.v` (its own theorems `dry_spec_mem`/`juicy_dry_specs` are neither
  cited nor needed here). `dry_mem_lemmas.v`'s `data_at__writable_perm`/
  `data_at_bytes`/`store_bytes_data_at` were considered for the errno-cell
  connection (see gap 2 below) and observed to already be leaf-generic
  (stated for an arbitrary `tarray tuchar z`/arbitrary `compspecs` type,
  not hardcoded to 32) but are not imported by the accepted file for the
  same OOM reason.
- `DryPost.v` -- the POST-side counterpart to `MemAdequacy.v`'s PRE side:
  `read_dry_post_n`/`write_dry_post_n`, generalizing `Dry.v`'s
  `read_dry_post`/`write_dry_post` to parametric n plus an explicit
  `errno_dry_post_effect` (forced to the actual new errno value on error,
  an unconstrained existential on success -- exactly `IOSpecs.read_spec`'s
  own `EX e'` POST shape, not a weakening of it), and two specialization
  theorems reusing `Specialize.v`'s already-proved
  `read_n_specializes_read32`/`write_n_specializes_write_block` directly
  (`rewrite` + `simpl`, not a re-derivation of the action/schedule case
  split). Also restates relay's two POST definitions locally, same reason
  and same technique as `MemAdequacy.v`.
- `AssertionBridge.v` -- the funspec-level bridge, deliberately scoped
  around `has_ext`'s cross-Espec incomparability (see `JuicyDry.v` and this
  file's own header for the precise reason a `funspec_sub` is not
  attempted). Checks, as literal `mpred`/value equalities rather than
  prose: the fd `PARAMS` reduce to relay's under `embed` (`reflexivity`),
  the byte-buffer POST resource at n=32/`embed` is *definitionally* the
  same `mpred` as relay's (`read_post_buffer_bridge`, composing
  `Specialize.read_n_specializes_read32` with `IOSpecs.buffer_prefix_relay`),
  and the errno-on-error value is forced to exactly `1` under `embed`
  (matching relay's single error sentinel `-1` one-for-one).
- `JuicyDry.v` -- attempts the actual "full `juicy_dry_ext_spec`" ask
  directly, not deferred again. Builds a standalone `IOW_Espec`
  (`add_funspecs` over `ok_void_spec IOW.world`, mirroring
  `relay/Specs.v`'s `Relay_Espec` construction but *not* tied to
  `Main.Espec` -- no linked whole program exists for the generalized
  development, see the file's header for why that's the right call, not a
  shortcut), the full dry `external_specification` `iow_dry_spec` (a
  `Program Definition` structurally identical to relay's own
  `relay_dry_spec`, adapted to the larger 6-tuple WITH-clauses and the
  errno-carrying pre/post from the two files above), and `iow_dessicate`.
  Two of the three `juicy_dry_ext_spec` conjuncts specific to this file are
  checked standalone: `dry_spec_mem` (memory only ever evolves, generalized
  to the two-step buffer-then-errno effect) and `dry_spec_exit` (the exit
  clause; both sides reduce to `True`, since `add_funspecs` fixes its
  built Espec's exit predicate to `True` unconditionally -- checked by
  direct `Show`, not assumed from relay's comment, which attributed the
  same fact to `Main.Espec` specifically and turned out to be an
  incomplete explanation once checked against a *different* base Espec).
  The `juicy_dry_ext_spec` record itself (PRE- and POST-preservation, the
  two ghost-state-heavy conjuncts relay's own `juicy_dry_specs` spends
  ~300 lines on) is not attempted -- see "Remaining gap".
- `ErrnoBridge.v` -- the entry point for the tint errno data_at-to-dry
  bridge PRE-preservation will need: `errno_at_address_mapsto` unfolds
  `IOSpecs.errno_at (Vptr b ofs) e` (a `data_at Ews tint` juicy fact) down
  to `!!tc_val tint (Vint (Int.repr e)) && address_mapsto Mint32 (Vint
  (Int.repr e)) Ews (b, Ptrofs.unsigned ofs)`, eliminating `mapsto`'s
  `Vundef` disjunct (mirroring the first step of
  `dry_mem_lemmas.data_at_bytes`'s own `tarray tuchar` proof), under one
  explicit `field_compatible tint [] (Vptr b ofs)` hypothesis (always
  available at any real call site -- the same fact `IOSpecs.read_spec`'s
  own `data_at_` precondition already carries for its buffer pointer).
  Does **not** reach `Mem.loadbytes`/`errno_dry_pre` yet: turning
  `address_mapsto`'s own `EX bl, decode_val Mint32 bl = ...` into the
  exact byte sequence `errno_dry_pre`/`errno_dry_post_effect` require is a
  separate, larger lemma (comparable in size to `data_at_bytes` itself)
  the file's closing comment scopes precisely, not attempted this session.

- `ErrnoLoad.v` (job 11) -- the scalar errno memory bridge, finished:
  `errno_at_loadbytes`/`errno_at_dry_pre` derive the exact dry fact
  `Mem.loadbytes (m_dry jm) b ofs 4 = Some (errno_memval e)` (i.e.
  `MemAdequacy.errno_dry_pre`) from the juicy `errno_at (Vptr b ofs) e`
  held by a sub-rmap of `m_phi jm`. Two genuinely new pieces:
  `address_mapsto_loadbytes` (chunk-generic resource extraction from ONE
  `address_mapsto`, via JMcontents/JMaccess/getN -- not `data_at_bytes`'s
  per-element array induction) and `decode_val_Mint32_inj` (decode_val
  Mint32 bl = Vint i with |bl| = 4 forces bl = encode_val Mint32 (Vint i);
  proved from a new byte/int round-trip `bytes_of_int_of_bytes`, the
  direction CompCert's Memdata does not state, plus `inj_proj_bytes`; the
  Fragment/`None` branch is excluded by `Archi.ptr64 = true` by
  `reflexivity`, not assumed). No auxiliary/weakened errno definition was
  needed: the exact-bytes statement in `MemAdequacy.v` stands.
- `JuicyPre.v` (job 11) -- **the `juicy_dry_ext_spec` PRE-preservation
  conjunct, closed**: `iow_juicy_dry_pre` for `IOW_Espec`/`iow_dry_spec`/
  `iow_dessicate`, both read and write, modeled on relay's first bullet;
  the buffer uses `data_at__writable_perm`/`data_at_bytes` (with
  `sizeof (tarray tuchar n) = n` from `0 <= n`), the errno cell uses
  `ErrnoLoad.errno_at_dry_pre`, `has_ext_compat` supplies `s = z`.
- `PostLemmas.v`, `PostLemmas2.v` (job 11) -- auxiliaries for the
  POST-preservation conjunct, all checked: `contents_at_storebytes_other`;
  `rebuild_store_gen` (relay's `rebuild_store` with the store abstracted to
  the two facts its proof uses) and its instances `rebuild_store1`/
  `rebuild_store2` (every branch now stores errno, and read-success stores
  twice, so relay's single-store/unchanged-memory paths do not apply);
  `inflate_store_VALspec_range`/`inflate_store_data_at_` (restated from
  Dry.v); `inflate_store_address_mapsto` (scalar counterpart of
  `store_bytes_data_at`); `inflate_store_unchanged` (an rmap whose VALs
  already agree with memory is a fixpoint of `inflate_store` -- carries the
  untouched buffer across the errno store); `errno_at_inflate_store` (the
  errno cell after storing `errno_memval e'`, using CompCert's
  `decode_encode_val_general`).
- `PostLemmas3.v` (job 13) -- last auxiliaries for POST-preservation:
  share transport through joins (`join_sub_YES`, `join_sub_YES_writable`,
  `YES_join_writable_absurd`: a writable YES and any YES at one address
  cannot join -- this is what makes the frame own nothing in the stored
  ranges, two joins deeper than relay's argument), `YES_perm_readable`/
  `join_sub_YES_perm_readable`, `errno_at_YES` (every address of the errno
  cell is `YES Ews`), `inflate_store_ext` (`inflate_store` reads only VAL
  addresses), `rebuild_store_gen_val` (`rebuild_store_gen` with its
  contents hypothesis restricted to VAL, the only case its proof used it
  for) and `rebuild_store2'` -- the two-store rebuild where the errno store
  is performed on a memory merely `mem_equiv` to the buffer store's result,
  which is exactly the shape `DryPost.read_dry_post_n` states (so the
  accepted dry contract needed no change), `contents_unchanged_sub`,
  `bytes_to_memvals_length`, `errno_memval_Zlength`.
- `JuicyPost.v` (job 13) -- **the `juicy_dry_ext_spec` POST-preservation
  conjunct, closed**: `iow_juicy_dry_post`, both primitives, all three
  branches (read error, read success incl. EOF, write). Witnesses exactly as
  the plan below (kept for the record): `phi2 := set_ghost (age_to (level
  jm) (inflate_store m2 phi0)) (ext_ghost (new world) :: ...)`, `phi3 :=
  age_to (level jm) phi1'`, `m2` the final errno-stored memory; join via
  `resource_at_join2` + `rebuild_store1`/`rebuild_store2'`; ghost as relay's
  (`ext_ghost_join`/`no_two_ref`/`ghost_not_both`, hypothesis names by
  pattern instead of relay's auto-generated `H11`/`H12`); `x0 := e'`; SEP
  split `phig | phie | phib` (`inflate_store_join1`, `inflate_store_join`),
  has_ext via `change_has_ext`, errno via `errno_at_inflate_store` with the
  `loadbytes` from `Mem.loadbytes_storebytes_same`, buffer via
  `split2_data_at__Tarray_tuchar` + `Body.tuchar_subarray_offset` +
  `inflate_store_ext` (contents at the prefix agree between `m2` and the
  buffer store's result) + `store_bytes_data_at` + `inflate_store_data_at_`
  on success, `inflate_store_unchanged` + `contents_unchanged_sub` on error
  and for write. No admissions; the accepted `IOSpecs` contracts and the
  `DryPost` dry contracts are used verbatim.
- `JuicyDrySpecs.v` (job 13) -- **the full record**:
  `iow_juicy_dry_specs : juicy_dry_ext_spec IOW.world iow_ext_spec'
  iow_dry_spec' iow_dessicate'` (`split; [|split]` of `iow_juicy_dry_pre`,
  `iow_juicy_dry_post`, `dry_spec_exit`), plus `iow_dry_spec_mem_evolve`
  (`dry_spec_mem`) restated alongside so one `Print Assumptions` covers the
  whole package VST's whole-program adequacy consumes for an external
  specification. This is the utility-contract analogue of relay's
  `juicy_dry_specs`, at parametric fd/count and with the errno cell.
- `EmbedBridge.v` (job 13) -- the world/ghost embedding bridge one level
  above `AssertionBridge.v`, boundaries explicit: `relay_dry_spec_local`
  (relay's dry record over `Specs.Relay_Espec`, not the OOM `Main.Espec`),
  `embed_dry_witness` (relay dry WITH-tuple to generalized one at n = 32 /
  `embed` / caller-supplied errno), `embed_dry_pre` (on the actual records:
  relay's `ext_spec_pre` + the extra errno-cell fact implies
  `iow_dry_spec`'s `ext_spec_pre` at the transported witness and oracle
  `embed z`), `read_dry_post_n_to_relay`/`write_dry_post_n_to_relay` (the
  reverse, functional-consequence direction of `DryPost.v`: a generalized
  dry POST at n = 32/`embed` forces the oracle to be the `embed` image of
  relay's new world and yields relay's dry POST up to the errno store, with
  errno = 1 on error -- "Closed under the global context"), and
  `has_ext_embed`/`has_ext_relay_to_iow`: the ghost-state coercion between
  oracle types (`set_ghost` replacing `ext_ghost w : ext_PCM
  RelayProtocol.world` by `ext_ghost (embed w) : ext_PCM IOW.world`;
  `change_has_ext` generalized from Z to Z -> Z').
- `EmbedPre.v` (job 13) -- **assertion-level PRE transport for read,
  checked**: `read_pre_relay_to_iow`. Hypotheses: relay's `Specs.read_spec`
  PRE body (verbatim text) held by `phi0` at some `argsEnviron ga`; the errno
  cell `errno_at (gv errno_id) e` held by a disjoint `phie`; `join phi0
  phie phi`; `ext_compat s phi` (what VST's juicy PRE supplies for any real
  witness); `gvars_denote gv` at `ga`'s genv. Conclusion: `IOSpecs.read_spec`'s
  PRE body (verbatim text, at WITH `(gv, embed s, p, 32, e, sh)`) held by
  `set_ghost phi (ext_ghost (embed s) :: tl (ghost_of phi))` -- the same
  resources, ghost head coerced to the IOW oracle PCM. Construction: the
  `has_ext` part is `set_ghost phig` with the coerced head
  (`has_ext_relay_to_iow`); the buffer and errno parts get a `None` ghost
  head (so no cross-PCM ghost join ever arises: `some_none_cons_join`,
  `none_cons_join`, `tl_ghost_join`), and resource-only predicates survive
  `set_ghost` (`set_ghost_VALspec_range`, `set_ghost_data_at__tuchar`,
  `set_ghost_address_mapsto`, `set_ghost_errno_at`). The write counterpart
  is not done: it needs one more transfer lemma, `data_at sh (tarray tuchar
  n) (map Vubyte bs) p` across `set_ghost` (value-carrying `byte_array`,
  not `data_at_`), see "Still open". -- *Done in job 14, `EmbedPre2.v`.*
- `EmbedPre2.v` (job 14) -- **write twin, checked**: `write_pre_relay_to_iow`
  (verbatim `Specs.write_spec` PRE body + errno cell to verbatim
  `IOSpecs.write_spec` PRE body at `(gv, embed s, p, bs, e, sh)` on the
  ghost-coerced rmap). The value-carrying `byte_array` transfers through
  `nh` (`nh_byte_array`): `data_at_rec_eq` unfolds it to a `rangespec` fold
  of per-byte `mapsto`s ending in `emp`; `nh` drops a non-nil ghost head to
  `None` (nil stays nil) and is compatible with join (`nh_join`), `emp`
  (`nh_emp`, via `res_predicates.emp_no` -- in VST 2.15 `emp` is
  resource-only), sepcon (`nh_sepcon`), `rangespec` (`nh_rangespec`) and
  address_mapsto. The has_ext part keeps the coerced head; the rest is
  `nh`-normalized (`head_swap_nh_join`).
- `EmbedJuicy.v` (job 14) -- **juicy PRE witness transport, read, checked,
  on the actual records**: `read_juicy_pre_relay_to_iow`. Hypotheses: a
  relay juicy PRE witness `ext_spec_pre (OK_spec (Relay_Espec ext_link)) ef
  t b tl vl z jm` for the read dispatch, the explicit dry-memory
  relationship `mem_cell_ext (m_dry jm) m' eb e` (m' extends m_dry jm by a
  4-byte cell in a block eb FRESH for m_dry jm: contents/access agree
  outside, Cur = Writable and Max >= Writable inside, bytes = errno_memval
  e), and the symbol-table fact `errno_id |-> eb` in the call's own `b`.
  Conclusion: an IOW juicy PRE witness `ext_spec_pre (OK_spec (IOW_Espec
  errno_id ext_link)) ef (embed_juicy_witness gv e phi1n ef t) b tl vl
  (embed z) (jmJ jm m' eb e (embed z) Hc)` with `gv = genv_globals b`.
  Everything is constructed, nothing assumed valid: `errno_rmap` (an
  explicit `make_rmap` holding the cell as `YES Ews VAL` and the unit of
  the base rmap elsewhere; satisfies the verbatim `errno_at (Vptr eb
  Ptrofs.zero) e`, `errno_rmap_errno_at`), `ext_rmap` (base ⊕ cell, join
  proved, `ext_rmap_join`; the base is NO-bot on the cell by
  alloc_cohere + `join_NO_bot_left`), `phiJ` (ext_rmap of `m_phi jm` with
  the oracle ghost head coerced), `phiJ_cohere` (all four cohesion
  predicates for m' proved from `mem_cell_ext` + jm's own cohesion +
  `SequentialClight.set_ghost_cohere`), `jmJ := mkJuicyMem m' phiJ ...`.
  The new frame is `nh phi1'`; `ext_compat (embed z)` of jmJ is proved via
  `ext_ref_join_opt`; the precondition part is `EmbedPre.read_pre_relay_to_iow`.
- `EmbedJuicy2.v` (job 14) -- `write_juicy_pre_relay_to_iow` (write twin;
  one extra explicit hypothesis `ext_link "read" <> ext_link "write"`, needed
  to refute the read dispatch for a write call -- stated, not assumed as
  injectivity), and the **PRE-side external-call correspondence at the
  dry boundary**: `relay_read_call_iow_dry_pre` / `relay_write_call_iow_dry_pre`:
  relay juicy witness + cell extension + `errno_id |-> eb` yield the CONCRETE
  `iow_dry_spec` precondition (buffer permission, args, errno bytes) at
  `m'` for the dessicated transported witness -- the juicy transport
  composed with the accepted record's PRE-preservation
  (`JuicyPre.iow_juicy_dry_pre`). With `EmbedBridge.read/write_dry_post_n_to_relay`
  (generalized dry POST back to relay's dry POST + errno effect, oracle
  forced to `embed` of relay's new world) and `JuicyPost.iow_juicy_dry_post`
  (dry POST to IOW juicy POST), this is the read/write external-call
  correspondence between the relay contracts and the generalized ones,
  stated without a whole program.
- `EmbedJuicy3.v` (job 14) -- **POST-side chaining on the actual records**:
  `relay_read_call_iow_dry_post` / `relay_write_call_iow_dry_post`. For the
  transported, dessicated witness of a relay read/write call, any
  `ext_spec_post iow_dry_spec'` at a final memory `m_f`, return `v`, new
  oracle `x` gives `ot <> Xvoid`, `v = Some (Vlong i)`, `x = embed` of
  relay's own new world (`read_world (read32 z)` / `write_world
  (write_block z bs)`), relay's dry POST (`relay_read_dry_post m' m1 i (z,p)
  ..` / `relay_write_dry_post m' m' i (z,p,bs) ..`) and the errno effect
  `m1 -> m_f` (`m' -> m_f` for write) at `genv_globals b errno_id` with
  errno = 1 on error. Same dispatch prologue as the PRE corollaries;
  `valid_world z` comes from the relay PRE witness. Together with
  `relay_read/write_call_iow_dry_pre` this closes item (ii)+(iii) of the
  accepted claim as single theorems.

## The exact "extras" the generalized contracts add over relay32 (do not
claim these away)

1. **errno.** `IOSpecs.errno_at (gv errno_id) e` is an extra `SEP` resource
   in both PRE and POST, plus an existential `e'` in the POST and a
   conditional `PROP` (`read_ret ... < 0 -> e' = read_errno ...`; *unconstrained*
   on success). Relay's `read_spec`/`write_spec` own no such resource at
   all -- a relay call site cannot supply it, so a `funspec_sub` from the
   generalized spec down to relay's is not obtainable (a stronger spec
   cannot demand a resource the weaker one's callers don't have), and none
   is claimed. At the CompCert layer this is `MemAdequacy.errno_dry_pre`,
   an extra 4-byte `Mem.loadbytes` obligation with no relay analogue.
2. **fd.** Generalized `PARAMS (Vint (Int.repr (in_fd s)); ...)` vs relay's
   literal `Vint Int.zero`/`Vint Int.one`. Only equal when the caller
   already knows `s = embed w` for some relay world `w` (`embed_in_fd`/
   `embed_out_fd`, `reflexivity`); the generalized spec does not derive fd
   0/1 on its own.
3. **count/request bound.** Generalized side condition `0 <= n <=
   SYS_BUFSIZE_MAX` (2146435072) vs relay's literal `32` (read) /
   `0 < Zlength bs <= 32` (write, note relay's *strict* lower bound `0 <`,
   the generalized spec's is `0 <=`). `SYS_BUFSIZE_MAX_eq` (`IOWorld.v`)
   already checks the constant against gnulib's `sys-limits.h` formula.
4. **GLOBALS clause.** The generalized spec carries `GLOBALS (gv)` (needed
   to locate the errno cell); relay's does not, since it has nothing global
   to locate.
5. **stdio/fatal-error imports distinction.** `IOSpecs.v`'s
   `quotearg_spec`/`error_spec`/`write_error_spec` are trust-boundary
   assumptions for the gnulib/coreutils wrapper layer (`SafeRead`/
   `SafeWrite`/`FullWrite`/`simple_cat`) that have **no relay counterpart at
   all** -- relay is a bare two-syscall program with no diagnostic path, so
   there is nothing in `../../relay/Specs.v` to specialize these three
   against. They are new trust boundary, not generalized-from-relay
   boundary, and are listed here only so they are not mistaken for part of
   the specialization.

Point 1 is why this directory does not attempt (and does not claim) a
`funspec_sub` between `IOSpecs.read_spec`/`write_spec` and
`Specs.read_spec`/`write_spec`; see `Specialize.v`'s and
`AssertionBridge.v`'s closing/header comments. There is a second, sharper
reason beyond the missing errno resource, found while building
`JuicyDry.v`: `has_ext s`/`has_ext (embed w)` are assertions about ghost
state typed to whichever `OracleKind` a program is eventually verified
under (its `@OK_ty`). `relay/Specs.v` fixes this once, for the whole relay
program, as `RelayProtocol.world` (`Relay_Espec`). No such choice existed
for `IOSpecs.v` before this session (no linked `main`, `utility-reuse/
RESULTS.md`'s own scope section; the VSU proofs use `NullExtension.Espec`,
`OK_ty = unit`, which doesn't need a program-wide oracle choice at the
body-proof level). `JuicyDry.v` now makes one (`IOW_Espec`, `OK_ty =
IOW.world`, checked by `iow_espec_ok_ty`) -- under it, `has_ext` assertions
typed against `Relay_Espec` and against `IOW_Espec` are about different
ghost PCMs and are not comparable by any `mpred` entailment without a
*third*, unifying Espec and a ghost-state-level coercion; `embed` (a plain
total function between the two *pure* world types) is not such a coercion
and was never used at the ghost-state level anywhere in this directory or
`../coq/`.

## Status after job 13 and what remains

**Closed (job 13):** the full `juicy_dry_ext_spec` record
`JuicyDrySpecs.iow_juicy_dry_specs` for `IOW_Espec`/`iow_dry_spec`/
`iow_dessicate` -- PRE-preservation (`JuicyPre.iow_juicy_dry_pre`, job 11),
POST-preservation (`JuicyPost.iow_juicy_dry_post`, job 13) and exit
(`JuicyDry.dry_spec_exit`) -- together with `dry_spec_mem`. Items 1 and 2 of
the previous "Remaining gap" list are therefore done; the text of item 1 is
kept below verbatim as the record of what was proved, since `JuicyPost.v`
follows it exactly.

**Closed (job 14):** the write twin (`EmbedPre2.write_pre_relay_to_iow`),
the juicy PRE witness transport for read and write on the actual records
(`EmbedJuicy.read_juicy_pre_relay_to_iow`, `EmbedJuicy2.write_juicy_pre_relay_to_iow`,
with the transported juicy memory `jmJ` explicitly constructed and its
cohesion proved), and the PRE-side call correspondence at the dry boundary
(`EmbedJuicy2.relay_read_call_iow_dry_pre` / `relay_write_call_iow_dry_pre`).

**The accepted claim, precisely.** For an external `read`/`write` call of
the relay program (any juicy PRE witness `t` in `jm` under
`OK_spec (Relay_Espec ext_link)`), given a dry memory `m'` that extends
`m_dry jm` by a 4-byte errno cell in a block `eb` fresh for `m_dry jm`
(`mem_cell_ext`), and the call's symbol table mapping `errno_id` to `eb`:
(i) the IOW juicy PRE (`IOSpecs.read_spec`/`write_spec` under
`OK_spec (IOW_Espec errno_id ext_link)`) holds for the transported
witness at the constructed juicy memory `jmJ` (dry part `m'`, oracle
ghost coerced to `embed z`); (ii) hence, by the accepted record, the
concrete dry precondition `iow_dry_spec` demands holds at `m'`; (iii) any
dry POST of the generalized call at n = 32 forces the new oracle to be
`embed` of relay's new world and yields relay's dry POST up to the errno
store (`EmbedBridge.read/write_dry_post_n_to_relay`); (iv) any juicy
memory rebuilt from such a dry POST satisfies the IOW juicy POST
(`JuicyPost.iow_juicy_dry_post`). Not claimed: a `funspec_sub` (errno
resource), a whole-program adequacy statement for `IOW_Espec` (no linked
`main`), or a POST-side juicy transport back to `Relay_Espec` (the relay
program has no errno cell to return the resource to; see NEXT).

**Still open (exact):**

- POST-side composition on the actual records -- *done in job 14,
  `EmbedJuicy3.relay_read/write_call_iow_dry_post`.*
- A relay-side juicy POST witness (transport back to `Relay_Espec` after
  the call): not attempted and not needed for the ledger row. The relay
  program owns no errno cell to which the `errno_at` resource could be
  returned, so such a witness would require changing relay's contract;
  the correspondence stops at relay's *dry* POST (`relay_read_dry_post`),
  which is what relay's own adequacy consumes.
- A juicy-level transport of whole relay PRE *witnesses* to IOW witnesses
  -- *done in job 14 (`EmbedJuicy.v`, `EmbedJuicy2.v`); the text below is
  kept as the record of the design that was implemented.* Previously:
  `EmbedBridge.v` supplies the ghost coercion for the `has_ext` conjunct
  (`has_ext_relay_to_iow`) and the dry-record PRE transport
  (`embed_dry_pre`), `EmbedPre.v` the assertion-level transport of the
  read precondition body; what is not built is the statement
  `ext_spec_pre relay_juicy ef (phi1, ts, (w,p,sh)) b tl vl w jm ->
   ext_spec_pre iow_ext_spec' ef (phi1', ts, (gv, embed w, p, 32, e, sh)) b tl vl (embed w) jm'`
  for suitable `phi1'`/`jm'`: `jm'` must be a *different* juicy memory
  (its `m_phi` ghost head is `ext_ghost (embed w)`, and `ext_compat (embed
  w)` must be re-established for it), and the errno cell resource must be
  joined in from outside (relay's witness does not own it: "extras" point
  1). That is a construction on juicy memories (`juicy_mem` rebuild with a
  coerced ghost), not a lemma about assertions, and is the remaining
  design item. No `funspec_sub` is obtainable (same point 1).
- Whole-program use: `IOW_Espec` has no linked `main` (no generalized
  `prog_correct`), so `iow_juicy_dry_specs` is the *external* half of an
  adequacy argument, exactly as relay's `juicy_dry_specs` is; the ledger
  row's "adequacy" wording should be read with that scope.

The record of item 1 as it was stated before being proved:

1. **POST-preservation**, statement (job 11's `ProbePost` receipt
   `utility-leaf11-probe-post-1` records the shared prologue succeeding and
   the exact residual goal; job 13's `JuicyPost.v` closes it):
   ```
   forall ef t t' b ot v x jm0 jm,
     (exists tl vl x0, iow_dessicate ef jm0 t = t' /\
        ext_spec_pre iow_ext_spec' ef t b tl vl x0 jm0) ->
     (level jm <= level jm0)%nat ->
     resource_at (m_phi jm) = resource_fmap (approx (level jm)) (approx (level jm))
        oo juicy_mem_lemmas.rebuild_juicy_mem_fmap jm0 (m_dry jm) ->
     ghost_of (m_phi jm) = Some (ext_ghost x, NoneP)
        :: ghost_fmap (approx (level jm)) (approx (level jm)) (tl (ghost_of (m_phi jm0))) ->
     ext_spec_post iow_dry_spec' ef t' b ot v x (m_dry jm) ->
     ext_spec_post iow_ext_spec' ef t b ot v x jm.
   ```
   After the prologue (read branch) the residual goal is, with `z0` the
   pre-state world, `e'`/`m1` from `read_dry_post_n`, `phi0 = phig ⊕ phir`,
   `phir = phib ⊕ phie` (has_ext / buffer / errno):
   ```
   exists phi2 phi3, join phi2 phi3 (m_phi jm) /\
     (EX x0, PROP (read_ret (read_n n z0) < 0 -> x0 = read_errno (read_n n z0))
             RETURN (Vlong (Int64.repr (read_ret (read_n n z0))))
             SEP (has_ext (read_world (read_n n z0)); errno_at (gv errno_id) x0;
                  if read_ret (read_n n z0) <? 0 then data_at_ sh (tarray tuchar n) p
                  else buffer_prefix_n sh p n (read_bytes (read_n n z0))))
        (make_ext_rval (filter_genv (symb2genv b)) ot (Some (Vlong i))) phi2
     /\ necR phi1 phi3
   ```
   Intended witnesses, following relay's read-success bullet: `phi2 :=
   set_ghost (age_to (level jm) (inflate_store m_final phi0)) (Some
   (ext_ghost (read_world ..), NoneP) :: ghost_approx .. (tl (ghost_of
   phi0)))`, `phi3 := age_to (level jm) phi1'`; the join via
   `resource_at_join2` + `PostLemmas.rebuild_store2` (read success: buffer
   then errno) or `rebuild_store1` (read error, write: errno only), whose
   `Hout` side conditions ("the frame owns no YES in the stored ranges")
   come from `phib`/`phie`'s writable/Ews ownership through `J2`/`J1`/`J`
   (relay's `join_writable_readable` argument, now two joins deeper);
   ghost part as relay's (`age_rejoin`, `set_ghost_join`, `ext_ghost_join`,
   `ghost_not_both`); `x0 := e'`; SEP split as relay's
   (`inflate_store_join1` for the has_ext part, `change_has_ext`,
   `age_to_pred`), buffer via `store_bytes_data_at` +
   `inflate_store_data_at_` (success) or `inflate_store_unchanged` (error /
   write), errno via `PostLemmas2.errno_at_inflate_store` with the
   `loadbytes` from `Mem.loadbytes_storebytes_same` + `mem_equiv`. Every
   lemma named here exists and is checked; what is not done is the
   ~200-line assembly itself. This is the "returned-status functional
   consequence" theorem the ledger row still needs. -- *Done in job 13
   (`JuicyPost.v`), 420 lines including the write branch; one deviation
   from the plan: `rebuild_store2` could not be used directly because the
   errno store acts on `m1`, only `mem_equiv` to the buffer store's exact
   result, hence `PostLemmas3.rebuild_store2'`.*
2. Assembling the three conjuncts into one `juicy_dry_ext_spec _
   iow_ext_spec' iow_dry_spec' iow_dessicate'` statement once (1) lands
   (a `split; [|split]` of the three, mechanical). -- *Done in job 13
   (`JuicyDrySpecs.v`).*
3. A checked funspec-level bridge stronger than `AssertionBridge.v`'s --
   unchanged from job 9's assessment (third unifying Espec + ghost-state
   coercion; separate design work). -- *Partly done in job 13
   (`EmbedBridge.v`: dry-record transport + ghost coercion); the juicy
   witness transport remains, see "Still open" above.*

## Receipts

All commands are `run_vst.py --name utility-leaf{8,9,10,11,13}-* -- coqc -Q
../../relay '' -Q .. '' -Q . '' <File>.v` from
`/home/coq/phase5/utility-reuse/adequacy` in the shared `phase5-vst`
container, serialized on `~/.cache/bash-spec-pilot/phase3-compiler.lock`.
Receipts: `~/agent-jobs/astra-research/phase5/runs/utility-leaf{8,9,10,11,13}-*.{json,log}`.

Job 13 clean replay (`utility-leaf13-replay-20260908T114429Z-NN-<File>`,
NN = 01..13 in dependency order, after deleting these files' `.vo`/`.vos`/
`.vok`/`.glob` in the container so nothing was reused; 14/15 are the two
audits): every receipt exit 0, timing exit 0. Source sha256 at replay
(repo and container identical, checked by the runner before each coqc):

| File | Theorem(s) | Job-13 replay receipt (exit) | sha256 (first 16) |
|---|---|---|---|
| `Specialize.v` | `read_n_specializes_read32`, `write_n_specializes_write_block`, `embed_valid` | `...-01-Specialize` (0) | `d3216a1e1a325eab` |
| `MemAdequacy.v` | `read_dry_pre_specializes`, `write_dry_pre_specializes` | `...-02-MemAdequacy` (0) | `b87e9e61acbc8009` |
| `DryPost.v` | `read_dry_post_specializes`, `write_dry_post_specializes` | `...-03-DryPost` (0) | `828b7b2c786eb6cf` |
| `AssertionBridge.v` | `read_params_bridge`, `write_params_bridge`, `read_post_buffer_bridge`, `read_errno_on_error`, `write_errno_on_error` | `...-04-AssertionBridge` (0) | `36cf021d8773475d` |
| `JuicyDry.v` | `iow_espec_ok_ty`, `dry_spec_mem`, `dry_spec_exit` | `...-05-JuicyDry` (0) | `fc9f3af39e36b3ff` |
| `ErrnoBridge.v` | `errno_at_address_mapsto` | `...-06-ErrnoBridge` (0) | `7f3229c34373753d` |
| `ErrnoLoad.v` | `bytes_of_int_of_bytes`, `decode_val_Mint32_inj`, `getN_contents`, `address_mapsto_loadbytes`, `errno_at_loadbytes`, `errno_at_dry_pre` | `...-07-ErrnoLoad` (0) | `4cbe7ee6d713f045` |
| `JuicyPre.v` | `iow_juicy_dry_pre` (PRE-preservation conjunct) | `...-08-JuicyPre` (0) | `ec7c9bccde3dfad4` |
| `PostLemmas.v` | `contents_at_storebytes_other`, `rebuild_store_gen`, `rebuild_store2`, `rebuild_store1`, `inflate_store_VALspec_range`, `inflate_store_data_at_`, `inflate_store_address_mapsto` | `...-09-PostLemmas` (0) | `ad34391192db123d` |
| `PostLemmas2.v` | `inflate_store_unchanged`, `decode_errno_memval`, `errno_at_inflate_store` | `...-10-PostLemmas2` (0) | `9c19879b04549b66` |
| `PostLemmas3.v` | `join_sub_YES`, `join_sub_YES_writable`, `YES_join_writable_absurd`, `YES_perm_readable`, `join_sub_YES_perm_readable`, `errno_at_YES`, `inflate_store_ext`, `rebuild_store_gen_val`, `rebuild_store2'`, `contents_unchanged_sub`, `bytes_to_memvals_length`, `errno_memval_Zlength` | `...-11-PostLemmas3` (0) | `ea3b2bd8c6922fce` |
| `JuicyPost.v` | `iow_juicy_dry_post` (POST-preservation conjunct) | `...-12-JuicyPost` (0) | `262db94f97ff7125` |
| `JuicyDrySpecs.v` | `iow_juicy_dry_specs` (full `juicy_dry_ext_spec` record), `iow_dry_spec_mem_evolve` | `...-13-JuicyDrySpecs` (0) | `1105fbd4404719ef` |
| `EmbedBridge.v` | `has_ext_embed`, `has_ext_relay_to_iow`, `read_dry_post_n_to_relay`, `write_dry_post_n_to_relay`, `relay_dry_spec_local`, `embed_dry_witness`, `embed_dry_pre` | `utility-leaf13-replay2-20260908T120030Z-01-EmbedBridge` (0) | `386dab85de318fcc` |
| `EmbedPre.v` | `set_ghost_VALspec_range`, `set_ghost_data_at__tuchar`, `set_ghost_address_mapsto`, `set_ghost_errno_at`, `tl_ghost_join`, `none_cons_join`, `some_none_cons_join`, `read_pre_relay_to_iow` | `utility-leaf13-replay2-20260908T120030Z-02-EmbedPre` (0) | `2cf7b406924a5507` |
| `EmbedPre2.v` (job 14) | `nh_*` (ghost-head normalization: join, emp, sepcon, rangespec, address_mapsto, errno_at), `nh_byte_array`, `head_swap_nh_join`, `write_pre_relay_to_iow` | `utility-leaf14-replay-20260908T122521Z-01-EmbedPre2` (0) | `e49d7af1a1d5ff8b` |
| `EmbedJuicy.v` (job 14) | `mem_cell_ext`, `getN_nth`, `loadbytes_contents_at`, `cell_res`/`errno_rmap` (+ `errno_rmap_errno_at`, `fc_tint_zero`), `ext_res`/`ext_rmap` (+ `ext_rmap_join`), `coerced_valid`, `phiJ`, `phiJ_cohere`, `jmJ`, `join_NO_bot_left`, `ext_ref_join_opt`, `genv_globals`, `embed_juicy_witness`, `read_juicy_pre_relay_to_iow` | `utility-leaf14-replay-20260908T122521Z-02-EmbedJuicy` (0) | `56c6caeeba5f8708` |
| `EmbedJuicy2.v` (job 14) | `write_juicy_pre_relay_to_iow`, `relay_read_call_iow_dry_pre`, `relay_write_call_iow_dry_pre` | `utility-leaf14-replay-20260908T122521Z-03-EmbedJuicy2` (0) | `93bebfdbb5662688` |
| `EmbedJuicy3.v` (job 14) | `relay_read_call_iow_dry_post`, `relay_write_call_iow_dry_post` | `utility-leaf14-replay3-20260908T124712Z-01-EmbedJuicy3` (0), audit `-02-AuditEmbedJuicy3` (0, standard axioms only) | `05302c7fd74c3b39` |

**Consolidated fresh dependency receipts (end of job 14):**
`utility-leaf14-full-20260908T124833Z-{01..19}` recompiled ALL nineteen
files of this directory (JuicyPostWrite.v excluded, Pi's) in dependency
order after deleting every one of their `.vo/.vos/.vok/.glob` in the
container, then `-{20..27}` re-ran all eight audits: 27/27 exit 0 /
timing 0, each log sha256 identical to the file's earlier accepted run
(deterministic). Source sha256 per file as in the table.

(`replay2` = the two bridge files recompiled after deleting their container
build artifacts, followed by their audits `-03-AuditEmbed`, `-04-AuditEmbedPre`.
Job 14's replay `utility-leaf14-replay-20260908T122521Z-{01..03}` likewise
recompiled the three job-14 files after deleting their artifacts, followed
by audits `-04-AuditEmbedPre2`, `-05-AuditEmbedJuicy`, `-06-AuditEmbedJuicy2`;
all six exit 0 / timing 0; the job-14 audits list the same standard axioms,
`eq_rect_eq` appearing exactly on the theorems that compose with
`JuicyPre`/inversion on ghost joins: `read/write_juicy_pre_relay_to_iow`,
`relay_read/write_call_iow_dry_pre`; `phiJ_cohere` needs only `prop_ext`
and functional extensionality.)

`Print Assumptions` (job 13: `utility-leaf13-replay-20260908T114429Z-14-AuditPost`
on `iow_juicy_dry_post`, `-15-AuditSpecs` on `iow_juicy_dry_specs` and
`iow_dry_spec_mem_evolve`, `utility-leaf13-replay2-20260908T120030Z-03-AuditEmbed`
on `EmbedBridge.v`'s four theorems, `-04-AuditEmbedPre` on
`read_pre_relay_to_iow`; earlier jobs: `utility-leaf9-audit-all-1`,
`utility-leaf10-eb-audit-1`, `utility-leaf11-{el,el-jp,pl,pl2}-audit-1`):
only the standard classical/functional-extensionality axioms already used
throughout this project (`classic`, `prop_ext`,
`functional_extensionality_dep`, `sig_not_dec`/`sig_forall_dec`, and for
`iow_juicy_dry_post`/`iow_juicy_dry_specs`/`read_pre_relay_to_iow` also Coq's stdlib
`Eqdep.Eq_rect_eq.eq_rect_eq` -- the same set relay's accepted adequacy
audit `adequacy-audit-coqc-1` lists, it enters through `inversion` on the
dependent ghost joins exactly as in relay's `juicy_dry_specs`), or "Closed
under the global context" for the purely constructive ones -- no
`Admitted`, no project axioms. `grep -n "Admitted\|^Axiom" *.v` (this
directory) is empty. See `STATUS.md` in each job directory for the full
command/error history (every intermediate rejected attempt) and
`REPORT.md` for the outcome summary in narrative form.
