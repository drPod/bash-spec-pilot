(* VSU component for the generated gnulib full_write (full_write.v):
   imports safe_write_spec (from SafeWriteVSU.v, the leaf wrapper it calls in
   a retry loop) and exports the generalized full_write contract proved in
   FullWriteBody.v. See SafeReadVSU.v for the GP convention. *)
Require Import VST.floyd.proofauto.
Require Import VST.floyd.VSU.
Require Import VST.veric.NullExtension.
Require Import IOWorld IOSpecs.
Require Import full_write.
Require Import FullWriteBody.
Import IOW.

Definition FullWrite_imported_specs : funspecs := [safe_write_spec _errno _safe_write].
Definition FullWrite_ASI : funspecs := [full_write_spec _errno _full_write].

Definition FullWrite_p := ltac:(QPprog prog).
Definition FullWrite_GP (gv : globals) : mpred := InitGPred (Vardefs FullWrite_p) gv.

Definition FullWriteVSU : @VSU NullExtension.Espec
      nil FullWrite_imported_specs FullWrite_p FullWrite_ASI FullWrite_GP.
Proof.
  mkVSU prog FullWrite_ASI.
  + solve_SF_internal FullWriteBody.body_full_write.
Qed.
