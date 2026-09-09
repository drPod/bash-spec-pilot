import Pipeline

/- Trusted runtime shim; host IO is outside the pure model proof. -/

/-- Drops a final empty split, so terminated and unterminated last lines are indistinguishable. -/
def readLines : IO (List String) := do
  let s ← (← IO.getStdin).readToEnd
  let parts := s.splitOn "\n"
  return if parts.getLast? = some "" then parts.dropLast else parts

def main (args : List String) : IO UInt32 := do
  let (out, code) := Pipeline.Generated.run args (← readLines)
  out.forM IO.println
  return code
