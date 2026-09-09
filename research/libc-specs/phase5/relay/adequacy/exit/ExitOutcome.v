(* Concrete execution consequence for the exit-wrapper program: the returned
   status at the exit-call boundary (adequacy-resume-2).

   Setting (all from the checked files): relay_exit.prog is relay.c unchanged
   plus `int main(void){ exit(relay()); return 0; }`; MainExit.prog_correct is
   its semax_prog theorem with exit's precondition `outcome w0 status final
   pending` proved by main from relay's postcondition; DryExit gives the dry
   specification exit_dry_spec w0 (read/write with real memory effects, exit
   with no return); SafetyExit.relay_exit_dry_safety gives dry_safeN of the
   concrete Clight core execution for every n under the explicit library
   premise Jsub.  Trace.v's generic section turns dry_safeN into statements
   about finite executions (dry_steps).

   What is stated here (relay_exit_outcome), for every valid initial world w0
   and every state (q, m, z) reachable from the initial core by finitely many
   dry_steps in an environment answering read/write as scheduled:

   (a) not stuck: at an external call the dry precondition holds of the actual
       arguments, memory and world; otherwise, unless halted, a core step exists;
   (b) RETURNED OUTCOME: if the state is at the external call
       exit (EF_external "exit" (mksignature [Xint] Xvoid cc_default)) with
       argument list args, then there are status and pending with
         args = [Vint (Int.repr status)]  and  outcome w0 status z pending,
       i.e. the integer actually handed to the environment by the concrete
       execution is the protocol status of the initial world, and the world at
       that moment is the protocol's final world (with the pending bytes of
       Reach.outcome).  This is at the exit-CALL boundary, not a statement about
       the original relay_main program's halted return value (which VST's forced
       exit predicate True cannot carry).
   (c) no dry_step leaves the exit call: the specification's dry post is False,
       so the environment's non-return is part of the model, not a theorem
       about the host OS.

   Not stated: that the exit call is REACHED (termination / progress of the C
   execution), or anything about the host OS; the C->Clight translation is
   trusted as documented (relay_exit.i / relay_exit.v hashes). *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.semantics.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.sepcomp.step_lemmas.
Require Import VST.veric.Clight_core.
Require Import VST.veric.semax_lemmas.
Require Import VST.veric.SequentialClight.
Require Import Trace.
Require Import relay_exit Protocol Reach MainExit DryExit SafetyExit.
Import RelayProtocol RelayReach.

(* The external function of the exit call, exactly as declared in
   relay_exit.prog's prog_defs. *)
Definition exit_ef : external_function :=
  EF_external "exit" (mksignature [AST.Xint] AST.Xvoid cc_default).

Lemma exit_ef_in_prog :
  In (_exit, Gfun (External exit_ef (tint :: nil) tvoid cc_default)) (prog_defs prog).
Proof. unfold prog; simpl; repeat first [left; reflexivity | right]. Qed.

Section ExitOutcome.

Variable w0 : world.

(* Inverting the dry precondition of exit_dry_spec w0 at the exit call. *)
Lemma exit_dry_pre_inv : forall (x : ext_spec_type (exit_dry_spec w0) exit_ef) b tys args z m,
  ext_spec_pre (exit_dry_spec w0) exit_ef x b tys args z m ->
  exists status pending, args = [Vint (Int.repr status)] /\ outcome w0 status z pending.
Proof.
  intros x b tys args z m Hpre.
  revert x Hpre; unfold exit_dry_spec; cbn [ext_spec_pre ext_spec_type].
  destruct (oi_eq_dec _ _) as [E | _].
  { exfalso; vm_compute in E; discriminate E. }
  destruct (oi_eq_dec _ _) as [E | _].
  { exfalso; vm_compute in E; discriminate E. }
  destruct (oi_eq_dec _ _) as [_ | N].
  2:{ exfalso; apply N; vm_compute; reflexivity. }
  intros x Hpre.
  destruct x as (m0 & ts & w); simpl in w.
  destruct w as ((status, final), pending).
  simpl in Hpre.
  destruct Hpre as [[Hargs [Hz Hout]] _]; subst.
  exists status, pending; auto.
Qed.

(* The dry postcondition of exit is False: no witness admits a return. *)
Lemma exit_dry_post_False : forall (x : ext_spec_type (exit_dry_spec w0) exit_ef) b ot ret z m,
  ~ ext_spec_post (exit_dry_spec w0) exit_ef x b ot ret z m.
Proof.
  intros x b ot ret z m Hpost.
  revert x Hpost; unfold exit_dry_spec; cbn [ext_spec_post ext_spec_type].
  destruct (oi_eq_dec _ _) as [E | _].
  { exfalso; vm_compute in E; discriminate E. }
  destruct (oi_eq_dec _ _) as [E | _].
  { exfalso; vm_compute in E; discriminate E. }
  destruct (oi_eq_dec _ _) as [_ | N].
  2:{ exfalso; apply N; vm_compute; reflexivity. }
  intros x Hpost; exact Hpost.
Qed.

End ExitOutcome.

Section RelayExitTrace.

Hypothesis Jsub : forall ef se lv m t v m' (EFI : ef_inline ef = true) m1
       (EFC : Events.external_call ef se lv m t v m'), juicy_mem.mem_sub m m1 ->
       exists m1' (EFC1 : Events.external_call ef se lv m1 t v m1'),
         juicy_mem.mem_sub m' m1' /\
         proj1_sig (inline_external_call_mem_events _ _ _ _ _ _ _ EFI EFC1) =
         proj1_sig (inline_external_call_mem_events _ _ _ _ _ _ _ EFI EFC).

(* Exactly the terms appearing in relay_exit_dry_safety's statement. *)
Local Notation csem := (cl_core_sem (globalenv prog)).
Local Notation exit_ge :=
  (Clight.genv_genv {| Clight.genv_genv := Genv.globalenv prog; Clight.genv_cenv := prog_comp_env prog |}).

Theorem relay_exit_outcome (w0 : world) (Hv : valid_world w0) :
  exists q0,
  semantics.initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
  forall k q m z,
    dry_steps csem (exit_dry_spec w0) semax.genv_symb_injective exit_ge k (q0, init_mem, w0) (q, m, z) ->
    (* (a) not stuck *)
    ((forall e args, semantics.at_external csem q m = Some (e, args) ->
       exists x, ext_spec_pre (exit_dry_spec w0) e x (semax.genv_symb_injective exit_ge)
                   (map proj_xtype (sig_args (ef_sig e))) args z m) /\
     (semantics.at_external csem q m = None -> (forall i, ~ semantics.halted csem q i) ->
       exists q' m', semantics.corestep csem q m q' m')) /\
    (* (b) returned outcome at the exit call *)
    (forall args, semantics.at_external csem q m = Some (exit_ef, args) ->
       exists status pending, args = [Vint (Int.repr status)] /\ outcome w0 status z pending) /\
    (* (c) the environment does not return from exit *)
    (forall args, semantics.at_external csem q m = Some (exit_ef, args) ->
       forall s', ~ dry_step csem (exit_dry_spec w0) semax.genv_symb_injective exit_ge (q, m, z) s').
Proof.
  destruct (relay_exit_dry_safety Jsub w0 Hv) as (q0 & Hinit & Hsafe).
  exists q0; split; [exact Hinit|].
  intros k q m z Hsteps.
  pose proof (Hsafe (k + 1)%nat) as Hk.
  pose proof (safeN_dry_steps csem (exit_dry_spec w0) semax.genv_symb_injective exit_ge
                (cl_fun _) (cl_excl _) k _ _ Hsteps 1 w0 q0 init_mem z q m eq_refl eq_refl Hk) as H1.
  pose proof (safeN_not_stuck csem (exit_dry_spec w0) semax.genv_symb_injective exit_ge (cl_excl _) z q m H1)
    as [Hpre Hstep].
  split; [split; assumption|].
  split.
  - intros args Hat.
    destruct (Hpre _ _ Hat) as (x & Hx).
    exact (exit_dry_pre_inv w0 x _ _ _ _ _ Hx).
  - intros args Hat s' Hs.
    destruct (Hpre _ _ Hat) as (x & Hx).
    inv Hs.
    + (* a core step from an at_external state is impossible *)
      match goal with Hc : semantics.corestep csem q m _ _ |- _ =>
        erewrite semantics.corestep_not_at_external in Hat; eauto; congruence end.
    + match goal with Ha : semantics.at_external csem q m = Some (?e, ?a),
                      Hb : semantics.at_external csem q m = Some (exit_ef, args) |- _ =>
        rewrite Hb in Ha; inv Ha end.
      match goal with Hpost : forall x, _ -> ext_spec_post _ _ _ _ _ _ _ _ |- _ =>
        exact (exit_dry_post_False w0 x _ _ _ _ _ (Hpost x Hx)) end.
Qed.

End RelayExitTrace.

Check relay_exit_outcome.
Print Assumptions relay_exit_outcome.
Print Assumptions exit_dry_pre_inv.
