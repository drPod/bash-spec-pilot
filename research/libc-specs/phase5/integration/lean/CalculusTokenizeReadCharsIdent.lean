import CalculusTokenizeReadCharsJoin
import CalculusTokenizeReadCharsSuf
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull
open CalculusTokenizeReadChars CalculusTokenizeReadCharsJoin CalculusTokenizeReadCharsSuf
namespace CalculusTokenizeReadCharsIdent
set_option maxRecDepth 100000
theorem step1 :
    tokenizeT (calculustokenizereadchars_s0.length + 1) calculustokenizereadchars_s0 = some readBlockToks :=
  Eq.subst (motive := fun ts => tokenizeT (calculustokenizereadchars_s0.length + 1) calculustokenizereadchars_s0 = some ts)
    (Eq.symm readBlockToks_eq_st0) calculustokenizereadchars_s0_tok_len
theorem step2 :
    tokenizeT (calculustokenizereadchars_s0.length + 1) rbChars = some readBlockToks :=
  Eq.subst (motive := fun cs => tokenizeT (calculustokenizereadchars_s0.length + 1) cs = some readBlockToks)
    (Eq.symm rbChars_eq_s0) step1
theorem rbChars_tokens :
    tokenizeT (rbChars.length + 1) rbChars = some readBlockToks :=
  Eq.subst (motive := fun n => tokenizeT (n + 1) rbChars = some readBlockToks)
    (congrArg List.length rbChars_eq_s0) step2
theorem readBlock_text_tokens : tokenizeTotal readBlockText = some readBlockToks := by
  unfold tokenizeTotal
  rw [readBlockText_toList, readBlockText_length]
  exact rbChars_tokens
end CalculusTokenizeReadCharsIdent
