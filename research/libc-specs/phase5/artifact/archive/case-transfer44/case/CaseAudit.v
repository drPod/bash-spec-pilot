(* Assumption audit for the case-studies development (head_bytes, wc_lines). Prints the
   axioms each checked theorem depends on; expected: only the standard-library
   axioms VST / CompCert already use (see relay/README.md), no Admitted, no
   project axioms. Also restates the exact semax_body statement checked. *)
Require Import IOWorld CaseWorld CaseSpecs HeadBytesBody WcLinesBody.
Import IOW.

Print Assumptions HeadBytesBody.body_head_bytes.
Print Assumptions HeadBytesBody.cenv_ok.
Print Assumptions HeadBytesBody.buffer_split.
Print Assumptions WcLinesBody.body_wc_lines.
Print Assumptions WcLinesBody.buf_view.
Print Assumptions WcLinesBody.buf_split.
Print Assumptions WcLinesBody.cenv_ok.
Print Assumptions CaseWorld.head_true_prefix.
Print Assumptions CaseWorld.head_false_reports.
Print Assumptions CaseWorld.wc_true_counts.
Print Assumptions CaseWorld.wc_false_reports.
Print Assumptions CaseWorld.XWrite_effect.
Check HeadBytesBody.body_head_bytes.
Check CaseWorld.head_true_prefix.
Check CaseWorld.head_false_reports.
Check CaseWorld.wc_true_counts.
Check CaseWorld.wc_false_reports.
(* The funspec the body was checked against, fully expanded. *)
Print CaseSpecs.head_bytes_spec.
Print CaseSpecs.xwrite_stdout_spec.
Print CaseWorld.XWrite.
Print CaseWorld.stdout_put.
Print CaseWorld.HeadOutcome.
Print CaseSpecs.wc_lines_spec.
Print CaseSpecs.rawmemchr_spec.
Print CaseWorld.WcLines.
Check WcLinesBody.buf_view.
Check WcLinesBody.body_wc_lines.
