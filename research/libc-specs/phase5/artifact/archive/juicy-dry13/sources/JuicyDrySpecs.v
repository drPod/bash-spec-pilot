(* The full juicy_dry_ext_spec record for the utility contracts: the actual
   IOSpecs read_spec/write_spec external specification IOW_Espec
   (JuicyDry.v), the concrete CompCert-memory specification iow_dry_spec,
   and the witness projection iow_dessicate, related by VST's own
   VST.veric.SequentialClight.juicy_dry_ext_spec (PRE-preservation,
   POST-preservation, exit equivalence). This is the utility-contract
   analogue of relay/adequacy/Dry.v's juicy_dry_specs: the three conjuncts
   are JuicyPre.iow_juicy_dry_pre, JuicyPost.iow_juicy_dry_post and
   JuicyDry.dry_spec_exit; together with JuicyDry.dry_spec_mem
   (ext_spec_mem_evolve) these are exactly the hypotheses VST's
   whole-program adequacy theorem consumes for an external specification. *)
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
Require Import dry_mem_lemmas.
Require Import relay Protocol Reach.
Require Import IOWorld IOSpecs.
Require Import Specialize MemAdequacy DryPost JuicyDry ErrnoBridge ErrnoLoad.
Require Import JuicyPre PostLemmas PostLemmas2 PostLemmas3 JuicyPost.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

Section IOWJuicyDrySpecs.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_ext_spec' := (iow_ext_spec errno_id ext_link).
Notation iow_dry_spec' := (iow_dry_spec errno_id ext_link).
Notation iow_dessicate' := (iow_dessicate errno_id ext_link).

Theorem iow_juicy_dry_specs :
  juicy_dry_ext_spec IOW.world iow_ext_spec' iow_dry_spec' iow_dessicate'.
Proof.
  split; [|split].
  - exact (iow_juicy_dry_pre errno_id ext_link).
  - exact (iow_juicy_dry_post errno_id ext_link).
  - exact (dry_spec_exit errno_id ext_link).
Qed.

(* Restated alongside so one Print Assumptions covers the whole package. *)
Theorem iow_dry_spec_mem_evolve : ext_spec_mem_evolve _ iow_dry_spec'.
Proof. exact (dry_spec_mem errno_id ext_link). Qed.

End IOWJuicyDrySpecs.
