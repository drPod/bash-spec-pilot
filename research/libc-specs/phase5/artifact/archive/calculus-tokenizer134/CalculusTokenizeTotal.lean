import CalculusExport

/-!
Total fail-closed tokenizer for CLI drivers (harness-total-119).

Does **not** import `CalculusTokenize` (that module pulls `CalculusRelayOuter` and the
proof stack). The functions below match `CalculusTokenize.tokenizeTotal` / `parseText`:
structurally recursive, `none` on unterminated string or fuel exhaustion, `parseStmt`
must consume the whole token stream.
-/

open CalculusExport
open CalculusNested

namespace CalculusTokenizeTotal

def isSpaceT (c : Char) : Bool := c = ' ' || c = '\n' || c = '\t' || c = '\r'
def isAtomCharT (c : Char) : Bool := !isSpaceT c && c ≠ '(' && c ≠ ')' && c ≠ '"'

def scanStringT (acc : String) : List Char → Option (String × List Char)
  | [] => none
  | '"' :: rest => some (acc ++ "\"", rest)
  | '\\' :: c :: rest => scanStringT (acc ++ "\\" ++ String.ofList [c]) rest
  | c :: rest => scanStringT (acc ++ String.ofList [c]) rest

def atomT : List Char → List Char × List Char
  | [] => ([], [])
  | c :: rest => if isAtomCharT c then
      let (a, r) := atomT rest
      (c :: a, r)
    else ([], c :: rest)

def tokenizeT : Nat → List Char → Option (List String)
  | 0, _ => none
  | _ + 1, [] => some []
  | fuel + 1, '(' :: rest => (tokenizeT fuel rest).map ("(" :: ·)
  | fuel + 1, ')' :: rest => (tokenizeT fuel rest).map (")" :: ·)
  | fuel + 1, '"' :: rest =>
    match scanStringT "" rest with
    | some (body, rest') => (tokenizeT fuel rest').map (("\"" ++ body) :: ·)
    | none => none
  | fuel + 1, c :: rest =>
    if isSpaceT c then tokenizeT fuel rest
    else
      let (a, r) := atomT rest
      (tokenizeT fuel r).map ((String.ofList (c :: a)) :: ·)

def tokenizeTotal (s : String) : Option (List String) := tokenizeT (s.length + 1) s.toList

def parseText (s : String) : Option (Stmt String) :=
  match tokenizeTotal s with
  | some toks =>
    match parseStmt 400 toks with
    | some (st, []) => some st
    | _ => none
  | none => none

end CalculusTokenizeTotal
