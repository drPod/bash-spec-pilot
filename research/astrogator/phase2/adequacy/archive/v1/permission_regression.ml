(* Regression checks exercise actual FQL code generation, not a Python replica. *)
let p o g t : Fql.Ast.perm = { owner=o; group=g; other=t }
let empty : Fql.Ast.file_perms = {
  read=None; write=None; exec=None; file_list=None;
  setuid=None; setgid=None; sticky=None }
let mode perms =
  match Fql.Codegen.codegen_file_perms (Modules.Ast.Id "f") perms with
  | [] -> None
  | [Modules.Ast.Assign (_, Modules.Ast.StringLit s)] -> Some s
  | _ -> failwith "Unexpected permission code generation"
let cases = [
  "unspecified permissions preserve mode", empty, None;
  "owner only explicitly clears group and other",
    {empty with read=Some(p true false false);write=Some(p true false false);exec=Some(p true false false)}, Some "u=rwx,g=,o=";
  "directory search retains conditional X",
    {empty with read=Some(p true false false);write=Some(p true false false);file_list=Some(p true false false)}, Some "u=rwX,g=,o=";
  "group only explicitly clears owner and other",
    {empty with read=Some(p false true false)}, Some "u=,g=r,o=";
  "explicit empty permissions clear all classes",
    {empty with read=Some(p false false false)}, Some "u=,g=,o=";
  "explicit false special bit is not an unspecified mode",
    {empty with sticky=Some false}, Some "u=,g=,o=";
  "all classes remain represented",
    {empty with read=Some(p true true true);write=Some(p true true true);exec=Some(p true true true)}, Some "u=rwx,g=rwx,o=rwx";
  "special permissions retain their class",
    {empty with setuid=Some true;setgid=Some true;sticky=Some true}, Some "u=s,g=s,o=t";
]
let () = List.iter (fun (name, input, expected) ->
  let actual=mode input in
  if actual <> expected then failwith name;
  Printf.printf "PASS %s\n" name
) cases
