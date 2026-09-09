import CalculusTokenizeRelayCharsJoin
import CalculusTokenizeRelayCharsSuf
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull
open CalculusTokenizeRelayChars CalculusTokenizeRelayCharsJoin CalculusTokenizeRelayCharsSuf
namespace CalculusTokenizeRelayCharsIdent
set_option maxRecDepth 100000
theorem step1 :
    tokenizeT (calculustokenizerelaychars_s0.length + 1) calculustokenizerelaychars_s0 = some relayToks :=
  Eq.subst (motive := fun ts => tokenizeT (calculustokenizerelaychars_s0.length + 1) calculustokenizerelaychars_s0 = some ts)
    (Eq.symm relayToks_eq_st0) calculustokenizerelaychars_s0_tok_len
theorem step2 :
    tokenizeT (calculustokenizerelaychars_s0.length + 1) rlChars = some relayToks :=
  Eq.subst (motive := fun cs => tokenizeT (calculustokenizerelaychars_s0.length + 1) cs = some relayToks)
    (Eq.symm rlChars_eq_s0) step1
theorem rlChars_tokens :
    tokenizeT (rlChars.length + 1) rlChars = some relayToks :=
  Eq.subst (motive := fun n => tokenizeT (n + 1) rlChars = some relayToks)
    (congrArg List.length rlChars_eq_s0) step2
theorem relay_text_tokens : tokenizeTotal relayText = some relayToks := by
  unfold tokenizeTotal
  rw [relayText_toList, relayText_length]
  exact rlChars_tokens
end CalculusTokenizeRelayCharsIdent
