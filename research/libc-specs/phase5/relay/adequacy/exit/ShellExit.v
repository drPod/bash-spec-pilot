(* Concrete C execution -> shell composition layer (adequacy-resume-3).

   Terminate.relay_exit_termination gives a concrete Clight execution of
   relay_exit.prog ending at exit(Vint (Int.repr status)) in world final with
   outcome w0 status final pending.  shell-bridge/Shell.v's relay primitive
   relay_prim is exactly that outcome predicate (plus the lost ledger), and
   Bridge.v maps the literal text "relay && mark" to relay_then_mark bang.

   This file states the composition: the status the concrete C execution hands
   to exit IS the exit status of the shell-level `relay` call in every shell
   state whose world is w0, and the parsed text "relay && mark" executes from
   that state with exactly that status (0 followed by mark's byte, or the
   nonzero status, as the and_then rules prescribe).  Nothing new is assumed:
   the shell layer's modelling assumptions (name binding, no pipes/fds/OS) and
   the environment model of Terminate.v are unchanged. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.semantics.
Require Import VST.veric.Clight_core.
Require Import relay_exit Protocol Reach SafetyExit ExitOutcome Terminate.
Require Import Shell Bridge.
Import RelayProtocol RelayReach.
Local Open Scope Z_scope.

Local Notation csem := (cl_core_sem (globalenv prog)).

Theorem relay_exit_shell_witness (w0 : world) (Hv : valid_world w0) (lost0 : list byte) :
  exists q0 k q m final status pending,
    semantics.initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
    ok_steps w0 k (q0, init_mem, w0) (q, m, final) /\
    semantics.at_external csem q m = Some (exit_ef, [Vint (Int.repr status)]) /\
    (* the shell-level relay call has exactly the concrete status *)
    ShellComposition.exec ShellComposition.relay_prim (ShellComposition.call ShellComposition.Relay)
      (ShellComposition.ShellState w0 lost0) status
      (ShellComposition.ShellState final (lost0 ++ pending)) /\
    (* and the literal text "relay && mark" runs from that state with that status *)
    exists c, ShellBridge.relay_command "relay && mark"%string = Some c /\
      ShellComposition.exec ShellComposition.relay_prim c (ShellComposition.ShellState w0 lost0) status
        (if status =? 0
         then ShellComposition.ShellState (ShellComposition.deliver final ShellComposition.bang) (lost0 ++ pending)
         else ShellComposition.ShellState final (lost0 ++ pending)).
Proof.
  destruct (relay_exit_termination w0 Hv)
    as (q0 & Hinit & k & q & m & final & status & pending & Hsteps & Hat & Hout).
  exists q0, k, q, m, final, status, pending.
  split; [exact Hinit|]. split; [exact Hsteps|]. split; [exact Hat|].
  assert (Hprim : ShellComposition.relay_prim ShellComposition.Relay
                    (ShellComposition.ShellState w0 lost0) status
                    (ShellComposition.ShellState final (lost0 ++ pending))).
  { simpl. exists pending. split; [exact Hout | reflexivity]. }
  split; [constructor; exact Hprim|].
  exists (ShellComposition.relay_then_mark ShellComposition.bang).
  split; [exact ShellBridge.relay_and_mark_text|].
  destruct (Z.eqb_spec status 0) as [E | N].
  - subst status. eapply ShellComposition.exec_and_zero; [constructor; exact Hprim|].
    constructor. simpl. repeat split.
  - eapply ShellComposition.exec_and_nonzero; [constructor; exact Hprim | exact N].
Qed.

Check relay_exit_shell_witness.
Print Assumptions relay_exit_shell_witness.
