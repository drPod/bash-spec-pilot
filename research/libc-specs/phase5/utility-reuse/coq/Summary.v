(* Modular summary of the utility-reuse wrapper chain.

   Each translation unit is verified separately against funspecs that are
   *definitions parametric in identifiers* (IOSpecs.v). This file checks the
   composition premise of that modular design without doing VST whole-program
   (VSU) linking:

   1. the identifiers clightgen assigned in the four translation units agree,
      so the funspec instance proved for a wrapper body is literally the funspec
      instance assumed at its call site in the caller's Gprog;
   2. the four body theorems are bundled into one statement so that a single
      Print Assumptions (Audit.v) shows the axiom set of the whole chain.

   What remains assumed (as funspecs inside the Gprogs, not theorems): the leaf
   libc contracts read_spec / write_spec (the trust boundary), and the coreutils
   externals quotearg_spec, error_spec, write_error_spec. Linking the TUs into
   one program, the entry wrapper simple_cat_entry, GNU cat's CLI/binary, and
   host syscall behaviour are outside this file. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld IOSpecs.
Require safe_read safe_write full_write cat_fragment.
Require SafeReadBody SafeWriteBody FullWriteBody CatBody.
Import IOW.

(* ---- 1. identifier agreement across translation units ---- *)

Lemma errno_ident_agree :
  safe_read._errno = cat_fragment._errno /\
  safe_write._errno = cat_fragment._errno /\
  full_write._errno = cat_fragment._errno.
Proof. repeat split; reflexivity. Qed.

Lemma safe_read_ident_agree : safe_read._safe_read = cat_fragment._safe_read.
Proof. reflexivity. Qed.

Lemma safe_write_ident_agree : safe_write._safe_write = full_write._safe_write.
Proof. reflexivity. Qed.

Lemma full_write_ident_agree : full_write._full_write = cat_fragment._full_write.
Proof. reflexivity. Qed.

(* Consequently the proved funspec instances equal the assumed ones. *)
Lemma safe_read_spec_agree :
  safe_read_spec safe_read._errno safe_read._safe_read =
  safe_read_spec cat_fragment._errno cat_fragment._safe_read.
Proof. reflexivity. Qed.

Lemma safe_write_spec_agree :
  safe_write_spec safe_write._errno safe_write._safe_write =
  safe_write_spec full_write._errno full_write._safe_write.
Proof. reflexivity. Qed.

Lemma full_write_spec_agree :
  full_write_spec full_write._errno full_write._full_write =
  full_write_spec cat_fragment._errno cat_fragment._full_write.
Proof. reflexivity. Qed.

(* ---- 2. the checked wrapper chain, bundled ---- *)

Theorem wrapper_chain :
  semax_body SafeReadBody.Vprog SafeReadBody.Gprog safe_read.f_safe_read
    (safe_read_spec safe_read._errno safe_read._safe_read) /\
  semax_body SafeWriteBody.Vprog SafeWriteBody.Gprog safe_write.f_safe_write
    (safe_write_spec safe_write._errno safe_write._safe_write) /\
  semax_body FullWriteBody.Vprog FullWriteBody.Gprog full_write.f_full_write
    (full_write_spec full_write._errno full_write._full_write) /\
  semax_body CatBody.Vprog CatBody.Gprog cat_fragment.f_simple_cat
    (simple_cat_spec cat_fragment._errno cat_fragment._simple_cat
       cat_fragment._input_desc cat_fragment._infile).
Proof.
  exact (conj SafeReadBody.body_safe_read
        (conj SafeWriteBody.body_safe_write
        (conj FullWriteBody.body_full_write CatBody.body_simple_cat))).
Qed.

(* Functional consequences already proved of the protocol relations named in
   the postconditions (IOWorld.v), restated here so the chain's end-to-end
   reading is visible next to the body theorems. *)
Check cat_true_copies_all.
Check cat_false_reports.
Check FullWrite_complete.
