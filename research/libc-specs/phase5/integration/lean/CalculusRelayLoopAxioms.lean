import CalculusRelayOuter
-- axiom audit for calculus-correspondence-14's loop/simulation/read_block/relay theorems
#print axioms CalculusSimulation.interp_fuel_mono
#print axioms CalculusSimulation.interp_fuel_mono_le
#print axioms CalculusRelayLoop.relay_inner_lost
#print axioms CalculusRelayLoop.relay_inner_step_inv
#print axioms CalculusRelayLoop.relay_inner_loop_run
#print axioms CalculusRelayLoop.relay_inner_loop_terminates
#print axioms CalculusRelayLoop.relay_inner_loop_terminates_any_fuel
#print axioms CalculusRelayOuter.readBlock_parse
#print axioms CalculusRelayOuter.readBlock_render
#print axioms CalculusRelayOuter.read_block_body_ret
#print axioms CalculusRelayOuter.read_block_body_neg
#print axioms CalculusRelayOuter.relayBody_eq
#print axioms CalculusRelayOuter.relay_outer_step
#print axioms CalculusRelayOuter.relay_outer_loop_run
#print axioms CalculusRelayOuter.relay_outer_loop_terminates
#print axioms CalculusRelayOuter.relay_prologue
#print axioms CalculusRelayOuter.relay_terminates
#print axioms CalculusRelayOuter.writeBlockBody_WF
#print axioms CalculusRelayOuter.readBlockBody_WF
#print axioms CalculusRelayOuter.relayBody_WF
#print axioms CalculusRelayOuter.writeBlock_round_trip
#print axioms CalculusRelayOuter.readBlock_round_trip
#print axioms CalculusRelayOuter.relay_round_trip
-- executable receipt for the read_block text -> tokens link (not kernel-checked; see CalculusBodyReceipts)
def readBlockText : String := "(seq (assign b ι) (seq (seq (get $t1 σ reads) (seq (get $t2 b cap) (assign q (head_or (pair $t1 $t2))))) (seq (seq (get $t3 σ reads) (set-attr σ reads (tail $t3))) (seq (seq (get $t4 σ read_calls) (set-attr σ read_calls (+ (pair $t4 1)))) (seq (if (< (pair q 0)) (return -1) pass) (seq (seq (get $t5 b cap) (seq (get $t6 σ input) (assign k (min (pair (max (pair 1 q)) (min (pair $t5 (length $t6)))))))) (seq (seq (get $t7 σ input) (set-attr b bytes (take (pair $t7 (range:0:4611686018427387903 k))))) (seq (set-attr b len (range:0:4611686018427387903 k)) (seq (seq (get $t8 σ input) (set-attr σ input (drop (pair $t8 (range:0:4611686018427387903 k))))) (return k))))))))))"
#eval (CalculusExport.tokenize readBlockText == CalculusRelayOuter.readBlockToks,
       CalculusExport.parseStmt 400 (CalculusExport.tokenize readBlockText) == some (CalculusRelayOuter.readBlockBody, []))
