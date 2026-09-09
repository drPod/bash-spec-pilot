import CalculusTokenizeRelayCharsIdent
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull
open CalculusTokenizeRelayCharsIdent
namespace CalculusTokenizeRelayCharsAst
set_option maxRecDepth 100000
theorem parseText_unfold (s : String) :
    parseText s =
      match tokenizeTotal s with
      | some toks =>
        match parseStmt 400 toks with
        | some (st, []) => some st
        | _ => none
      | none => none := rfl
theorem relay_text_ast : parseText relayText = some relayBody := by
  rw [parseText_unfold, relay_text_tokens]
  change (match parseStmt 400 relayToks with
          | some (st, []) => some st
          | _ => none) = some relayBody
  rw [relay_parse]
#print axioms CalculusTokenizeRelayCharsIdent.relay_text_tokens
#print axioms relay_text_ast
end CalculusTokenizeRelayCharsAst
