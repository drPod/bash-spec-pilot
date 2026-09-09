(* A bounded shell-text frontend for the phase3/Shell.v command grammar.

   Accepted fragment (transparently chosen, NOT Bash): command identifiers
   [A-Za-z_][A-Za-z0-9_]* that are not Bash reserved words, with no arguments,
   no expansions; operators ";" "&&" "||"; parentheses; spaces and tabs.
   Everything else (newlines, pipes, redirections, "&", quotes, "$", "#",
   "!", braces, non-ASCII, ...) is rejected by the lexer: nothing is erased.
   Adjacent "((" is rejected because Bash lexes it as the arithmetic command
   (found by the differential test: bash runs "((t))" as arithmetic, status 1);
   "( (t) )" with a blank between the parentheses is nested grouping.

   Precedence follows Bash (parse.y: %left ';' ... %left AND_AND OR_OR):
   "&&" and "||" bind tighter than ";", have equal precedence and associate to
   the left; ";" associates to the left; a trailing ";" is permitted at the end
   of a list (top level or inside parentheses). Parentheses only group here:
   the state model has no subshell-local state, so "( c )" denotes c.

   Checked content: `parse_program_sound` shows that whenever the recursive
   descent parser accepts a token list it returns a command that the inductive
   grammar relation `body_derives` (the precedence-stratified grammar above)
   derives from exactly those tokens. The grammar relation is the specification;
   the parser is not trusted. The lexer is proved sound separately in Lex.v
   (`lex_sound`: tokens are a maximal-munch tokenization of the characters).
   Trusted boundary that remains: the identification of these two inductive
   relations with Bash's own lexer/parser on this fragment (directed and random
   tests against real Bash in validate_text.py are evidence, not proof). This is a NEW bounded frontend for
   shell text; it is not Aaron Councilman's spec-language parser
   (counc009/state_based bash-verifier), which parses a different language and
   is untouched. Completeness (every derivable token list is accepted) is not
   proved. *)
From Coq Require Import List Ascii String ZArith Lia Bool.
Require Import Shell.
Import ListNotations ShellComposition.
Local Open Scope Z_scope.

Module ShellText.

Inductive token : Type :=
| TIdent (name : string)
| TSemi | TAndAnd | TOrOr | TLParen | TRParen.

(* ---- Lexer (trusted; ASCII only) ---- *)

Definition ascii_between (lo hi : nat) (c : ascii) : bool :=
  (Nat.leb lo (nat_of_ascii c)) && (Nat.leb (nat_of_ascii c) hi).
Definition is_lower (c : ascii) : bool := ascii_between 97 122 c.
Definition is_upper (c : ascii) : bool := ascii_between 65 90 c.
Definition is_digit (c : ascii) : bool := ascii_between 48 57 c.
Definition is_underscore (c : ascii) : bool := Nat.eqb (nat_of_ascii c) 95.
Definition is_ident_start (c : ascii) : bool :=
  is_lower c || is_upper c || is_underscore c.
Definition is_ident_char (c : ascii) : bool := is_ident_start c || is_digit c.
Definition is_blank (c : ascii) : bool :=
  Nat.eqb (nat_of_ascii c) 32 || Nat.eqb (nat_of_ascii c) 9.
Definition is_char (n : nat) (c : ascii) : bool := Nat.eqb (nat_of_ascii c) n.

(* Bash reserved words (bash(1) RESERVED WORDS) that lex as identifiers here;
   "!", "{", "}", "[[", "]]" are already unlexable. Rejected, since Bash would
   not parse them as simple commands. *)
Definition reserved (s : string) : bool :=
  existsb (String.eqb s)
    (["if"; "then"; "else"; "elif"; "fi"; "case"; "esac"; "for"; "select";
      "while"; "until"; "do"; "done"; "in"; "function"; "time"; "coproc"])%string.

Fixpoint take_ident (cs : list ascii) : string * list ascii :=
  match cs with
  | c :: rest =>
      if is_ident_char c
      then let (id, rest') := take_ident rest in (String c id, rest')
      else (EmptyString, cs)
  | [] => (EmptyString, [])
  end.

Fixpoint lex (fuel : nat) (cs : list ascii) : option (list token) :=
  match fuel with
  | O => None
  | S n =>
    match cs with
    | [] => Some []
    | c :: rest =>
      if is_blank c then lex n rest
      else if is_char 59 c (* ; *) then option_map (cons TSemi) (lex n rest)
      else if is_char 40 c (* ( *) then
        match rest with
        | c2 :: _ => if is_char 40 c2 then None (* "((" is Bash arithmetic *)
                     else option_map (cons TLParen) (lex n rest)
        | [] => None
        end
      else if is_char 41 c (* ) *) then option_map (cons TRParen) (lex n rest)
      else if is_char 38 c (* & *) then
        match rest with
        | c2 :: rest2 => if is_char 38 c2 then option_map (cons TAndAnd) (lex n rest2)
                         else None
        | [] => None
        end
      else if is_char 124 c (* | *) then
        match rest with
        | c2 :: rest2 => if is_char 124 c2 then option_map (cons TOrOr) (lex n rest2)
                         else None
        | [] => None
        end
      else if is_ident_start c then
        let (id, rest') := take_ident cs in
        if reserved id then None
        else option_map (cons (TIdent id)) (lex n rest')
      else None
    end
  end.

Fixpoint list_of_string (s : string) : list ascii :=
  match s with EmptyString => [] | String c s' => c :: list_of_string s' end.

Definition lex_string (s : string) : option (list token) :=
  let cs := list_of_string s in lex (S (List.length cs)) cs.

(* ---- Grammar relation: the specification of the fragment ---- *)

Inductive cmd_derives : list token -> command string -> Prop :=
| d_ident s : cmd_derives [TIdent s] (call s)
| d_paren ts c : body_derives ts c ->
    cmd_derives (TLParen :: ts ++ [TRParen]) c
with andor_derives : list token -> command string -> Prop :=
| d_single ts c : cmd_derives ts c -> andor_derives ts c
| d_and ts1 c1 ts2 c2 : andor_derives ts1 c1 -> cmd_derives ts2 c2 ->
    andor_derives (ts1 ++ TAndAnd :: ts2) (and_then c1 c2)
| d_or ts1 c1 ts2 c2 : andor_derives ts1 c1 -> cmd_derives ts2 c2 ->
    andor_derives (ts1 ++ TOrOr :: ts2) (or_else c1 c2)
with list_derives : list token -> command string -> Prop :=
| d_andor ts c : andor_derives ts c -> list_derives ts c
| d_seq ts1 c1 ts2 c2 : list_derives ts1 c1 -> andor_derives ts2 c2 ->
    list_derives (ts1 ++ TSemi :: ts2) (seq c1 c2)
with body_derives : list token -> command string -> Prop :=
| d_body ts c : list_derives ts c -> body_derives ts c
| d_body_trailing ts c : list_derives ts c -> body_derives (ts ++ [TSemi]) c.

(* ---- Recursive descent parser (fuel-indexed, total) ---- *)

Fixpoint parse_cmd (fuel : nat) (toks : list token)
  : option (command string * list token) :=
  match fuel with
  | O => None
  | S n =>
    match toks with
    | TIdent s :: rest => Some (call s, rest)
    | TLParen :: rest =>
        match parse_list n rest with
        | Some (c, TRParen :: rest') => Some (c, rest')
        | _ => None
        end
    | _ => None
    end
  end
with parse_andor (fuel : nat) (toks : list token)
  : option (command string * list token) :=
  match fuel with
  | O => None
  | S n =>
    match parse_cmd n toks with
    | Some (c, rest) => parse_andor_tail n c rest
    | None => None
    end
  end
with parse_andor_tail (fuel : nat) (acc : command string) (toks : list token)
  : option (command string * list token) :=
  match fuel with
  | O => None
  | S n =>
    match toks with
    | TAndAnd :: rest =>
        match parse_cmd n rest with
        | Some (c, rest') => parse_andor_tail n (and_then acc c) rest'
        | None => None
        end
    | TOrOr :: rest =>
        match parse_cmd n rest with
        | Some (c, rest') => parse_andor_tail n (or_else acc c) rest'
        | None => None
        end
    | _ => Some (acc, toks)
    end
  end
with parse_list (fuel : nat) (toks : list token)
  : option (command string * list token) :=
  match fuel with
  | O => None
  | S n =>
    match parse_andor n toks with
    | Some (c, rest) => parse_list_tail n c rest
    | None => None
    end
  end
with parse_list_tail (fuel : nat) (acc : command string) (toks : list token)
  : option (command string * list token) :=
  match fuel with
  | O => None
  | S n =>
    match toks with
    | TSemi :: rest =>
        match rest with
        | [] | TRParen :: _ => Some (acc, rest)
        | _ =>
          match parse_andor n rest with
          | Some (c, rest') => parse_list_tail n (seq acc c) rest'
          | None => None
          end
        end
    | _ => Some (acc, toks)
    end
  end.

Definition parse_tokens (toks : list token) : option (command string) :=
  match parse_list (8 * (List.length toks + 1)) toks with
  | Some (c, []) => Some c
  | _ => None
  end.

Definition parse_program (s : string) : option (command string) :=
  match lex_string s with
  | Some toks => parse_tokens toks
  | None => None
  end.

(* ---- Soundness: accepted token lists are derivations of the grammar ---- *)

Definition sound_cmd fuel := forall toks c rest,
  parse_cmd fuel toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\ cmd_derives ts c.
Definition sound_andor fuel := forall toks c rest,
  parse_andor fuel toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\ andor_derives ts c.
Definition sound_andor_tail fuel := forall acc toks c rest,
  parse_andor_tail fuel acc toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\
    forall ts0, andor_derives ts0 acc -> andor_derives (ts0 ++ ts) c.
Definition sound_list fuel := forall toks c rest,
  parse_list fuel toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\ body_derives ts c.
Definition sound_list_tail fuel := forall acc toks c rest,
  parse_list_tail fuel acc toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\
    forall ts0, list_derives ts0 acc -> body_derives (ts0 ++ ts) c.

Lemma parse_sound fuel :
  sound_cmd fuel /\ sound_andor fuel /\ sound_andor_tail fuel /\
  sound_list fuel /\ sound_list_tail fuel.
Proof.
  induction fuel as [| n [IHc [IHa [IHat [IHl IHlt]]]]].
  { repeat split; red; intros; discriminate. }
  repeat split.
  - (* cmd *)
    intros toks c rest H. simpl in H.
    destruct toks as [| t toks']; [discriminate |].
    destruct t; try discriminate.
    + injection H as Hc Hr; subst. exists [TIdent name]. split; [reflexivity |].
      constructor.
    + destruct (parse_list n toks') as [[c' rest'] |] eqn:E; [| discriminate].
      destruct rest' as [| t' rest'']; [discriminate |].
      destruct t'; try discriminate.
      injection H as Hc Hr; subst.
      destruct (IHl _ _ _ E) as [ts [Ht Hd]].
      exists (TLParen :: ts ++ [TRParen]). split.
      * rewrite Ht. simpl. rewrite <- app_assoc. reflexivity.
      * apply d_paren; exact Hd.
  - (* andor *)
    intros toks c rest H. simpl in H.
    destruct (parse_cmd n toks) as [[c1 rest1] |] eqn:E; [| discriminate].
    destruct (IHc _ _ _ E) as [ts1 [Ht1 Hd1]].
    destruct (IHat _ _ _ _ H) as [ts2 [Ht2 Hd2]].
    exists (ts1 ++ ts2). split.
    + rewrite Ht1, Ht2. apply app_assoc.
    + apply Hd2. apply d_single; exact Hd1.
  - (* andor_tail *)
    intros acc toks c rest H. simpl in H.
    destruct toks as [| t toks'].
    { injection H as Hc Hr; subst. exists []. split; [reflexivity |].
      intros ts0 Hd. rewrite app_nil_r; exact Hd. }
    destruct t;
      try (injection H as Hc Hr; subst; exists []; split; [reflexivity |];
           intros ts0 Hd; rewrite app_nil_r; exact Hd).
    + (* && *)
      destruct (parse_cmd n toks') as [[c2 rest2] |] eqn:E; [| discriminate].
      destruct (IHc _ _ _ E) as [ts2 [Ht2 Hd2]].
      destruct (IHat _ _ _ _ H) as [ts3 [Ht3 Hd3]].
      exists (TAndAnd :: ts2 ++ ts3). split.
      * rewrite Ht2, Ht3. simpl. rewrite app_assoc. reflexivity.
      * intros ts0 Hd0.
        specialize (Hd3 (ts0 ++ TAndAnd :: ts2) (d_and _ _ _ _ Hd0 Hd2)).
        rewrite <- app_assoc in Hd3. exact Hd3.
    + (* || *)
      destruct (parse_cmd n toks') as [[c2 rest2] |] eqn:E; [| discriminate].
      destruct (IHc _ _ _ E) as [ts2 [Ht2 Hd2]].
      destruct (IHat _ _ _ _ H) as [ts3 [Ht3 Hd3]].
      exists (TOrOr :: ts2 ++ ts3). split.
      * rewrite Ht2, Ht3. simpl. rewrite app_assoc. reflexivity.
      * intros ts0 Hd0.
        specialize (Hd3 (ts0 ++ TOrOr :: ts2) (d_or _ _ _ _ Hd0 Hd2)).
        rewrite <- app_assoc in Hd3. exact Hd3.
  - (* list *)
    intros toks c rest H. simpl in H.
    destruct (parse_andor n toks) as [[c1 rest1] |] eqn:E; [| discriminate].
    destruct (IHa _ _ _ E) as [ts1 [Ht1 Hd1]].
    destruct (IHlt _ _ _ _ H) as [ts2 [Ht2 Hd2]].
    exists (ts1 ++ ts2). split.
    + rewrite Ht1, Ht2. apply app_assoc.
    + apply Hd2. apply d_andor; exact Hd1.
  - (* list_tail *)
    intros acc toks c rest H. simpl in H.
    destruct toks as [| t toks'].
    { injection H as Hc Hr; subst. exists []. split; [reflexivity |].
      intros ts0 Hd. rewrite app_nil_r. apply d_body; exact Hd. }
    destruct t;
      try (injection H as Hc Hr; subst; exists []; split; [reflexivity |];
           intros ts0 Hd; rewrite app_nil_r; apply d_body; exact Hd).
    (* ; *)
    assert (Htrail : forall rest0, Some (acc, rest0) = Some (c, rest) ->
      exists ts, TSemi :: rest0 = ts ++ rest /\
        forall ts0, list_derives ts0 acc -> body_derives (ts0 ++ ts) c).
    { intros rest0 H0. injection H0 as Hc Hr; subst.
      exists [TSemi]. split; [reflexivity |].
      intros ts0 Hd. apply d_body_trailing; exact Hd. }
    assert (Hcont : parse_andor n toks' = parse_andor n toks') by reflexivity.
    destruct toks' as [| t' toks''].
    { exact (Htrail _ H). }
    assert (Hmore : match parse_andor n (t' :: toks'') with
                    | Some (c0, rest') => parse_list_tail n (seq acc c0) rest'
                    | None => None
                    end = Some (c, rest) ->
                    exists ts, TSemi :: t' :: toks'' = ts ++ rest /\
                      forall ts0, list_derives ts0 acc -> body_derives (ts0 ++ ts) c).
    { intro H1.
      destruct (parse_andor n (t' :: toks'')) as [[c2 rest2] |] eqn:E; [| discriminate].
      destruct (IHa _ _ _ E) as [ts2 [Ht2 Hd2]].
      destruct (IHlt _ _ _ _ H1) as [ts3 [Ht3 Hd3]].
      exists (TSemi :: ts2 ++ ts3). split.
      * rewrite Ht2, Ht3. simpl. rewrite app_assoc. reflexivity.
      * intros ts0 Hd0.
        specialize (Hd3 (ts0 ++ TSemi :: ts2) (d_seq _ _ _ _ Hd0 Hd2)).
        rewrite <- app_assoc in Hd3. exact Hd3. }
    destruct t'; try exact (Hmore H).
    exact (Htrail _ H).
Qed.

Theorem parse_tokens_sound toks c :
  parse_tokens toks = Some c -> body_derives toks c.
Proof.
  unfold parse_tokens. intro H.
  destruct (parse_list (8 * (List.length toks + 1)) toks) as [[c' rest] |] eqn:E;
    [| discriminate].
  destruct rest; [| discriminate]. injection H as Hc; subst.
  destruct (proj1 (proj2 (proj2 (proj2 (parse_sound _)))) _ _ _ E)
    as [ts [Ht Hd]].
  rewrite app_nil_r in Ht. subst. exact Hd.
Qed.

Theorem parse_program_sound s c :
  parse_program s = Some c ->
  exists toks, lex_string s = Some toks /\ body_derives toks c.
Proof.
  unfold parse_program. intro H.
  destruct (lex_string s) as [toks |] eqn:E; [| discriminate].
  exists toks. split; [reflexivity | apply parse_tokens_sound; exact H].
Qed.

(* ---- Executable validation semantics (for comparison with real Bash) ---- *)

(* Each identifier denotes a fixed exit status and a fixed stdout text; the
   composed run follows phase3 RelayComposition.runFragment. `run_reachable`
   ties it to the relational exec of Shell.v, so every validation record is an
   exec derivation. *)
Definition env := string -> Z * string.
Definition graph (e : env) : primitive string string :=
  fun name s rc t => t = (s ++ snd (e name))%string /\ rc = fst (e name).

Fixpoint run (e : env) (c : command string) (out : string) : Z * string :=
  match c with
  | call a => (fst (e a), (out ++ snd (e a))%string)
  | seq x y => run e y (snd (run e x out))
  | and_then x y =>
      let t := run e x out in if Z.eqb (fst t) 0 then run e y (snd t) else t
  | or_else x y =>
      let t := run e x out in if Z.eqb (fst t) 0 then t else run e y (snd t)
  end.

Theorem run_reachable e c out :
  exec (graph e) c out (fst (run e c out)) (snd (run e c out)).
Proof.
  revert out. induction c as [a | x IHx y IHy | x IHx y IHy | x IHx y IHy];
    intro out; simpl.
  - apply exec_call. split; reflexivity.
  - eapply exec_seq; [apply IHx | apply IHy].
  - destruct (Z.eqb (fst (run e x out)) 0) eqn:E.
    + apply Z.eqb_eq in E. eapply exec_and_zero; [| apply IHy].
      rewrite <- E. apply IHx.
    + apply Z.eqb_neq in E. apply exec_and_nonzero; [apply IHx | exact E].
  - destruct (Z.eqb (fst (run e x out)) 0) eqn:E.
    + apply Z.eqb_eq in E. rewrite E. apply exec_or_zero. rewrite <- E. apply IHx.
    + apply Z.eqb_neq in E. eapply exec_or_nonzero; [apply IHx | exact E | apply IHy].
Qed.

(* Validation environment shared with validate_text.py: t/u succeed, f/g fail. *)
Local Open Scope string_scope.
Definition test_env : env := fun name =>
  if String.eqb name "t" then (0, "t")
  else if String.eqb name "u" then (0, "u")
  else if String.eqb name "f" then (1, "f")
  else if String.eqb name "g" then (2, "g")
  else (127, "").

End ShellText.
