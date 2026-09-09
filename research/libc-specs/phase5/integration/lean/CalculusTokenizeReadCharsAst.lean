import CalculusTokenizeReadCharsIdent
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull
open CalculusTokenizeReadCharsIdent
namespace CalculusTokenizeReadCharsAst
set_option maxRecDepth 100000
theorem parseText_unfold (s : String) :
    parseText s =
      match tokenizeTotal s with
      | some toks =>
        match parseStmt 400 toks with
        | some (st, []) => some st
        | _ => none
      | none => none := rfl
theorem readBlock_text_ast : parseText readBlockText = some readBlockBody := by
  rw [parseText_unfold, readBlock_text_tokens]
  change (match parseStmt 400 readBlockToks with
          | some (st, []) => some st
          | _ => none) = some readBlockBody
  rw [readBlock_parse]
#print axioms CalculusTokenizeReadCharsIdent.readBlock_text_tokens
#print axioms readBlock_text_ast
end CalculusTokenizeReadCharsAst
