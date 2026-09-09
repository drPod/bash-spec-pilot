(* Third batch of POST-preservation auxiliaries (see PostLemmas.v,
   PostLemmas2.v). Everything the POST assembly (JuicyPost.v) needs beyond
   relay's Dry.v that is specific to the utility contracts:
   - resource-level share transport through joins (a YES held with a
     writable share stays a YES with a writable share up any join_sub; two
     YES resources at one address cannot join if one side is writable);
   - memory-readability of any VAL location of a juicy memory;
   - `rebuild_store_gen_val`: PostLemmas.rebuild_store_gen with the
     contents hypothesis restricted to VAL resources (the only ones its
     proof uses it for), and `rebuild_store2'`: the two-store rebuild where
     the errno store is performed on a memory only mem_equiv to the buffer
     store's result -- exactly the shape DryPost.read_dry_post_n states;
   - `inflate_store_ext`: inflate_store only looks at contents of VAL
     addresses, so memories agreeing there give the same rmap;
   - `errno_at_YES`: every address of the errno cell is a YES Ews VAL
     resource in any rmap holding errno_at;
   - `bytes_to_memvals_length`, `errno_memval_Zlength`: Zlength facts.
   No new definitions; nothing here changes IOSpecs/DryPost contracts. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.veric.juicy_mem.
Require Import VST.veric.compcert_rmaps.
Require Import VST.veric.initial_world.
Require Import VST.veric.ghost_PCM.
Require Import VST.veric.SequentialClight.
Require Import VST.concurrency.conclib.
Require Import VST.veric.mem_lessdef.
Require Import VST.veric.res_predicates.
Require Import dry_mem_lemmas.
Require Import IOSpecs MemAdequacy ErrnoBridge ErrnoLoad PostLemmas PostLemmas2.
Import ListNotations.
Import Maps.
Local Open Scope Z_scope.

(* ---- Zlength facts ---- *)

Lemma bytes_to_memvals_length : forall li, Zlength (bytes_to_memvals li) = Zlength li.
Proof.
  intros.
  rewrite !Zlength_correct; f_equal.
  unfold bytes_to_memvals.
  rewrite <- map_map, encode_vals_length, map_length; auto.
Qed.

Lemma errno_memval_Zlength : forall e, Zlength (errno_memval e) = 4.
Proof.
  intro e. unfold errno_memval. rewrite Zlength_correct, encode_val_length. reflexivity.
Qed.

(* ---- share transport through joins ---- *)

Lemma join_sub_YES : forall phi phi' l sh rsh k pp,
  join_sub phi phi' -> phi @ l = YES sh rsh k pp ->
  exists sh' rsh', phi' @ l = YES sh' rsh' k pp /\ join_sub sh sh'.
Proof.
  intros phi phi' l sh rsh k pp [phix J] Hl.
  apply (resource_at_join _ _ _ l) in J. rewrite Hl in J.
  (* inversion rewrites the goal's own occurrence of phi' @ l *)
  inv J; (do 2 eexists; split;
    [first [reflexivity | eassumption | symmetry; eassumption] | eexists; eassumption]).
Qed.

Lemma join_sub_YES_writable : forall phi phi' l sh rsh k pp,
  join_sub phi phi' -> phi @ l = YES sh rsh k pp -> writable_share sh ->
  exists sh' rsh', phi' @ l = YES sh' rsh' k pp /\ writable_share sh'.
Proof.
  intros phi phi' l sh rsh k pp Hsub Hl Hw.
  destruct (join_sub_YES _ _ _ _ _ _ _ Hsub Hl) as (sh' & rsh' & Hl' & [shx Jsh]).
  exists sh', rsh'. split; [exact Hl'|]. eapply join_writable1; eauto.
Qed.

Lemma YES_join_writable_absurd : forall phiA phiB phiC l shA rshA kA ppA shB rshB kB ppB,
  join phiA phiB phiC ->
  phiA @ l = YES shA rshA kA ppA -> phiB @ l = YES shB rshB kB ppB ->
  writable_share shB -> False.
Proof.
  intros phiA phiB phiC l shA rshA kA ppA shB rshB kB ppB J HA HB Hw.
  apply (resource_at_join _ _ _ l) in J. rewrite HA, HB in J. inv J.
  match goal with Hj : join shA shB _ |- _ =>
    eapply join_writable_readable; [apply join_comm; exact Hj | exact Hw | exact rshA] end.
Qed.

(* ---- readability of VAL locations ---- *)

Lemma YES_perm_readable : forall jm b o sh rsh v pp,
  m_phi jm @ (b, o) = YES sh rsh (VAL v) pp -> Mem.perm (m_dry jm) b o Cur Readable.
Proof.
  intros jm b o sh rsh v pp H.
  pose proof (juicy_mem_access jm (b, o)) as Ha. rewrite H in Ha; simpl in Ha.
  eapply access_at_readable; eauto.
Qed.

Lemma join_sub_YES_perm_readable : forall jm phi b o sh rsh v pp,
  join_sub phi (m_phi jm) -> phi @ (b, o) = YES sh rsh (VAL v) pp ->
  Mem.perm (m_dry jm) b o Cur Readable.
Proof.
  intros jm phi b o sh rsh v pp Hsub Hl.
  destruct (join_sub_YES _ _ _ _ _ _ _ Hsub Hl) as (sh' & rsh' & Hl' & _).
  eapply YES_perm_readable; eauto.
Qed.

(* ---- the errno cell is YES Ews everywhere in its 4 addresses ---- *)

Lemma errno_at_YES : forall b ofs e phi l,
  field_compatible tint [] (Vptr b ofs) ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e) phi ->
  adr_range (b, Ptrofs.unsigned ofs) 4 l ->
  exists rsh v, phi @ l = YES Ews rsh (VAL v) NoneP.
Proof.
  intros b ofs e phi l Hfc Herr Hin.
  rewrite errno_at_address_mapsto in Herr by exact Hfc.
  destruct Herr as [_ [bl [_ Hres]]].
  specialize (Hres l). simpl in Hres.
  rewrite if_true in Hres by (change (size_chunk Mint32) with 4; exact Hin).
  destruct Hres as [rsh Hres]. hnf in Hres.
  try rewrite preds_fmap_NoneP in Hres.
  eauto.
Qed.

(* ---- inflate_store only reads VAL addresses ---- *)

Lemma inflate_store_ext : forall m m' phi,
  (forall l sh rsh v pp, phi @ l = YES sh rsh (VAL v) pp -> contents_at m l = contents_at m' l) ->
  inflate_store m phi = inflate_store m' phi.
Proof.
  intros m m' phi H.
  apply rmap_ext.
  - unfold inflate_store; rewrite !level_make_rmap; reflexivity.
  - intro l. unfold inflate_store; rewrite !resource_at_make_rmap.
    destruct (phi @ l) as [| sh rsh k pp |] eqn:Hl; auto.
    destruct k; auto. rewrite (H _ _ _ _ _ Hl). reflexivity.
  - unfold inflate_store; rewrite !ghost_of_make_rmap; reflexivity.
Qed.

(* ---- rebuild_store_gen, contents hypothesis on VAL resources only
   (verbatim PostLemmas.rebuild_store_gen otherwise; its two uses of Hcont
   are under `destruct k` with k = VAL) ---- *)

Lemma rebuild_store_gen_val : forall jm0 phi m m' phi0 phi1 loc
  (Hlevel : (level phi <= level (m_phi jm0))%nat)
  (Hrebuild : resource_at phi =
     resource_fmap (approx (level phi)) (approx (level phi))
     oo juicy_mem_lemmas.rebuild_juicy_mem_fmap jm0 m)
  (Hacc : access_at (m_dry jm0) = access_at m') (Heq : mem_equiv m m')
  (J : join phi0 phi1 (m_phi jm0))
  (Hcont : forall l sh rsh v p, phi1 @ l = YES sh rsh (VAL v) p -> contents_at m' l = contents_at (m_dry jm0) l),
  join (age_to.age_to (level phi) (inflate_store m' phi0) @ loc)
         (age_to.age_to (level phi) phi1 @ loc) (phi @ loc).
Proof.
  intros.
  destruct (join_level _ _ _ J).
  rewrite Hrebuild, !age_to_resource_at.age_to_resource_at.
  unfold compose, inflate_store, juicy_mem_lemmas.rebuild_juicy_mem_fmap; rewrite !resource_at_make_rmap.
  apply (resource_at_join _ _ _ loc) in J.
  simpl.
  inv J; try constructor.
  - rewrite if_false; [constructor; auto|].
    erewrite mem_equiv_access by eauto.
    rewrite <- Hacc.
    destruct jm0; simpl in *.
    rewrite (JMaccess loc), <- H4; simpl.
    if_tac; auto.
    intro X; inv X.
  - destruct k; try (rewrite resource_fmap_fmap, approx_oo_approx', approx'_oo_approx by lia; constructor; auto).
    destruct jm0; simpl in *.
    pose proof (JMaccess loc) as Haccess.
    rewrite <- H4 in Haccess; simpl in Haccess.
    rewrite Hacc, <- (mem_equiv_access m m' Heq) in Haccess.
    destruct loc as (b', o').
    erewrite <- (mem_equiv_contents m m'); eauto.
    rewrite Haccess, if_true.
    constructor; auto.
    { unfold perm_of_sh.
      if_tac; if_tac; constructor || contradiction. }
    { eapply access_at_readable; eauto. }
  - destruct k; try (constructor; auto).
    pose proof (juicy_mem_access jm0 loc) as Haccess.
    rewrite <- H4 in Haccess; simpl in Haccess.
    rewrite Hacc, <- (mem_equiv_access m m' Heq) in Haccess.
    rewrite Haccess, if_true.
    destruct loc as (b', o').
    erewrite (mem_equiv_contents m m'); eauto.
    exploit (juicy_mem_contents jm0); eauto; intros []; subst.
    match goal with HY : YES _ _ _ _ = phi1 @ (b', o') |- _ => rewrite (Hcont _ _ _ _ _ (eq_sym HY)) end.
    constructor; auto.
    { eapply access_at_readable; eauto. }
    { unfold perm_of_sh.
      if_tac; if_tac; constructor || contradiction. }
  - destruct k; try (rewrite resource_fmap_fmap, approx_oo_approx', approx'_oo_approx by lia; constructor; auto).
    pose proof (juicy_mem_access jm0 loc) as Haccess.
    rewrite <- H4 in Haccess; simpl in Haccess.
    rewrite Hacc, <- (mem_equiv_access m m' Heq) in Haccess.
    rewrite Haccess, if_true.
    destruct loc as (b', o').
    erewrite (mem_equiv_contents m); eauto.
    exploit (juicy_mem_contents jm0); eauto; intros []; subst.
    match goal with HY : YES _ _ _ _ = phi1 @ (b', o') |- _ => rewrite (Hcont _ _ _ _ _ (eq_sym HY)) end.
    constructor; auto.
    { eapply access_at_readable; eauto. }
    { unfold perm_of_sh.
      if_tac; if_tac; constructor || contradiction. }
Qed.

(* ---- two stores where the second is performed on a memory merely
   mem_equiv to the first store's result (DryPost.read_dry_post_n's shape:
   buffer store m_dry jm0 -> m1', mem_equiv m1 m1', errno store m1 -> m2,
   mem_equiv m m2) ---- *)

Lemma rebuild_store2' : forall jm0 phi m m1 m1' m2 b1 o1 lv1 b2 o2 lv2 phi0 phi1 loc
  (Hlevel : (level phi <= level (m_phi jm0))%nat)
  (Hrebuild : resource_at phi =
     resource_fmap (approx (level phi)) (approx (level phi))
     oo juicy_mem_lemmas.rebuild_juicy_mem_fmap jm0 m)
  (Hst1 : Mem.storebytes (m_dry jm0) b1 o1 lv1 = Some m1')
  (Heq1 : mem_equiv m1 m1')
  (Hst2 : Mem.storebytes m1 b2 o2 lv2 = Some m2)
  (Heq : mem_equiv m m2)
  (J : join phi0 phi1 (m_phi jm0))
  (Hout1 : forall l sh rsh k p, phi1 @ l = YES sh rsh k p -> ~ adr_range (b1, o1) (Zlength lv1) l)
  (Hout2 : forall l sh rsh k p, phi1 @ l = YES sh rsh k p -> ~ adr_range (b2, o2) (Zlength lv2) l),
  join (age_to.age_to (level phi) (inflate_store m2 phi0) @ loc)
         (age_to.age_to (level phi) phi1 @ loc) (phi @ loc).
Proof.
  intros.
  eapply rebuild_store_gen_val; eauto.
  - rewrite (storebytes_access _ _ _ _ _ Hst1), <- (mem_equiv_access _ _ Heq1),
      (storebytes_access _ _ _ _ _ Hst2); reflexivity.
  - intros l sh rsh v p Hl.
    rewrite (contents_at_storebytes_other _ _ _ _ _ _ Hst2) by (eapply Hout2; eauto).
    rewrite <- (contents_at_storebytes_other _ _ _ _ _ _ Hst1) by (eapply Hout1; eauto).
    destruct l as (b, o).
    apply mem_equiv_contents; [exact Heq1|].
    destruct Heq1 as (_ & Hperm & _). rewrite Hperm.
    eapply Mem.perm_storebytes_1; [exact Hst1|].
    eapply join_sub_YES_perm_readable; [eexists; apply join_comm; exact J | exact Hl].
Qed.

(* ---- contents of a VAL address of a sub-rmap of jm0 survive a store
   elsewhere: gives inflate_store_unchanged's hypothesis ---- *)

Lemma contents_unchanged_sub : forall jm0 phi m0 m b o lv l sh rsh v pp,
  join_sub phi (m_phi jm0) ->
  m0 = m_dry jm0 ->
  Mem.storebytes m0 b o lv = Some m ->
  ~ adr_range (b, o) (Zlength lv) l ->
  phi @ l = YES sh rsh (VAL v) pp ->
  contents_at m l = v /\ pp = NoneP.
Proof.
  intros jm0 phi m0 m b o lv l sh rsh v pp Hsub Hm0 Hst Hout Hl. subst m0.
  rewrite (contents_at_storebytes_other _ _ _ _ _ _ Hst Hout).
  destruct (join_sub_YES _ _ _ _ _ _ _ Hsub Hl) as (sh' & rsh' & Hl' & _).
  exact (juicy_mem_contents jm0 _ _ _ _ _ Hl').
Qed.
