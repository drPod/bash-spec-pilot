import CalculusShellText
import CalculusQuery
open ShellObservation CalculusCommands CalculusQuery CalculusNested CalculusRelayShared CalculusShellText

set_option linter.unusedSimpArgs false

namespace CalculusShellText
def compileScriptQuery (s : String) (q : Query) : Option (Stmt String) :=
  match parseSupported s with
  | some cmd => some (.seq (encodeCmd cmd) q.program)
  | none => none

theorem parseSupported_some (s : String) (cmd : Command Atom) :
    parseSupported s = some cmd →
      ∃ c, parseProgram s = some c ∧ mapCommand c = some cmd := by
  intro h
  simp [parseSupported] at h
  cases hp : parseProgram s with
  | none => simp [hp] at h
  | some c => exact ⟨c, rfl, by simpa [hp] using h⟩

theorem compileScriptQuery_some (s : String) (q : Query) (cmd : Command Atom) :
    parseSupported s = some cmd →
      compileScriptQuery s q = some (.seq (encodeCmd cmd) q.program) := by
  intro h; simp [compileScriptQuery, h]

theorem compileScriptQuery_nested
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = CalculusBody.writeBlockBody)
    (hrb : actDef "read_block" = CalculusRelayOuter.readBlockBody)
    (hrelay : actDef "relay" = CalculusBody.relayBody)
    (hmark : actDef "mark" = CalculusCommands.markBody)
    (L : Nat) (s : String) (cmd : Command Atom) (q : Query)
    (k fuel : Nat) (st : St) (w : QueryWorld)
    (hparse : parseSupported s = some cmd)
    (hr : Related st w) (hb : Budget (k + relayBudget cmd) L w)
    (hq : ∀ rc w', Exec atomPrim cmd w rc w' → q.eval rc w' = true) :
    compileScriptQuery s q = some (.seq (encodeCmd cmd) q.program) ∧
      ∃ env' st',
        interp actDef (fuel + fuelCost cmd + q.fuelCost + 2 * L + 119)
          (.seq (encodeCmd cmd) q.program) initEnv st = .continue env' st' ∧
        Related st' (runCmd cmd w).2 ∧
        lookup env' "q" = some (.v (.lit (.bool true))) := by
  refine ⟨compileScriptQuery_some s q cmd hparse, ?_⟩
  exact script_query_universal actDef hwb hrb hrelay hmark L cmd q k fuel st w hr hb hq


end CalculusShellText

#print axioms CalculusShellText.compileScriptQuery_nested
#print axioms CalculusShellText.compileScriptQuery_some
