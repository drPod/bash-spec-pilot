/-
CalculusTokenizeCharsIdent.lean (tokenizer-chars-100)
writeBlock_text_tokens on the original writeBlockText literal.
-/
import CalculusTokenizeCharsJoin
import CalculusTokenizeCharsSuf
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull
open CalculusTokenizeChars CalculusTokenizeCharsJoin CalculusTokenizeCharsSuf

namespace CalculusTokenizeCharsIdent
set_option maxRecDepth 100000

theorem step1 :
    tokenizeT (wb_s0.length + 1) wb_s0 = some writeBlockToks :=
  Eq.subst (motive := fun ts => tokenizeT (wb_s0.length + 1) wb_s0 = some ts)
    (Eq.symm writeBlockToks_eq_st0) wb_s0_tok_len

theorem step2 :
    tokenizeT (wb_s0.length + 1) wbChars = some writeBlockToks :=
  Eq.subst (motive := fun cs => tokenizeT (wb_s0.length + 1) cs = some writeBlockToks)
    (Eq.symm wbChars_eq_s0) step1

theorem wbChars_tokens :
    tokenizeT (wbChars.length + 1) wbChars = some writeBlockToks :=
  Eq.subst (motive := fun n => tokenizeT (n + 1) wbChars = some writeBlockToks)
    (congrArg List.length wbChars_eq_s0) step2

theorem writeBlock_text_tokens : tokenizeTotal writeBlockText = some writeBlockToks := by
  unfold tokenizeTotal
  rw [writeBlockText_toList, writeBlockText_length]
  exact wbChars_tokens

end CalculusTokenizeCharsIdent
