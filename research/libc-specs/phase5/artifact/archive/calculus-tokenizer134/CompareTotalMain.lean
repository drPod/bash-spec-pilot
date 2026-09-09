import CalculusTokenizeTotal
import Lean.Data.Json.Printer

/-!
`compare-run` total driver (harness-total-119). Does **not** import `CompareMain`
(that module defines `main`). Tokenization is `CalculusTokenizeTotal.parseText`
(fail-closed). Malformed FUNCS_FILE lines are rejected, not silently dropped.
-/

open CalculusNested
open CalculusExport
open CalculusTokenizeTotal

def hexDigit? (c : Char) : Option Nat :=
  if '0' ≤ c ∧ c ≤ '9' then some (c.toNat - '0'.toNat)
  else if 'a' ≤ c ∧ c ≤ 'f' then some (c.toNat - 'a'.toNat + 10)
  else if 'A' ≤ c ∧ c ≤ 'F' then some (c.toNat - 'A'.toNat + 10)
  else none

partial def hexToBytes : List Char → List Int
  | hi :: lo :: rest =>
    match hexDigit? hi, hexDigit? lo with
    | some h, some l => (Int.ofNat (h * 16 + l)) :: hexToBytes rest
    | _, _ => []
  | _ => []

def parseIntCsv (tok : String) : Int :=
  if tok.isEmpty then 0
  else if tok.front = '-' then -(Int.ofNat ((tok.drop 1).toNat?.getD 0))
  else Int.ofNat (tok.toNat?.getD 0)

def csvToInts (s : String) : List Int :=
  if s = "" then [] else (s.splitOn ",").map parseIntCsv

def initialState (input reads writes : List Int) : St :=
  .mk [("input", Val.ofIntList input), ("delivered", Val.ofIntList []),
       ("lost", Val.ofIntList []), ("reads", Val.ofIntList reads),
       ("writes", Val.ofIntList writes), ("read_calls", .lit (.int 0)),
       ("write_calls", .lit (.int 0))] []

/-- `some` only for `NAME<TAB>SEXPR` that `parseText` accepts and fully consumes. -/
def parseLine (line : String) : Option (String × Stmt String) :=
  match line.splitOn "\t" with
  | [name, sexpr] =>
    match parseText sexpr with
    | some s => some (name, s)
    | none => none
  | _ => none

def actDefOf (table : List (String × Stmt String)) : String → Stmt String :=
  fun name => (lookup table name).getD (.raise (.lit (.str "action-not-found")))

def interpFuel : Nat := 4000

def hexOf (xs : List Int) : String :=
  String.join (xs.map (fun b =>
    let n := b.toNat
    let hexChar (d : Nat) : Char := if d < 10 then Char.ofNat (d + '0'.toNat) else Char.ofNat (d - 10 + 'a'.toNat)
    String.ofList [hexChar (n / 16), hexChar (n % 16)]))

def jstr (s : String) : String := (Lean.Json.str s).compress

def caseLineOutcome (actDef : String → Stmt String) (entry : String) (line : String) : String :=
  match line.splitOn "\t" with
  | [name, hex, reads, writes] =>
    let input := hexToBytes hex.toList
    let readsL := csvToInts reads
    let writesL := csvToInts writes
    let st := initialState input readsL writesL
    let res := runEntry actDef interpFuel entry st
    "{\"mode\": \"run\", \"entry\": " ++ jstr entry ++ ", \"name\": " ++ jstr name ++
      ", \"input_hex\": " ++ jstr (hexOf input) ++
      ", \"reads\": [" ++ ", ".intercalate (readsL.map toString) ++ "]" ++
      ", \"writes\": [" ++ ", ".intercalate (writesL.map toString) ++ "], " ++
      renderRes res ++ "}"
  | _ => "{\"mode\": \"run\", \"outcome\": \"bad_case_line\", \"line\": " ++ jstr line ++ "}"

def main (args : List String) : IO UInt32 := do
  match args with
  | [entry, funcsFile] =>
    let contents ← IO.FS.readFile funcsFile
    let flines := (contents.splitOn "\n").filter (fun l => l ≠ "")
    let parsed := flines.map (fun l => (l, parseLine l))
    let mut rejected := false
    for (l, r) in parsed do
      match r with
      | none =>
        rejected := true
        IO.eprintln ("{\"funcs_line\": " ++ jstr l ++ ", \"outcome\": \"parse_rejected\"}")
      | some _ => pure ()
    if rejected then
      IO.eprintln "compare-run: malformed export line(s); refusing to run"
      return 1
    let table := parsed.filterMap (fun (_, r) => r)
    let actDef := actDefOf table
    let stdin ← IO.getStdin
    let caseContents ← stdin.readToEnd
    let caseLines := (caseContents.splitOn "\n").filter
      (fun l => l ≠ "" ∧ l.front ≠ '#')
    for l in caseLines do
      IO.println (caseLineOutcome actDef entry l)
    return 0
  | _ =>
    IO.eprintln "usage: compare-run ENTRY FUNCS_FILE < CASEFILE"
    return 2
