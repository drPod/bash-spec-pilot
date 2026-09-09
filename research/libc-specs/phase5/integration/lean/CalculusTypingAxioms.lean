import CalculusTyping
import CalculusLowering
import CalculusTypeCheck
-- calculus-correspondence-61: axiom audit + executable receipts for the typing and lowering modules
#print axioms CalculusTyping.Sub_sound
#print axioms CalculusTyping.funcDef_sound
#print axioms CalculusTyping.ETy_sound
#print axioms CalculusTyping.STy_extends
#print axioms CalculusTyping.preservation
#print axioms CalculusLowering.lowering_checked
-- the lowering, evaluated: every exported body is reproduced (should print 9 `true`s and the names)
#eval (CalculusLowering.lowerProgram CalculusLowering.byteRelayExecSpec).map (fun l => l.map (·.1))
#eval match CalculusLowering.lowerProgram CalculusLowering.byteRelayExecSpec with
  | some l => l.map (fun (n, b) =>
      (n, b == (match n with
        | "read_block" => CalculusRelayOuter.readBlockBody | "write_block" => CalculusBody.writeBlockBody
        | "relay" => CalculusBody.relayBody | "relay_raising" => CalculusLowering.relayRaisingBody
        | "relay_caught" => CalculusLowering.relayCaughtBody | "mark" => CalculusLowering.markBody
        | "relay_seq_relay" => CalculusLowering.relaySeqRelayBody
        | "relay_and_mark" => CalculusLowering.relayAndMarkBody
        | _ => CalculusLowering.relayOrMarkBody)))
  | none => []
-- type checker + concrete instantiation (CalculusTypeCheck)
#print axioms CalculusTypeCheck.subB_sound
#print axioms CalculusTypeCheck.inferE_sound
#print axioms CalculusTypeCheck.checkS_sound
#print axioms CalculusTypeCheck.writeBlock_typed
#print axioms CalculusTypeCheck.relayCaught_typed
#print axioms CalculusTypeCheck.relayActs_typed
#print axioms CalculusTypeCheck.writeBlock_preserves
-- the checker's actual output contexts for the three main bodies (executable receipt)
#eval (CalculusTypeCheck.checkS CalculusTypeCheck.relaySchema CalculusTypeCheck.relaySig .int
  (CalculusTypeCheck.calleeCtxL (.rpair .ref (.data (.pair .int .int)))) CalculusBody.writeBlockBody).map (·.map (·.1))
#eval (CalculusTypeCheck.checkS CalculusTypeCheck.relaySchema CalculusTypeCheck.relaySig .int
  (CalculusTypeCheck.calleeCtxL .ref) CalculusRelayOuter.readBlockBody).map (·.map (·.1))
#eval (CalculusTypeCheck.checkS CalculusTypeCheck.relaySchema CalculusTypeCheck.relaySig .int
  (CalculusTypeCheck.calleeCtxL (.data .unit)) CalculusBody.relayBody).map (·.map (·.1))
