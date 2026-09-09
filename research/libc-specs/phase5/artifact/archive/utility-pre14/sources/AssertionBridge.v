(* Funspec-level bridge, scoped as follows (see the header comment before
   the theorems for the precise justification): a `funspec_sub` between
   `../IOSpecs.v`'s `read_spec`/`write_spec` and `../../relay/Specs.v`'s is
   NOT attempted here, and the reason is a checked type fact, not prose --
   see the "why `has_ext` cannot be bridged" note below and
   `JuicyDry.v`'s `iow_espec_ok_ty` and its header comment. What IS checked here is
   the part of the two funspecs' PRE/POST that does not mention `has_ext`:
   the byte-buffer resource, the fd `PARAMS`, and the errno value on error.
   These are exactly the assertions REUSE.md/README.md already singled out
   as "the extras" (fd, errno); this file makes the non-extra remainder
   (the byte buffer) into a checked equality instead of a claim, and pins
   the fd extra down to a `reflexivity` fact rather than leaving it prose.

   Why `has_ext` cannot be bridged at the assertion level, precisely: it is
   not merely that the generalized PRE owns an extra `errno_at` resource a
   relay call site lacks (README.md's "extras" list, already established);
   `has_ext s`/`has_ext (embed w)` are propositions about GHOST STATE
   tracked by whichever `OracleKind` the enclosing program is eventually
   verified under (`@OK_ty` of that `OracleKind`). `relay/Specs.v` fixes
   this once, for the whole relay program, as `RelayProtocol.world`
   (`Relay_Espec`, `relay/Specs.v`'s last two definitions). No such choice
   has been made for `IOSpecs.v` (no linked `main` exists for the
   generalized development at all -- `utility-reuse/RESULTS.md`'s own scope
   section; the VSU body proofs use `NullExtension.Espec`, whose `OK_ty` is
   `unit`, precisely because body proofs do not need a program-wide oracle
   choice, only a *use* of it does). `JuicyDry.v` makes one such choice
   (`IOW_Espec`, `OK_ty := IOW.world`) for the purpose of the adequacy
   record it attempts; under that choice, `@OK_ty (Relay_Espec ext_link) =
   RelayProtocol.world <> IOW.world = @OK_ty (IOW_Espec ext_link)` is a
   `reflexivity`-checkable fact (`JuicyDry.v`), so `has_ext` assertions
   typed against the two Especs are propositions about different ghost
   PCMs and are not comparable by any `mpred` entailment without first
   picking a *third*, unifying Espec and a coercion `RelayProtocol.world ->
   IOW.world -> (unified Z)` -- `embed` alone, a plain total function
   between the two *pure* world types, is not such a coercion (it says
   nothing about ghost state) and was never used at the ghost-state level
   in any accepted proof in this directory or `../coq/`. *)
Require Import VST.floyd.proofauto.
Require Import relay Protocol Reach.
Require Import IOWorld IOSpecs.
Require Import Specialize.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

(* ---- fd PARAMS: the generalized PARAMS reduce to relay's literal fd
   exactly when s = embed w (embed_in_fd/embed_out_fd already established
   this by reflexivity in Specialize.v; restated here as the PARAMS-typed
   facts the two DECLAREs actually use). ---- *)

Theorem read_params_bridge : forall w,
  Vint (Int.repr (IOW.in_fd (embed w))) = Vint Int.zero.
Proof. intros; reflexivity. Qed.

Theorem write_params_bridge : forall w,
  Vint (Int.repr (IOW.out_fd (embed w))) = Vint Int.one.
Proof. intros; reflexivity. Qed.

(* ---- byte-buffer POST resource: the actual SEP disjunct IOSpecs.read_spec
   returns, instantiated at n = 32 and s = embed w, is definitionally the
   SAME mpred as relay's read_spec's (not merely entailment-equivalent,
   not merely "the same bytes" -- literal Coq `=` of the mpred terms,
   obtained by composing the two already-accepted rewrites
   Specialize.read_n_specializes_read32 and IOSpecs.buffer_prefix_relay). ---- *)

Theorem read_post_buffer_bridge : forall w sh p,
  RelayProtocol.valid_reads (RelayProtocol.reads w) ->
  (if read_ret (read_n 32 (embed w)) <? 0
   then data_at_ sh (tarray tuchar 32) p
   else buffer_prefix_n sh p 32 (read_bytes (read_n 32 (embed w))))
  =
  (if RelayProtocol.read_ret (RelayProtocol.read32 w) <? 0
   then data_at_ sh (tarray tuchar 32) p
   else Specs.buffer_prefix sh p (RelayProtocol.read_bytes (RelayProtocol.read32 w))).
Proof.
  intros w sh p Hv.
  rewrite (Specialize.read_n_specializes_read32 w Hv). simpl.
  rewrite IOSpecs.buffer_prefix_relay. reflexivity.
Qed.

(* The write-side buffer resource needs no bridge lemma: `IOSpecs.v`
   defines `Notation byte_array := Specs.byte_array` (a literal alias, not
   a distinct predicate), and both `write_spec`s keep it unconditionally
   unchanged in PRE and POST (no branch on success/error), so the two
   funspecs' buffer SEP conjunct is the same term by construction, with no
   dependence on `w`/`embed`/`n` at all. *)

(* ---- errno-on-error value: forced to exactly 1 under embed, matching
   relay's own error sentinel (-1) one-for-one via the embedding chosen in
   Specialize.v (embed's schedule lists are untouched, so relay's fixed
   error code corresponds to IOW's errno = 1, never an arbitrary value). ---- *)

Theorem read_errno_on_error : forall w,
  RelayProtocol.valid_reads (RelayProtocol.reads w) ->
  RelayProtocol.read_ret (RelayProtocol.read32 w) < 0 ->
  read_errno (read_n 32 (embed w)) = 1.
Proof.
  intros w Hv Hneg.
  rewrite (Specialize.read_n_specializes_read32 w Hv). simpl.
  destruct (Z.ltb_spec (RelayProtocol.read_ret (RelayProtocol.read32 w)) 0); [reflexivity | lia].
Qed.

Theorem write_errno_on_error : forall w bs,
  RelayProtocol.valid_writes (RelayProtocol.writes w) ->
  RelayProtocol.write_ret (RelayProtocol.write_block w bs) < 0 ->
  write_errno (write_n bs (embed w)) = 1.
Proof.
  intros w bs Hv Hneg.
  rewrite (Specialize.write_n_specializes_write_block w bs Hv). simpl.
  destruct (Z.ltb_spec (RelayProtocol.write_ret (RelayProtocol.write_block w bs)) 0); [reflexivity | lia].
Qed.

(* ---- what this file does and does not establish ----
   Checked: the fd PARAMS, the byte-buffer POST resource (a literal mpred
   equality, not an entailment), and the errno-on-error value all reduce
   exactly to relay's own quantities under n=32/embed. This is the full
   "non-oracle, non-errno-resource" content of the two funspecs' PRE/POST
   agreeing under specialization -- i.e. everything REUSE.md's "extras"
   list did not already flag as new. NOT claimed: a `funspec_sub` in
   either direction, a comparison of the two `has_ext` assertions (see the
   header note; this is a structural fact about picking an Espec, not
   something this file's proof technique could paper over even with more
   time), or anything about the errno value on SUCCESS (the funspec itself
   leaves it an unconstrained existential; there is nothing to bridge). *)
