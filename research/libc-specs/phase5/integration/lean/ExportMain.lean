import CalculusExport

/-!
`export-run`: reads `NAME<TAB>SEXPR` lines from stdin (one per fixture function, `SEXPR` being
the LITERAL text `Lower.show_stmt` printed — the real OCaml compiler's own export, copied
verbatim by the driver in `calculus-correspondence/`, never hand-edited), parses every line with
`CalculusExport.parseStmt`, builds one `actDef` table so functions can call each other by name
(exactly as the OCaml `Bytes_builtin.Defs.acts` hashtable does), and for every line that parsed
runs `CalculusNested.runEntry` on it from `St.empty`, printing one JSON line per input line so a
Python driver can diff it against the real OCaml `"run"` records for the same functions.
A line whose S-expression this fragment does not support prints `"outcome": "parse_rejected"`
instead of guessing — the automated, general form of "fail closed unsupported".
-/

open CalculusNested
open CalculusExport

def parseLine (fuel : Nat) (line : String) : Option (String × Stmt String) :=
  match line.splitOn "\t" with
  | [name, sexpr] =>
    let toks := tokenize sexpr
    match parseStmt fuel toks with
    | some (s, []) => some (name, s)
    | _ => none
  | _ => none

def actDefOf (table : List (String × Stmt String)) : String → Stmt String :=
  fun name => (lookup table name).getD (.raise (.lit (.str "action-not-found")))

def lineName (line : String) : String :=
  match line.splitOn "\t" with
  | name :: _ => name
  | [] => "?"

def parseFuel : Nat := 400
def interpFuel : Nat := 4000

def main : IO Unit := do
  let stdin ← IO.getStdin
  let contents ← stdin.readToEnd
  let lines := (contents.splitOn "\n").filter (fun l => l ≠ "")
  let results := lines.map (fun l => (l, parseLine parseFuel l))
  let table := results.filterMap (fun (_, r) => r)
  let actDef := actDefOf table
  for (l, r) in results do
    match r with
    | none =>
      IO.println ("{\"export_entry\": \"" ++ lineName l ++ "\", \"outcome\": \"parse_rejected\"}")
    | some (name, _) =>
      IO.println ("{\"export_entry\": \"" ++ name ++ "\", " ++
        renderRes (runEntry actDef interpFuel name St.empty) ++ "}")
