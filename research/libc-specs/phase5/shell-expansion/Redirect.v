(* Output redirection (`>`, `>>`) over the ACTUAL relay contract's atoms
   (Shell.v `relay_prim`, unchanged), reusing its own byte-conservation fact
   (`relay_step_shape`, imported) rather than inventing new write semantics.

   Scope: ONE trailing redirection on a single atom (`relay > out`,
   `relay >> out`), matching the fragment's existing "no arguments, no
   compounding beyond the grammar in Shell.v" spirit. What is modelled:

   - File-descriptor binding: for the duration of the redirected atom's own
     execution, its writes are diverted from the ambient, terminal-visible
     `delivered` stream into a NAMED file's content (`file_store`, a total
     map from name to current bytes). This is a real fd retarget, not a
     cosmetic rename: `redirect_truncate_observations` below shows the
     terminal-visible stream is UNCHANGED (`os_reset`) after the redirected
     atom runs, while the file gained exactly the bytes the atom produced.
   - Restoration: the fd retarget is scoped to the one atom it is attached
     to. `os_reset` puts the pre-command `delivered` value back once the
     atom finishes; nothing here threads the redirect through a later
     command (there is no later command inside a single `ratom`), so
     restoration is the definition, not a separate theorem to forget.
   - Truncate vs append: decided ONCE, at open time, by the boolean flag.
     `>` truncates (the file's prior content, if any, is dropped before the
     new bytes are appended); `>>` appends after whatever content the file
     already had. Both then simply append the atom's output; the difference
     is entirely in what "opened" starts as. `redirect_append_preserves_
     prior_content` / `redirect_truncate_discards_prior_content` are the
     same relay run against the same pre-existing file, differing only in
     the flag, with different observed file contents.
   - Error case: an empty filename fails to open (status 1, nothing runs,
     no state changes) rather than being silently accepted as a valid name.
   - What is NOT modelled: real fd numbers/dup2, more than one redirection
     per atom, redirecting a compound command (only a single atom), input
     redirection `<`, `2>`, and any interaction between a file's existence
     and the OS (this `file_store` is a pure map, not backed by any real
     filesystem call). *)
From Coq Require Import List String ZArith.
From compcert Require Import Integers.
Require Import Protocol Reach ReachExamples Conservation Shell.
Import ListNotations RelayProtocol RelayReach RelayConservation ShellComposition.
Local Open Scope Z_scope.

Module ShellRedirect.

Definition file_store := string -> list byte.
Definition empty_files : file_store := fun _ => [].
Definition update_file (path : string) (content : list byte) (fs : file_store) : file_store :=
  fun p => if String.eqb p path then content else fs p.

Record rstate := RState { rs_shell : shell_state; rs_files : file_store }.

Inductive ratom := Direct (a : atom) | Redirect (append : bool) (path : string) (a : atom).

(* Put the pre-command `delivered` value back; keep everything else (the
   unread input, the read/write schedules, the call counters) as the atom's
   own execution advanced them. This IS the fd restoration. *)
Definition os_reset (t : world) (old_delivered : list byte) : world :=
  World (unread t) old_delivered (reads t) (writes t) (read_calls t) (write_calls t).

Lemma relay_prim_delivered_extra a s rc t :
  relay_prim a s rc t -> exists extra, delivered (os t) = delivered (os s) ++ extra.
Proof.
  destruct a as [| b]; simpl; intro H.
  - destruct (relay_step_shape s rc t H) as [extra [pending [Hd _]]]. exists extra; exact Hd.
  - destruct H as [_ [Ht _]]. exists [b]. rewrite Ht. unfold deliver; simpl. reflexivity.
Qed.

Definition redirect_prim : primitive ratom rstate := fun ra r rc r' =>
  match ra with
  | Direct a => relay_prim a (rs_shell r) rc (rs_shell r') /\ rs_files r' = rs_files r
  | Redirect append path a =>
      (path = ""%string /\ rc = 1 /\ r' = r)
      \/
      (path <> ""%string /\
       exists t extra,
         relay_prim a (rs_shell r) rc t /\
         delivered (os t) = delivered (os (rs_shell r)) ++ extra /\
         rs_files r' =
           update_file path ((if append then rs_files r path else []) ++ extra) (rs_files r) /\
         rs_shell r' = ShellState (os_reset (os t) (delivered (os (rs_shell r)))) (lost t))
  end.

(* Every redirected atom's underlying execution really did happen: the
   file-store bookkeeping is layered on top of, not instead of, `relay_prim`. *)
Theorem redirect_underlying_exec append path a r rc r' :
  redirect_prim (Redirect append path a) r rc r' -> path <> ""%string ->
  exists t, relay_prim a (rs_shell r) rc t.
Proof.
  intros [[Hp _] | [_ [t [extra [Ha _]]]]] Hpath.
  - contradiction (Hpath Hp).
  - exists t; exact Ha.
Qed.

(* Open failure never runs the underlying atom: the state is untouched. *)
Theorem redirect_open_failure append a r r' :
  redirect_prim (Redirect append ""%string a) r 1 r' -> r' = r.
Proof.
  intros [[_ [_ Heq]] | [Hne _]]; [exact Heq | contradiction (Hne eq_refl)].
Qed.

(* ---- Concrete witnesses, reusing the relay worker's own fixtures
   (`input_s`/`final_s`/`success_outcome`, Shell.v) unchanged. ---- *)

Definition redirect_truncate_final :=
  RState (ShellState (os_reset final_s []) []) (update_file "out"%string abc empty_files).

Example redirect_truncate_witness :
  redirect_prim (Redirect false "out"%string Relay)
    (RState (ShellState input_s []) empty_files) 0 redirect_truncate_final.
Proof.
  right. split; [discriminate |].
  exists (ShellState final_s []), abc.
  split; [| split; [| split]].
  - exists []. split; [exact success_outcome | reflexivity].
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
Qed.

(* The file gained exactly the relay's output; the terminal-visible stream
   (what a later, unredirected command would see) is unchanged, i.e. the fd
   really was retargeted and then restored, not merely duplicated. *)
Example redirect_truncate_observations :
  rs_files redirect_truncate_final "out"%string = abc /\
  delivered (os (rs_shell redirect_truncate_final)) = [].
Proof. vm_compute. split; reflexivity. Qed.

Definition preexisting_files := update_file "out"%string (map Byte.repr [120; 121]) empty_files.

Definition redirect_append_final :=
  RState (ShellState (os_reset final_s []) [])
    (update_file "out"%string (map Byte.repr [120; 121] ++ abc) preexisting_files).

Example redirect_append_witness :
  redirect_prim (Redirect true "out"%string Relay)
    (RState (ShellState input_s []) preexisting_files) 0 redirect_append_final.
Proof.
  right. split; [discriminate |].
  exists (ShellState final_s []), abc.
  split; [| split; [| split]].
  - exists []. split; [exact success_outcome | reflexivity].
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
Qed.

Definition redirect_truncate_over_existing_final :=
  RState (ShellState (os_reset final_s []) [])
    (update_file "out"%string abc preexisting_files).

Example redirect_truncate_witness_over_existing :
  redirect_prim (Redirect false "out"%string Relay)
    (RState (ShellState input_s []) preexisting_files) 0 redirect_truncate_over_existing_final.
Proof.
  right. split; [discriminate |].
  exists (ShellState final_s []), abc.
  split; [| split; [| split]].
  - exists []. split; [exact success_outcome | reflexivity].
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
Qed.

(* Same relay run, same pre-existing file content, two different flags: `>>`
   keeps the old "xy" ahead of the new bytes, `>` drops it. This is the
   truncate/append distinction, not just a naming difference. *)
Example redirect_append_vs_truncate :
  rs_files redirect_append_final "out"%string = map Byte.repr [120; 121] ++ abc /\
  rs_files redirect_truncate_over_existing_final "out"%string = abc.
Proof. vm_compute. split; reflexivity. Qed.

(* Sequencing: `Direct` (an ordinary, unredirected atom) after a `Redirect`
   sees the restored terminal stream, not the file. Redirection does not
   leak into whatever runs next -- there is no "next" state left pointing at
   the file once the redirected atom returns. *)
Definition redirect_then_direct_final :=
  RState (ShellState (deliver (os (rs_shell redirect_truncate_final)) bang) [])
    (rs_files redirect_truncate_final).

Example redirect_then_direct_sees_restored_stream :
  redirect_prim (Direct (Mark bang)) redirect_truncate_final 0 redirect_then_direct_final /\
  delivered (os (rs_shell redirect_then_direct_final)) = [bang] /\
  rs_files redirect_then_direct_final "out"%string = abc.
Proof. repeat split; vm_compute; reflexivity. Qed.

Example redirect_empty_path_rejected :
  redirect_prim (Redirect false ""%string Relay) (RState (ShellState input_s []) empty_files) 1
    (RState (ShellState input_s []) empty_files).
Proof. left. repeat split. Qed.

(* ---- `ratom`/`redirect_prim` is a plain instance of Shell.v's generic
   `command`/`exec` (unchanged, universally quantified over the atom and
   state types), so its own `command_refines`/`query_transfer` already cover
   any composition of `Direct`/`Redirect` atoms; nothing new is proved here,
   only applied. One worked example: `relay ; (mark > log)` -- the second
   command's output is redirected, so the SEQUENCE's final terminal-visible
   stream is exactly the first command's, even though a second command ran
   after it and actually wrote a byte (just not to the terminal). *)
Definition command3 := command ratom.
Definition exec3 := exec redirect_prim.
Definition redirect_command_refines := @command_refines ratom.
Definition redirect_query_transfer := @query_transfer ratom.

Example redirect_within_seq :
  exec redirect_prim
    (seq (call (Direct Relay)) (call (Redirect false "log"%string (Mark bang))))
    (RState (ShellState input_s []) empty_files) 0
    (RState (ShellState final_s []) (update_file "log"%string [bang] empty_files)).
Proof.
  apply exec_seq with (t := RState (ShellState final_s []) empty_files) (rc1 := 0).
  - apply exec_call. split; [exists []; split; [exact success_outcome | reflexivity] | reflexivity].
  - apply exec_call. right. split; [discriminate |].
    exists (ShellState (deliver final_s bang) []), [bang].
    repeat split; vm_compute; reflexivity.
Qed.

End ShellRedirect.
