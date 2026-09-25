let () =
  try while true do
    let line=read_line () in
    match String.split_on_char '\t' line with
    | [kind; mode] ->
      let result=if kind="integer" then Modules.Permission_mode.integer (int_of_string mode)
        else Modules.Permission_mode.normalize ~directory:(kind="directory") mode in
      print_endline (Option.value result ~default:"DECLINED")
    | _ -> failwith "Expected kind<TAB>mode"
  done with End_of_file -> ()
