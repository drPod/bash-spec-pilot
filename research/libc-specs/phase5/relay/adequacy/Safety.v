(* Whole-program dry (CompCert-memory) safety of relay_main.prog, obtained from
   Main.prog_correct (semax_prog) through VST 2.15's
   whole_program_sequential_safety_ext with the dry specification of Dry.v.

   What this is: for every n, the concrete Clight core semantics
   (cl_core_sem) started at main with the initial memory Genv.init_mem prog and
   the initial world w0 is dry-safe for n steps under relay_dry_spec.  Every
   external call the concrete execution reaches satisfies the dry precondition
   (read(0, buf, 32) on a writable 32-byte range / write(1, buf+off, len) whose
   len bytes are actually in memory), and the environment's scheduled response
   (read32/write_block effect on memory and world) is assumed at each call.

   What this is NOT: the dry exit predicate is True (forced, see Dry.v), so this
   theorem says nothing about the value returned by main.  The returned-status
   functional theorem over the concrete execution remains missing. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.SequentialClight.
Require Import VST.veric.Clight_core.
Require Import dry_mem_lemmas.
Require Import relay_main Protocol Reach Main Dry.
Import RelayProtocol RelayReach.

(* Genv.init_mem prog exists: prog has 59 function definitions (block count below is an upper bound; unused allocations are harmless). *)
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

(* Library soundness premise of whole_program_sequential_safety_ext (VST 2.15,
   veric/SequentialClight.v): inlined external calls (CompCert builtins, which
   are declared in prog_defs even though relay_main never calls one) commute
   with memory extension.  VST's own io examples assume it as an Axiom
   (progs64/verif_io_mem.v) or Hypothesis (progs64/io_combine.v).  Here it is a
   Section hypothesis: an explicit, undischarged premise of the theorem below,
   not a project axiom and not claimed proved. *)
Hypothesis Jsub : forall ef se lv m t v m' (EFI : ef_inline ef = true) m1
       (EFC : Events.external_call ef se lv m t v m'), juicy_mem.mem_sub m m1 ->
       exists m1' (EFC1 : Events.external_call ef se lv m1 t v m1'),
         juicy_mem.mem_sub m' m1' /\
         proj1_sig (inline_external_call_mem_events _ _ _ _ _ _ _ EFI EFC1) =
         proj1_sig (inline_external_call_mem_events _ _ _ _ _ _ _ EFI EFC).

Theorem relay_dry_safety (w0 : world) (Hv : valid_world w0) :
  exists q,
  semantics.initial_core (cl_core_sem (globalenv prog)) 0 init_mem q init_mem
    (Vptr main_block Ptrofs.zero) [] /\
  forall n, @step_lemmas.dry_safeN _ _ _ _ semax.genv_symb_injective (cl_core_sem (globalenv prog))
             relay_dry_spec {| genv_genv := Genv.globalenv prog; genv_cenv := prog_comp_env prog |} n
             w0 q init_mem.
Proof.
  edestruct whole_program_sequential_safety_ext with (V := Vprog) as (b & q & Hb & Hq & Hsafe).
  - repeat intro; simpl. apply I.
  - apply Jsub.
  - apply add_funspecs_frame.
  - apply juicy_dry_specs.
  - apply dry_spec_mem.
  - intros; apply I.
  - apply CSHL_Sound.semax_prog_sound, (prog_correct w0 Hv).
  - apply (proj2_sig init_mem_exists).
  - exists q.
    rewrite (proj2_sig main_block_exists) in Hb; inv Hb.
    auto.
Qed.

End Safety.

Check relay_dry_safety.
Print Assumptions relay_dry_safety.
