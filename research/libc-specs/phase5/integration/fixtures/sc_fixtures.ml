(* Integration fixtures for the pinned state_based `bash` branch
   (commit 190dd8491b258d8a0ee29f79629908540236b332), 2026-09-07.

   Modes:
     parse OUTDIR FILE...   run the actual pinned lexer/parser (Frontend.Runner /
                            Frontend.Parser.program / Frontend.Lexer.token) and the
                            pinned pretty-printer; check print/parse fixpoint.
     semant FILE...         run the pinned Frontend.Semant.analyze_program.
     interp                 run shell-fragment programs through the pinned
                            Calculus.Interp.InterpConcrete with a small builtin
                            instance defined below (the builtin instance is ours).
   Output: one JSON object per line on stdout. No verification claim is made by
   exit status; outputs are compared externally. *)

open Frontend

let read_file f =
  let ic = open_in_bin f in
  let n = in_channel_length ic in
  let s = really_input_string ic n in
  close_in ic; s

let json_string s =
  let b = Buffer.create (String.length s + 2) in
  Buffer.add_char b '"';
  String.iter (fun c ->
    match c with
    | '"' -> Buffer.add_string b "\\\""
    | '\\' -> Buffer.add_string b "\\\\"
    | '\n' -> Buffer.add_string b "\\n"
    | '\r' -> Buffer.add_string b "\\r"
    | '\t' -> Buffer.add_string b "\\t"
    | c when Char.code c < 0x20 -> Buffer.add_string b (Printf.sprintf "\\u%04x" (Char.code c))
    | c -> Buffer.add_char b c) s;
  Buffer.add_char b '"';
  Buffer.contents b

let json_obj fields =
  "{" ^ String.concat ", " (List.map (fun (k, v) -> json_string k ^ ": " ^ v) fields) ^ "}"

let json_list xs = "[" ^ String.concat ", " xs ^ "]"

(* ---------------- parse mode ---------------- *)

type parse_outcome =
  | Parsed of Ast.Parsed.decl list
  | LexError of string
  | ParseError of int * int (* line, column at the failing token *)

let parse_source (src : string) : parse_outcome =
  let lexbuf = Lexing.from_string src in
  try Parsed (Parser.program Lexer.token lexbuf) with
  | Lexer.LexerError msg -> LexError msg
  | Invalid_argument msg | Failure msg ->
      (* e.g. the pinned lexer hands a suffixed lexeme such as "0u64" to Stdint's
         of_string, which raises Invalid_argument instead of LexerError *)
      LexError ("uncaught lexer/parser exception: " ^ msg)
  | Parser.Error ->
      let p = lexbuf.Lexing.lex_start_p in
      ParseError (p.Lexing.pos_lnum, p.Lexing.pos_cnum - p.Lexing.pos_bol + 1)

let decl_kind (d : Ast.Parsed.decl) =
  match d.ast with
  | Enum { name; _ } -> "enum " ^ name
  | Struct { name; _ } -> "struct " ^ name
  | Type { name; _ } -> "type " ^ name
  | Uninterp { name; _ } -> "uninterpreted " ^ name
  | Attribute { name; _ } -> "attribute " ^ name
  | Element { name; _ } -> "element " ^ name
  | Exception { name; _ } -> "exception " ^ name
  | Function { name; body; _ } -> Printf.sprintf "fn %s (%d stmts)" name (List.length body)

let parse_file outdir file =
  let src = read_file file in
  (* Primary path: the pinned entry point used by bin/main.ml. *)
  let via_runner =
    try ignore (Runner.parse_string src); "parsed" with
    | Lexer.LexerError _ -> "lexer_error"
    | Parser.Error -> "parse_error"
    | e -> "exception " ^ Printexc.to_string e in
  let base = Filename.remove_extension (Filename.basename file) in
  let fields =
    match parse_source src with
    | Parsed decls ->
        let printed = Format.string_of_ast decls in
        let out = Filename.concat outdir (base ^ ".printed.sc") in
        let oc = open_out_bin out in output_string oc printed; close_out oc;
        let fixpoint =
          match parse_source printed with
          | Parsed decls2 -> Some (Format.string_of_ast decls2 = printed)
          | _ -> None in
        [ "outcome", json_string "parsed";
          "decls", string_of_int (List.length decls);
          "decl_kinds", json_list (List.map (fun d -> json_string (decl_kind d)) decls);
          "printed_file", json_string out;
          "printed_bytes", string_of_int (String.length printed);
          "reparse_of_printed", (match fixpoint with
             | None -> json_string "parse_error_on_printed_output"
             | Some true -> json_string "fixpoint"
             | Some false -> json_string "printed_twice_differs") ]
    | LexError msg -> [ "outcome", json_string "lexer_error"; "message", json_string msg ]
    | ParseError (l, c) ->
        [ "outcome", json_string "parse_error"; "line", string_of_int l; "column", string_of_int c ]
  in
  print_endline (json_obj ([ "mode", json_string "parse"; "file", json_string file;
                             "runner_parse_string", json_string via_runner ] @ fields))

(* ---------------- semant mode ---------------- *)

let rec err_messages (e : Semant.err_msg) acc =
  match e with
  | Semant.Leaf { pos = (p, _); msg } ->
      json_obj [ "line", string_of_int p.Lexing.pos_lnum;
                 "column", string_of_int (p.Lexing.pos_cnum - p.Lexing.pos_bol + 1);
                 "message", json_string msg ] :: acc
  | Semant.Node (a, b) -> err_messages a (err_messages b acc)

let semant_file file =
  let src = read_file file in
  let fields =
    match parse_source src with
    | Parsed decls ->
        (try
           match Semant.analyze_program decls with
           | Semant.Ok _ -> [ "outcome", json_string "ok" ]
           | Semant.Err (_, es) ->
               [ "outcome", json_string "errors"; "errors", json_list (err_messages es []) ]
         with
         | Failure msg -> [ "outcome", json_string "exception"; "exception", json_string ("Failure " ^ msg) ]
         | Not_found -> [ "outcome", json_string "exception"; "exception", json_string "Not_found" ]
         | Stack_overflow -> [ "outcome", json_string "exception"; "exception", json_string "Stack_overflow" ])
    | LexError msg -> [ "outcome", json_string "lexer_error"; "message", json_string msg ]
    | ParseError (l, c) ->
        [ "outcome", json_string "parse_error"; "line", string_of_int l; "column", string_of_int c ]
  in
  print_endline (json_obj ([ "mode", json_string "semant"; "file", json_string file ] @ fields))

(* ---------------- interp mode ---------------- *)

(* Our builtin instance. The pinned interpreter is a functor over builtins; this
   instance is integration-worker code and is a trusted boundary of the fixture. *)
module B = struct
  type lit = Unit | Bool of bool | Int of int | String of string
  type func = Eq | ConcatStr
  type act = RelayOk | RelayLateError | Mark | NoReturn
  let string_of_lit = function
    | Unit -> "()" | Bool b -> string_of_bool b | Int i -> string_of_int i | String s -> s
end

module Defs = struct
  type func = B.func
  type act = B.act
  module V = Calculus.Value.Value (B)
  type v = V.t
  module C = Calculus.Ast.Ast (B)
  type stmt = C.stmt

  let as_bool = function V.Literal (B.Bool b) -> Some b | _ -> None
  let rec as_list = function
    | V.Left (V.Literal B.Unit) -> Some []
    | V.Right (V.Pair (hd, tl)) -> Option.map (fun tl -> hd :: tl) (as_list tl)
    | _ -> None
  let rec of_list = function
    | [] -> V.Left (V.Literal B.Unit)
    | hd :: tl -> V.Right (V.Pair (hd, of_list tl))

  let func_def (f : B.func) : v -> v option =
    match f with
    | B.Eq -> (function
        | V.Pair (V.Literal x, V.Literal y) -> Some (V.Literal (B.Bool (x = y)))
        | _ -> None)
    | B.ConcatStr -> (function
        | V.Pair (V.Literal (B.String x), V.Literal (B.String y)) -> Some (V.Literal (B.String (x ^ y)))
        | _ -> None)

  let sigma = C.Variable "σ"
  (* stdout := stdout ^ s, reading the attribute through the pinned Get/Add statements *)
  let append_stdout s =
    C.Seq (C.Get ("cur", (sigma, "stdout")),
           C.Add (C.QualAttr (sigma, "stdout",
                              C.Function (B.ConcatStr, C.Pair (C.Variable "cur", C.Literal (B.String s))))))
  let act_def : act -> stmt = function
    | B.RelayOk -> C.Seq (append_stdout "abc", C.Return (C.Literal (B.Int 0)))
    | B.RelayLateError -> C.Seq (append_stdout "abc", C.Return (C.Literal (B.Int 1)))
    | B.Mark -> C.Seq (append_stdout "!", C.Return (C.Literal (B.Int 0)))
    | B.NoReturn -> append_stdout "?"   (* falls off the end: pinned interp yields Failure *)
end

module I = Calculus.Interp.InterpConcrete (B) (Defs)
module C = Defs.C

type cmd = Call of B.act | Seq of cmd * cmd | And of cmd * cmd | Or of cmd * cmd

let rec cmd_text = function
  | Call B.RelayOk -> "relay_ok"
  | Call B.RelayLateError -> "relay_late_error"
  | Call B.Mark -> "mark"
  | Call B.NoReturn -> "noreturn"
  | Seq (a, b) -> "(" ^ cmd_text a ^ " ; " ^ cmd_text b ^ ")"
  | And (a, b) -> "(" ^ cmd_text a ^ " && " ^ cmd_text b ^ ")"
  | Or (a, b) -> "(" ^ cmd_text a ^ " || " ^ cmd_text b ^ ")"

let rc_zero = C.Function (B.Eq, C.Pair (C.Variable "rc", C.Literal (B.Int 0)))

(* Encoding of the phase3 ShellObservation.Command grammar into pinned calculus
   statements: the exit status lives in variable "rc". *)
let rec encode = function
  | Call a -> C.Action ("rc", a, C.Literal B.Unit)
  | Seq (a, b) -> C.Seq (encode a, encode b)
  | And (a, b) -> C.Seq (encode a, C.Cond (rc_zero, encode b, C.Pass))
  | Or (a, b) -> C.Seq (encode a, C.Cond (rc_zero, C.Pass, encode b))

let program c = C.Seq (C.Add (C.QualAttr (Defs.sigma, "stdout", C.Literal (B.String ""))), encode c)

let run_program name text (p : C.stmt) =
  let res = I.interp p I.init_env (I.S.empty_state ()) in
  let state_fields st =
    let attrs = I.S.extract_attributes st in
    [ "attrs", json_list (List.map (fun (k, v) -> json_obj [ k, json_string (Defs.V.string_of_value v) ]) attrs) ] in
  let fields =
    match res with
    | I.Continue (env, st) ->
        let rc = match I.VarMap.find_opt "rc" env with
          | Some (Defs.V.Literal (B.Int n)) -> string_of_int n | _ -> "null" in
        [ "outcome", json_string "continue"; "rc", rc ] @ state_fields st
    | I.Raise (v, _, st) -> [ "outcome", json_string "raise"; "value", json_string (Defs.V.string_of_value v) ] @ state_fields st
    | I.Return (v, _, st) -> [ "outcome", json_string "return"; "value", json_string (Defs.V.string_of_value v) ] @ state_fields st
    | I.Yield (v, _, st) -> [ "outcome", json_string "yield"; "value", json_string (Defs.V.string_of_value v) ] @ state_fields st
    | I.Failure -> [ "outcome", json_string "failure" ]
  in
  print_endline (json_obj ([ "mode", json_string "interp"; "name", json_string name;
                             "command", json_string text ] @ fields))

let ok = Call B.RelayOk and late = Call B.RelayLateError and mark = Call B.Mark

let interp_fixtures () =
  let cases = [
    "call_ok", ok;
    "call_late_error", late;
    "and_ok_mark", And (ok, mark);
    "and_late_mark", And (late, mark);
    "or_late_mark", Or (late, mark);
    "or_ok_mark", Or (ok, mark);
    "seq_late_mark", Seq (late, mark);
    "and_or_nested", And (Or (late, mark), ok);
    "and_late_nested", And (late, Or (mark, ok));
    "seq_ok_late", Seq (ok, late);
    "seq_seq_and", Seq (Seq (ok, late), And (ok, mark));
  ] in
  List.iter (fun (n, c) -> run_program n (cmd_text c) (program c)) cases;
  (* negative controls on the pinned interpreter itself *)
  run_program "control_noreturn_action" "noreturn" (program (Call B.NoReturn));
  run_program "control_cond_nonbool" "if (nonbool)"
    (C.Cond (C.Literal (B.Int 3), C.Pass, C.Pass));
  run_program "control_get_missing_attr" "get missing"
    (C.Get ("x", (Defs.sigma, "stdout")));
  run_program "control_unbound_variable" "rc unbound"
    (C.Cond (rc_zero, C.Pass, C.Pass))

let () =
  match Array.to_list Sys.argv with
  | _ :: "parse" :: outdir :: files -> List.iter (parse_file outdir) files
  | _ :: "semant" :: files -> List.iter semant_file files
  | _ :: "interp" :: _ -> interp_fixtures ()
  | _ -> prerr_endline "usage: sc_fixtures (parse OUTDIR FILE... | semant FILE... | interp)"; exit 2
