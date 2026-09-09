(* calculus-bytes worker, 2026-09-07. Bounded lowering from the REAL parsed
   spec-language AST (Frontend.Ast.Parsed, produced by the pinned
   Frontend.Parser.program / Frontend.Lexer.token) to the pinned Calculus.Ast.

   This module is NEW worker code, not upstream. At the pinned commit
   Semant.analyze_expr is `failwith "TODO"` and no lowering exists; nothing here
   claims to be Aaron's intended semantics. The mapping is documented in
   research/libc-specs/phase5/calculus-bytes/MAPPING.md. Every construct outside
   the supported fragment is rejected with a source position and a reason;
   nothing is silently erased or approximated.

   Supported fragment (summary):
     decls: attribute, element, exception, uninterpreted (table-mapped only),
            type alias (accepted, ignored: ints are untyped), fn
     stmts: let, assignment to local / root attribute / state.attribute,
            while, if/else, return, raise, try/catch/finally, touch, clear, assert
     exprs: identifiers, integer/bool/char/unit literals, unary - and !,
            binary + - * / % < <= > >= == != && ||, calls of uninterpreted
            functions / fns / elements, state.attribute, state.element(args),
            exists element(args)
   Rejected: enum/struct/match, for loops, yield, localize, casts, tuples,
             string literals, floats, generics, conditional expressions,
             short-circuit operands with effects, redeclared locals. *)

open Frontend
module P = Ast.Parsed
module B = Bytes_builtin.B
module C = Bytes_builtin.Defs.C

exception Unsupported of (Lexing.position * Lexing.position) * string

let reject pos fmt = Printf.ksprintf (fun msg -> raise (Unsupported (pos, msg))) fmt

type kind = KState | KVal

type global =
  | GAttr
  | GElem of int
  | GUninterp of B.func * int
  | GFn of int * kind
  | GExc of int

module SM = Map.Make (String)

type env = { globals : global SM.t; locals : kind SM.t }

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

let kind_of_typ (t : P.typ) = match t.ast with P.StateRef -> KState | _ -> KVal

let lit_int i = C.Literal (B.Int i)

let binop pos = function
  | P.Add -> B.Add | P.Sub -> B.Sub | P.Mul -> B.Mul | P.Div -> B.Div | P.Mod -> B.Mod
  | P.Lt -> B.Lt | P.Le -> B.Le | P.Gt -> B.Gt | P.Ge -> B.Ge
  | P.Eq -> B.Eq | P.Ne -> B.Ne | P.LAnd -> B.LAnd | P.LOr -> B.LOr
  | P.LShft | P.RShft | P.BAnd | P.BXor | P.BOr ->
      reject pos "bitwise operators are outside the fragment (integers are untyped here)"

let lookup_global env pos name =
  match SM.find_opt name env.globals with
  | Some g -> g
  | None -> reject pos "undefined name '%s'" name

(* Returns (prefix statements, expression, kind). Prefix statements perform the
   attribute reads / fn calls the expression depends on, in left-to-right order. *)
let rec lexpr env (e : P.expr) : C.stmt list * C.expr * kind =
  match e.ast with
  | P.Id v ->
      begin match SM.find_opt v env.locals with
      | Some k -> ([], C.Variable v, k)
      | None ->
          match lookup_global env e.pos v with
          | GAttr -> let t = fresh () in ([C.Get (t, (sigma, v))], C.Variable t, KVal)
          | GElem _ -> reject e.pos "element '%s' must be applied to its arguments" v
          | GFn _ -> reject e.pos "fn '%s' used as a value" v
          | GUninterp _ -> reject e.pos "uninterpreted '%s' used as a value" v
          | GExc _ -> reject e.pos "exception '%s' used as a value" v
      end
  | P.BoolLit b -> ([], C.Literal (B.Bool b), KVal)
  | P.UnitLit -> ([], C.Literal B.Unit, KVal)
  | P.CharLit c -> ([], lit_int (Char.code c), KVal)
  | P.Int8Lit i -> ([], lit_int (Stdint.Int8.to_int i), KVal)
  | P.Int16Lit i -> ([], lit_int (Stdint.Int16.to_int i), KVal)
  | P.Int32Lit i -> ([], lit_int (Stdint.Int32.to_int i), KVal)
  | P.Int64Lit i -> ([], lit_int (Stdint.Int64.to_int i), KVal)
  | P.UInt8Lit i -> ([], lit_int (Stdint.Uint8.to_int i), KVal)
  | P.UInt16Lit i -> ([], lit_int (Stdint.Uint16.to_int i), KVal)
  | P.UInt32Lit i -> ([], lit_int (Stdint.Uint32.to_int i), KVal)
  | P.UInt64Lit i -> ([], lit_int (Stdint.Uint64.to_int i), KVal)
  | P.StringLit _ -> reject e.pos "string literals are outside the fragment (bytes are list::<u8>)"
  | P.F32Lit _ | P.F64Lit _ -> reject e.pos "floating point is outside the fragment"
  | P.UnaryExp (P.Neg, x) ->
      let (p, x', _) = lexpr env x in (p, C.Function (B.Neg, x'), KVal)
  | P.UnaryExp (P.LNot, x) ->
      let (p, x', _) = lexpr env x in (p, C.Function (B.LNot, x'), KVal)
  | P.UnaryExp (P.BNot, _) -> reject e.pos "bitwise not is outside the fragment"
  | P.BinaryExp (l, op, r) ->
      let f = binop e.pos op in
      let (pl, l', _) = lexpr env l in
      let (pr, r', _) = lexpr env r in
      if (op = P.LAnd || op = P.LOr) && pr <> [] then
        reject e.pos "right operand of a short-circuit operator needs effects (attribute read or call); not supported";
      (pl @ pr, C.Function (f, C.Pair (l', r')), KVal)
  | P.FieldExp (base, f) ->
      let (pb, b', kb) = lexpr env base in
      if kb <> KState then reject e.pos "field access '.%s' on a non-state value (structs are outside the fragment)" f;
      begin match lookup_global env e.pos f with
      | GAttr -> let t = fresh () in (pb @ [C.Get (t, (b', f))], C.Variable t, KVal)
      | _ -> reject e.pos "'.%s' is not a declared attribute" f
      end
  | P.FuncExp (_, _ :: _, _) -> reject e.pos "explicit type arguments are outside the fragment"
  | P.FuncExp (f, [], args) ->
      let lower_args () =
        let (ps, es) = List.split (List.map (fun a -> let (p, a', _) = lexpr env a in (p, a')) args) in
        (List.concat ps, es) in
      begin match f.ast with
      | P.Id name when not (SM.mem name env.locals) ->
          begin match lookup_global env f.pos name with
          | GUninterp (fn, arity) ->
              if List.length args <> arity then reject e.pos "'%s' expects %d arguments" name arity;
              let (p, es) = lower_args () in (p, C.Function (fn, tuple es), KVal)
          | GElem arity ->
              if List.length args <> arity then reject e.pos "element '%s' expects %d arguments" name arity;
              let (p, es) = lower_args () in (p, C.Element (sigma, name, tuple es), KState)
          | GFn (arity, k) ->
              if List.length args <> arity then reject e.pos "fn '%s' expects %d arguments" name arity;
              let (p, es) = lower_args () in
              let t = fresh () in (p @ [C.Action (t, name, tuple es)], C.Variable t, k)
          | GAttr -> reject e.pos "attribute '%s' is not callable" name
          | GExc _ -> reject e.pos "exception '%s' is not callable (use raise)" name
          end
      | P.FieldExp (base, name) ->
          let (pb, b', kb) = lexpr env base in
          if kb <> KState then reject e.pos "'.%s(...)' on a non-state value" name;
          begin match lookup_global env e.pos name with
          | GElem arity ->
              if List.length args <> arity then reject e.pos "element '%s' expects %d arguments" name arity;
              let (p, es) = lower_args () in (pb @ p, C.Element (b', name, tuple es), KState)
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
                            C.Assign (t, C.Literal (B.Bool false)))], C.Variable t, KVal)
      | _ -> reject e.pos "exists requires an element expression"
      end
  | P.CastExp _ -> reject e.pos "casts are outside the fragment (integers are untyped here)"
  | P.TupleExp _ | P.ProdField _ -> reject e.pos "tuples are outside the fragment"
  | P.StructExp _ -> reject e.pos "structs are outside the fragment"
  | P.EnumExp _ -> reject e.pos "enums are outside the fragment"
  | P.CondExp _ -> reject e.pos "conditional expressions are outside the fragment"
  | P.ForEach _ -> reject e.pos "for-each expressions are outside the fragment"

(* An element expression as a (base, name, arg) triple, for touch/clear. *)
let lelem env (e : P.expr) =
  let (p, e', _) = lexpr env e in
  match e' with
  | C.Element (base, elm, arg) -> (p, (base, elm, arg))
  | _ -> reject e.pos "touch/clear require an element expression"

let bind_local env pos v k =
  if SM.mem v env.locals then reject pos "redeclaration of local '%s' (the calculus environment is flat)" v;
  if SM.mem v env.globals then reject pos "local '%s' shadows a global declaration" v;
  { env with locals = SM.add v k env.locals }

let rec lstmt env (s : P.stmt) : env * C.stmt =
  match s.ast with
  | P.LetStmt (v, _ty, rhs) ->
      let (p, rhs', k) = lexpr env rhs in
      let env = bind_local env s.pos v k in
      (env, seq (p @ [C.Assign (v, rhs')]))
  | P.Assign (lhs, rhs) ->
      begin match lhs.ast with
      | P.Id v when SM.mem v env.locals ->
          let (p, rhs', _) = lexpr env rhs in (env, seq (p @ [C.Assign (v, rhs')]))
      | P.Id v ->
          begin match lookup_global env lhs.pos v with
          | GAttr -> let (p, rhs', _) = lexpr env rhs in
              (env, seq (p @ [C.Add (C.QualAttr (sigma, v, rhs'))]))
          | _ -> reject lhs.pos "assignment target '%s' is neither a local nor an attribute" v
          end
      | P.FieldExp (base, f) ->
          let (pb, b', kb) = lexpr env base in
          if kb <> KState then reject lhs.pos "'.%s' assignment on a non-state value" f;
          begin match lookup_global env lhs.pos f with
          | GAttr -> let (p, rhs', _) = lexpr env rhs in
              (env, seq (pb @ p @ [C.Add (C.QualAttr (b', f, rhs'))]))
          | _ -> reject lhs.pos "'.%s' is not a declared attribute" f
          end
      | _ -> reject lhs.pos "unsupported assignment target"
      end
  | P.WhileLoop (c, body) ->
      let (p, c', _) = lexpr env c in
      let body' = lblock env body in
      (* the condition's prefix must be re-evaluated before every test *)
      (env, seq (p @ [C.While (c', seq [body'; seq p])]))
  | P.IfThenElse (c, thn, els) ->
      let (p, c', _) = lexpr env c in
      (env, seq (p @ [C.Cond (c', lblock env thn, lblock env els)]))
  | P.Return e ->
      let (p, e', _) = lexpr env e in (env, seq (p @ [C.Return e']))
  | P.Raise (name, args) ->
      begin match lookup_global env s.pos name with
      | GExc arity ->
          if List.length args <> arity then reject s.pos "exception '%s' expects %d arguments" name arity;
          let (ps, es) = List.split (List.map (fun a -> let (p, a', _) = lexpr env a in (p, a')) args) in
          (env, seq (List.concat ps @ [C.Raise (C.Pair (C.Literal (B.String name), tuple es))]))
      | _ -> reject s.pos "'%s' is not a declared exception" name
      end
  | P.TryCatch (body, catch, finally) ->
      let body' = lblock env body in
      let with_catch =
        match catch with
        | None -> body'
        | Some (exc, vars, cbody) ->
            begin match lookup_global env s.pos exc with
            | GExc arity ->
                if List.length vars <> arity then reject s.pos "catch %s binds %d names, exception has %d" exc (List.length vars) arity;
                let ex = fresh () in
                let n = List.length vars in
                let (cenv, binds) = List.fold_left (fun (env, acc) (i, v) ->
                    let env = bind_local env s.pos v KVal in
                    (env, acc @ [C.Assign (v, proj i n (C.Function (B.Snd, C.Variable ex)))]))
                    (env, []) (List.mapi (fun i v -> (i, v)) vars) in
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
      let (p, e', _) = lexpr env e in
      (env, seq (p @ [C.Cond (e', C.Pass,
                              C.Raise (C.Pair (C.Literal (B.String "AssertionFailure"), C.Literal B.Unit)))]))
  | P.Match _ -> reject s.pos "match/enums are outside the fragment"
  | P.ForLoop _ -> reject s.pos "for loops are outside the fragment"
  | P.Yield _ -> reject s.pos "yield is outside the fragment"
  | P.Localize _ -> reject s.pos "localize is outside the fragment"

and lblock env (stmts : P.stmt list) : C.stmt =
  let (_, acc) = List.fold_left (fun (env, acc) s ->
      let (env, s') = lstmt env s in (env, acc @ [s'])) (env, []) stmts in
  seq acc

type lowered = {
  globals : (string * string) list;        (* name, category *)
  fns : (string * C.stmt) list;            (* lowered action bodies *)
}

let category = function
  | GAttr -> "attribute" | GElem n -> Printf.sprintf "element/%d" n
  | GUninterp (_, n) -> Printf.sprintf "uninterpreted/%d" n
  | GFn (n, KState) -> Printf.sprintf "fn/%d->state" n
  | GFn (n, KVal) -> Printf.sprintf "fn/%d" n
  | GExc n -> Printf.sprintf "exception/%d" n

let lower_program (decls : P.decl list) : lowered =
  counter := 0;
  let add name g pos globals =
    if SM.mem name globals then reject pos "name '%s' declared twice" name;
    SM.add name g globals in
  let globals = List.fold_left (fun globals (d : P.decl) ->
      match d.ast with
      | P.Attribute { local = true; name; _ } -> reject d.pos "local attribute '%s' is outside the fragment" name
      | P.Element { local = true; name; _ } -> reject d.pos "local element '%s' is outside the fragment" name
      | P.Attribute { name; _ } -> add name GAttr d.pos globals
      | P.Element { name; ty; _ } -> add name (GElem (List.length ty)) d.pos globals
      | P.Exception { name; ty } -> add name (GExc (List.length ty)) d.pos globals
      | P.Type _ -> globals   (* aliases accepted; integer widths are not modelled *)
      | P.Uninterp { name; ty_args = _ :: _; _ } -> reject d.pos "generic uninterpreted '%s' is outside the fragment" name
      | P.Uninterp { name; args; _ } ->
          begin match List.find_opt (fun (n, _, _) -> n = name) Bytes_builtin.uninterp_table with
          | Some (_, f, arity) ->
              if List.length args <> arity then reject d.pos "uninterpreted '%s' declared with %d args; builtin table has %d" name (List.length args) arity;
              add name (GUninterp (f, arity)) d.pos globals
          | None -> reject d.pos "uninterpreted '%s' has no builtin interpretation in the documented table" name
          end
      | P.Function { name; ty_args = _ :: _; _ } -> reject d.pos "generic fn '%s' is outside the fragment" name
      | P.Function { name; args; ret; _ } -> add name (GFn (List.length args, kind_of_typ ret)) d.pos globals
      | P.Enum { name; _ } -> reject d.pos "enum '%s' is outside the fragment" name
      | P.Struct { name; _ } -> reject d.pos "struct '%s' is outside the fragment" name)
      SM.empty decls in
  let fns = List.filter_map (fun (d : P.decl) ->
      match d.ast with
      | P.Function { name; args; body; _ } ->
          let env = { globals; locals = SM.empty } in
          let n = List.length args in
          let (env, binds) = List.fold_left (fun (env, acc) (i, (v, ty)) ->
              let env = bind_local env d.pos v (kind_of_typ ty) in
              (env, acc @ [C.Assign (v, proj i n (C.Variable "ι"))]))
              (env, []) (List.mapi (fun i a -> (i, a)) args) in
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
