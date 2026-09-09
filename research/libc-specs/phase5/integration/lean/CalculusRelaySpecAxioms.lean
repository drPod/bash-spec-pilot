import CalculusRelaySpec
import CalculusTokenize
import CalculusFragmentRules
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusRelaySpec CalculusTokenize
-- calculus-correspondence-15: phase3 correspondence and total tokenizer
#print axioms CalculusRelaySpec.relay_inner_exact
#print axioms CalculusRelaySpec.relay_outer_exact_step
#print axioms CalculusRelaySpec.relay_outer_exact
#print axioms CalculusRelaySpec.relay_matches_phase3
#print axioms CalculusFragmentRules.interp_pure_state
#print axioms CalculusFragmentRules.supported_of_stmt
#print axioms CalculusTokenize.small_text_tokens
#print axioms CalculusTokenize.rejects_unterminated_string
#print axioms CalculusTokenize.rejects_unterminated_after_escape
#print axioms CalculusTokenize.rejects_non_statement
#print axioms CalculusTokenize.rejects_trailing
#print axioms CalculusTokenize.rejects_match_text
#print axioms CalculusTokenize.rejects_underscore_range
-- executable receipts: the total tokenizer on the three verbatim exports, and its agreement
-- with the historical partial tokenizer on them (not kernel-checked; see the module docstring)
#eval (tokenizeTotal writeBlockText == some writeBlockToks,
       tokenizeTotal relayText == some relayToks,
       tokenizeTotal readBlockText == some readBlockToks)
#eval (tokenizeTotal writeBlockText == some (CalculusExport.tokenize writeBlockText),
       tokenizeTotal relayText == some (CalculusExport.tokenize relayText),
       tokenizeTotal readBlockText == some (CalculusExport.tokenize readBlockText))
#eval (parseText writeBlockText == some writeBlockBody,
       parseText relayText == some relayBody,
       parseText readBlockText == some readBlockBody)
-- a concrete instance of `relay_matches_phase3`'s two sides, evaluated: the calculus run and the
-- phase3 model agree on the phase3 example schedule (Examples.retry_binary)
#eval (BufferRelay.run [0, 255, 10, 128] [2, 1] [1, 1, 1, 1])
#eval (renderRes (runEntry (actDefOf [("relay", relayBody), ("read_block", readBlockBody), ("write_block", writeBlockBody)]) 4000 "relay" (initialState (toInts [0, 255, 10, 128]) [2, 1] [1, 1, 1, 1])))
