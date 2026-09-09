(* Whole-program dry (CompCert-memory) safety of the exit-wrapper program
   relay_exit.prog, obtained from MainExit.prog_correct (semax_prog) through
   VST 2.15's whole_program_sequential_safety_ext with the dry specification
   of DryExit.v.  Same construction as ../Safety.v for relay_main.prog.

   For every n, the concrete Clight core semantics started at main with
   Genv.init_mem prog and initial world w0 is dry-safe for n steps under
   exit_dry_spec w0: every external call the execution reaches satisfies the
   dry precondition -- for exit, that the argument is Vint (Int.repr status)
   for a status with outcome w0 status z pending in the current world z
   (ExitOutcome.v draws that consequence).  The environment's scheduled
   response to read/write is assumed at each call; exit is assumed not to
   return (dry post False).

   Jsub is VST's library premise about inlined external calls (CompCert
   builtins declared in prog_defs, never called by this program); it stays an
   explicit quantified hypothesis of the theorem, exactly as in ../Safety.v. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.SequentialClight.
Require Import VST.veric.Clight_core.
Require Import dry_mem_lemmas.
Require Import relay_exit Protocol Reach MainExit DryExit.
Import RelayProtocol RelayReach.

(* Genv.init_mem prog exists: prog has 60 definitions (block count below is an upper bound; unused allocations are harmless). *)
Definition init_mem_exists : { m | Genv.init_mem prog = Some m }.
Proof.
  unfold Genv.init_mem; simpl.
Ltac alloc_block m n := match n with
  | O => idtac
  | S ?n' => let m' := fresh "m" in let Hm' := fresh "Hm" in
    destruct (dry_mem_lemmas.drop_alloc m) as [m' Hm']; alloc_block m' n'
  end.
  alloc_block Mem.empty 64%nat;
  eexists; repeat match goal with H : ?a = _ |- match ?a with Some m' => _ | None => None end = _ => rewrite H end;
  reflexivity.
Qed.

Definition init_mem := proj1_sig init_mem_exists.

Definition main_block_exists : {b | Genv.find_symbol (Genv.globalenv prog) (AST.prog_main prog) = Some b}.
Proof.
  eexists; simpl.
  unfold Genv.find_symbol; simpl; reflexivity.
Qed.

Definition main_block := proj1_sig main_block_exists.

Section Safety.

Hypothesis Jsub : forall ef se lv m t v m' (EFI : ef_inline ef = true) m1
       (EFC : Events.external_call ef se lv m t v m'), juicy_mem.mem_sub m m1 ->
       exists m1' (EFC1 : Events.external_call ef se lv m1 t v m1'),
         juicy_mem.mem_sub m' m1' /\
         proj1_sig (inline_external_call_mem_events _ _ _ _ _ _ _ EFI EFC1) =
         proj1_sig (inline_external_call_mem_events _ _ _ _ _ _ _ EFI EFC).

Theorem relay_exit_dry_safety (w0 : world) (Hv : valid_world w0) :
  exists q,
  semantics.initial_core (cl_core_sem (globalenv prog)) 0 init_mem q init_mem
    (Vptr main_block Ptrofs.zero) [] /\
  forall n, @step_lemmas.dry_safeN _ _ _ _ semax.genv_symb_injective (cl_core_sem (globalenv prog))
             (exit_dry_spec w0) {| genv_genv := Genv.globalenv prog; genv_cenv := prog_comp_env prog |} n
             w0 q init_mem.
Proof.
  edestruct (@whole_program_sequential_safety_ext _ (Espec w0)) with (V := Vprog) as (b & q & Hb & Hq & Hsafe).
  - repeat intro; simpl. apply I.
  - apply Jsub.
  - apply add_funspecs_frame.
  - apply exit_juicy_dry_specs.
  - apply exit_dry_spec_mem.
  - intros; apply I.
  - apply CSHL_Sound.semax_prog_sound, (prog_correct w0 Hv).
  - apply (proj2_sig init_mem_exists).
  - exists q.
    rewrite (proj2_sig main_block_exists) in Hb; inv Hb.
    auto.
Qed.

End Safety.

Check relay_exit_dry_safety.
Print Assumptions relay_exit_dry_safety.
