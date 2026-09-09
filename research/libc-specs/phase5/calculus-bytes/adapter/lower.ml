(* calculus-bytes worker, 2026-09-07 (v1, kept verbatim in v1/lower.ml);
   calculus-resume-2 worker, 2026-09-07 (v2, this file).

   Bounded lowering from the REAL parsed spec-language AST (Frontend.Ast.Parsed,
   produced by the pinned Frontend.Parser.program / Frontend.Lexer.token) to the
   pinned Calculus.Ast.

   This module is NEW worker code, not upstream. At the pinned commit
   Semant.analyze_expr is `failwith "TODO"` and no lowering exists; nothing here
   claims to be Aaron's intended semantics. The mapping is documented in
   research/libc-specs/phase5/calculus-bytes/MAPPING.md. Every construct outside
   the supported fragment is rejected with a source position and a reason;
   nothing is silently erased or approximated.

   v2 changes (all documented in MAPPING.md, section "v2"):
   - `&&` / `||` are REAL short-circuit: `(p1; t := e1; if t then (p2; t := e2) else pass)`
     so the right operand's effects AND traps are skipped when the left decides.
   - Every expression is statically typed with the adapter's types
     (bool, unit, int ranges, lists, state). Ill-typed operations (`1 && true`,
     `x == some_list`, non-bool conditions, wrong arities, unknown type names,
     duplicate type aliases) are rejected at lowering time.
   - Declared integer widths are enforced as explicit range assertions
     (`Range`/`RangeList` builtins) at every annotated source/sink; literals that
     violate a declared range are rejected statically. i64 = the 63-bit carrier,
     u64 = [0, max_int]; see bytes_builtin.ml.
   - Block scoping: a `let` is visible only in the rest of its block (the env is
     immutable and blocks return the outer env); redeclaring a name visible in
     scope (including shadowing) is rejected; use of a name after its block is
     rejected as undefined. The runtime calculus environment is flat, but no
     accepted program can observe that.
   Supported fragment (summary):
     decls: type alias, attribute, element, exception, uninterpreted (table-mapped
            only, declared signature shape-checked), fn
     stmts: let, assignment to local / root attribute / state.attribute,
            while, if/else, return, raise, try/catch/finally, touch, clear, assert
     exprs: identifiers, integer/bool/char/unit literals, unary - and !,
            binary + - * / % < <= > >= == != && ||, calls of uninterpreted
            functions / fns / elements (nested `s.e(args)` to any depth),
            state.attribute, exists element(args)
   Rejected: enum/struct/match, for loops, yield, localize, casts, tuples,
             string literals, floats, generics, conditional expressions,
             bitwise operators, redeclared/shadowed locals, unknown type names. *)

open Frontend
module P = Ast.Parsed
module B = Bytes_builtin.B
module C = Bytes_builtin.Defs.C

exception Unsupported of (Lexing.position * Lexing.position) * string

let reject pos fmt = Printf.ksprintf (fun msg -> raise (Unsupported (pos, msg))) fmt

(* ---------------- adapter types ---------------- *)

type ty = TBool | TUnit | TInt of (int * int) | TList of ty | TState

let carrier = (min_int, max_int)

let rec show_ty = function
  | TBool -> "bool" | TUnit -> "unit" | TState -> "state"
  | TInt (lo, hi) when (lo, hi) = carrier -> "int[carrier]"
  | TInt (lo, hi) -> Printf.sprintf "int[%d,%d]" lo hi
  | TList t -> "list<" ^ show_ty t ^ ">"

(* [lo,hi] included in [lo',hi'] *)
let sub (lo, hi) (lo', hi') = lo' <= lo && hi <= hi'

(* the type a local gets from an unannotated `let`: literal singletons widen to the carrier *)
let rec generalize = function
  | TInt _ -> TInt carrier
  | TList t -> TList (generalize t)
  | t -> t

module SM = Map.Make (String)

let rec resolve (aliases : ty SM.t) (t : P.typ) : ty =
  match t.ast with
  | P.Bool -> TBool
  | P.Void -> TUnit
  | P.SInt8 -> TInt (-128, 127)
  | P.UInt8 -> TInt (0, 255)
  | P.SInt16 -> TInt (-32768, 32767)
  | P.UInt16 -> TInt (0, 65535)
  | P.SInt32 -> TInt (-2147483648, 2147483647)
  | P.UInt32 -> TInt (0, 4294967295)
  | P.SInt64 -> TInt carrier                 (* the carrier itself (63-bit), see bytes_builtin.ml *)
  | P.UInt64 -> TInt (0, max_int)            (* the representable sub-range; larger values trap *)
  | P.StateRef -> TState
  | P.List t -> TList (resolve aliases t)
  | P.Named (n, []) ->
      begin match SM.find_opt n aliases with
      | Some t -> t
      | None -> reject t.pos "unknown type name '%s' (declare `type %s = <width>` first)" n n
      end
  | P.Named (n, _ :: _) -> reject t.pos "generic type '%s' is outside the fragment" n
  | P.Float32 | P.Float64 -> reject t.pos "floating point is outside the fragment"
  | P.String -> reject t.pos "string type is outside the fragment (bytes are list::<u8>)"
  | P.Function _ -> reject t.pos "function types are outside the fragment"
  | P.Product _ -> reject t.pos "tuple types are outside the fragment"

(* Coerce an expression of type [actual] to a sink of type [target]: identical
   types pass; an integer (list) whose range is not included in the target's gets
   an explicit runtime range assertion; a literal outside the target range is a
   static error; anything else is a type mismatch. *)
let coerce pos ~(actual : ty) ~(target : ty) (e : C.expr) : C.expr =
  let rec go actual target e =
    match actual, target with
    | TInt r, TInt r' when sub r r' -> e
    | TInt _, TInt (lo, hi) ->
        begin match e with
        | C.Literal (B.Int n) ->
            if lo <= n && n <= hi then e
            else reject pos "literal %d is outside the declared range [%d,%d]" n lo hi
        | _ -> C.Function (B.Range (lo, hi), e)
        end
    | TList (TInt r), TList (TInt r') when sub r r' -> e
    | TList (TInt _), TList (TInt (lo, hi)) -> C.Function (B.RangeList (lo, hi), e)
    | TList a, TList b when a = b -> e
    | TBool, TBool | TUnit, TUnit | TState, TState -> e
    | _ -> reject pos "type mismatch: expression has type %s, expected %s" (show_ty actual) (show_ty target)
  in go actual target e

(* ---------------- globals ---------------- *)

type global =
  | GAttr of ty
  | GElem of ty list
  | GUninterp of B.func * ty list * ty
  | GFn of ty list * ty
  | GExc of ty list

type env = { globals : global SM.t; locals : ty SM.t; ret : ty }

let sigma = C.Variable "σ"
let counter = ref 0
let fresh () = incr counter; Printf.sprintf "$t%d" !counter

let rec seq = function
  | [] -> C.Pass
  | [s] -> s
  | s :: rest -> C.Seq (s, seq rest)

(* Argument tuples are right-nested pairs; unit for none. *)
let rec tuple = function
  | [] -> C.Literal B.Unit
  | [e] -> e
  | e :: rest -> C.Pair (e, tuple rest)

(* Projection i of n out of a right-nested tuple expression. *)
let rec proj i n e =
  if n <= 1 then e
  else if i = 0 then C.Function (B.Fst, e)
  else proj (i - 1) (n - 1) (C.Function (B.Snd, e))

let lit_int i = C.Literal (B.Int i)

(* Shape of each table builtin, checked against the DECLARED uninterpreted signature. *)
let shape_ok (f : B.func) (args : ty list) (ret : ty) =
  let isint = function TInt _ -> true | _ -> false in
  let isil = function TList (TInt _) -> true | _ -> false in
  match f, args with
  | B.Length, [a] -> isil a && isint ret
  | (B.Take | B.Drop), [a; n] -> isil a && isint n && isil ret
  | B.Slice, [a; o; n] -> isil a && isint o && isint n && isil ret
  | B.Append, [a; b] -> isil a && isil b && isil ret
  | B.Single, [b] -> isint b && isil ret
  | B.Empty, [] -> isil ret
  | B.HeadOr, [a; d] -> isil a && isint d && isint ret
  | B.Tail, [a] -> isil a && isil ret
  | (B.Min | B.Max), [a; b] -> isint a && isint b && isint ret
  | _ -> false

let arith pos = function
  | P.Add -> B.Add | P.Sub -> B.Sub | P.Mul -> B.Mul | P.Div -> B.Div | P.Mod -> B.Mod
  | P.Lt -> B.Lt | P.Le -> B.Le | P.Gt -> B.Gt | P.Ge -> B.Ge
  | P.Eq -> B.Eq | P.Ne -> B.Ne | P.LAnd -> B.LAnd | P.LOr -> B.LOr
  | P.LShft | P.RShft | P.BAnd | P.BXor | P.BOr ->
      reject pos "bitwise operators are outside the fragment"

let lookup_global env pos name =
  match SM.find_opt name env.globals with
  | Some g -> g
  | None -> reject pos "undefined name '%s'" name

(* Typed literals: the lexer (with the private suffix patch) already enforces the
   suffix width; the value must additionally fit the carrier. *)
let int64_lit pos (i : Stdint.int64) =
  if Stdint.Int64.compare i (Stdint.Int64.of_int max_int) > 0
  || Stdint.Int64.compare i (Stdint.Int64.of_int min_int) < 0
  then reject pos "i64 literal %s is outside the adapter carrier [%d,%d]" (Stdint.Int64.to_string i) min_int max_int;
  Stdint.Int64.to_int i
let uint64_lit pos (i : Stdint.uint64) =
  if Stdint.Uint64.compare i (Stdint.Uint64.of_int max_int) > 0
  then reject pos "u64 literal %s is outside the adapter carrier [0,%d]" (Stdint.Uint64.to_string i) max_int;
  Stdint.Uint64.to_int i

let const n = ([], lit_int n, TInt (n, n))

(* Lower a list of argument expressions against declared parameter types. *)
let rec lower_args env pos what (args : P.expr list) (tys : ty list) =
  if List.length args <> List.length tys then
    reject pos "%s expects %d arguments, %d given" what (List.length tys) (List.length args);
  let (ps, es) = List.split (List.map2 (fun (a : P.expr) t ->
      let (p, a', ta) = lexpr env a in (p, coerce a.pos ~actual:ta ~target:t a')) args tys) in
  (List.concat ps, es)

(* Returns (prefix statements, expression, type). Prefix statements perform the
   attribute reads / fn calls / short-circuit tests the expression depends on, in
   left-to-right order. *)
and lexpr env (e : P.expr) : C.stmt list * C.expr * ty =
  match e.ast with
  | P.Id v ->
      begin match SM.find_opt v env.locals with
      | Some t -> ([], C.Variable v, t)
      | None ->
          match lookup_global env e.pos v with
          | GAttr t -> let x = fresh () in ([C.Get (x, (sigma, v))], C.Variable x, t)
          | GElem _ -> reject e.pos "element '%s' must be applied to its arguments" v
          | GFn _ -> reject e.pos "fn '%s' used as a value" v
          | GUninterp _ -> reject e.pos "uninterpreted '%s' used as a value" v
          | GExc _ -> reject e.pos "exception '%s' used as a value" v
      end
  | P.BoolLit b -> ([], C.Literal (B.Bool b), TBool)
  | P.UnitLit -> ([], C.Literal B.Unit, TUnit)
  | P.CharLit c -> const (Char.code c)
  | P.Int8Lit i -> const (Stdint.Int8.to_int i)
  | P.Int16Lit i -> const (Stdint.Int16.to_int i)
  | P.Int32Lit i -> const (Stdint.Int32.to_int i)
  | P.Int64Lit i -> const (int64_lit e.pos i)
  | P.UInt8Lit i -> const (Stdint.Uint8.to_int i)
  | P.UInt16Lit i -> const (Stdint.Uint16.to_int i)
  | P.UInt32Lit i -> const (Stdint.Uint32.to_int i)
  | P.UInt64Lit i -> const (uint64_lit e.pos i)
  | P.StringLit _ -> reject e.pos "string literals are outside the fragment (bytes are list::<u8>)"
  | P.F32Lit _ | P.F64Lit _ -> reject e.pos "floating point is outside the fragment"
  | P.UnaryExp (P.Neg, x) ->
      begin match lexpr env x with
      | ([], C.Literal (B.Int n), TInt _) when n <> min_int -> const (- n)
      | (p, x', TInt _) -> (p, C.Function (B.Neg, x'), TInt carrier)
      | (_, _, t) -> reject e.pos "unary '-' on a %s" (show_ty t)
      end
  | P.UnaryExp (P.LNot, x) ->
      begin match lexpr env x with
      | (p, x', TBool) -> (p, C.Function (B.LNot, x'), TBool)
      | (_, _, t) -> reject e.pos "'!' on a %s" (show_ty t)
      end
  | P.UnaryExp (P.BNot, _) -> reject e.pos "bitwise not is outside the fragment"
  | P.BinaryExp (l, ((P.LAnd | P.LOr) as op), r) ->
      (* v2: real short-circuit; the right operand (prefix and traps) runs only if needed *)
      let (pl, l', tl) = lexpr env l in
      let (pr, r', tr) = lexpr env r in
      if tl <> TBool then reject l.pos "left operand of a short-circuit operator has type %s, expected bool" (show_ty tl);
      if tr <> TBool then reject r.pos "right operand of a short-circuit operator has type %s, expected bool" (show_ty tr);
      let t = fresh () in
      let rhs = seq (pr @ [C.Assign (t, r')]) in
      let test = if op = P.LAnd then C.Cond (C.Variable t, rhs, C.Pass) else C.Cond (C.Variable t, C.Pass, rhs) in
      (pl @ [C.Assign (t, l'); test], C.Variable t, TBool)
  | P.BinaryExp (l, op, r) ->
      let f = arith e.pos op in
      let (pl, l', tl) = lexpr env l in
      let (pr, r', tr) = lexpr env r in
      let result = match op, tl, tr with
        | (P.Add | P.Sub | P.Mul | P.Div | P.Mod), TInt _, TInt _ -> TInt carrier
        | (P.Lt | P.Le | P.Gt | P.Ge), TInt _, TInt _ -> TBool
        | (P.Eq | P.Ne), TInt _, TInt _ | (P.Eq | P.Ne), TBool, TBool | (P.Eq | P.Ne), TUnit, TUnit -> TBool
        | (P.Eq | P.Ne), _, _ -> reject e.pos "equality between %s and %s is outside the fragment (only int/bool/unit literals)" (show_ty tl) (show_ty tr)
        | _ -> reject e.pos "operator applied to %s and %s (expected two integers)" (show_ty tl) (show_ty tr) in
      (pl @ pr, C.Function (f, C.Pair (l', r')), result)
  | P.FieldExp (base, f) ->
      let (pb, b', kb) = lexpr env base in
      if kb <> TState then reject e.pos "field access '.%s' on a %s (structs are outside the fragment)" f (show_ty kb);
      begin match lookup_global env e.pos f with
      | GAttr t -> let x = fresh () in (pb @ [C.Get (x, (b', f))], C.Variable x, t)
      | _ -> reject e.pos "'.%s' is not a declared attribute" f
      end
  | P.FuncExp (_, _ :: _, _) -> reject e.pos "explicit type arguments are outside the fragment"
  | P.FuncExp (f, [], args) ->
      begin match f.ast with
      | P.Id name when not (SM.mem name env.locals) ->
          begin match lookup_global env f.pos name with
          | GUninterp (fn, tys, ret) ->
              let (p, es) = lower_args env e.pos ("'" ^ name ^ "'") args tys in
              (p, C.Function (fn, tuple es), ret)
          | GElem tys ->
              let (p, es) = lower_args env e.pos ("element '" ^ name ^ "'") args tys in
              (p, C.Element (sigma, name, tuple es), TState)
          | GFn (tys, ret) ->
              let (p, es) = lower_args env e.pos ("fn '" ^ name ^ "'") args tys in
              let t = fresh () in (p @ [C.Action (t, name, tuple es)], C.Variable t, ret)
          | GAttr _ -> reject e.pos "attribute '%s' is not callable" name
          | GExc _ -> reject e.pos "exception '%s' is not callable (use raise)" name
          end
      | P.FieldExp (base, name) ->
          let (pb, b', kb) = lexpr env base in
          if kb <> TState then reject e.pos "'.%s(...)' on a %s" name (show_ty kb);
          begin match lookup_global env e.pos name with
          | GElem tys ->
              let (p, es) = lower_args env e.pos ("element '" ^ name ^ "'") args tys in
              (pb @ p, C.Element (b', name, tuple es), TState)
          | _ -> reject e.pos "'.%s(...)' is not a declared element" name
          end
      | _ -> reject e.pos "only named uninterpreted functions, fns and elements can be called"
      end
  | P.Exists x ->
      let (p, x', _) = lexpr env x in
      begin match x' with
      | C.Element (base, elm, arg) ->
          let t = fresh () in
          (p @ [C.Contains ((base, elm, arg), C.Assign (t, C.Literal (B.Bool true)),
                            C.Assign (t, C.Literal (B.Bool false)))], C.Variable t, TBool)
      | _ -> reject e.pos "exists requires an element expression"
      end
  | P.CastExp _ -> reject e.pos "casts are outside the fragment (declared widths are enforced as range assertions instead)"
  | P.TupleExp _ | P.ProdField _ -> reject e.pos "tuples are outside the fragment"
  | P.StructExp _ -> reject e.pos "structs are outside the fragment"
  | P.EnumExp _ -> reject e.pos "enums are outside the fragment"
  | P.CondExp _ -> reject e.pos "conditional expressions are outside the fragment"
  | P.ForEach _ -> reject e.pos "for-each expressions are outside the fragment"

(* a boolean condition *)
let lcond env (c : P.expr) =
  let (p, c', t) = lexpr env c in
  if t <> TBool then reject c.pos "condition has type %s, expected bool" (show_ty t);
  (p, c')

(* An element expression as a (base, name, arg) triple, for touch/clear. *)
let lelem env (e : P.expr) =
  let (p, e', _) = lexpr env e in
  match e' with
  | C.Element (base, elm, arg) -> (p, (base, elm, arg))
  | _ -> reject e.pos "touch/clear require an element expression"

(* type aliases are resolved once at declaration time and stored resolved *)
let current_aliases : ty SM.t ref = ref SM.empty
let resolve_env (_ : env) ty = resolve !current_aliases ty

let bind_local env pos v t =
  if SM.mem v env.locals then reject pos "redeclaration of local '%s' (shadowing is outside the fragment)" v;
  if SM.mem v env.globals then reject pos "local '%s' shadows a global declaration" v;
  { env with locals = SM.add v t env.locals }

let rec lstmt env (s : P.stmt) : env * C.stmt =
  match s.ast with
  | P.LetStmt (v, ty, rhs) ->
      let (p, rhs', tr) = lexpr env rhs in
      let (t, rhs') = match ty with
        | None -> (generalize tr, rhs')
        | Some ty -> let t = resolve_env env ty in (t, coerce rhs.pos ~actual:tr ~target:t rhs') in
      let env = bind_local env s.pos v t in
      (env, seq (p @ [C.Assign (v, rhs')]))
  | P.Assign (lhs, rhs) ->
      begin match lhs.ast with
      | P.Id v when SM.mem v env.locals ->
          let t = SM.find v env.locals in
          let (p, rhs', tr) = lexpr env rhs in
          (env, seq (p @ [C.Assign (v, coerce rhs.pos ~actual:tr ~target:t rhs')]))
      | P.Id v ->
          begin match lookup_global env lhs.pos v with
          | GAttr t -> let (p, rhs', tr) = lexpr env rhs in
              (env, seq (p @ [C.Add (C.QualAttr (sigma, v, coerce rhs.pos ~actual:tr ~target:t rhs'))]))
          | _ -> reject lhs.pos "assignment target '%s' is neither a local nor an attribute" v
          end
      | P.FieldExp (base, f) ->
          let (pb, b', kb) = lexpr env base in
          if kb <> TState then reject lhs.pos "'.%s' assignment on a %s" f (show_ty kb);
          begin match lookup_global env lhs.pos f with
          | GAttr t -> let (p, rhs', tr) = lexpr env rhs in
              (env, seq (pb @ p @ [C.Add (C.QualAttr (b', f, coerce rhs.pos ~actual:tr ~target:t rhs'))]))
          | _ -> reject lhs.pos "'.%s' is not a declared attribute" f
          end
      | _ -> reject lhs.pos "unsupported assignment target"
      end
  | P.WhileLoop (c, body) ->
      let (p, c') = lcond env c in
      let body' = lblock env body in
      (* the condition's prefix must be re-evaluated before every test *)
      (env, seq (p @ [C.While (c', seq [body'; seq p])]))
  | P.IfThenElse (c, thn, els) ->
      let (p, c') = lcond env c in
      (env, seq (p @ [C.Cond (c', lblock env thn, lblock env els)]))
  | P.Return e ->
      let (p, e', t) = lexpr env e in
      (env, seq (p @ [C.Return (coerce e.pos ~actual:t ~target:env.ret e')]))
  | P.Raise (name, args) ->
      begin match lookup_global env s.pos name with
      | GExc tys ->
          let (p, es) = lower_args env s.pos ("exception '" ^ name ^ "'") args tys in
          (env, seq (p @ [C.Raise (C.Pair (C.Literal (B.String name), tuple es))]))
      | _ -> reject s.pos "'%s' is not a declared exception" name
      end
  | P.TryCatch (body, catch, finally) ->
      let body' = lblock env body in
      let with_catch =
        match catch with
        | None -> body'
        | Some (exc, vars, cbody) ->
            begin match lookup_global env s.pos exc with
            | GExc tys ->
                let arity = List.length tys in
                if List.length vars <> arity then reject s.pos "catch %s binds %d names, exception has %d" exc (List.length vars) arity;
                let ex = fresh () in
                let (cenv, binds) = List.fold_left (fun (env, acc) (i, (v, t)) ->
                    let env = bind_local env s.pos v t in
                    (env, acc @ [C.Assign (v, proj i arity (C.Function (B.Snd, C.Variable ex)))]))
                    (env, []) (List.mapi (fun i vt -> (i, vt)) (List.combine vars tys)) in
                let cbody' = lblock cenv cbody in
                C.TryCatch (body', ex,
                  C.Cond (C.Function (B.ExcTag exc, C.Variable ex),
                          seq (binds @ [cbody']),
                          C.Raise (C.Variable ex)))
            | _ -> reject s.pos "'%s' is not a declared exception" exc
            end in
      let result = match finally with
        | [] -> with_catch
        | fin -> C.TryFinally (with_catch, lblock env fin) in
      (env, result)
  | P.Touch e -> let (p, (b, el, a)) = lelem env e in (env, seq (p @ [C.Add (C.QualPosE (b, el, a))]))
  | P.Clear e -> let (p, (b, el, a)) = lelem env e in (env, seq (p @ [C.Add (C.QualNegE (b, el, a))]))
  | P.Assert e ->
      let (p, e') = lcond env e in
      (env, seq (p @ [C.Cond (e', C.Pass,
                              C.Raise (C.Pair (C.Literal (B.String "AssertionFailure"), C.Literal B.Unit)))]))
  | P.Match _ -> reject s.pos "match/enums are outside the fragment"
  | P.ForLoop _ -> reject s.pos "for loops are outside the fragment"
  | P.Yield _ -> reject s.pos "yield is outside the fragment"
  | P.Localize _ -> reject s.pos "localize is outside the fragment"

(* A block: each statement sees the bindings of the statements before it in the
   same block; the block returns the OUTER environment (lets do not escape). *)
and lblock env (stmts : P.stmt list) : C.stmt =
  let (_, acc) = List.fold_left (fun (env, acc) s ->
      let (env, s') = lstmt env s in (env, acc @ [s'])) (env, []) stmts in
  seq acc


type lowered = {
  globals : (string * string) list;        (* name, category *)
  fns : (string * C.stmt) list;            (* lowered action bodies *)
}

let category = function
  | GAttr t -> "attribute:" ^ show_ty t
  | GElem ts -> "element(" ^ String.concat "," (List.map show_ty ts) ^ ")"
  | GUninterp (_, ts, r) -> "uninterpreted(" ^ String.concat "," (List.map show_ty ts) ^ ")->" ^ show_ty r
  | GFn (ts, r) -> "fn(" ^ String.concat "," (List.map show_ty ts) ^ ")->" ^ show_ty r
  | GExc ts -> "exception(" ^ String.concat "," (List.map show_ty ts) ^ ")"

let lower_program (decls : P.decl list) : lowered =
  counter := 0;
  current_aliases := SM.empty;
  let add name g pos globals =
    if SM.mem name globals then reject pos "name '%s' declared twice" name;
    SM.add name g globals in
  let globals = List.fold_left (fun globals (d : P.decl) ->
      let res = resolve !current_aliases in
      match d.ast with
      | P.Attribute { local = true; name; _ } -> reject d.pos "local attribute '%s' is outside the fragment" name
      | P.Element { local = true; name; _ } -> reject d.pos "local element '%s' is outside the fragment" name
      | P.Attribute { name; ty; _ } -> add name (GAttr (res ty)) d.pos globals
      | P.Element { name; ty; _ } -> add name (GElem (List.map res ty)) d.pos globals
      | P.Exception { name; ty } -> add name (GExc (List.map res ty)) d.pos globals
      | P.Type { name; def } ->
          if SM.mem name !current_aliases then reject d.pos "type alias '%s' declared twice" name;
          current_aliases := SM.add name (res def) !current_aliases;
          globals
      | P.Uninterp { name; ty_args = _ :: _; _ } -> reject d.pos "generic uninterpreted '%s' is outside the fragment" name
      | P.Uninterp { name; args; ret; _ } ->
          begin match List.find_opt (fun (n, _, _) -> n = name) Bytes_builtin.uninterp_table with
          | Some (_, f, arity) ->
              if List.length args <> arity then reject d.pos "uninterpreted '%s' declared with %d args; builtin table has %d" name (List.length args) arity;
              let tys = List.map res args and r = res ret in
              if not (shape_ok f tys r) then reject d.pos "uninterpreted '%s' declared with signature (%s)->%s, which does not match the builtin's shape" name (String.concat "," (List.map show_ty tys)) (show_ty r);
              add name (GUninterp (f, tys, r)) d.pos globals
          | None -> reject d.pos "uninterpreted '%s' has no builtin interpretation in the documented table" name
          end
      | P.Function { name; ty_args = _ :: _; _ } -> reject d.pos "generic fn '%s' is outside the fragment" name
      | P.Function { name; args; ret; _ } -> add name (GFn (List.map (fun (_, t) -> res t) args, res ret)) d.pos globals
      | P.Enum { name; _ } -> reject d.pos "enum '%s' is outside the fragment" name
      | P.Struct { name; _ } -> reject d.pos "struct '%s' is outside the fragment" name)
      SM.empty decls in
  let fns = List.filter_map (fun (d : P.decl) ->
      match d.ast with
      | P.Function { name; args; body; _ } ->
          let (tys, ret) = match SM.find name globals with GFn (t, r) -> (t, r) | _ -> assert false in
          let env = { globals; locals = SM.empty; ret } in
          let n = List.length args in
          (* parameters: bound from ι with the declared range enforced on entry *)
          let (env, binds) = List.fold_left (fun (env, acc) (i, ((v, _), t)) ->
              let env = bind_local env d.pos v t in
              let arg = proj i n (C.Variable "ι") in
              let arg = match t with
                | TInt (lo, hi) when (lo, hi) <> carrier -> C.Function (B.Range (lo, hi), arg)
                | TList (TInt (lo, hi)) when (lo, hi) <> carrier -> C.Function (B.RangeList (lo, hi), arg)
                | _ -> arg in
              (env, acc @ [C.Assign (v, arg)]))
              (env, []) (List.mapi (fun i a -> (i, a)) (List.combine args tys)) in
          Some (name, seq (binds @ [lblock env body]))
      | _ -> None) decls in
  { globals = List.map (fun (n, g) -> (n, category g)) (SM.bindings globals); fns }

(* S-expression printer for the lowered calculus, so the exact program that ran
   can be recorded and hashed. *)
let rec show_expr = function
  | C.Function (f, e) -> Printf.sprintf "(%s %s)" (show_func f) (show_expr e)
  | C.Literal l -> B.string_of_lit l
  | C.Variable v -> v
  | C.Pair (a, b) -> Printf.sprintf "(pair %s %s)" (show_expr a) (show_expr b)
  | C.Element (b, e, a) -> Printf.sprintf "(elem %s %s %s)" (show_expr b) e (show_expr a)
and show_func = function
  | B.Add -> "+" | B.Sub -> "-" | B.Mul -> "*" | B.Div -> "/" | B.Mod -> "%"
  | B.Lt -> "<" | B.Le -> "<=" | B.Gt -> ">" | B.Ge -> ">=" | B.Eq -> "==" | B.Ne -> "!="
  | B.Neg -> "neg" | B.LNot -> "not" | B.LAnd -> "and" | B.LOr -> "or"
  | B.Fst -> "fst" | B.Snd -> "snd" | B.ExcTag t -> "exc-is:" ^ t
  | B.Range (lo, hi) -> Printf.sprintf "range:%d:%d" lo hi
  | B.RangeList (lo, hi) -> Printf.sprintf "range-list:%d:%d" lo hi
  | B.Length -> "length" | B.Take -> "take" | B.Drop -> "drop" | B.Slice -> "slice"
  | B.Append -> "append" | B.Single -> "single" | B.Empty -> "empty"
  | B.HeadOr -> "head_or" | B.Tail -> "tail" | B.Min -> "min" | B.Max -> "max"
let rec show_stmt = function
  | C.Seq (a, b) -> Printf.sprintf "(seq %s %s)" (show_stmt a) (show_stmt b)
  | C.Action (v, a, e) -> Printf.sprintf "(action %s %s %s)" v a (show_expr e)
  | C.Assign (v, e) -> Printf.sprintf "(assign %s %s)" v (show_expr e)
  | C.Add (C.QualAttr (b, a, e)) -> Printf.sprintf "(set-attr %s %s %s)" (show_expr b) a (show_expr e)
  | C.Add (C.QualPosE (b, el, e)) -> Printf.sprintf "(add-elem %s %s %s)" (show_expr b) el (show_expr e)
  | C.Add (C.QualNegE (b, el, e)) -> Printf.sprintf "(remove-elem %s %s %s)" (show_expr b) el (show_expr e)
  | C.Get (v, (b, a)) -> Printf.sprintf "(get %s %s %s)" v (show_expr b) a
  | C.Contains ((b, el, e), t, f) -> Printf.sprintf "(contains %s %s %s %s %s)" (show_expr b) el (show_expr e) (show_stmt t) (show_stmt f)
  | C.Cond (c, t, f) -> Printf.sprintf "(if %s %s %s)" (show_expr c) (show_stmt t) (show_stmt f)
  | C.Match (e, v, l, r) -> Printf.sprintf "(match %s %s %s %s)" (show_expr e) v (show_stmt l) (show_stmt r)
  | C.ForEach (r, e, v, b) -> Printf.sprintf "(foreach %s %s %s %s)" r (show_expr e) v (show_stmt b)
  | C.While (c, b) -> Printf.sprintf "(while %s %s)" (show_expr c) (show_stmt b)
  | C.ForElem (b, el, v, s) -> Printf.sprintf "(forelem %s %s %s %s)" (show_expr b) el v (show_stmt s)
  | C.TryCatch (b, v, c) -> Printf.sprintf "(try %s catch %s %s)" (show_stmt b) v (show_stmt c)
  | C.TryFinally (b, f) -> Printf.sprintf "(try %s finally %s)" (show_stmt b) (show_stmt f)
  | C.Localize (el, e, b) -> Printf.sprintf "(localize %s %s %s)" el (show_expr e) (show_stmt b)
  | C.Raise e -> Printf.sprintf "(raise %s)" (show_expr e)
  | C.Return e -> Printf.sprintf "(return %s)" (show_expr e)
  | C.Yield e -> Printf.sprintf "(yield %s)" (show_expr e)
  | C.Pass -> "pass"
