import CalculusNested

/-!
Hand transcription of three `fixtures/v2/nested_state.sc` functions from the exact
S-expressions the OCaml `cb_main lower` mode printed for them (see
`calculus-bytes/results/v2/nested_state__*.jsonl`, first "mode":"lower" record, `fns[].calculus`
field, matched by name). Not machine-generated: this is the "one concrete subchain" correspondence
check, not a general lowering-to-Lean pipeline. Compared structurally (not byte-for-byte, since
the OCaml driver's JSON always carries the byte-relay root attributes even when unused) by
`calculus-bytes/compare_lean_v2.py` against the pinned interpreter's actual output.
-/

open CalculusNested

inductive NestedAct where
  | missingParent
  | wrongOrderProbe
  | deepSet
  | catchScope
  | finallyRuns
  | uncaughtIsRaise
  | partialEffectsSurviveRaise
  | loopLet
  | deep3
  | deepClear
  | clearedThenRead

def E (base : Expr) (n : String) (i : Int) : Expr := .elem base n (.lit (.int i))
def add2 (a b : Expr) : Expr := .fn .add (.pair a b)
def mul2 (a b : Expr) : Expr := .fn .mul (.pair a b)
def σ : Expr := .var "σ"

/-- `(seq (set-attr (elem (elem σ a 1) b 2) v 1) (return 0))` -/
def missingParentBody : Stmt NestedAct :=
  .seq (.setAttr (E (E σ "a" 1) "b" 2) "v" (.lit (.int 1))) (.ret (.lit (.int 0)))

/-- `(seq (add-elem σ a 1) (seq (add-elem (elem σ a 1) b 2)
      (seq (add-elem (elem (elem σ a 1) b 2) a 3) (return 1))))` -/
def wrongOrderProbeBody : Stmt NestedAct :=
  .seq (.addElem σ "a" (.lit (.int 1))) $
  .seq (.addElem (E σ "a" 1) "b" (.lit (.int 2))) $
  .seq (.addElem (E (E σ "a" 1) "b" 2) "a" (.lit (.int 3)))
       (.ret (.lit (.int 1)))

/-- `deep_set`'s full body, transcribed statement-for-statement from the lowered S-expression
    (see the docstring above); the sum-of-products return expression is grouped differently than
    the OCaml left fold but denotes the same integer by associativity/commutativity of `+`. -/
def deepSetBody : Stmt NestedAct :=
  .seq (.addElem σ "a" (.lit (.int 1))) $
  .seq (.addElem σ "a" (.lit (.int 2))) $
  .seq (.assign "s" (E σ "a" 1)) $
  .seq (.addElem (.var "s") "b" (.lit (.int 2))) $
  .seq (.addElem (.var "s") "b" (.lit (.int 3))) $
  .seq (.setAttr σ "v" (.lit (.int 100))) $
  .seq (.setAttr (.var "s") "v" (.lit (.int 10))) $
  .seq (.setAttr (E (.var "s") "b" 2) "v" (.lit (.int 7))) $
  .seq (.setAttr (E (.var "s") "b" 3) "v" (.lit (.int 9))) $
  .seq (.setAttr (E σ "a" 2) "v" (.lit (.int 20))) $
  .seq (.assign "t" (E (.var "s") "b" 2)) $
  .seq (.setAttr (.var "t") "w" (.lit (.int 70))) $
  .seq (.get "t1" (E (E σ "a" 1) "b" 2) "v") $
  .seq (.get "t2" (E (E σ "a" 1) "b" 3) "v") $
  .seq (.get "t3" (.var "s") "v") $
  .seq (.get "t4" σ "v") $
  .seq (.get "t5" (E σ "a" 2) "v") $
  .seq (.get "t6" (.var "t") "w") $
  .ret (add2 (add2 (add2 (add2 (add2 (.var "t1") (mul2 (.var "t2") (.lit (.int 10))))
                                (mul2 (.var "t3") (.lit (.int 100))))
                          (mul2 (.var "t4") (.lit (.int 1000))))
                    (mul2 (.var "t5") (.lit (.int 100000))))
             (mul2 (.var "t6") (.lit (.int 10000000))))

/-- `fixtures/v2/scope_ok.sc`, `catch_scope`:
    `(seq (try (raise (pair "E" 4)) catch $t1 (if (exc-is:E $t1) (seq (assign c (snd $t1))
      (return c)) (raise $t1))) (return -1))` -/
def catchScopeBody : Stmt NestedAct :=
  .seq
    (.tryCatch (.raise (.pair (.lit (.str "E")) (.lit (.int 4))))
               "t1"
               (.cond (.fn (.excTag "E") (.var "t1"))
                      (.seq (.assign "c" (.fn .snd (.var "t1"))) (.ret (.var "c")))
                      (.raise (.var "t1"))))
    (.ret (.lit (.int (-1))))

/-- `finally_runs`: `(seq (set-attr σ count 0) (seq (try (seq (get $t2 σ count)
      (set-attr σ count (+ (pair $t2 1)))) finally (seq (get $t3 σ count)
      (set-attr σ count (+ (pair $t3 10))))) (seq (get $t4 σ count) (return $t4))))` -/
def finallyRunsBody : Stmt NestedAct :=
  .seq (.setAttr σ "count" (.lit (.int 0))) $
  .seq (.tryFinally
          (.seq (.get "t2" σ "count") (.setAttr σ "count" (add2 (.var "t2") (.lit (.int 1)))))
          (.seq (.get "t3" σ "count") (.setAttr σ "count" (add2 (.var "t3") (.lit (.int 10))))))
       (.seq (.get "t4" σ "count") (.ret (.var "t4")))

/-- `uncaught_is_raise`: `(raise (pair "E" 9))` -/
def uncaughtIsRaiseBody : Stmt NestedAct :=
  .raise (.pair (.lit (.str "E")) (.lit (.int 9)))

/-- `partial_effects_survive_raise`: `(seq (set-attr σ count 0) (seq (try (seq (set-attr σ count 5)
      (raise (pair "E" 1))) catch $t5 (if (exc-is:E $t5) (seq (assign c (snd $t5))
      (seq (get $t6 σ count) (return (+ (pair $t6 c))))) (raise $t5))) (return -1)))` -/
def partialEffectsBody : Stmt NestedAct :=
  .seq (.setAttr σ "count" (.lit (.int 0))) $
  .seq (.tryCatch
          (.seq (.setAttr σ "count" (.lit (.int 5)))
                (.raise (.pair (.lit (.str "E")) (.lit (.int 1)))))
          "t5"
          (.cond (.fn (.excTag "E") (.var "t5"))
                 (.seq (.assign "c" (.fn .snd (.var "t5")))
                       (.seq (.get "t6" σ "count") (.ret (add2 (.var "t6") (.var "c")))))
                 (.raise (.var "t5"))))
       (.ret (.lit (.int (-1))))

/-- `loop_let`: `(seq (assign i 0) (seq (assign acc 0) (seq (while (< (pair i 3))
      (seq (seq (assign d (* (pair i 2))) (seq (assign acc (+ (pair acc d)))
      (assign i (+ (pair i 1))))) pass)) (return acc))))` -/
def loopLetBody : Stmt NestedAct :=
  .seq (.assign "i" (.lit (.int 0))) $
  .seq (.assign "acc" (.lit (.int 0))) $
  .seq (.while (.fn .lt (.pair (.var "i") (.lit (.int 3))))
               (.seq (.seq (.assign "d" (mul2 (.var "i") (.lit (.int 2))))
                           (.seq (.assign "acc" (add2 (.var "acc") (.var "d")))
                                 (.assign "i" (add2 (.var "i") (.lit (.int 1))))))
                     .pass))
       (.ret (.var "acc"))

/-- `nested_state.sc`, `deep3`: three levels (`a(1).b(2).a(3)`), exercising `contains`/
    `hasElemAt` (via `exists`) alongside a `clear` + re-`touch` of the deepest element (whose
    attrs must come back EMPTY, not the `v=5,w=8` it held before the clear). Transcribed
    statement-for-statement from the lowered S-expression (see `results/v2/
    nested_state__deep3.jsonl`'s first "mode":"lower" record, `fns[].calculus` for "deep3"). -/
def deep3Body : Stmt NestedAct :=
  .seq (.addElem σ "a" (.lit (.int 1))) $
  .seq (.addElem (E σ "a" 1) "b" (.lit (.int 2))) $
  .seq (.addElem (E (E σ "a" 1) "b" 2) "a" (.lit (.int 3))) $
  .seq (.setAttr (E (E (E σ "a" 1) "b" 2) "a" 3) "v" (.lit (.int 5))) $
  .seq (.setAttr (E (E σ "a" 1) "b" 2) "v" (.lit (.int 6))) $
  .seq (.setAttr (E σ "a" 1) "v" (.lit (.int 4))) $
  .seq (.setAttr σ "v" (.lit (.int 3))) $
  .seq (.assign "s" (E (E σ "a" 1) "b" 2)) $
  .seq (.assign "u" (E (.var "s") "a" 3)) $
  .seq (.setAttr (.var "u") "w" (.lit (.int 8))) $
  .seq (.seq (.get "t20" (.var "u") "v")
             (.seq (.get "t21" (.var "u") "w")
                   (.assign "probe" (add2 (mul2 (.var "t20") (.lit (.int 10000)))
                                          (mul2 (.var "t21") (.lit (.int 100000))))))) $
  .seq (.removeElem (.var "s") "a" (.lit (.int 3))) $
  .seq (.seq (.contains (E (E σ "a" 1) "b" 2) "a" (.lit (.int 3))
                        (.assign "t22" (.lit (.bool true))) (.assign "t22" (.lit (.bool false))))
             (.cond (.var "t22") (.ret (.lit (.int (-1)))) .pass)) $
  .seq (.addElem (.var "s") "a" (.lit (.int 3))) $
  .seq (.seq (.contains (E (E σ "a" 1) "b" 2) "a" (.lit (.int 3))
                        (.assign "t23" (.lit (.bool true))) (.assign "t23" (.lit (.bool false))))
             (.cond (.var "t23")
                    (.seq (.get "t24" (E (E σ "a" 1) "b" 2) "v")
                          (.seq (.get "t25" (E σ "a" 1) "v")
                                (.seq (.get "t26" σ "v")
                                      (.ret (add2 (add2 (add2 (mul2 (.var "t24") (.lit (.int 10)))
                                                                (mul2 (.var "t25") (.lit (.int 100))))
                                                        (mul2 (.var "t26") (.lit (.int 1000))))
                                                  (.var "probe"))))))
                    .pass))
       (.ret (.lit (.int (-2))))

/-- `deep_clear`: calls `deep_set` via `Action` (the only case here that does), then removes
    `a(1).b(2)` and checks it (and only it) is gone via `contains`/`exists`.
    `(seq (seq (action $t7 deep_set ()) (assign r $t7)) (seq (remove-elem (elem σ a 1) b 2)
      (seq (seq (contains (elem σ a 1) b 2 (assign $t8 true) (assign $t8 false))
                (if $t8 (return -1) pass))
      (seq (seq (contains (elem σ a 1) b 3 (assign $t9 true) (assign $t9 false))
                (if (not $t9) (return -2) pass))
      (seq (seq (contains σ a 1 (assign $t10 true) (assign $t10 false))
                (if (not $t10) (return -3) pass))
      (seq (seq (contains σ a 2 (assign $t11 true) (assign $t11 false))
                (if (not $t11) (return -4) pass))
      (seq (get $t12 (elem (elem σ a 1) b 3) v) (seq (get $t13 (elem σ a 1) v)
      (seq (get $t14 σ v) (seq (get $t15 (elem σ a 2) v)
      (return (+ (pair (+ (pair (+ (pair $t12 (* (pair $t13 100)))) (* (pair $t14 1000))))
                 (* (pair $t15 100000))))))))))))))))` -/
def deepClearBody : Stmt NestedAct :=
  .seq (.seq (.action "t7" .deepSet (.lit .unit)) (.assign "r" (.var "t7"))) $
  .seq (.removeElem (E σ "a" 1) "b" (.lit (.int 2))) $
  .seq (.seq (.contains (E σ "a" 1) "b" (.lit (.int 2))
                        (.assign "t8" (.lit (.bool true))) (.assign "t8" (.lit (.bool false))))
             (.cond (.var "t8") (.ret (.lit (.int (-1)))) .pass)) $
  .seq (.seq (.contains (E σ "a" 1) "b" (.lit (.int 3))
                        (.assign "t9" (.lit (.bool true))) (.assign "t9" (.lit (.bool false))))
             (.cond (.fn .lnot (.var "t9")) (.ret (.lit (.int (-2)))) .pass)) $
  .seq (.seq (.contains σ "a" (.lit (.int 1))
                        (.assign "t10" (.lit (.bool true))) (.assign "t10" (.lit (.bool false))))
             (.cond (.fn .lnot (.var "t10")) (.ret (.lit (.int (-3)))) .pass)) $
  .seq (.seq (.contains σ "a" (.lit (.int 2))
                        (.assign "t11" (.lit (.bool true))) (.assign "t11" (.lit (.bool false))))
             (.cond (.fn .lnot (.var "t11")) (.ret (.lit (.int (-4)))) .pass)) $
  .seq (.get "t12" (E (E σ "a" 1) "b" 3) "v") $
  .seq (.get "t13" (E σ "a" 1) "v") $
  .seq (.get "t14" σ "v") $
  .seq (.get "t15" (E σ "a" 2) "v")
       (.ret (add2 (add2 (add2 (.var "t12") (mul2 (.var "t13") (.lit (.int 100))))
                          (mul2 (.var "t14") (.lit (.int 1000))))
                    (mul2 (.var "t15") (.lit (.int 100000)))))

/-- `cleared_then_read`: calls `deep_set`, removes `a(1).b(2)`, then reads its `v` — a `Get` on
    a path whose element no longer exists, which must fail (not silently produce a default).
    `(seq (seq (action $t27 deep_set ()) (assign r $t27)) (seq (remove-elem (elem σ a 1) b 2)
      (seq (get $t28 (elem (elem σ a 1) b 2) v) (return $t28))))` -/
def clearedThenReadBody : Stmt NestedAct :=
  .seq (.seq (.action "t27" .deepSet (.lit .unit)) (.assign "r" (.var "t27"))) $
  .seq (.removeElem (E σ "a" 1) "b" (.lit (.int 2))) $
  .seq (.get "t28" (E (E σ "a" 1) "b" 2) "v") (.ret (.var "t28"))

def nestedActDef : NestedAct → Stmt NestedAct
  | .missingParent => missingParentBody
  | .wrongOrderProbe => wrongOrderProbeBody
  | .deepSet => deepSetBody
  | .catchScope => catchScopeBody
  | .finallyRuns => finallyRunsBody
  | .uncaughtIsRaise => uncaughtIsRaiseBody
  | .partialEffectsSurviveRaise => partialEffectsBody
  | .loopLet => loopLetBody
  | .deep3 => deep3Body
  | .deepClear => deepClearBody
  | .clearedThenRead => clearedThenReadBody

def line (name : String) (act : NestedAct) : String :=
  "{\"lean_entry\": \"" ++ name ++ "\", " ++
    renderRes (runEntry nestedActDef 200 act St.empty) ++ "}"

def main : IO Unit := do
  IO.println (line "missing_parent" .missingParent)
  IO.println (line "wrong_order_probe" .wrongOrderProbe)
  IO.println (line "deep_set" .deepSet)
  IO.println (line "catch_scope" .catchScope)
  IO.println (line "finally_runs" .finallyRuns)
  IO.println (line "uncaught_is_raise" .uncaughtIsRaise)
  IO.println (line "partial_effects_survive_raise" .partialEffectsSurviveRaise)
  IO.println (line "loop_let" .loopLet)
  IO.println (line "deep3" .deep3)
  IO.println (line "deep_clear" .deepClear)
  IO.println (line "cleared_then_read" .clearedThenRead)
