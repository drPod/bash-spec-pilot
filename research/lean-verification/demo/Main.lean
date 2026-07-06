import Demo

open Demo

/-- Read stdin as lines, dropping the single trailing empty element that a final
    newline produces, so `"a\nb\n"` and `"a\nb"` both parse to `["a", "b"]`. This is
    the line-level abstraction the Lean model and `validate.py` agree on. -/
def readLines : IO (List String) := do
  let s ← (← IO.getStdin).readToEnd
  let parts := s.splitOn "\n"
  return if parts.getLast? = some "" then parts.dropLast else parts

def putLines (ls : List String) : IO Unit :=
  ls.forM IO.println

/-- Runs the *same* total models that `Demo/Basic.lean` proves theorems about. -/
def main (args : List String) : IO UInt32 := do
  match args with
  | ["true"]        => return trueModel.toUInt32
  | ["false"]       => return falseModel.toUInt32
  | "echo" :: rest  => putLines (echoModel rest); return 0
  | ["head", k]     =>
      match k.toNat? with
      | some n => putLines (headModel n (← readLines)); return 0
      | none   => IO.eprintln s!"head: invalid count '{k}'"; return 1
  | _ => IO.eprintln "usage: demo (true | false | echo ARGS... | head K)"; return 2
