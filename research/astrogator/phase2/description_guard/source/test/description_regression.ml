module S = Fql.Semant.Semant(Fql.Knowledge.Example)
let analyze text =
  try S.analyze_top (Fql.Parser.query Fql.Lexer.token (Lexing.from_string text))
  with ex -> Error (Printexc.to_string ex)
let cases = [
 "canonical directory", "delete directory at /home/mydata/web", true;
 "canonical file", "delete file at \"/tmp/item.txt\"", true;
 "canonical contents", "delete files in /home/mydata/web", true;
 "misleading contents directory", "delete contents of directory at /home/mydata/web", false;
 "misleading contents file", "delete contents of file at \"/tmp/item.txt\"", false;
 "KB file without explicit path", "delete postfix configuration file", true;
 "KB directory without explicit path", "delete zsh configuration directory for user=foo", true;
 "KB file plus conflicting explicit path", "delete postfix configuration file at \"/tmp/other\"", false;
 "KB directory plus conflicting explicit path", "delete zsh configuration directory at /tmp/other for user=foo", false;
]
let () = List.iter (fun (label,q,expected) ->
 let got=analyze q in let ok=Result.is_ok got in
 if ok<>expected then (Printf.eprintf "FAIL %s: %s\n" label (match got with Ok _ -> "unexpected success"| Error e -> e);exit 1);
 Printf.printf "PASS %s\n" label
) cases
