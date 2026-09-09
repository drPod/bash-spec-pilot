import BufferRelay
import CalculusNested

/-!
# ClightSubset: the fragment of CompCert Clight used by the relay, with its semantics

A Lean transcription of the Clight constructs that occur in `relay.v` (CompCert 3.15
`clightgen -normalize` output for `phase2/relay.c`), together with a fuel-indexed big-step
semantics that follows CompCert's `Clight.v` / `Cop.v` rules for exactly the type combinations
that occur. External calls `read`/`write` are given by the scheduled libc contracts used by the
VST specification (`Specs.v`: `read32` / `write_block` of `Protocol.v`), which are the same
`action` / `readAmount` / drain-step functions as the accepted Lean reference `BufferRelay`.

Rule-by-rule correspondence (documented model; this is the trusted transcription):
- Values: `vint` = `Vint` (32-bit), `vlong` = `Vlong` (64-bit, both `tlong` and `tulong`),
  `vptr` = `Vptr` into the single local block `buf` (offset only; one block).
- `Evar buf (tarray ..)`: array local, `By_reference` access mode → the block address (`vptr 0`).
- `Etempvar`: temp lookup; an unassigned temp is `none` (Clight: `Vundef`, on which every use
  below is also undefined).
- `semCast` = `Cop.sem_cast` for int→long (`cast_case_i2l Signed`: sign extension, target
  signedness irrelevant), long↔long (on `Archi.ptr64` this is `cast_case_pointer`; identity on
  `Vlong`), int→int I32 (identity), array/pointer→pointer (`cast_case_pointer`: identity).
- `Ebinop`: `classify_binarith`: (long, int) → both to long, signedness Signed unless one is
  unsigned; (ulong, ulong) → Unsigned. `Oadd`/`Osub` on longs: `Int64.add/sub` (mod 2^64).
  Comparisons: `Int64.cmp` (signed) or `Int64.cmpu` (unsigned) → `Vint 1/0` (`Val.of_bool`).
  `Oadd` pointer + long (`add_case_pl`, `sizeof tuchar = 1`): offset + n (mod 2^64).
- `Sifthenelse`: `bool_val` at `tint`: `Vint n` is true iff `n ≠ 0`.
- `Sset`: stores the value unchanged. `Scall (Some tmp) f args`: args are cast to the callee's
  parameter types (`eval_exprlist`), the external result is stored unchanged.
- `Sreturn (Some e)`: value cast to the function return type.
- `Sloop s1 s2` (Clight.v `Kloop1`/`Kloop2`): `s1` normal or `continue` → `s2`; `s2` normal → loop;
  `break` in either → loop exits normally; `return` propagates; `continue` in `s2` has no rule.
  `swhile` is CompCert's definition of `Swhile`.
- Externals, exactly the VST `Specs.v` contract shapes: `read(0, p, 32)` (any other fd or count
  is `none`): `q = action 32 reads`; `q < 0` → returns `-1`, consumes the action, bumps
  `read_calls`, memory unchanged (the VST post leaves the buffer unconstrained; this model picks
  "unchanged"); else `k = BufferRelay.readAmount input q` (= Protocol `read_amount q input`),
  stores the first `k` input bytes at `p`, consumes them, returns `k`. `write(1, p, cnt)`: loads
  `cnt` bytes at `p` (must be inside the block), `q = action cnt writes`; `q < 0` → `-1`; else
  `k = min q cnt`, delivers the first `k` bytes, returns `k`. Other fds: `none`.
- Memory is a total `Fin 32 → UInt8` (no `Vundef` bytes); theorems are stated for every initial
  memory `m0`, so uninitialised contents never matter to the results proved.
- Fuel: `exec` is a fuel-indexed big-step evaluator; theorems give a sufficient fuel
  (`input.length + 46` for the relay). This is NOT a theorem about CompCert's `Clight.step`
  relation or its compiler: it is a Lean model of the occurring rules, and it is part of the
  trusted boundary together with the generator and the libc contracts.
Not modelled (never occurs in `f_relay`): floats, other operators, globals other than the two
externals, function calls other than the externals, `Scontinue`, `Sswitch`, labels, builtins. -/

namespace ClightSubset

inductive Ty where
  | tint | tlong | tulong | tuchar | tvoid
  | tptr (t : Ty)
  | tarray (t : Ty) (n : Int)
  | tfunction (args : List Ty) (ret : Ty)

inductive Binop where
  | oadd | osub | olt | ole | oeq
  deriving DecidableEq, Repr

inductive Expr where
  | econst_int (n : Int) (t : Ty)
  | evar (x : String) (t : Ty)
  | etempvar (x : String) (t : Ty)
  | ebinop (op : Binop) (a b : Expr) (t : Ty)
  | ecast (e : Expr) (t : Ty)

inductive Stmt where
  | sskip
  | sbreak
  | scontinue
  | ssequence (a b : Stmt)
  | sset (x : String) (e : Expr)
  | scall (dst : Option String) (f : Expr) (args : List Expr)
  | sifthenelse (c : Expr) (t e : Stmt)
  | sloop (a b : Stmt)
  | sreturn (e : Option Expr)

/-- CompCert: `Swhile e s = Sloop (Ssequence (Sifthenelse e Sskip Sbreak) s) Sskip`. -/
def swhile (c : Expr) (s : Stmt) : Stmt :=
  .sloop (.ssequence (.sifthenelse c .sskip .sbreak) s) .sskip

structure Func where
  ret : Ty
  vars : List (String × Ty)
  temps : List (String × Ty)
  body : Stmt

/-! ## Values and the world -/

inductive Val where
  | vint (i : BitVec 32)
  | vlong (l : BitVec 64)
  | vptr (o : BitVec 64)
  deriving DecidableEq, Repr

abbrev Byte := UInt8
abbrev Mem := MemoryTransfer.Memory 32

structure World where
  mem : Mem
  temps : List (String × Val)
  input : List Byte
  reads : List Int
  writes : List Int
  delivered : List Byte
  readCalls : Nat
  writeCalls : Nat

def Expr.typeof : Expr → Ty
  | .econst_int _ t => t
  | .evar _ t => t
  | .etempvar _ t => t
  | .ebinop _ _ _ t => t
  | .ecast _ t => t

/-- `Cop.sem_cast` for the occurring type pairs. -/
def semCast (v : Val) (src dst : Ty) : Option Val :=
  match v, src, dst with
  | .vint i, .tint, .tint => some (.vint i)
  | .vint i, .tint, .tlong => some (.vlong (i.signExtend 64))
  | .vint i, .tint, .tulong => some (.vlong (i.signExtend 64))
  | .vlong l, .tlong, .tlong => some (.vlong l)
  | .vlong l, .tlong, .tulong => some (.vlong l)
  | .vlong l, .tulong, .tulong => some (.vlong l)
  | .vlong l, .tulong, .tlong => some (.vlong l)
  | .vptr o, .tarray _ _, .tptr _ => some (.vptr o)
  | .vptr o, .tptr _, .tptr _ => some (.vptr o)
  | _, _, _ => none

def ofBool (b : Bool) : Val := .vint (if b then 1 else 0)

/-- `Cop.sem_binary_operation` for the occurring cases. -/
def semBinop (op : Binop) (v1 : Val) (t1 : Ty) (v2 : Val) (t2 : Ty) : Option Val :=
  match op, v1, t1, v2, t2 with
  -- classify_binarith (long, int): cast int to long, signed
  | .olt, .vlong a, .tlong, .vint b, .tint => some (ofBool (a.slt (b.signExtend 64)))
  | .ole, .vlong a, .tlong, .vint b, .tint => some (ofBool (a.sle (b.signExtend 64)))
  | .oeq, .vlong a, .tlong, .vint b, .tint => some (ofBool (a == b.signExtend 64))
  -- classify_binarith (ulong, ulong): unsigned
  | .olt, .vlong a, .tulong, .vlong b, .tulong => some (ofBool (a.ult b))
  | .oadd, .vlong a, .tulong, .vlong b, .tulong => some (.vlong (a + b))
  | .osub, .vlong a, .tulong, .vlong b, .tulong => some (.vlong (a - b))
  -- add_case_pl: pointer to tuchar plus unsigned long, sizeof tuchar = 1
  | .oadd, .vptr o, .tarray .tuchar _, .vlong b, .tulong => some (.vptr (o + b))
  | .oadd, .vptr o, .tptr .tuchar, .vlong b, .tulong => some (.vptr (o + b))
  | _, _, _, _, _ => none

def boolVal (v : Val) (t : Ty) : Option Bool :=
  match v, t with
  | .vint i, .tint => some (i != 0)
  | _, _ => none

def evalExpr (w : World) : Expr → Option Val
  | .econst_int n .tint => some (.vint (BitVec.ofInt 32 n))
  | .econst_int _ _ => none
  | .evar "buf" (.tarray _ _) => some (.vptr 0)
  | .evar _ _ => none
  | .etempvar x _ => CalculusNested.lookup w.temps x
  | .ebinop op a b _ =>
    match evalExpr w a, evalExpr w b with
    | some va, some vb => semBinop op va a.typeof vb b.typeof
    | _, _ => none
  | .ecast e t =>
    match evalExpr w e with
    | some v => semCast v e.typeof t
    | none => none

def evalArgs (w : World) : List Expr → List Ty → Option (List Val)
  | [], [] => some []
  | e :: es, t :: ts =>
    match evalExpr w e with
    | some v =>
      match semCast v e.typeof t, evalArgs w es ts with
      | some v', some vs => some (v' :: vs)
      | _, _ => none
    | none => none
  | _, _ => none

def setOpt (temps : List (String × Val)) (dst : Option String) (v : Val) : List (String × Val) :=
  match dst with
  | some x => CalculusNested.assocSet temps x v
  | none => temps

/-- `read(0, p, cnt)` under the scheduled contract (`Protocol.read32` with request `cnt`). -/
def extRead (dst : Option String) (args : List Val) (w : World) : Option World :=
  match args with
  | [.vint fd, .vptr p, .vlong cnt] =>
    if fd ≠ 0 ∨ cnt.toNat ≠ 32 then none else
    let (q, rest) := BufferRelay.action 32 w.reads
    if q < 0 then
      some { w with reads := rest, readCalls := w.readCalls + 1,
                    temps := setOpt w.temps dst (.vlong (-1 : BitVec 64)) }
    else
      let k := BufferRelay.readAmount w.input q
      if p.toNat + k ≤ 32 then
        some { w with mem := MemoryTransfer.store w.mem p.toNat (w.input.take k),
                      input := w.input.drop k, reads := rest, readCalls := w.readCalls + 1,
                      temps := setOpt w.temps dst (.vlong (BitVec.ofNat 64 k)) }
      else none
  | _ => none

/-- `write(1, p, cnt)` under the scheduled contract (`Protocol.write_block`). -/
def extWrite (dst : Option String) (args : List Val) (w : World) : Option World :=
  match args with
  | [.vint fd, .vptr p, .vlong cnt] =>
    if fd ≠ 1 then none else
    if h : p.toNat + cnt.toNat ≤ 32 then
      let bs := MemoryTransfer.load w.mem p.toNat cnt.toNat h
      let (q, rest) := BufferRelay.action bs.length w.writes
      if q < 0 then
        some { w with writes := rest, writeCalls := w.writeCalls + 1,
                      temps := setOpt w.temps dst (.vlong (-1 : BitVec 64)) }
      else
        let k := min q.toNat bs.length
        some { w with delivered := w.delivered ++ bs.take k, writes := rest,
                      writeCalls := w.writeCalls + 1,
                      temps := setOpt w.temps dst (.vlong (BitVec.ofNat 64 k)) }
    else none
  | _ => none

inductive Outcome where
  | normal
  | brk
  | cont
  | ret (v : Option Val)
  deriving DecidableEq, Repr

/-- Fuel-indexed big-step execution of a statement in a function with return type `fnRet`. -/
def exec (fnRet : Ty) : Nat → Stmt → World → Option (Outcome × World)
  | 0, _, _ => none
  | fuel + 1, s, w =>
    match s with
    | .sskip => some (.normal, w)
    | .sbreak => some (.brk, w)
    | .scontinue => some (.cont, w)
    | .ssequence a b =>
      match exec fnRet fuel a w with
      | some (.normal, w1) => exec fnRet fuel b w1
      | r => r
    | .sset x e =>
      match evalExpr w e with
      | some v => some (.normal, { w with temps := CalculusNested.assocSet w.temps x v })
      | none => none
    | .scall dst f args =>
      match f with
      | .evar "read" (.tfunction ps _) =>
        match evalArgs w args ps with
        | some vs => (extRead dst vs w).map (fun w' => (.normal, w'))
        | none => none
      | .evar "write" (.tfunction ps _) =>
        match evalArgs w args ps with
        | some vs => (extWrite dst vs w).map (fun w' => (.normal, w'))
        | none => none
      | _ => none
    | .sifthenelse c t e =>
      match evalExpr w c with
      | some v =>
        match boolVal v c.typeof with
        | some true => exec fnRet fuel t w
        | some false => exec fnRet fuel e w
        | none => none
      | none => none
    | .sloop a b =>
      match exec fnRet fuel a w with
      | some (.normal, w1) | some (.cont, w1) =>
        match exec fnRet fuel b w1 with
        | some (.normal, w2) => exec fnRet fuel (.sloop a b) w2
        | some (.brk, w2) => some (.normal, w2)
        | some (.cont, _) => none
        | r => r
      | some (.brk, w1) => some (.normal, w1)
      | r => r
    | .sreturn none => some (.ret none, w)
    | .sreturn (some e) =>
      match evalExpr w e with
      | some v =>
        match semCast v e.typeof fnRet with
        | some v' => some (.ret (some v'), w)
        | none => none
      | none => none

/-- Run a function body from an initial memory and world (temps undefined, nothing delivered). -/
def initWorld (m0 : Mem) (input : List Byte) (reads writes : List Int) : World :=
  { mem := m0, temps := [], input := input, reads := reads, writes := writes,
    delivered := [], readCalls := 0, writeCalls := 0 }

def runFunc (f : Func) (fuel : Nat) (m0 : Mem) (input : List Byte) (reads writes : List Int) :
    Option (Outcome × World) :=
  exec f.ret fuel f.body (initWorld m0 input reads writes)

end ClightSubset
