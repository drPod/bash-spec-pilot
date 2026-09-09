(* Universal C-execution -> shell composition (universal-relay-4).

   ShellExit.relay_exit_shell_witness composes ONE concrete execution with the
   shell layer.  With UniversalExit.relay_exit_universal the composition holds
   for ALL executions: for every valid w0 there is one status (the protocol
   outcome, unique by Determinism.outcome_unique) such that every dry_steps
   execution of relay_exit.prog is bounded by N, is at the exit call with
   exactly that status at length N, reaches an exit call ONLY with that status
   and only at length N, and that status is the exit status of the shell-level
   `relay` call from every shell state with world w0; the parsed text
   "relay && mark" executes from that state with that status.  Nothing new is
   assumed: same environment model, same shell modelling assumptions (name
   binding, no pipes/fds/OS) as ShellExit.v. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.semantics.
Require Import VST.veric.Clight_core.
Require Import Trace.
Require Import relay_exit Protocol Reach Determinism SafetyExit DryExit ExitOutcome Terminate UniversalExit.
Require Import Shell Bridge.
Import RelayProtocol RelayReach.
Local Open Scope Z_scope.

Local Notation csem := (cl_core_sem (globalenv prog)).
Local Notation exit_ge :=
  (Clight.genv_genv {| Clight.genv_genv := Genv.globalenv prog; Clight.genv_cenv := prog_comp_env prog |}).
Local Notation dstep w0 := (dry_step csem (exit_dry_spec w0) semax.genv_symb_injective exit_ge).
Local Notation dsteps w0 := (dry_steps csem (exit_dry_spec w0) semax.genv_symb_injective exit_ge).

Theorem relay_exit_shell_universal (w0 : world) (Hv : valid_world w0) (lost0 : list byte) :
  exists q0 N status final pending,
    semantics.initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
    (* the shell-level relay call has exactly this status ... *)
    ShellComposition.exec ShellComposition.relay_prim (ShellComposition.call ShellComposition.Relay)
      (ShellComposition.ShellState w0 lost0) status
      (ShellComposition.ShellState final (lost0 ++ pending)) /\
    (* ... and the literal text "relay && mark" runs from that state with it *)
    (exists c, ShellBridge.relay_command "relay && mark"%string = Some c /\
      ShellComposition.exec ShellComposition.relay_prim c (ShellComposition.ShellState w0 lost0) status
        (if status =? 0
         then ShellComposition.ShellState (ShellComposition.deliver final ShellComposition.bang) (lost0 ++ pending)
         else ShellComposition.ShellState final (lost0 ++ pending))) /\
    (* and EVERY C execution hands exactly this status to exit, after exactly N steps *)
    forall k q m z, dsteps w0 k (q0, init_mem, w0) (q, m, z) ->
      (k <= N)%nat /\
      ((k < N)%nat -> exists s', dstep w0 (q, m, z) s') /\
      (k = N -> semantics.at_external csem q m = Some (exit_ef, [Vint (Int.repr status)]) /\ z = final) /\
      (forall args, semantics.at_external csem q m = Some (exit_ef, args) ->
         k = N /\ args = [Vint (Int.repr status)] /\ z = final) /\
      (forall s', dstep w0 (q, m, z) s' -> (k < N)%nat).
Proof.
  destruct (relay_exit_universal w0 Hv) as (q0 & N & status & final & pending & Hinit & Hout & Hall).
  exists q0, N, status, final, pending.
  split; [exact Hinit|].
  assert (Hprim : ShellComposition.relay_prim ShellComposition.Relay
                    (ShellComposition.ShellState w0 lost0) status
                    (ShellComposition.ShellState final (lost0 ++ pending))).
  { simpl. exists pending. split; [exact Hout | reflexivity]. }
  split; [constructor; exact Hprim|].
  split.
  { exists (ShellComposition.relay_then_mark ShellComposition.bang).
    split; [exact ShellBridge.relay_and_mark_text|].
    destruct (Z.eqb_spec status 0) as [E | NE].
    - subst status. eapply ShellComposition.exec_and_zero; [constructor; exact Hprim|].
      constructor. simpl. repeat split.
    - eapply ShellComposition.exec_and_nonzero; [constructor; exact Hprim | exact NE]. }
  intros k q m z Hd.
  destruct (Hall k q m z Hd) as (B1 & _ & B3 & B4 & B5 & B6).
  split; [exact B1|]. split; [exact B3|]. split; [exact B4|]. split; [| exact B6].
  intros args Hat.
  pose proof (B5 _ _ Hat eq_refl) as EN.
  destruct (B4 EN) as (Hat' & Ez).
  rewrite Hat in Hat'. inv Hat'.
  auto.
Qed.

Check relay_exit_shell_universal.
Print Assumptions relay_exit_shell_universal.
