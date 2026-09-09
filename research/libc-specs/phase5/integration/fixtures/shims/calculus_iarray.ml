(* Compatibility shim (integration worker, 2026-09-07): OCaml 4.13.1 has no Stdlib.Iarray.
   Immutable-array subset used by generator.ml / semant.ml, implemented over Array. *)
type 'a t = 'a array
let of_list = Array.of_list
let of_seq = Array.of_seq
let length = Array.length
let get = Array.get
let init = Array.init
