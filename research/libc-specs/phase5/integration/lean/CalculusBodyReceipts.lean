import CalculusBody
open CalculusNested CalculusExport CalculusBody

/-! Executable receipts (calculus-correspondence-13). NOT kernel-checked; these close the one
link the kernel does not see: the exporter's TEXT -> `CalculusExport.tokenize` (a `partial`
def) -> the token lists the kernel-checked identity theorems are stated over. The two strings
are the verbatim `write_block`/`relay` lines of
`calculus-correspondence/results/export_input__byte_relay_exec.tsv`. -/

def writeBlockText : String := "(seq (assign b (fst ι)) (seq (assign off (range:0:4611686018427387903 (fst (snd ι)))) (seq (assign n (range:0:4611686018427387903 (snd (snd ι)))) (seq (if (<= (pair off n)) pass (raise (pair \"AssertionFailure\" ()))) (seq (seq (get $t9 b len) (if (<= (pair n $t9)) pass (raise (pair \"AssertionFailure\" ())))) (seq (seq (get $t10 b len) (assign l $t10)) (seq (seq (get $t11 b cap) (if (<= (pair l $t11)) pass (raise (pair \"AssertionFailure\" ())))) (seq (seq (get $t12 b bytes) (assign req (slice (pair $t12 (pair off n))))) (seq (seq (get $t13 σ writes) (assign q (head_or (pair $t13 (length (range-list:0:255 req)))))) (seq (seq (get $t14 σ writes) (set-attr σ writes (tail $t14))) (seq (seq (get $t15 σ write_calls) (set-attr σ write_calls (+ (pair $t15 1)))) (seq (if (< (pair q 0)) (return -1) pass) (seq (assign k (min (pair q (length (range-list:0:255 req))))) (seq (seq (get $t16 σ delivered) (set-attr σ delivered (append (pair $t16 (take (pair (range-list:0:255 req) (range:0:4611686018427387903 k))))))) (return k)))))))))))))))"
def relayText : String := "(seq (remove-elem σ block 0) (seq (add-elem σ block 0) (seq (assign b (elem σ block 0)) (seq (set-attr b cap 32) (seq (set-attr b len 0) (seq (set-attr b bytes (empty ())) (while true (seq (seq (seq (action $t17 read_block b) (assign r $t17)) (seq (if (< (pair r 0)) (return 1) pass) (seq (if (== (pair r 0)) (return 0) pass) (seq (assign off 0) (while (< (pair off r)) (seq (seq (seq (action $t18 write_block (pair b (pair (range:0:4611686018427387903 off) (range:0:4611686018427387903 r)))) (assign w $t18)) (seq (if (<= (pair w 0)) (seq (seq (get $t19 σ lost) (seq (get $t20 b bytes) (set-attr σ lost (append (pair $t19 (slice (pair $t20 (pair (range:0:4611686018427387903 off) (range:0:4611686018427387903 r))))))))) (return 2)) pass) (assign off (+ (pair off w))))) pass)))))) pass))))))))"

#eval (tokenize writeBlockText == writeBlockToks, tokenize relayText == relayToks)
#eval (parseStmt 400 (tokenize writeBlockText) == some (writeBlockBody, []),
       parseStmt 400 (tokenize relayText) == some (relayBody, []))

#print axioms CalculusBody.writeBlock_parse
#print axioms CalculusBody.writeBlock_render
#print axioms CalculusBody.relay_parse
#print axioms CalculusBody.relay_render
#print axioms CalculusBody.setAttrAt_isSome_of_getAttrAt
#print axioms CalculusBody.write_block_body_ret
#print axioms CalculusBody.write_block_body_neg
#print axioms CalculusBody.write_block_assert1_raises
#print axioms CalculusBody.write_block_assert2_raises
#print axioms CalculusBody.write_block_assert3_raises
#print axioms CalculusBody.relay_inner_step
