import CalculusCommands
open ShellObservation CalculusCommands

set_option linter.unusedSimpArgs false

/-!
Bounded fail-closed Bash-subset text frontend (Lean).

Port of the Coq shell-bridge/Parse.v fragment (independent inductive grammar +
recursive descent), then map names to Atom.relay / Atom.mark. Composed with
accepted encodeCmd / Query.program. Not completeness, not full Bash, not a
query-text parser.

Blanks: space and tab only. Newline is rejected. Unsupported syntax and
unknown command names fail closed.
-/

namespace CalculusShellText

inductive Token where
  | ident (name : String)
  | semi | andAnd | orOr | lParen | rParen
  deriving DecidableEq, Repr

def isLower (c : Char) : Bool :=
  let n := c.toNat; decide (97 ≤ n ∧ n ≤ 122)
def isUpper (c : Char) : Bool :=
  let n := c.toNat; decide (65 ≤ n ∧ n ≤ 90)
def isDigit (c : Char) : Bool :=
  let n := c.toNat; decide (48 ≤ n ∧ n ≤ 57)
def isUnderscore (c : Char) : Bool := decide (c.toNat = 95)
def isIdentStart (c : Char) : Bool := isLower c || isUpper c || isUnderscore c
def isIdentChar (c : Char) : Bool := isIdentStart c || isDigit c
def isBlank (c : Char) : Bool := decide (c.toNat = 32) || decide (c.toNat = 9)

def reserved (s : String) : Bool :=
  s == "if" || s == "then" || s == "else" || s == "elif" || s == "fi" ||
  s == "case" || s == "esac" || s == "for" || s == "select" || s == "while" ||
  s == "until" || s == "do" || s == "done" || s == "in" || s == "function" ||
  s == "time" || s == "coproc"

def takeIdent : List Char → String × List Char
  | c :: rest =>
      if isIdentChar c then
        let p := takeIdent rest
        (String.ofList [c] ++ p.1, p.2)
      else ("", c :: rest)
  | [] => ("", [])

def lex : Nat → List Char → Option (List Token)
  | 0, _ => none
  | n + 1, cs =>
    match cs with
    | [] => some []
    | c :: rest =>
      if isBlank c then lex n rest
      else if c.toNat = 59 then (lex n rest).map (fun ts => Token.semi :: ts)
      else if c.toNat = 40 then
        match rest with
        | c2 :: _ =>
            if c2.toNat = 40 then none
            else (lex n rest).map (fun ts => Token.lParen :: ts)
        | [] => none
      else if c.toNat = 41 then (lex n rest).map (fun ts => Token.rParen :: ts)
      else if c.toNat = 38 then
        match rest with
        | c2 :: rest2 =>
            if c2.toNat = 38 then (lex n rest2).map (fun ts => Token.andAnd :: ts)
            else none
        | [] => none
      else if c.toNat = 124 then
        match rest with
        | c2 :: rest2 =>
            if c2.toNat = 124 then (lex n rest2).map (fun ts => Token.orOr :: ts)
            else none
        | [] => none
      else if isIdentStart c then
        let p := takeIdent cs
        if reserved p.1 then none
        else (lex n p.2).map (fun ts => Token.ident p.1 :: ts)
      else none

def lexString (s : String) : Option (List Token) :=
  let cs := s.toList
  lex (cs.length + 1) cs

mutual
inductive CmdDerives : List Token → Command String → Prop
  | ident (s : String) : CmdDerives [Token.ident s] (.call s)
  | paren {ts c} : BodyDerives ts c →
      CmdDerives (Token.lParen :: ts ++ [Token.rParen]) c
inductive AndorDerives : List Token → Command String → Prop
  | single {ts c} : CmdDerives ts c → AndorDerives ts c
  | and {ts1 c1 ts2 c2} : AndorDerives ts1 c1 → CmdDerives ts2 c2 →
      AndorDerives (ts1 ++ Token.andAnd :: ts2) (.andThen c1 c2)
  | or {ts1 c1 ts2 c2} : AndorDerives ts1 c1 → CmdDerives ts2 c2 →
      AndorDerives (ts1 ++ Token.orOr :: ts2) (.orElse c1 c2)
inductive ListDerives : List Token → Command String → Prop
  | andor {ts c} : AndorDerives ts c → ListDerives ts c
  | seq {ts1 c1 ts2 c2} : ListDerives ts1 c1 → AndorDerives ts2 c2 →
      ListDerives (ts1 ++ Token.semi :: ts2) (.seq c1 c2)
inductive BodyDerives : List Token → Command String → Prop
  | body {ts c} : ListDerives ts c → BodyDerives ts c
  | trailing {ts c} : ListDerives ts c → BodyDerives (ts ++ [Token.semi]) c
end

mutual
def parseCmd : Nat → List Token → Option (Command String × List Token)
  | 0, _ => none
  | n + 1, toks =>
    match toks with
    | Token.ident s :: rest => some (.call s, rest)
    | Token.lParen :: rest =>
        match parseList n rest with
        | some (c, Token.rParen :: rest') => some (c, rest')
        | _ => none
    | _ => none
def parseAndor : Nat → List Token → Option (Command String × List Token)
  | 0, _ => none
  | n + 1, toks =>
    match parseCmd n toks with
    | some (c, rest) => parseAndorTail n c rest
    | none => none
def parseAndorTail : Nat → Command String → List Token → Option (Command String × List Token)
  | 0, _, _ => none
  | n + 1, acc, toks =>
    match toks with
    | Token.andAnd :: rest =>
        match parseCmd n rest with
        | some (c, rest') => parseAndorTail n (.andThen acc c) rest'
        | none => none
    | Token.orOr :: rest =>
        match parseCmd n rest with
        | some (c, rest') => parseAndorTail n (.orElse acc c) rest'
        | none => none
    | _ => some (acc, toks)
def parseList : Nat → List Token → Option (Command String × List Token)
  | 0, _ => none
  | n + 1, toks =>
    match parseAndor n toks with
    | some (c, rest) => parseListTail n c rest
    | none => none
def parseListTail : Nat → Command String → List Token → Option (Command String × List Token)
  | 0, _, _ => none
  | n + 1, acc, toks =>
    match toks with
    | Token.semi :: rest =>
        match rest with
        | [] => some (acc, rest)
        | Token.rParen :: _ => some (acc, rest)
        | _ =>
          match parseAndor n rest with
          | some (c, rest') => parseListTail n (.seq acc c) rest'
          | none => none
    | _ => some (acc, toks)
end

def parseTokens (toks : List Token) : Option (Command String) :=
  match parseList (8 * (toks.length + 1)) toks with
  | some (c, []) => some c
  | _ => none

def parseProgram (s : String) : Option (Command String) :=
  match lexString s with
  | some toks => parseTokens toks
  | none => none

def atomOf (s : String) : Option Atom :=
  if s == "relay" then some .relay
  else if s == "mark" then some .mark
  else none

def mapCommand : Command String → Option (Command Atom)
  | .call a => (atomOf a).map Command.call
  | .seq x y =>
      match mapCommand x, mapCommand y with
      | some x', some y' => some (.seq x' y')
      | _, _ => none
  | .andThen x y =>
      match mapCommand x, mapCommand y with
      | some x', some y' => some (.andThen x' y')
      | _, _ => none
  | .orElse x y =>
      match mapCommand x, mapCommand y with
      | some x', some y' => some (.orElse x' y')
      | _, _ => none

def parseSupported (s : String) : Option (Command Atom) :=
  match parseProgram s with
  | some c => mapCommand c
  | none => none

end CalculusShellText
