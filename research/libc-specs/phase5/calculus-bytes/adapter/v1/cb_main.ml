(* calculus-bytes worker, 2026-09-07. Driver: pinned parser -> Lower -> pinned
   Calculus.Interp.InterpConcrete with the Bytes_builtin instance.

   Modes (one JSON object per line on stdout; exit status carries no claim):
     lower FILE...                 parse with the pinned parser, lower, print the
                                   lowered calculus (S-expressions) or the rejection
     run FILE ENTRY CASEFILE       parse+lower FILE, then for every case line
                                   `name<TAB>input_hex<TAB>reads<TAB>writes` run
                                   `Action("rc", ENTRY, ())` from a root state holding
                                   the byte streams and schedules; print observations *)

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

type parse_outcome =
  | Parsed of Ast.Parsed.decl list
  | LexError of string
  | ParseError of int * int

let parse_source (src : string) : parse_outcome =
  let lexbuf = Lexing.from_string src in
  try Parsed (Parser.program Lexer.token lexbuf) with
  | Lexer.LexerError msg -> LexError msg
  | Invalid_argument msg | Failure msg -> LexError ("uncaught lexer/parser exception: " ^ msg)
  | Parser.Error ->
      let p = lexbuf.Lexing.lex_start_p in
      ParseError (p.Lexing.pos_lnum, p.Lexing.pos_cnum - p.Lexing.pos_bol + 1)

let pos_fields ((p, _) : Lexing.position * Lexing.position) =
  [ "line", string_of_int p.Lexing.pos_lnum;
    "column", string_of_int (p.Lexing.pos_cnum - p.Lexing.pos_bol + 1) ]

type lower_outcome =
  | Lowered of Lower.lowered
  | Rejected of (Lexing.position * Lexing.position) * string
  | NotParsed of (string * string) list

let lower_file file =
  match parse_source (read_file file) with
  | Parsed decls ->
      (try Lowered (Lower.lower_program decls)
       with Lower.Unsupported (pos, msg) -> Rejected (pos, msg))
  | LexError msg -> NotParsed [ "outcome", json_string "lexer_error"; "message", json_string msg ]
  | ParseError (l, c) ->
      NotParsed [ "outcome", json_string "parse_error"; "line", string_of_int l; "column", string_of_int c ]

let lower_fields = function
  | Lowered l ->
      [ "outcome", json_string "lowered";
        "globals", json_list (List.map (fun (n, c) -> json_obj [ "name", json_string n; "category", json_string c ]) l.Lower.globals);
        "fns", json_list (List.map (fun (n, s) ->
            let text = Lower.show_stmt s in
            json_obj [ "name", json_string n; "calculus", json_string text;
                       "calculus_md5", json_string (Digest.to_hex (Digest.string text)) ]) l.Lower.fns) ]
  | Rejected (pos, msg) -> [ "outcome", json_string "rejected"; "reason", json_string msg ] @ pos_fields pos
  | NotParsed fields -> fields

let lower_mode files =
  List.iter (fun file ->
    print_endline (json_obj ([ "mode", json_string "lower"; "file", json_string file ] @ lower_fields (lower_file file))))
    files

(* ---------------- run mode ---------------- *)

module D = Bytes_builtin.Defs
module I = Bytes_builtin.I
module V = D.V
module C = D.C
module B = Bytes_builtin.B

let hex_of_bytes xs =
  String.concat "" (List.map (fun b -> Printf.sprintf "%02x" b) xs)
let bytes_of_hex h =
  List.init (String.length h / 2) (fun i -> int_of_string ("0x" ^ String.sub h (2 * i) 2))
let ints_of_csv s =
  if s = "" then [] else List.map int_of_string (String.split_on_char ',' s)

let attr_json (v : V.t) =
  match D.as_ints v with
  | Some xs when List.for_all (fun b -> 0 <= b && b <= 255) xs -> json_obj [ "hex", json_string (hex_of_bytes xs); "len", string_of_int (List.length xs) ]
  | Some xs -> json_list (List.map string_of_int xs)
  | None -> (match v with
      | V.Literal (B.Int i) -> string_of_int i
      | V.Literal (B.Bool b) -> string_of_bool b
      | v -> json_string (V.string_of_value v))

let state_json (st : I.S.t) =
  let attrs = List.map (fun (k, v) -> (k, attr_json v)) (I.S.extract_attributes st) in
  let elems = List.map (fun ((elem, v), nested) ->
      json_obj [ "element", json_string elem; "arg", json_string (V.string_of_value v);
                 "attrs", json_obj (List.map (fun (k, v) -> (k, attr_json v)) (I.S.extract_attributes nested)) ])
      (I.S.extract_elements st) in
  [ "attrs", json_obj attrs; "elements", json_list elems ]

let initial_state input reads writes =
  let set st name v = match I.S.set_attr st V.Here name v with Some st -> st | None -> failwith "set_attr" in
  let st = I.S.empty_state () in
  let st = set st "input" (D.of_ints input) in
  let st = set st "delivered" (D.of_ints []) in
  let st = set st "lost" (D.of_ints []) in
  let st = set st "reads" (D.of_ints reads) in
  let st = set st "writes" (D.of_ints writes) in
  let st = set st "read_calls" (D.int 0) in
  set st "write_calls" (D.int 0)

let run_case entry name input reads writes =
  let st = initial_state input reads writes in
  let program = C.Action ("rc", entry, C.Literal B.Unit) in
  let res = I.interp program I.init_env st in
  let fields =
    match res with
    | I.Continue (env, st) ->
        let rc = match I.VarMap.find_opt "rc" env with
          | Some (V.Literal (B.Int n)) -> string_of_int n | _ -> "null" in
        [ "outcome", json_string "continue"; "rc", rc ] @ state_json st
    | I.Raise (v, _, st) -> [ "outcome", json_string "raise"; "value", json_string (V.string_of_value v) ] @ state_json st
    | I.Return (v, _, st) -> [ "outcome", json_string "return"; "value", json_string (V.string_of_value v) ] @ state_json st
    | I.Yield (v, _, st) -> [ "outcome", json_string "yield"; "value", json_string (V.string_of_value v) ] @ state_json st
    | I.Failure -> [ "outcome", json_string "failure" ] in
  print_endline (json_obj ([ "mode", json_string "run"; "entry", json_string entry; "name", json_string name;
                             "input_hex", json_string (hex_of_bytes input);
                             "reads", json_list (List.map string_of_int reads);
                             "writes", json_list (List.map string_of_int writes) ] @ fields))

let run_mode file entry casefile =
  match lower_file file with
  | Lowered l ->
      Hashtbl.reset D.acts;
      List.iter (fun (n, s) -> Hashtbl.replace D.acts n s) l.Lower.fns;
      if not (Hashtbl.mem D.acts entry) then begin
        print_endline (json_obj [ "mode", json_string "run"; "file", json_string file;
                                  "outcome", json_string "no_such_entry"; "entry", json_string entry ]);
        exit 3
      end;
      print_endline (json_obj ([ "mode", json_string "lower"; "file", json_string file ] @ lower_fields (Lowered l)));
      let lines = String.split_on_char '\n' (read_file casefile) in
      List.iter (fun line ->
        if String.trim line <> "" && line.[0] <> '#' then
          match String.split_on_char '\t' line with
          | [ name; hex; reads; writes ] ->
              (try run_case entry name (bytes_of_hex hex) (ints_of_csv reads) (ints_of_csv writes)
               with Failure msg ->
                 print_endline (json_obj [ "mode", json_string "run"; "entry", json_string entry; "name", json_string name;
                                           "outcome", json_string "ocaml_exception"; "message", json_string msg ]))
          | _ -> prerr_endline ("bad case line: " ^ line); exit 2) lines
  | other ->
      print_endline (json_obj ([ "mode", json_string "lower"; "file", json_string file ] @ lower_fields other));
      exit 4

let () =
  match Array.to_list Sys.argv with
  | _ :: "lower" :: files -> lower_mode files
  | [ _; "run"; file; entry; casefile ] -> run_mode file entry casefile
  | _ -> prerr_endline "usage: cb_main (lower FILE... | run FILE ENTRY CASEFILE)"; exit 2
