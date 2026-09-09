(* Print Assumptions over every checked declaration in FdTable.v (v2,
   root-scope-review revision, second pass: reverse/adequacy direction +
   concrete error witnesses + corrected header). Expected: every line
   "Closed under the global context" -- no Admitted, Axiom, Parameter or
   Conjecture (also checked by grep, `FdTable.v` header). *)
Require Import FdTable.
Import ShellFd.

Print Assumptions ShellFd.fd_savebind_requires_fresh_target.
Print Assumptions ShellFd.fd_savebind_saves_and_binds.
Print Assumptions ShellFd.fd_write_restore_restores_on_any_status.
Print Assumptions ShellFd.fd_write_restore_unbound_never_touches_file.
Print Assumptions ShellFd.fd_write_restore_bound_never_extends_terminal.
Print Assumptions ShellFd.fd_write_restore_unbound_witness.
Print Assumptions ShellFd.fd_write_restore_bound_witness.
Print Assumptions ShellFd.fd_write_restore_bound_witness_restored.
Print Assumptions ShellFd.fd_write_restore_gated_by_table.
Print Assumptions ShellFd.exec_call_prim.
Print Assumptions ShellFd.fd_redirect_seq_matches_redirect_prim.
Print Assumptions ShellFd.fd_redirect_seq_adequate.
Print Assumptions ShellFd.fd_write_restore_bound_read_error_witness.
Print Assumptions ShellFd.fd_write_restore_bound_write_error_witness.
