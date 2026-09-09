(* calculus-bytes worker, 2026-09-07 (v1); calculus-resume-2 worker, 2026-09-07 (v2).
   Builtin instance for the pinned Calculus.Interp functor
   (counc009/state_based@190dd849, bash-verifier/lib/calculus). v1 is kept verbatim in v1/.

   THIS FILE IS WORKER CODE AND A TRUSTED BOUNDARY. The pinned interpreter is a
   functor over BUILTIN; it fixes statement semantics (Seq/While/Cond/Action/
   Get/Add/Raise/TryCatch/...), but literals, pure functions and action bodies
   are supplied here. Every pure function below is total on well-typed input and
   returns None (which the pinned interpreter turns into Failure) otherwise.

   INTEGER SEMANTICS (v2, the adapter's chosen semantics, NOT a claim about the
   upstream analyzer, which is unimplemented at the pinned commit):
   - The carrier is the OCaml native int of the build host: 63-bit two's complement,
     [min_int, max_int] = [-2^62, 2^62-1]. v1 documented "unbounded ints"; that was
     false (OCaml + wraps). v2 makes every arithmetic operation TRAP (None -> Failure)
     when the mathematical result leaves the carrier: no wraparound anywhere.
   - Declared widths (u8..u64, i8..i64) are enforced by the lowering as range
     assertions (`Range`/`RangeList`) at every annotated sink and source: typed let,
     local re-assignment, attribute assignment, fn parameter and return, element
     argument, exception payload, uninterpreted argument/result. A value outside the
     declared range traps; it never wraps. i64 denotes the carrier itself; u64 denotes
     [0, max_int] (the carrier cannot hold 2^62..2^64-1: such values trap, which is
     explicit and checked, not silent).
   - Division truncates toward zero (OCaml `/`, `mod`); divisor 0 traps; min_int / -1 traps.

   Byte lists use the calculus' own list encoding (Left () = nil,
   Right (hd, tl) = cons) with each element Literal (Int b), 0 <= b <= 255.
   Range checks happen where bytes are constructed (single, append, take,
   drop, slice check every element of every list they touch) and, in v2, at every
   sink declared `list::<u8>` via RangeList. *)

module B = struct
  type lit = Unit | Bool of bool | Int of int | String of string
  type func =
    (* integer arithmetic / comparison, on Pair (Int, Int); trapping on carrier overflow *)
    | Add | Sub | Mul | Div | Mod | Lt | Le | Gt | Ge
    (* structural equality on literals *)
    | Eq | Ne
    (* booleans / negation *)
    | Neg | LNot | LAnd | LOr
    (* pair projections used for argument tuples and exception payloads *)
    | Fst | Snd
    (* exception tag test: Pair (String tag, payload) *)
    | ExcTag of string
    (* v2: declared-width range assertions inserted by the lowering *)
    | Range of int * int          (* Int n with lo <= n <= hi, else trap *)
    | RangeList of int * int      (* list of Int, every element in range, else trap *)
    (* byte-list / schedule-list primitives (the `uninterpreted` table) *)
    | Length | Take | Drop | Slice | Append | Single | Empty
    | HeadOr | Tail | Min | Max
  (* actions are the lowered spec-language `fn` bodies, by name *)
  type act = string
  let string_of_lit = function
    | Unit -> "()" | Bool b -> string_of_bool b
    | Int i -> string_of_int i | String s -> "\"" ^ String.escaped s ^ "\""
end

(* Mapping from `uninterpreted` declaration names in a spec-language source to
   builtin pure functions. Any other uninterpreted name is rejected by Lower.
   The declared signature in the source is type-checked by Lower against the
   builtin's expected shape (v2). *)
let uninterp_table : (string * B.func * int) list = [
  (* name, function, arity *)
  "length", B.Length, 1;      (* list::<u8> -> int *)
  "take",   B.Take,   2;      (* (xs, n) -> first n (0 <= n <= |xs|) *)
  "drop",   B.Drop,   2;      (* (xs, n) -> all but first n *)
  "slice",  B.Slice,  3;      (* (xs, off, n) -> xs[off, n) with 0<=off<=n<=|xs| *)
  "append", B.Append, 2;      (* (xs, ys) -> xs @ ys *)
  "single", B.Single, 1;      (* b -> [b], 0 <= b <= 255 *)
  "empty",  B.Empty,  0;      (* () -> [] *)
  "head_or", B.HeadOr, 2;     (* (xs, d) -> head of int list or d if empty *)
  "tail",   B.Tail,   1;      (* xs -> tl xs ([] on []) *)
  "min",    B.Min,    2;
  "max",    B.Max,    2;
]

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

  let ( let* ) = Option.bind

  let as_int = function V.Literal (B.Int i) -> Some i | _ -> None
  let int i = V.Literal (B.Int i)
  let bool b = V.Literal (B.Bool b)

  (* int lists: every element an Int literal *)
  let as_ints v =
    let* xs = as_list v in
    List.fold_right (fun x acc -> let* acc = acc in let* i = as_int x in Some (i :: acc)) xs (Some [])
  (* byte lists: every element an Int literal in 0..255 *)
  let as_bytes v =
    let* xs = as_ints v in
    if List.for_all (fun b -> 0 <= b && b <= 255) xs then Some xs else None
  let of_ints xs = of_list (List.map int xs)

  let rec take n = function
    | [] -> [] | x :: xs -> if n <= 0 then [] else x :: take (n - 1) xs
  let rec drop n = function
    | [] -> [] | (_ :: xs) as l -> if n <= 0 then l else drop (n - 1) xs

  let int2 f = function
    | V.Pair (a, b) -> let* a = as_int a in let* b = as_int b in f a b
    | _ -> None
  let bool2 f = function
    | V.Pair (a, b) -> let* a = as_bool a in let* b = as_bool b in Some (bool (f a b))
    | _ -> None

  (* v2: carrier-overflow detection for the 63-bit OCaml int. *)
  let add_checked a b =
    let s = a + b in
    if (a >= 0) = (b >= 0) && (s >= 0) <> (a >= 0) then None else Some s
  let sub_checked a b =
    let d = a - b in
    if (a >= 0) <> (b >= 0) && (d >= 0) <> (a >= 0) then None else Some d
  let mul_checked a b =
    if a = 0 || b = 0 then Some 0
    else if (a = -1 && b = min_int) || (b = -1 && a = min_int) then None
    else let p = a * b in if p / b <> a then None else Some p
  let div_checked a b =
    if b = 0 || (a = min_int && b = -1) then None else Some (a / b)
  let mod_checked a b =
    if b = 0 then None else Some (a mod b)
  let neg_checked a = if a = min_int then None else Some (- a)

  let func_def (f : B.func) : v -> v option =
    match f with
    | B.Add -> int2 (fun a b -> Option.map int (add_checked a b))
    | B.Sub -> int2 (fun a b -> Option.map int (sub_checked a b))
    | B.Mul -> int2 (fun a b -> Option.map int (mul_checked a b))
    | B.Div -> int2 (fun a b -> Option.map int (div_checked a b))
    | B.Mod -> int2 (fun a b -> Option.map int (mod_checked a b))
    | B.Lt -> int2 (fun a b -> Some (bool (a < b)))
    | B.Le -> int2 (fun a b -> Some (bool (a <= b)))
    | B.Gt -> int2 (fun a b -> Some (bool (a > b)))
    | B.Ge -> int2 (fun a b -> Some (bool (a >= b)))
    | B.Min -> int2 (fun a b -> Some (int (min a b)))
    | B.Max -> int2 (fun a b -> Some (int (max a b)))
    | B.Eq -> (function
        | V.Pair (V.Literal x, V.Literal y) -> Some (bool (x = y))
        | _ -> None)
    | B.Ne -> (function
        | V.Pair (V.Literal x, V.Literal y) -> Some (bool (x <> y))
        | _ -> None)
    | B.Neg -> (fun v -> let* i = as_int v in Option.map int (neg_checked i))
    | B.LNot -> (fun v -> let* b = as_bool v in Some (bool (not b)))
    | B.LAnd -> bool2 ( && )   (* only reached with both operands already evaluated;
                                  the v2 lowering never emits LAnd/LOr (it emits Cond) *)
    | B.LOr -> bool2 ( || )
    | B.Fst -> (function V.Pair (a, _) -> Some a | _ -> None)
    | B.Snd -> (function V.Pair (_, b) -> Some b | _ -> None)
    | B.ExcTag tag -> (function
        | V.Pair (V.Literal (B.String t), _) -> Some (bool (t = tag))
        | _ -> None)
    | B.Range (lo, hi) -> (fun v -> let* i = as_int v in if lo <= i && i <= hi then Some (int i) else None)
    | B.RangeList (lo, hi) -> (fun v -> let* xs = as_ints v in
                                if List.for_all (fun i -> lo <= i && i <= hi) xs then Some v else None)
    | B.Length -> (fun v -> let* xs = as_ints v in Some (int (List.length xs)))
    | B.Empty -> (function V.Literal B.Unit -> Some (of_list []) | _ -> None)
    | B.Single -> (fun v -> let* b = as_int v in
                    if 0 <= b && b <= 255 then Some (of_ints [b]) else None)
    | B.Append -> (function
        | V.Pair (a, b) -> let* xs = as_bytes a in let* ys = as_bytes b in Some (of_ints (xs @ ys))
        | _ -> None)
    | B.Take -> (function
        | V.Pair (a, n) -> let* xs = as_bytes a in let* n = as_int n in
            if 0 <= n && n <= List.length xs then Some (of_ints (take n xs)) else None
        | _ -> None)
    | B.Drop -> (function
        | V.Pair (a, n) -> let* xs = as_bytes a in let* n = as_int n in
            if 0 <= n && n <= List.length xs then Some (of_ints (drop n xs)) else None
        | _ -> None)
    | B.Slice -> (function
        | V.Pair (a, V.Pair (off, n)) ->
            let* xs = as_bytes a in let* off = as_int off in let* n = as_int n in
            if 0 <= off && off <= n && n <= List.length xs
            then Some (of_ints (take (n - off) (drop off xs))) else None
        | _ -> None)
    | B.HeadOr -> (function
        | V.Pair (a, d) -> let* xs = as_ints a in let* d = as_int d in
            Some (int (match xs with [] -> d | x :: _ -> x))
        | _ -> None)
    | B.Tail -> (fun v -> let* xs = as_ints v in
                  Some (of_ints (match xs with [] -> [] | _ :: t -> t)))

  (* Action bodies are installed by the lowering (one per spec-language fn). *)
  let acts : (string, stmt) Hashtbl.t = Hashtbl.create 16
  let act_def (a : act) : stmt =
    match Hashtbl.find_opt acts a with
    | Some s -> s
    | None -> failwith ("act_def: unknown action " ^ a)
end

module I = Calculus.Interp.InterpConcrete (B) (Defs)
