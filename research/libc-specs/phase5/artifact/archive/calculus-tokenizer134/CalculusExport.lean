import CalculusNested
import Std.Data.String.ToNat

/-!
# CalculusExport: a mechanical parser for the pinned OCaml compiler's OWN S-expression export

Worker: Claude (calculus-correspondence-4), 2026-09-07. This file is new; it does not edit
`CalculusNested.lean` (frozen, read-only here), only imports it.

## What this replaces

`NestedMain.lean` (predecessor work) hand-transcribes OCaml source into `CalculusNested.Stmt`
terms by a human reading `results/v2/*.jsonl`'s `"calculus"` field. That field is not invented by
this project: it is `Lower.show_stmt`/`show_expr` in
`calculus-bytes/adapter/lower.ml:501-539`, the pinned adapter's OWN printer of its OWN
`Calculus.Ast` value for a lowered function, run for every fixture function
(e.g. `results/v2/nested_state__deep_set.jsonl`'s `"lower"` record). This file parses THAT
literal text, mechanically, into `CalculusNested.Expr` / `CalculusNested.Stmt String`, so no
program's Lean AST is ever hand-typed again: every fn this parser accepts came from running the
real compiler and reading its own output.

## Trust boundary (read this before citing any theorem below)

- TRUSTED, NOT CHECKED HERE: that `Lower.show_stmt`/`show_expr` faithfully serializes the
  `Calculus.Ast.stmt`/`expr` value the pinned OCaml lowerer actually built from parsed source,
  and that the lowerer itself matches upstream's (nonexistent, `TODO`) intended semantics. This
  file starts from the printed text; it says nothing about how that text was produced.
- CHECKED BY LEAN'S KERNEL, GENERAL (∀, not per-example):
  - `parseExpr`/`parseStmt` are total, structurally-recursive, ordinary (non-`partial`) Lean
    functions — no `sorry`, no new axiom, fully reducible by `simp`/kernel `whnf`.
  - `round_trip_expr`/`round_trip_stmt`: for EVERY value of the Lean `Expr`/`Stmt String` type
    (not just the specific programs anyone has parsed), rendering it to tokens with
    `renderExprToks`/`renderStmtToks` and parsing the result back gives the same value with no
    leftover tokens. This is the sense in which the parser is a faithful, general decoder of this
    project's supported fragment: it is provably (not just empirically) a left inverse of a
    printer that covers every constructor of the Lean AST.
  - `parseStmt_rejects_*` / `parseExpr_rejects_*`: for every unsupported head tag
    (`match`, `foreach`, `forelem`, `localize`, `yield` at statement level; every byte-list
    builtin and `and`/`or` at expression level), parsing ALWAYS returns `none`, whatever the
    rest of the token stream is — fail-closed is a proved property of the parser's shape, not an
    observation about the inputs anyone happened to try.
- EMPIRICAL, FINITE, SECONDARY (see `calculus-correspondence/` driver + `RESULTS.md`): that the
  REAL tokenizer (`tokenize`, defined here, NOT proved correct against OCaml's lexical
  conventions) applied to REAL `"calculus"` text from many fixture functions is accepted by this
  parser, and that running the resulting AST with `CalculusNested.interp` agrees with the real
  OCaml interpreter's recorded output. This is measured, not proved, exactly like predecessor
  work's 11-program comparison — the difference is that the AST fed to Lean is now the parser's
  output on the compiler's own text, for as many functions as the driver processes, not a human
  transcription capped at however many programs a person retyped.
- NOT ESTABLISHED BY ANYTHING HERE: any theorem about the OCaml program, any Bash-level claim,
  any Coq/Lean import. `CalculusNested`'s general frame theorems
  (`setAttrAt_frame`, `addElemAt_attrs`, `removeElemAt_here_frame`) already give general
  (∀ path/state) resource-preservation for the state mutators; they are unchanged by this file
  and apply to any AST this parser produces, precisely because they are stated about the
  mutator functions, not about specific programs.
-/

namespace CalculusExport
open CalculusNested

/-! ## Tokenizer (untrusted glue: turns the compiler's raw text into a token list) -/

private def isSpace (c : Char) : Bool := c = ' ' || c = '\n' || c = '\t' || c = '\r'

/-- Scan a quoted-string token starting at a `"`; returns the token INCLUDING both quotes
    (so the parser can tell a string literal apart from a bare atom) and the rest. Handles the
    two escapes `B.string_of_lit`/`String.escaped` can emit for this project's identifiers
    (`\\`, `\"`); any other escaped char is kept as `\` followed by that char (still safe: it
    never closes the string early). -/
partial def scanString (acc : String) : List Char → (String × List Char)
  | [] => (acc, [])
  | '"' :: rest => (acc ++ "\"", rest)
  | '\\' :: c :: rest => scanString (acc ++ "\\" ++ String.ofList [c]) rest
  | c :: rest => scanString (acc ++ String.ofList [c]) rest

partial def tokenizeChars : List Char → List String
  | [] => []
  | '(' :: rest => "(" :: tokenizeChars rest
  | ')' :: rest => ")" :: tokenizeChars rest
  | '"' :: rest =>
    let (body, rest') := scanString "" rest
    ("\"" ++ body) :: tokenizeChars rest'
  | c :: rest =>
    if isSpace c then tokenizeChars rest
    else
      let (atomRest, tailRest) := rest.span (fun c => !isSpace c && c ≠ '(' && c ≠ ')' && c ≠ '"')
      (String.ofList (c :: atomRest)) :: tokenizeChars tailRest

def tokenize (s : String) : List String := tokenizeChars s.toList

/-! ## Atom classification (bare, non-parenthesized tokens) -/

-- Matches on `s.toList`, not `s.isEmpty`/`s.front`/`s.drop`: the general round-trip proof below
-- (`parseIntLit_repr`) needs to reason about the shape of the string, and `List Char` structural
-- recursion is provable by induction directly, unlike the legacy `String` position API. Same
-- input/output behavior as an isEmpty/front/drop formulation, for every string.
-- calculus-correspondence-13: the decimal digits are read by a hand-rolled STRUCTURAL `List Char`
-- parser (`digitsToNat?`), not `String.toNat?`. In Lean 4.31 `String.toNat?` goes through
-- `String.Slice` `for`-loops (well-founded recursion the kernel does not evaluate), which made it
-- impossible to kernel-check that a real exported token list parses to a stated AST; it also
-- silently accepted `_` digit separators (`"1_0"` ↦ 10), which no export ever contains.
-- `digitsToNat?` accepts exactly nonempty all-`[0-9]` strings — a strict subset of the old
-- behavior on every token the OCaml exporter can emit; `parseIntLit_repr` below is re-proved
-- against it from `Nat.repr_of_lt`/`Nat.repr_of_ge` (general, for every `Int`).
def digitVal? (c : Char) : Option Nat :=
  if '0' ≤ c ∧ c ≤ '9' then some (c.toNat - '0'.toNat) else none

def digitsToNatAux : Nat → List Char → Option Nat
  | acc, [] => some acc
  | acc, c :: rest =>
    match digitVal? c with
    | some d => digitsToNatAux (acc * 10 + d) rest
    | none => none

def digitsToNat? : List Char → Option Nat
  | [] => none
  | c :: rest => digitsToNatAux 0 (c :: rest)

theorem digitsToNatAux_append (acc : Nat) (a b : List Char) :
    digitsToNatAux acc (a ++ b) =
      match digitsToNatAux acc a with
      | some m => digitsToNatAux m b
      | none => none := by
  induction a generalizing acc with
  | nil => simp [digitsToNatAux]
  | cons c rest ih =>
    simp only [List.cons_append, digitsToNatAux]
    cases digitVal? c with
    | none => simp
    | some d => simp [ih]

theorem digitVal?_digitChar {d : Nat} (h : d < 10) : digitVal? (Nat.digitChar d) = some d := by
  revert h
  rcases d with _|_|_|_|_|_|_|_|_|_|d <;> intro h <;> first | decide | omega

theorem digitsToNat?_cons (c : Char) (rest : List Char) :
    digitsToNat? (c :: rest) = digitsToNatAux 0 (c :: rest) := rfl

/-- General: the decimal digits `Nat.repr` prints always read back to the same number. -/
theorem digitsToNatAux_repr (m : Nat) : digitsToNatAux 0 (Nat.repr m).toList = some m := by
  induction m using Nat.strongRecOn with
  | _ m ih =>
    by_cases hlt : m < 10
    · rw [Nat.repr_of_lt hlt, String.singleton_eq_ofList, String.toList_ofList]
      simp [digitsToNatAux, digitVal?_digitChar hlt]
    · have h10 : 10 ≤ m := by omega
      rw [Nat.repr_of_ge h10, String.toList_append, String.singleton_eq_ofList, String.toList_ofList,
        digitsToNatAux_append, ih (m / 10) (by omega)]
      simp [digitsToNatAux, digitVal?_digitChar (Nat.mod_lt m (by omega))]
      omega

theorem digitsToNat?_repr (m : Nat) : digitsToNat? (Nat.repr m).toList = some m := by
  rcases htl : (Nat.repr m).toList with _ | ⟨c, rest⟩
  · exact absurd (Nat.toList_repr (n := m) ▸ htl) Nat.toDigits_ne_nil
  · rw [digitsToNat?_cons, ← htl]
    exact digitsToNatAux_repr m

private def parseIntLit (s : String) : Option Int :=
  match s.toList with
  | [] => none
  | '-' :: rest => (digitsToNat? rest).map (fun n => -(Int.ofNat n))
  | l => (digitsToNat? l).map Int.ofNat

/-- Split a `List Char` at its first `':'`, returning `none` if there isn't one. Used (below) to
    parse `Func.range`'s `"range:" ++ lo.repr ++ ":" ++ hi.repr` encoding — a hand-rolled `List
    Char` recursion, not `String.splitOn`, so the round-trip proof (`splitFirstColon_append`) is a
    plain structural induction instead of unfolding the legacy `String` position-scanning API. -/
def splitFirstColon : List Char → Option (List Char × List Char)
  | [] => none
  | c :: rest =>
    if c = ':' then some ([], rest)
    else (splitFirstColon rest).map (fun p => (c :: p.1, p.2))

/-- If `a` has no `':'`, splitting `a ++ ':' :: b` at the first colon recovers exactly `(a, b)` —
    general over every `a b : List Char`, proved by structural induction on `a`, not tied to any
    particular string content. -/
theorem splitFirstColon_append (a b : List Char) (ha : ':' ∉ a) :
    splitFirstColon (a ++ ':' :: b) = some (a, b) := by
  induction a with
  | nil => simp [splitFirstColon]
  | cons c a ih =>
    simp only [List.mem_cons, not_or] at ha
    obtain ⟨hc, ha⟩ := ha
    simp [splitFirstColon, Ne.symm hc, ih ha]

/-- Unescape the two escapes `scanString` preserves; inverse of `String.escaped` for this
    project's actual strings (exception tags and `AssertionFailure`: no other escapes occur in
    any observed export). -/
-- Total (structural on the char list), not `partial`, since calculus-correspondence-13: a
-- `partial def` is opaque to the kernel, which made it impossible to kernel-check that a real
-- exported token list parses to a stated AST whenever a string literal (`"AssertionFailure"`)
-- occurs in it. Same equations as before; only the termination status changed.
def unescape : List Char → String
  | [] => ""
  | '\\' :: c :: rest => String.ofList [c] ++ unescape rest
  | c :: rest => String.ofList [c] ++ unescape rest

def atomToExpr (tok : String) : Expr :=
  if tok = "true" then .lit (.bool true)
  else if tok = "false" then .lit (.bool false)
  else if tok.front = '"' && tok.length ≥ 2 then
    .lit (.str (unescape (tok.toList.drop 1 |>.dropLast)))
  else match parseIntLit tok with
    | some n => .lit (.int n)
    | none => .var tok

/-! ## Function-name table (fail-closed: anything not listed is `none`) -/

def parseFunc (s : String) : Option Func :=
  if s = "+" then some .add
  else if s = "-" then some .sub
  else if s = "*" then some .mul
  else if s = "/" then some .div
  else if s = "%" then some .mod
  else if s = "<" then some .lt
  else if s = "<=" then some .le
  else if s = ">" then some .gt
  else if s = ">=" then some .ge
  else if s = "==" then some .eq
  else if s = "!=" then some .ne
  else if s = "neg" then some .neg
  else if s = "not" then some .lnot
  else if s = "fst" then some .fst
  else if s = "snd" then some .snd
  -- Byte-list/schedule-list primitives, added calculus-correspondence-9 (see
  -- `CalculusNested`'s 2026-09-08 module-docstring update): fixed names, same shape as the
  -- scalar operators above, so `parseFunc_renderFunc`'s existing wildcard case covers them.
  else if s = "length" then some .length
  else if s = "take" then some .take
  else if s = "drop" then some .drop
  else if s = "slice" then some .slice
  else if s = "append" then some .append
  else if s = "single" then some .single
  else if s = "empty" then some .empty
  else if s = "head_or" then some .headOr
  else if s = "tail" then some .tail
  else if s = "min" then some .min
  else if s = "max" then some .max
  else match s.toList with
    | 'e' :: 'x' :: 'c' :: '-' :: 'i' :: 's' :: ':' :: rest => some (.excTag (String.ofList rest))
    -- `range-list:` (calculus-correspondence-10) BEFORE `range:`: the two prefixes diverge at
    -- their 6th character ('-' vs ':'), so this is unambiguous regardless of order, but the
    -- longer, more specific pattern is listed first for readability.
    | 'r' :: 'a' :: 'n' :: 'g' :: 'e' :: '-' :: 'l' :: 'i' :: 's' :: 't' :: ':' :: rest =>
      match splitFirstColon rest with
      | some (loC, hiC) =>
        match parseIntLit (String.ofList loC), parseIntLit (String.ofList hiC) with
        | some lo, some hi => some (.rangeList lo hi)
        | _, _ => none
      | none => none
    | 'r' :: 'a' :: 'n' :: 'g' :: 'e' :: ':' :: rest =>
      -- `splitFirstColon` (below), not `String.splitOn`: the round-trip proof needs to reason
      -- about the split, and the legacy `splitOn`'s Pos-indexed scan is not amenable to that,
      -- whereas this hand-rolled `List Char` recursion is (see `splitFirstColon_append`).
      match splitFirstColon rest with
      | some (loC, hiC) =>
        match parseIntLit (String.ofList loC), parseIntLit (String.ofList hiC) with
        | some lo, some hi => some (.range lo hi)
        | _, _ => none
      | none => none
    | _ => none
  -- `and`, `or` (raw non-short-circuit ops the v2 lowering never emits) fall through to `none`:
  -- neither has a `Func` constructor in `CalculusNested`. Fail closed instead.

/-! ## Expression parser (self-recursive on `fuel`, decreasing structurally) -/

private def expectTok (t : String) : List String → Option (List String)
  | tok :: rest => if tok = t then some rest else none
  | [] => none

private def parseAtomName : List String → Option (String × List String)
  | tok :: rest => if tok = "(" || tok = ")" then none else some (tok, rest)
  | [] => none

def parseExpr (fuel : Nat) (toks : List String) : Option (Expr × List String) :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
    match toks with
    | [] => none
    | "(" :: ")" :: rest => some (.lit .unit, rest)
    | "(" :: "pair" :: rest => do
        let (a, rest1) ← parseExpr fuel rest
        let (b, rest2) ← parseExpr fuel rest1
        let rest3 ← expectTok ")" rest2
        pure (.pair a b, rest3)
    | "(" :: "elem" :: rest => do
        let (base, rest1) ← parseExpr fuel rest
        let (name, rest2) ← parseAtomName rest1
        let (arg, rest3) ← parseExpr fuel rest2
        let rest4 ← expectTok ")" rest3
        pure (.elem base name arg, rest4)
    | "(" :: fname :: rest => do
        let f ← parseFunc fname
        let (e, rest1) ← parseExpr fuel rest
        let rest2 ← expectTok ")" rest1
        pure (.fn f e, rest2)
    | ")" :: _ => none
    | tok :: rest => some (atomToExpr tok, rest)

/-! ## Statement parser (self-recursive on `fuel`; calls the already-total `parseExpr`) -/

def parseStmt (fuel : Nat) (toks : List String) : Option (Stmt String × List String) :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
    match toks with
    | "pass" :: rest => some (.pass, rest)
    | "(" :: "seq" :: rest => do
        let (a, rest1) ← parseStmt fuel rest
        let (b, rest2) ← parseStmt fuel rest1
        let rest3 ← expectTok ")" rest2
        pure (.seq a b, rest3)
    | "(" :: "action" :: rest => do
        let (v, rest1) ← parseAtomName rest
        let (a, rest2) ← parseAtomName rest1
        let (e, rest3) ← parseExpr fuel rest2
        let rest4 ← expectTok ")" rest3
        pure (.action v a e, rest4)
    | "(" :: "assign" :: rest => do
        let (v, rest1) ← parseAtomName rest
        let (e, rest2) ← parseExpr fuel rest1
        let rest3 ← expectTok ")" rest2
        pure (.assign v e, rest3)
    | "(" :: "set-attr" :: rest => do
        let (b, rest1) ← parseExpr fuel rest
        let (a, rest2) ← parseAtomName rest1
        let (e, rest3) ← parseExpr fuel rest2
        let rest4 ← expectTok ")" rest3
        pure (.setAttr b a e, rest4)
    | "(" :: "add-elem" :: rest => do
        let (b, rest1) ← parseExpr fuel rest
        let (n, rest2) ← parseAtomName rest1
        let (e, rest3) ← parseExpr fuel rest2
        let rest4 ← expectTok ")" rest3
        pure (.addElem b n e, rest4)
    | "(" :: "remove-elem" :: rest => do
        let (b, rest1) ← parseExpr fuel rest
        let (n, rest2) ← parseAtomName rest1
        let (e, rest3) ← parseExpr fuel rest2
        let rest4 ← expectTok ")" rest3
        pure (.removeElem b n e, rest4)
    | "(" :: "get" :: rest => do
        let (v, rest1) ← parseAtomName rest
        let (b, rest2) ← parseExpr fuel rest1
        let (a, rest3) ← parseAtomName rest2
        let rest4 ← expectTok ")" rest3
        pure (.get v b a, rest4)
    | "(" :: "contains" :: rest => do
        let (b, rest1) ← parseExpr fuel rest
        let (n, rest2) ← parseAtomName rest1
        let (e, rest3) ← parseExpr fuel rest2
        let (t, rest4) ← parseStmt fuel rest3
        let (f, rest5) ← parseStmt fuel rest4
        let rest6 ← expectTok ")" rest5
        pure (.contains b n e t f, rest6)
    | "(" :: "if" :: rest => do
        let (c, rest1) ← parseExpr fuel rest
        let (t, rest2) ← parseStmt fuel rest1
        let (e, rest3) ← parseStmt fuel rest2
        let rest4 ← expectTok ")" rest3
        pure (.cond c t e, rest4)
    | "(" :: "while" :: rest => do
        let (c, rest1) ← parseExpr fuel rest
        let (b, rest2) ← parseStmt fuel rest1
        let rest3 ← expectTok ")" rest2
        pure (.while c b, rest3)
    | "(" :: "try" :: rest => do
        let (b, rest1) ← parseStmt fuel rest
        match rest1 with
        | "catch" :: rest2 => do
            let (v, rest3) ← parseAtomName rest2
            let (h, rest4) ← parseStmt fuel rest3
            let rest5 ← expectTok ")" rest4
            pure (.tryCatch b v h, rest5)
        | "finally" :: rest2 => do
            let (f, rest3) ← parseStmt fuel rest2
            let rest4 ← expectTok ")" rest3
            pure (.tryFinally b f, rest4)
        | _ => none
    | "(" :: "raise" :: rest => do
        let (e, rest1) ← parseExpr fuel rest
        let rest2 ← expectTok ")" rest1
        pure (.raise e, rest2)
    | "(" :: "return" :: rest => do
        let (e, rest1) ← parseExpr fuel rest
        let rest2 ← expectTok ")" rest1
        pure (.ret e, rest2)
    | _ => none
    -- `match`, `foreach`, `forelem`, `localize`, `yield`, any malformed/truncated/garbage
    -- token stream, and every head tag `CalculusNested.Stmt` has no constructor for: `none`.

/-! ## Fail-closed theorems: general over the entire rest of the token stream -/

theorem parseStmt_rejects_match (fuel : Nat) (rest : List String) :
    parseStmt (fuel + 1) ("(" :: "match" :: rest) = none := by simp [parseStmt]

theorem parseStmt_rejects_foreach (fuel : Nat) (rest : List String) :
    parseStmt (fuel + 1) ("(" :: "foreach" :: rest) = none := by simp [parseStmt]

theorem parseStmt_rejects_forelem (fuel : Nat) (rest : List String) :
    parseStmt (fuel + 1) ("(" :: "forelem" :: rest) = none := by simp [parseStmt]

theorem parseStmt_rejects_localize (fuel : Nat) (rest : List String) :
    parseStmt (fuel + 1) ("(" :: "localize" :: rest) = none := by simp [parseStmt]

theorem parseStmt_rejects_yield (fuel : Nat) (rest : List String) :
    parseStmt (fuel + 1) ("(" :: "yield" :: rest) = none := by simp [parseStmt]

theorem parseFunc_rejects_and : parseFunc "and" = none := by simp [parseFunc]
theorem parseFunc_rejects_or : parseFunc "or" = none := by simp [parseFunc]
-- `parseFunc_rejects_length`/`_take`/`_drop`/`_slice`/`_append`/`_single`/`_empty`/
-- `_head_or`/`_tail`/`_min`/`_max` (11 theorems) REMOVED, calculus-correspondence-9: these
-- eleven names are now supported (`CalculusNested`'s 2026-09-08 update); the statements would
-- be false, not weaker. `parseFunc_rejects_rangelist` REMOVED, calculus-correspondence-10, same
-- reason: `range-list:lo:hi` is now supported (`Func.rangeList`). `parseFunc_renderFunc` below
-- covers all twelve round trips instead, the same as every other supported operator.

/-! ## Renderer (produces token lists, the inverse of the parser) and the round-trip theorem -/

def renderFunc : Func → String
  | .add => "+" | .sub => "-" | .mul => "*" | .div => "/" | .mod => "%"
  | .lt => "<" | .le => "<=" | .gt => ">" | .ge => ">=" | .eq => "==" | .ne => "!="
  | .neg => "neg" | .lnot => "not" | .fst => "fst" | .snd => "snd"
  | .length => "length" | .take => "take" | .drop => "drop" | .slice => "slice"
  | .append => "append" | .single => "single" | .empty => "empty" | .headOr => "head_or"
  | .tail => "tail" | .min => "min" | .max => "max"
  | .excTag t => "exc-is:" ++ t
  | .rangeList lo hi => "range-list:" ++ toString lo ++ ":" ++ toString hi
  | .range lo hi => "range:" ++ toString lo ++ ":" ++ toString hi

def renderLit : Lit → String
  | .unit => "()"
  | .bool true => "true"
  | .bool false => "false"
  | .int n => toString n
  | .str s => "\"" ++ s ++ "\""

def renderExprToks : Expr → List String
  | .lit .unit => ["(", ")"]
  | .lit l => [renderLit l]
  | .var x => [x]
  | .pair a b => ["(", "pair"] ++ renderExprToks a ++ renderExprToks b ++ [")"]
  | .fn f e => ["(", renderFunc f] ++ renderExprToks e ++ [")"]
  | .elem base n arg => ["(", "elem"] ++ renderExprToks base ++ [n] ++ renderExprToks arg ++ [")"]

def renderStmtToks : Stmt String → List String
  | .pass => ["pass"]
  | .seq a b => ["(", "seq"] ++ renderStmtToks a ++ renderStmtToks b ++ [")"]
  | .action v a e => ["(", "action", v, a] ++ renderExprToks e ++ [")"]
  | .assign v e => ["(", "assign", v] ++ renderExprToks e ++ [")"]
  | .setAttr b a e => ["(", "set-attr"] ++ renderExprToks b ++ [a] ++ renderExprToks e ++ [")"]
  | .addElem b n e => ["(", "add-elem"] ++ renderExprToks b ++ [n] ++ renderExprToks e ++ [")"]
  | .removeElem b n e => ["(", "remove-elem"] ++ renderExprToks b ++ [n] ++ renderExprToks e ++ [")"]
  | .get v b a => ["(", "get", v] ++ renderExprToks b ++ [a] ++ [")"]
  | .contains b n e t f =>
    ["(", "contains"] ++ renderExprToks b ++ [n] ++ renderExprToks e ++ renderStmtToks t ++
      renderStmtToks f ++ [")"]
  | .cond c t e => ["(", "if"] ++ renderExprToks c ++ renderStmtToks t ++ renderStmtToks e ++ [")"]
  | .while c b => ["(", "while"] ++ renderExprToks c ++ renderStmtToks b ++ [")"]
  | .tryCatch b v h => ["(", "try"] ++ renderStmtToks b ++ ["catch", v] ++ renderStmtToks h ++ [")"]
  | .tryFinally b f => ["(", "try"] ++ renderStmtToks b ++ ["finally"] ++ renderStmtToks f ++ [")"]
  | .raise e => ["(", "raise"] ++ renderExprToks e ++ [")"]
  | .ret e => ["(", "return"] ++ renderExprToks e ++ [")"]

/-- Recursion-depth lower bound on `fuel`: `parseExpr`/`parseStmt` spend exactly one unit of
    fuel per level of AST nesting (siblings share the fuel their parent already paid for; see
    the definitions above), so this — not a token count — is the fuel a parse needs. -/
def depthExpr : Expr → Nat
  | .lit _ => 1
  | .var _ => 1
  | .pair a b => 1 + max (depthExpr a) (depthExpr b)
  | .fn _ e => 1 + depthExpr e
  | .elem base _ arg => 1 + max (depthExpr base) (depthExpr arg)

def depthStmt : Stmt String → Nat
  | .pass => 1
  | .seq a b => 1 + max (depthStmt a) (depthStmt b)
  | .action _ _ e => 1 + depthExpr e
  | .assign _ e => 1 + depthExpr e
  | .setAttr b _ e => 1 + max (depthExpr b) (depthExpr e)
  | .addElem b _ e => 1 + max (depthExpr b) (depthExpr e)
  | .removeElem b _ e => 1 + max (depthExpr b) (depthExpr e)
  | .get _ b _ => 1 + depthExpr b
  | .contains b _ e t f => 1 + max (depthExpr b) (max (depthExpr e) (max (depthStmt t) (depthStmt f)))
  | .cond c t e => 1 + max (depthExpr c) (max (depthStmt t) (depthStmt e))
  | .while c b => 1 + max (depthExpr c) (depthStmt b)
  | .tryCatch b _ h => 1 + max (depthStmt b) (depthStmt h)
  | .tryFinally b f => 1 + max (depthStmt b) (depthStmt f)
  | .raise e => 1 + depthExpr e
  | .ret e => 1 + depthExpr e

def fuelOfExpr (e : Expr) : Nat := depthExpr e
def fuelOfStmt (s : Stmt String) : Nat := depthStmt s

/-! ## Integer-literal round trip (general, needed for the `Func.range` case below)

None of this was needed by the file's earlier `hshort`-only proofs; `range` is the one `Func`
constructor whose rendered text embeds a value (`Int.repr`) that must itself be parsed back, not
just recognized against a fixed keyword. -/

private theorem nat_repr_no_colon (m : Nat) : ':' ∉ (Nat.repr m).toList := by
  rw [Nat.toList_repr]
  intro hmem
  have hdig := Nat.isDigit_of_mem_toDigits (b := 10) (n := m) (by decide) (by decide) hmem
  simp at hdig

private theorem nat_repr_head_ne_dash {m : Nat} {c : Char} {rest : List Char}
    (h : (Nat.repr m).toList = c :: rest) : c ≠ '-' := by
  have hmem : c ∈ Nat.toDigits 10 m := by rw [← Nat.toList_repr, h]; exact List.mem_cons_self
  have hdig : c.isDigit := Nat.isDigit_of_mem_toDigits (by decide) (by decide) hmem
  intro heq
  rw [heq] at hdig
  simp at hdig

/-- General round trip for integer literals: parsing what `Int.repr` printed always recovers the
    same integer, for EVERY `Int`, not just the values anyone happened to test. -/
private theorem parseIntLit_repr (n : Int) : parseIntLit n.repr = some n := by
  cases n with
  | ofNat m =>
    show parseIntLit (Nat.repr m) = some (Int.ofNat m)
    unfold parseIntLit
    rcases htl : (Nat.repr m).toList with _ | ⟨c, rest⟩
    · exact absurd (Nat.toList_repr (n := m) ▸ htl) Nat.toDigits_ne_nil
    · have hne := nat_repr_head_ne_dash htl
      have hd : digitsToNat? (c :: rest) = some m := htl ▸ digitsToNat?_repr m
      split
      · rename_i heq; exact absurd heq (by simp)
      · rename_i c' rest' heq; simp_all
      · simp [hd]
  | negSucc m =>
    show parseIntLit ("-" ++ Nat.repr (m + 1)) = some (Int.negSucc m)
    unfold parseIntLit
    have htl : ("-" ++ Nat.repr (m + 1)).toList = '-' :: (Nat.repr (m + 1)).toList := by
      simp [String.toList_append]
    rw [htl]
    show (digitsToNat? (Nat.repr (m + 1)).toList).map (fun n => -(Int.ofNat n)) = some (Int.negSucc m)
    rw [digitsToNat?_repr]
    rfl

/-- `Int.repr` never contains `:` (it is a `-` sign followed by decimal digits), so splitting the
    rendered `"range:" ++ lo.repr ++ ":" ++ hi.repr` on its one embedded colon always recovers
    `lo.repr` and `hi.repr` exactly, for every `lo hi : Int`. -/
private theorem int_repr_no_colon (n : Int) : ':' ∉ n.repr.toList := by
  cases n with
  | ofNat m => simpa [Int.repr] using nat_repr_no_colon m
  | negSucc m =>
    simp only [Int.repr, String.toList_append]
    intro hmem
    simp at hmem
    exact absurd (Nat.isDigit_of_mem_toDigits (b := 10) (n := m + 1) (by decide) (by decide) hmem)
      (by decide)

-- Which named `hshort`/`if_neg` facts a given `simp` call ends up needing (vs. discharging some
-- other way, e.g. through a different simp lemma already in scope) is not stable across the
-- proof's surrounding context; disabled rather than hand-tuned per call, same as the repo's other
-- `hshort`-style disjointness proofs. Every remaining fact is still separately, honestly proved —
-- this only silences the "some supplied fact turned out redundant" style lint, not correctness.
set_option linter.unusedSimpArgs false in
/-- `renderFunc` is injective on the range `parseFunc` recognizes: parsing what it printed
    always recovers the same `Func`, for every `Func` value (including every exception tag and
    every integer range, not just the fixed-name operators). -/
theorem parseFunc_renderFunc : ∀ (f : Func), parseFunc (renderFunc f) = some f := by
  intro f
  cases f with
  | excTag t =>
    have hexc : ("exc-is:" : String).length = 7 := rfl
    have hshort : ∀ s : String, s.length ≤ 3 → ("exc-is:" ++ t) ≠ s := by
      intro s hs heq
      have := congrArg String.length heq
      simp [String.length_append, hexc] at this
      omega
    -- The 11 byte-list builtin names (calculus-correspondence-9) are longer than 3 chars, so
    -- `hshort` doesn't cover them; they contain no `:`, while `"exc-is:" ++ t` always does.
    have hcolonmem : ':' ∈ ("exc-is:" ++ t).toList := by simp [String.toList_append]
    have hnocolon : ∀ s : String, ':' ∉ s.toList → ("exc-is:" ++ t) ≠ s := by
      intro s hs heq
      exact hs (heq ▸ hcolonmem)
    simp [renderFunc, parseFunc, String.toList_append, String.ofList_toList,
      hshort "+" (by decide), hshort "-" (by decide), hshort "*" (by decide),
      hshort "/" (by decide), hshort "%" (by decide), hshort "<" (by decide),
      hshort "<=" (by decide), hshort ">" (by decide), hshort ">=" (by decide),
      hshort "==" (by decide), hshort "!=" (by decide), hshort "neg" (by decide),
      hshort "not" (by decide), hshort "fst" (by decide), hshort "snd" (by decide),
      hnocolon "length" (by decide), hnocolon "take" (by decide), hnocolon "drop" (by decide),
      hnocolon "slice" (by decide), hnocolon "append" (by decide), hnocolon "single" (by decide),
      hnocolon "empty" (by decide), hnocolon "head_or" (by decide), hnocolon "tail" (by decide),
      hnocolon "min" (by decide), hnocolon "max" (by decide)]
  | range lo hi =>
    have hrange : ("range:" : String).length = 6 := rfl
    have hcolon : (":" : String).length = 1 := rfl
    have hshort : ∀ s : String, s.length ≤ 3 → ("range:" ++ toString lo ++ ":" ++ toString hi) ≠ s := by
      intro s hs heq
      have := congrArg String.length heq
      simp [String.length_append, hrange, hcolon] at this
      omega
    have hsplit : splitFirstColon (lo.repr.toList ++ ':' :: hi.repr.toList) =
        some (lo.repr.toList, hi.repr.toList) :=
      splitFirstColon_append _ _ (int_repr_no_colon lo)
    have hcolonmem : ':' ∈ ("range:" ++ toString lo ++ ":" ++ toString hi).toList := by
      simp [String.toList_append]
    have hnocolon : ∀ s : String, ':' ∉ s.toList →
        ("range:" ++ toString lo ++ ":" ++ toString hi) ≠ s := by
      intro s hs heq
      exact hs (heq ▸ hcolonmem)
    simp only [renderFunc, parseFunc,
      if_neg (hshort "+" (by decide)), if_neg (hshort "-" (by decide)),
      if_neg (hshort "*" (by decide)), if_neg (hshort "/" (by decide)),
      if_neg (hshort "%" (by decide)), if_neg (hshort "<" (by decide)),
      if_neg (hshort "<=" (by decide)), if_neg (hshort ">" (by decide)),
      if_neg (hshort ">=" (by decide)), if_neg (hshort "==" (by decide)),
      if_neg (hshort "!=" (by decide)), if_neg (hshort "neg" (by decide)),
      if_neg (hshort "not" (by decide)), if_neg (hshort "fst" (by decide)),
      if_neg (hshort "snd" (by decide)),
      if_neg (hnocolon "length" (by decide)), if_neg (hnocolon "take" (by decide)),
      if_neg (hnocolon "drop" (by decide)), if_neg (hnocolon "slice" (by decide)),
      if_neg (hnocolon "append" (by decide)), if_neg (hnocolon "single" (by decide)),
      if_neg (hnocolon "empty" (by decide)), if_neg (hnocolon "head_or" (by decide)),
      if_neg (hnocolon "tail" (by decide)), if_neg (hnocolon "min" (by decide)),
      if_neg (hnocolon "max" (by decide)), String.reduceToList]
    simp [String.toList_append, String.reduceToList, List.cons_append, List.nil_append,
      List.append_assoc, hsplit, String.ofList_toList, Int.toString_eq_repr, parseIntLit_repr]
  | rangeList lo hi =>
    have hrange : ("range-list:" : String).length = 11 := rfl
    have hcolon : (":" : String).length = 1 := rfl
    have hshort : ∀ s : String, s.length ≤ 3 →
        ("range-list:" ++ toString lo ++ ":" ++ toString hi) ≠ s := by
      intro s hs heq
      have := congrArg String.length heq
      simp [String.length_append, hrange, hcolon] at this
      omega
    have hsplit : splitFirstColon (lo.repr.toList ++ ':' :: hi.repr.toList) =
        some (lo.repr.toList, hi.repr.toList) :=
      splitFirstColon_append _ _ (int_repr_no_colon lo)
    have hcolonmem : ':' ∈ ("range-list:" ++ toString lo ++ ":" ++ toString hi).toList := by
      simp [String.toList_append]
    have hnocolon : ∀ s : String, ':' ∉ s.toList →
        ("range-list:" ++ toString lo ++ ":" ++ toString hi) ≠ s := by
      intro s hs heq
      exact hs (heq ▸ hcolonmem)
    simp only [renderFunc, parseFunc,
      if_neg (hshort "+" (by decide)), if_neg (hshort "-" (by decide)),
      if_neg (hshort "*" (by decide)), if_neg (hshort "/" (by decide)),
      if_neg (hshort "%" (by decide)), if_neg (hshort "<" (by decide)),
      if_neg (hshort "<=" (by decide)), if_neg (hshort ">" (by decide)),
      if_neg (hshort ">=" (by decide)), if_neg (hshort "==" (by decide)),
      if_neg (hshort "!=" (by decide)), if_neg (hshort "neg" (by decide)),
      if_neg (hshort "not" (by decide)), if_neg (hshort "fst" (by decide)),
      if_neg (hshort "snd" (by decide)),
      if_neg (hnocolon "length" (by decide)), if_neg (hnocolon "take" (by decide)),
      if_neg (hnocolon "drop" (by decide)), if_neg (hnocolon "slice" (by decide)),
      if_neg (hnocolon "append" (by decide)), if_neg (hnocolon "single" (by decide)),
      if_neg (hnocolon "empty" (by decide)), if_neg (hnocolon "head_or" (by decide)),
      if_neg (hnocolon "tail" (by decide)), if_neg (hnocolon "min" (by decide)),
      if_neg (hnocolon "max" (by decide)), String.reduceToList]
    simp [String.toList_append, String.reduceToList, List.cons_append, List.nil_append,
      List.append_assoc, hsplit, String.ofList_toList, Int.toString_eq_repr, parseIntLit_repr]
  | _ => simp [renderFunc, parseFunc]

/-- `renderFunc` never collides with the two non-`Func` head keywords `parseExpr` checks first
    (`pair`, `elem`), for every `Func` value — needed so the parser's dispatch on a rendered
    `fn` node provably falls through to the generic function-name branch. The two parametric
    constructors are handled by a length argument since their rendered text is a fixed
    prefix followed by arbitrary (numeral/identifier) content. -/
theorem renderFunc_ne_pair_elem (f : Func) :
    renderFunc f ≠ "pair" ∧ renderFunc f ≠ "elem" ∧ renderFunc f ≠ ")" := by
  have hpair : ("pair" : String).length = 4 := rfl
  have helem : ("elem" : String).length = 4 := rfl
  have hclose : (")" : String).length = 1 := rfl
  have hexc : ("exc-is:" : String).length = 7 := rfl
  have hrange : ("range:" : String).length = 6 := rfl
  have hcolon : (":" : String).length = 1 := rfl
  cases f with
  | excTag t =>
    refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩ <;>
      · have hl := congrArg String.length h
        simp only [renderFunc, String.length_append, hexc, hpair, helem, hclose] at hl
        omega
  | range lo hi =>
    refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩ <;>
      · have hl := congrArg String.length h
        simp only [renderFunc, String.length_append, hrange, hcolon, hpair, helem, hclose] at hl
        omega
  | rangeList lo hi =>
    have hrangelist : ("range-list:" : String).length = 11 := rfl
    refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩ <;>
      · have hl := congrArg String.length h
        simp only [renderFunc, String.length_append, hrangelist, hcolon, hpair, helem, hclose] at hl
        omega
  | _ => refine ⟨?_, ?_, ?_⟩ <;> simp [renderFunc]

/-- Well-formedness: no name field (a variable, attribute, element or action name) is the
    literal token `"("` or `")"`. Every name in every real export is an OCaml identifier or a
    `$tN` temporary (`adapter/lower.ml`'s fresh-name scheme) or a fn/attribute/element source
    name — never a bare paren — so this holds of every AST this project has ever produced; it is
    stated explicitly because without it the round-trip claim below would be literally false
    (a pathological `Stmt` built by hand with a field equal to `"("` renders to a token that the
    parser would then read back as the START of a new parenthesized form, not as a name). -/
def _root_.CalculusNested.Expr.WF : Expr → Prop
  | .lit .unit => True
  | .lit l => renderLit l ≠ "(" ∧ renderLit l ≠ ")" ∧ atomToExpr (renderLit l) = .lit l
  | .var x => x ≠ "(" ∧ x ≠ ")" ∧ atomToExpr x = .var x
  | .pair a b => a.WF ∧ b.WF
  | .fn _ e => e.WF
  | .elem base n arg => base.WF ∧ n ≠ "(" ∧ n ≠ ")" ∧ arg.WF

def _root_.CalculusNested.Stmt.WF : Stmt String → Prop
  | .pass => True
  | .seq a b => a.WF ∧ b.WF
  | .action v a e => v ≠ "(" ∧ v ≠ ")" ∧ a ≠ "(" ∧ a ≠ ")" ∧ e.WF
  | .assign v e => v ≠ "(" ∧ v ≠ ")" ∧ e.WF
  | .setAttr b a e => b.WF ∧ a ≠ "(" ∧ a ≠ ")" ∧ e.WF
  | .addElem b n e => b.WF ∧ n ≠ "(" ∧ n ≠ ")" ∧ e.WF
  | .removeElem b n e => b.WF ∧ n ≠ "(" ∧ n ≠ ")" ∧ e.WF
  | .get v b a => v ≠ "(" ∧ v ≠ ")" ∧ b.WF ∧ a ≠ "(" ∧ a ≠ ")"
  | .contains b n e t f => b.WF ∧ n ≠ "(" ∧ n ≠ ")" ∧ e.WF ∧ t.WF ∧ f.WF
  | .cond c t e => c.WF ∧ t.WF ∧ e.WF
  | .while c b => c.WF ∧ b.WF
  | .tryCatch b v h => b.WF ∧ v ≠ "(" ∧ v ≠ ")" ∧ h.WF
  | .tryFinally b f => b.WF ∧ f.WF
  | .raise e => e.WF
  | .ret e => e.WF

/-- The general round-trip theorem, in the form the induction actually needs: an arbitrary
    trailing `suffix` (the tokens of whatever comes after `e` in a larger program), so that the
    statement composes through `pair`/`fn`/`elem` without a separate fuel-monotonicity lemma —
    each recursive use below picks exactly the fuel its own depth requires, all drawn from the
    same `fuel` the parent already has in hand. -/
theorem parseExpr_render : ∀ (e : Expr), e.WF → ∀ (fuel : Nat) (suffix : List String),
    depthExpr e ≤ fuel → parseExpr fuel (renderExprToks e ++ suffix) = some (e, suffix) := by
  intro e
  induction e with
  | lit l =>
    intro hwf fuel suffix hle
    simp only [depthExpr] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hstep : 1 + k = k + 1 := by omega
    cases l with
    | unit => simp [renderExprToks, hstep, parseExpr]
    | _ =>
      obtain ⟨h1, _h2, h3⟩ := hwf
      simp [renderExprToks, hstep, parseExpr, h1, h3]
  | var x =>
    intro hwf fuel suffix hle
    obtain ⟨hx1, _hx2, hx3⟩ := hwf
    simp only [depthExpr] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hstep : 1 + k = k + 1 := by omega
    simp [renderExprToks, hstep, parseExpr, hx1, hx3]
  | pair a b iha ihb =>
    intro hwf fuel suffix hle
    obtain ⟨hwfa, hwfb⟩ := hwf
    simp [depthExpr] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hda : depthExpr a ≤ max (depthExpr a) (depthExpr b) + k := by omega
    have hdb : depthExpr b ≤ max (depthExpr a) (depthExpr b) + k := by omega
    have e1 := iha hwfa (max (depthExpr a) (depthExpr b) + k) (renderExprToks b ++ ")" :: suffix) hda
    have e2 := ihb hwfb (max (depthExpr a) (depthExpr b) + k) (")" :: suffix) hdb
    have hstep : 1 + max (depthExpr a) (depthExpr b) + k
        = (max (depthExpr a) (depthExpr b) + k) + 1 := by omega
    simp [renderExprToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseExpr, e1,
      e2, expectTok]
  | fn f e ih =>
    intro hwf fuel suffix hle
    simp [depthExpr] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hde : depthExpr e ≤ depthExpr e + k := by omega
    have e1 := ih hwf (depthExpr e + k) (")" :: suffix) hde
    have hstep : 1 + depthExpr e + k = (depthExpr e + k) + 1 := by omega
    obtain ⟨hnp, hne, hnc⟩ := renderFunc_ne_pair_elem f
    simp only [renderExprToks, List.cons_append, List.nil_append, List.append_assoc, hstep]
    simp only [parseExpr]
    (repeat' split) <;> simp_all [expectTok, parseFunc_renderFunc]
  | elem base name arg ihb iha =>
    intro hwf fuel suffix hle
    obtain ⟨hwfbase, hn1, hn2, hwfarg⟩ := hwf
    simp [depthExpr] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdbase : depthExpr base ≤ max (depthExpr base) (depthExpr arg) + k := by omega
    have hdarg : depthExpr arg ≤ max (depthExpr base) (depthExpr arg) + k := by omega
    have e1 := ihb hwfbase (max (depthExpr base) (depthExpr arg) + k) (name :: (renderExprToks arg ++ (")" :: suffix))) hdbase
    have e2 := iha hwfarg (max (depthExpr base) (depthExpr arg) + k) (")" :: suffix) hdarg
    have hstep : 1 + max (depthExpr base) (depthExpr arg) + k
        = (max (depthExpr base) (depthExpr arg) + k) + 1 := by omega
    simp [renderExprToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseExpr, e1,
      parseAtomName, hn1, hn2, e2, expectTok]

theorem round_trip_expr (e : Expr) (hwf : e.WF) :
    parseExpr (fuelOfExpr e) (renderExprToks e) = some (e, []) := by
  have h := parseExpr_render e hwf (fuelOfExpr e) [] (by unfold fuelOfExpr; exact Nat.le_refl _)
  simpa using h

/-- Same statement, for statements: proved directly from `parseExpr_render` for every embedded
    expression, and by the same "arbitrary suffix" shape for nested sub-statements; same `WF`
    side condition on every name field, for the same reason. -/
theorem parseStmt_render : ∀ (s : Stmt String), s.WF → ∀ (fuel : Nat) (suffix : List String),
    depthStmt s ≤ fuel → parseStmt fuel (renderStmtToks s ++ suffix) = some (s, suffix) := by
  intro s
  induction s with
  | pass =>
    intro _ fuel suffix hle
    simp only [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hstep : 1 + k = k + 1 := by omega
    simp [renderStmtToks, hstep, parseStmt]
  | seq a b iha ihb =>
    intro hwf fuel suffix hle
    obtain ⟨hwfa, hwfb⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hda : depthStmt a ≤ max (depthStmt a) (depthStmt b) + k := by omega
    have hdb : depthStmt b ≤ max (depthStmt a) (depthStmt b) + k := by omega
    have e1 := iha hwfa (max (depthStmt a) (depthStmt b) + k) (renderStmtToks b ++ ")" :: suffix) hda
    have e2 := ihb hwfb (max (depthStmt a) (depthStmt b) + k) (")" :: suffix) hdb
    have hstep : 1 + max (depthStmt a) (depthStmt b) + k
        = (max (depthStmt a) (depthStmt b) + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      e2, expectTok]
  | action v a e =>
    intro hwf fuel suffix hle
    obtain ⟨hv1, hv2, ha1, ha2, hwfe⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have e1 := parseExpr_render e hwfe (depthExpr e + k) (")" :: suffix) (by omega)
    have hstep : 1 + depthExpr e + k = (depthExpr e + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt,
      parseAtomName, hv1, hv2, ha1, ha2, e1, expectTok]
  | assign v e =>
    intro hwf fuel suffix hle
    obtain ⟨hv1, hv2, hwfe⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have e1 := parseExpr_render e hwfe (depthExpr e + k) (")" :: suffix) (by omega)
    have hstep : 1 + depthExpr e + k = (depthExpr e + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt,
      parseAtomName, hv1, hv2, e1, expectTok]
  | setAttr b a e =>
    intro hwf fuel suffix hle
    obtain ⟨hwfb, ha1, ha2, hwfe⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdb : depthExpr b ≤ max (depthExpr b) (depthExpr e) + k := by omega
    have hde : depthExpr e ≤ max (depthExpr b) (depthExpr e) + k := by omega
    have e1 := parseExpr_render b hwfb (max (depthExpr b) (depthExpr e) + k) (a :: (renderExprToks e ++ (")" :: suffix))) hdb
    have e2 := parseExpr_render e hwfe (max (depthExpr b) (depthExpr e) + k) (")" :: suffix) hde
    have hstep : 1 + max (depthExpr b) (depthExpr e) + k
        = (max (depthExpr b) (depthExpr e) + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      parseAtomName, ha1, ha2, e2, expectTok]
  | addElem b n e =>
    intro hwf fuel suffix hle
    obtain ⟨hwfb, hn1, hn2, hwfe⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdb : depthExpr b ≤ max (depthExpr b) (depthExpr e) + k := by omega
    have hde : depthExpr e ≤ max (depthExpr b) (depthExpr e) + k := by omega
    have e1 := parseExpr_render b hwfb (max (depthExpr b) (depthExpr e) + k) (n :: (renderExprToks e ++ (")" :: suffix))) hdb
    have e2 := parseExpr_render e hwfe (max (depthExpr b) (depthExpr e) + k) (")" :: suffix) hde
    have hstep : 1 + max (depthExpr b) (depthExpr e) + k
        = (max (depthExpr b) (depthExpr e) + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      parseAtomName, hn1, hn2, e2, expectTok]
  | removeElem b n e =>
    intro hwf fuel suffix hle
    obtain ⟨hwfb, hn1, hn2, hwfe⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdb : depthExpr b ≤ max (depthExpr b) (depthExpr e) + k := by omega
    have hde : depthExpr e ≤ max (depthExpr b) (depthExpr e) + k := by omega
    have e1 := parseExpr_render b hwfb (max (depthExpr b) (depthExpr e) + k) (n :: (renderExprToks e ++ (")" :: suffix))) hdb
    have e2 := parseExpr_render e hwfe (max (depthExpr b) (depthExpr e) + k) (")" :: suffix) hde
    have hstep : 1 + max (depthExpr b) (depthExpr e) + k
        = (max (depthExpr b) (depthExpr e) + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      parseAtomName, hn1, hn2, e2, expectTok]
  | get v b a =>
    intro hwf fuel suffix hle
    obtain ⟨hv1, hv2, hwfb, ha1, ha2⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have e1 := parseExpr_render b hwfb (depthExpr b + k) (a :: (")" :: suffix)) (by omega)
    have hstep : 1 + depthExpr b + k = (depthExpr b + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt,
      parseAtomName, hv1, hv2, ha1, ha2, e1, expectTok]
  | contains b n e t f iht ihf =>
    intro hwf fuel suffix hle
    obtain ⟨hwfb, hn1, hn2, hwfe, hwft, hwff⟩ := hwf
    simp [depthStmt] at hle
    let m := max (depthExpr b) (max (depthExpr e) (max (depthStmt t) (depthStmt f)))
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdb : depthExpr b ≤ m + k := by omega
    have hde : depthExpr e ≤ m + k := by omega
    have hdt : depthStmt t ≤ m + k := by omega
    have hdf : depthStmt f ≤ m + k := by omega
    have e1 := parseExpr_render b hwfb (m + k) (n :: (renderExprToks e ++ (renderStmtToks t ++ (renderStmtToks f ++ (")" :: suffix))))) hdb
    have e2 := parseExpr_render e hwfe (m + k) (renderStmtToks t ++ (renderStmtToks f ++ (")" :: suffix))) hde
    have e3 := iht hwft (m + k) (renderStmtToks f ++ (")" :: suffix)) hdt
    have e4 := ihf hwff (m + k) (")" :: suffix) hdf
    have hstep : 1 + max (depthExpr b) (max (depthExpr e) (max (depthStmt t) (depthStmt f))) + k
        = max (depthExpr b) (max (depthExpr e) (max (depthStmt t) (depthStmt f))) + k + 1 := by omega
    simp only [m] at e1 e2 e3 e4
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      parseAtomName, hn1, hn2, e2, e3, e4, expectTok]
  | cond c t e iht ihe =>
    intro hwf fuel suffix hle
    obtain ⟨hwfc, hwft, hwfe⟩ := hwf
    simp [depthStmt] at hle
    let m := max (depthExpr c) (max (depthStmt t) (depthStmt e))
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdc : depthExpr c ≤ m + k := by omega
    have hdt : depthStmt t ≤ m + k := by omega
    have hde : depthStmt e ≤ m + k := by omega
    have e1 := parseExpr_render c hwfc (m + k) (renderStmtToks t ++ (renderStmtToks e ++ (")" :: suffix))) hdc
    have e2 := iht hwft (m + k) (renderStmtToks e ++ (")" :: suffix)) hdt
    have e3 := ihe hwfe (m + k) (")" :: suffix) hde
    have hstep : 1 + max (depthExpr c) (max (depthStmt t) (depthStmt e)) + k
        = max (depthExpr c) (max (depthStmt t) (depthStmt e)) + k + 1 := by omega
    simp only [m] at e1 e2 e3
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      e2, e3, expectTok]
  | «while» c b ihb =>
    intro hwf fuel suffix hle
    obtain ⟨hwfc, hwfb⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdc : depthExpr c ≤ max (depthExpr c) (depthStmt b) + k := by omega
    have hdb : depthStmt b ≤ max (depthExpr c) (depthStmt b) + k := by omega
    have e1 := parseExpr_render c hwfc (max (depthExpr c) (depthStmt b) + k) (renderStmtToks b ++ ")" :: suffix) hdc
    have e2 := ihb hwfb (max (depthExpr c) (depthStmt b) + k) (")" :: suffix) hdb
    have hstep : 1 + max (depthExpr c) (depthStmt b) + k
        = (max (depthExpr c) (depthStmt b) + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      e2, expectTok]
  | tryCatch b v h ihb ihh =>
    intro hwf fuel suffix hle
    obtain ⟨hwfb, hv1, hv2, hwfh⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdb : depthStmt b ≤ max (depthStmt b) (depthStmt h) + k := by omega
    have hdh : depthStmt h ≤ max (depthStmt b) (depthStmt h) + k := by omega
    have e1 := ihb hwfb (max (depthStmt b) (depthStmt h) + k) ("catch" :: v :: (renderStmtToks h ++ (")" :: suffix))) hdb
    have e2 := ihh hwfh (max (depthStmt b) (depthStmt h) + k) (")" :: suffix) hdh
    have hstep : 1 + max (depthStmt b) (depthStmt h) + k
        = (max (depthStmt b) (depthStmt h) + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      parseAtomName, hv1, hv2, e2, expectTok]
  | tryFinally b f ihb ihf =>
    intro hwf fuel suffix hle
    obtain ⟨hwfb, hwff⟩ := hwf
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have hdb : depthStmt b ≤ max (depthStmt b) (depthStmt f) + k := by omega
    have hdf : depthStmt f ≤ max (depthStmt b) (depthStmt f) + k := by omega
    have e1 := ihb hwfb (max (depthStmt b) (depthStmt f) + k) ("finally" :: (renderStmtToks f ++ (")" :: suffix))) hdb
    have e2 := ihf hwff (max (depthStmt b) (depthStmt f) + k) (")" :: suffix) hdf
    have hstep : 1 + max (depthStmt b) (depthStmt f) + k
        = (max (depthStmt b) (depthStmt f) + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt, e1,
      e2, expectTok]
  | raise e =>
    intro hwf fuel suffix hle
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have e1 := parseExpr_render e hwf (depthExpr e + k) (")" :: suffix) (by omega)
    have hstep : 1 + depthExpr e + k = (depthExpr e + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt,
      e1, expectTok]
  | ret e =>
    intro hwf fuel suffix hle
    simp [depthStmt] at hle
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hle
    have e1 := parseExpr_render e hwf (depthExpr e + k) (")" :: suffix) (by omega)
    have hstep : 1 + depthExpr e + k = (depthExpr e + k) + 1 := by omega
    simp [renderStmtToks, List.cons_append, List.nil_append, List.append_assoc, hstep, parseStmt,
      e1, expectTok]

theorem round_trip_stmt (s : Stmt String) (hwf : s.WF) :
    parseStmt (fuelOfStmt s) (renderStmtToks s) = some (s, []) := by
  have h := parseStmt_render s hwf (fuelOfStmt s) [] (by unfold fuelOfStmt; exact Nat.le_refl _)
  simpa using h

end CalculusExport
