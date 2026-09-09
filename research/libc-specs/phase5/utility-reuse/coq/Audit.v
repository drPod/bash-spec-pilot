(* Assumption audit for the utility-reuse development. Prints the axioms each
   checked theorem depends on; expected: only the standard-library axioms VST /
   CompCert already use (see relay/README.md), no Admitted, no project axioms. *)
Require Import IOWorld IOSpecs SafeReadBody SafeWriteBody FullWriteBody CatBody Summary.
Import IOW.

Print Assumptions IOW.cat_true_copies_all.
Print Assumptions IOW.cat_false_reports.
Print Assumptions IOW.FullWrite_complete.
Print Assumptions SafeReadBody.body_safe_read.
Print Assumptions SafeWriteBody.body_safe_write.
Print Assumptions FullWriteBody.body_full_write.
Print Assumptions CatBody.body_simple_cat.
Print Assumptions Summary.wrapper_chain.
Print Assumptions Summary.safe_read_spec_agree.
Print Assumptions Summary.safe_write_spec_agree.
Print Assumptions Summary.full_write_spec_agree.
Print Assumptions SafeReadBody.cenv_ok.
Print Assumptions SafeWriteBody.cenv_ok.
Print Assumptions FullWriteBody.cenv_ok.
Print Assumptions CatBody.cenv_ok.
Check SafeReadBody.body_safe_read.
Check SafeWriteBody.body_safe_write.
Check FullWriteBody.body_full_write.
Check CatBody.body_simple_cat.
Check Summary.wrapper_chain.
