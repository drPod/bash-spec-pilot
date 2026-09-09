(* (a) Write twin of EmbedJuicy.read_juicy_pre_relay_to_iow (same
   construction jmJ / nh frame, precondition part EmbedPre2.write_pre_relay_to_iow).
   (b) The scoped external-call correspondence at the dry boundary: a relay
   juicy PRE witness for the call in jm, plus the explicit errno cell
   extension m' of m_dry jm, yields the CONCRETE CompCert dry precondition
   iow_dry_spec demands of the transported witness at m' -- by composing
   the juicy transport with the accepted record's PRE-preservation
   conjunct (JuicyPre.iow_juicy_dry_pre through JuicyDrySpecs). Together
   with EmbedBridge.read/write_dry_post_n_to_relay (dry POST of the
   generalized call back to relay's dry POST + errno effect, oracle forced
   to embed of relay's new world) and JuicyPost.iow_juicy_dry_post (dry
   POST to IOW juicy POST), this is the read/write external-call
   correspondence relay-side <-> generalized-side, stated without any
   whole program: hypotheses are exactly the relay witness, the cell
   extension, and the symbol-table fact errno_id |-> eb. *)
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
Require Import Specialize MemAdequacy DryPost ErrnoBridge ErrnoLoad PostLemmas2 PostLemmas3 JuicyDry JuicyPre EmbedBridge EmbedPre EmbedPre2 EmbedJuicy.
Import ListNotations.
Import Maps.
Local Open Scope Z_scope.

Section EmbedJuicy2.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_ext_spec' := (iow_ext_spec errno_id ext_link).
Notation iow_dry_spec' := (iow_dry_spec errno_id ext_link).
Notation iow_dessicate' := (iow_dessicate errno_id ext_link).
Notation relay_ext_spec' := (relay_ext_spec_local ext_link).

(* ext_link is a fresh-ident map in every VST client (relay's and IOSpecs'
   Espec constructions both take it as a parameter); we only need it to
   separate "read" from "write", stated as an explicit hypothesis rather
   than assumed injective. *)
Theorem write_juicy_pre_relay_to_iow : forall ef t b tl vl z jm m' eb e
  (Hc : mem_cell_ext (m_dry jm) m' eb e)
  (Hb : Map.get (filter_genv (symb2genv b)) errno_id = Some eb)
  (Hinj : ext_link "read"%string <> ext_link "write"%string),
  ef_id_sig ext_link ef = Some (ext_link "write"%string, typesig2signature ([tint; tptr tvoid; tulong], tlong) cc_default) ->
  ext_spec_pre relay_ext_spec' ef t b tl vl z jm ->
  exists phi1n,
    ext_spec_pre iow_ext_spec' ef (embed_juicy_witness errno_id ext_link (genv_globals b) e phi1n ef t) b tl vl (embed z)
      (jmJ jm m' eb e (embed z) Hc).
Proof.
  intros ef. simpl. unfold funspec2pre, embed_juicy_witness. simpl.
  if_tac.
  { intros t b tl vl z jm m' eb e Hc Hb Hinj Hef. rewrite <- H in Hef.
    exfalso. injection Hef; intros.
    match goal with Hl : ext_link _ = ext_link _ |- _ => exact (Hinj Hl) end. }
  clear H. unfold funspec2pre; simpl. if_tac; [| intros; congruence].
  intros t b tl vl z jm m' eb e Hc Hb Hinj Hef Hpre.
  destruct t as (phi1 & ts & w). destruct w as (((s & p) & bs) & sh). simpl in *.
  destruct Hpre as (Hty & phi0 & phi1' & J & Hpre & Hnec & Hext).
  assert (Hsub0 : join_sub phi0 (m_phi jm)) by (eexists; exact J).
  assert (Htr : exists phig, join_sub phig phi0 /\ app_pred (has_ext s) phig).
  { pose proof Hpre as Hp. unfold SEPx in Hp; simpl in Hp. rewrite seplog.sepcon_emp in Hp.
    destruct Hp as [_ [_ [_ [phig [phib [J1 [Htrace _]]]]]]]. exists phig. split; [eexists; exact J1 | exact Htrace]. }
  destruct Htr as (phig & Hsubg & Htrace).
  destruct (has_ext_compat _ z _ _ Htrace (join_sub_trans Hsubg Hsub0) Hext) as (Hsz & _ & Hg). subst z.
  assert (Hext0 : semax.ext_compat s phi0) by (eapply ext_compat_sub; eauto).
  destruct (has_ext_compat _ s _ _ Htrace Hsubg Hext0) as (_ & _ & Hg0).
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
  - try rewrite jmJ_phi. unfold phiJ.
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
  - pose proof (write_pre_relay_to_iow errno_id s p sh bs phi0 (errno_rmap phi0 m' eb) (ext_rmap phi0 m' eb) gv e
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
  all: match goal with |- ?G => idtac "WRITE JUICY leftover:" G end.
Qed.

(* ---- (b) PRE-side external-call correspondence at the dry boundary ---- *)

Theorem relay_read_call_iow_dry_pre : forall ef t b tl vl z jm m' eb e
  (Hc : mem_cell_ext (m_dry jm) m' eb e)
  (Hb : Map.get (filter_genv (symb2genv b)) errno_id = Some eb),
  ef_id_sig ext_link ef = Some (ext_link "read"%string, typesig2signature ([tint; tptr tvoid; tulong], tlong) cc_default) ->
  ext_spec_pre relay_ext_spec' ef t b tl vl z jm ->
  exists phi1n,
    ext_spec_pre iow_dry_spec' ef
      (iow_dessicate' ef (jmJ jm m' eb e (embed z) Hc)
         (embed_juicy_witness errno_id ext_link (genv_globals b) e phi1n ef t))
      b tl vl (embed z) m'.
Proof.
  intros ef t b tl vl z jm m' eb e Hc Hb Hef Hpre.
  destruct (read_juicy_pre_relay_to_iow errno_id ext_link ef t b tl vl z jm m' eb e Hc Hb Hef Hpre) as (phi1n & HP).
  exists phi1n.
  pose proof (iow_juicy_dry_pre errno_id ext_link ef _ _ b tl vl (embed z) _ eq_refl HP) as HD.
  try rewrite jmJ_dry in HD. exact HD.
Qed.

Theorem relay_write_call_iow_dry_pre : forall ef t b tl vl z jm m' eb e
  (Hc : mem_cell_ext (m_dry jm) m' eb e)
  (Hb : Map.get (filter_genv (symb2genv b)) errno_id = Some eb)
  (Hinj : ext_link "read"%string <> ext_link "write"%string),
  ef_id_sig ext_link ef = Some (ext_link "write"%string, typesig2signature ([tint; tptr tvoid; tulong], tlong) cc_default) ->
  ext_spec_pre relay_ext_spec' ef t b tl vl z jm ->
  exists phi1n,
    ext_spec_pre iow_dry_spec' ef
      (iow_dessicate' ef (jmJ jm m' eb e (embed z) Hc)
         (embed_juicy_witness errno_id ext_link (genv_globals b) e phi1n ef t))
      b tl vl (embed z) m'.
Proof.
  intros ef t b tl vl z jm m' eb e Hc Hb Hinj Hef Hpre.
  destruct (write_juicy_pre_relay_to_iow ef t b tl vl z jm m' eb e Hc Hb Hinj Hef Hpre) as (phi1n & HP).
  exists phi1n.
  pose proof (iow_juicy_dry_pre errno_id ext_link ef _ _ b tl vl (embed z) _ eq_refl HP) as HD.
  try rewrite jmJ_dry in HD. exact HD.
Qed.

End EmbedJuicy2.
