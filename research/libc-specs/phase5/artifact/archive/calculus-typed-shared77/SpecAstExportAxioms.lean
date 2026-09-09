/- Axiom audit + executable receipt for `SpecAstExport` (calculus-correspondence-75). -/
import SpecAstExport
open CalculusLowering

#print axioms CalculusLowering.exportedSpec_eq_hand
#print axioms CalculusLowering.exported_lowers
#print axioms CalculusLowering.lowering_checked

-- executable receipts: 33 declarations exported; nine functions lowered from the machine AST
#eval CalculusLowering.exportedSpec.length
#eval (CalculusLowering.lowerProgram CalculusLowering.exportedSpec).map (fun l => l.map (·.1))
