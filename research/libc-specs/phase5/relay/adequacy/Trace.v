(* Concrete execution-trace consequence of relay_dry_safety.

   dry_safeN is a step-indexed safety predicate; this file unfolds it into a
   statement about actual finite executions of the Clight core semantics in an
   environment that answers every external call according to relay_dry_spec:

   - dry_step: one internal Clight core step (oracle unchanged), or one external
     call whose result/memory/oracle satisfy the dry postcondition for every
     witness that satisfies the dry precondition (the environment behaves as
     specified), followed by after_external;
   - every state reachable from the initial core by dry_steps is safe: if it is at
     an external call, the dry precondition holds of the actual arguments, memory
     and world for some witness (so the call is read(0,buf,32) on a writable range
     or write(1,buf+off,len) of the bytes actually in memory, with the current
     world as the witness world); if it is neither external nor halted, it can
     take a core step.

   Still NOT stated: anything about the value main returns (the dry exit
   predicate is True), and termination.

   Resume note (adequacy-resume-2): the first version fixed the section's global
   environment to Genv.globalenv prog, whereas relay_dry_safety states dry_safeN
   over Clight.genv_genv {| genv_genv := ..; genv_cenv := .. |} (coercion inserted
   by genv_symb_injective).  `apply` then tried to unify two differently headed
   terms over the 59-entry program and did not finish in 600 s
   (adequacy-trace-coqc-7).  The section is now generic in the environment type
   and the relay instance uses the syntactically identical term, closed by exact. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.semantics.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.sepcomp.step_lemmas.
Require Import VST.veric.Clight_core.
Require Import VST.veric.semax_lemmas.
Require Import VST.veric.SequentialClight.
Require Import relay_main Protocol Reach Main Dry Safety.
Import RelayProtocol RelayReach.

Section Trace.
Context {C : Type}.
Variable csem : @CoreSemantics C mem.
Variable spec : external_specification mem external_function world.
Context {G : Type}.
Variable genv_symb : G -> injective_PTree block.
Variable ge : G.
Hypothesis csem_fun : forall m q m1 q1 m2 q2,
  semantics.corestep csem q m q1 m1 -> semantics.corestep csem q m q2 m2 -> (q1, m1) = (q2, m2).
(* VST 2.15's CoreSemantics has no at_external/halted exclusivity field; it holds
   for cl_core_sem by case analysis on the core state (cl_excl below). *)
Hypothesis csem_excl : forall q m e args i,
  semantics.at_external csem q m = Some (e, args) -> ~ semantics.halted csem q i.

Local Notation symb := (genv_symb ge).
Local Notation safeN :=
  (@safeN_ G C mem world genv_symb (fun _ _ _ => True) csem spec ge).

Inductive dry_step : C * mem * world -> C * mem * world -> Prop :=
| dry_step_core q m z q' m' :
    semantics.corestep csem q m q' m' ->
    dry_step (q, m, z) (q', m', z)
| dry_step_ext q m z e args ret m' z' q' :
    semantics.at_external csem q m = Some (e, args) ->
    Val.has_type_list args (map proj_xtype (sig_args (ef_sig e))) ->
    Builtins0.val_opt_has_rettype ret (sig_res (ef_sig e)) ->
    (forall x, ext_spec_pre spec e x symb (map proj_xtype (sig_args (ef_sig e))) args z m ->
               ext_spec_post spec e x symb (sig_res (ef_sig e)) ret z' m') ->
    semantics.after_external csem ret q m' = Some q' ->
    dry_step (q, m, z) (q', m', z').

Inductive dry_steps : nat -> C * mem * world -> C * mem * world -> Prop :=
| dry_steps_0 s : dry_steps 0 s s
| dry_steps_S k s s' s'' : dry_step s s' -> dry_steps k s' s'' -> dry_steps (S k) s s''.

Lemma safeN_dry_step : forall n z q m z' q' m',
  safeN (S n) z q m -> dry_step (q, m, z) (q', m', z') -> safeN n z' q' m'.
Proof.
  intros n z q m z' q' m' Hsafe Hstep.
  inv Hstep.
  - inv Hsafe.
    + match goal with H1 : semantics.corestep csem q m _ _, H2 : semantics.corestep csem q m _ _ |- _ =>
        pose proof (csem_fun _ _ _ _ _ _ H1 H2) as Heq; inv Heq end; auto.
    + match goal with Hc : semantics.corestep csem q m _ _, Ha : semantics.at_external csem q m = Some _ |- _ =>
        erewrite semantics.corestep_not_at_external in Ha; eauto; congruence end.
    + match goal with Hc : semantics.corestep csem q m _ _, Hh : semantics.halted csem q _ |- _ =>
        exfalso; eapply (semantics.corestep_not_halted csem); eauto end.
  - inv Hsafe.
    + match goal with Hc : semantics.corestep csem q m _ _, Ha : semantics.at_external csem q m = Some _ |- _ =>
        erewrite semantics.corestep_not_at_external in Ha; eauto; congruence end.
    + match goal with Ha : semantics.at_external csem q m = Some (e, args), Hb : semantics.at_external csem q m = Some _ |- _ =>
        rewrite Ha in Hb; inv Hb end.
      match goal with Hcont : forall ret m' z' n', _ |- _ =>
        edestruct Hcont as (q'' & Hafter & Hsafe'); eauto end.
      match goal with Ha : semantics.after_external csem ret q m' = Some q', Hb : semantics.after_external csem ret q m' = Some q'' |- _ =>
        rewrite Ha in Hb; inv Hb end; auto.
    + match goal with Ha : semantics.at_external csem q m = Some _, Hh : semantics.halted csem q _ |- _ =>
        exfalso; eapply csem_excl; eauto end.
Qed.

Lemma safeN_dry_steps : forall k s s', dry_steps k s s' ->
  forall n z q m z' q' m', s = (q, m, z) -> s' = (q', m', z') ->
  safeN (k + n) z q m -> safeN n z' q' m'.
Proof.
  induction 1; intros; subst.
  - inv H0; auto.
  - destruct s' as ((q1, m1), z1).
    eapply IHdry_steps; eauto.
    eapply safeN_dry_step; eauto.
Qed.

(* A safe state is not stuck: at an external call the dry precondition holds;
   otherwise, unless halted, a core step exists. *)
Lemma safeN_not_stuck : forall z q m, safeN 1 z q m ->
  (forall e args, semantics.at_external csem q m = Some (e, args) ->
     exists x, ext_spec_pre spec e x symb (map proj_xtype (sig_args (ef_sig e))) args z m) /\
  (semantics.at_external csem q m = None -> (forall i, ~ semantics.halted csem q i) ->
     exists q' m', semantics.corestep csem q m q' m').
Proof.
  intros z q m Hsafe; split.
  - intros e args Hat. inv Hsafe.
    + erewrite semantics.corestep_not_at_external in Hat; eauto; congruence.
    + match goal with Hb : semantics.at_external csem q m = Some _ |- _ => rewrite Hat in Hb; inv Hb end.
      eexists; eauto.
    + exfalso; eapply csem_excl; eauto.
  - intros Hat Hnh. inv Hsafe.
    + eauto.
    + congruence.
    + exfalso; eapply Hnh; eauto.
Qed.

End Trace.

(* Clight instance: functionality of the core step and at_external/halted
   exclusivity, for any Clight genv. *)
Lemma cl_excl (g : genv) : forall q m e args i,
  semantics.at_external (cl_core_sem g) q m = Some (e, args) -> ~ semantics.halted (cl_core_sem g) q i.
Proof.
  intros q m e args i Hat Hh.
  destruct q; simpl in *; try discriminate.
  apply Hh; reflexivity.
Qed.

Lemma cl_fun (g : genv) : forall m q m1 q1 m2 q2,
  semantics.corestep (cl_core_sem g) q m q1 m1 -> semantics.corestep (cl_core_sem g) q m q2 m2 -> (q1, m1) = (q2, m2).
Proof. intros m q m1 q1 m2 q2 H1 H2. exact (cl_corestep_fun _ _ _ _ _ _ _ H1 H2). Qed.

Section RelayTrace.

Hypothesis Jsub : forall ef se lv m t v m' (EFI : ef_inline ef = true) m1
       (EFC : Events.external_call ef se lv m t v m'), juicy_mem.mem_sub m m1 ->
       exists m1' (EFC1 : Events.external_call ef se lv m1 t v m1'),
         juicy_mem.mem_sub m' m1' /\
         proj1_sig (inline_external_call_mem_events _ _ _ _ _ _ _ EFI EFC1) =
         proj1_sig (inline_external_call_mem_events _ _ _ _ _ _ _ EFI EFC).

(* Exactly the terms appearing in relay_dry_safety's statement. *)
Local Notation csem := (cl_core_sem (globalenv prog)).
Local Notation relay_ge :=
  (Clight.genv_genv {| Clight.genv_genv := Genv.globalenv prog; Clight.genv_cenv := prog_comp_env prog |}).

Theorem relay_concrete_trace (w0 : world) (Hv : valid_world w0) :
  exists q0,
  semantics.initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
  forall k q m z,
    dry_steps csem relay_dry_spec semax.genv_symb_injective relay_ge k (q0, init_mem, w0) (q, m, z) ->
    (forall e args, semantics.at_external csem q m = Some (e, args) ->
       exists x, ext_spec_pre relay_dry_spec e x (semax.genv_symb_injective relay_ge)
                   (map proj_xtype (sig_args (ef_sig e))) args z m) /\
    (semantics.at_external csem q m = None -> (forall i, ~ semantics.halted csem q i) ->
       exists q' m', semantics.corestep csem q m q' m').
Proof.
  destruct (relay_dry_safety Jsub w0 Hv) as (q0 & Hinit & Hsafe).
  exists q0; split; [exact Hinit|].
  intros k q m z Hsteps.
  pose proof (Hsafe (k + 1)%nat) as Hk.
  pose proof (safeN_dry_steps csem relay_dry_spec semax.genv_symb_injective relay_ge
                (cl_fun _) (cl_excl _) k _ _ Hsteps 1 w0 q0 init_mem z q m eq_refl eq_refl Hk) as H1.
  exact (safeN_not_stuck csem relay_dry_spec semax.genv_symb_injective relay_ge (cl_excl _) z q m H1).
Qed.

(* The dry witness type is inhabited only for the two scheduled primitives. *)
Lemma relay_dry_type_read_write : forall e (x : ext_spec_type relay_dry_spec e),
  Some (ext_link "read"%string, typesig2signature ([tint; tptr tvoid; tulong], tlong) cc_default)
    = ef_id_sig ext_link e \/
  Some (ext_link "write"%string, typesig2signature ([tint; tptr tvoid; tulong], tlong) cc_default)
    = ef_id_sig ext_link e.
Proof.
  intros e x; simpl in x.
  destruct (oi_eq_dec _ _) as [E1 | _]; [left; exact E1|].
  destruct (oi_eq_dec _ _) as [E2 | _]; [right; exact E2|].
  contradiction.
Qed.

End RelayTrace.

Check relay_concrete_trace.
Print Assumptions relay_concrete_trace.
Print Assumptions relay_dry_type_read_write.
