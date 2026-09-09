(* A general compositional parser + semantics for the pipe/redirect fragment,
   unifying Bridge2.v's `atom2` (bare relay/mark, or one `relay|relay` pipe)
   and Redirect.v's `ratom` (redirection) into ONE atom type `yatom`, and
   composing it with the SAME `;`/`&&`/`||`/parens grammar levels as the
   frozen `shell-bridge/Parse.v`, at the precedence position bash's own
   `parse.y` uses (pipeline/redirect bind tighter than `&&`/`||`, which bind
   tighter than `;`; parens only group, no subshell-local state, exactly
   Parse.v's own stated convention).

   WHAT IS NEW HERE, precisely:
   1. `yredirect_prim` generalizes `Redirect.v`'s `redirect_prim` from
      wrapping a bare `atom` to wrapping an `atom2` (Bridge2.v): redirecting
      a PIPE RESULT (`relay | relay > out`) is now expressible, not just
      redirecting a bare relay/mark. `pipe_prim_delivered_extra` below is the
      needed generalization of `Redirect.v`'s `relay_prim_delivered_extra`
      (reused unchanged for the `FromShell` case; proved fresh for `PipeRR`
      directly from `pipe_prim`'s own definition, not by reproving
      `Pipeline.v`'s trace facts).
   2. `rcmd_derives`/`uandor_derives`/`ulist_derives`/`ubody_derives` is a
      FOUR-LEVEL mutual inductive grammar mirroring `Parse.v`'s own
      `cmd_derives`/.../`body_derives` exactly in shape (same four levels,
      same left-associativity, same paren rule), with the base level
      (`Parse.v`'s bare `TIdent`) replaced by `redir_derives` (a pipe-or-bare
      unit, plus an optional trailing `>`/`>>` target) instead of a single
      identifier. `uparse_program3_sound` is the soundness theorem
      (`Parse.v`'s own `parse_program_sound` is the pattern followed): every
      token list the recursive-descent parser accepts derives from the
      grammar relation. NOT proved: completeness (every derivable token list
      is accepted) -- same stated gap as `Parse.v` itself.
   3. Explicit unsupported forms, checked as rejects below, not silently
      mis-parsed: three-stage pipes, piping anything but literal
      `relay`/`relay`, more than one redirect, redirecting a PARENTHESIZED
      group (only a bare pipe-or-unit can be redirected in this fragment --
      attaching `>`/`>>` to a `(...)` group is unsupported, stated, not
      approximated).
   4. Composition is via the SAME `Shell.v` `command`/`exec`/
      `command_refines`/`query_transfer` (unchanged, universally
      quantified): nothing new is proved for composing `yatom` atoms with
      `;`/`&&`/`||` beyond what `command_refines`/`query_transfer` already
      give for ANY atom type -- `compose_command_refines`/
      `compose_query_transfer` below are direct instantiations, stated
      explicitly so the claim is visibly "applied", not "invented".

   Frozen/unmodified, only imported for reuse: `Protocol.v`, `Reach.v`,
   `Conservation.v`, `ReachExamples.v` (relay/), `Shell.v`, `Parse.v`,
   `Bridge.v` (shell-bridge/), `Pipeline.v`, `Bridge2.v`, `Redirect.v`,
   `ParseExpansion.v` (shell-expansion/, this directory's own prior session).

   WHAT THIS STILL DOES NOT ESTABLISH (see extended/README.md for the full
   list): real fds/dup2/process model; `PipeRR` remains two `Relay`-shaped
   stages only (no N-stage, no heterogeneous pipeline); `pstep_fn` remains a
   single deterministic scheduler, not a nondeterministic "any interleaving"
   relation (`Pipeline.v`'s own stated limit, unchanged, inherited here);
   redirecting a compound (`;`/`&&`/`||`/paren) command is out of scope, only
   a bare pipe-or-unit; grammar-to-real-Bash fidelity is finite directed
   evidence (`validate_extended.py`), not a completeness or correctness
   proof against Bash's actual parser. *)
From Coq Require Import List Ascii String ZArith Bool.
From compcert Require Import Integers.
Require Import Protocol Reach ReachExamples Conservation Shell Parse Bridge
  Pipeline Bridge2 Redirect ParseExpansion.
Import ListNotations RelayProtocol RelayReach RelayConservation
  ShellComposition ShellText ShellBridge ShellPipeline ShellPipeBridge
  ShellRedirect ShellExpansionText.
Local Open Scope Z_scope.
Local Open Scope string_scope.
Local Open Scope list_scope.

Module ShellCompose.

(* ================================================================== *)
(* 1. Generalized redirect: wraps atom2 (bare relay/mark, or PipeRR),   *)
(*    not just a bare atom.                                             *)
(* ================================================================== *)

Inductive yatom := YDirect (a2 : atom2) | YRedirect (append : bool) (path : string) (a2 : atom2).

Lemma pipe_prim_delivered_extra a2 s rc t :
  pipe_prim a2 s rc t -> exists extra, delivered (os t) = delivered (os s) ++ extra.
Proof.
  destruct a2 as [a |]; simpl; intro H.
  - exact (relay_prim_delivered_extra a s rc t H).
  - destruct H as [cw [fuel H]]. destruct H as [_ [_ [_ Ht]]].
    eexists. rewrite Ht. simpl. reflexivity.
Qed.

Definition yredirect_prim : primitive yatom rstate := fun y r rc r' =>
  match y with
  | YDirect a2 => pipe_prim a2 (rs_shell r) rc (rs_shell r') /\ rs_files r' = rs_files r
  | YRedirect append path a2 =>
      (path = "" /\ rc = 1 /\ r' = r)
      \/
      (path <> "" /\
       exists t extra,
         pipe_prim a2 (rs_shell r) rc t /\
         delivered (os t) = delivered (os (rs_shell r)) ++ extra /\
         rs_files r' = update_file path ((if append then rs_files r path else []) ++ extra) (rs_files r) /\
         rs_shell r' = ShellState (os_reset (os t) (delivered (os (rs_shell r)))) (lost t))
  end.

Theorem yredirect_underlying_exec append path a2 r rc r' :
  yredirect_prim (YRedirect append path a2) r rc r' -> path <> ""%string ->
  exists t, pipe_prim a2 (rs_shell r) rc t.
Proof.
  intros [[Hp _] | [_ [t [extra [Ha _]]]]] Hpath.
  - contradiction (Hpath Hp).
  - exists t; exact Ha.
Qed.

Theorem yredirect_open_failure append a2 r r' :
  yredirect_prim (YRedirect append ""%string a2) r 1 r' -> r' = r.
Proof.
  intros [[_ [_ Heq]] | [Hne _]]; [exact Heq | contradiction (Hne eq_refl)].
Qed.

(* ---- Reuse sanity: redirecting a bare relay via `YDirect`/`YRedirect`
   reproduces exactly `Redirect.v`'s own `redirect_truncate_witness`. This
   is not a new fact, only evidence the generalization did not silently
   change the bare-atom case. ---- *)

Example yredirect_relay_gt_out_matches_old :
  yredirect_prim (YRedirect false "out"%string (FromShell Relay))
    (RState (ShellState input_s []) empty_files) 0
    (RState (ShellState (os_reset final_s []) []) (update_file "out"%string abc empty_files)).
Proof.
  right. split; [discriminate |].
  exists (ShellState final_s []), abc.
  split; [| split; [| split]].
  - exists []. split; [exact success_outcome | reflexivity].
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
Qed.

(* ---- NEW: redirecting a PIPE result. `relay | relay > out` in real bash
   redirects only the pipeline's own visible output (the second stage's
   writes); `pipe_prim`'s own definition already folds exactly that into the
   ambient `delivered` stream (`delivered (os s) ++ delivered (pw_consumer
   pwF)`), so `extra` here is precisely the consumer's own delivered bytes,
   not the whole internal trace -- redirecting `PipeRR` faithfully redirects
   the pipeline's real observable output, not an approximation of it. ---- *)

Definition piperr_result : shell_state :=
  ShellState (World (unread (pw_producer (prun 20 demo_pw0)))
                (delivered demo_producer0 ++ delivered (pw_consumer (prun 20 demo_pw0)))
                (reads (pw_producer (prun 20 demo_pw0))) (writes demo_producer0)
                (read_calls (pw_producer (prun 20 demo_pw0))) (write_calls demo_producer0))
    ([] ++ pw_prod_lost (prun 20 demo_pw0) ++ pw_cons_lost (prun 20 demo_pw0)).

Lemma piperr_witness :
  pipe_prim PipeRR (ShellState demo_producer0 []) 0 piperr_result.
Proof. exists [], 20%nat. vm_compute. repeat split; (reflexivity || discriminate). Qed.

Definition pipe_redirect_final : rstate :=
  RState
    (ShellState (os_reset (os piperr_result) (delivered demo_producer0)) (lost piperr_result))
    (update_file "out"%string (delivered (pw_consumer (prun 20 demo_pw0))) empty_files).

Example pipe_redirect_witness :
  yredirect_prim (YRedirect false "out"%string PipeRR)
    (RState (ShellState demo_producer0 []) empty_files) 0 pipe_redirect_final.
Proof.
  right. split; [discriminate |].
  exists piperr_result, (delivered (pw_consumer (prun 20 demo_pw0))).
  split; [| split; [| split]].
  - exact piperr_witness.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
Qed.

Example pipe_redirect_observations :
  rs_files pipe_redirect_final "out"%string = demo_bytes /\
  delivered (os (rs_shell pipe_redirect_final)) = [].
Proof. vm_compute. split; reflexivity. Qed.

(* ---- One `seq`-composed example carried over at the new type, matching
   `Redirect.v`'s own `redirect_within_seq` shape: a later, unredirected
   command sees the restored stream, not the file. ---- *)

Example ycompose_within_seq :
  exec yredirect_prim
    (seq (call (YDirect (FromShell Relay))) (call (YRedirect false "log"%string (FromShell (Mark bang)))))
    (RState (ShellState input_s []) empty_files) 0
    (RState (ShellState final_s []) (update_file "log"%string [bang] empty_files)).
Proof.
  apply exec_seq with (t := RState (ShellState final_s []) empty_files) (rc1 := 0).
  - apply exec_call. split; [exists []; split; [exact success_outcome | reflexivity] | reflexivity].
  - apply exec_call. right. split; [discriminate |].
    exists (ShellState (deliver final_s bang) []), [bang].
    repeat split; vm_compute; reflexivity.
Qed.

(* ---- `yatom`/`yredirect_prim` is one more plain instance of Shell.v's
   generic `command`/`exec`: nothing new is proved for `;`/`&&`/`||`
   composition beyond what `command_refines`/`query_transfer` already give
   for any atom type, only applied. ---- *)

Definition compose_command := command yatom.
Definition compose_exec := exec yredirect_prim.
Definition compose_command_refines := @command_refines yatom.
Definition compose_query_transfer := @query_transfer yatom.

(* ================================================================== *)
(* 2. Lexer: the union of Parse.v's token set and ParseExpansion.v's,
      reusing their character classifiers unchanged.                   *)
(* ================================================================== *)

Inductive utoken : Type :=
| UIdent (name : string)
| USemi | UAndAnd | UOrOr | ULParen | URParen
| UPipe | UGt | UGtGt.

Fixpoint ulex (fuel : nat) (cs : list ascii) : option (list utoken) :=
  match fuel with
  | O => None
  | S n =>
    match cs with
    | [] => Some []
    | c :: rest =>
      if is_blank c then ulex n rest
      else if is_char 59 c (* ; *) then option_map (cons USemi) (ulex n rest)
      else if is_char 40 c (* ( *) then
        match rest with
        | c2 :: _ => if is_char 40 c2 then None (* "((" is Bash arithmetic *)
                     else option_map (cons ULParen) (ulex n rest)
        | [] => option_map (cons ULParen) (ulex n rest)
        end
      else if is_char 41 c (* ) *) then option_map (cons URParen) (ulex n rest)
      else if is_char 38 c (* & *) then
        match rest with
        | c2 :: rest2 => if is_char 38 c2 then option_map (cons UAndAnd) (ulex n rest2)
                         else None
        | [] => None
        end
      else if is_char 124 c (* | *) then
        match rest with
        | c2 :: rest2 => if is_char 124 c2 then option_map (cons UOrOr) (ulex n rest2)
                         else option_map (cons UPipe) (ulex n rest)
        | [] => option_map (cons UPipe) (ulex n rest)
        end
      else if is_char 62 c (* > *) then
        match rest with
        | c2 :: rest2 => if is_char 62 c2 then option_map (cons UGtGt) (ulex n rest2)
                          else option_map (cons UGt) (ulex n rest)
        | [] => option_map (cons UGt) (ulex n rest)
        end
      else if is_ident_start c then
        let (id, rest') := take_ident cs in
        if reserved id then None else option_map (cons (UIdent id)) (ulex n rest')
      else None
    end
  end.

Definition ulex_string (s : string) : option (list utoken) :=
  let cs := list_of_string s in ulex (S (List.length cs)) cs.

(* ================================================================== *)
(* 3. Grammar: rcmd/uandor/ulist/ubody, mirroring Parse.v's own
      cmd_derives/andor_derives/list_derives/body_derives exactly in
      shape, with the base level generalized to a pipe-or-unit plus an
      optional redirect instead of a bare identifier.                  *)
(* ================================================================== *)

Inductive unit_derives : list utoken -> atom -> Prop :=
| du_atom s a : atom_of_name s = Some a -> unit_derives [UIdent s] a.

Inductive pipe_derives : list utoken -> atom2 -> Prop :=
| dpi_single ts a : unit_derives ts a -> pipe_derives ts (FromShell a)
| dpi_pipe : pipe_derives [UIdent "relay"; UPipe; UIdent "relay"] PipeRR.

Inductive redir_derives : list utoken -> yatom -> Prop :=
| dre_plain ts a2 : pipe_derives ts a2 -> redir_derives ts (YDirect a2)
| dre_trunc ts a2 path : pipe_derives ts a2 ->
    redir_derives (ts ++ [UGt; UIdent path]) (YRedirect false path a2)
| dre_append ts a2 path : pipe_derives ts a2 ->
    redir_derives (ts ++ [UGtGt; UIdent path]) (YRedirect true path a2).

Inductive rcmd_derives : list utoken -> command yatom -> Prop :=
| dc_unit ts y : redir_derives ts y -> rcmd_derives ts (call y)
| dc_paren ts c : ubody_derives ts c ->
    rcmd_derives (ULParen :: ts ++ [URParen]) c
with uandor_derives : list utoken -> command yatom -> Prop :=
| dua_single ts c : rcmd_derives ts c -> uandor_derives ts c
| dua_and ts1 c1 ts2 c2 : uandor_derives ts1 c1 -> rcmd_derives ts2 c2 ->
    uandor_derives (ts1 ++ UAndAnd :: ts2) (and_then c1 c2)
| dua_or ts1 c1 ts2 c2 : uandor_derives ts1 c1 -> rcmd_derives ts2 c2 ->
    uandor_derives (ts1 ++ UOrOr :: ts2) (or_else c1 c2)
with ulist_derives : list utoken -> command yatom -> Prop :=
| dul_andor ts c : uandor_derives ts c -> ulist_derives ts c
| dul_seq ts1 c1 ts2 c2 : ulist_derives ts1 c1 -> uandor_derives ts2 c2 ->
    ulist_derives (ts1 ++ USemi :: ts2) (seq c1 c2)
with ubody_derives : list utoken -> command yatom -> Prop :=
| dub_body ts c : ulist_derives ts c -> ubody_derives ts c
| dub_trailing ts c : ulist_derives ts c -> ubody_derives (ts ++ [USemi]) c.

(* ================================================================== *)
(* 4. Recursive-descent parser, fuel-indexed, mirroring Parse.v's own
      parse_cmd/parse_andor/parse_andor_tail/parse_list/parse_list_tail.  *)
(* ================================================================== *)

Definition parse_pipe (toks : list utoken) : option (atom2 * list utoken) :=
  match toks with
  | UIdent s1 :: UPipe :: UIdent s2 :: rest =>
      if andb (String.eqb s1 "relay") (String.eqb s2 "relay")
      then Some (PipeRR, rest) else None
  | UIdent s :: rest =>
      match atom_of_name s with Some a => Some (FromShell a, rest) | None => None end
  | _ => None
  end.

Definition parse_redir (toks : list utoken) : option (yatom * list utoken) :=
  match parse_pipe toks with
  | None => None
  | Some (a2, rest) =>
      match rest with
      | UGt :: UIdent path :: rest' => Some (YRedirect false path a2, rest')
      | UGtGt :: UIdent path :: rest' => Some (YRedirect true path a2, rest')
      | _ => Some (YDirect a2, rest)
      end
  end.

Fixpoint parse_rcmd (fuel : nat) (toks : list utoken)
  : option (command yatom * list utoken) :=
  match fuel with
  | O => None
  | S n =>
    match toks with
    | ULParen :: rest =>
        match parse_ulist n rest with
        | Some (c, URParen :: rest') => Some (c, rest')
        | _ => None
        end
    | _ =>
        match parse_redir toks with
        | Some (y, rest) => Some (call y, rest)
        | None => None
        end
    end
  end
with parse_uandor (fuel : nat) (toks : list utoken)
  : option (command yatom * list utoken) :=
  match fuel with
  | O => None
  | S n =>
    match parse_rcmd n toks with
    | Some (c, rest) => parse_uandor_tail n c rest
    | None => None
    end
  end
with parse_uandor_tail (fuel : nat) (acc : command yatom) (toks : list utoken)
  : option (command yatom * list utoken) :=
  match fuel with
  | O => None
  | S n =>
    match toks with
    | UAndAnd :: rest =>
        match parse_rcmd n rest with
        | Some (c, rest') => parse_uandor_tail n (and_then acc c) rest'
        | None => None
        end
    | UOrOr :: rest =>
        match parse_rcmd n rest with
        | Some (c, rest') => parse_uandor_tail n (or_else acc c) rest'
        | None => None
        end
    | _ => Some (acc, toks)
    end
  end
with parse_ulist (fuel : nat) (toks : list utoken)
  : option (command yatom * list utoken) :=
  match fuel with
  | O => None
  | S n =>
    match parse_uandor n toks with
    | Some (c, rest) => parse_ulist_tail n c rest
    | None => None
    end
  end
with parse_ulist_tail (fuel : nat) (acc : command yatom) (toks : list utoken)
  : option (command yatom * list utoken) :=
  match fuel with
  | O => None
  | S n =>
    match toks with
    | USemi :: rest =>
        match rest with
        | [] | URParen :: _ => Some (acc, rest)
        | _ =>
          match parse_uandor n rest with
          | Some (c, rest') => parse_ulist_tail n (seq acc c) rest'
          | None => None
          end
        end
    | _ => Some (acc, toks)
    end
  end.

Definition parse_utokens (toks : list utoken) : option (command yatom) :=
  match parse_ulist (8 * (List.length toks + 1)) toks with
  | Some (c, []) => Some c
  | _ => None
  end.

Definition parse_program3 (s : string) : option (command yatom) :=
  match ulex_string s with
  | Some toks => parse_utokens toks
  | None => None
  end.

(* ================================================================== *)
(* 5. Soundness: mirrors Parse.v's parse_sound/parse_program_sound.      *)
(* ================================================================== *)

Lemma parse_pipe_sound toks a2 rest :
  parse_pipe toks = Some (a2, rest) -> exists ts, toks = ts ++ rest /\ pipe_derives ts a2.
Proof.
  intro H.
  destruct toks as [| t1 toks1]; [discriminate |].
  destruct t1 as [s1| | | | | | | |]; try discriminate.
  destruct toks1 as [| t2 toks2].
  { simpl in H. destruct (atom_of_name s1) eqn:Ea; inversion H; subst.
    exists [UIdent s1]; split; [reflexivity |]. apply dpi_single. constructor; exact Ea. }
  destruct t2; try (
    simpl in H; destruct (atom_of_name s1) eqn:Ea; inversion H; subst;
    exists [UIdent s1]; split; [reflexivity |]; apply dpi_single; constructor; exact Ea).
  (* t2 = UPipe *)
  destruct toks2 as [| t3 toks3].
  { simpl in H. destruct (atom_of_name s1) eqn:Ea; inversion H; subst.
    exists [UIdent s1]; split; [reflexivity |]. apply dpi_single; constructor; exact Ea. }
  destruct t3 as [s2| | | | | | | |]; try (
    simpl in H; destruct (atom_of_name s1) eqn:Ea; inversion H; subst;
    exists [UIdent s1]; split; [reflexivity |]; apply dpi_single; constructor; exact Ea).
  (* t3 = UIdent s2 *)
  simpl in H.
  destruct (andb (String.eqb s1 "relay") (String.eqb s2 "relay")) eqn:Eb; [| discriminate].
  apply andb_true_iff in Eb as [E1 E2]. apply String.eqb_eq in E1, E2. subst.
  inversion H; subst.
  exists [UIdent "relay"; UPipe; UIdent "relay"]; split; [reflexivity |]. apply dpi_pipe.
Qed.

Lemma parse_redir_sound toks y rest :
  parse_redir toks = Some (y, rest) -> exists ts, toks = ts ++ rest /\ redir_derives ts y.
Proof.
  unfold parse_redir. intro H.
  destruct (parse_pipe toks) as [[a2 rp] |] eqn:Ep; [| discriminate].
  destruct rp as [| t rp1].
  - inversion H; subst.
    destruct (parse_pipe_sound _ _ _ Ep) as [ts [Ht Hd]].
    exists ts; split; [rewrite Ht, app_nil_r; reflexivity | apply dre_plain; exact Hd].
  - destruct t; try (
      inversion H; subst;
      destruct (parse_pipe_sound _ _ _ Ep) as [ts [Ht Hd]];
      exists ts; split; [exact Ht |]; apply dre_plain; exact Hd).
    + (* UGt *)
      destruct rp1 as [| t2 rp2]; try (
        inversion H; subst;
        destruct (parse_pipe_sound _ _ _ Ep) as [ts [Ht Hd]];
        exists ts; split; [exact Ht |]; apply dre_plain; exact Hd).
      destruct t2 as [path| | | | | | | |]; try (
        inversion H; subst;
        destruct (parse_pipe_sound _ _ _ Ep) as [ts [Ht Hd]];
        exists ts; split; [exact Ht |]; apply dre_plain; exact Hd).
      inversion H; subst.
      destruct (parse_pipe_sound _ _ _ Ep) as [ts [Ht Hd]].
      exists (ts ++ [UGt; UIdent path]); split.
      * rewrite Ht. rewrite <- app_assoc. reflexivity.
      * apply dre_trunc; exact Hd.
    + (* UGtGt *)
      destruct rp1 as [| t2 rp2]; try (
        inversion H; subst;
        destruct (parse_pipe_sound _ _ _ Ep) as [ts [Ht Hd]];
        exists ts; split; [exact Ht |]; apply dre_plain; exact Hd).
      destruct t2 as [path| | | | | | | |]; try (
        inversion H; subst;
        destruct (parse_pipe_sound _ _ _ Ep) as [ts [Ht Hd]];
        exists ts; split; [exact Ht |]; apply dre_plain; exact Hd).
      inversion H; subst.
      destruct (parse_pipe_sound _ _ _ Ep) as [ts [Ht Hd]].
      exists (ts ++ [UGtGt; UIdent path]); split.
      * rewrite Ht. rewrite <- app_assoc. reflexivity.
      * apply dre_append; exact Hd.
Qed.

Lemma match_urparen_some (X : Type) (l : list utoken) (v y : X) (r : list utoken) :
  match l with URParen :: r' => Some (v, r') | _ => None end = Some (y, r) ->
  exists r', l = URParen :: r' /\ v = y /\ r' = r.
Proof.
  destruct l as [| tk r'].
  - discriminate.
  - destruct tk; try discriminate.
    intro Heq. injection Heq as Hv Hr. exists r'. auto.
Qed.

Ltac redir_case :=
  match goal with
  | H : context [parse_redir ?toksx] |- _ =>
      let y := fresh "y" in let rp := fresh "rp" in let E := fresh "E" in
      let ts := fresh "ts" in let Ht := fresh "Ht" in let Hd := fresh "Hd" in
      destruct (parse_redir toksx) as [[y rp] |] eqn:E; [| discriminate];
      inversion H; subst;
      destruct (parse_redir_sound _ _ _ E) as [ts [Ht Hd]];
      exists ts; split; [exact Ht |]; apply dc_unit; exact Hd
  end.

Definition usound_rcmd fuel := forall toks c rest,
  parse_rcmd fuel toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\ rcmd_derives ts c.
Definition usound_uandor fuel := forall toks c rest,
  parse_uandor fuel toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\ uandor_derives ts c.
Definition usound_uandor_tail fuel := forall acc toks c rest,
  parse_uandor_tail fuel acc toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\
    forall ts0, uandor_derives ts0 acc -> uandor_derives (ts0 ++ ts) c.
Definition usound_ulist fuel := forall toks c rest,
  parse_ulist fuel toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\ ubody_derives ts c.
Definition usound_ulist_tail fuel := forall acc toks c rest,
  parse_ulist_tail fuel acc toks = Some (c, rest) ->
  exists ts, toks = ts ++ rest /\
    forall ts0, ulist_derives ts0 acc -> ubody_derives (ts0 ++ ts) c.

Lemma uparse_sound fuel :
  usound_rcmd fuel /\ usound_uandor fuel /\ usound_uandor_tail fuel /\
  usound_ulist fuel /\ usound_ulist_tail fuel.
Proof.
  induction fuel as [| n [IHc [IHa [IHat [IHl IHlt]]]]].
  { repeat split; red; intros; discriminate. }
  repeat split.
  - (* rcmd *)
    intros toks c rest H. simpl in H.
    destruct toks as [| t toks'].
    + simpl in H. discriminate.
    + destruct t; simpl in H.
      * (* UIdent: parse_redir genuinely depends on toks', stays symbolic *)
        redir_case.
      * discriminate. (* USemi: parse_redir already computes to None *)
      * discriminate. (* UAndAnd *)
      * discriminate. (* UOrOr *)
      * (* ULParen *)
        destruct (parse_ulist n toks') as [[c' rest'] |] eqn:E; [| discriminate].
        destruct (match_urparen_some _ rest' c' c rest H) as [rest0' [Hr' [Hc0 Hrest0]]].
        subst.
        destruct (IHl _ _ _ E) as [ts [Ht Hd]].
        exists (ULParen :: ts ++ [URParen]). split.
        -- rewrite Ht. simpl. rewrite <- app_assoc. reflexivity.
        -- apply dc_paren; exact Hd.
      * discriminate. (* URParen *)
      * discriminate. (* UPipe *)
      * discriminate. (* UGt *)
      * discriminate. (* UGtGt *)
  - (* uandor *)
    intros toks c rest H. simpl in H.
    destruct (parse_rcmd n toks) as [[c1 rest1] |] eqn:E; [| discriminate].
    destruct (IHc _ _ _ E) as [ts1 [Ht1 Hd1]].
    destruct (IHat _ _ _ _ H) as [ts2 [Ht2 Hd2]].
    exists (ts1 ++ ts2). split.
    + rewrite Ht1, Ht2. apply app_assoc.
    + apply Hd2. apply dua_single; exact Hd1.
  - (* uandor_tail *)
    intros acc toks c rest H. simpl in H.
    destruct toks as [| t toks'].
    { inversion H; subst. exists []. split; [reflexivity |].
      intros ts0 Hd. rewrite app_nil_r; exact Hd. }
    destruct t;
      try (inversion H; subst; exists []; split; [reflexivity |];
           intros ts0 Hd; rewrite app_nil_r; exact Hd).
    + (* && *)
      destruct (parse_rcmd n toks') as [[c2 rest2] |] eqn:E; [| discriminate].
      destruct (IHc _ _ _ E) as [ts2 [Ht2 Hd2]].
      destruct (IHat _ _ _ _ H) as [ts3 [Ht3 Hd3]].
      exists (UAndAnd :: ts2 ++ ts3). split.
      * rewrite Ht2, Ht3. simpl. rewrite app_assoc. reflexivity.
      * intros ts0 Hd0.
        specialize (Hd3 (ts0 ++ UAndAnd :: ts2) (dua_and _ _ _ _ Hd0 Hd2)).
        rewrite <- app_assoc in Hd3. exact Hd3.
    + (* || *)
      destruct (parse_rcmd n toks') as [[c2 rest2] |] eqn:E; [| discriminate].
      destruct (IHc _ _ _ E) as [ts2 [Ht2 Hd2]].
      destruct (IHat _ _ _ _ H) as [ts3 [Ht3 Hd3]].
      exists (UOrOr :: ts2 ++ ts3). split.
      * rewrite Ht2, Ht3. simpl. rewrite app_assoc. reflexivity.
      * intros ts0 Hd0.
        specialize (Hd3 (ts0 ++ UOrOr :: ts2) (dua_or _ _ _ _ Hd0 Hd2)).
        rewrite <- app_assoc in Hd3. exact Hd3.
  - (* ulist *)
    intros toks c rest H. simpl in H.
    destruct (parse_uandor n toks) as [[c1 rest1] |] eqn:E; [| discriminate].
    destruct (IHa _ _ _ E) as [ts1 [Ht1 Hd1]].
    destruct (IHlt _ _ _ _ H) as [ts2 [Ht2 Hd2]].
    exists (ts1 ++ ts2). split.
    + rewrite Ht1, Ht2. apply app_assoc.
    + apply Hd2. apply dul_andor; exact Hd1.
  - (* ulist_tail *)
    intros acc toks c rest H. simpl in H.
    destruct toks as [| t toks'].
    { inversion H; subst. exists []. split; [reflexivity |].
      intros ts0 Hd. rewrite app_nil_r. apply dub_body; exact Hd. }
    destruct t;
      try (inversion H; subst; exists []; split; [reflexivity |];
           intros ts0 Hd; rewrite app_nil_r; apply dub_body; exact Hd).
    (* ; *)
    assert (Htrail : forall rest0, Some (acc, rest0) = Some (c, rest) ->
      exists ts, USemi :: rest0 = ts ++ rest /\
        forall ts0, ulist_derives ts0 acc -> ubody_derives (ts0 ++ ts) c).
    { intros rest0 H0. inversion H0; subst.
      exists [USemi]. split; [reflexivity |].
      intros ts0 Hd. apply dub_trailing; exact Hd. }
    destruct toks' as [| t' toks''].
    { exact (Htrail _ H). }
    assert (Hmore : match parse_uandor n (t' :: toks'') with
                    | Some (c0, rest') => parse_ulist_tail n (seq acc c0) rest'
                    | None => None
                    end = Some (c, rest) ->
                    exists ts, USemi :: t' :: toks'' = ts ++ rest /\
                      forall ts0, ulist_derives ts0 acc -> ubody_derives (ts0 ++ ts) c).
    { intro H1.
      destruct (parse_uandor n (t' :: toks'')) as [[c2 rest2] |] eqn:E; [| discriminate].
      destruct (IHa _ _ _ E) as [ts2 [Ht2 Hd2]].
      destruct (IHlt _ _ _ _ H1) as [ts3 [Ht3 Hd3]].
      exists (USemi :: ts2 ++ ts3). split.
      * rewrite Ht2, Ht3. simpl. rewrite app_assoc. reflexivity.
      * intros ts0 Hd0.
        specialize (Hd3 (ts0 ++ USemi :: ts2) (dul_seq _ _ _ _ Hd0 Hd2)).
        rewrite <- app_assoc in Hd3. exact Hd3. }
    destruct t'; try exact (Hmore H).
    exact (Htrail _ H).
Qed.

Theorem parse_utokens_sound toks c :
  parse_utokens toks = Some c -> ubody_derives toks c.
Proof.
  unfold parse_utokens. intro H.
  destruct (parse_ulist (8 * (List.length toks + 1)) toks) as [[c' rest] |] eqn:E;
    [| discriminate].
  destruct rest; [| discriminate]. inversion H; subst.
  destruct (proj1 (proj2 (proj2 (proj2 (uparse_sound _)))) _ _ _ E)
    as [ts [Ht Hd]].
  rewrite app_nil_r in Ht. subst. exact Hd.
Qed.

Theorem parse_program3_sound s c :
  parse_program3 s = Some c ->
  exists toks, ulex_string s = Some toks /\ ubody_derives toks c.
Proof.
  unfold parse_program3. intro H.
  destruct (ulex_string s) as [toks |] eqn:E; [| discriminate].
  exists toks. split; [reflexivity | apply parse_utokens_sound; exact H].
Qed.

(* ================================================================== *)
(* 6. Concrete parses: old accepted cases preserved, new cases added,   *)
(*    explicit unsupported forms rejected (not silently mis-parsed).    *)
(* ================================================================== *)

Example ex_accept_bare_relay :
  parse_program3 "relay" = Some (call (YDirect (FromShell Relay))).
Proof. vm_compute; reflexivity. Qed.

Example ex_accept_bare_mark :
  parse_program3 "mark" = Some (call (YDirect (FromShell (Mark bang)))).
Proof. vm_compute; reflexivity. Qed.

Example ex_accept_pipe :
  parse_program3 "relay | relay" = Some (call (YDirect PipeRR)).
Proof. vm_compute; reflexivity. Qed.

Example ex_accept_gt_out :
  parse_program3 "relay > out" = Some (call (YRedirect false "out" (FromShell Relay))).
Proof. vm_compute; reflexivity. Qed.

Example ex_accept_gtgt_log :
  parse_program3 "relay >> log" = Some (call (YRedirect true "log" (FromShell Relay))).
Proof. vm_compute; reflexivity. Qed.

(* NEW: redirecting a pipe's own output, no parens needed (matches real
   Bash's own precedence: redirection attaches to the pipeline unit). *)
Example ex_accept_pipe_redirect :
  parse_program3 "relay | relay > out" = Some (call (YRedirect false "out" PipeRR)).
Proof. vm_compute; reflexivity. Qed.

(* NEW: composition with ; and && / || over the new atom type. *)
Example ex_accept_seq_redirect :
  parse_program3 "relay ; mark > log" =
    Some (seq (call (YDirect (FromShell Relay)))
              (call (YRedirect false "log" (FromShell (Mark bang))))).
Proof. vm_compute; reflexivity. Qed.

Example ex_accept_and :
  parse_program3 "relay && mark" =
    Some (and_then (call (YDirect (FromShell Relay))) (call (YDirect (FromShell (Mark bang))))).
Proof. vm_compute; reflexivity. Qed.

Example ex_accept_or :
  parse_program3 "relay || mark" =
    Some (or_else (call (YDirect (FromShell Relay))) (call (YDirect (FromShell (Mark bang))))).
Proof. vm_compute; reflexivity. Qed.

(* NEW: parens grouping composed with &&, matching Parse.v's own convention
   that "( c )" denotes c (no subshell-local state). *)
Example ex_accept_paren_and :
  parse_program3 "(relay ; mark) && mark" =
    Some (and_then (seq (call (YDirect (FromShell Relay))) (call (YDirect (FromShell (Mark bang)))))
                   (call (YDirect (FromShell (Mark bang))))).
Proof. vm_compute; reflexivity. Qed.

(* Explicit unsupported forms: rejected, not silently mis-parsed. *)
Example ex_reject_mismatched_pipe :
  parse_program3 "relay | mark" = None.
Proof. vm_compute; reflexivity. Qed.

Example ex_reject_three_stage_pipe :
  parse_program3 "relay | relay | relay" = None.
Proof. vm_compute; reflexivity. Qed.

Example ex_reject_double_redirect :
  parse_program3 "relay > a > b" = None.
Proof. vm_compute; reflexivity. Qed.

Example ex_reject_unknown_name :
  parse_program3 "cat > out" = None.
Proof. vm_compute; reflexivity. Qed.

(* Redirecting a PARENTHESIZED group is unsupported in this fragment (only a
   bare pipe-or-unit carries a redirect); stated, checked, not approximated. *)
Example ex_reject_paren_redirect :
  parse_program3 "(relay | relay) > out" = None.
Proof. vm_compute; reflexivity. Qed.

(* The soundness theorem, applied to one accepted text. *)
Example ex_accept_pipe_redirect_derivation :
  exists toks, ulex_string "relay | relay > out" = Some toks /\
    ubody_derives toks (call (YRedirect false "out" PipeRR)).
Proof. apply parse_program3_sound. vm_compute; reflexivity. Qed.

(* The parsed AST for the NEW pipe-redirect text is exactly the checked
   `pipe_redirect_witness`/`pipe_redirect_observations` run above -- the
   parser and the semantics agree on the same concrete case, not just in
   principle. *)
Example ex_pipe_redirect_runs_as_checked :
  parse_program3 "relay | relay > out" = Some (call (YRedirect false "out" PipeRR)) /\
  yredirect_prim (YRedirect false "out" PipeRR)
    (RState (ShellState demo_producer0 []) empty_files) 0 pipe_redirect_final /\
  rs_files pipe_redirect_final "out" = demo_bytes.
Proof.
  split; [vm_compute; reflexivity |].
  split; [exact pipe_redirect_witness | apply pipe_redirect_observations].
Qed.

End ShellCompose.
