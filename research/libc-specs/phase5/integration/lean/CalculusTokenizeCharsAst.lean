/-
CalculusTokenizeCharsAst.lean (tokenizer-chars-100)
writeBlock_text_ast on the original writeBlockText literal.
-/
import CalculusTokenizeCharsIdent
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull
open CalculusTokenizeCharsIdent

namespace CalculusTokenizeCharsAst
set_option maxRecDepth 100000

theorem parseText_unfold (s : String) :
    parseText s =
      match tokenizeTotal s with
      | some toks =>
        match parseStmt 400 toks with
        | some (st, []) => some st
        | _ => none
      | none => none := rfl

theorem writeBlock_text_ast : parseText writeBlockText = some writeBlockBody := by
  rw [parseText_unfold, writeBlock_text_tokens]
  change (match parseStmt 400 writeBlockToks with
          | some (st, []) => some st
          | _ => none) = some writeBlockBody
  rw [writeBlock_parse]

#print axioms CalculusTokenizeCharsIdent.writeBlock_text_tokens
#print axioms writeBlock_text_ast

end CalculusTokenizeCharsAst
