(* print_ast.ml -- S-expression printer for the pinned frontend's PARSED spec-language AST
   (calculus-correspondence-61, 2026-09-08). Companion to `cb_main.exe lower`: where `lower`
   prints the OUTPUT of the bounded lowering (`Lower.show_stmt`), this prints its INPUT
   (`Ast.Parsed`), so the Lean model of the lowering (`integration/lean/CalculusLowering.lean`)
   can be checked against a machine-produced spec AST instead of a hand encoding.

   Status (session -75, 2026-09-08): every constructor and record field below was checked
   against the pinned `bash-verifier/lib/frontend/ast.ml` (sha256 eeff5471…, identical in the
   shared container and the host clone): `Parsed.annt = {ast; pos}`, `typ_base`, `expr_base`,
   `stmt_base`, `decl_base` records `Attribute{local;name;ty}`, `Element{local;name;ty}`,
   `Exception{name;ty}`, `Type{name;def}`, `Uninterp{name;ty_args;args;ret}`,
   `Function{name;ty_args;args;ret;body}`. Built and run in a private staging tree (receipts in
   calculus-correspondence-75).
   Only the SUPPORTED fragment is printed faithfully; every other constructor prints
   `(unsupported <tag>)` so the Lean side fails closed (its `Decl`/`SExpr`/`SStmt` have no such
   constructor). Build: drop this file next to `cb_main.ml` in the PRIVATE staging tree created
   by `setup_private_build.sh` (never the shared container original), add it to the dune
   executable, run via `run_vst.py` under the shared compiler lock. *)

open Frontend
module P = Ast.Parsed

let esc s =
  let b = Buffer.create (String.length s + 2) in
  Buffer.add_char b '"';
  String.iter (fun c -> match c with
    | '"' -> Buffer.add_string b "\\\""
    | '\\' -> Buffer.add_string b "\\\\"
    | c -> Buffer.add_char b c) s;
  Buffer.add_char b '"';
  Buffer.contents b

let rec show_typ (t : P.typ) : string =
  match t.ast with
  | P.Bool -> "bool" | P.Void -> "void"
  | P.SInt8 -> "i8" | P.UInt8 -> "u8" | P.SInt16 -> "i16" | P.UInt16 -> "u16"
  | P.SInt32 -> "i32" | P.UInt32 -> "u32" | P.SInt64 -> "i64" | P.UInt64 -> "u64"
  | P.StateRef -> "state"
  | P.List t -> Printf.sprintf "(list %s)" (show_typ t)
  | P.Named (n, []) -> Printf.sprintf "(named %s)" (esc n)
  | _ -> "(unsupported typ)"

let binop = function
  | P.Add -> "+" | P.Sub -> "-" | P.Mul -> "*" | P.Div -> "/" | P.Mod -> "%"
  | P.Lt -> "<" | P.Le -> "<=" | P.Gt -> ">" | P.Ge -> ">=" | P.Eq -> "==" | P.Ne -> "!="
  | P.LAnd -> "&&" | P.LOr -> "||"
  | _ -> "unsupported-binop"

(* polymorphic: defined outside the recursive group so it can be used at both expr and stmt *)
let show_list : 'a. ('a -> string) -> 'a list -> string =
  fun f xs -> "(" ^ String.concat " " (List.map f xs) ^ ")"

let rec show_expr (e : P.expr) : string =
  match e.ast with
  | P.Id v -> Printf.sprintf "(var %s)" (esc v)
  | P.BoolLit b -> Printf.sprintf "(bool %b)" b
  | P.UnitLit -> "unit"
  | P.CharLit c -> Printf.sprintf "(int %d)" (Char.code c)
  | P.Int8Lit i -> Printf.sprintf "(int %d)" (Stdint.Int8.to_int i)
  | P.Int16Lit i -> Printf.sprintf "(int %d)" (Stdint.Int16.to_int i)
  | P.Int32Lit i -> Printf.sprintf "(int %d)" (Stdint.Int32.to_int i)
  | P.Int64Lit i -> Printf.sprintf "(int %s)" (Stdint.Int64.to_string i)
  | P.UInt8Lit i -> Printf.sprintf "(int %d)" (Stdint.Uint8.to_int i)
  | P.UInt16Lit i -> Printf.sprintf "(int %d)" (Stdint.Uint16.to_int i)
  | P.UInt32Lit i -> Printf.sprintf "(int %s)" (Stdint.Uint32.to_string i)
  | P.UInt64Lit i -> Printf.sprintf "(int %s)" (Stdint.Uint64.to_string i)
  | P.UnaryExp (P.Neg, x) -> Printf.sprintf "(neg %s)" (show_expr x)
  | P.UnaryExp (P.LNot, x) -> Printf.sprintf "(lnot %s)" (show_expr x)
  | P.BinaryExp (l, op, r) -> Printf.sprintf "(binop %s %s %s)" (binop op) (show_expr l) (show_expr r)
  | P.FieldExp (b, f) -> Printf.sprintf "(field %s %s)" (show_expr b) (esc f)
  | P.FuncExp (f, [], args) ->
      begin match f.ast with
      | P.Id name -> Printf.sprintf "(call %s %s)" (esc name) (show_list show_expr args)
      | P.FieldExp (b, name) -> Printf.sprintf "(field-call %s %s %s)" (show_expr b) (esc name) (show_list show_expr args)
      | _ -> "(unsupported call)"
      end
  | P.Exists x -> Printf.sprintf "(exists %s)" (show_expr x)
  | _ -> "(unsupported expr)"

let rec show_stmt (s : P.stmt) : string =
  match s.ast with
  | P.LetStmt (v, None, rhs) -> Printf.sprintf "(let %s _ %s)" (esc v) (show_expr rhs)
  | P.LetStmt (v, Some ty, rhs) -> Printf.sprintf "(let %s %s %s)" (esc v) (show_typ ty) (show_expr rhs)
  | P.Assign (lhs, rhs) -> Printf.sprintf "(assign %s %s)" (show_expr lhs) (show_expr rhs)
  | P.WhileLoop (c, body) -> Printf.sprintf "(while %s %s)" (show_expr c) (show_list show_stmt body)
  | P.IfThenElse (c, t, e) -> Printf.sprintf "(if %s %s %s)" (show_expr c) (show_list show_stmt t) (show_list show_stmt e)
  | P.Return e -> Printf.sprintf "(return %s)" (show_expr e)
  | P.Raise (name, args) -> Printf.sprintf "(raise %s %s)" (esc name) (show_list show_expr args)
  | P.TryCatch (body, catch, fin) ->
      let c = match catch with
        | None -> "none"
        | Some (exc, vars, cbody) ->
            Printf.sprintf "(catch %s %s %s)" (esc exc) (show_list esc vars) (show_list show_stmt cbody) in
      Printf.sprintf "(try %s %s %s)" (show_list show_stmt body) c (show_list show_stmt fin)
  | P.Touch e -> Printf.sprintf "(touch %s)" (show_expr e)
  | P.Clear e -> Printf.sprintf "(clear %s)" (show_expr e)
  | P.Assert e -> Printf.sprintf "(assert %s)" (show_expr e)
  | _ -> "(unsupported stmt)"

let show_decl (d : P.decl) : string =
  match d.ast with
  | P.Attribute { local = false; name; ty; _ } -> Printf.sprintf "(attribute %s %s)" (esc name) (show_typ ty)
  | P.Element { local = false; name; ty; _ } -> Printf.sprintf "(element %s %s)" (esc name) (show_list show_typ ty)
  | P.Exception { name; ty } -> Printf.sprintf "(exception %s %s)" (esc name) (show_list show_typ ty)
  | P.Type { name; def } -> Printf.sprintf "(type %s %s)" (esc name) (show_typ def)
  | P.Uninterp { name; ty_args = []; args; ret; _ } ->
      Printf.sprintf "(uninterp %s %s %s)" (esc name) (show_list show_typ args) (show_typ ret)
  | P.Function { name; ty_args = []; args; ret; body; _ } ->
      Printf.sprintf "(function %s %s %s %s)" (esc name)
        (show_list (fun (v, t) -> Printf.sprintf "(%s %s)" (esc v) (show_typ t)) args)
        (show_typ ret) (show_list show_stmt body)
  | _ -> "(unsupported decl)"

(* Usage: print_ast FILE -- one S-expression per declaration, in file order. The parse entry is
   the same one `cb_main.ml`'s `parse_source` uses: `Parser.program Lexer.token` over the file
   text (`open Frontend` at the top of this file). *)
let () =
  match Array.to_list Sys.argv with
  | [ _; file ] ->
      let ic = open_in_bin file in
      let src = really_input_string ic (in_channel_length ic) in
      close_in ic;
      let decls = Parser.program Lexer.token (Lexing.from_string src) in
      List.iter (fun d -> print_endline (show_decl d)) decls
  | _ -> prerr_endline "usage: print_ast FILE"; exit 2
