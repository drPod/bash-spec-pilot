(* VST VSU linking of the four utility-reuse translation units into one
   checked component (NEXT.md item 1). Not whole-program: there is no
   `main`; the leaf syscalls (read/write) and the coreutils externals
   (quotearg_n_style_colon, error, write_error) remain unresolved imports of
   the final linked VSU, i.e. the trust boundary, exactly as stated in
   RESULTS.md's scope section. What this file adds beyond Summary.v's
   identifier/funspec-agreement check: the four TUs' underlying Clight
   programs are actually merged by VST/CompCert's QPlink_progs (inside
   linkVSUs), so this is real linking of the pinned source's compiled ASTs,
   not just a statement that the specs would agree if linked. *)
Require Import VST.floyd.proofauto.
Require Import VST.floyd.VSU.
Require Import VST.veric.NullExtension.
Require Import SafeReadVSU.
Require Import SafeWriteVSU.
Require Import FullWriteVSU.
Require Import CatFragmentVSU.

(* safe_write.c and full_write.c: full_write's safe_write_spec import is
   satisfied by safe_write's export. Result still imports write_spec
   (the leaf syscall, unresolved). *)
Definition SafeWrite_FullWrite_VSU :=
  ltac:(linkVSUs SafeWriteVSU.SafeWriteVSU FullWriteVSU.FullWriteVSU).

(* + safe_read.c: no shared dependency with the above pair, but combining
   keeps every wrapper TU compiled Clight program merged into one QP
   program before cat_fragment is added. Result imports read_spec and
   write_spec. *)
Definition Wrappers_VSU :=
  ltac:(linkVSUs SafeReadVSU.SafeReadVSU SafeWrite_FullWrite_VSU).

(* + cat_fragment.c: its safe_read_spec / full_write_spec imports are
   satisfied by Wrappers_VSU's exports. quotearg_spec / error_spec /
   write_error_spec (coreutils externals, never implemented in any of our
   four TUs) and read_spec / write_spec (the libc trust boundary) remain
   as the final linked VSU's imports -- this is the actual, explicit,
   checked assumption set of the whole-linked-TU chain. *)
Definition AllVSU :=
  ltac:(linkVSUs Wrappers_VSU CatFragmentVSU.CatFragmentVSU).

(* The point of this file: AllVSU's existence and its Coq type (visible via
   Print) IS the checked whole-program-modulo-leaves linking theorem. The
   Check below fails to compile unless VST/CompCert actually accepted the
   QPlink_progs merge of all four TUs' generated Clight ASTs and every
   ASI/import identifier match Summary.v already proved by reflexivity. *)
Check AllVSU.
Print Assumptions AllVSU.
