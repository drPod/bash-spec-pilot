import Main

/- Runtime tests only, not part of the pure relay theorem/axiom manifest. -/
private def testInputBound (n cap step : Nat) : IO Unit := do
  let input : List UInt8 := (List.range n).map UInt8.ofNat
  let unread ← IO.mkRef input
  let consumed ← IO.mkRef 0
  let stream : IO.FS.Stream := {
    flush := pure ()
    read := fun requested => do
      let pending ← unread.get
      let k := min requested.toNat step
      let chunk := pending.take k
      unread.set (pending.drop k)
      consumed.modify (· + chunk.length)
      return ⟨chunk.toArray⟩
    write := fun _ => pure ()
    getLine := pure ""
    putStr := fun _ => pure ()
    isTty := pure false }
  let actual ← readBounded stream cap
  let expected := if n ≤ cap then some input else none
  if actual.map (fun b => b.data.toList) != expected then
    throw <| IO.userError s!"bounded input mismatch n={n} cap={cap} step={step}"
  if (← consumed.get) > cap + 1 then
    throw <| IO.userError "ingestion exceeded cap+1"
  if n > cap && (← consumed.get) != cap + 1 then
    throw <| IO.userError "oversize ingestion did not stop at cap+1"

private def testNoEOF : IO Unit := do
  let consumed ← IO.mkRef 0
  let stream : IO.FS.Stream := {
    flush := pure ()
    read := fun requested => do
      consumed.modify (· + requested.toNat)
      return ⟨Array.replicate requested.toNat 0⟩
    write := fun _ => pure ()
    getLine := pure ""
    putStr := fun _ => pure ()
    isTty := pure false }
  let result ← readBounded stream 32
  unless result.isNone && (← consumed.get) = 33 do
    throw <| IO.userError "returning no-EOF stream did not stop at33 bytes"

private def testSuite : IO Unit := do
  for cap in [0, 3, 32] do
    for n in [0, 1, 3, 4, 31, 32, 33, 65] do
      for step in [1, 7, 65536] do
        testInputBound n cap step
  testNoEOF
  IO.println "InputBoundTests: 72 finite cases and 1 returning no-EOF stream passed"

#eval testSuite
