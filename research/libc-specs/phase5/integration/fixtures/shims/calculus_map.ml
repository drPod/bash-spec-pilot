(* Compatibility shim (integration worker, 2026-09-07): Map.S.of_list / to_list are OCaml >= 5.1. *)
module type OrderedType = Stdlib.Map.OrderedType
module type S = sig
  include Stdlib.Map.S
  val of_list : (key * 'a) list -> 'a t
  val to_list : 'a t -> (key * 'a) list
end
module Make (Ord : OrderedType) : S with type key = Ord.t = struct
  include Stdlib.Map.Make (Ord)
  let of_list l = Stdlib.List.fold_left (fun m (k, v) -> add k v m) empty l
  let to_list = bindings
end
