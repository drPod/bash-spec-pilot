(* VSU component for the generated gnulib safe_read (safe_read.v): imports
   the leaf read(2) contract (the assumed libc trust boundary) and exports
   the generalized safe_read contract already proved in SafeReadBody.v.
   First step toward VSU-linking the four wrapper-chain translation units
   (NEXT.md item 1, utility-reuse).

   GP (the VSU's persistent global-resource predicate) is taken to be
   exactly InitGPred (Vardefs p): the ownership the TU's own global
   variables need at program start, no more and no less. This is the
   uniform choice used across all four component files so it composes
   under linkVSUs without hand-picking a GP per TU. *)
Require Import VST.floyd.proofauto.
Require Import VST.floyd.VSU.
Require Import VST.veric.NullExtension.
Require Import IOWorld IOSpecs.
Require Import safe_read.
Require Import SafeReadBody.
Import IOW.

Definition SafeRead_imported_specs : funspecs := [read_spec _errno _read].
Definition SafeRead_ASI : funspecs := [safe_read_spec _errno _safe_read].

Definition SafeRead_p := ltac:(QPprog prog).
Definition SafeRead_GP (gv : globals) : mpred := InitGPred (Vardefs SafeRead_p) gv.

Definition SafeReadVSU : @VSU NullExtension.Espec
      nil SafeRead_imported_specs SafeRead_p SafeRead_ASI SafeRead_GP.
Proof.
  mkVSU prog SafeRead_ASI.
  + solve_SF_internal SafeReadBody.body_safe_read.
Qed.
