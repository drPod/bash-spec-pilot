import CalculusShellText
open CalculusShellText
open CalculusCommands
open ShellObservation

set_option linter.unusedSimpArgs false
set_option maxHeartbeats 400000

/-!
Parser soundness vs independently defined BodyDerives (Coq Parse.v style).
Fuel induction; no sorry / native_decide / new axioms.
-/

namespace CalculusShellTextSound

def SoundCmd (fuel : Nat) : Prop :=
  ∀ toks c rest,
    parseCmd fuel toks = some (c, rest) →
    ∃ ts, toks = ts ++ rest ∧ CmdDerives ts c

def SoundAndor (fuel : Nat) : Prop :=
  ∀ toks c rest,
    parseAndor fuel toks = some (c, rest) →
    ∃ ts, toks = ts ++ rest ∧ AndorDerives ts c

def SoundAndorTail (fuel : Nat) : Prop :=
  ∀ acc toks c rest,
    parseAndorTail fuel acc toks = some (c, rest) →
    ∃ ts, toks = ts ++ rest ∧
      ∀ ts0, AndorDerives ts0 acc → AndorDerives (ts0 ++ ts) c

def SoundList (fuel : Nat) : Prop :=
  ∀ toks c rest,
    parseList fuel toks = some (c, rest) →
    ∃ ts, toks = ts ++ rest ∧ BodyDerives ts c

def SoundListTail (fuel : Nat) : Prop :=
  ∀ acc toks c rest,
    parseListTail fuel acc toks = some (c, rest) →
    ∃ ts, toks = ts ++ rest ∧
      ∀ ts0, ListDerives ts0 acc → BodyDerives (ts0 ++ ts) c

theorem sound_zero :
    SoundCmd 0 ∧ SoundAndor 0 ∧ SoundAndorTail 0 ∧ SoundList 0 ∧ SoundListTail 0 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro toks c rest h; cases h
  · intro toks c rest h; cases h
  · intro acc toks c rest h; cases h
  · intro toks c rest h; cases h
  · intro acc toks c rest h; cases h

theorem sound_cmd_succ (n : Nat)
    (IHl : SoundList n) : SoundCmd (n + 1) := by
  intro toks c rest h
  cases toks with
  | nil => cases h
  | cons t toks' =>
    cases t with
    | ident s =>
      cases h
      exact ⟨[Token.ident s], rfl, CmdDerives.ident s⟩
    | lParen =>
      cases hList : parseList n toks' with
      | none =>
        simp [parseCmd, hList] at h
      | some p =>
        rcases p with ⟨c', rest'⟩
        cases rest' with
        | nil =>
          simp [parseCmd, hList] at h
        | cons t' rest'' =>
          cases t' with
          | rParen =>
            simp [parseCmd, hList] at h
            rcases h with ⟨hc, hr⟩
            rcases IHl toks' c' (Token.rParen :: rest'') hList with ⟨ts, ht, hd⟩
            refine ⟨Token.lParen :: ts ++ [Token.rParen], ?_, ?_⟩
            · rw [ht, ← hr]; simp [List.append_assoc]
            · rw [← hc]; exact CmdDerives.paren hd
          | _ =>
            simp [parseCmd, hList] at h
    | _ =>
      simp [parseCmd] at h

theorem sound_andor_succ (n : Nat)
    (IHc : SoundCmd n) (IHat : SoundAndorTail n) : SoundAndor (n + 1) := by
  intro toks c rest h
  cases hCmd : parseCmd n toks with
  | none =>
    simp [parseAndor, hCmd] at h
  | some p =>
    rcases p with ⟨c1, rest1⟩
    simp [parseAndor, hCmd] at h
    rcases IHc toks c1 rest1 hCmd with ⟨ts1, ht1, hd1⟩
    rcases IHat c1 rest1 c rest h with ⟨ts2, ht2, hd2⟩
    refine ⟨ts1 ++ ts2, ?_, hd2 ts1 (AndorDerives.single hd1)⟩
    simp [ht1, ht2, List.append_assoc]

theorem sound_andor_tail_succ (n : Nat)
    (IHc : SoundCmd n) (IHat : SoundAndorTail n) : SoundAndorTail (n + 1) := by
  intro acc toks c rest h
  cases toks with
  | nil =>
    cases h
    refine ⟨[], rfl, ?_⟩
    intro ts0 hd; simpa using hd
  | cons t toks' =>
    cases t with
    | andAnd =>
      cases hCmd : parseCmd n toks' with
      | none =>
        simp [parseAndorTail, hCmd] at h
      | some p =>
        rcases p with ⟨c2, rest2⟩
        simp [parseAndorTail, hCmd] at h
        rcases IHc toks' c2 rest2 hCmd with ⟨ts2, ht2, hd2⟩
        rcases IHat (.andThen acc c2) rest2 c rest h with ⟨ts3, ht3, hd3⟩
        refine ⟨Token.andAnd :: ts2 ++ ts3, ?_, ?_⟩
        · simp [ht2, ht3, List.append_assoc]
        · intro ts0 hd0
          have := hd3 (ts0 ++ Token.andAnd :: ts2) (AndorDerives.and hd0 hd2)
          simpa [List.append_assoc] using this
    | orOr =>
      cases hCmd : parseCmd n toks' with
      | none =>
        simp [parseAndorTail, hCmd] at h
      | some p =>
        rcases p with ⟨c2, rest2⟩
        simp [parseAndorTail, hCmd] at h
        rcases IHc toks' c2 rest2 hCmd with ⟨ts2, ht2, hd2⟩
        rcases IHat (.orElse acc c2) rest2 c rest h with ⟨ts3, ht3, hd3⟩
        refine ⟨Token.orOr :: ts2 ++ ts3, ?_, ?_⟩
        · simp [ht2, ht3, List.append_assoc]
        · intro ts0 hd0
          have := hd3 (ts0 ++ Token.orOr :: ts2) (AndorDerives.or hd0 hd2)
          simpa [List.append_assoc] using this
    | _ =>
      cases h
      refine ⟨[], rfl, ?_⟩
      intro ts0 hd; simpa using hd

theorem sound_list_succ (n : Nat)
    (IHa : SoundAndor n) (IHlt : SoundListTail n) : SoundList (n + 1) := by
  intro toks c rest h
  cases hA : parseAndor n toks with
  | none =>
    simp [parseList, hA] at h
  | some p =>
    rcases p with ⟨c1, rest1⟩
    simp [parseList, hA] at h
    rcases IHa toks c1 rest1 hA with ⟨ts1, ht1, hd1⟩
    rcases IHlt c1 rest1 c rest h with ⟨ts2, ht2, hd2⟩
    refine ⟨ts1 ++ ts2, ?_, hd2 ts1 (ListDerives.andor hd1)⟩
    simp [ht1, ht2, List.append_assoc]

theorem list_tail_continue (n : Nat)
    (IHa : SoundAndor n) (IHlt : SoundListTail n)
    (acc c : Command String) (rest restToks : List Token)
    (h : (match parseAndor n restToks with
          | some (c2, rest2) => parseListTail n (acc.seq c2) rest2
          | none => none) = some (c, rest)) :
    ∃ ts, Token.semi :: restToks = ts ++ rest ∧
      ∀ ts0, ListDerives ts0 acc → BodyDerives (ts0 ++ ts) c := by
  cases hA : parseAndor n restToks with
  | none =>
    simp [hA] at h
  | some p =>
    rcases p with ⟨c2, rest2⟩
    simp [hA] at h
    rcases IHa restToks c2 rest2 hA with ⟨ts2, ht2, hd2⟩
    rcases IHlt (.seq acc c2) rest2 c rest h with ⟨ts3, ht3, hd3⟩
    refine ⟨Token.semi :: ts2 ++ ts3, ?_, ?_⟩
    · simp [ht2, ht3, List.append_assoc]
    · intro ts0 hd0
      have := hd3 (ts0 ++ Token.semi :: ts2) (ListDerives.seq hd0 hd2)
      simpa [List.append_assoc] using this

theorem sound_list_tail_succ (n : Nat)
    (IHa : SoundAndor n) (IHlt : SoundListTail n) : SoundListTail (n + 1) := by
  intro acc toks c rest h
  cases toks with
  | nil =>
    cases h
    refine ⟨[], rfl, ?_⟩
    intro ts0 hd
    simpa using BodyDerives.body hd
  | cons t toks' =>
    cases t with
    | semi =>
      cases toks' with
      | nil =>
        cases h
        refine ⟨[Token.semi], rfl, ?_⟩
        intro ts0 hd
        simpa using BodyDerives.trailing hd
      | cons t' toks'' =>
        cases t' with
        | rParen =>
          cases h
          refine ⟨[Token.semi], rfl, ?_⟩
          intro ts0 hd
          simpa using BodyDerives.trailing hd
        | ident s =>
          simp [parseListTail] at h
          exact list_tail_continue n IHa IHlt acc c rest (Token.ident s :: toks'') h
        | semi =>
          simp [parseListTail] at h
          exact list_tail_continue n IHa IHlt acc c rest (Token.semi :: toks'') h
        | andAnd =>
          simp [parseListTail] at h
          exact list_tail_continue n IHa IHlt acc c rest (Token.andAnd :: toks'') h
        | orOr =>
          simp [parseListTail] at h
          exact list_tail_continue n IHa IHlt acc c rest (Token.orOr :: toks'') h
        | lParen =>
          simp [parseListTail] at h
          exact list_tail_continue n IHa IHlt acc c rest (Token.lParen :: toks'') h
    | _ =>
      cases h
      refine ⟨[], rfl, ?_⟩
      intro ts0 hd
      simpa using BodyDerives.body hd

theorem parse_sound (fuel : Nat) :
    SoundCmd fuel ∧ SoundAndor fuel ∧ SoundAndorTail fuel ∧
      SoundList fuel ∧ SoundListTail fuel := by
  induction fuel with
  | zero => exact sound_zero
  | succ n ih =>
    rcases ih with ⟨IHc, IHa, IHat, IHl, IHlt⟩
    exact ⟨
      sound_cmd_succ n IHl,
      sound_andor_succ n IHc IHat,
      sound_andor_tail_succ n IHc IHat,
      sound_list_succ n IHa IHlt,
      sound_list_tail_succ n IHa IHlt
    ⟩

theorem parseTokens_sound (toks : List Token) (c : Command String) :
    parseTokens toks = some c → BodyDerives toks c := by
  intro h
  unfold parseTokens at h
  cases hL : parseList (8 * (toks.length + 1)) toks with
  | none => simp [hL] at h
  | some p =>
    rcases p with ⟨c', rest⟩
    cases rest with
    | cons _ _ => simp [hL] at h
    | nil =>
      simp [hL] at h
      have sl := (parse_sound (8 * (toks.length + 1))).2.2.2.1
      rcases sl toks c' [] hL with ⟨ts, ht, hd⟩
      rw [← h]
      simpa [ht] using hd

theorem parseProgram_sound (s : String) (c : Command String) :
    parseProgram s = some c →
      ∃ toks, lexString s = some toks ∧ BodyDerives toks c := by
  intro h
  unfold parseProgram at h
  revert h
  cases (lexString s) with
  | none => intro h; cases h
  | some toks =>
    intro h
    exact ⟨toks, rfl, parseTokens_sound toks c h⟩

theorem parseSupported_sound (s : String) (c : Command Atom) :
    parseSupported s = some c →
      ∃ toks cstr,
        lexString s = some toks ∧
        BodyDerives toks cstr ∧
        mapCommand cstr = some c := by
  intro h
  unfold parseSupported at h
  revert h
  cases hP : parseProgram s with
  | none => intro h; simp [hP] at h
  | some cstr =>
    intro h
    simp at h
    rcases parseProgram_sound s cstr hP with ⟨toks, hLex, hd⟩
    exact ⟨toks, cstr, hLex, hd, h⟩

#print axioms parse_sound
#print axioms parseTokens_sound
#print axioms parseProgram_sound
#print axioms parseSupported_sound

end CalculusShellTextSound
