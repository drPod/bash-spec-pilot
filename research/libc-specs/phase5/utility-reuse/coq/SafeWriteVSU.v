(* VSU component for the generated gnulib safe_write (safe_write.v):
   imports the leaf write(2) contract (the assumed libc trust boundary) and
   exports the generalized safe_write contract proved in SafeWriteBody.v.
   See SafeReadVSU.v for the GP convention. *)
Require Import VST.floyd.proofauto.
Require Import VST.floyd.VSU.
Require Import VST.veric.NullExtension.
Require Import IOWorld IOSpecs.
Require Import safe_write.
Require Import SafeWriteBody.
Import IOW.

Definition SafeWrite_imported_specs : funspecs := [write_spec _errno _write].
Definition SafeWrite_ASI : funspecs := [safe_write_spec _errno _safe_write].

Definition SafeWrite_p := ltac:(QPprog prog).
Definition SafeWrite_GP (gv : globals) : mpred := InitGPred (Vardefs SafeWrite_p) gv.

Definition SafeWriteVSU : @VSU NullExtension.Espec
      nil SafeWrite_imported_specs SafeWrite_p SafeWrite_ASI SafeWrite_GP.
Proof.
  mkVSU prog SafeWrite_ASI.
  + solve_SF_internal SafeWriteBody.body_safe_write.
Qed.
