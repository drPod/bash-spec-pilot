import CalculusExport

/-!
`compare-run`: same-input OCaml-vs-Lean comparison driver (calculus-correspondence-9).

Args: `ENTRY FUNCS_FILE`. `FUNCS_FILE` is a `NAME<TAB>SEXPR` file exactly like `export-run`'s
stdin (the real OCaml compiler's own `Lower.show_stmt` export, never hand-edited). Stdin is a
`cb_main.exe run`-format case file: `name<TAB>input_hex<TAB>reads<TAB>writes` per line, `#`-
prefixed and blank lines skipped — the SAME file `cb_main.exe run FILE ENTRY CASEFILE` reads,
so both sides run from IDENTICAL input. For each case, builds the initial state exactly as
`cb_main.ml`'s `initial_state` does (`input`/`delivered`/`lost`/`reads`/`writes`/`read_calls`/
`write_calls` attributes on the root, matching names and construction order) and runs
`CalculusNested.runEntry actDef fuel ENTRY st`, printing one JSON line per case so a Python
driver can diff it against `cb_main.exe run`'s own JSON for the same case file and entry.

This is glue code (untrusted, like `export-run`'s line/tokenizer parsing): the hex/CSV
parsers below are not proved, only the `CalculusExport`/`CalculusNested` pipeline they feed is.
-/

open CalculusNested
open CalculusExport

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

def parseLine (fuel : Nat) (line : String) : Option (String × Stmt String) :=
  match line.splitOn "\t" with
  | [name, sexpr] =>
    let toks := CalculusExport.tokenize sexpr
    match parseStmt fuel toks with
    | some (s, []) => some (name, s)
    | _ => none
  | _ => none

def actDefOf (table : List (String × Stmt String)) : String → Stmt String :=
  fun name => (lookup table name).getD (.raise (.lit (.str "action-not-found")))

def parseFuel : Nat := 400
def interpFuel : Nat := 4000

def hexOf (xs : List Int) : String :=
  String.join (xs.map (fun b =>
    let n := b.toNat
    let hexChar (d : Nat) : Char := if d < 10 then Char.ofNat (d + '0'.toNat) else Char.ofNat (d - 10 + 'a'.toNat)
    String.ofList [hexChar (n / 16), hexChar (n % 16)]))

def jstr (s : String) : String := "\"" ++ s ++ "\""

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

def main (args : List String) : IO Unit := do
  match args with
  | [entry, funcsFile] =>
    let contents ← IO.FS.readFile funcsFile
    let flines := (contents.splitOn "\n").filter (fun l => l ≠ "")
    let table := (flines.map (parseLine parseFuel)).filterMap id
    let actDef := actDefOf table
    let stdin ← IO.getStdin
    let caseContents ← stdin.readToEnd
    let caseLines := (caseContents.splitOn "\n").filter
      (fun l => l ≠ "" ∧ l.front ≠ '#')
    for l in caseLines do
      IO.println (caseLineOutcome actDef entry l)
  | _ => IO.eprintln "usage: compare-run ENTRY FUNCS_FILE < CASEFILE"
