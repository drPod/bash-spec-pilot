(* Thin diagnostic driver over unmodified upstream parser/semantic analyzer.
   Fingerprints compare AST structure, NOT denotational equivalence. *)
module Semant = Fql.Semant.Semant(Fql.Knowledge.Example)
let fingerprint x =
  try Digest.to_hex (Digest.string (Marshal.to_string x [Marshal.No_sharing]))
  with Invalid_argument _ -> "unavailable:functional_value"
let emit stage ok detail =
  Printf.printf "%s\t%s\t%s\n" stage (if ok then "ok" else "error")
    (String.escaped detail)
let () =
  let text = In_channel.with_open_text Sys.argv.(1) In_channel.input_all in
  try
    let parsed = Fql.Parser.query Fql.Lexer.token (Lexing.from_string text) in
    emit "parse" true (fingerprint parsed);
    if parsed = [] then (emit "nonempty" false "Empty query is vacuous"; exit 10);
    (match Semant.analyze_top parsed with
    | Error msg -> emit "semantic" false msg; exit 11
    | Ok q ->
        emit "semantic" true (fingerprint q);
        match Fql.Codegen.codegen_query q with
        | Error msg -> emit "codegen" false msg; exit 12
        | Ok _ -> emit "codegen" true "lowered to module language")
  with ex -> emit "exception" false (Printexc.to_string ex); exit 13
