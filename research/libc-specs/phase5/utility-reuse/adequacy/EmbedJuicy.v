(* Juicy-level PRE witness transport from Relay_Espec to IOW_Espec, with
   every extra made explicit and constructed (nothing assumed valid):

   - `mem_cell_ext m m' eb e`: the dry memory relationship. m' extends m by
     one 4-byte errno cell in a block eb that is FRESH for m (eb >= nextblock
     m, so m's juicy view is NO there by alloc_cohere): contents/access
     agree with m outside the cell; inside, Cur permission is exactly
     Writable (perm_of_sh Ews), Max is at least Writable, and the bytes are
     errno_memval e. (An alloc + store + drop_perm on m yields such an m';
     this file states the relationship rather than one particular
     construction of it.)
   - `errno_rmap phi m' eb`: an EXPLICIT rmap (make_rmap) holding exactly
     the cell as YES Ews VAL resources and the unit of phi elsewhere; it
     satisfies the verbatim IOSpecs.errno_at (Vptr eb Ptrofs.zero) e and
     joins with any phi that is NO-bot on the cell.
   - `ext_rmap phi m' eb` = phi ⊕ errno_rmap (make_rmap, join proved).
   - `jmJ jm m' eb w'`: the transported juicy memory: dry part m', rmap
     `set_ghost (ext_rmap (m_phi jm) m' eb)` with the oracle ghost head
     coerced to `ext_ghost w' : ext_PCM IOW.world`; all four cohesion
     predicates PROVED from mem_cell_ext and jm's own cohesion
     (SequentialClight.set_ghost_cohere for the ghost part).
   - `read_juicy_pre_relay_to_iow`: on the actual records. A relay juicy
     PRE witness for jm (ext_spec_pre of OK_spec (Relay_Espec ext_link))
     yields an IOW juicy PRE witness for jmJ (ext_spec_pre of
     OK_spec (IOW_Espec errno_id ext_link)) at the transported WITH-tuple
     (gv, embed s, p, 32, e, sh) and oracle embed z, where gv is the
     globals function of the call's own symbol table b and errno_id maps
     to the fresh block eb. The frame is nh phi1' (ghost head dropped);
     the precondition part is EmbedPre.read_pre_relay_to_iow. *)
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
Require Import Specialize MemAdequacy ErrnoBridge ErrnoLoad PostLemmas2 PostLemmas3 JuicyDry EmbedBridge EmbedPre EmbedPre2.
Import ListNotations.
Import Maps.
Local Open Scope Z_scope.

(* ---- the dry memory relationship ---- *)

Record mem_cell_ext (m m' : mem) (eb : block) (e : Z) : Prop := {
  mce_fresh : (eb >= Mem.nextblock m)%positive;
  mce_next : (Mem.nextblock m <= Mem.nextblock m')%positive;
  mce_in : (eb < Mem.nextblock m')%positive;
  mce_contents : forall loc, ~ adr_range (eb, 0) 4 loc -> contents_at m' loc = contents_at m loc;
  mce_access : forall loc, ~ adr_range (eb, 0) 4 loc -> access_at m' loc = access_at m loc;
  mce_cur : forall loc, adr_range (eb, 0) 4 loc -> access_at m' loc Cur = Some Writable;
  mce_max : forall loc, adr_range (eb, 0) 4 loc -> Mem.perm_order'' (max_access_at m' loc) (Some Writable);
  mce_load : Mem.loadbytes m' eb 0 4 = Some (errno_memval e)
}.

(* ---- getN to per-address contents (converse of ErrnoLoad.getN_contents) ---- *)

Lemma getN_nth : forall n p c (bl : list memval),
  Mem.getN n p c = bl -> forall k, (k < n)%nat -> ZMap.get (p + Z.of_nat k) c = nth k bl Undef.
Proof.
  induction n; intros p c bl H k Hk; [lia|].
  simpl in H. subst bl. destruct k.
  - simpl. rewrite Z.add_0_r. reflexivity.
  - simpl. rewrite <- (IHn (p + 1) c _ eq_refl k) by lia. f_equal. lia.
Qed.

Lemma loadbytes_contents_at : forall m b ofs (bl : list memval),
  Mem.loadbytes m b ofs (Z.of_nat (length bl)) = Some bl ->
  forall k, (k < length bl)%nat -> contents_at m (b, ofs + Z.of_nat k) = nth k bl Undef.
Proof.
  intros m b ofs bl H k Hk.
  Transparent Mem.loadbytes. unfold Mem.loadbytes in H. Opaque Mem.loadbytes.
  destruct (Mem.range_perm_dec m b ofs (ofs + Z.of_nat (length bl)) Cur Readable); [|discriminate].
  injection H as H. unfold contents_at; simpl.
  rewrite Nat2Z.id in H. eapply getN_nth; eauto.
Qed.

(* ---- the explicit errno rmap ---- *)

Definition cell_res (phi : rmap) (m' : mem) (eb : block) (loc : address) : resource :=
  if adr_range_dec (eb, 0) 4 loc
  then YES Ews (writable_readable_share writable_Ews) (VAL (contents_at m' loc)) NoneP
  else match phi @ loc with PURE k pp => PURE k pp | _ => NO Share.bot bot_unreadable end.

Lemma cell_res_approx : forall phi m' eb,
  resource_fmap (approx (level phi)) (approx (level phi)) oo cell_res phi m' eb = cell_res phi m' eb.
Proof.
  intros; extensionality loc; simpl; unfold cell_res.
  destruct (adr_range_dec (eb, 0) 4 loc); simpl; try (rewrite preds_fmap_NoneP; reflexivity); try reflexivity.
  all: pose proof (resource_at_approx phi loc) as Ha; destruct (phi @ loc) eqn:Hl; simpl in *; auto.
  all: try exact Ha.
Qed.

Definition errno_rmap (phi : rmap) (m' : mem) (eb : block) : rmap :=
  proj1_sig (make_rmap (cell_res phi m' eb) nil (level phi) (cell_res_approx phi m' eb) eq_refl).

Lemma errno_rmap_level : forall phi m' eb, level (errno_rmap phi m' eb) = level phi.
Proof. intros; unfold errno_rmap; destruct (make_rmap _ _ _ _ _) as (? & ? & ? & ?); simpl; auto. Qed.
Lemma errno_rmap_at : forall phi m' eb, resource_at (errno_rmap phi m' eb) = cell_res phi m' eb.
Proof. intros; unfold errno_rmap; destruct (make_rmap _ _ _ _ _) as (? & ? & ? & ?); simpl; auto. Qed.
Lemma errno_rmap_ghost : forall phi m' eb, ghost_of (errno_rmap phi m' eb) = nil.
Proof. intros; unfold errno_rmap; destruct (make_rmap _ _ _ _ _) as (? & ? & ? & ?); simpl; auto. Qed.

Lemma fc_tint_zero : forall eb, field_compatible tint [] (Vptr eb Ptrofs.zero).
Proof.
  intro eb. unfold field_compatible.
  split; [exact I|]. split; [reflexivity|].
  split. { red. rewrite Ptrofs.unsigned_zero. simpl. rep_lia. }
  split. { red. rewrite Ptrofs.unsigned_zero.
           eapply align_compatible_rec_by_value; [reflexivity|]. simpl. apply Z.divide_0_r. }
  exact I.
Qed.

Lemma errno_rmap_errno_at : forall phi m m' eb e,
  mem_cell_ext m m' eb e ->
  app_pred (IOSpecs.errno_at (Vptr eb Ptrofs.zero) e) (errno_rmap phi m' eb).
Proof.
  intros phi m m' eb e Hc.
  rewrite errno_at_address_mapsto by apply fc_tint_zero.
  split; [simpl; auto|].
  exists (errno_memval e).
  split.
  { split; [unfold errno_memval; rewrite encode_val_length; reflexivity|].
    split; [apply decode_errno_memval|].
    rewrite Ptrofs.unsigned_zero. apply Z.divide_0_r. }
  intro loc. simpl. change (Ptrofs.unsigned Ptrofs.zero) with 0.
  destruct (adr_range_dec (eb, 0) 4 loc) as [Hin | Hout].
  - exists (writable_readable_share writable_Ews). hnf.
    rewrite errno_rmap_at. unfold cell_res. rewrite if_true by exact Hin.
    try rewrite preds_fmap_NoneP.
    destruct loc as (lb, lo). destruct Hin as [Hb Ho]; simpl in Hb; subst lb.
    pose proof (mce_load _ _ _ _ Hc) as Hload.
    assert (H4 : Z.of_nat (length (errno_memval e)) = 4) by (rewrite <- Zlength_correct; apply errno_memval_Zlength).
    rewrite <- H4 in Hload.
    assert (Hcont : forall o, 0 <= o < 4 -> contents_at m' (eb, o) = nth (Z.to_nat o) (errno_memval e) Undef).
    { intros o Ho'. rewrite <- (loadbytes_contents_at _ _ _ _ Hload (Z.to_nat o)) by lia.
      f_equal. f_equal. rewrite Z2Nat.id by lia. lia. }
    simpl. rewrite Z.sub_0_r. f_equal. f_equal. apply Hcont. simpl in Ho. lia.
  - hnf. rewrite errno_rmap_at. unfold cell_res. rewrite if_false by exact Hout.
    destruct (phi @ loc); [apply NO_identity | apply NO_identity | apply PURE_identity].
  all: match goal with |- ?G => idtac "ERRNO_RMAP leftover:" G end.
Qed.

(* ---- the extended rmap: phi plus the cell ---- *)

Definition ext_res (phi : rmap) (m' : mem) (eb : block) (loc : address) : resource :=
  if adr_range_dec (eb, 0) 4 loc then cell_res phi m' eb loc else phi @ loc.

Lemma ext_res_approx : forall phi m' eb,
  resource_fmap (approx (level phi)) (approx (level phi)) oo ext_res phi m' eb = ext_res phi m' eb.
Proof.
  intros; extensionality loc; simpl; unfold ext_res.
  destruct (adr_range_dec (eb, 0) 4 loc).
  - pose proof (cell_res_approx phi m' eb) as Ha.
    apply (f_equal (fun f => f loc)) in Ha. exact Ha.
  - apply resource_at_approx.
Qed.

Definition ext_rmap (phi : rmap) (m' : mem) (eb : block) : rmap :=
  proj1_sig (make_rmap (ext_res phi m' eb) (ghost_of phi) (level phi) (ext_res_approx phi m' eb) (ghost_of_approx phi)).

Lemma ext_rmap_level : forall phi m' eb, level (ext_rmap phi m' eb) = level phi.
Proof. intros; unfold ext_rmap; destruct (make_rmap _ _ _ _ _) as (? & ? & ? & ?); simpl; auto. Qed.
Lemma ext_rmap_at : forall phi m' eb, resource_at (ext_rmap phi m' eb) = ext_res phi m' eb.
Proof. intros; unfold ext_rmap; destruct (make_rmap _ _ _ _ _) as (? & ? & ? & ?); simpl; auto. Qed.
Lemma ext_rmap_ghost : forall phi m' eb, ghost_of (ext_rmap phi m' eb) = ghost_of phi.
Proof. intros; unfold ext_rmap; destruct (make_rmap _ _ _ _ _) as (? & ? & ? & ?); simpl; auto. Qed.

Definition no_cell (phi : rmap) (eb : block) : Prop :=
  forall loc, adr_range (eb, 0) 4 loc -> phi @ loc = NO Share.bot bot_unreadable.

Lemma ext_rmap_join : forall phi m' eb,
  no_cell phi eb -> join phi (errno_rmap phi m' eb) (ext_rmap phi m' eb).
Proof.
  intros phi m' eb Hno.
  apply resource_at_join2; rewrite ?errno_rmap_level, ?ext_rmap_level; auto.
  - intro loc. rewrite errno_rmap_at, ext_rmap_at. unfold ext_res, cell_res.
    destruct (adr_range_dec (eb, 0) 4 loc) as [Hin | Hout].
    + rewrite (Hno _ Hin). constructor. apply bot_join_eq.
    + destruct (phi @ loc); constructor; apply join_bot_eq.
  - rewrite errno_rmap_ghost, ext_rmap_ghost. constructor.
Qed.

(* ---- the coerced ghost and the transported juicy memory ---- *)

Lemma coerced_valid : forall (phi : rmap) (w' : IOW.world),
  ghost_fmap (approx (level phi)) (approx (level phi)) (Some (ext_ghost w', NoneP) :: tl (ghost_of phi))
  = Some (ext_ghost w', NoneP) :: tl (ghost_of phi).
Proof.
  intros. rewrite <- ghost_of_approx at 2. simpl. destruct (ghost_of phi); auto.
Qed.

Definition phiJ (phi : rmap) (m' : mem) (eb : block) (w' : IOW.world) : rmap :=
  set_ghost (ext_rmap phi m' eb) (Some (ext_ghost w', NoneP) :: tl (ghost_of (ext_rmap phi m' eb)))
    (coerced_valid (ext_rmap phi m' eb) w').

Lemma phiJ_cohere : forall jm m' eb e w',
  mem_cell_ext (m_dry jm) m' eb e ->
  mem_rmap_cohere m' (phiJ (m_phi jm) m' eb w').
Proof.
  intros jm m' eb e w' Hc.
  unfold phiJ. apply set_ghost_cohere.
  split; [|split; [|split]].
  - (* contents *)
    intros rsh sh v loc pp H. rewrite ext_rmap_at in H. unfold ext_res, cell_res in H.
    destruct (adr_range_dec (eb, 0) 4 loc) as [Hin | Hout].
    + inv H. auto.
    + rewrite (mce_contents _ _ _ _ Hc _ Hout). exact (juicy_mem_contents jm _ _ _ _ _ H).
  - (* access *)
    intro loc. rewrite ext_rmap_at. unfold ext_res, cell_res.
    destruct (adr_range_dec (eb, 0) 4 loc) as [Hin | Hout].
    + rewrite (mce_cur _ _ _ _ Hc _ Hin). simpl. rewrite perm_of_Ews. reflexivity.
    + rewrite (mce_access _ _ _ _ Hc _ Hout). apply juicy_mem_access.
  - (* max access *)
    intro loc. rewrite ext_rmap_at. unfold ext_res, cell_res.
    destruct (adr_range_dec (eb, 0) 4 loc) as [Hin | Hout].
    + simpl. rewrite perm_of_Ews. apply (mce_max _ _ _ _ Hc _ Hin).
    + unfold max_access_at. rewrite (mce_access _ _ _ _ Hc _ Hout). apply juicy_mem_max_access.
  - (* alloc *)
    intros loc Hge. rewrite ext_rmap_at. unfold ext_res.
    destruct (adr_range_dec (eb, 0) 4 loc) as [Hin | Hout].
    + exfalso. destruct loc as (lb, lo). destruct Hin as [Hb _]. simpl in *. subst lb.
      pose proof (mce_in _ _ _ _ Hc). lia.
    + apply juicy_mem_alloc_cohere. pose proof (mce_next _ _ _ _ Hc). lia.
  all: match goal with |- ?G => idtac "PHIJ_COHERE leftover:" G end.
Qed.

Definition jmJ (jm : juicy_mem) (m' : mem) (eb : block) (e : Z) (w' : IOW.world)
  (Hc : mem_cell_ext (m_dry jm) m' eb e) : juicy_mem :=
  mkJuicyMem m' (phiJ (m_phi jm) m' eb w')
    (proj1 (phiJ_cohere jm m' eb e w' Hc))
    (proj1 (proj2 (phiJ_cohere jm m' eb e w' Hc)))
    (proj1 (proj2 (proj2 (phiJ_cohere jm m' eb e w' Hc))))
    (proj2 (proj2 (proj2 (phiJ_cohere jm m' eb e w' Hc)))).

Lemma jmJ_dry : forall jm m' eb e w' Hc, m_dry (jmJ jm m' eb e w' Hc) = m'.
Proof. reflexivity. Qed.
Lemma jmJ_phi : forall jm m' eb e w' Hc, m_phi (jmJ jm m' eb e w' Hc) = phiJ (m_phi jm) m' eb w'.
Proof. reflexivity. Qed.

(* ---- share facts for the frame on the cell ---- *)

Lemma join_NO_bot_left : forall r1 r2,
  join r1 r2 (NO Share.bot bot_unreadable) -> r1 = NO Share.bot bot_unreadable /\ r2 = NO Share.bot bot_unreadable.
Proof.
  intros r1 r2 J. inv J.
  match goal with RJ : join ?a ?b Share.bot |- _ =>
    assert (Ha : a = Share.bot) by (eapply identity_share_bot, split_identity; [exact RJ | apply bot_identity]);
    assert (Hb : b = Share.bot) by (eapply identity_share_bot, split_identity; [apply join_comm; exact RJ | apply bot_identity]);
    subst end.
  split; f_equal; apply proof_irr.
Qed.

Lemma ext_ref_join_opt : forall {Z} (z : Z),
  join (Some (ext_ghost z, NoneP)) (Some (ext_ref z, NoneP)) (Some (ext_both z, NoneP)).
Proof.
  intros. constructor. split; [apply ext_ref_join | split; reflexivity].
Qed.

Section EmbedJuicy.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_ext_spec' := (iow_ext_spec errno_id ext_link).
Notation relay_ext_spec' := (relay_ext_spec_local ext_link).

Definition genv_globals (b : injective_PTree block) : globals :=
  fun i => match Map.get (filter_genv (symb2genv b)) i with Some bl => Vptr bl Ptrofs.zero | None => Vundef end.

(* witness transport: relay (phi1, ts, (s,p,sh)) to IOW (phi1n, ts, (gv, embed s, p, 32, e, sh)) *)
Definition embed_juicy_witness (gv : globals) (e : Z) (phi1n : rmap) : forall ef,
  ext_spec_type relay_ext_spec' ef -> ext_spec_type iow_ext_spec' ef.
Proof.
  simpl; intros ef X.
  destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|exact X]].
  - destruct X as (_ & X). destruct X as [ts w]. destruct w as ((s & p) & sh).
    exact (phi1n, existT _ ts (gv, embed s, p, 32, e, sh)).
  - destruct X as (_ & X). destruct X as [ts w]. destruct w as (((s & p) & bs) & sh).
    exact (phi1n, existT _ ts (gv, embed s, p, bs, e, sh)).
Defined.

Theorem read_juicy_pre_relay_to_iow : forall ef t b tl vl z jm m' eb e
  (Hc : mem_cell_ext (m_dry jm) m' eb e)
  (Hb : Map.get (filter_genv (symb2genv b)) errno_id = Some eb),
  ef_id_sig ext_link ef = Some (ext_link "read"%string, typesig2signature ([tint; tptr tvoid; tulong], tlong) cc_default) ->
  ext_spec_pre relay_ext_spec' ef t b tl vl z jm ->
  exists phi1n,
    ext_spec_pre iow_ext_spec' ef (embed_juicy_witness (genv_globals b) e phi1n ef t) b tl vl (embed z)
      (jmJ jm m' eb e (embed z) Hc).
Proof.
  intros ef. simpl. unfold funspec2pre, embed_juicy_witness. simpl.
  if_tac; [| intros; congruence].
  intros t b tl vl z jm m' eb e Hc Hb Hef Hpre.
  destruct t as (phi1 & ts & w). destruct w as ((s & p) & sh). simpl in *.
  destruct Hpre as (Hty & phi0 & phi1' & J & Hpre & Hnec & Hext).
  assert (Hsub0 : join_sub phi0 (m_phi jm)) by (eexists; exact J).
  (* has_ext s inside phi0: s = z and the ghost heads *)
  assert (Htr : exists phig, join_sub phig phi0 /\ app_pred (has_ext s) phig).
  { pose proof Hpre as Hp. unfold SEPx in Hp; simpl in Hp. rewrite seplog.sepcon_emp in Hp.
    destruct Hp as [_ [_ [_ [phig [phib [J1 [Htrace _]]]]]]]. exists phig. split; [eexists; exact J1 | exact Htrace]. }
  destruct Htr as (phig & Hsubg & Htrace).
  destruct (has_ext_compat _ z _ _ Htrace (join_sub_trans Hsubg Hsub0) Hext) as (Hsz & _ & Hg). subst z.
  assert (Hext0 : semax.ext_compat s phi0) by (eapply ext_compat_sub; eauto).
  destruct (has_ext_compat _ s _ _ Htrace Hsubg Hext0) as (_ & _ & Hg0).
  (* the fresh cell is NO-bot in jm, hence in phi0 and in the frame *)
  assert (Hno : forall loc, adr_range (eb, 0) 4 loc -> m_phi jm @ loc = NO Share.bot bot_unreadable).
  { intros loc Hin. apply juicy_mem_alloc_cohere. destruct loc as (lb, lo); destruct Hin as [-> _]; simpl.
    exact (mce_fresh _ _ _ _ Hc). }
  assert (Hno0 : no_cell phi0 eb).
  { intros loc Hin. pose proof (resource_at_join _ _ _ loc J) as Jl. rewrite (Hno _ Hin) in Jl.
    exact (proj1 (join_NO_bot_left _ _ Jl)). }
  assert (Hno1 : forall loc, adr_range (eb, 0) 4 loc -> phi1' @ loc = NO Share.bot bot_unreadable).
  { intros loc Hin. pose proof (resource_at_join _ _ _ loc J) as Jl. rewrite (Hno _ Hin) in Jl.
    exact (proj2 (join_NO_bot_left _ _ Jl)). }
  destruct (join_level _ _ _ J) as [Hl0 Hl1].
  set (gv := genv_globals b).
  assert (Hgv : gv errno_id = Vptr eb Ptrofs.zero) by (unfold gv, genv_globals; rewrite Hb; reflexivity).
  exists (nh phi1').
  split; [exact Hty|].
  exists (set_ghost (ext_rmap phi0 m' eb) (Some (ext_ghost (embed s), NoneP) :: List.tl (ghost_of (ext_rmap phi0 m' eb))) (coerced_valid _ _)), (nh phi1').
  split; [|split; [|split]].
  - (* join into m_phi jmJ *)
    try rewrite jmJ_phi. unfold phiJ.
    apply resource_at_join2.
    + unfold set_ghost; rewrite !level_make_rmap, !ext_rmap_level; exact Hl0.
    + rewrite nh_level. unfold set_ghost; rewrite level_make_rmap, ext_rmap_level; exact Hl1.
    + intro loc. rewrite nh_resource_at. unfold set_ghost; rewrite !resource_at_make_rmap, !ext_rmap_at. unfold ext_res.
      destruct (adr_range_dec (eb, 0) 4 loc) as [Hin | Hout].
      * unfold cell_res. rewrite !if_true by exact Hin. rewrite (Hno1 _ Hin). constructor. apply join_bot_eq.
      * apply resource_at_join; exact J.
    + rewrite nh_ghost_of. unfold set_ghost; rewrite !ghost_of_make_rmap, !ext_rmap_ghost.
      pose proof (ghost_of_join _ _ _ J) as Jg. rewrite Hg0, Hg in Jg.
      exact (head_swap_nh_join _ _ _ _ _ Jg).
  - (* the IOW precondition on the coerced part: EmbedPre.read_pre_relay_to_iow *)
    pose proof (read_pre_relay_to_iow errno_id s p sh phi0 (errno_rmap phi0 m' eb) (ext_rmap phi0 m' eb) gv e
                  (filter_genv (symb2genv b), vl) (coerced_valid _ _) (ext_rmap_join _ _ _ Hno0)) as HP.
    lapply HP; clear HP; [intro HP | unfold semax.ext_compat; rewrite ext_rmap_ghost; exact Hext0].
    lapply HP; clear HP; [intro HP | reflexivity].
    lapply HP; clear HP; [intro HP | exact Hpre].
    lapply HP; clear HP; [intro HP | rewrite Hgv; exact (errno_rmap_errno_at _ _ _ _ _ Hc)].
    exact HP.
  - apply rt_refl.
  - try rewrite jmJ_phi. unfold phiJ, semax.ext_compat, set_ghost. rewrite ghost_of_make_rmap.
    exists (Some (ext_both (embed s), NoneP) :: List.tl (ghost_of (ext_rmap (m_phi jm) m' eb))).
    constructor; [apply ext_ref_join_opt | constructor].
  all: match goal with |- ?G => idtac "JUICY leftover:" G end.
Qed.

End EmbedJuicy.
