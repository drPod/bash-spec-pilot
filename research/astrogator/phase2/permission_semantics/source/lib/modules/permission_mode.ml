(* Opt-in integration switch; the normalizer itself is a pure function. *)
let enabled = ref false

(* A deliberately partial normalizer for constant, state-independent modes.
   None means retain the original representation, not that the input is invalid.
   X is constant only when every affected object is known to be a directory. *)
let normalize ?(directory=false) (s : string) : string option =
  let len=String.length s in
  let octal = len >= 3 && len <= 4 &&
    String.for_all (fun c -> c >= '0' && c <= '7') s in
  if octal then Some (Printf.sprintf "%04o" (int_of_string ("0o" ^ s)))
  else
    let parts=String.split_on_char ',' s in
    if List.length parts <> 3 then None
    else
      let seen=Hashtbl.create 3 in
      let bits=ref 0 in
      let valid=List.for_all (fun part ->
        if String.length part < 2 || part.[1] <> '=' then false
        else
          let who=part.[0] in
          if not (List.mem who ['u';'g';'o']) || Hashtbl.mem seen who
          then false
          else begin
            Hashtbl.add seen who ();
            let shift=if who='u' then 6 else if who='g' then 3 else 0 in
            let perms=String.sub part 2 (String.length part-2) in
            String.for_all (fun c ->
              let mask=match c with
                | 'r' -> Some (4 lsl shift)
                | 'w' -> Some (2 lsl shift)
                | 'x' -> Some (1 lsl shift)
                | 'X' when directory -> Some (1 lsl shift)
                | 's' when who='u' -> Some 0o4000
                | 's' when who='g' -> Some 0o2000
                | 't' when who='o' -> Some 0o1000
                | _ -> None
              in match mask with
              | None -> false
              | Some n -> bits := !bits lor n; true
            ) perms
          end
      ) parts in
      if valid then Some (Printf.sprintf "%04o" !bits) else None

let integer (n : int) : string option =
  if n < 0 || n > 0o7777 then None else Some (Printf.sprintf "%04o" n)
