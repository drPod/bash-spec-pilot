import PointerRelay

/- Runtime adapter only: CLI, host IO and JSON formatting are not covered by the
   pure refinement theorem. The parser follows the phase2 common CLI, with a
   smaller 4096-byte runtime input cap for bounded trace experiments. -/
namespace TraceCLI

def parseActions (isRead : Bool) (s : String) : Except String (List Int) := do
  if s = "" then return []
  let parts := s.splitOn ","
  if parts.length > 4096 then throw "too many actions"
  parts.mapM fun part => do
    if part = "-1" then return -1
    if part.isEmpty || !(part.toList.all Char.isDigit) then throw "bad action"
    if part.length > 1 && part.startsWith "0" then throw "leading zero"
    let some n := part.toNat? | throw "bad integer"
    if n > 1048576 || (isRead && n = 0) then throw "action outside domain"
    return (n : Int)

def parseArgs : List String → Except String (List Int × List Int)
  | [] => .ok ([], [])
  | ["--reads", r, "--writes", w] => do return (← parseActions true r, ← parseActions false w)
  | ["--writes", w, "--reads", r] => do return (← parseActions true r, ← parseActions false w)
  | ["--reads", r] => do return (← parseActions true r, [])
  | ["--writes", w] => do return ([], ← parseActions false w)
  | _ => .error "usage: pointer-trace [--reads LIST] [--writes LIST]"

def bytesJSON (bs : List UInt8) : String :=
  "[" ++ String.intercalate "," (bs.map fun b => toString b.toNat) ++ "]"

def eventJSON (e : PointerRelay.Event) : String :=
  let kind := match e.kind with | .read => "read" | .write => "write"
  let result : Int := if e.action < 0 then -1 else Int.ofNat e.bytes.length
  "{\"kind\":\"" ++ kind ++ "\",\"block\":" ++ toString e.pointer.block ++
  ",\"offset\":" ++ toString e.pointer.offset ++ ",\"request\":" ++ toString e.request ++
  ",\"action\":" ++ toString e.action ++ ",\"result\":" ++ toString result ++
  ",\"bytes\":" ++ bytesJSON e.bytes ++ "}"

def executionJSON (r : PointerRelay.Execution) : String :=
  let o := PointerRelay.observe r.state
  "{\"output\":" ++ bytesJSON o.output ++ ",\"remaining\":" ++ bytesJSON o.remaining ++
  ",\"pending\":" ++ bytesJSON o.pending ++ ",\"status\":" ++ toString o.status ++
  ",\"read_calls\":" ++ toString o.readCalls ++ ",\"write_calls\":" ++ toString o.writeCalls ++
  ",\"events\":[" ++ String.intercalate "," (r.trace.map eventJSON) ++ "]}"

def inputBounded (stream : IO.FS.Stream) : IO (Option ByteArray) := do
  let mut bytes := ByteArray.empty
  for _ in [:4097] do
    let chunk ← stream.read (USize.ofNat (4097 - bytes.size))
    if chunk.isEmpty then return some bytes
    bytes := bytes ++ chunk
    if bytes.size > 4096 then return none
  return none

end TraceCLI

def main (args : List String) : IO UInt32 := do
  match TraceCLI.parseArgs args with
  | .error e => (← IO.getStderr).putStrLn e; return 64
  | .ok (reads, writes) =>
    let some input ← TraceCLI.inputBounded (← IO.getStdin) | do
      (← IO.getStderr).putStrLn "trace input exceeds 4096-byte cap"
      return 64
    let r := PointerRelay.run input.data.toList reads writes
    (← IO.getStdout).putStrLn (TraceCLI.executionJSON r)
    return 0
