(* POST-side chaining of the external-call correspondence on the actual
   records (README "Still open", first bullet): for the transported,
   dessicated witness of a relay read/write call, any dry POST of the
   generalized call (ext_spec_post of iow_dry_spec at the final CompCert
   memory m_f, return value v, new oracle x) forces x to be `embed` of
   relay's own new world and yields relay's dry POST (DryPost's restated
   relay_read/write_dry_post) at an intermediate memory m1, plus the errno
   store m1 -> m_f with errno = 1 on error. Hypotheses: the relay juicy PRE
   witness (for valid_world s and s = z), the cell extension, errno_id |->
   eb, the read/write dispatch fact, and the dry POST itself. *)
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
Require Import Specialize MemAdequacy DryPost ErrnoBridge ErrnoLoad PostLemmas2 PostLemmas3 JuicyDry JuicyPre EmbedBridge EmbedPre EmbedPre2 EmbedJuicy EmbedJuicy2.
Import ListNotations.
Import Maps.
Local Open Scope Z_scope.

Section EmbedJuicy3.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_ext_spec' := (iow_ext_spec errno_id ext_link).
Notation iow_dry_spec' := (iow_dry_spec errno_id ext_link).
Notation iow_dessicate' := (iow_dessicate errno_id ext_link).
Notation relay_ext_spec' := (relay_ext_spec_local ext_link).

Theorem relay_read_call_iow_dry_post : forall ef t b tl vl z jm m' eb e
  (Hc : mem_cell_ext (m_dry jm) m' eb e)
  (Hb : Map.get (filter_genv (symb2genv b)) errno_id = Some eb)
  phi1n ot v x m_f,
  ef_id_sig ext_link ef = Some (ext_link "read"%string, typesig2signature ([tint; tptr tvoid; tulong], tlong) cc_default) ->
  ext_spec_pre relay_ext_spec' ef t b tl vl z jm ->
  ext_spec_post iow_dry_spec' ef
    (iow_dessicate' ef (jmJ jm m' eb e (embed z) Hc)
       (embed_juicy_witness errno_id ext_link (genv_globals b) e phi1n ef t))
    b ot v x m_f ->
  ot <> Xvoid /\
  exists i p m1 e',
    v = Some (Vlong i) /\
    x = embed (RelayProtocol.read_world (RelayProtocol.read32 z)) /\
    relay_read_dry_post m' m1 i (z, p) (RelayProtocol.read_world (RelayProtocol.read32 z)) /\
    (RelayProtocol.read_ret (RelayProtocol.read32 z) < 0 -> e' = 1) /\
    errno_dry_post_effect m1 m_f (genv_globals b errno_id) e'.
Proof.
  intros ef. simpl. unfold funspec2pre, embed_juicy_witness, iow_dessicate. simpl.
  if_tac; [| intros; congruence].
  intros t b tl vl z jm m' eb e Hc Hb phi1n ot v x m_f Hef Hpre Hpost.
  destruct t as (phi1 & ts & w). destruct w as ((s & p) & sh). simpl in *.
  destruct Hpre as (Hty & phi0 & phi1' & J & Hpre & Hnec & Hext).
  assert (Hsub0 : join_sub phi0 (m_phi jm)) by (eexists; exact J).
  assert (Htr : exists phig, join_sub phig phi0 /\ app_pred (has_ext s) phig /\ RelayProtocol.valid_world s).
  { pose proof Hpre as Hp. unfold SEPx in Hp; simpl in Hp. rewrite seplog.sepcon_emp in Hp.
    destruct Hp as [[Hvalid _] [_ [_ [phig [phib [J1 [Htrace _]]]]]]]. exists phig.
    split; [eexists; exact J1 | split; [exact Htrace | exact Hvalid]]. }
  destruct Htr as (phig & Hsubg & Htrace & Hvalid).
  destruct (has_ext_compat _ z _ _ Htrace (join_sub_trans Hsubg Hsub0) Hext) as (Hsz & _ & _). subst z.
  destruct v as [vv|]; [|contradiction].
  destruct vv; try contradiction.
  destruct Hpost as (Hot & Hpost).
  split; [exact Hot|].
  apply read_dry_post_n_to_relay in Hpost; [|exact (proj1 Hvalid)].
  destruct Hpost as (Hx & m1 & e' & Hrel & He & Herr).
  exists i, p, m1, e'.
  split; [reflexivity|]. split; [exact Hx|]. split; [exact Hrel|]. split; [exact He|].
  exact Herr.
  all: match goal with |- ?G => idtac "POST3 leftover:" G end.
Qed.

Theorem relay_write_call_iow_dry_post : forall ef t b tl vl z jm m' eb e
  (Hc : mem_cell_ext (m_dry jm) m' eb e)
  (Hb : Map.get (filter_genv (symb2genv b)) errno_id = Some eb)
  (Hinj : ext_link "read"%string <> ext_link "write"%string)
  phi1n ot v x m_f,
  ef_id_sig ext_link ef = Some (ext_link "write"%string, typesig2signature ([tint; tptr tvoid; tulong], tlong) cc_default) ->
  ext_spec_pre relay_ext_spec' ef t b tl vl z jm ->
  ext_spec_post iow_dry_spec' ef
    (iow_dessicate' ef (jmJ jm m' eb e (embed z) Hc)
       (embed_juicy_witness errno_id ext_link (genv_globals b) e phi1n ef t))
    b ot v x m_f ->
  ot <> Xvoid /\
  exists i p bs e',
    v = Some (Vlong i) /\
    x = embed (RelayProtocol.write_world (RelayProtocol.write_block z bs)) /\
    relay_write_dry_post m' m' i (z, p, bs) (RelayProtocol.write_world (RelayProtocol.write_block z bs)) /\
    (RelayProtocol.write_ret (RelayProtocol.write_block z bs) < 0 -> e' = 1) /\
    errno_dry_post_effect m' m_f (genv_globals b errno_id) e'.
Proof.
  intros ef. simpl. unfold funspec2pre, embed_juicy_witness, iow_dessicate. simpl.
  if_tac.
  { intros t b tl vl z jm m' eb e Hc Hb Hinj phi1n ot v x m_f Hef. rewrite <- H in Hef.
    exfalso. injection Hef; intros.
    match goal with Hl : ext_link _ = ext_link _ |- _ => exact (Hinj Hl) end. }
  clear H. unfold funspec2pre; simpl. if_tac; [| intros; congruence].
  intros t b tl vl z jm m' eb e Hc Hb Hinj phi1n ot v x m_f Hef Hpre Hpost.
  destruct t as (phi1 & ts & w). destruct w as (((s & p) & bs) & sh). simpl in *.
  destruct Hpre as (Hty & phi0 & phi1' & J & Hpre & Hnec & Hext).
  assert (Hsub0 : join_sub phi0 (m_phi jm)) by (eexists; exact J).
  assert (Htr : exists phig, join_sub phig phi0 /\ app_pred (has_ext s) phig /\ RelayProtocol.valid_world s).
  { pose proof Hpre as Hp. unfold SEPx in Hp; simpl in Hp. rewrite seplog.sepcon_emp in Hp.
    destruct Hp as [[Hvalid _] [_ [_ [phig [phib [J1 [Htrace _]]]]]]]. exists phig.
    split; [eexists; exact J1 | split; [exact Htrace | exact Hvalid]]. }
  destruct Htr as (phig & Hsubg & Htrace & Hvalid).
  destruct (has_ext_compat _ z _ _ Htrace (join_sub_trans Hsubg Hsub0) Hext) as (Hsz & _ & _). subst z.
  destruct v as [vv|]; [|contradiction].
  destruct vv; try contradiction.
  destruct Hpost as (Hot & Hpost).
  split; [exact Hot|].
  pose proof (write_dry_post_n_to_relay m' m_f i s bs p (genv_globals b errno_id) x (proj2 Hvalid) Hpost) as Hpost'.
  destruct Hpost' as (Hx & e' & Hrel & He & Herr).
  exists i, p, bs, e'.
  split; [reflexivity|]. split; [exact Hx|]. split; [exact Hrel|]. split; [exact He|].
  exact Herr.
  all: match goal with |- ?G => idtac "POST3W leftover:" G end.
Qed.

End EmbedJuicy3.
