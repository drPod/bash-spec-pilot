(* Full juicy/dry external-specification adequacy for the generalized
   read/write leaves, attempted (not assumed to be out of scope) per this
   session's assignment. Modeled directly on ../../relay/adequacy/Dry.v's
   `relay_dry_spec`/`dessicate`/`juicy_dry_specs`/`dry_spec_mem`, adapted
   to IOSpecs' larger WITH-tuples (gv, s, p, n, e, sh for read; gv, s, p,
   bs, e, sh for write, vs relay's s, p, sh) and to `read_dry_pre_n`/
   `write_dry_pre_n`/`read_dry_post_n`/`write_dry_post_n` (MemAdequacy.v/
   DryPost.v) in place of relay's fixed-32/no-errno pre/post.

   Espec choice: relay's own construction is tied to `Main.Espec`, i.e. a
   whole linked program (`relay_ext_spec := @OK_spec Main.Espec`). No such
   linked program exists for the generalized development (no `main`
   verified against IOSpecs' funspecs anywhere in `../coq/` -- the VSU
   proofs there use `NullExtension.Espec`, `OK_ty = unit`, which is right
   for a body/VSU proof but not for stating adequacy against `read_spec`/
   `write_spec`'s own oracle). This file makes its own standalone Espec,
   `IOW_Espec`, exactly the way `../../relay/Specs.v`'s last two
   definitions (`Relay_void_Espec`/`Relay_Espec`) make relay's -- probe-
   tested first (`utility-leaf9-probe-espec-2`, exit 0) before use here.
   `AssertionBridge.v`'s header cites this file's `iow_espec_ok_ty`
   for why this is a genuinely different, non-unifiable choice from
   `Relay_Espec`, not an arbitrary one. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.veric.juicy_extspec.
Require Import VST.veric.juicy_mem.
Require Import VST.veric.compcert_rmaps.
Require Import VST.veric.initial_world.
Require Import VST.veric.ghost_PCM.
Require Import VST.veric.SequentialClight.
Require Import VST.concurrency.conclib.
Require Import VST.veric.mem_lessdef.
Require Import dry_mem_lemmas.
Require Import relay Protocol Reach.
Require Import IOWorld IOSpecs.
Require Import Specialize.
Require Import MemAdequacy.
Require Import DryPost.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

Section IOWEspec.
Variable errno_id : ident.

Definition IOW_void_Espec : OracleKind := ok_void_spec IOW.world.

Definition IOW_Espec (ext_link : string -> ident) : OracleKind :=
  add_funspecs IOW_void_Espec ext_link
    [(ext_link "read"%string, snd (read_spec errno_id (ext_link "read"%string)));
     (ext_link "write"%string, snd (write_spec errno_id (ext_link "write"%string)))].

(* The checked fact AssertionBridge.v's header cites: this Espec's oracle
   type is IOW.world, by `reflexivity` -- not itself a proof that
   `RelayProtocol.world <> IOW.world` (proving type-level Record
   inequality formally is a separate, harder question this file does not
   attempt; the two are different by direct inspection of their
   `Record ... := World { ... }` definitions -- Protocol.v's `world`, 6
   fields, vs IOWorld.v's `IOW.world`, 9 fields, REUSE.md's
   "Generalizations relative to the relay contracts"). What matters for
   the adequacy record below is only that `IOW_Espec` is a genuine,
   independently well-typed `OracleKind` (checked: it compiles, and
   `Relay_Espec` (relay/Specs.v) is a separate, pre-existing one this file
   never references), not that the two are formally proved unequal. *)
Theorem iow_espec_ok_ty (ext_link : string -> ident) :
  @OK_ty (IOW_Espec ext_link) = IOW.world.
Proof. reflexivity. Qed.

Definition iow_ext_spec (ext_link : string -> ident) := @OK_spec (IOW_Espec ext_link).

End IOWEspec.

Section IOWDrySpec.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_ext_spec' := (iow_ext_spec errno_id ext_link).

(* ---- the dry external_specification, generalizing relay/adequacy/Dry.v's
   `relay_dry_spec` to both primitives' full WITH-tuples and to the
   errno-carrying pre/post (MemAdequacy.v/DryPost.v). Structurally
   identical to relay's own `Program Definition`/`unshelve econstructor`
   (same `oi_eq_dec` case split, same `mem * {_ : list Type & WITH}`
   witness shape -- confirmed by direct inspection,
   `utility-leaf9-probe-dry-2`, before writing this), only the WITH-tuple
   destructuring pattern and the pre/post predicates differ. ---- *)

Program Definition iow_dry_spec : external_specification mem external_function IOW.world.
Proof.
  unshelve econstructor.
  - intro e.
    pose (ext_spec_type iow_ext_spec' e) as T; simpl in T.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|exact False]];
      match goal with T := (_ * ?A)%type |- _ => exact (mem * A)%type end.
  - simpl; intros e x ge_s tys args z m.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|contradiction]].
    + destruct x as (m0 & _ & w).
      exact ((let '(gv, s, p, n, er, sh) := w in
              args = [Vint (Int.repr (IOW.in_fd s)); p; Vlong (Int64.repr n)]) /\
             m0 = m /\
             (let '(gv, s, p, n, er, sh) := w in read_dry_pre_n n m (s, p, gv errno_id) z)).
    + destruct x as (m0 & _ & w).
      exact ((let '(gv, s, p, bs, er, sh) := w in
              args = [Vint (Int.repr (IOW.out_fd s)); p; Vlong (Int64.repr (Zlength bs))]) /\
             m0 = m /\
             (let '(gv, s, p, bs, er, sh) := w in write_dry_pre_n m (s, p, bs, gv errno_id) z)).
  - simpl; intros e x ge_s ot ret z m.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|contradiction]].
    + destruct x as (m0 & _ & w).
      destruct ret as [v|]; [|exact False].
      destruct v; [exact False | exact False | | exact False | exact False | exact False].
      exact (ot <> Xvoid /\
             (let '(gv, s, p, n, er, sh) := w in read_dry_post_n n m0 m i (s, p, gv errno_id) z)).
    + destruct x as (m0 & _ & w).
      destruct ret as [v|]; [|exact False].
      destruct v; [exact False | exact False | | exact False | exact False | exact False].
      exact (ot <> Xvoid /\
             (let '(gv, s, p, bs, er, sh) := w in write_dry_post_n m0 m i (s, p, bs, gv errno_id) z)).
  - intros; exact True.
Defined.

Definition iow_dessicate : forall ef (jm : juicy_mem),
  ext_spec_type iow_ext_spec' ef -> ext_spec_type iow_dry_spec ef.
Proof.
  simpl; intros.
  destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|assumption]].
  - destruct X as [_ X]; exact (m_dry jm, X).
  - destruct X as [_ X]; exact (m_dry jm, X).
Defined.

(* ---- memory evolution: generalizes relay/adequacy/Dry.v's `dry_spec_mem`
   to the two-step (buffer, then errno) memory effect. Both steps are the
   same "storebytes or unchanged, up to mem_equiv" shape, so this factors
   through one local helper instead of relay's two inlined copies. ---- *)

Lemma storebytes_effect_evolve : forall m0 m1,
  m0 = m1 \/ (exists b ofs bytes m', Mem.storebytes m0 b ofs bytes = Some m' /\ mem_equiv m1 m') ->
  mem_evolve m0 m1.
Proof.
  intros m0 m1 [-> | (b & ofs & bytes & m' & Hst & Heq)].
  - apply mem_evolve_refl.
  - eapply mem_evolve_equiv2; [|apply mem_equiv_sym; eauto].
    eapply mem_evolve_access, storebytes_access; eauto.
Qed.

Lemma dry_spec_mem : ext_spec_mem_evolve _ iow_dry_spec.
Proof.
  intros ??????????? Hpre Hpost.
  simpl in Hpre, Hpost, w.
  if_tac in Hpre.
  - (* read *)
    destruct w as (m0 & _ & w').
    destruct w' as (((((gv & ws) & pp) & n) & er) & sh).
    destruct Hpre as (_ & <- & _).
    destruct v; try contradiction.
    destruct v; try contradiction.
    destruct Hpost as (_ & Hpost).
    unfold read_dry_post_n in Hpost.
    destruct Hpost as (_ & _ & m1 & e' & Hbuf & _ & Herrno).
    apply (mem_evolve_trans m0 m1 m').
    + apply storebytes_effect_evolve.
      destruct pp; try contradiction.
      match type of Hbuf with context[if ?Y then _ else _] => destruct Y eqn:Hc end; simpl in Hbuf.
      * left; exact Hbuf.
      * right. destruct Hbuf as (m'' & Hst & Heq). do 4 eexists. split; eassumption.
    + apply storebytes_effect_evolve.
      unfold errno_dry_post_effect in Herrno.
      match type of Herrno with context[match ?X with _ => _ end] => destruct X eqn:Hx end; try contradiction.
      right. destruct Herrno as (m'' & Hst & Heq). do 4 eexists. split; eassumption.
  - if_tac in Hpre; [|contradiction].
    (* write *)
    destruct w as (m0 & _ & w').
    destruct w' as (((((gv & ws) & pp) & bs) & er) & sh).
    destruct Hpre as (_ & <- & _).
    destruct v; try contradiction.
    destruct v; try contradiction.
    destruct Hpost as (_ & Hpost).
    unfold write_dry_post_n in Hpost.
    destruct Hpost as (_ & _ & e' & _ & Herrno).
    apply storebytes_effect_evolve.
    unfold errno_dry_post_effect in Herrno.
    match type of Herrno with context[match ?X with _ => _ end] => destruct X eqn:Hx end; try contradiction.
    right. destruct Herrno as (m'' & Hst & Heq). do 4 eexists. split; eassumption.
Qed.

(* ---- exit clause: the third conjunct of `juicy_dry_ext_spec`. Checked
   directly (`utility-leaf9-juicydry-21`'s `Show`) that
   `ext_spec_exit iow_ext_spec' v x jm` reduces to `True`: `add_funspecs`
   (VST.veric.semax_ext.v) fixes its built Espec's exit predicate to `True`
   unconditionally, regardless of the base Espec's own one (`IOW_void_Espec`
   here is `ok_void_spec`, whose own bare exit is `False`,
   VST.veric.juicy_extspec.v's `void_spec` -- `add_funspecs` overrides it).
   This is the same reason relay's `relay_dry_spec` uses `True`, restated
   correctly here: it is a property of `add_funspecs` itself, not something
   specific to relay's `Main.Espec`/whole-program construction as this
   file's header previously (incorrectly) reasoned before the `Show` above
   corrected it. `iow_dry_spec`'s own exit component (last bullet of the
   `Program Definition` above) is accordingly `True`, matching. ---- *)

Theorem dry_spec_exit : forall v x jm,
  ext_spec_exit iow_ext_spec' v x jm <-> ext_spec_exit iow_dry_spec v x (m_dry jm).
Proof. intros; unfold ext_spec_exit; simpl; tauto. Qed.

End IOWDrySpec.
