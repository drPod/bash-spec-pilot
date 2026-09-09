(* Compatibility shim (integration worker, 2026-09-07): List.is_empty is OCaml >= 5.1. *)
include Stdlib.List
let is_empty = function [] -> true | _ :: _ -> false
