(* Assertion-level PRE transport with the ghost coercion and the errno
   extension made explicit (EmbedBridge.v item "not claimed" narrowed):
   relay's `Specs.read_spec`/`write_spec` PRE body (verbatim text) held by
   phi0, plus the errno cell held by a disjoint phie, gives
   `IOSpecs.read_spec`/`write_spec`'s PRE body (verbatim text, at
   (gv, embed s, p, 32, e, sh)) held by `set_ghost (phi0 ⊕ phie)` with the
   ghost head coerced from `ext_ghost s` (relay oracle PCM) to
   `ext_ghost (embed s)` (IOW oracle PCM). The `ext_compat s` hypothesis on
   the combined rmap is exactly what VST's juicy PRE supplies for any real
   witness (see JuicyPre.v's use of has_ext_compat) and is what rules out
   the frame holding the oracle reference. Resource-only predicates
   (`data_at_ tarray tuchar`, `errno_at`) transfer to the set_ghost'ed
   rmap because set_ghost preserves resource_at and level. *)
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
Require Import VST.veric.res_predicates.
Require Import dry_mem_lemmas.
Require Import relay Protocol Reach.
Require Specs.
Require Import IOWorld IOSpecs.
Require Import Specialize MemAdequacy ErrnoBridge EmbedBridge.
Import ListNotations.
Local Open Scope Z_scope.

(* ---- resource-only predicates survive set_ghost ---- *)

Lemma set_ghost_VALspec_range : forall n sh l phi g H,
  app_pred (VALspec_range n sh l) phi ->
  app_pred (VALspec_range n sh l) (set_ghost phi g H).
Proof.
  intros n sh l phi g H Hv.
  hnf in Hv |- *.
  intro loc; specialize (Hv loc).
  destruct (adr_range_dec l n loc) as [Hin | Hout].
  - rewrite jam_true in Hv |- * by auto.
    hnf in Hv; destruct Hv as (v & Hv).
    hnf in Hv; destruct Hv as (rsh & Hv).
    hnf in Hv.
    exists v. hnf; exists rsh. hnf.
    unfold set_ghost; rewrite resource_at_make_rmap, level_make_rmap. exact Hv.
  - rewrite jam_false in Hv |- * by auto.
    hnf in Hv |- *.
    unfold set_ghost; rewrite resource_at_make_rmap. exact Hv.
Qed.

Local Transparent memory_block.

Lemma set_ghost_data_at__tuchar : forall sh n b o phi g H,
  readable_share sh -> 0 <= n ->
  app_pred (data_at_ sh (tarray tuchar n) (Vptr b o)) phi ->
  app_pred (data_at_ sh (tarray tuchar n) (Vptr b o)) (set_ghost phi g H).
Proof.
  intros sh n b o phi g H Hsh Hn Hdata.
  pose proof (proj1 Hdata) as Hfc.
  assert (Hmod : 0 <= n < Ptrofs.modulus).
  { destruct Hfc as (_ & _ & Hsize & _); simpl in Hsize.
    rewrite Z.max_r in Hsize by lia. pose proof (Ptrofs.unsigned_range o). lia. }
  rewrite <- memory_block_data_at__tarray_tuchar_eq in Hdata |- * by exact Hmod.
  unfold memory_block in Hdata |- *.
  hnf in Hdata; destruct Hdata as [Hbound Hblock]; hnf in Hbound.
  split; [exact Hbound|].
  pose proof (Ptrofs.unsigned_range o) as Hrange.
  change (Ptrofs.unsigned o + n < Ptrofs.modulus) in Hbound.
  assert (Hside1 : 0 <= Ptrofs.unsigned o) by lia.
  assert (Hside2 : Z.of_nat (Z.to_nat n) + Ptrofs.unsigned o < Ptrofs.modulus)
    by (rewrite Z2Nat.id by lia; lia).
  rewrite (mapsto_memory_block.memory_block'_eq sh (Z.to_nat n) b (Ptrofs.unsigned o) Hside1 Hside2) in Hblock |- *.
  unfold mapsto_memory_block.memory_block'_alt in Hblock |- *.
  destruct (readable_share_dec sh); [|contradiction].
  apply set_ghost_VALspec_range; auto.
Qed.

Lemma set_ghost_address_mapsto : forall ch v sh l phi g H,
  app_pred (address_mapsto ch v sh l) phi ->
  app_pred (address_mapsto ch v sh l) (set_ghost phi g H).
Proof.
  intros ch v sh l phi g H Hm.
  destruct Hm as [bl [Hbl Hres]]. exists bl. split; [exact Hbl|].
  intro loc; specialize (Hres loc). simpl in Hres |- *.
  destruct (adr_range_dec l (size_chunk ch) loc) as [Hin | Hout].
  - destruct Hres as [rsh Hres]. exists rsh. hnf in Hres |- *.
    unfold set_ghost; rewrite resource_at_make_rmap; try rewrite level_make_rmap. exact Hres.
  - hnf in Hres |- *. unfold set_ghost; rewrite resource_at_make_rmap. exact Hres.
Qed.

Lemma set_ghost_errno_at : forall b ofs e phi g H,
  field_compatible tint [] (Vptr b ofs) ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e) phi ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e) (set_ghost phi g H).
Proof.
  intros b ofs e phi g H Hfc Herr.
  rewrite errno_at_address_mapsto in Herr |- * by exact Hfc.
  destruct Herr as [Htc Hm]. split; [exact Htc|].
  apply set_ghost_address_mapsto; exact Hm.
Qed.

(* ---- ghost-list algebra used by the split ---- *)

Lemma tl_ghost_join : forall (a b c : ghost), join a b c -> join (tl a) (tl b) (tl c).
Proof.
  intros a b c J. inv J; simpl; try constructor; auto.
Qed.

Lemma none_cons_join : forall (l1 l2 l3 : ghost), join l1 l2 l3 ->
  join (None :: l1) (None :: l2) (None :: l3).
Proof. intros; constructor; [constructor | auto]. Qed.

Lemma some_none_cons_join : forall x (l1 l2 l3 : ghost),
  join l1 l2 l3 -> join (x :: l1) (None :: l2) (x :: l3).
Proof. intros; constructor; [constructor | auto]. Qed.

Section EmbedPre.
Variable errno_id : ident.

(* The relay read PRE body (Specs.read_spec, verbatim) held by phi0 and the
   errno cell held by phie, joined into phi with ext_compat s, give the
   IOSpecs.read_spec PRE body (verbatim, at (gv, embed s, p, 32, e, sh))
   held by phi with its ghost head coerced to the IOW oracle PCM. *)
Theorem read_pre_relay_to_iow : forall (s : RelayProtocol.world) p sh phi0 phie phi gv e (ga : argsEnviron) H,
  join phi0 phie phi ->
  semax.ext_compat s phi ->
  gvars_denote gv (Clight_seplog.mkEnv (fst ga) [] []) ->
  app_pred ((PROP (RelayProtocol.valid_world s; writable_share sh)
             PARAMS (Vint Int.zero; p; Vlong (Int64.repr 32))
             SEP (has_ext s; data_at_ sh (tarray tuchar 32) p)) ga) phi0 ->
  app_pred (IOSpecs.errno_at (gv errno_id) e) phie ->
  app_pred ((PROP (IOW.valid_world (embed s); writable_share sh; 0 <= 32 <= 2146435072;
                   0 <= IOW.in_fd (embed s) <= Int.max_signed)
             PARAMS (Vint (Int.repr (IOW.in_fd (embed s))); p; Vlong (Int64.repr 32))
             GLOBALS (gv)
             SEP (has_ext (embed s); data_at_ sh (tarray tuchar 32) p; IOSpecs.errno_at (gv errno_id) e)) ga)
    (set_ghost phi (Some (ext_ghost (embed s), NoneP) :: tl (ghost_of phi)) H).
Proof.
  intros s p sh phi0 phie phi gv e ga H J Hc Hgv Hpre Herr.
  unfold SEPx in Hpre; simpl in Hpre. rewrite seplog.sepcon_emp in Hpre.
  destruct Hpre as [[Hvalid [Hwritable _]] [Hargs [_ [phig [phib [J1 [Htrace Hbuf]]]]]]].
  hnf in Hargs.
  assert (Hrsh : readable_share sh) by (apply writable_readable_share; exact Hwritable).
  (* regroup: phi = phig ⊕ (phib ⊕ phie) *)
  destruct (join_assoc J1 J) as (phir & Jr & Jg).
  (* ghost heads: phig and phi both start with ext_ghost s *)
  assert (Hsubg : join_sub phig phi) by (eexists; exact Jg).
  destruct (has_ext_compat _ s _ _ Htrace Hsubg Hc) as (_ & Hgg & Hg).
  simpl; split; [| split].
  - (* PROP *)
    simpl. split; [apply Specialize.embed_valid; exact Hvalid|].
    split; [exact Hwritable|]. split; [lia|]. split; [|exact I].
    change (IOW.in_fd (embed s)) with 0. rep_lia.
  - (* PARAMS *)
    hnf. rewrite Hargs. reflexivity.
  - (* GLOBALS + SEP *)
    split.
    { unfold_lift. split; auto. }
    unfold SEPx; simpl. rewrite seplog.sepcon_emp.
    unshelve eexists (set_ghost phig (Some (ext_ghost (embed s), NoneP) :: tl (ghost_of phig)) _),
      (set_ghost phir (None :: tl (ghost_of phir)) _).
    { rewrite <- ghost_of_approx at 2; simpl; destruct (ghost_of phig); auto. }
    { rewrite <- ghost_of_approx at 2; simpl; destruct (ghost_of phir); auto. }
    destruct (join_level _ _ _ Jg) as [Hlg Hlr].
    split.
    { apply resource_at_join2; unfold set_ghost; rewrite ?level_make_rmap; auto.
      - intro loc; rewrite !resource_at_make_rmap. apply resource_at_join; exact Jg.
      - rewrite !ghost_of_make_rmap.
        apply some_none_cons_join. apply tl_ghost_join. apply ghost_of_join; exact Jg. }
    split.
    { apply has_ext_relay_to_iow; exact Htrace. }
    (* buffer * errno on the None-headed part *)
    pose proof (proj1 Hbuf) as Hfcb. pose proof (field_compatible_isptr _ _ _ Hfcb) as Hpb.
    pose proof (proj1 Herr) as Hfce. pose proof (field_compatible_isptr _ _ _ Hfce) as Hpe.
    destruct p as [| | | | | pb pofs]; try contradiction.
    destruct (gv errno_id) as [| | | | | eb eofs] eqn:Hgve; try contradiction.
    unshelve eexists (set_ghost phib (None :: tl (ghost_of phib)) _),
      (set_ghost phie (None :: tl (ghost_of phie)) _).
    { rewrite <- ghost_of_approx at 2; simpl; destruct (ghost_of phib); auto. }
    { rewrite <- ghost_of_approx at 2; simpl; destruct (ghost_of phie); auto. }
    destruct (join_level _ _ _ Jr) as [Hlb Hle].
    split.
    { apply resource_at_join2; unfold set_ghost; rewrite ?level_make_rmap; auto.
      - intro loc; rewrite !resource_at_make_rmap. apply resource_at_join; exact Jr.
      - rewrite !ghost_of_make_rmap.
        apply none_cons_join. apply tl_ghost_join. apply ghost_of_join; exact Jr. }
    split.
    { apply set_ghost_data_at__tuchar; [exact Hrsh | lia | exact Hbuf]. }
    { apply set_ghost_errno_at; [exact Hfce | exact Herr]. }
  all: match goal with |- ?G => idtac "EMBEDPRE leftover:" G end.
Qed.

End EmbedPre.
