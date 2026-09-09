import GeneratedRelay

/- Test-driver protocol, outside the pure model proof. Raw bytes are never UTF-8 decoded.
   Schedules use decimal values bounded by 2^20, or the sentinel -1. -/
def parseActions (isRead : Bool) (s : String) : Except String (List Int) := do
  if s = "" then return []
  let parts := s.splitOn ","
  if parts.length > 4096 then throw "too many schedule entries"
  parts.mapM fun part => do
    if part = "-1" then return -1
    if part.isEmpty || !(part.toList.all Char.isDigit) then
      throw "schedule entries must be decimal integers or -1"
    if part.length > 1 && part.startsWith "0" then throw "leading zeros are unsupported"
    let some n := part.toNat? | throw "invalid schedule integer"
    if n > 1048576 then throw "schedule value exceeds 1048576"
    if isRead && n = 0 then throw "read quota must be positive or -1"
    return (n : Int)

def parseArgs : List String → Except String (List Int × List Int)
  | [] => .ok ([], [])
  | ["--reads", reads, "--writes", writes] => do
    return (← parseActions true reads, ← parseActions false writes)
  | ["--writes", writes, "--reads", reads] => do
    return (← parseActions true reads, ← parseActions false writes)
  | ["--reads", reads] => do return (← parseActions true reads, [])
  | ["--writes", writes] => do return ([], ← parseActions false writes)
  | _ => .error "usage: relay-model [--reads LIST] [--writes LIST]"

/-- Runtime ingestion bound only; host IO/CLI code is outside the pure proof.
    Read at most cap+1 bytes. A nonreturning host read still needs an OS timeout. -/
def readBounded (stream : IO.FS.Stream) (cap : Nat) : IO (Option ByteArray) := do
  let mut bytes := ByteArray.empty
  for _ in [:cap + 1] do
    let chunk ← stream.read (USize.ofNat (min 65536 (cap + 1 - bytes.size)))
    if chunk.isEmpty then return some bytes
    bytes := bytes ++ chunk
    if bytes.size > cap then return none
  return none

def main (args : List String) : IO UInt32 := do
  match parseArgs args with
  | .error message =>
    (← IO.getStderr).putStr (message ++ "\n")
    return 64
  | .ok (reads, writes) =>
    let some bytes ← readBounded (← IO.getStdin) 16777216 | do
      (← IO.getStderr).putStr "input exceeds 16 MiB cap\n"
      return 64
    let input := bytes.data.toList
    let result := GeneratedRelay.run input reads writes
    (← IO.getStdout).write ⟨result.output.toArray⟩
    let consumed := input.length - result.remaining.length
    (← IO.getStderr).putStr s!"consumed={consumed}\nread_calls={result.readCalls}\nwrite_calls={result.writeCalls}\n"
    return UInt32.ofNat result.status
