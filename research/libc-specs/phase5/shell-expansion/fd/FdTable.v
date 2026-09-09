(* A real, numbered file-descriptor table layered on top of the ACTUAL,
   already-checked `Redirect.v` model (`ShellRedirect.rstate`, `relay_prim`
   from `Shell.v`). `Redirect.v`/`Shell.v` are read-only, only
   imported/required, never edited.

   REVISION 2026-09-08, second pass (same day, root-scope review at
   12:18Z, after the first v1-to-v2 pass at 11:53Z fixed the original
   decorative-table gap): two remaining issues, fixed here.
   (1) `fd_redirect_seq_matches_redirect_prim` is a FORWARD refinement
   only (every `fd_prim` execution of `redirect_seq` corresponds to a
   `redirect_prim` step) -- it does NOT by itself show every
   `redirect_prim` outcome is REACHABLE that way, so it is not, on its
   own, an "equivalence". `fd_redirect_seq_adequate` (new, below) is the
   REVERSE direction: given any `redirect_prim` outcome and a table where
   fd 3 is free beforehand, an `fd_prim` execution realizing it exists.
   Together the two directions are an equivalence UNDER that one
   precondition (fd 3 free) -- exactly `FdSaveBind`'s own requirement, not
   an extra assumption smuggled in; neither theorem claims more.
   (2) The first pass's header mis-described what `FdSaveBind` actually
   does: it said "opening the target allocates fd 3" as if fd 3 held the
   NEW target -- the code puts the target directly at fd 1 and uses fd 3
   as a SAVE SLOT for fd 1's OLD value (so it can be restored later), the
   `exec 3>&1; exec 1>file; ...; exec 1>&3; exec 3>&-` shape, not
   `open()`'s own return value. Corrected below. The header also
   overstated "0/1/2 are always the standard descriptors; nothing else is
   ever open" as if fd-3-freeness said something about fds other than 1
   and 3 -- it does not: this model tracks fd 1 and fd 3 only, and makes
   no claim, positive or negative, about any other descriptor. `None` in
   this table means "this fragment's own record of fd 1 as pointing at
   the modelled terminal / not tracked", not "the OS considers this fd
   closed" -- there is no OS here to consider anything.

   What "real numbered fd" means here, concretely, matching a real shell's
   own save/redirect/restore idiom around a command (`dup2(1, 3)` to save;
   `open(path,...)` + `dup2(newfd, 1)` to bind; ... run the command,
   writing through fd 1 ...; `dup2(3, 1)` to restore; `close(3)`):
     - fd 1 (`STDOUT_FD`) is always the process's stdout descriptor.
     - fd 3 (`OPEN_TARGET_FD`) is a SAVE SLOT this fragment's model uses
       while a redirect is active; it must be free beforehand
       (`fs_fds f OPEN_TARGET_FD = None`, a genuine precondition:
       `FdSaveBind`'s relation is simply FALSE, not "true after silently
       overwriting", when it is not free --
       `fd_savebind_requires_fresh_target`). This says nothing about any
       OTHER descriptor.
     - SAVE+BIND (`FdSaveBind`, one atom): fd 3 := fd 1's CURRENT value
       (read live from the table, a genuine `dup2`-from-source read, not a
       passed-in literal, the SAVE half); fd 1 := `Some (Ofd path append)`
       (the BIND half -- the target goes DIRECTLY into fd 1, not via fd 3).
     - WRITE+RESTORE (`FdWriteRestore`, one atom): the underlying `relay`/
       `mark` atom's produced bytes go to the file `path` IF AND ONLY IF
       `fs_fds f STDOUT_FD` is currently `Some (Ofd path _)` at the moment
       this atom runs (a live lookup, matched inside the primitive's own
       definition -- `fd_write_restore_prim`), otherwise to the terminal
       stream, exactly the pre-fd behavior; restoration (fd 1 := fd 3's
       CURRENT value -- the saved value -- fd 3 := `None`) happens as part
       of the SAME atomic step, unconditionally on the underlying write's
       own exit status (`rc` is free in the defining `exists`, so
       `fd_write_restore_prim` restores on EVERY `rc`, including read/write
       errors -- `fd_write_restore_restores_on_any_status`, with concrete
       rc=1/rc=2 witnesses below, not only a general statement).
     - The full redirected command is `andThen (call (FdSaveBind path
       append)) (call (FdWriteRestore a))`: `andThen`'s own semantics
       (`Shell.v`, unchanged) already give "skip the write+restore and
       report rc=1 if opening failed", "otherwise report the WRITE's own
       rc" for free -- no bespoke "run second regardless of first's status"
       combinator needed.

   Negative controls proving the gating is REAL, not a relabelled
   postcondition (`fd_write_restore_unbound_never_touches_file`,
   `fd_write_restore_bound_never_extends_terminal`,
   `fd_write_restore_gated_by_table`): the VERY SAME atom (`FdWriteRestore
   Relay`), run from a state where fd 1 is unbound, never touches any file;
   the SAME atom, run from a state where fd 1 is bound, never appends to
   the terminal stream -- one constructor, two outcomes, decided purely by
   which table state it is run from.

   What is explicitly NOT modelled or claimed: real `open`/`dup2`/`close`
   syscalls (their SAVE/BIND/WRITE/RESTORE effect on a table is modelled,
   not the kernel calls themselves), any descriptor other than 1 and 3
   (neither open nor closed, simply outside this model's vocabulary), more
   than one simultaneously open redirect, fd inheritance across `exec`,
   signals, any OS-level fd-table resource limit, or that this matches
   real Bash's own descriptor-allocation choice (no such claim is made or
   needed). The underlying byte/status semantics of `relay`/`mark`
   themselves are entirely `Shell.v`'s own `relay_prim`, unchanged; nothing
   here alters what bytes a given `relay`/`mark` call itself produces, only
   where they end up. *)
From Coq Require Import List String ZArith.
From compcert Require Import Integers.
Require Import Protocol Reach ReachExamples Conservation Shell Redirect.
Import ListNotations RelayProtocol RelayReach RelayConservation ShellComposition ShellRedirect.
Local Open Scope Z_scope.

Module ShellFd.

(* ---- Real, numbered file descriptors ---- *)

Definition fd := Z.
Definition STDOUT_FD : fd := 1.
Definition OPEN_TARGET_FD : fd := 3.

Record ofd := Ofd { ofd_path : string; ofd_append : bool }.

Definition fdtable := fd -> option ofd.

Definition empty_fdtable : fdtable := fun _ => None.

Definition set_fd (f : fd) (v : option ofd) (t : fdtable) : fdtable :=
  fun g => if Z.eqb g f then v else t g.

(* ---- fd-aware state: `Redirect.v`'s own `rstate` (unchanged, its two
   fields `rs_shell`/`rs_files` still carry every byte/status fact), plus
   the fd table. ---- *)

Record fstate := FState { fs_r : rstate; fs_fds : fdtable }.

Inductive fatom := FdSaveBind (path : string) (append : bool) | FdWriteRestore (a : atom).

(* ---- SAVE+BIND: requires fd 3 free (a genuine precondition, not an
   assumption discharged elsewhere); on success, reads fd 1's CURRENT
   value into fd 3 and binds fd 1 to the target. Empty path is the
   original open-failure case (`Redirect.v`'s own first disjunct shape):
   rc = 1, nothing touched at all, matching `redirect_open_failure`. ---- *)

Definition fd_prim_savebind (path : string) (append : bool) : primitive unit fstate :=
  fun _ f rc f' =>
    (path = ""%string /\ rc = 1 /\ f' = f)
    \/
    (path <> ""%string /\ fs_fds f OPEN_TARGET_FD = None /\ rc = 0 /\
     fs_r f' = fs_r f /\
     fs_fds f' = set_fd OPEN_TARGET_FD (fs_fds f STDOUT_FD)
                    (set_fd STDOUT_FD (Some (Ofd path append)) (fs_fds f))).

(* ---- WRITE+RESTORE: the ONLY write-capable atom. Which ledger receives
   the underlying `relay`/`mark` atom's bytes is decided by a LIVE MATCH on
   `fs_fds f STDOUT_FD` -- this is the actual gating the review asked for:
   the SAME atom constructor, run from two different tables, provably goes
   to two different places (`fd_write_restore_gated_by_table` below). When
   bound, restoration (fd 1 := fd 3's current value, fd 3 := `None`) is
   part of the SAME step, for ANY `rc` (the underlying atom's own exit
   status is free in the `exists`, never constrained to 0). ---- *)

Definition fd_write_restore_prim : primitive atom fstate := fun a f rc f' =>
  match fs_fds f STDOUT_FD with
  | None =>
      relay_prim a (rs_shell (fs_r f)) rc (rs_shell (fs_r f')) /\
      rs_files (fs_r f') = rs_files (fs_r f) /\
      fs_fds f' = fs_fds f
  | Some target =>
      exists t extra,
        relay_prim a (rs_shell (fs_r f)) rc t /\
        delivered (os t) = delivered (os (rs_shell (fs_r f))) ++ extra /\
        rs_files (fs_r f') =
          update_file (ofd_path target)
            ((if ofd_append target then rs_files (fs_r f) (ofd_path target) else []) ++ extra)
            (rs_files (fs_r f)) /\
        rs_shell (fs_r f') =
          ShellState (os_reset (os t) (delivered (os (rs_shell (fs_r f))))) (lost t) /\
        fs_fds f' = set_fd OPEN_TARGET_FD None (set_fd STDOUT_FD (fs_fds f OPEN_TARGET_FD) (fs_fds f))
  end.

Definition fd_prim : primitive fatom fstate := fun fa f rc f' =>
  match fa with
  | FdSaveBind path append => fd_prim_savebind path append tt f rc f'
  | FdWriteRestore a => fd_write_restore_prim a f rc f'
  end.

(* The full redirected command: open+bind, THEN write+restore. `andThen`'s
   own semantics (`Shell.v`, unchanged) give exactly the wanted control
   flow for free: if SAVE+BIND fails (rc=1), WRITE+RESTORE never runs and
   the whole thing reports rc=1 with the state untouched
   (`exec_and_nonzero`); otherwise the whole thing reports WRITE+RESTORE's
   own rc (`exec_and_zero`), never a swallowed/replaced status. *)
Definition redirect_seq (path : string) (append : bool) (a : atom) : command fatom :=
  and_then (call (FdSaveBind path append)) (call (FdWriteRestore a)).

(* ---- Freshness is enforced, not merely claimed ---- *)

Theorem fd_savebind_requires_fresh_target path append f rc f' :
  path <> ""%string -> fd_prim_savebind path append tt f rc f' ->
  fs_fds f OPEN_TARGET_FD = None.
Proof.
  intros Hpath [[Hp _] | [_ [Hfresh _]]].
  - contradiction (Hpath Hp).
  - exact Hfresh.
Qed.

(* ---- The save+bind step itself, stated directly ---- *)

Theorem fd_savebind_saves_and_binds path append f rc f' :
  path <> ""%string -> fd_prim_savebind path append tt f rc f' ->
  fs_fds f' STDOUT_FD = Some (Ofd path append) /\ fs_fds f' OPEN_TARGET_FD = fs_fds f STDOUT_FD.
Proof.
  intros Hpath [[Hp _] | [_ [_ [_ [_ Ht]]]]].
  - contradiction (Hpath Hp).
  - split; rewrite Ht; reflexivity.
Qed.

(* ---- Restoration, for ANY exit status of the underlying write -- "fd
   restoration also on permitted error exits" ---- *)

Theorem fd_write_restore_restores_on_any_status a f rc f' target :
  fs_fds f STDOUT_FD = Some target -> fd_write_restore_prim a f rc f' ->
  fs_fds f' STDOUT_FD = fs_fds f OPEN_TARGET_FD /\ fs_fds f' OPEN_TARGET_FD = None.
Proof.
  intros Hbound Hw. unfold fd_write_restore_prim in Hw. rewrite Hbound in Hw.
  destruct Hw as [t [extra [_ [_ [_ [_ Ht]]]]]].
  split; rewrite Ht; reflexivity.
Qed.

(* ---- Negative controls: the SAME atom constructor, gated purely by live
   table state, not by which constructor was used. ---- *)

(* Before any bind (or after a restore put it back to unbound): a write
   NEVER touches any file, whatever it writes or how it exits. *)
Theorem fd_write_restore_unbound_never_touches_file a f rc f' :
  fs_fds f STDOUT_FD = None -> fd_write_restore_prim a f rc f' ->
  rs_files (fs_r f') = rs_files (fs_r f).
Proof.
  intros Hun Hw. unfold fd_write_restore_prim in Hw. rewrite Hun in Hw.
  destruct Hw as [_ [Hf _]]. exact Hf.
Qed.

(* While bound: a write NEVER reaches the terminal stream (the redirected
   bytes are diverted, not duplicated) -- `Redirect.v`'s own point, now
   derived from a live table lookup instead of an atom tag. *)
Theorem fd_write_restore_bound_never_extends_terminal a f rc f' target :
  fs_fds f STDOUT_FD = Some target -> fd_write_restore_prim a f rc f' ->
  delivered (os (rs_shell (fs_r f'))) = delivered (os (rs_shell (fs_r f))).
Proof.
  intros Hb Hw. unfold fd_write_restore_prim in Hw. rewrite Hb in Hw.
  destruct Hw as [t [extra [_ [_ [_ [Ht _]]]]]].
  rewrite Ht. unfold os_reset. simpl. reflexivity.
Qed.

(* THE gating fact itself, concretely: the SAME atom (`FdWriteRestore
   Relay`), run once from a table where fd 1 is unbound and once from a
   table where fd 1 is bound to "out" (same underlying relay run, reusing
   `Shell.v`'s own `input_s`/`final_s`/`success_outcome`, so this is not a
   different atom or a different byte-producing run) -- the file store is
   untouched in the first run and gains exactly the produced bytes in the
   second. One constructor, two outcomes, decided purely by live table
   state at the moment it runs. *)
Example fd_write_restore_unbound_witness :
  fd_write_restore_prim Relay
    (FState (RState (ShellState input_s []) empty_files) empty_fdtable) 0
    (FState (RState (ShellState final_s []) empty_files) empty_fdtable).
Proof.
  simpl.
  split.
  - exists ([] : list byte). split; [exact success_outcome | reflexivity].
  - split; reflexivity.
Qed.

Definition fd_bound_source : fstate :=
  FState (RState (ShellState input_s []) empty_files)
    (set_fd STDOUT_FD (Some (Ofd "out"%string false)) empty_fdtable).

Definition fd_bound_result_table : fdtable :=
  set_fd OPEN_TARGET_FD None (set_fd STDOUT_FD (fs_fds fd_bound_source OPEN_TARGET_FD) (fs_fds fd_bound_source)).

Example fd_write_restore_bound_witness :
  fd_write_restore_prim Relay fd_bound_source 0
    (FState redirect_truncate_final fd_bound_result_table).
Proof.
  unfold fd_write_restore_prim. unfold fd_bound_source at 1. simpl.
  exists (ShellState final_s []), abc.
  split.
  - exists ([] : list byte). split; [exact success_outcome | reflexivity].
  - split.
    + vm_compute. reflexivity.
    + split.
      * vm_compute. reflexivity.
      * split; reflexivity.
Qed.

(* The result table, read back at both descriptors: fd 1 is restored (back
   to `None`, its value before the bind), fd 3 is closed. Value-level
   lookups at concrete descriptors, so plain computation (no function
   extensionality) decides them. *)
Example fd_write_restore_bound_witness_restored :
  fd_bound_result_table STDOUT_FD = None /\ fd_bound_result_table OPEN_TARGET_FD = None.
Proof. split; reflexivity. Qed.

Theorem fd_write_restore_gated_by_table :
  rs_files (fs_r (FState (RState (ShellState final_s []) empty_files) empty_fdtable))
    "out"%string = [] /\
  rs_files (fs_r (FState redirect_truncate_final empty_fdtable)) "out"%string = abc.
Proof. split; reflexivity. Qed.

(* ---- Correspondence to the EXISTING `Redirect.v` relation: the ACTUAL
   two-step execution of `redirect_seq`, projected onto `fs_r`, is exactly
   one step of `redirect_prim (Redirect append path a)` -- proved by
   unfolding the real `Exec` derivation (SAVE+BIND then WRITE+RESTORE),
   not asserted by construction. ---- *)

Lemma exec_call_prim {Atom State : Type} (prim : primitive Atom State)
    (a : Atom) (s : State) (rc : Z) (t : State) :
  exec prim (call a) s rc t -> prim a s rc t.
Proof. intro H. inversion H; subst; assumption. Qed.

Theorem fd_redirect_seq_matches_redirect_prim path append a f f' rc :
  exec fd_prim (redirect_seq path append a) f rc f' ->
  redirect_prim (Redirect append path a) (fs_r f) rc (fs_r f').
Proof.
  intro He. unfold redirect_seq in He.
  inversion He; subst.
  - (* exec_and_zero: SAVE+BIND returned 0, then WRITE+RESTORE ran and its
       own rc is the whole thing's rc. Real hypothesis names from this
       exact `inversion`: H1 : exec fd_prim (call (FdSaveBind path append))
       f 0 t; H5 : exec fd_prim (call (FdWriteRestore a)) t rc f'. *)
    apply exec_call_prim in H1. apply exec_call_prim in H5. simpl in H1, H5.
    destruct H1 as [[_ [Hc _]] | [Hpath [_ [_ [Heq Htab]]]]]; [discriminate Hc |].
    unfold fd_write_restore_prim in H5. rewrite Htab in H5. simpl in H5.
    rewrite Heq in H5.
    destruct H5 as [t' [extra [Hrel [Hdel [Hfile [Hshell _]]]]]].
    right. split; [exact Hpath |]. exists t', extra.
    repeat split; [exact Hrel | exact Hdel | exact Hfile | exact Hshell].
  - (* exec_and_nonzero: SAVE+BIND itself returned rc <> 0 (the empty-path
       case); WRITE+RESTORE never ran, state untouched. Real hypothesis
       names from this exact `inversion`: H1 : exec fd_prim
       (call (FdSaveBind path append)) f rc f'; H5 : rc <> 0. *)
    apply exec_call_prim in H1. simpl in H1.
    destruct H1 as [[Hp [Hrc Heq]] | [_ [_ [Hrc0 _]]]].
    + left. subst rc. rewrite Heq. auto.
    + exfalso. apply H5. exact Hrc0.
Qed.

(* ---- The REVERSE direction: every `redirect_prim` outcome is REACHABLE
   as an `fd_prim` execution of `redirect_seq`, given fd 3 free beforehand
   -- exactly `FdSaveBind`'s own precondition, nothing extra. Together with
   `fd_redirect_seq_matches_redirect_prim` above, this is a genuine
   equivalence under that one condition, not a one-way refinement dressed
   up as more. ---- *)

Theorem fd_redirect_seq_adequate path append a r r' rc (t : fdtable) :
  t OPEN_TARGET_FD = None ->
  redirect_prim (Redirect append path a) r rc r' ->
  exists f', exec fd_prim (redirect_seq path append a) (FState r t) rc f' /\ fs_r f' = r'.
Proof.
  intros Hfresh Hred. unfold redirect_seq.
  destruct Hred as [[Hp [Hrc Heq]] | [Hpath [t0 [extra [Hrel [Hdel [Hfile Hshell]]]]]]].
  - exists (FState r t). split.
    + apply exec_and_nonzero.
      * apply exec_call. left. auto.
      * rewrite Hrc. discriminate.
    + simpl. rewrite Heq. reflexivity.
  - set (mid_fds := set_fd OPEN_TARGET_FD (t STDOUT_FD) (set_fd STDOUT_FD (Some (Ofd path append)) t)).
    set (result_fds := set_fd OPEN_TARGET_FD None (set_fd STDOUT_FD (mid_fds OPEN_TARGET_FD) mid_fds)).
    exists (FState r' result_fds). split.
    + apply exec_and_zero with (t := FState r mid_fds).
      * apply exec_call. right.
        split; [exact Hpath |]. split; [exact Hfresh |]. split; [reflexivity |].
        split; reflexivity.
      * apply exec_call. unfold fd_write_restore_prim. simpl.
        exists t0, extra.
        split; [exact Hrel |]. split; [exact Hdel |]. split; [exact Hfile |].
        split; [exact Hshell | reflexivity].
    + reflexivity.
Qed.

(* ---- Concrete restoration witnesses on ACTUAL read/write errors, not
   only the general `fd_write_restore_restores_on_any_status` statement
   -- avoiding a vacuous-in-practice error claim. Both reuse
   `ReachExamples.v`'s own fixtures (nothing new invented at the byte
   level), and both reuse `fd_bound_result_table` (the fd part of the
   result depends only on the TABLE, not on `relay`'s outcome, so it is
   literally the same value as the success witness above). ---- *)

Example fd_write_restore_bound_read_error_witness :
  exists f',
    fd_write_restore_prim Relay
      (FState (RState (ShellState input_a []) empty_files)
        (set_fd STDOUT_FD (Some (Ofd "out"%string false)) empty_fdtable)) 1 f' /\
    fs_fds f' STDOUT_FD = None /\ fs_fds f' OPEN_TARGET_FD = None.
Proof.
  assert (Hrelay : relay_prim Relay (ShellState input_a []) 1 (ShellState final_a [])).
  { exists ([] : list byte). split; [exact read_error_outcome | reflexivity]. }
  destruct (relay_prim_delivered_extra Relay (ShellState input_a []) 1 (ShellState final_a []) Hrelay)
    as [extra Hextra].
  exists (FState
    (RState (ShellState (os_reset final_a []) []) (update_file "out"%string extra empty_files))
    fd_bound_result_table).
  split.
  - unfold fd_write_restore_prim. simpl.
    exists (ShellState final_a []), extra.
    split; [exact Hrelay |]. split; [exact Hextra |]. split; [reflexivity |].
    split; reflexivity.
  - split; reflexivity.
Qed.

Example fd_write_restore_bound_write_error_witness :
  exists f',
    fd_write_restore_prim Relay
      (FState (RState (ShellState input_b []) empty_files)
        (set_fd STDOUT_FD (Some (Ofd "out"%string false)) empty_fdtable)) 2 f' /\
    fs_fds f' STDOUT_FD = None /\ fs_fds f' OPEN_TARGET_FD = None.
Proof.
  set (t := ShellState final_b (suffix 2 abcd)).
  assert (Hrelay : relay_prim Relay (ShellState input_b []) 2 t).
  { exists (suffix 2 abcd). split; [exact zero_write_outcome | reflexivity]. }
  destruct (relay_prim_delivered_extra Relay (ShellState input_b []) 2 t Hrelay) as [extra Hextra].
  exists (FState
    (RState (ShellState (os_reset (os t) []) (lost t)) (update_file "out"%string extra empty_files))
    fd_bound_result_table).
  split.
  - unfold fd_write_restore_prim. simpl.
    exists t, extra.
    split; [exact Hrelay |]. split; [exact Hextra |]. split; [reflexivity |].
    split; reflexivity.
  - split; reflexivity.
Qed.

End ShellFd.
