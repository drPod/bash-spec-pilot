(* Write twin of EmbedPre.read_pre_relay_to_iow, and the ghost-head
   normalization `nh` it needs. The write PRE carries the value-carrying
   `byte_array sh p bs = data_at sh (tarray tuchar (Zlength bs)) (map Vubyte
   bs) p`, which unfolds (data_at_rec_eq) to a `rangespec` fold of
   per-byte `mapsto`s ending in `emp`. `nh` replaces the ghost head by
   None only when the ghost is non-nil (nil stays nil, so it is also safe
   should emp ever constrain the ghost; in VST 2.15 emp = ALL l, noat l,
   res_predicates.emp_no); it is compatible with join, emp, sepcon and
   every resource-only predicate, which is exactly what the fold needs. All statements are about the
   verbatim Specs.write_spec / IOSpecs.write_spec PRE bodies. *)
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
Require Import Specialize MemAdequacy ErrnoBridge EmbedBridge EmbedPre.
Import ListNotations.
Local Open Scope Z_scope.

(* ---- nh: drop the ghost head to None, nil stays nil ---- *)

Definition nh_ghost (g : ghost) : ghost :=
  match g with nil => nil | _ :: t => None :: t end.

Lemma nh_ghost_valid : forall phi,
  ghost_fmap (approx (level phi)) (approx (level phi)) (nh_ghost (ghost_of phi)) = nh_ghost (ghost_of phi).
Proof.
  intro phi. rewrite <- ghost_of_approx at 2. destruct (ghost_of phi); auto.
Qed.

Definition nh (phi : rmap) : rmap := set_ghost phi (nh_ghost (ghost_of phi)) (nh_ghost_valid phi).

Lemma nh_resource_at : forall phi, resource_at (nh phi) = resource_at phi.
Proof. intro; unfold nh, set_ghost; extensionality l; rewrite resource_at_make_rmap; auto. Qed.

Lemma nh_level : forall phi, level (nh phi) = level phi.
Proof. intro; unfold nh, set_ghost; rewrite level_make_rmap; auto. Qed.

Lemma nh_ghost_of : forall phi, ghost_of (nh phi) = nh_ghost (ghost_of phi).
Proof. intro; unfold nh, set_ghost; rewrite ghost_of_make_rmap; auto. Qed.

Lemma nh_ghost_join : forall (a b c : ghost), join a b c -> join (nh_ghost a) (nh_ghost b) (nh_ghost c).
Proof.
  intros a b c J. inv J; simpl; try constructor; auto. constructor.
Qed.

Lemma nh_join : forall a b c, join a b c -> join (nh a) (nh b) (nh c).
Proof.
  intros a b c J.
  destruct (join_level _ _ _ J).
  apply resource_at_join2; rewrite ?nh_level; auto.
  - intro l; rewrite !nh_resource_at; apply resource_at_join; auto.
  - rewrite !nh_ghost_of; apply nh_ghost_join; apply ghost_of_join; auto.
Qed.

Lemma nh_emp : forall phi, app_pred predicates_sl.emp phi -> app_pred predicates_sl.emp (nh phi).
Proof.
  (* VST 2.15: emp = ALL l, noat l (res_predicates.emp_no), resources only *)
  intros phi H. rewrite emp_no in H |- *.
  hnf in H |- *. intro l. specialize (H l). hnf in H |- *.
  unfold nh, set_ghost; rewrite resource_at_make_rmap. exact H.
Qed.

Lemma nh_sepcon : forall (P Q : mpred) phi,
  (forall a, app_pred P a -> app_pred P (nh a)) ->
  (forall b, app_pred Q b -> app_pred Q (nh b)) ->
  app_pred (P * Q)%logic phi -> app_pred (P * Q)%logic (nh phi).
Proof.
  intros P Q phi HP HQ (a & b & J & Ha & Hb).
  exists (nh a), (nh b). split; [apply nh_join; auto|]. auto.
Qed.

Lemma nh_address_mapsto : forall ch v sh l phi,
  app_pred (address_mapsto ch v sh l) phi -> app_pred (address_mapsto ch v sh l) (nh phi).
Proof. intros; apply set_ghost_address_mapsto; auto. Qed.

Lemma nh_errno_at : forall b ofs e phi,
  field_compatible tint [] (Vptr b ofs) ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e) phi ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e) (nh phi).
Proof. intros; apply set_ghost_errno_at; auto. Qed.

Lemma nh_rangespec : forall (P : Z -> val -> mpred) p lo n phi,
  (forall i a, app_pred (P i p) a -> app_pred (P i p) (nh a)) ->
  app_pred (aggregate_pred.rangespec lo n P p) phi -> app_pred (aggregate_pred.rangespec lo n P p) (nh phi).
Proof.
  intros P p lo n. revert lo. induction n; intros lo phi HP H; simpl in H |- *.
  - apply nh_emp; auto.
  - apply nh_sepcon; auto.
  all: match goal with |- ?G => idtac "NH_RANGESPEC leftover:" G end.
Qed.

(* value-carrying byte array across nh: per byte, mapsto for a readable
   share is a disjunction of two address_mapsto forms *)
Lemma nh_byte_array : forall sh z (bytes : list val) b i phi,
  readable_share sh ->
  app_pred (data_at sh (tarray tuchar z) bytes (Vptr b i)) phi ->
  app_pred (data_at sh (tarray tuchar z) bytes (Vptr b i)) (nh phi).
Proof.
  intros sh z bytes b i phi Hsh Hbuf.
  destruct Hbuf as [Hfc Hbuf]. split; [exact Hfc|].
  unfold at_offset in Hbuf |- *. simpl in Hbuf |- *.
  rewrite data_at_rec_eq in Hbuf |- *. simpl in Hbuf |- *.
  unfold unfold_reptype in *; simpl in *.
  destruct Hbuf as [Hlen Hbuf]. split; [exact Hlen|].
  apply nh_rangespec; [|exact Hbuf].
  intros j a Ha.
  unfold at_offset in Ha |- *; simpl in Ha |- *.
  rewrite data_at_rec_eq in Ha |- *; simpl in Ha |- *.
  unfold unfold_reptype, mapsto in Ha |- *; simpl in Ha |- *.
  rewrite if_true in Ha |- * by auto.
  destruct Ha as [[Htc Hm] | [Hu [v' Hm]]].
  - left. split; [exact Htc | apply nh_address_mapsto; exact Hm].
  - right. split; [exact Hu | exists v'; apply nh_address_mapsto; exact Hm].
  all: match goal with |- ?G => idtac "NH_BYTE_ARRAY leftover:" G end.
Qed.

(* ---- head algebra for the has_ext part against an nh-normalized rest ---- *)

Lemma head_swap_nh_join : forall h h' (l1 : ghost) g2 (l3 : ghost),
  join (h :: l1) g2 (h :: l3) -> join (h' :: l1) (nh_ghost g2) (h' :: l3).
Proof.
  intros h h' l1 g2 l3 J. inv J; simpl.
  - constructor.
  - constructor; [constructor | auto].
Qed.

Section EmbedPre2.
Variable errno_id : ident.

(* The relay write PRE body (Specs.write_spec, verbatim) held by phi0 and
   the errno cell held by phie, joined into phi with ext_compat s, give the
   IOSpecs.write_spec PRE body (verbatim, at (gv, embed s, p, bs, e, sh))
   held by phi with its ghost head coerced to the IOW oracle PCM. *)
Theorem write_pre_relay_to_iow : forall (s : RelayProtocol.world) p sh (bs : list byte) phi0 phie phi gv e (ga : argsEnviron) H,
  join phi0 phie phi ->
  semax.ext_compat s phi ->
  gvars_denote gv (Clight_seplog.mkEnv (fst ga) [] []) ->
  app_pred ((PROP (RelayProtocol.valid_world s; readable_share sh; 0 < Zlength bs <= 32)
             PARAMS (Vint Int.one; p; Vlong (Int64.repr (Zlength bs)))
             SEP (has_ext s; Specs.byte_array sh p bs)) ga) phi0 ->
  app_pred (IOSpecs.errno_at (gv errno_id) e) phie ->
  app_pred ((PROP (IOW.valid_world (embed s); readable_share sh; 0 <= Zlength bs <= 2146435072;
                   0 <= IOW.out_fd (embed s) <= Int.max_signed)
             PARAMS (Vint (Int.repr (IOW.out_fd (embed s))); p; Vlong (Int64.repr (Zlength bs)))
             GLOBALS (gv)
             SEP (has_ext (embed s); Specs.byte_array sh p bs; IOSpecs.errno_at (gv errno_id) e)) ga)
    (set_ghost phi (Some (ext_ghost (embed s), NoneP) :: tl (ghost_of phi)) H).
Proof.
  intros s p sh bs phi0 phie phi gv e ga H J Hc Hgv Hpre Herr.
  unfold SEPx in Hpre; simpl in Hpre. rewrite seplog.sepcon_emp in Hpre.
  destruct Hpre as [[Hvalid [Hreadable [Hlen _]]] [Hargs [_ [phig [phib [J1 [Htrace Hbuf]]]]]]].
  hnf in Hargs.
  destruct (join_assoc J1 J) as (phir & Jr & Jg).
  assert (Hsubg : join_sub phig phi) by (eexists; exact Jg).
  destruct (has_ext_compat _ s _ _ Htrace Hsubg Hc) as (_ & Hgg & Hg).
  simpl; split; [| split].
  - (* PROP *)
    simpl. split; [apply Specialize.embed_valid; exact Hvalid|].
    split; [exact Hreadable|]. split; [lia|]. split; [|exact I].
    change (IOW.out_fd (embed s)) with 1. rep_lia.
  - (* PARAMS *)
    hnf. rewrite Hargs. reflexivity.
  - (* GLOBALS + SEP *)
    split.
    { unfold_lift. split; auto. }
    unfold SEPx; simpl. rewrite seplog.sepcon_emp.
    unshelve eexists (set_ghost phig (Some (ext_ghost (embed s), NoneP) :: tl (ghost_of phig)) _), (nh phir).
    { rewrite <- ghost_of_approx at 2; simpl; destruct (ghost_of phig); auto. }
    destruct (join_level _ _ _ Jg) as [Hlg Hlr].
    split.
    { apply resource_at_join2; unfold nh, set_ghost; rewrite ?level_make_rmap; auto.
      - intro loc; rewrite !resource_at_make_rmap. apply resource_at_join; exact Jg.
      - rewrite !ghost_of_make_rmap.
        pose proof (ghost_of_join _ _ _ Jg) as Jgh.
        rewrite Hgg, Hg in Jgh.
        exact (head_swap_nh_join _ _ _ _ _ Jgh). }
    split.
    { apply has_ext_relay_to_iow; exact Htrace. }
    pose proof (proj1 Hbuf) as Hfcb. pose proof (field_compatible_isptr _ _ _ Hfcb) as Hpb.
    pose proof (proj1 Herr) as Hfce. pose proof (field_compatible_isptr _ _ _ Hfce) as Hpe.
    destruct p as [| | | | | pb pofs]; try contradiction.
    destruct (gv errno_id) as [| | | | | eb eofs] eqn:Hgve; try contradiction.
    apply nh_sepcon.
    { intros a Ha. unfold Specs.byte_array in Ha |- *. apply nh_byte_array; auto. }
    { intros a Ha. apply nh_errno_at; [exact (proj1 Ha) | exact Ha]. }
    exists phib, phie. split; [exact Jr|]. split; [exact Hbuf | exact Herr].
  all: match goal with |- ?G => idtac "WRITEPRE leftover:" G end.
Qed.

End EmbedPre2.
