(* Lexer soundness: the token list produced by `lex` is a tokenization of the
   input characters according to the inductive relation `renders` (blanks
   skipped; identifiers maximal, starting with a letter/underscore, not
   reserved; "&&", "||", ";", "(", ")" literal; "((" never adjacent).
   With Parse.v's `parse_program_sound`, an accepted text is related to its
   AST by two inductive specifications only (`renders`, `body_derives`); the
   executable lexer and parser are no longer trusted. What remains trusted is
   that these two relations describe the intended Bash fragment. *)
From Coq Require Import List Ascii String ZArith Lia Bool.
Require Import Shell Parse.
Import ListNotations ShellComposition ShellText.

Module ShellLex.

Definition ident_chars (s : string) : Prop :=
  match list_of_string s with
  | [] => False
  | c :: cs => is_ident_start c = true /\ Forall (fun d => is_ident_char d = true) cs
  end.

Inductive render_token : token -> list ascii -> Prop :=
| r_ident s : ident_chars s -> reserved s = false ->
    render_token (TIdent s) (list_of_string s)
| r_semi c : is_char 59 c = true -> render_token TSemi [c]
| r_andand c1 c2 : is_char 38 c1 = true -> is_char 38 c2 = true ->
    render_token TAndAnd [c1; c2]
| r_oror c1 c2 : is_char 124 c1 = true -> is_char 124 c2 = true ->
    render_token TOrOr [c1; c2]
| r_lparen c : is_char 40 c = true -> render_token TLParen [c]
| r_rparen c : is_char 41 c = true -> render_token TRParen [c].

(* Maximal munch: an identifier is not followed by an identifier character;
   "(" is not followed by "(". *)
Definition boundary (t : token) (rest : list ascii) : Prop :=
  match t with
  | TIdent _ => match rest with c :: _ => is_ident_char c = false | [] => True end
  | TLParen => match rest with c :: _ => is_char 40 c = false | [] => True end
  | _ => True
  end.

Inductive renders : list token -> list ascii -> Prop :=
| r_nil : renders [] []
| r_blank ts c cs : is_blank c = true -> renders ts cs -> renders ts (c :: cs)
| r_tok t ts chars rest : render_token t chars -> boundary t rest ->
    renders ts rest -> renders (t :: ts) (chars ++ rest).

Lemma ident_start_char c : is_ident_start c = true -> is_ident_char c = true.
Proof. unfold is_ident_char. intro H. rewrite H. reflexivity. Qed.

Lemma take_ident_spec cs : forall id rest, take_ident cs = (id, rest) ->
  cs = list_of_string id ++ rest /\
  Forall (fun d => is_ident_char d = true) (list_of_string id) /\
  match rest with [] => True | d :: _ => is_ident_char d = false end.
Proof.
  induction cs as [| c cs IH]; intros id rest H; simpl in H.
  - injection H as Hi Hr; subst. simpl. repeat split; constructor.
  - destruct (is_ident_char c) eqn:Hc.
    + destruct (take_ident cs) as [id' rest'] eqn:E.
      injection H as Hi Hr; subst.
      destruct (IH id' rest eq_refl) as [Hcs [Hall Hb]].
      simpl. rewrite <- Hcs. repeat split; [constructor; assumption | exact Hb].
    + injection H as Hi Hr; subst. simpl. repeat split; [constructor | exact Hc].
Qed.

Lemma option_map_cons_some (t : token) o toks :
  option_map (cons t) o = Some toks -> exists ts, o = Some ts /\ toks = t :: ts.
Proof.
  destruct o as [ts |]; simpl; intro H; [| discriminate].
  injection H as H; subst. exists ts; auto.
Qed.

Lemma lex_step n c rest : lex (S n) (c :: rest) =
  if is_blank c then lex n rest
  else if is_char 59 c then option_map (cons TSemi) (lex n rest)
  else if is_char 40 c then
    match rest with
    | c2 :: _ => if is_char 40 c2 then None
                 else option_map (cons TLParen) (lex n rest)
    | [] => None
    end
  else if is_char 41 c then option_map (cons TRParen) (lex n rest)
  else if is_char 38 c then
    match rest with
    | c2 :: rest2 => if is_char 38 c2 then option_map (cons TAndAnd) (lex n rest2)
                     else None
    | [] => None
    end
  else if is_char 124 c then
    match rest with
    | c2 :: rest2 => if is_char 124 c2 then option_map (cons TOrOr) (lex n rest2)
                     else None
    | [] => None
    end
  else if is_ident_start c then
    let (id, rest') := take_ident (c :: rest) in
    if reserved id then None
    else option_map (cons (TIdent id)) (lex n rest')
  else None.
Proof. reflexivity. Qed.

Lemma lex_sound fuel : forall cs toks, lex fuel cs = Some toks -> renders toks cs.
Proof.
  induction fuel as [| n IH]; intros cs toks H; [discriminate |].
  destruct cs as [| c rest].
  { simpl in H. injection H as H; subst. constructor. }
  rewrite lex_step in H.
  destruct (is_blank c) eqn:Hb.
  { apply r_blank; [exact Hb | apply IH; exact H]. }
  destruct (is_char 59 c) eqn:H59.
  { destruct (option_map_cons_some _ _ _ H) as [ts [Hl Ht]]; subst.
    apply (r_tok TSemi ts [c] rest);
      [apply r_semi; exact H59 | exact I | apply IH; exact Hl]. }
  destruct (is_char 40 c) eqn:H40.
  { destruct rest as [| c2 rest2]; [discriminate |].
    destruct (is_char 40 c2) eqn:H40b; [discriminate |].
    destruct (option_map_cons_some _ _ _ H) as [ts [Hl Ht]]; subst.
    apply (r_tok TLParen ts [c] (c2 :: rest2));
      [apply r_lparen; exact H40 | simpl; exact H40b | apply IH; exact Hl]. }
  destruct (is_char 41 c) eqn:H41.
  { destruct (option_map_cons_some _ _ _ H) as [ts [Hl Ht]]; subst.
    apply (r_tok TRParen ts [c] rest);
      [apply r_rparen; exact H41 | exact I | apply IH; exact Hl]. }
  destruct (is_char 38 c) eqn:H38.
  { destruct rest as [| c2 rest2]; [discriminate |].
    destruct (is_char 38 c2) eqn:H38b; [| discriminate].
    destruct (option_map_cons_some _ _ _ H) as [ts [Hl Ht]]; subst.
    apply (r_tok TAndAnd ts [c; c2] rest2);
      [apply r_andand; assumption | exact I | apply IH; exact Hl]. }
  destruct (is_char 124 c) eqn:H124.
  { destruct rest as [| c2 rest2]; [discriminate |].
    destruct (is_char 124 c2) eqn:H124b; [| discriminate].
    destruct (option_map_cons_some _ _ _ H) as [ts [Hl Ht]]; subst.
    apply (r_tok TOrOr ts [c; c2] rest2);
      [apply r_oror; assumption | exact I | apply IH; exact Hl]. }
  destruct (is_ident_start c) eqn:Hs; [| discriminate].
  destruct (take_ident (c :: rest)) as [id rest'] eqn:E.
  destruct (reserved id) eqn:Hr; [discriminate |].
  destruct (option_map_cons_some _ _ _ H) as [ts [Hl Ht]]; subst.
  destruct (take_ident_spec _ _ _ E) as [Hcs [Hall Hbnd]].
  rewrite Hcs.
  apply (r_tok (TIdent id) ts (list_of_string id) rest');
    [| exact Hbnd | apply IH; exact Hl].
  apply r_ident; [| exact Hr].
  unfold ident_chars.
  destruct id as [| c0 id'].
  - (* impossible: an identifier start character was consumed *)
    simpl in Hcs. subst rest'. simpl in Hbnd.
    rewrite (ident_start_char c Hs) in Hbnd. discriminate.
  - simpl in Hcs. injection Hcs as Hc0 _. subst c0.
    split; [exact Hs |].
    simpl in Hall. inversion Hall; assumption.
Qed.

Theorem lex_string_sound s toks :
  lex_string s = Some toks -> renders toks (list_of_string s).
Proof. unfold lex_string. apply lex_sound. Qed.

(* Characters -> tokens -> AST, both links inductive specifications. *)
Theorem parse_program_sound_chars s c :
  parse_program s = Some c ->
  exists toks, renders toks (list_of_string s) /\ body_derives toks c.
Proof.
  intro H. destruct (parse_program_sound _ _ H) as [toks [Hl Hd]].
  exists toks. split; [apply lex_string_sound; exact Hl | exact Hd].
Qed.

End ShellLex.
