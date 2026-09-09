# Numbered file-descriptor table over `Redirect.v`

`../Redirect.v` stores files as `string -> list byte` with no numbered fds. This layer gates writes on a live table (fd 1 stdout, fd 3 save slot) and proves correspondence with `redirect_prim`.

Equivalence under fd-3-fresh: `fd_redirect_seq_matches_redirect_prim` (forward) and `fd_redirect_seq_adequate` (reverse). Writes are gated by `fs_fds f STDOUT_FD`, not by constructor. Restoration on any status, with concrete rc=1/rc=2 witnesses. Audit `shelllean24-fdaudit-v3rev1`: 14 statements closed. `results/receipts.json`.

Effect on a table, not `open`/`dup2`/`close` syscalls. Only fds 1 and 3. No shared mutable file offset. `None` means “not tracked as terminal in this fragment”, not OS-closed.

A first version carried `redirect_prim`’s postcondition in parallel (decorative table) and allowed clobbering fd 3; a second pass had a forward-only correspondence. Those defects are fixed in `FdTable.v` (header “REVISION 2026-09-08, second pass”).

## Model

- **`FdSaveBind path append`:** requires `fs_fds f OPEN_TARGET_FD = None` (`fd_savebind_requires_fresh_target`). On success: fd 3 := current fd 1; fd 1 := `Some (Ofd path append)`. Empty path: rc=1, untouched.
- **`FdWriteRestore a`:** destination decided by runtime match on fd 1; restore fd 1 from fd 3 and clear fd 3 for any exit status (`fd_write_restore_restores_on_any_status`).
- **`redirect_seq`:** `and_then` of save-bind then write-restore.

Witnesses: `fd_write_restore_unbound_witness` / `_bound_witness`; `fd_write_restore_gated_by_table`; unbound never touches the file; bound never extends the terminal. Error witnesses use `ReachExamples.read_error_outcome` (rc=1) and `zero_write_outcome` (rc=2).

Replay: `results/receipts.json`.
