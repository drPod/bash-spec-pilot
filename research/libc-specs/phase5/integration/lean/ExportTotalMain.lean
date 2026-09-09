import CalculusTokenizeTotal
import Lean.Data.Json.Printer

/-!
`export-run` total driver (harness-total-119). Does **not** import `ExportMain`.
Uses `CalculusTokenizeTotal.parseText` (fail-closed). Unsupported / malformed
S-expressions print `"outcome": "parse_rejected"`.
-/

open CalculusNested
open CalculusExport
open CalculusTokenizeTotal

def parseLine (line : String) : Option (String × Stmt String) :=
  match line.splitOn "\t" with
  | [name, sexpr] =>
    match parseText sexpr with
    | some s => some (name, s)
    | none => none
  | _ => none

def actDefOf (table : List (String × Stmt String)) : String → Stmt String :=
  fun name => (lookup table name).getD (.raise (.lit (.str "action-not-found")))

def lineName (line : String) : String :=
  match line.splitOn "\t" with
  | name :: _ => name
  | [] => "?"

def interpFuel : Nat := 4000

def jstr (s : String) : String := (Lean.Json.str s).compress

def main : IO UInt32 := do
  let stdin ← IO.getStdin
  let contents ← stdin.readToEnd
  let lines := (contents.splitOn "\n").filter (fun l => l ≠ "")
  let results := lines.map (fun l => (l, parseLine l))
  let mut rejected := false
  for (l, r) in results do
    match r with
    | none =>
      rejected := true
      IO.println ("{\"export_entry\": " ++ jstr (lineName l) ++ ", \"outcome\": \"parse_rejected\"}")
    | some _ => pure ()
  if rejected then return 1
  let table := results.filterMap (fun (_, r) => r)
  let actDef := actDefOf table
  for (name, _) in table do
    IO.println ("{\"export_entry\": " ++ jstr name ++ ", " ++
      renderRes (runEntry actDef interpFuel name St.empty) ++ "}")
  return 0
