import RawWc

def main : IO UInt32 := do
  let input ← (← IO.getStdin).readBinToEnd
  let (out, status) := RawWc.runBytes input.data.toList
  (← IO.getStdout).putStr (String.ofList out)
  return status
