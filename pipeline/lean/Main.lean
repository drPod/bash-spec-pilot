import Pipeline

/-
Trusted IO shim, NOT LLM-generated. It calls the *same* total function
(`Pipeline.Generated.run`) the spec theorems are about, so the binary that the
differential layer tests is the function the kernel verified. Adapted verbatim
from demo/Main.lean's line-level abstraction.
-/

/-- Read stdin as lines, dropping the single trailing empty element that a final
    newline produces, so `"a\nb\n"` and `"a\nb"` both parse to `["a", "b"]`. -/
def readLines : IO (List String) := do
  let s ← (← IO.getStdin).readToEnd
  let parts := s.splitOn "\n"
  return if parts.getLast? = some "" then parts.dropLast else parts

def main (args : List String) : IO UInt32 := do
  let (out, code) := Pipeline.Generated.run args (← readLines)
  out.forM IO.println
  return code
