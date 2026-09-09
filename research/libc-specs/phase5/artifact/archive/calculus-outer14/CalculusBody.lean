import CalculusExport
open CalculusNested CalculusExport

/-!
# CalculusBody: the REAL exported bodies of `write_block` and `relay`, kernel-identified with
# the exporter's own token stream, and statement-level theorems about them
# (calculus-correspondence-13, 2026-09-08)

Two kinds of results, kept separate on purpose:

1. **Mechanical identity with the export.** `writeBlockToks`/`relayToks` are the token lists of
   the current `calculus-correspondence/results/export_input__byte_relay_exec.tsv` entries
   (sha256 `5b3af9ea…`; the lists were generated from that file by a script, not typed).
   `writeBlock_parse`/`relay_parse` are KERNEL-CHECKED (`decide +kernel`): the shared checked
   parser `CalculusExport.parseStmt` maps those tokens to exactly the `Stmt` values
   `writeBlockBody`/`relayBody` stated below, and `renderStmtToks` maps them back. The one
   link this does NOT cover is text -> tokens (`CalculusExport.tokenize`, `partial`, untrusted
   glue, exactly as it already was for `export-run`/`compare-run`); that link is checked
   executably (`CalculusBodyReceipts.lean`), not by the kernel.

2. **Whole-body theorems.** `write_block_body_ret`/`write_block_body_neg` state, for EVERY
   fuel, environment, state, block path, root path, offset/length, byte content and write
   schedule satisfying the explicit well-formedness hypotheses, exactly what running
   `writeBlockBody` does: the three `setAttrAt` updates it performs (in order, at the root
   path `σ`), the value it returns, and the environment it returns with. The three
   `write_block_assert*_raises` theorems characterize the `AssertionFailure` error paths.
   `relay_inner_step` composes the body theorem through the real `.action` call site of
   `relay`'s inner `while` loop: one positive-write iteration advances `off` by the returned
   `k > 0` and continues the SAME loop with fuel reduced by exactly two.

What these theorems are NOT: theorems about the OCaml program (the transcription/trust
boundary is unchanged, see `CalculusNested.lean`'s header and
`calculus-correspondence/README.md`), termination or a full invariant for either of `relay`'s
loops (see the README's "Exact remaining theorem obligations"), or type soundness of the
calculus as a language — the in-range/well-formedness hypotheses below are exactly the
premises such a soundness theorem would have to discharge for a well-typed caller.
-/

namespace CalculusBody

/-! ## The exported bodies, token-for-token -/

def writeBlockToks : List String := ["(", "seq", "(", "assign", "b", "(", "fst", "ι", ")", ")", "(", "seq", "(", "assign", "off", "(", "range:0:4611686018427387903", "(", "fst", "(", "snd", "ι", ")", ")", ")", ")", "(", "seq", "(", "assign", "n", "(", "range:0:4611686018427387903", "(", "snd", "(", "snd", "ι", ")", ")", ")", ")", "(", "seq", "(", "if", "(", "<=", "(", "pair", "off", "n", ")", ")", "pass", "(", "raise", "(", "pair", "\"AssertionFailure\"", "(", ")", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t9", "b", "len", ")", "(", "if", "(", "<=", "(", "pair", "n", "$t9", ")", ")", "pass", "(", "raise", "(", "pair", "\"AssertionFailure\"", "(", ")", ")", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t10", "b", "len", ")", "(", "assign", "l", "$t10", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t11", "b", "cap", ")", "(", "if", "(", "<=", "(", "pair", "l", "$t11", ")", ")", "pass", "(", "raise", "(", "pair", "\"AssertionFailure\"", "(", ")", ")", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t12", "b", "bytes", ")", "(", "assign", "req", "(", "slice", "(", "pair", "$t12", "(", "pair", "off", "n", ")", ")", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t13", "σ", "writes", ")", "(", "assign", "q", "(", "head_or", "(", "pair", "$t13", "(", "length", "(", "range-list:0:255", "req", ")", ")", ")", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t14", "σ", "writes", ")", "(", "set-attr", "σ", "writes", "(", "tail", "$t14", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t15", "σ", "write_calls", ")", "(", "set-attr", "σ", "write_calls", "(", "+", "(", "pair", "$t15", "1", ")", ")", ")", ")", "(", "seq", "(", "if", "(", "<", "(", "pair", "q", "0", ")", ")", "(", "return", "-1", ")", "pass", ")", "(", "seq", "(", "assign", "k", "(", "min", "(", "pair", "q", "(", "length", "(", "range-list:0:255", "req", ")", ")", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t16", "σ", "delivered", ")", "(", "set-attr", "σ", "delivered", "(", "append", "(", "pair", "$t16", "(", "take", "(", "pair", "(", "range-list:0:255", "req", ")", "(", "range:0:4611686018427387903", "k", ")", ")", ")", ")", ")", ")", ")", "(", "return", "k", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")"]

def writeBlockBody : Stmt String :=
(.seq
  (.assign "b" (.fn .fst (.var "ι")))
  (.seq
    (.assign "off" (.fn (.range 0 4611686018427387903) (.fn .fst (.fn .snd (.var "ι")))))
    (.seq
      (.assign "n" (.fn (.range 0 4611686018427387903) (.fn .snd (.fn .snd (.var "ι")))))
      (.seq
        (.cond (.fn .le (.pair (.var "off") (.var "n")))
          .pass
          (.raise (.pair (.lit (.str "AssertionFailure")) (.lit .unit))))
        (.seq
          (.seq
            (.get "$t9" (.var "b") "len")
            (.cond (.fn .le (.pair (.var "n") (.var "$t9")))
              .pass
              (.raise (.pair (.lit (.str "AssertionFailure")) (.lit .unit)))))
          (.seq
            (.seq
              (.get "$t10" (.var "b") "len")
              (.assign "l" (.var "$t10")))
            (.seq
              (.seq
                (.get "$t11" (.var "b") "cap")
                (.cond (.fn .le (.pair (.var "l") (.var "$t11")))
                  .pass
                  (.raise (.pair (.lit (.str "AssertionFailure")) (.lit .unit)))))
              (.seq
                (.seq
                  (.get "$t12" (.var "b") "bytes")
                  (.assign "req" (.fn .slice (.pair (.var "$t12") (.pair (.var "off") (.var "n"))))))
                (.seq
                  (.seq
                    (.get "$t13" (.var "σ") "writes")
                    (.assign "q" (.fn .headOr (.pair (.var "$t13") (.fn .length (.fn (.rangeList 0 255) (.var "req")))))))
                  (.seq
                    (.seq
                      (.get "$t14" (.var "σ") "writes")
                      (.setAttr (.var "σ") "writes" (.fn .tail (.var "$t14"))))
                    (.seq
                      (.seq
                        (.get "$t15" (.var "σ") "write_calls")
                        (.setAttr (.var "σ") "write_calls" (.fn .add (.pair (.var "$t15") (.lit (.int 1))))))
                      (.seq
                        (.cond (.fn .lt (.pair (.var "q") (.lit (.int 0))))
                          (.ret (.lit (.int (-1))))
                          .pass)
                        (.seq
                          (.assign "k" (.fn .min (.pair (.var "q") (.fn .length (.fn (.rangeList 0 255) (.var "req"))))))
                          (.seq
                            (.seq
                              (.get "$t16" (.var "σ") "delivered")
                              (.setAttr (.var "σ") "delivered" (.fn .append (.pair (.var "$t16") (.fn .take (.pair (.fn (.rangeList 0 255) (.var "req")) (.fn (.range 0 4611686018427387903) (.var "k"))))))))
                            (.ret (.var "k"))))))))))))))))

def relayToks : List String := ["(", "seq", "(", "remove-elem", "σ", "block", "0", ")", "(", "seq", "(", "add-elem", "σ", "block", "0", ")", "(", "seq", "(", "assign", "b", "(", "elem", "σ", "block", "0", ")", ")", "(", "seq", "(", "set-attr", "b", "cap", "32", ")", "(", "seq", "(", "set-attr", "b", "len", "0", ")", "(", "seq", "(", "set-attr", "b", "bytes", "(", "empty", "(", ")", ")", ")", "(", "while", "true", "(", "seq", "(", "seq", "(", "seq", "(", "action", "$t17", "read_block", "b", ")", "(", "assign", "r", "$t17", ")", ")", "(", "seq", "(", "if", "(", "<", "(", "pair", "r", "0", ")", ")", "(", "return", "1", ")", "pass", ")", "(", "seq", "(", "if", "(", "==", "(", "pair", "r", "0", ")", ")", "(", "return", "0", ")", "pass", ")", "(", "seq", "(", "assign", "off", "0", ")", "(", "while", "(", "<", "(", "pair", "off", "r", ")", ")", "(", "seq", "(", "seq", "(", "seq", "(", "action", "$t18", "write_block", "(", "pair", "b", "(", "pair", "(", "range:0:4611686018427387903", "off", ")", "(", "range:0:4611686018427387903", "r", ")", ")", ")", ")", "(", "assign", "w", "$t18", ")", ")", "(", "seq", "(", "if", "(", "<=", "(", "pair", "w", "0", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t19", "σ", "lost", ")", "(", "seq", "(", "get", "$t20", "b", "bytes", ")", "(", "set-attr", "σ", "lost", "(", "append", "(", "pair", "$t19", "(", "slice", "(", "pair", "$t20", "(", "pair", "(", "range:0:4611686018427387903", "off", ")", "(", "range:0:4611686018427387903", "r", ")", ")", ")", ")", ")", ")", ")", ")", ")", "(", "return", "2", ")", ")", "pass", ")", "(", "assign", "off", "(", "+", "(", "pair", "off", "w", ")", ")", ")", ")", ")", "pass", ")", ")", ")", ")", ")", ")", "pass", ")", ")", ")", ")", ")", ")", ")", ")"]

/-- `relay`'s inner `while` loop, exactly as exported (a sub-term of `relayBody` below; the
    kernel identity `relay_parse` covers it because `relayBody` is built from it). -/
def relayInnerBody : Stmt String :=
(.seq
                            (.seq
                              (.seq
                                (.action "$t18" "write_block" (.pair (.var "b") (.pair (.fn (.range 0 4611686018427387903) (.var "off")) (.fn (.range 0 4611686018427387903) (.var "r")))))
                                (.assign "w" (.var "$t18")))
                              (.seq
                                (.cond (.fn .le (.pair (.var "w") (.lit (.int 0))))
                                  (.seq
                                    (.seq
                                      (.get "$t19" (.var "σ") "lost")
                                      (.seq
                                        (.get "$t20" (.var "b") "bytes")
                                        (.setAttr (.var "σ") "lost" (.fn .append (.pair (.var "$t19") (.fn .slice (.pair (.var "$t20") (.pair (.fn (.range 0 4611686018427387903) (.var "off")) (.fn (.range 0 4611686018427387903) (.var "r"))))))))))
                                    (.ret (.lit (.int 2))))
                                  .pass)
                                (.assign "off" (.fn .add (.pair (.var "off") (.var "w"))))))
                            .pass)

def relayInnerLoop : Stmt String :=
  .while (.fn .lt (.pair (.var "off") (.var "r"))) relayInnerBody

def relayBody : Stmt String :=
(.seq
  (.removeElem (.var "σ") "block" (.lit (.int 0)))
  (.seq
    (.addElem (.var "σ") "block" (.lit (.int 0)))
    (.seq
      (.assign "b" (.elem (.var "σ") "block" (.lit (.int 0))))
      (.seq
        (.setAttr (.var "b") "cap" (.lit (.int 32)))
        (.seq
          (.setAttr (.var "b") "len" (.lit (.int 0)))
          (.seq
            (.setAttr (.var "b") "bytes" (.fn .empty (.lit .unit)))
            (.while (.lit (.bool true))
              (.seq
                (.seq
                  (.seq
                    (.action "$t17" "read_block" (.var "b"))
                    (.assign "r" (.var "$t17")))
                  (.seq
                    (.cond (.fn .lt (.pair (.var "r") (.lit (.int 0))))
                      (.ret (.lit (.int 1)))
                      .pass)
                    (.seq
                      (.cond (.fn .eq (.pair (.var "r") (.lit (.int 0))))
                        (.ret (.lit (.int 0)))
                        .pass)
                      (.seq
                        (.assign "off" (.lit (.int 0)))
                        relayInnerLoop))))
                .pass))))))))

theorem writeBlock_parse : parseStmt 400 writeBlockToks = some (writeBlockBody, []) := by
  decide +kernel
theorem writeBlock_render : renderStmtToks writeBlockBody = writeBlockToks := by
  decide +kernel
theorem relay_parse : parseStmt 400 relayToks = some (relayBody, []) := by
  decide +kernel
theorem relay_render : renderStmtToks relayBody = relayToks := by
  decide +kernel

/-! ## Builtin evaluation lemmas (each one line of `funcDef`, with its precondition explicit) -/

theorem Val.asByteList?_ofIntList (xs : List Int)
    (h : xs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    Val.asByteList? (Val.ofIntList xs) = some xs := by
  simp only [Val.asByteList?, Val.asIntList?_ofIntList, h]
  rfl

theorem all_take_of_all {p : Int → Bool} (xs : List Int) (k : Nat) (h : xs.all p = true) :
    (xs.take k).all p = true :=
  List.all_eq_true.mpr (fun x hx => List.all_eq_true.mp h x (List.mem_of_mem_take hx))

theorem all_drop_of_all {p : Int → Bool} (xs : List Int) (k : Nat) (h : xs.all p = true) :
    (xs.drop k).all p = true :=
  List.all_eq_true.mpr (fun x hx => List.all_eq_true.mp h x (List.mem_of_mem_drop hx))

/-- A path that can be read can be written: the `setAttrAt` results the body theorems take as
    hypotheses always exist. -/
theorem setAttrAt_isSome_of_getAttrAt : ∀ (p : Path) (st : St) (a b : String) (x y : Val),
    getAttrAt p st a = some x → ∃ st', setAttrAt p st b y = some st' := by
  intro p
  induction p with
  | here => intro st a b x y _; exact ⟨_, rfl⟩
  | nested n v rest ih =>
    intro st a b x y h
    simp only [getAttrAt] at h
    split at h
    · cases h
    · rename_i sub hsub
      obtain ⟨sub', hsub'⟩ := ih sub a b x y h
      exact ⟨St.mk st.attrs (assocSet st.elems (n, v) sub'), by simp [setAttrAt, hsub, hsub']⟩

/-- `head_or ws d` on a schedule list: the next scheduled write count, or `d` if none. -/
def wbQ (ws : List Int) (req : List Int) : Int :=
  match ws with
  | [] => (req.length : Int)
  | x :: _ => x

theorem funcDef_fst (a b : Val) : funcDef .fst (.pair a b) = some a := by simp [funcDef]
theorem funcDef_snd (a b : Val) : funcDef .snd (.pair a b) = some b := by simp [funcDef]
theorem funcDef_headOr_ofIntList (ws req : List Int) :
    funcDef .headOr (.pair (Val.ofIntList ws) (.lit (.int (req.length : Int)))) =
      some (.lit (.int (wbQ ws req))) := by
  cases ws <;> simp [funcDef, Val.asIntList?_ofIntList, wbQ]
theorem funcDef_tail_ofIntList (ws : List Int) :
    funcDef .tail (Val.ofIntList ws) = some (Val.ofIntList ws.tail) := by
  simp [funcDef, Val.asIntList?_ofIntList]
theorem funcDef_le (a b : Int) :
    funcDef .le (.pair (.lit (.int a)) (.lit (.int b))) = some (.lit (.bool (decide (a ≤ b)))) := by
  simp [funcDef]
theorem funcDef_lt (a b : Int) :
    funcDef .lt (.pair (.lit (.int a)) (.lit (.int b))) = some (.lit (.bool (decide (a < b)))) := by
  simp [funcDef]
theorem funcDef_range (n lo hi : Int) (h : lo ≤ n ∧ n ≤ hi) :
    funcDef (.range lo hi) (.lit (.int n)) = some (.lit (.int n)) := by
  simp [funcDef, h]
theorem funcDef_rangeList (lo hi : Int) (xs : List Int)
    (h : xs.all (fun i => decide (lo ≤ i ∧ i ≤ hi)) = true) :
    funcDef (.rangeList lo hi) (Val.ofIntList xs) = some (Val.ofIntList xs) := by
  simp only [funcDef, Val.asIntList?_ofIntList, h] <;> rfl
theorem funcDef_length (xs : List Int) :
    funcDef .length (Val.ofIntList xs) = some (.lit (.int (xs.length : Int))) := by
  simp [funcDef, Val.asIntList?_ofIntList]
theorem funcDef_slice (bs : List Int) (off n : Int)
    (hb : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hc : 0 ≤ off ∧ off ≤ n ∧ n ≤ (bs.length : Int)) :
    funcDef .slice (.pair (Val.ofIntList bs) (.pair (.lit (.int off)) (.lit (.int n)))) =
      some (Val.ofIntList ((bs.drop off.toNat).take (n - off).toNat)) := by
  simp [funcDef, Val.asByteList?_ofIntList _ hb, hc]
theorem funcDef_add (a b : Int) (h : minInt ≤ a + b ∧ a + b ≤ maxInt) :
    funcDef .add (.pair (.lit (.int a)) (.lit (.int b))) = some (.lit (.int (a + b))) := by
  simp [funcDef, checked, h]
theorem funcDef_min (a b : Int) :
    funcDef .min (.pair (.lit (.int a)) (.lit (.int b))) = some (.lit (.int (min a b))) := by
  simp [funcDef]
theorem funcDef_take (xs : List Int) (k : Int)
    (hb : xs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hk : 0 ≤ k ∧ k ≤ (xs.length : Int)) :
    funcDef .take (.pair (Val.ofIntList xs) (.lit (.int k))) =
      some (Val.ofIntList (xs.take k.toNat)) := by
  simp [funcDef, Val.asByteList?_ofIntList _ hb, hk]
theorem funcDef_append (xs ys : List Int)
    (hx : xs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hy : ys.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    funcDef .append (.pair (Val.ofIntList xs) (Val.ofIntList ys)) =
      some (Val.ofIntList (xs ++ ys)) := by
  simp [funcDef, Val.asByteList?_ofIntList _ hx, Val.asByteList?_ofIntList _ hy]

/-! ## The whole `write_block` body

Argument shape: `relay`'s call site is `(pair b (pair (range off) (range r)))`; since `b` is a
state reference and the inner pair is plain data, `evalExpr` yields
`rpair (sref pb) (v (pair off r))` — NOT the nested `rpair _ (rpair _ _)` that the -11 and -12
prefix theorems (`write_block_prefix_binds*`) assumed. Those remain true statements about the
shape they name but do not apply to `relay`'s actual call; the theorems below use the real
shape (`hι`), and `relay_inner_step` is the proof that it is the real one (it composes
through `relay`'s exported call site with no further assumption).

Hypotheses, by group: `hι`/`hσ` bind the callee environment; `hlen`..`hdvb` are the
well-formed block/root state (a block whose `len` is its byte count, byte-valued lists);
`h0`..`hwc1` are the in-range premises of the body's own `range:` assertions and checked add;
`hreq` names the requested slice; `h1`..`h3` name the three successive states the body
writes (they always exist: `setAttrAt_isSome_of_getAttrAt`). -/

theorem write_block_body_ret (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st st1 st2 st3 : St) (pb pσ : Path) (off n len cap wc : Int) (bs ws dv req : List Int)
    (hι : lookup env "ι" = some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int n))))))
    (hσ : lookup env "σ" = some (.sref pσ))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hbytes : getAttrAt pb st "bytes" = some (Val.ofIntList bs))
    (hbs : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hbslen : (bs.length : Int) = len)
    (hws : getAttrAt pσ st "writes" = some (Val.ofIntList ws))
    (hwc : getAttrAt pσ st "write_calls" = some (.lit (.int wc)))
    (hdv : getAttrAt pσ st "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (h0 : 0 ≤ off) (hon : off ≤ n) (hnl : n ≤ len) (hlc : len ≤ cap)
    (hnmax : n ≤ 4611686018427387903)
    (hwc1 : minInt ≤ wc + 1 ∧ wc + 1 ≤ maxInt)
    (hreq : req = (bs.drop off.toNat).take (n - off).toNat)
    (h1 : setAttrAt pσ st "writes" (Val.ofIntList ws.tail) = some st1)
    (h2 : setAttrAt pσ st1 "write_calls" (.lit (.int (wc + 1))) = some st2)
    (hq : 0 ≤ wbQ ws req)
    (h3 : setAttrAt pσ st2 "delivered"
      (Val.ofIntList (dv ++ req.take (min (wbQ ws req) (req.length : Int)).toNat)) = some st3) :
    ∃ env', interp actDef (fuel + 24) writeBlockBody env st =
      .ret (.lit (.int (min (wbQ ws req) (req.length : Int)))) env' st3 := by
  have hwc1' : getAttrAt pσ st1 "write_calls" = some (.lit (.int wc)) := by
    rw [setAttrAt_frame pσ st st1 "writes" _ h1 pσ "write_calls" (Or.inr (by decide))]; exact hwc
  have hdv2 : getAttrAt pσ st2 "delivered" = some (Val.ofIntList dv) := by
    rw [setAttrAt_frame pσ st1 st2 "write_calls" _ h2 pσ "delivered" (Or.inr (by decide)),
      setAttrAt_frame pσ st st1 "writes" _ h1 pσ "delivered" (Or.inr (by decide))]; exact hdv
  have hnb : n ≤ (bs.length : Int) := by omega
  have hreq' : List.take (n - off).toNat (List.drop off.toNat bs) = req := hreq.symm
  have hreqb : req.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := by
    rw [hreq]; exact all_take_of_all _ _ (all_drop_of_all _ _ hbs)
  have hreqlen : (req.length : Int) ≤ n - off := by
    rw [hreq]; simp only [List.length_take, List.length_drop]; omega
  have hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903 := ⟨h0, by omega⟩
  have hn0 : 0 ≤ n ∧ n ≤ 4611686018427387903 := ⟨by omega, hnmax⟩
  have hslice : 0 ≤ off ∧ off ≤ n ∧ n ≤ (bs.length : Int) := ⟨h0, hon, hnb⟩
  have hkb : (req.take (min (wbQ ws req) (req.length : Int)).toNat).all
      (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := all_take_of_all _ _ hreqb
  have hk01 : 0 ≤ min (wbQ ws req) (req.length : Int) ∧
      min (wbQ ws req) (req.length : Int) ≤ 4611686018427387903 := ⟨by omega, by omega⟩
  have hk02 : 0 ≤ min (wbQ ws req) (req.length : Int) ∧
      min (wbQ ws req) (req.length : Int) ≤ (req.length : Int) := ⟨by omega, by omega⟩
  have hqnn : ¬ (wbQ ws req < 0) := by omega
  refine ⟨?e, ?h⟩
  case h =>
  simp only [writeBlockBody, interp, evalExpr, lookup_assocSet_same, lookup_assocSet_other,
    hι, hσ, hlen, hcap, hbytes, hws, h1, h2, hwc1', hdv2,
    funcDef_fst, funcDef_snd,
    funcDef_range off 0 _ hoff0, funcDef_range n 0 _ hn0,
    funcDef_le, funcDef_lt, funcDef_slice bs off n hbs hslice, hreq',
    funcDef_rangeList 0 255 req hreqb, funcDef_length, funcDef_headOr_ofIntList,
    funcDef_tail_ofIntList, funcDef_add wc 1 hwc1, funcDef_min,
    hon, hnl, hlc, decide_true, decide_false, Option.map_some, ne_eq,
    not_false_eq_true, String.reduceEq, h3,
    funcDef_range (min (wbQ ws req) (req.length : Int)) 0 _ hk01,
    funcDef_take req _ hreqb hk02, funcDef_append dv _ hdvb hkb, hqnn]
  rfl

/-- The `q < 0` path (a negative scheduled write): the two bookkeeping updates happen, then
    `-1` is returned with `delivered` untouched. -/
theorem write_block_body_neg (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st st1 st2 : St) (pb pσ : Path) (off n len cap wc : Int) (bs ws req : List Int)
    (hι : lookup env "ι" = some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int n))))))
    (hσ : lookup env "σ" = some (.sref pσ))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hbytes : getAttrAt pb st "bytes" = some (Val.ofIntList bs))
    (hbs : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hbslen : (bs.length : Int) = len)
    (hws : getAttrAt pσ st "writes" = some (Val.ofIntList ws))
    (hwc : getAttrAt pσ st "write_calls" = some (.lit (.int wc)))
    (h0 : 0 ≤ off) (hon : off ≤ n) (hnl : n ≤ len) (hlc : len ≤ cap)
    (hnmax : n ≤ 4611686018427387903)
    (hwc1 : minInt ≤ wc + 1 ∧ wc + 1 ≤ maxInt)
    (hreq : req = (bs.drop off.toNat).take (n - off).toNat)
    (h1 : setAttrAt pσ st "writes" (Val.ofIntList ws.tail) = some st1)
    (h2 : setAttrAt pσ st1 "write_calls" (.lit (.int (wc + 1))) = some st2)
    (hq : wbQ ws req < 0) :
    ∃ env', interp actDef (fuel + 24) writeBlockBody env st = .ret (.lit (.int (-1))) env' st2 := by
  have hwc1' : getAttrAt pσ st1 "write_calls" = some (.lit (.int wc)) := by
    rw [setAttrAt_frame pσ st st1 "writes" _ h1 pσ "write_calls" (Or.inr (by decide))]; exact hwc
  have hnb : n ≤ (bs.length : Int) := by omega
  have hreq' : List.take (n - off).toNat (List.drop off.toNat bs) = req := hreq.symm
  have hreqb : req.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := by
    rw [hreq]; exact all_take_of_all _ _ (all_drop_of_all _ _ hbs)
  have hreqlen : (req.length : Int) ≤ n - off := by
    rw [hreq]; simp only [List.length_take, List.length_drop]; omega
  have hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903 := ⟨h0, by omega⟩
  have hn0 : 0 ≤ n ∧ n ≤ 4611686018427387903 := ⟨by omega, hnmax⟩
  have hslice : 0 ≤ off ∧ off ≤ n ∧ n ≤ (bs.length : Int) := ⟨h0, hon, hnb⟩
  refine ⟨?e, ?h⟩
  case h =>
  simp only [writeBlockBody, interp, evalExpr, lookup_assocSet_same, lookup_assocSet_other,
    hι, hσ, hlen, hcap, hbytes, hws, h1, h2, hwc1',
    funcDef_fst, funcDef_snd,
    funcDef_range off 0 _ hoff0, funcDef_range n 0 _ hn0,
    funcDef_le, funcDef_lt, funcDef_slice bs off n hbs hslice, hreq',
    funcDef_rangeList 0 255 req hreqb, funcDef_length, funcDef_headOr_ofIntList,
    funcDef_tail_ofIntList, funcDef_add wc 1 hwc1,
    hon, hnl, hlc, decide_true, Option.map_some, ne_eq,
    not_false_eq_true, String.reduceEq, hq]
  rfl

/-! ## Error characterization: the three `AssertionFailure` raises, in body order -/

theorem write_block_assert1_raises (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (pb : Path) (off n : Int)
    (hι : lookup env "ι" = some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int n))))))
    (h0 : 0 ≤ off) (hoffmax : off ≤ 4611686018427387903)
    (hn0 : 0 ≤ n) (hnmax : n ≤ 4611686018427387903)
    (hon : ¬ off ≤ n) :
    ∃ env', interp actDef (fuel + 24) writeBlockBody env st =
      .raise (.pair (.lit (.str "AssertionFailure")) (.lit .unit)) env' st := by
  have hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903 := ⟨h0, hoffmax⟩
  have hn0' : 0 ≤ n ∧ n ≤ 4611686018427387903 := ⟨hn0, hnmax⟩
  refine ⟨?e, ?h⟩
  case h =>
  simp only [writeBlockBody, interp, evalExpr, lookup_assocSet_same, lookup_assocSet_other, hι,
    funcDef_fst, funcDef_snd,
    funcDef_range off 0 _ hoff0, funcDef_range n 0 _ hn0', funcDef_le, hon, decide_false,
    Option.map_some, ne_eq, not_false_eq_true, String.reduceEq]
  rfl

theorem write_block_assert2_raises (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (pb : Path) (off n len : Int)
    (hι : lookup env "ι" = some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int n))))))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (h0 : 0 ≤ off) (hoffmax : off ≤ 4611686018427387903)
    (hn0 : 0 ≤ n) (hnmax : n ≤ 4611686018427387903)
    (hon : off ≤ n) (hnl : ¬ n ≤ len) :
    ∃ env', interp actDef (fuel + 24) writeBlockBody env st =
      .raise (.pair (.lit (.str "AssertionFailure")) (.lit .unit)) env' st := by
  have hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903 := ⟨h0, hoffmax⟩
  have hn0' : 0 ≤ n ∧ n ≤ 4611686018427387903 := ⟨hn0, hnmax⟩
  refine ⟨?e, ?h⟩
  case h =>
  simp only [writeBlockBody, interp, evalExpr, lookup_assocSet_same, lookup_assocSet_other, hι,
    hlen, funcDef_fst, funcDef_snd,
    funcDef_range off 0 _ hoff0, funcDef_range n 0 _ hn0', funcDef_le, hon, hnl, decide_true,
    decide_false, Option.map_some, ne_eq, not_false_eq_true, String.reduceEq]
  rfl

theorem write_block_assert3_raises (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (pb : Path) (off n len cap : Int)
    (hι : lookup env "ι" = some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int n))))))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (h0 : 0 ≤ off) (hoffmax : off ≤ 4611686018427387903)
    (hn0 : 0 ≤ n) (hnmax : n ≤ 4611686018427387903)
    (hon : off ≤ n) (hnl : n ≤ len) (hlc : ¬ len ≤ cap) :
    ∃ env', interp actDef (fuel + 24) writeBlockBody env st =
      .raise (.pair (.lit (.str "AssertionFailure")) (.lit .unit)) env' st := by
  have hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903 := ⟨h0, hoffmax⟩
  have hn0' : 0 ≤ n ∧ n ≤ 4611686018427387903 := ⟨hn0, hnmax⟩
  refine ⟨?e, ?h⟩
  case h =>
  simp only [writeBlockBody, interp, evalExpr, lookup_assocSet_same, lookup_assocSet_other, hι,
    hlen, hcap, funcDef_fst, funcDef_snd,
    funcDef_range off 0 _ hoff0, funcDef_range n 0 _ hn0', funcDef_le, hon, hnl, hlc,
    decide_true, decide_false, Option.map_some, ne_eq, not_false_eq_true, String.reduceEq]
  rfl

/-! ## `relay`'s inner loop: one positive-write iteration, through the real call site

`relay` binds `b := (elem σ block 0)` (so `pb = Path.nested "block" 0 .here`) and `σ` is the
root; the theorem is stated for any `pb` bound to `b`, with `σ` at the root as in every
`calleeEnv`. Fuel: the `.while` costs one level, its `.seq body (.while ..)` one more, the
body's own three nested `.seq`s and the `.action` four more — the callee therefore runs at
`fuel + 24`, exactly `write_block_body_ret`'s budget, and the loop continues at `fuel + 28`. -/
theorem relay_inner_step (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env)
    (st st1 st2 st3 : St) (pb : Path) (off r len cap wc : Int) (bs ws dv req : List Int)
    (hb : lookup env "b" = some (.sref pb))
    (hσ : lookup env "σ" = some (.sref .here))
    (hoff : lookup env "off" = some (.v (.lit (.int off))))
    (hr : lookup env "r" = some (.v (.lit (.int r))))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hbytes : getAttrAt pb st "bytes" = some (Val.ofIntList bs))
    (hbs : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hbslen : (bs.length : Int) = len)
    (hws : getAttrAt .here st "writes" = some (Val.ofIntList ws))
    (hwc : getAttrAt .here st "write_calls" = some (.lit (.int wc)))
    (hdv : getAttrAt .here st "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (h0 : 0 ≤ off) (hor : off < r) (hrl : r ≤ len) (hlc : len ≤ cap)
    (hrmax : r ≤ 4611686018427387903)
    (hwc1 : minInt ≤ wc + 1 ∧ wc + 1 ≤ maxInt)
    (hreq : req = (bs.drop off.toNat).take (r - off).toNat)
    (hq : 0 ≤ wbQ ws req)
    (hkpos : 0 < min (wbQ ws req) (req.length : Int))
    (h1 : setAttrAt .here st "writes" (Val.ofIntList ws.tail) = some st1)
    (h2 : setAttrAt .here st1 "write_calls" (.lit (.int (wc + 1))) = some st2)
    (h3 : setAttrAt .here st2 "delivered"
      (Val.ofIntList (dv ++ req.take (min (wbQ ws req) (req.length : Int)).toNat)) = some st3) :
    interp actDef (fuel + 30) relayInnerLoop env st =
      interp actDef (fuel + 28) relayInnerLoop
        (assocSet (assocSet (assocSet env "$t18" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "w" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "off" (.v (.lit (.int (off + min (wbQ ws req) (req.length : Int))))))
        st3 := by
  obtain ⟨e, he⟩ := write_block_body_ret actDef fuel
    (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))))
    st st1 st2 st3 pb .here off r len cap wc bs ws dv req
    (by simp [calleeEnv, lookup]) (by simp [calleeEnv, lookup])
    hlen hcap hbytes hbs hbslen hws hwc hdv hdvb h0 (by omega) hrl hlc hrmax hwc1 hreq h1 h2 hq h3
  have hreqlen : (req.length : Int) ≤ r - off := by
    rw [hreq]; simp only [List.length_take, List.length_drop]; omega
  have hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903 := ⟨h0, by omega⟩
  have hr0 : 0 ≤ r ∧ r ≤ 4611686018427387903 := ⟨by omega, hrmax⟩
  have hkle : ¬ (min (wbQ ws req) (req.length : Int) ≤ 0) := by omega
  have hadd : minInt ≤ off + min (wbQ ws req) (req.length : Int) ∧
      off + min (wbQ ws req) (req.length : Int) ≤ maxInt := by
    simp only [minInt, maxInt]; omega
  -- keep the callee body opaque so `simp` uses `he` instead of unfolding all of `write_block`
  generalize hW : writeBlockBody = W at he hwb
  -- the loop condition, then the body on its own (it contains no `.while`, so unfolding
  -- `interp` on it terminates), then ONE unfolding of the loop itself
  have hc : evalExpr env (.fn .lt (.pair (.var "off") (.var "r"))) = some (.v (.lit (.bool true))) := by
    simp only [evalExpr, hoff, hr, funcDef_lt, hor, decide_true, Option.map_some]
  have hbody : interp actDef (fuel + 28) relayInnerBody env st =
      .continue (assocSet (assocSet (assocSet env "$t18"
          (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "w" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "off" (.v (.lit (.int (off + min (wbQ ws req) (req.length : Int)))))) st3 := by
    have iseq : ∀ {n : Nat} {a b : Stmt String} {e : Env} {s : St},
        interp actDef (n + 1) (.seq a b) e s =
          match interp actDef n a e s with
          | .continue e s => interp actDef n b e s
          | r => r := fun {n a b e s} => rfl
    have iact : ∀ {n : Nat} {v a : String} {e : Expr} {env : Env} {st : St},
        interp actDef (n + 1) (.action v a e) env st =
          match evalExpr env e with
          | none => .failure
          | some arg =>
            match interp actDef n (actDef a) (calleeEnv arg) st with
            | .ret res _ st => .continue (assocSet env v (.v res)) st
            | .raise x _ st => .raise x env st
            | _ => .failure := fun {n v a e env st} => rfl
    have iasg : ∀ {n : Nat} {v : String} {e : Expr} {env : Env} {st : St},
        interp actDef (n + 1) (.assign v e) env st =
          match evalExpr env e with
          | some x => .continue (assocSet env v x) st
          | none => .failure := fun {n v e env st} => rfl
    have icnd : ∀ {n : Nat} {c : Expr} {t e : Stmt String} {env : Env} {st : St},
        interp actDef (n + 1) (.cond c t e) env st =
          match evalExpr env c with
          | some (.v (.lit (.bool true))) => interp actDef n t env st
          | some (.v (.lit (.bool false))) => interp actDef n e env st
          | _ => .failure := fun {n c t e env st} => rfl
    have ipass : ∀ {n : Nat} {env : Env} {st : St},
        interp actDef (n + 1) .pass env st = .continue env st := fun {n env st} => rfl
    have mcont : ∀ {e : Env} {s : St} {P : Env → St → Res},
        (match (Res.continue e s : Res) with
         | .continue e s => P e s
         | r => r) = P e s := fun {e s P} => rfl
    have harg :
        evalExpr env (.pair (.var "b")
          (.pair (.fn (.range 0 4611686018427387903) (.var "off"))
            (.fn (.range 0 4611686018427387903) (.var "r")))) =
          some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))) := by
      simp only [evalExpr, hb, hoff, hr, funcDef_range off 0 _ hoff0, funcDef_range r 0 _ hr0,
        Option.map_some]
    let _ := hσ
    unfold relayInnerBody
    rw [show fuel + 28 = (fuel + 27) + 1 from rfl, iseq]
    rw [show fuel + 27 = (fuel + 26) + 1 from rfl, iseq]
    rw [show fuel + 26 = (fuel + 25) + 1 from rfl, iseq]
    rw [show fuel + 25 = (fuel + 24) + 1 from rfl, iact, harg]
    simp only [hwb, he]
    rw [show fuel + 25 = (fuel + 24) + 1 from rfl, iasg]
    simp only [evalExpr, lookup_assocSet_same]
    rw [show fuel + 26 = (fuel + 25) + 1 from rfl, iseq]
    rw [show fuel + 25 = (fuel + 24) + 1 from rfl, icnd]
    simp only [evalExpr, lookup_assocSet_same, hkle, funcDef_le, decide_false, Option.map_some]
    rw [show fuel + 24 = (fuel + 23) + 1 from rfl, ipass]
    rw [mcont]
    rw [show fuel + 25 = (fuel + 24) + 1 from rfl, iasg]
    have hoff' :
        lookup (assocSet (assocSet env "$t18"
            (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
            "w" (.v (.lit (.int (min (wbQ ws req) (req.length : Int)))))) "off" =
          some (.v (.lit (.int off))) := by
      rw [lookup_assocSet_other (a := "w") (b := "off") (h := by decide)]
      rw [lookup_assocSet_other (a := "$t18") (b := "off") (h := by decide)]
      exact hoff
    simp only [evalExpr, lookup_assocSet_same, hoff', funcDef_add off _ hadd, Option.map_some]
    rw [show fuel + 24 + 1 + 1 + 1 = (fuel + 26) + 1 from rfl, ipass]
  show interp actDef (fuel + 29 + 1) relayInnerLoop env st = _
  rw [relayInnerLoop, interp_while_true actDef (fuel + 29) env st _ relayInnerBody hc]
  show (match interp actDef (fuel + 28) relayInnerBody env st with
    | .continue env st => interp actDef (fuel + 28) (.while (.fn .lt (.pair (.var "off") (.var "r"))) relayInnerBody) env st
    | r => r) = _
  rw [hbody]

end CalculusBody
