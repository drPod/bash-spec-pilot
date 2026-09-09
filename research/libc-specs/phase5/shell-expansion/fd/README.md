# A real, numbered file-descriptor table over the checked `Redirect.v` model

Date: 2026-09-08. Worker: Claude CLI (`shell-lean-final-24`). Checked by Coq 8.20.1 in the
shared `phase5-vst` container (CompCert 3.15, VST 2.15) through `../../run_vst.py`. Nothing
upstream is touched: `../Redirect.v` (and everything it needs -- `relay/`, `shell-bridge/`) is
read-only here, only freshly recompiled in this worker's own private container directory so no
stale `.vo` is reused across workers. This worker owns `shell-expansion/fd/` and
`integration/lean-final/` only.

**Revision (same day, two passes):** this is v2, second pass. A root-scope review at 11:53Z
(`results/receipts.json`'s `prior_v1_review_and_response`) found v1's fd table decorative -- it
carried the SAME postcondition `redirect_prim` already had, in parallel, rather than actually
deciding where bytes went, and silently allowed clobbering a pre-existing fd 3; fixed in the first
v2 pass. A SECOND review at 12:18Z (`results/receipts.json`'s `second_review_and_response`) then
found the correspondence theorem was forward-only (mislabelled "equivalent" in the header), the
SAVE/BIND description was backwards (fd 3 saves the OLD value, not the new target), the "nothing
else is ever open" scope claim overclaimed, and no CONCRETE error-restoration witness existed
(only the general theorem). All four fixed in this pass: `fd_redirect_seq_adequate` (the reverse
direction, making the correspondence a genuine equivalence under the fd-3-fresh precondition), a
corrected header, and two concrete rc=1/rc=2 restoration witnesses. See `FdTable.v`'s own header
"REVISION 2026-09-08, second pass" for the full account.

## Why this directory

`../Redirect.v`'s own `file_store` is a pure `string -> list byte` map: a redirected atom's
writes are diverted to a NAMED file, with no numbered file descriptor anywhere in the model
(stated explicitly in its own header, "NOT modelled: real fd numbers/dup2"). The scope-audit
correction (`pi-reviews/scope-audit-correction-23/NEXT.md`, item R) leaves that sentence
**required/open**. This directory adds a real, numbered fd layer whose behavior is actually
GATED by live fd-table state, proved to correspond to `Redirect.v`'s own relation.

## What "real numbered fd" means here

Matching a real shell's own save/redirect/restore idiom around a simple command (`dup2(1, 3)` to
save; `open(path,...)` + `dup2(newfd, 1)` to bind; ... run the command, writing through fd 1 ...;
`dup2(3, 1)` to restore; `close(3)`):

- fd 1 (`STDOUT_FD`) is always the process's stdout descriptor; fd 3 (`OPEN_TARGET_FD`) is a SAVE
  SLOT this fragment's model uses while a redirect is active -- it holds the OLD fd-1 value, not
  the new target (the target goes directly into fd 1, see below).
- **`FdSaveBind path append`** (one atom): requires `fs_fds f OPEN_TARGET_FD = None` -- a real
  precondition (`fd_savebind_requires_fresh_target`): if fd 3 is already occupied, the relation
  is simply FALSE, not "silently overwrite it". This says nothing about any OTHER descriptor.
  On success: fd 3 := fd 1's CURRENT value, read live off the table (a genuine `dup2`-from-source
  read, not a passed-in literal -- the SAVE half); fd 1 := `Some (Ofd path append)` (the BIND
  half, `fd_savebind_saves_and_binds`). Empty path is the original open failure: rc = 1, nothing
  touched at all.
- **`FdWriteRestore a`** (one atom, the ONLY write-capable atom): whether the underlying
  `relay`/`mark` atom's bytes land on the terminal or in the bound file is decided by an ACTUAL
  RUNTIME MATCH on `fs_fds f STDOUT_FD` inside `fd_write_restore_prim`'s own definition -- not by
  which atom constructor was used. When bound, restoration (fd 1 := fd 3's current value -- the
  saved value -- fd 3 := `None`) happens as part of the SAME atomic step, for **any** exit status
  of the underlying write (`fd_write_restore_restores_on_any_status`, with concrete rc=1/rc=2
  witnesses below, not only the general statement).
- **`redirect_seq path append a := and_then (call (FdSaveBind path append)) (call (FdWriteRestore
  a))`**: `and_then`'s own semantics (`Shell.v`, unchanged) give the right control flow for free
  -- skip the write and report rc=1 if opening failed, otherwise report the write's own rc.

**What is explicitly NOT modelled or claimed**: real `open`/`dup2`/`close` syscalls (their
save/bind/write/restore EFFECT on a table is modelled, not the kernel calls), any descriptor
other than 1 and 3 (neither open nor closed -- simply outside this model's vocabulary; fd 3 being
free says nothing about fd 4, fd 0, etc.), more than one simultaneously open redirect, fd
inheritance across `exec`, signals, any OS-level fd-table resource limit, a real shared mutable
file offset between aliased descriptors (the `ofd` record is a value, not a shared cell), or that
fd 3 specifically is what real Bash would allocate (no such claim is made) -- the same "one atom,
one trailing redirect" fragment boundary `Redirect.v` itself already has. `None` in this table
means "this fragment's own record of fd 1 as pointing at the modelled terminal / not tracked",
not "the OS considers this fd closed" -- there is no OS here to consider anything.

## The gating is real, not a relabelled postcondition

The reviewer's core demand: prove the SAME atom constructor produces different outcomes purely
as a function of live table state, and that a write before bind / after restore genuinely fails
to reach the file (not merely asserted).

- `fd_write_restore_unbound_witness` / `fd_write_restore_bound_witness`: the identical relay run
  (`Shell.v`'s own `input_s`/`final_s`/`success_outcome`), once from an unbound table, once from
  a table bound to `"out"` -- `fd_write_restore_gated_by_table` reads the resulting file stores
  back: untouched (`[]`) in the first, exactly `abc` in the second.
- `fd_write_restore_unbound_never_touches_file`: for ANY atom, ANY exit status, whenever fd 1 is
  unbound, the file store is provably unchanged.
- `fd_write_restore_bound_never_extends_terminal`: for ANY atom, ANY exit status, whenever fd 1
  is bound, the terminal stream is provably unchanged (the write is diverted, not duplicated).

## Correspondence to the existing `Redirect.v` relation -- an equivalence, both directions

`fd_redirect_seq_matches_redirect_prim` (forward): for ANY execution of `redirect_seq path append
a` through `fd_prim` (i.e. any real two-step `Exec` derivation: `FdSaveBind` then
`FdWriteRestore`), the projection onto `fs_r` is EXACTLY one step of `redirect_prim (Redirect
append path a)`. Derived BY case analysis on the real `Exec` derivation (`Shell.v`'s
`exec_and_zero`/`exec_and_nonzero`, unchanged), not asserted by construction.

`fd_redirect_seq_adequate` (reverse): for ANY `redirect_prim (Redirect append path a)` outcome,
and any fd table with fd 3 free beforehand, there EXISTS a matching `fd_prim`/`Exec` execution of
`redirect_seq` realizing it. This is the direction the forward theorem alone does not give --
without it, "every `fd_prim` run corresponds to a `redirect_prim` run" says nothing about whether
every `redirect_prim` run is *reachable* that way. Together, the two directions are a genuine
equivalence UNDER the fd-3-fresh precondition -- exactly `FdSaveBind`'s own requirement, not an
extra assumption; neither theorem is stated as unconditional.

## Restoration on permitted error exits -- general theorem plus concrete witnesses

`fd_write_restore_restores_on_any_status` is proved for universally quantified `rc`. Concrete
witnesses instantiate it at ACTUAL errors, not only a general statement, over `ReachExamples.v`'s
own fixtures (nothing invented): `fd_write_restore_bound_read_error_witness` (rc = 1,
`ReachExamples.read_error_outcome` -- the underlying atom never reads anything) and
`fd_write_restore_bound_write_error_witness` (rc = 2, `ReachExamples.zero_write_outcome` -- a
genuine short/zero-write failure) both show fd 1 and fd 3 restored to their pre-redirect values
(`None`) despite the underlying write failing. `fd_write_restore_bound_witness`/
`fd_write_restore_bound_witness_restored` cover the success (rc = 0) case the same way.

## What this does not establish

Everything `../Redirect.v`'s own README already disclaims (real fd numbers beyond 1/3, more than
one redirection per atom, redirecting a compound command, `<`/`2>`, any real filesystem call)
plus: no claim that fd 3 specifically is what a real kernel's `open()` would return (it is a save
slot in THIS fragment's minimal scope, not even the target -- see above); no `dup2`/`open`/`close`
syscall semantics, only their save/bind/restore/close EFFECT on a table; no shared mutable file
offset between two descriptors naming "the same" `ofd` (a real `dup2` alias would share position
state across writers -- not exercised here since only one descriptor, fd 1, ever writes); no claim
about any fd other than 1 and 3.

## Assumptions

`FdTableAudit.v` (receipt `shelllean24-fdaudit-v3rev1`, `results/receipts.json`) runs
`Print Assumptions` on all 14 theorems/lemmas/examples in `FdTable.v`: every line reads "Closed
under the global context". No axiom, no `Admitted`, no `Parameter`, no `Conjecture` (grep-checked
too). Everything is `Qed`-closed against `Redirect.v`'s/`Shell.v`'s own already-frozen,
already-audited facts (`redirect_prim`, `redirect_truncate_final`, `redirect_truncate_witness`,
`success_outcome`, `relay_prim`, `relay_prim_delivered_extra`, `ReachExamples.read_error_outcome`,
`ReachExamples.zero_write_outcome`) plus one small reusable helper proved here
(`exec_call_prim`, a generic `exec`-inversion lemma for any primitive/atom/state).

## Replay

See `results/receipts.json` for exact commands, receipts, and the full review-to-response
record.
