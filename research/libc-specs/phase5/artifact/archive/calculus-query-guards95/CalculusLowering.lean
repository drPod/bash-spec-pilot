import CalculusRelayOuter
open CalculusNested CalculusBody CalculusRelayOuter

/-!
# CalculusLowering: a Lean model of the pinned frontend's bounded lowering
# (`calculus-bytes/adapter/lower.ml`, v2) and the checked spec-AST → calculus relation
# (calculus-correspondence-61, 2026-09-08 — DRAFT, written without a compiler turn)

`lower.ml` is the ONLY semantics the spec language has in this project (upstream has none, see
`calculus-bytes/MAPPING.md`). This module re-implements it in Lean, constructor by constructor,
INCLUDING its evaluation order for the temporary-name counter (`fresh`), so that the Lean
lowering of a spec-language program is the exact `Stmt String` the OCaml adapter prints:

* `LTy`/`STyp`: the adapter's types and the resolved subset of the parser's `Ast.Parsed.typ`;
  `resolve`, `coerce` (identical types pass; a narrower→wider integer range passes; otherwise
  a `range:`/`range-list:` assertion is inserted; literals out of range are rejected).
* `SExpr`/`SStmt`/`Decl`: the SUPPORTED fragment of `Ast.Parsed` (everything `lower.ml`
  rejects with `Unsupported` has no constructor here; the model is fail-closed: `none`).
* `lexpr`/`lstmt`/`lblock`/`lowerProgram`: `lower.ml`'s `lexpr`/`lstmt`/`lblock`/
  `lower_program`, fuel-indexed so the kernel can evaluate them (`decide`).
* `byteRelayExecSpec`: `fixtures/byte_relay_exec.sc`, encoded by hand from its text (the pinned
  parser has no AST export yet — `calculus-correspondence/spec_ast_export/` holds the OCaml
  printer to be built when the compiler turn is granted, so this encoding can be replaced by a
  machine-produced one).
* `lowering_checked`: `lowerProgram byteRelayExecSpec` yields EXACTLY the nine exported bodies
  (`readBlockBody`/`writeBlockBody`/`relayBody` from `CalculusBody`/`CalculusRelayOuter`,
  kernel-identified with the export in -13 and -14, plus the six others generated from the same
  TSV here). To be established by `decide +kernel` at compile time.

Trust boundary, stated exactly: this is a checked relation between (i) a Lean encoding of the
spec-language AST, (ii) a Lean re-implementation of the lowering, and (iii) the exported
calculus bodies. It is NOT a proof about `lower.ml`'s OCaml text; agreement of (ii) with (i)→
(iii) on this program is the evidence that the re-implementation is faithful on it, and every
rule of (ii) is a transcription of a named `lower.ml` clause. -/

namespace CalculusLowering

/-! ## Adapter types (`lower.ml` `ty`) -/

inductive LTy where
  | bool | unit
  | int (lo hi : Int)
  | list (t : LTy)
  | state
  deriving DecidableEq, Repr

def carrierLo : Int := minInt
def carrierHi : Int := maxInt

/-- `sub (lo, hi) (lo', hi')`: `[lo,hi] ⊆ [lo',hi']`. -/
def subR (lo hi lo' hi' : Int) : Bool := decide (lo' ≤ lo ∧ hi ≤ hi')

/-- `generalize`: the type an unannotated `let` gets (integer ranges widen to the carrier). -/
def generalize : LTy → LTy
  | .int _ _ => .int carrierLo carrierHi
  | .list t => .list (generalize t)
  | t => t

/-- The resolved subset of `Ast.Parsed.typ`. -/
inductive STyp where
  | bool | void
  | sint8 | uint8 | sint16 | uint16 | sint32 | uint32 | sint64 | uint64
  | stateRef
  | list (t : STyp)
  | named (n : String)
  deriving DecidableEq, Repr

def resolve (aliases : List (String × LTy)) : STyp → Option LTy
  | .bool => some .bool
  | .void => some .unit
  | .sint8 => some (.int (-128) 127)
  | .uint8 => some (.int 0 255)
  | .sint16 => some (.int (-32768) 32767)
  | .uint16 => some (.int 0 65535)
  | .sint32 => some (.int (-2147483648) 2147483647)
  | .uint32 => some (.int 0 4294967295)
  | .sint64 => some (.int carrierLo carrierHi)
  | .uint64 => some (.int 0 carrierHi)
  | .stateRef => some .state
  | .list t => (resolve aliases t).map .list
  | .named n => lookup aliases n

/-- `coerce`: see `lower.ml`. -/
def coerce (actual target : LTy) (e : Expr) : Option Expr :=
  match actual, target with
  | .int lo hi, .int lo' hi' =>
    if subR lo hi lo' hi' then some e
    else match e with
      | .lit (.int n) => if lo' ≤ n ∧ n ≤ hi' then some e else none
      | _ => some (.fn (.range lo' hi') e)
  | .list (.int lo hi), .list (.int lo' hi') =>
    if subR lo hi lo' hi' then some e else some (.fn (.rangeList lo' hi') e)
  | .list a, .list b => if a = b then some e else none
  | .bool, .bool => some e
  | .unit, .unit => some e
  | .state, .state => some e
  | _, _ => none

/-! ## Globals, environments, helpers -/

inductive Global where
  | attr (t : LTy)
  | elem (ts : List LTy)
  | uninterp (f : Func) (ts : List LTy) (ret : LTy)
  | fn (ts : List LTy) (ret : LTy)
  | exc (ts : List LTy)
  deriving Repr

structure LEnv where
  globals : List (String × Global)
  locals : List (String × LTy)
  ret : LTy

def sigmaE : Expr := .var "σ"

/-- `fresh ()`: the counter is incremented first, then printed (`$t1` is the first name). -/
def fresh (n : Nat) : String × Nat := (s!"$t{n + 1}", n + 1)

def seqL : List (Stmt String) → Stmt String
  | [] => .pass
  | [s] => s
  | s :: rest => .seq s (seqL rest)

def tuple : List Expr → Expr
  | [] => .lit .unit
  | [e] => e
  | e :: rest => .pair e (tuple rest)

/-- Projection `i` of `n` out of a right-nested tuple (structural on `n`). -/
def proj (i : Nat) : Nat → Expr → Expr
  | 0, e => e
  | 1, e => e
  | n + 2, e => if i = 0 then .fn .fst e else proj (i - 1) (n + 1) (.fn .snd e)

def isInt : LTy → Bool | .int _ _ => true | _ => false
def isIntList : LTy → Bool | .list (.int _ _) => true | _ => false

def shapeOk (f : Func) (args : List LTy) (ret : LTy) : Bool :=
  match f, args with
  | .length, [a] => isIntList a && isInt ret
  | .take, [a, n] | .drop, [a, n] => isIntList a && isInt n && isIntList ret
  | .slice, [a, o, n] => isIntList a && isInt o && isInt n && isIntList ret
  | .append, [a, b] => isIntList a && isIntList b && isIntList ret
  | .single, [b] => isInt b && isIntList ret
  | .empty, [] => isIntList ret
  | .headOr, [a, d] => isIntList a && isInt d && isInt ret
  | .tail, [a] => isIntList a && isIntList ret
  | .min, [a, b] | .max, [a, b] => isInt a && isInt b && isInt ret
  | _, _ => false

/-- `bytes_builtin.ml`'s `uninterp_table`: name, builtin, arity. -/
def uninterpTable : List (String × Func × Nat) :=
  [("length", .length, 1), ("take", .take, 2), ("drop", .drop, 2), ("slice", .slice, 3),
   ("append", .append, 2), ("single", .single, 1), ("empty", .empty, 0), ("head_or", .headOr, 2),
   ("tail", .tail, 1), ("min", .min, 2), ("max", .max, 2)]

/-! ## The supported fragment of `Ast.Parsed` -/

inductive BinOp where
  | add | sub | mul | div | mod | lt | le | gt | ge | eq | ne | land | lor
  deriving DecidableEq, Repr

def arith : BinOp → Option Func
  | .add => some .add | .sub => some .sub | .mul => some .mul | .div => some .div | .mod => some .mod
  | .lt => some .lt | .le => some .le | .gt => some .gt | .ge => some .ge
  | .eq => some .eq | .ne => some .ne
  | .land | .lor => none   -- short-circuit forms are lowered structurally, never as `Func`s

inductive SExpr where
  | var (v : String)
  | boolLit (b : Bool)
  | unitLit
  /-- every integer/char literal form, after the lexer's width decoding (`const n`) -/
  | intLit (n : Int)
  | neg (e : SExpr)
  | lnot (e : SExpr)
  | binop (op : BinOp) (l r : SExpr)
  | field (base : SExpr) (f : String)
  | call (f : String) (args : List SExpr)
  | fieldCall (base : SExpr) (name : String) (args : List SExpr)
  | existsE (e : SExpr)
  deriving Repr

inductive SStmt where
  | letS (v : String) (ty : Option STyp) (rhs : SExpr)
  | assign (lhs rhs : SExpr)
  | whileS (c : SExpr) (body : List SStmt)
  | ifS (c : SExpr) (thn els : List SStmt)
  | ret (e : SExpr)
  | raise (name : String) (args : List SExpr)
  | tryCatch (body : List SStmt) (catchC : Option (String × List String × List SStmt)) (fin : List SStmt)
  | touch (e : SExpr)
  | clear (e : SExpr)
  | assert (e : SExpr)
  deriving Repr

inductive Decl where
  | attribute (name : String) (ty : STyp)
  | element (name : String) (tys : List STyp)
  | exception (name : String) (tys : List STyp)
  | typeAlias (name : String) (def_ : STyp)
  | uninterp (name : String) (args : List STyp) (ret : STyp)
  | function (name : String) (args : List (String × STyp)) (ret : STyp) (body : List SStmt)
  deriving Repr

/-! ## Expressions (`lexpr`) — fuel-indexed transcription -/

/-- `lower_args`: each argument lowered then coerced to the declared parameter type. -/
def lowerArgs (lexpr : LEnv → SExpr → Nat → Option (List (Stmt String) × Expr × LTy × Nat))
    (env : LEnv) : List SExpr → List LTy → Nat → Option (List (Stmt String) × List Expr × Nat)
  | [], [], n => some ([], [], n)
  | a :: args, t :: tys, n => do
    let (p, a', ta, n1) ← lexpr env a n
    let a'' ← coerce ta t a'
    let (ps, es, n2) ← lowerArgs lexpr env args tys n1
    pure (p ++ ps, a'' :: es, n2)
  | _, _, _ => none

def lexpr : Nat → LEnv → SExpr → Nat → Option (List (Stmt String) × Expr × LTy × Nat)
  | 0, _, _, _ => none
  | fuel + 1, env, e, n =>
    match e with
    | .var v =>
      match lookup env.locals v with
      | some t => some ([], .var v, t, n)
      | none =>
        match lookup env.globals v with
        | some (.attr t) =>
          let (x, n1) := fresh n
          some ([.get x sigmaE v], .var x, t, n1)
        | _ => none
    | .boolLit b => some ([], .lit (.bool b), .bool, n)
    | .unitLit => some ([], .lit .unit, .unit, n)
    | .intLit i => some ([], .lit (.int i), .int i i, n)
    | .neg x =>
      match lexpr fuel env x n with
      | some ([], .lit (.int i), .int _ _, n1) =>
        if i ≠ carrierLo then some ([], .lit (.int (-i)), .int (-i) (-i), n1)
        else some ([], .fn .neg (.lit (.int i)), .int carrierLo carrierHi, n1)
      | some (p, x', .int _ _, n1) => some (p, .fn .neg x', .int carrierLo carrierHi, n1)
      | _ => none
    | .lnot x =>
      match lexpr fuel env x n with
      | some (p, x', .bool, n1) => some (p, .fn .lnot x', .bool, n1)
      | _ => none
    | .binop .land l r =>
      match lexpr fuel env l n with
      | some (pl, l', .bool, n1) =>
        match lexpr fuel env r n1 with
        | some (pr, r', .bool, n2) =>
          let (t, n3) := fresh n2
          let rhs := seqL (pr ++ [.assign t r'])
          some (pl ++ [.assign t l', .cond (.var t) rhs .pass], .var t, .bool, n3)
        | _ => none
      | _ => none
    | .binop .lor l r =>
      match lexpr fuel env l n with
      | some (pl, l', .bool, n1) =>
        match lexpr fuel env r n1 with
        | some (pr, r', .bool, n2) =>
          let (t, n3) := fresh n2
          let rhs := seqL (pr ++ [.assign t r'])
          some (pl ++ [.assign t l', .cond (.var t) .pass rhs], .var t, .bool, n3)
        | _ => none
      | _ => none
    | .binop op l r =>
      match arith op with
      | none => none
      | some f =>
        match lexpr fuel env l n with
        | none => none
        | some (pl, l', tl, n1) =>
          match lexpr fuel env r n1 with
          | none => none
          | some (pr, r', tr, n2) =>
            let result : Option LTy :=
              match op, tl, tr with
              | .add, .int _ _, .int _ _ | .sub, .int _ _, .int _ _ | .mul, .int _ _, .int _ _
              | .div, .int _ _, .int _ _ | .mod, .int _ _, .int _ _ => some (.int carrierLo carrierHi)
              | .lt, .int _ _, .int _ _ | .le, .int _ _, .int _ _
              | .gt, .int _ _, .int _ _ | .ge, .int _ _, .int _ _ => some .bool
              | .eq, .int _ _, .int _ _ | .ne, .int _ _, .int _ _
              | .eq, .bool, .bool | .ne, .bool, .bool
              | .eq, .unit, .unit | .ne, .unit, .unit => some .bool
              | _, _, _ => none
            match result with
            | none => none
            | some rt => some (pl ++ pr, .fn f (.pair l' r'), rt, n2)
    | .field base f =>
      match lexpr fuel env base n with
      | some (pb, b', .state, n1) =>
        match lookup env.globals f with
        | some (.attr t) =>
          let (x, n2) := fresh n1
          some (pb ++ [.get x b' f], .var x, t, n2)
        | _ => none
      | _ => none
    | .call name args =>
      match lookup env.locals name with
      | some _ => none
      | none =>
        match lookup env.globals name with
        | some (.uninterp fn tys ret) =>
          match lowerArgs (lexpr fuel) env args tys n with
          | some (p, es, n1) => some (p, .fn fn (tuple es), ret, n1)
          | none => none
        | some (.elem tys) =>
          match lowerArgs (lexpr fuel) env args tys n with
          | some (p, es, n1) => some (p, .elem sigmaE name (tuple es), .state, n1)
          | none => none
        | some (.fn tys ret) =>
          match lowerArgs (lexpr fuel) env args tys n with
          | some (p, es, n1) =>
            let (t, n2) := fresh n1
            some (p ++ [.action t name (tuple es)], .var t, ret, n2)
          | none => none
        | _ => none
    | .fieldCall base name args =>
      match lexpr fuel env base n with
      | some (pb, b', .state, n1) =>
        match lookup env.globals name with
        | some (.elem tys) =>
          match lowerArgs (lexpr fuel) env args tys n1 with
          | some (p, es, n2) => some (pb ++ p, .elem b' name (tuple es), .state, n2)
          | none => none
        | _ => none
      | _ => none
    | .existsE x =>
      match lexpr fuel env x n with
      | some (p, .elem base elm arg, _, n1) =>
        let (t, n2) := fresh n1
        some (p ++ [.contains base elm arg (.assign t (.lit (.bool true)))
                      (.assign t (.lit (.bool false)))], .var t, .bool, n2)
      | _ => none

def lcond (fuel : Nat) (env : LEnv) (c : SExpr) (n : Nat) : Option (List (Stmt String) × Expr × Nat) :=
  match lexpr fuel env c n with
  | some (p, c', .bool, n1) => some (p, c', n1)
  | _ => none

def lelem (fuel : Nat) (env : LEnv) (e : SExpr) (n : Nat) :
    Option (List (Stmt String) × (Expr × String × Expr) × Nat) :=
  match lexpr fuel env e n with
  | some (p, .elem base elm arg, _, n1) => some (p, (base, elm, arg), n1)
  | _ => none

def bindLocal (env : LEnv) (v : String) (t : LTy) : Option LEnv :=
  if (lookup env.locals v).isSome then none
  else if (lookup env.globals v).isSome then none
  else some { env with locals := (v, t) :: env.locals }

/-! ## Statements (`lstmt`/`lblock`) -/

mutual
def lstmt (aliases : List (String × LTy)) : Nat → LEnv → SStmt → Nat → Option (LEnv × Stmt String × Nat)
  | 0, _, _, _ => none
  | fuel + 1, env, s, n =>
    match s with
    | .letS v ty rhs =>
      match lexpr fuel env rhs n with
      | none => none
      | some (p, rhs', tr, n1) =>
        let tr' : Option (LTy × Expr) :=
          match ty with
          | none => some (generalize tr, rhs')
          | some ty => match resolve aliases ty with
            | none => none
            | some t => (coerce tr t rhs').map (fun e => (t, e))
        match tr' with
        | none => none
        | some (t, rhs'') =>
          match bindLocal env v t with
          | none => none
          | some env' => some (env', seqL (p ++ [.assign v rhs'']), n1)
    | .assign lhs rhs =>
      match lhs with
      | .var v =>
        match lookup env.locals v with
        | some t =>
          match lexpr fuel env rhs n with
          | some (p, rhs', tr, n1) =>
            (coerce tr t rhs').map (fun e => (env, seqL (p ++ [.assign v e]), n1))
          | none => none
        | none =>
          match lookup env.globals v with
          | some (.attr t) =>
            match lexpr fuel env rhs n with
            | some (p, rhs', tr, n1) =>
              (coerce tr t rhs').map (fun e => (env, seqL (p ++ [.setAttr sigmaE v e]), n1))
            | none => none
          | _ => none
      | .field base f =>
        match lexpr fuel env base n with
        | some (pb, b', .state, n1) =>
          match lookup env.globals f with
          | some (.attr t) =>
            match lexpr fuel env rhs n1 with
            | some (p, rhs', tr, n2) =>
              (coerce tr t rhs').map (fun e => (env, seqL (pb ++ p ++ [.setAttr b' f e]), n2))
            | none => none
          | _ => none
        | _ => none
      | _ => none
    | .whileS c body =>
      match lcond fuel env c n with
      | none => none
      | some (p, c', n1) =>
        match lblock aliases fuel env body n1 with
        | none => none
        | some (body', n2) => some (env, seqL (p ++ [.while c' (seqL [body', seqL p])]), n2)
    | .ifS c thn els =>
      match lcond fuel env c n with
      | none => none
      | some (p, c', n1) =>
        match lblock aliases fuel env thn n1 with
        | none => none
        | some (thn', n2) =>
          match lblock aliases fuel env els n2 with
          | none => none
          | some (els', n3) => some (env, seqL (p ++ [.cond c' thn' els']), n3)
    | .ret e =>
      match lexpr fuel env e n with
      | some (p, e', t, n1) => (coerce t env.ret e').map (fun e'' => (env, seqL (p ++ [.ret e'']), n1))
      | none => none
    | .raise name args =>
      match lookup env.globals name with
      | some (.exc tys) =>
        match lowerArgs (lexpr fuel) env args tys n with
        | some (p, es, n1) =>
          some (env, seqL (p ++ [.raise (.pair (.lit (.str name)) (tuple es))]), n1)
        | none => none
      | _ => none
    | .tryCatch body catchC fin =>
      match lblock aliases fuel env body n with
      | none => none
      | some (body', n1) =>
        let withCatch : Option (Stmt String × Nat) :=
          match catchC with
          | none => some (body', n1)
          | some (exc, vars, cbody) =>
            match lookup env.globals exc with
            | some (.exc tys) =>
              if vars.length ≠ tys.length then none
              else
                let (ex, n2) := fresh n1
                let arity := tys.length
                let bound : Option (LEnv × List (Stmt String)) :=
                  (List.range arity).foldl (fun acc i =>
                    match acc with
                    | none => none
                    | some (env, binds) =>
                      match vars[i]?, tys[i]? with
                      | some v, some t =>
                        (bindLocal env v t).map (fun env' =>
                          (env', binds ++ [.assign v (proj i arity (.fn .snd (.var ex)))]))
                      | _, _ => none) (some (env, []))
                match bound with
                | none => none
                | some (cenv, binds) =>
                  match lblock aliases fuel cenv cbody n2 with
                  | none => none
                  | some (cbody', n3) =>
                    some (.tryCatch body' ex
                      (.cond (.fn (.excTag exc) (.var ex)) (seqL (binds ++ [cbody'])) (.raise (.var ex))), n3)
            | _ => none
        match withCatch with
        | none => none
        | some (wc, n4) =>
          match fin with
          | [] => some (env, wc, n4)
          | _ =>
            match lblock aliases fuel env fin n4 with
            | none => none
            | some (fin', n5) => some (env, .tryFinally wc fin', n5)
    | .touch e =>
      match lelem fuel env e n with
      | some (p, (b, el, a), n1) => some (env, seqL (p ++ [.addElem b el a]), n1)
      | none => none
    | .clear e =>
      match lelem fuel env e n with
      | some (p, (b, el, a), n1) => some (env, seqL (p ++ [.removeElem b el a]), n1)
      | none => none
    | .assert e =>
      match lcond fuel env e n with
      | some (p, e', n1) =>
        some (env, seqL (p ++ [.cond e' .pass (.raise (.pair (.lit (.str "AssertionFailure")) (.lit .unit)))]), n1)
      | none => none

/-- `lblock`: statements see earlier bindings of the same block; lets do not escape. -/
def lblock (aliases : List (String × LTy)) : Nat → LEnv → List SStmt → Nat → Option (Stmt String × Nat)
  | 0, _, _, _ => none
  | fuel + 1, env, stmts, n =>
    match lblockAcc aliases fuel env stmts n with
    | some (acc, n1) => some (seqL acc, n1)
    | none => none

def lblockAcc (aliases : List (String × LTy)) : Nat → LEnv → List SStmt → Nat → Option (List (Stmt String) × Nat)
  | _, _, [], n => some ([], n)
  | 0, _, _ :: _, _ => none
  | fuel + 1, env, s :: rest, n =>
    match lstmt aliases fuel env s n with
    | none => none
    | some (env', s', n1) =>
      match lblockAcc aliases fuel env' rest n1 with
      | none => none
      | some (acc, n2) => some (s' :: acc, n2)
end

/-! ## Programs (`lower_program`) -/

structure Globals where
  aliases : List (String × LTy)
  globals : List (String × Global)

def addGlobal (gs : List (String × Global)) (name : String) (g : Global) : Option (List (String × Global)) :=
  if (lookup gs name).isSome then none else some ((name, g) :: gs)

def resolveAll (aliases : List (String × LTy)) : List STyp → Option (List LTy)
  | [] => some []
  | t :: ts => do let t' ← resolve aliases t; let ts' ← resolveAll aliases ts; pure (t' :: ts')

def buildGlobals : List Decl → Globals → Option Globals
  | [], g => some g
  | d :: ds, g =>
    match d with
    | .attribute name ty => do
      let t ← resolve g.aliases ty
      let gs ← addGlobal g.globals name (.attr t)
      buildGlobals ds { g with globals := gs }
    | .element name tys => do
      let ts ← resolveAll g.aliases tys
      let gs ← addGlobal g.globals name (.elem ts)
      buildGlobals ds { g with globals := gs }
    | .exception name tys => do
      let ts ← resolveAll g.aliases tys
      let gs ← addGlobal g.globals name (.exc ts)
      buildGlobals ds { g with globals := gs }
    | .typeAlias name def_ =>
      if (lookup g.aliases name).isSome then none
      else do
        let t ← resolve g.aliases def_
        buildGlobals ds { g with aliases := (name, t) :: g.aliases }
    | .uninterp name args ret =>
      match uninterpTable.find? (fun e => e.1 = name) with
      | none => none
      | some (_, f, arity) => do
        if args.length ≠ arity then none
        else
          let tys ← resolveAll g.aliases args
          let r ← resolve g.aliases ret
          if shapeOk f tys r then do
            let gs ← addGlobal g.globals name (.uninterp f tys r)
            buildGlobals ds { g with globals := gs }
          else none
    | .function name args ret _ => do
      let tys ← resolveAll g.aliases (args.map (·.2))
      let r ← resolve g.aliases ret
      let gs ← addGlobal g.globals name (.fn tys r)
      buildGlobals ds { g with globals := gs }

/-- Parameter binding on entry: `ι`'s projections, range-asserted unless the declared type is
    the carrier (or a non-integer). -/
def bindParams (env : LEnv) (args : List (String × STyp)) (tys : List LTy) :
    Option (LEnv × List (Stmt String)) :=
  let arity := args.length
  (List.range arity).foldl (fun acc i =>
    match acc with
    | none => none
    | some (env, binds) =>
      match args[i]?, tys[i]? with
      | some (v, _), some t =>
        (bindLocal env v t).map (fun env' =>
          let arg := proj i arity (.var "ι")
          let arg := match t with
            | .int lo hi => if (lo, hi) ≠ (carrierLo, carrierHi) then Expr.fn (.range lo hi) arg else arg
            | .list (.int lo hi) => if (lo, hi) ≠ (carrierLo, carrierHi) then Expr.fn (.rangeList lo hi) arg else arg
            | _ => arg
          (env', binds ++ [.assign v arg]))
      | _, _ => none) (some (env, []))

def lowerFns (fuel : Nat) (g : Globals) : List Decl → Nat → Option (List (String × Stmt String))
  | [], _ => some []
  | .function name args _ body :: ds, n =>
    match lookup g.globals name with
    | some (.fn tys ret) =>
      let env : LEnv := { globals := g.globals, locals := [], ret := ret }
      match bindParams env args tys with
      | none => none
      | some (env', binds) =>
        match lblock g.aliases fuel env' body n with
        | none => none
        | some (body', n1) =>
          match lowerFns fuel g ds n1 with
          | none => none
          | some rest => some ((name, seqL (binds ++ [body'])) :: rest)
    | _ => none
  | _ :: ds, n => lowerFns fuel g ds n

/-- `lower_program`: counter reset to 0, globals in declaration order, functions in declaration
    order with the counter running across them. -/
def lowerProgram (decls : List Decl) : Option (List (String × Stmt String)) :=
  match buildGlobals decls { aliases := [], globals := [] } with
  | none => none
  | some g => lowerFns 1000 g decls 0

/-! ## `fixtures/byte_relay_exec.sc`, encoded from its text -/

def lu8 : STyp := .list .uint8
def li64 : STyp := .list .sint64

section SpecProgram
open SExpr SStmt

/-- The shared body of `relay`/`relay_raising`; only the read-error statement differs. -/
def relayBodySpec (onReadError : SStmt) : List SStmt :=
  [ clear (call "block" [intLit 0]),
    touch (call "block" [intLit 0]),
    letS "b" none (call "block" [intLit 0]),
    assign (field (var "b") "cap") (intLit 32),
    assign (field (var "b") "len") (intLit 0),
    assign (field (var "b") "bytes") (call "empty" []),
    whileS (boolLit true)
      [ letS "r" none (call "read_block" [var "b"]),
        onReadError,
        ifS (binop .eq (var "r") (intLit 0)) [ret (intLit 0)] [],
        letS "off" none (intLit 0),
        whileS (binop .lt (var "off") (var "r"))
          [ letS "w" none (call "write_block" [var "b", var "off", var "r"]),
            ifS (binop .le (var "w") (intLit 0))
              [ assign (var "lost") (call "append" [var "lost",
                  call "slice" [field (var "b") "bytes", var "off", var "r"]]),
                ret (intLit 2) ] [],
            assign (var "off") (binop .add (var "off") (var "w")) ] ] ]

/-- `fixtures/byte_relay_exec.sc` (declarations in file order; `int` is the parser's `i64`,
    `state` its `StateRef`). -/
def byteRelayExecSpec : List Decl :=
  [ .typeAlias "byte" .uint8,
    .attribute "input" lu8, .attribute "delivered" lu8, .attribute "lost" lu8,
    .attribute "reads" li64, .attribute "writes" li64,
    .attribute "read_calls" .sint64, .attribute "write_calls" .sint64,
    .element "block" [.sint64],
    .attribute "cap" .uint64, .attribute "len" .uint64, .attribute "bytes" lu8,
    .uninterp "length" [lu8] .uint64,
    .uninterp "take" [lu8, .uint64] lu8,
    .uninterp "drop" [lu8, .uint64] lu8,
    .uninterp "slice" [lu8, .uint64, .uint64] lu8,
    .uninterp "append" [lu8, lu8] lu8,
    .uninterp "empty" [] lu8,
    .uninterp "single" [.uint8] lu8,
    .uninterp "head_or" [li64, .sint64] .sint64,
    .uninterp "tail" [li64] li64,
    .uninterp "min" [.sint64, .sint64] .sint64,
    .uninterp "max" [.sint64, .sint64] .sint64,
    .exception "ReadError" [.sint64],
    .function "read_block" [("b", .stateRef)] .sint64
      [ letS "q" none (call "head_or" [var "reads", field (var "b") "cap"]),
        assign (var "reads") (call "tail" [var "reads"]),
        assign (var "read_calls") (binop .add (var "read_calls") (intLit 1)),
        ifS (binop .lt (var "q") (intLit 0)) [ret (neg (intLit 1))] [],
        letS "k" none (call "min" [call "max" [intLit 1, var "q"],
                                   call "min" [field (var "b") "cap", call "length" [var "input"]]]),
        assign (field (var "b") "bytes") (call "take" [var "input", var "k"]),
        assign (field (var "b") "len") (var "k"),
        assign (var "input") (call "drop" [var "input", var "k"]),
        ret (var "k") ],
    .function "write_block" [("b", .stateRef), ("off", .uint64), ("n", .uint64)] .sint64
      [ assert (binop .le (var "off") (var "n")),
        assert (binop .le (var "n") (field (var "b") "len")),
        letS "l" none (field (var "b") "len"),
        assert (binop .le (var "l") (field (var "b") "cap")),
        letS "req" none (call "slice" [field (var "b") "bytes", var "off", var "n"]),
        letS "q" none (call "head_or" [var "writes", call "length" [var "req"]]),
        assign (var "writes") (call "tail" [var "writes"]),
        assign (var "write_calls") (binop .add (var "write_calls") (intLit 1)),
        ifS (binop .lt (var "q") (intLit 0)) [ret (neg (intLit 1))] [],
        letS "k" none (call "min" [var "q", call "length" [var "req"]]),
        assign (var "delivered") (call "append" [var "delivered", call "take" [var "req", var "k"]]),
        ret (var "k") ],
    .function "relay" [] .sint64
      (relayBodySpec (ifS (binop .lt (var "r") (intLit 0)) [ret (intLit 1)] [])),
    .function "relay_raising" [] .sint64
      (relayBodySpec (ifS (binop .lt (var "r") (intLit 0)) [raise "ReadError" [var "r"]] [])),
    .function "relay_caught" [] .sint64
      [ tryCatch [ letS "s" none (call "relay_raising" []), ret (var "s") ]
          (some ("ReadError", ["code"], [ret (intLit 1)])) [] ],
    .function "mark" [] .sint64
      [ assign (var "delivered") (call "append" [var "delivered", call "single" [intLit 33]]),
        ret (intLit 0) ],
    .function "relay_seq_relay" [] .sint64
      [ letS "a" none (call "relay" []), letS "c" none (call "relay" []), ret (var "c") ],
    .function "relay_and_mark" [] .sint64
      [ letS "rc" none (call "relay" []),
        ifS (binop .eq (var "rc") (intLit 0)) [ letS "m" none (call "mark" []), ret (var "m") ] [],
        ret (var "rc") ],
    .function "relay_or_mark" [] .sint64
      [ letS "rc" none (call "relay" []),
        ifS (binop .eq (var "rc") (intLit 0)) [ret (var "rc")] [],
        letS "m" none (call "mark" []), ret (var "m") ] ]

end SpecProgram

/-! ## The six exported bodies not yet in Lean (generated from the TSV by script) -/

/-- exported `relay_raising` (265 tokens), generated from the TSV by script -/
def relayRaisingBody : Stmt String :=
  (.seq (.removeElem (.var "σ") "block" (.lit (.int 0))) (.seq (.addElem (.var "σ") "block" (.lit (.int 0))) (.seq (.assign "b" (.elem (.var "σ") "block" (.lit (.int 0)))) (.seq (.setAttr (.var "b") "cap" (.lit (.int 32))) (.seq (.setAttr (.var "b") "len" (.lit (.int 0))) (.seq (.setAttr (.var "b") "bytes" (.fn .empty (.lit .unit))) (.while (.lit (.bool true)) (.seq (.seq (.seq (.action "$t21" "read_block" (.var "b")) (.assign "r" (.var "$t21"))) (.seq (.cond (.fn .lt (.pair (.var "r") (.lit (.int 0)))) (.raise (.pair (.lit (.str "ReadError")) (.var "r"))) .pass) (.seq (.cond (.fn .eq (.pair (.var "r") (.lit (.int 0)))) (.ret (.lit (.int 0))) .pass) (.seq (.assign "off" (.lit (.int 0))) (.while (.fn .lt (.pair (.var "off") (.var "r"))) (.seq (.seq (.seq (.action "$t22" "write_block" (.pair (.var "b") (.pair (.fn (.range 0 4611686018427387903) (.var "off")) (.fn (.range 0 4611686018427387903) (.var "r"))))) (.assign "w" (.var "$t22"))) (.seq (.cond (.fn .le (.pair (.var "w") (.lit (.int 0)))) (.seq (.seq (.get "$t23" (.var "σ") "lost") (.seq (.get "$t24" (.var "b") "bytes") (.setAttr (.var "σ") "lost" (.fn .append (.pair (.var "$t23") (.fn .slice (.pair (.var "$t24") (.pair (.fn (.range 0 4611686018427387903) (.var "off")) (.fn (.range 0 4611686018427387903) (.var "r")))))))))) (.ret (.lit (.int 2)))) .pass) (.assign "off" (.fn .add (.pair (.var "off") (.var "w")))))) .pass)))))) .pass))))))))

/-- exported `relay_caught` (53 tokens), generated from the TSV by script -/
def relayCaughtBody : Stmt String :=
  (.tryCatch (.seq (.seq (.action "$t25" "relay_raising" (.lit .unit)) (.assign "s" (.var "$t25"))) (.ret (.var "s"))) "$t26" (.cond (.fn (.excTag "ReadError") (.var "$t26")) (.seq (.assign "code" (.fn .snd (.var "$t26"))) (.ret (.lit (.int 1)))) (.raise (.var "$t26"))))

/-- exported `mark` (32 tokens), generated from the TSV by script -/
def markBody : Stmt String :=
  (.seq (.seq (.get "$t27" (.var "σ") "delivered") (.setAttr (.var "σ") "delivered" (.fn .append (.pair (.var "$t27") (.fn .single (.lit (.int 33))))))) (.ret (.lit (.int 0))))

/-- exported `relay_seq_relay` (40 tokens), generated from the TSV by script -/
def relaySeqRelayBody : Stmt String :=
  (.seq (.seq (.action "$t28" "relay" (.lit .unit)) (.assign "a" (.var "$t28"))) (.seq (.seq (.action "$t29" "relay" (.lit .unit)) (.assign "c" (.var "$t29"))) (.ret (.var "c"))))

/-- exported `relay_and_mark` (59 tokens), generated from the TSV by script -/
def relayAndMarkBody : Stmt String :=
  (.seq (.seq (.action "$t30" "relay" (.lit .unit)) (.assign "rc" (.var "$t30"))) (.seq (.cond (.fn .eq (.pair (.var "rc") (.lit (.int 0)))) (.seq (.seq (.action "$t31" "mark" (.lit .unit)) (.assign "m" (.var "$t31"))) (.ret (.var "m"))) .pass) (.ret (.var "rc"))))

/-- exported `relay_or_mark` (59 tokens), generated from the TSV by script -/
def relayOrMarkBody : Stmt String :=
  (.seq (.seq (.action "$t32" "relay" (.lit .unit)) (.assign "rc" (.var "$t32"))) (.seq (.cond (.fn .eq (.pair (.var "rc") (.lit (.int 0)))) (.ret (.var "rc")) .pass) (.seq (.seq (.action "$t33" "mark" (.lit .unit)) (.assign "m" (.var "$t33"))) (.ret (.var "m")))))


/-! ## The checked relation (to be established by `decide +kernel` at compile time) -/

/-- The Lean lowering of the encoded spec program is exactly the nine exported bodies, in
    declaration order, with the temporary names numbered as the OCaml adapter numbered them. -/
theorem lowering_checked :
    lowerProgram byteRelayExecSpec = some
      [("read_block", readBlockBody), ("write_block", writeBlockBody), ("relay", relayBody),
       ("relay_raising", relayRaisingBody), ("relay_caught", relayCaughtBody), ("mark", markBody),
       ("relay_seq_relay", relaySeqRelayBody), ("relay_and_mark", relayAndMarkBody),
       ("relay_or_mark", relayOrMarkBody)] := by
  decide +kernel

end CalculusLowering
