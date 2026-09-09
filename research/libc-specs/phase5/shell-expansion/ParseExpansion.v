(* A bounded, EXECUTABLE text frontend for the pipe/redirect atoms of
   Bridge2.v/Redirect.v. Not a change to `shell-bridge/Parse.v`/`Lex.v`
   (frozen, unchanged, still exactly the old fragment): a new lexer/parser,
   reusing their character-classification helpers (`ShellText.is_blank`,
   `.is_ident_char`, `.take_ident`, `.reserved`, imported unchanged) since
   the token type itself needs new constructors.

   HONESTLY SCOPED: this is an EXECUTABLE parser, checked against the
   literal texts below by `vm_compute` (evidence for those texts only), with
   NO soundness proof analogous to `Parse.v`'s `parse_program_sound`. That
   proof is the next slice (NEXT.md), not attempted here under the
   90-minute budget. Fragment: one identifier, or exactly two identifiers
   joined by `|` (matching `PipeRR`'s two-stage scope, Bridge2.v), with an
   OPTIONAL trailing `>`/`>>` IDENT redirect target on a BARE identifier only
   (redirecting a pipe result is a stated, deferred generalization: `ratom`,
   Redirect.v, wraps a plain `atom`, not `atom2`; see NEXT.md item 2).
   Precedence: `|` binds inside a single unit; `>`/`>>` attaches to that
   whole unit; composing units with `;`/`&&`/`||`/parens is not attempted
   here (would need `ratom`/`atom2` unified into one type first, also left
   to NEXT.md) so this frontend covers exactly one top-level unit. *)
From Coq Require Import List Ascii String ZArith Bool.
From compcert Require Import Integers.
Require Import Protocol Reach ReachExamples Conservation Shell Parse Bridge Pipeline Bridge2 Redirect.
Import ListNotations RelayProtocol RelayReach RelayConservation ShellComposition ShellText
  ShellBridge ShellPipeline ShellPipeBridge ShellRedirect.
Local Open Scope Z_scope.
Local Open Scope string_scope.

Module ShellExpansionText.

Inductive token2 :=
| U2Ident (name : string) | U2Pipe | U2Gt | U2GtGt.

Fixpoint lex2 (fuel : nat) (cs : list ascii) : option (list token2) :=
  match fuel with
  | O => None
  | S n =>
    match cs with
    | [] => Some []
    | c :: rest =>
      if is_blank c then lex2 n rest
      else if is_char 124 c (* | *) then
        match rest with
        | c2 :: _ => if is_char 124 c2 then None (* "||" is out of this fragment *)
                     else option_map (cons U2Pipe) (lex2 n rest)
        | [] => option_map (cons U2Pipe) (lex2 n rest)
        end
      else if is_char 62 c (* > *) then
        match rest with
        | c2 :: rest2 => if is_char 62 c2 then option_map (cons U2GtGt) (lex2 n rest2)
                          else option_map (cons U2Gt) (lex2 n rest)
        | [] => option_map (cons U2Gt) (lex2 n rest)
        end
      else if is_ident_start c then
        let (id, rest') := take_ident cs in
        if reserved id then None else option_map (cons (U2Ident id)) (lex2 n rest')
      else None
    end
  end.

Definition lex_string2 (s : string) : option (list token2) :=
  let cs := list_of_string s in lex2 (S (List.length cs)) cs.

Definition atom_of_name (s : string) : option atom :=
  if String.eqb s "relay" then Some Relay
  else if String.eqb s "mark" then Some (Mark bang) else None.

(* One pipe-stage unit: a bare name, or exactly `name1 | name2`. *)
Definition parse_unit (toks : list token2) : option (atom2 * list token2) :=
  match toks with
  | U2Ident s1 :: U2Pipe :: U2Ident s2 :: rest =>
      if andb (String.eqb s1 "relay") (String.eqb s2 "relay")
      then Some (PipeRR, rest) else None
  | U2Ident s :: rest =>
      match atom_of_name s with Some a => Some (FromShell a, rest) | None => None end
  | _ => None
  end.

(* A unit, plus an optional trailing `>`/`>>` IDENT, as an `ratom`. Only a
   BARE identifier (not a pipe result) may be redirected in this fragment. *)
Definition parse_program2 (s : string) : option ratom :=
  match lex_string2 s with
  | None => None
  | Some toks =>
    match toks with
    | [U2Ident s1] =>
        match atom_of_name s1 with Some a => Some (Direct a) | None => None end
    | [U2Ident s1; U2Gt; U2Ident path] =>
        match atom_of_name s1 with Some a => Some (Redirect false path a) | None => None end
    | [U2Ident s1; U2GtGt; U2Ident path] =>
        match atom_of_name s1 with Some a => Some (Redirect true path a) | None => None end
    | _ => None
    end
  end.

(* The pipe unit is parsed separately into `atom2` (Bridge2.v), since
   `ratom` cannot express "redirect a pipe" in this fragment (see header). *)
Definition parse_program_pipe (s : string) : option atom2 :=
  match lex_string2 s with
  | Some toks =>
      match parse_unit toks with
      | Some (a, []) => Some a
      | _ => None
      end
  | None => None
  end.

Example parse_relay_pipe_relay :
  parse_program_pipe "relay | relay" = Some PipeRR.
Proof. vm_compute; reflexivity. Qed.

Example parse_relay_gt_out :
  parse_program2 "relay > out" = Some (Redirect false "out" Relay).
Proof. vm_compute; reflexivity. Qed.

Example parse_relay_gtgt_log :
  parse_program2 "relay >> log" = Some (Redirect true "log" Relay).
Proof. vm_compute; reflexivity. Qed.

Example parse_mark_bare :
  parse_program2 "mark" = Some (Direct (Mark bang)).
Proof. vm_compute; reflexivity. Qed.

(* Rejected, not silently accepted: double pipe, unknown name, empty target,
   redirecting a pipe result, more than one redirect. All of these ARE valid
   Bash syntax (`bash -n` accepts every one, `results/parseexpansion_bash_n.json`)
   -- the rejection is this fragment's own stated scope limit, not a claim
   that Bash itself rejects them. *)
Example parse_rejects_oror : lex_string2 "relay || relay" = None.
Proof. vm_compute; reflexivity. Qed.

Example parse_rejects_unknown_name : parse_program2 "cat > out" = None.
Proof. vm_compute; reflexivity. Qed.

Example parse_rejects_three_pipe : parse_program_pipe "relay | relay | relay" = None.
Proof. vm_compute; reflexivity. Qed.

Example parse_rejects_double_redirect : parse_program2 "relay > a > b" = None.
Proof. vm_compute; reflexivity. Qed.

(* The parsed AST inherits `Bridge2.v`/`Redirect.v`'s own checked facts:
   e.g. `relay > out`, run from the SAME `input_s` fixture used throughout,
   is exactly the checked `redirect_truncate_witness`/`_observations` run. *)
Example parse_relay_gt_out_runs_as_checked :
  parse_program2 "relay > out" = Some (Redirect false "out" Relay) /\
  redirect_prim (Redirect false "out" Relay) (RState (ShellState input_s []) empty_files) 0
    redirect_truncate_final /\
  rs_files redirect_truncate_final "out" = abc.
Proof.
  split; [vm_compute; reflexivity |].
  split; [exact redirect_truncate_witness | apply redirect_truncate_observations].
Qed.

End ShellExpansionText.
