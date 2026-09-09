import CalculusTokenizeChars
open CalculusTokenize CalculusTokenizeChars
namespace CalculusTokenizeCharsSuf
set_option maxRecDepth 100000
theorem wb_s0_tok_len :
    tokenizeT (wb_s0.length + 1) wb_s0 = some wb_st0 :=
  tokenizeT_sufficient 1197 wb_s0 wb_st0 wb_s0_tok
end CalculusTokenizeCharsSuf
