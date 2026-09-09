import CalculusShellTextQuery
import CalculusQueryExportLink
open ShellObservation CalculusCommands CalculusQuery CalculusNested CalculusRelayShared
  CalculusShellText

set_option linter.unusedSimpArgs false

/-!
# CalculusShellTextExport: the text-level connector with the EXPORTED mark body

`CalculusShellText.compileScriptQuery_nested` (root135) assumes
`actDef "mark" = CalculusCommands.markBody`, the hand-written mark body. The fixture's exported
`mark` (`CalculusLowering.markBody`, temp `$t27`, left-nested `seq`) is a different `Stmt`
value. Root92 accepted `CalculusQuery.markSpec_of_export` (the exported body satisfies the
mark action contract) and the axiom-free identity
`CalculusQueryExportLink.mark_body_identity : exportMarkBody = CalculusLowering.markBody`.
This module composes those accepted pieces with the accepted text parser: the theorem below
is the 135 connector with the exported body as the explicit `mark` premise. Nothing is assumed
about the mark body beyond that identity; no accepted file is modified.

Also included: kernel-checked parse witnesses for the two accepted example scripts (and one
grammar shape with parentheses and a trailing semicolon, and one fail-closed rejection), and the
two example script/query programs stated directly from their text with the exported body.

Not claimed: any change to the supported grammar or query AST, a query-text parser, a
character-level lexer theorem, host Bash semantics, or anything about the OCaml program. -/

namespace CalculusShellTextExport

/-- The exported `mark` body satisfies the action contract used by every command theorem
    (via the root92 identity; no hand-written body involved). -/
theorem markSpec_of_lowering (actDef : String → Stmt String)
    (hmark : actDef "mark" = CalculusLowering.markBody) : MarkSpec actDef :=
  markSpec_of_export actDef (hmark.trans CalculusQueryExportLink.mark_body_identity.symm)

/-- Root135's text-level connector, with the fixture's EXPORTED mark body as the `mark`
    premise. Premises: parse success, the three exported relay-side body identities, the
    exported mark body, `Related`, `Budget`, and a query true of every abstract execution. -/
theorem compileScriptQuery_nested_export
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = CalculusBody.writeBlockBody)
    (hrb : actDef "read_block" = CalculusRelayOuter.readBlockBody)
    (hrelay : actDef "relay" = CalculusBody.relayBody)
    (hmark : actDef "mark" = CalculusLowering.markBody)
    (L : Nat) (s : String) (cmd : Command Atom) (q : Query)
    (k fuel : Nat) (st : St) (w : QueryWorld)
    (hparse : parseSupported s = some cmd)
    (hr : Related st w) (hb : Budget (k + relayBudget cmd) L w)
    (hq : ∀ rc w', Exec atomPrim cmd w rc w' → q.eval rc w' = true) :
    compileScriptQuery s q = some (.seq (encodeCmd cmd) q.program) ∧
      ∃ env' st',
        interp actDef (fuel + fuelCost cmd + q.fuelCost + 2 * L + 119)
          (.seq (encodeCmd cmd) q.program) initEnv st = .continue env' st' ∧
        Related st' (runCmd cmd w).2 ∧ Budget k L (runCmd cmd w).2 ∧
        lookup env' "rc" = some (.v (.lit (.int ((runCmd cmd w).1 : Int)))) ∧
        lookup env' "q" = some (.v (.lit (.bool true))) := by
  refine ⟨compileScriptQuery_some s q cmd hparse, ?_⟩
  exact script_query_universal_spec actDef hwb hrb hrelay (markSpec_of_lowering actDef hmark)
    L cmd q k fuel st w hr hb hq

/-- Same statement for the program obtained from the text: whatever `compileScriptQuery`
    returns for a parsable script IS the program the theorem executes. -/
theorem compiled_program_export
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = CalculusBody.writeBlockBody)
    (hrb : actDef "read_block" = CalculusRelayOuter.readBlockBody)
    (hrelay : actDef "relay" = CalculusBody.relayBody)
    (hmark : actDef "mark" = CalculusLowering.markBody)
    (L : Nat) (s : String) (cmd : Command Atom) (q : Query) (prog : Stmt String)
    (k fuel : Nat) (st : St) (w : QueryWorld)
    (hparse : parseSupported s = some cmd) (hc : compileScriptQuery s q = some prog)
    (hr : Related st w) (hb : Budget (k + relayBudget cmd) L w)
    (hq : ∀ rc w', Exec atomPrim cmd w rc w' → q.eval rc w' = true) :
    ∃ env' st',
      interp actDef (fuel + fuelCost cmd + q.fuelCost + 2 * L + 119) prog initEnv st =
        .continue env' st' ∧
      Related st' (runCmd cmd w).2 ∧ Budget k L (runCmd cmd w).2 ∧
      lookup env' "rc" = some (.v (.lit (.int ((runCmd cmd w).1 : Int)))) ∧
      lookup env' "q" = some (.v (.lit (.bool true))) := by
  obtain ⟨hc', h⟩ := compileScriptQuery_nested_export actDef hwb hrb hrelay hmark L s cmd q
    k fuel st w hparse hr hb hq
  rw [hc'] at hc
  injection hc with hprog
  rw [← hprog]
  exact h

/-! ## Kernel-checked text witnesses (supported grammar; fail-closed rejection) -/

deriving instance DecidableEq for ShellObservation.Command

theorem parse_relayAndMark : parseSupported "relay && mark" = some relayAndMark := by
  first | decide +kernel | rfl

theorem parse_relayOrMark : parseSupported "relay || mark" = some relayOrMark := by
  first | decide +kernel | rfl

/-- Parentheses and an optional trailing semicolon are in the accepted grammar. -/
theorem parse_paren_trailing : parseSupported "(relay && mark);" = some relayAndMark := by
  first | decide +kernel | rfl

/-- A pipe is outside the supported fragment: the parser fails closed. -/
theorem reject_pipe : parseSupported "relay | mark" = none := by
  first | decide +kernel | rfl

/-! ## The two accepted example scripts, from their text, with the exported mark body -/

/-- `relay && mark` with query `status ≠ 0 ∨ 1 ≤ deliveredLen`: from any related state with
    one relay of headroom, the compiled text program computes `q = true`. -/
theorem text_relayAndMark_markedOrFailed_export
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = CalculusBody.writeBlockBody)
    (hrb : actDef "read_block" = CalculusRelayOuter.readBlockBody)
    (hrelay : actDef "relay" = CalculusBody.relayBody)
    (hmark : actDef "mark" = CalculusLowering.markBody)
    (L k fuel : Nat) (st : St) (w : QueryWorld) (hr : Related st w) (hb : Budget (k + 1) L w) :
    compileScriptQuery "relay && mark" markedOrFailed =
        some (.seq (encodeCmd relayAndMark) markedOrFailed.program) ∧
      ∃ env' st', interp actDef (fuel + 2 * L + 128)
          (.seq (encodeCmd relayAndMark) markedOrFailed.program) initEnv st = .continue env' st' ∧
        Related st' (runCmd relayAndMark w).2 ∧
        lookup env' "q" = some (.v (.lit (.bool true))) :=
  ⟨compileScriptQuery_some _ _ _ parse_relayAndMark,
   relayAndMark_markedOrFailed_export actDef hwb hrb hrelay
     (hmark.trans CalculusQueryExportLink.mark_body_identity.symm) L k fuel st w hr hb⟩

/-- `relay || mark` with query `status = 0` (error-then-recovery), from its text. -/
theorem text_relayOrMark_statusZero_export
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = CalculusBody.writeBlockBody)
    (hrb : actDef "read_block" = CalculusRelayOuter.readBlockBody)
    (hrelay : actDef "relay" = CalculusBody.relayBody)
    (hmark : actDef "mark" = CalculusLowering.markBody)
    (L k fuel : Nat) (st : St) (w : QueryWorld) (hr : Related st w) (hb : Budget (k + 1) L w) :
    compileScriptQuery "relay || mark" statusZero =
        some (.seq (encodeCmd relayOrMark) statusZero.program) ∧
      ∃ env' st', interp actDef (fuel + 2 * L + 122)
          (.seq (encodeCmd relayOrMark) statusZero.program) initEnv st = .continue env' st' ∧
        Related st' (runCmd relayOrMark w).2 ∧
        lookup env' "q" = some (.v (.lit (.bool true))) :=
  ⟨compileScriptQuery_some _ _ _ parse_relayOrMark,
   relayOrMark_statusZero_export actDef hwb hrb hrelay
     (hmark.trans CalculusQueryExportLink.mark_body_identity.symm) L k fuel st w hr hb⟩

#print axioms markSpec_of_lowering
#print axioms compileScriptQuery_nested_export
#print axioms compiled_program_export
#print axioms parse_relayAndMark
#print axioms parse_relayOrMark
#print axioms parse_paren_trailing
#print axioms reject_pipe
#print axioms text_relayAndMark_markedOrFailed_export
#print axioms text_relayOrMark_statusZero_export

end CalculusShellTextExport
