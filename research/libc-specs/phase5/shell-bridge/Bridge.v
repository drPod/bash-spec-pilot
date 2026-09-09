(* Text -> checked AST -> relay-contract query, in one file.

   `relay_command` lexes and parses restricted shell text (Parse.v) and maps
   the command names "relay" and "mark" to the relay atoms of Shell.v. Any
   other name, and any unsupported syntax, yields None. The theorems below
   show that the literal text "relay && mark" produces exactly the command
   `relay_then_mark bang` and therefore inherits the status-sensitive query
   `relay_then_mark_query`, whose relay case is the relay_spec postcondition
   predicate `RelayReach.outcome`; and that the literal text "relay ; relay"
   produces the command with the pending-loss witness execution.

   The name binding ("relay" is the process whose contract is relay_spec,
   "mark" is a successful one-byte printf) is a modelling assumption, not a
   theorem about Bash command lookup. *)
From Coq Require Import List Ascii String ZArith.
From compcert Require Import Integers.
Require Import Protocol Reach ReachExamples Conservation Shell Parse.
Import ListNotations RelayProtocol RelayReach RelayConservation
  ShellComposition ShellText.
Local Open Scope Z_scope.

Module ShellBridge.

Fixpoint map_command {A B : Type} (f : A -> option B) (c : command A)
  : option (command B) :=
  match c with
  | call a => option_map (@call B) (f a)
  | seq x y =>
      match map_command f x, map_command f y with
      | Some x', Some y' => Some (seq x' y') | _, _ => None end
  | and_then x y =>
      match map_command f x, map_command f y with
      | Some x', Some y' => Some (and_then x' y') | _, _ => None end
  | or_else x y =>
      match map_command f x, map_command f y with
      | Some x', Some y' => Some (or_else x' y') | _, _ => None end
  end.

Definition atom_of (s : string) : option atom :=
  if String.eqb s "relay"%string then Some Relay
  else if String.eqb s "mark"%string then Some (Mark bang) else None.

Definition relay_command (text : string) : option (command atom) :=
  match parse_program text with
  | Some c => map_command atom_of c
  | None => None
  end.

Example relay_and_mark_text :
  relay_command "relay && mark"%string = Some (relay_then_mark bang).
Proof. vm_compute; reflexivity. Qed.

Example relay_seq_text :
  relay_command "relay ; relay"%string = Some (seq (call Relay) (call Relay)).
Proof. vm_compute; reflexivity. Qed.

Example relay_paren_text :
  relay_command "( relay && mark ) ; relay"%string =
    Some (seq (relay_then_mark bang) (call Relay)).
Proof. vm_compute; reflexivity. Qed.

Example unsupported_pipe_text : relay_command "relay | mark"%string = None.
Proof. vm_compute; reflexivity. Qed.

Example unsupported_redirect_text : relay_command "relay > out"%string = None.
Proof. vm_compute; reflexivity. Qed.

Example unknown_name_text : relay_command "cat && mark"%string = None.
Proof. vm_compute; reflexivity. Qed.

(* The parsed text inherits the query proved for every initial state. *)
Theorem relay_and_mark_text_query c s rc t :
  relay_command "relay && mark"%string = Some c ->
  exec relay_prim c s rc t ->
  (rc = 0 /\
    delivered (os t) = delivered (os s) ++ unread (os s) ++ [bang] /\
    unread (os t) = [] /\ lost t = lost s)
  \/
  (rc <> 0 /\ (rc = 1 \/ rc = 2) /\
    exists extra pending,
      delivered (os t) = delivered (os s) ++ extra /\
      lost t = lost s ++ pending /\
      extra ++ pending ++ unread (os t) = unread (os s) /\
      (rc = 1 -> pending = []) /\ (rc = 2 -> pending <> [])).
Proof.
  intros Hc He. rewrite relay_and_mark_text in Hc.
  injection Hc as Hc. subst c.
  exact (relay_then_mark_query bang s rc t He).
Qed.

(* The parsed text has the concrete late-error and success executions. *)
Theorem relay_and_mark_text_witnesses :
  exists c, relay_command "relay && mark"%string = Some c /\
    exec relay_prim c (ShellState input_a []) 1 (ShellState final_a []) /\
    exec relay_prim c (ShellState input_s []) 0
      (ShellState (deliver final_s bang) []) /\
    delivered final_a = delivered final_s.
Proof.
  exists (relay_then_mark bang).
  split; [exact relay_and_mark_text |].
  split; [exact late_error_exec |].
  split; [exact success_exec | exact same_relay_bytes].
Qed.

(* The parsed text "relay ; relay" has the pending-loss execution. *)
Theorem relay_seq_text_witness :
  exists c, relay_command "relay ; relay"%string = Some c /\
    exec relay_prim c (ShellState input_b []) 0
      (ShellState final_b2 (suffix 2 abcd)).
Proof.
  exists (seq (call Relay) (call Relay)).
  split; [exact relay_seq_text | exact pending_lost_then_fresh_relay].
Qed.

(* And every accepted text is a derivation of the grammar relation. *)
Theorem relay_command_derives text c :
  relay_command text = Some c ->
  exists toks c0, lex_string text = Some toks /\ body_derives toks c0 /\
    map_command atom_of c0 = Some c.
Proof.
  unfold relay_command. intro H.
  destruct (parse_program text) as [c0 |] eqn:E; [| discriminate].
  destruct (parse_program_sound _ _ E) as [toks [Hl Hd]].
  exists toks, c0. auto.
Qed.

End ShellBridge.
