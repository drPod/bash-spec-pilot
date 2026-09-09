# Relay through the established C frontend

`relay.v` is the actual normalized Clight output of CompCert 3.15 for the unchanged
phase 2 relay. `relay.i` retains the preprocessed input, including header line
markers. `frontend-results.json` records source/header/tool hashes, commands,
resource measurements and the manual signature/control-flow inspection.

The generated file was accepted by Coq 8.20.1 in 0.72 seconds with 507,948 KiB
maximum child RSS. Generation took 0.01 seconds with 17,152 KiB maximum child RSS.
These results establish a usable generated representation, **not a functional
proof of the relay or verified C-to-AST translation**. See `../FRONTEND.md`.

## Replay in the persistent toolchain

Dependencies and compiler output stay in the local container, outside source sync.
The tested environment is the rootless `phase5-vst` container described in
`frontend-results.json`, with Coq 8.20.1 and installed CompCert 3.15. Wait for any
existing build to finish before running the following from the repository root:

```sh
docker exec phase5-vst mkdir -p /home/coq/phase5/relay/include
docker cp research/libc-specs/phase2/relay.c phase5-vst:/home/coq/phase5/relay/relay.c
docker cp research/libc-specs/phase5/relay/include/unistd.h phase5-vst:/home/coq/phase5/relay/include/unistd.h
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-clightgen-replay --seconds 60 --workdir /home/coq/phase5/relay -- clightgen -normalize -dprepro -nostdinc -Iinclude -I/home/coq/.opam/4.13.1+flambda/lib/compcert/include -std=c11 -fnone relay.c
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-ast-coqc-replay --seconds 120 --workdir /home/coq/phase5/relay -- coqc relay.v
docker exec phase5-vst sha256sum /home/coq/phase5/relay/relay.i /home/coq/phase5/relay/relay.v
```

Choose fresh run names for subsequent replays; logs and receipts are retained
under `~/agent-jobs/astra-research/phase5/runs`. Compare generated hashes against
the manifest. The `.vo` file is a compiled AST definition, not a correctness
certificate for the program. VST behavioral proof work remains in progress.

## Checked VST body proof (2026-09-07)

`Body.v` proves, against the **unchanged** contracts in `Specs.v`,

```coq
Lemma body_relay : semax_body Vprog Gprog f_relay relay_spec.
```

for the actual generated `f_relay` in `relay.v`. Receipt
`relay-body-coqc-16.json` (exit 0, 5.46 s, 641,524 KiB peak RSS);
`Body.v` sha256 `88768fc4c0128475ae44b4689d79e5f0b08f24d5f70c63f6eac15f8b39522aa2`.
`Progress.v` (sha256 `3586494810f119ad264d02bf50c649c887f7b380bcf20765407c734e96a3fc43`,
receipt `relay-progress-coqc-5.json`) and the extended `Audit.v`
(sha256 `32128f3c8abf8b89534ea9db679b89678642f13c8d8603034adcbfe0400e65f1`,
receipt `relay-audit-3.json`) were checked afterwards in that order.

What the body theorem says. In VST's separation logic, under the external
funspecs `read_spec`/`write_spec` (which pin each call to the deterministic
scheduled primitives `read32`/`write_block` on the `has_ext` world), every
terminating execution of the generated body returns `Vint (Int.repr status)`
with `outcome initial status final pending`, i.e. an actual derivation of the
abstract relation `reaches initial (Halt status pending) final`. The loop
invariants are the ones in the design note: `reaches initial Ready s` with
`data_at_ Tsh (tarray tuchar 32) v_buf` before each read; `reaches initial
(Drain chunk off) t` with `buffer_prefix Tsh v_buf chunk` and
`temp _off (Vlong (Int64.repr off))` inside the write loop. The write call
receives exactly the memory range `offset_val off v_buf` holding
`suffix off chunk` (lemma `byte_array_split`), so byte delivery is tied to the
initialized stack bytes rather than to a ghost list. Combined with
`Conservation.v` this yields, for every status, `delivered final =
delivered initial ++ extra` and `extra ++ pending ++ unread final = unread
initial`, plus the status-specific facts (`outcome_success_exact`,
`outcome_read_error_pending`, `outcome_write_error_pending`).

What it does not say. `semax_body` is partial correctness/safety in VST's
logic: no termination of the C loop, no statement about host `read`/`write`,
no dry/juicy external adequacy (`juicy_dry_ext_spec` for a world oracle with
buffer stores is still unproved), no `semax_prog`/whole-program theorem (the
translation unit has no `main`), and no CompCert compilation theorem. The
64-bit comparisons in the body are discharged using the bounds
`-1 <= read_ret <= 32` and `-1 <= write_ret <= n - off` from `Protocol.v`; the
unsigned `off < (size_t)n` test is interpreted through `ltu_repr64`.

`Progress.v` is a separate **abstract** progress/termination result:
`reaches_progress` (every reachable non-Halt configuration has a reachable
successor of strictly smaller measure `3*(33*|unread| + |pending|) +
phase_rank`) and `outcome_exists` (every initial world reaches some Halt).
It needs no validity hypothesis because the primitives are total. It is a
theorem about abstract read/write operations, not about Clight steps; lifting
it to the C program needs finite internal paths between calls and the
assumption that each specified external call returns.

Assumptions (from `relay-audit-3.log`, `Print Assumptions`): all
Protocol/Reach/ReachExamples/Conservation/Progress theorems are closed under
the global context. `body_relay` and the Body.v memory lemmas depend only on
the standard library axioms already used by VST/CompCert:
`Classical_Prop.classic`, `Axioms.prop_ext`,
`FunctionalExtensionality.functional_extensionality_dep`,
`Eqdep.Eq_rect_eq.eq_rect_eq`, `Ensembles.Extensionality_Ensembles`,
`ClassicalDedekindReals.sig_not_dec`/`sig_forall_dec`. No `Admitted`, no
project axioms, no contract was weakened.

Replay (repository root, container idle; choose fresh run names):

```sh
for f in Body Progress Audit; do docker cp research/libc-specs/phase5/relay/$f.v phase5-vst:/home/coq/phase5/relay/$f.v; done
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-body-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc Body.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-progress-replay --seconds 120 --workdir /home/coq/phase5/relay -- coqc Progress.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-audit-replay --seconds 300 --workdir /home/coq/phase5/relay -- coqc Audit.v
```

`Body.v` requires compiled `relay`, `Protocol`, `Reach`, `Conservation`,
`Specs`; `Audit.v` additionally requires `ReachExamples`, `Progress`, `Body`.

## Whole-program `semax_prog` for a wrapper translation unit (2026-09-07)

`relay_main.c` is a two-line wrapper: `#include "relay.c"` (the frozen file,
sha256 `c5abc06f…` unchanged) plus `int main(void) { return relay(); }`. It was
generated with the same clightgen options (receipt `relay-main-clightgen-1`,
AST accepted in `relay-main-ast-coqc-1`). The generated `f_relay` in
`relay_main.v` is textually identical to the one in `relay.v` (checked with
`diff` on the `Definition f_relay` blocks). Hashes: `relay_main.c`
`3fb8a9a21991e8905907eb72b87d94408c69b5c6cae93504ccca10e1d64a0910`,
`relay_main.i` `384aa1af1eeb3dde5af1ad1513c3222fdc63e5943d77486af26945bb457b8c50`,
`relay_main.v` `a3f914f5c2d655aee4c23bcd271c84c61b4be998cbb6b53fd6d00729bbaf9d9c`.

`Main.v` (sha256 `99127b18627c71d298805746457d542a102a3d02fd7d742c79d221aba6a54f02`,
receipt `relay-main-coqc-4.json`, exit 0, 14.46 s, 871,452 KiB) restates the
`Specs.v` contracts verbatim for `relay_main.prog`, replays the `Body.v` script
(`body_relay w0 : semax_body Vprog (Gprog w0) f_relay relay_spec`), proves

```coq
(* exact text of Main.v *)
Definition main_spec (w0 : world) :=
 DECLARE _main
 WITH gv : globals
 PRE [] main_pre prog w0 gv
 POST [ tint ]
   EX status : Z, EX final : world, EX pending : list byte,
   PROP (outcome w0 status final pending)
   RETURN (Vint (Int.repr status))
   SEP (has_ext final).
Lemma body_main w0 (Hv : valid_world w0) :
  semax_body Vprog (Gprog w0) f_main (main_spec w0).
Lemma prog_correct w0 : valid_world w0 -> semax_prog prog w0 Vprog (Gprog w0).
```

(`has_ext final` is the postcondition's only SEP conjunct: the world after the
run is `final`, related to the initial `w0` by `outcome`.)

with `Espec := Relay_Espec (ext_link_prog prog)` (the oracle is the concrete
`world`; `read`/`write` are external functions whose funspecs are installed in
the external specification by `add_funspecs`). The initial world is the
`semax_prog` oracle argument, as VST's `main_spec_ext'` requires; its validity
is a Coq hypothesis of the theorem. `main` returns exactly relay's status, and
the postcondition carries the same `outcome` derivation.

Still absent: the dry external specification over CompCert memory and the
`juicy_dry_ext_spec` proof, hence no `whole_program_sequential_safety_ext`
consequence yet (and note VST 2.15's own `verif_io.v` needs a `Jsub` axiom at
that step). Assumptions of `body_main`/`prog_correct` (receipt
`relay-audit-4`): only the standard axioms listed above. The wrapper is a
separate artefact; the source-fidelity claim remains about `relay.c`/`relay.v`.

## Determinism of the abstract contract (2026-09-07)

`Determinism.v` (sha256 `98ccb12f86ee949b12ec2d39c92be4b6f1776b50174cd104c0fd39e4fcc0c700`,
receipt `relay-determinism-coqc-4.json`, exit 0) defines an executable
`step : phase * world -> option (phase * world)` and `run n`, and proves
`outcome_run : outcome initial status final pending <-> exists n, run n (Ready,
initial) = Some (Halt status pending, final)` and
`outcome_unique : outcome initial a fa pa -> outcome initial b fb pb -> a = b /\
fa = fb /\ pa = pb`. So the relational utility summary used in the VST
contracts is exactly the graph of a deterministic executable Coq function on
the scheduled environment (design §4). All four theorems are closed under the
global context (receipt `relay-audit-5`, which covers every file:
60 `Closed under the global context`, 12 blocks with only the standard
axioms listed above).

Full replay order (fresh names; container idle): `relay`, `relay_main`
(clightgen + coqc, see the wrapper section), `Protocol`, `Reach`,
`ReachExamples`, `Specs`, `Conservation`, `Progress`, `Body`, `Main`,
`Determinism`, `Audit`.

## Fuel-bounded executable evaluator (2026-09-07)

`Evaluator.v` (sha256 `d323c48109e26b65db1aecb1ad5086bd49275413b40f1eb1d8479526397696a9`,
receipt `relay-evaluator-coqc-3.json`, exit 0) defines `eval n c` (iterate
`step`, stop at Halt) and `fuel initial := Z.to_nat (measure Ready initial)`
(= 99·|unread| + 1), and proves `step_measure` (each executable step strictly
decreases the Progress.v measure on reachable configurations), `eval_sound`
(any result of `eval` is an `outcome`) and `eval_total` (with `fuel initial`
the evaluator returns `Some (Halt status pending, final)` and that is an
`outcome`; unique by `outcome_unique`). The two witnesses are now computed:
`eval_a` (abc/[3;-1] ⇒ status 1, abc delivered) and `eval_b`
(abcdef/[4]/[2;0] ⇒ status 2, ab delivered, cd pending, ef unread) by
`vm_compute`. Audit `relay-audit-6` (Audit.v sha256
`43048ce3d8263d98c7e5c0e7e623fe7575f9d76ce093db03849394a43f203a1b`):
66 closed, 12 standard-axiom blocks, unchanged axiom set.

## Falsifiability on the fixed witnesses (2026-09-07)

`Distinguish.v` (sha256 `b40707330c90456eb5ae16724648b0ffb3686c1b625211dd055e78c4846fd14e`,
receipt `relay-distinguish-coqc-1.json`, exit 0) uses `outcome_unique` with the
ReachExamples derivations to prove that the contract admits exactly one status
per witness: `no_false_success_a`/`no_write_error_a` (abc/[3;-1] cannot end
with status 0 or 2), `no_false_success_b`/`no_read_error_b`
(abcdef/[4]/[2;0] cannot end with 0 or 1) and `pending_forced_b` (status 2 on
input_b forces pending = cd and the final world). Because `body_relay`
establishes `outcome` for the generated code, the false-success and
dropped-pending mutations of design §7 are excluded by the checked
postcondition; the infinite zero-write retry is unconstrained by
`semax_body` (no outcome), which is why Progress.v is a separate obligation.
Audit `relay-audit-7` (Audit.v sha256
`1b0410f3eb059697c5ca383a30a5fed387726aa67a514f384dec65ada3e64b7e`):
71 closed, 12 standard-axiom blocks.

## From-scratch replay evidence (2026-09-07 08:46–08:47 UTC)

The whole chain was rebuilt in a fresh container directory
(`/home/coq/phase5/relay/replay/`, containing only `relay.c`,
`include/unistd.h`, `relay_main.c` and the twelve `.v` sources) with fresh run
names `replay-*-1`: `clightgen` for `relay.c` and `relay_main.c`, then `coqc`
for `relay`, `relay_main`, `Protocol`, `Reach`, `ReachExamples`, `Specs`,
`Conservation`, `Progress`, `Body`, `Main`, `Determinism`, `Evaluator`,
`Distinguish`, `Audit` — 16 receipts, all exit 0, 58 s wall in total. The
regenerated `relay.i`/`relay.v`/`relay_main.i`/`relay_main.v` have exactly the
hashes recorded above and in `frontend-results.json`; the replayed audit prints
the same 71 closed / 12 standard-axiom blocks.

## Dry external adequacy and whole-program safety (2026-09-07, `adequacy/`)

New files (nothing above was modified; `dry_mem_lemmas.v` is a verbatim copy of
VST 2.15 `progs64/dry_mem_lemmas.v`, sha256
`cdeeaa5ab3de6bc6bd18014af191749c0767e227fb7ca980f1759630562bf564`, needed
because the installed VST ships `progs64` as source only):

- `adequacy/Dry.v` (sha256 `370fe484c02e739dc1d8b5edf622349aa2b971beae57f7596bb81f77ba06435d`,
  receipt `adequacy-dry-coqc-20`, exit 0). `relay_dry_spec : external_specification
  mem external_function world` gives the dry (CompCert-memory) meaning of the two
  scheduled primitives, with the actual memory effects: `read(0, p, 32)` requires
  `Mem.range_perm` (writable) on the 32-byte range at `p`; on `read_ret < 0` the
  memory is unchanged, otherwise `Mem.storebytes` of exactly `read_bytes (read32 s)`
  (empty on EOF) at `p` with the rest of the range untouched; `write(1, p, |bs|)`
  requires `Mem.loadbytes` of the `|bs|` bytes at `p` to be `bs` (the funspec's byte
  list, i.e. the initialized stack bytes) and leaves memory unchanged. Return values
  are `Vlong (Int64.repr (read_ret ..))`/`(write_ret ..)`; the oracle evolves by
  `read_world`/`write_world`. `dessicate` forgets the frame rmap.
  `juicy_dry_specs : juicy_dry_ext_spec _ relay_ext_spec relay_dry_spec dessicate`
  connects the funspecs of `Main.Espec` to it (pre ⇒ dry pre; dry post ⇒ juicy post
  including the `buffer_prefix` reconstruction after the partial store), and
  `dry_spec_mem : ext_spec_mem_evolve _ relay_dry_spec`. Reused from VST:
  `data_at__writable_perm`, `data_at_bytes`, `store_bytes_data_at`, `rebuild_store`,
  `rebuild_same`, `inflate_store_join(1)`, `has_ext_compat`, `change_has_ext`,
  `age_rejoin`, `ext_ghost_join`, `no_two_ref`, `ghost_not_both`, `mem_evolve_*`,
  `storebytes_access`, `split2_data_at__Tarray_tuchar`, `Main.tuchar_subarray_offset`.
  New obligations proved here: `inflate_store_VALspec_range` and
  `inflate_store_data_at_` (the untouched tail of the 32-byte buffer stays a
  `data_at_` after the store), and the split/rejoin of the buffer at the returned
  length; VST's example stores the whole buffer.
- `adequacy/Safety.v` (sha256 `62e0748b9bf06d942f1df06ec17cf15a8a2672cd914a7dda805cffc25eaf5977`,
  receipt `adequacy-safety-coqc-2`, exit 0): `init_mem_exists : {m | Genv.init_mem
  prog = Some m}`, `main_block_exists`, and

  ```coq
  Theorem relay_dry_safety (w0 : world) (Hv : valid_world w0) :
    exists q,
    semantics.initial_core (cl_core_sem (globalenv prog)) 0 init_mem q init_mem
      (Vptr main_block Ptrofs.zero) [] /\
    forall n, @step_lemmas.dry_safeN _ _ _ _ semax.genv_symb_injective
               (cl_core_sem (globalenv prog)) relay_dry_spec
               {| genv_genv := Genv.globalenv prog; genv_cenv := prog_comp_env prog |}
               n w0 q init_mem.
  ```

  proved by `whole_program_sequential_safety_ext` from `Main.prog_correct`,
  `add_funspecs_frame`, `juicy_dry_specs`, `dry_spec_mem`, inside a Section whose
  single `Hypothesis Jsub` is the library's inline-external-call premise (VST's own
  `verif_io_mem.v` states it as an `Axiom`). After `End Section` it is the first
  quantified premise of the theorem (see `Check` in `adequacy-audit-coqc-1.log`). It is
  **not discharged**: `prog_defs` declares CompCert builtins (`ef_inline = true`) even
  though `relay_main` never calls one, and a program-local vacuity argument was not
  turned into a theorem.

What `relay_dry_safety` says: the concrete Clight core semantics of `relay_main.prog`,
started at `main` with the constructed initial memory and world `w0`, is dry-safe for
every number of steps: it never gets stuck, every external call it reaches is
`read`/`write` with `relay_dry_spec`'s precondition holding of the actual arguments and
memory, and after each call the environment's scheduled response is assumed. What it
does not say: the dry exit predicate is `True`. This is forced, not chosen:
`funspec2extspec` fixes the juicy exit predicate to `True` and `postcondition_allows_exit`
requires it for every well-typed return value, so no value returned by `main` is visible
in `dry_safeN`. **The functional source-execution theorem (returned status and final
world satisfy `outcome w0 status final pending` on the concrete execution) is still
missing** as a consequence of `relay_dry_safety`; `Main.main_spec`'s postcondition proves
it only inside VST's logic. (Both the returned status and termination are established by
a direct construction in the section "Exit-wrapper chain" below: `TerminateMain.v` for
`relay_main.prog` itself — the concrete execution halts in `Returnstate (Vint (Int.repr
status)) Kstop` with `outcome` — and `Terminate.v`/`ExitOutcome.v` for the exit wrapper.)
See `adequacy/AuditAdequacy.v`
(`adequacy-audit-coqc-1`): `Dry.v` theorems use only the standard axioms listed above;
`relay_dry_safety` additionally depends on `lib.Axioms.proof_irr`,
`Clight_core.inline_external_call_mem_events` (VST), `Events.external_functions_sem` and
`Events.inline_assembly_sem` (CompCert parameters), all inherited from
`whole_program_sequential_safety_ext`; no project axiom, no `Admitted`.

Replay (repository root; container idle; fresh names; after the full chain above):

```sh
for f in dry_mem_lemmas Dry Safety AuditAdequacy; do docker cp research/libc-specs/phase5/relay/adequacy/$f.v phase5-vst:/home/coq/phase5/relay/$f.v; done
uv run --no-project python research/libc-specs/phase5/run_vst.py --name adequacy-drymem-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc dry_mem_lemmas.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name adequacy-dry-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc Dry.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name adequacy-safety-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc Safety.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name adequacy-audit-replay --seconds 300 --workdir /home/coq/phase5/relay -- coqc AuditAdequacy.v
```

## Exit-wrapper chain: returned outcome at the exit call, and a concrete execution witness (2026-09-07, `adequacy/exit/`)

Motivation: VST 2.15 forces the dry exit predicate to `True`, so the value returned by
`main` in `relay_main.prog` is invisible to `dry_safeN`. The wrapper
`adequacy/exit/relay_exit.c` (sha256 `bc6b2fa785304d9949f256fce9023783267b64e74e542e59890598ef48885030`)
is `#include "relay.c"` (the frozen file, unchanged) plus `void exit(int); int main(void)
{ exit(relay()); return 0; }`; the status is handed to the environment through the
external call `exit`, whose precondition dry safety does carry. Generated with the same
clightgen options (receipts `adequacy-exit-clightgen-1`, `adequacy-exit-coqc-1`;
`relay_exit.i` sha256 `7394626fdf8595ef6f787da51b23eb8f4080dad2117e54c54cc0bc0b5b562c2f`,
`relay_exit.v` sha256 `374f75b84767a5fcd5725406d98e0e0a7423ccd46c63fcc57160c146eb78be33`).
`AuditExit.v` checks `eq_refl : relay_exit.f_relay = relay_main.f_relay` and
`= relay.f_relay`, so the verified relay body is definitionally the same AST.

Files (all direct `coqc` receipts, exit 0, in `~/agent-jobs/astra-research/phase5/runs/`;
first accepted run and the fresh in-order replay `adequacy-replay3-*-1` of 2026-09-07
20:07:41–20:09:13 UTC, whose logs are byte-identical to the first accepted logs):

| File | sha256 | First accepted receipt | Replay receipt |
|---|---|---|---|
| `adequacy/exit/MainExit.v` | `ce6f4da289f5d577a5cfa1e166d61a3f04a00c32bcd55a3ce7ade46f08270921` | `adequacy-mainexit-coqc-1` (15.11 s) | `adequacy-replay3-mainexit-1` |
| `adequacy/exit/DryExit.v` | `7920afdbdbddfd625fcd0cc50ee689ca116362c8a41c772f7942d0df0e52c967` | `adequacy-dryexit-coqc-3` (5.47 s) | `adequacy-replay3-dryexit-1` |
| `adequacy/exit/SafetyExit.v` | `41d782b5f1df55e96ecc88273e4df1bfc2e6f5cbf13c7978c0a9bd1e79674893` | `adequacy-safetyexit-coqc-2` (9.99 s) | `adequacy-replay3-safetyexit-1` |
| `adequacy/Trace.v` | `887784249be08dc5ac55c5e0e9b3c8db3373df50e99e55b0d22c496de5940a6c` | `adequacy-trace-coqc-10` (10.67 s) | `adequacy-replay3-trace-1` |
| `adequacy/exit/ExitOutcome.v` | `8c986887e8f60c084764c959d1e5dd3452fbcd307409d24b2f0c29e3d13a7ca2` | `adequacy-exitoutcome-coqc-3` (10.86 s) | `adequacy-replay3-exitoutcome-1` |
| `adequacy/exit/AuditExit.v` | `2e8b4d9c6c80545d2120cefa7cd802979dce736b733d805f4a40a13bbfe0b374` | `adequacy-auditexit-coqc-1` (23.66 s) | `adequacy-replay3-auditexit-1` |
| `adequacy/exit/Terminate.v` | `27be473e969cf1c7eb73872a3bd00265992a6eee2e6f98261f39e1e569d689bc` | `adequacy-terminate-coqc-19` (4.54 s) | `adequacy-replay3-terminate-1` |
| `adequacy/exit/AuditTerminate.v` | `1d89e08d623607bb86e79e618772c44487efff14621df96ab0bc526dd5981a12` | `adequacy-auditterminate-coqc-1` (7.94 s) | `adequacy-replay3-auditterminate-1` |
| `adequacy/exit/ShellExit.v` | `759b596f92cf8faf91713187857144823985c15c51a1c6cdcac2342a402f9a4e` | `adequacy-shellexit-coqc-1` (2.08 s, first compile) | — |
| `adequacy/exit/TerminateMain.v` | `2b52a82e924c205f659c482b9dce7e5b440e544108963c29fd426c5f8e0ff644` | `adequacy-terminatemain-coqc-3` (4.80 s; runs 1–3 differ only in comments, identical logs) | — |

What each file establishes (exact names):

- `MainExit.v`: the `Specs.v` contracts retargeted to `relay_exit.prog`, plus

  ```coq
  Definition exit_spec (w0 : world) :=
   DECLARE _exit
   WITH status : Z, final : world, pending : list byte
   PRE [ tint ]
     PROP (outcome w0 status final pending)
     PARAMS (Vint (Int.repr status))
     SEP (has_ext final)
   POST [ tvoid ]
     PROP (False) RETURN () SEP ().
  Definition main_spec (w0 : world) :=
   DECLARE _main WITH gv : globals PRE [] main_pre prog w0 gv
   POST [ tint ] PROP (False) RETURN () SEP ().
  Lemma prog_correct : forall w0, valid_world w0 -> semax_prog prog w0 Vprog (Gprog w0).
  ```

  (implicit `Espec := Espec w0 = add_funspecs (ok_void_spec world) ext_link [read; write; exit w0]`,
  printed by `Check` in `adequacy-auditexit-coqc-1.log`). `outcome w0 status final pending`
  in exit's PRE is the **caller's** obligation, discharged by `body_main` from relay's
  postcondition; nothing is assumed of read/write/exit about the whole-program outcome.
  `body_relay` is `Main.v`'s script replayed.
- `DryExit.v`: `exit_dry_spec w0` = `Dry.v`'s read/write cases (same `Mem.storebytes` /
  `Mem.loadbytes` effects, same no-effect error cases) plus exit with dry pre
  `args = [Vint (Int.repr status)] /\ final = z /\ outcome w0 status final pending` and dry
  post `False`; `exit_juicy_dry_specs : juicy_dry_ext_spec _ (JE_spec _ (exit_ext_spec w0))
  (exit_dry_spec w0) (dessicate w0)`; `exit_dry_spec_mem`.
- `SafetyExit.v`: `init_mem_exists`, `main_block_exists`, and
  `relay_exit_dry_safety : Jsub -> forall w0, valid_world w0 -> exists q, initial_core ... /\
  forall n, dry_safeN (cl_core_sem (globalenv prog)) (exit_dry_spec w0) ... n w0 q init_mem`.
  `Jsub` is VST's inline-external premise, an explicit quantified hypothesis (its full text is
  printed by `Check` in the audit logs); it is **not** discharged.
- `Trace.v`: generic `dry_step` (one core step, or one external call answered by any result /
  memory / oracle satisfying the dry post for every witness satisfying the dry pre) and
  `dry_steps`; `safeN_dry_steps`, `safeN_not_stuck`; `relay_concrete_trace` for `relay_main.prog`.
- `ExitOutcome.v`, under the same explicit `Jsub`, for every valid `w0` and every state
  `(q, m, z)` reachable from the initial core by `dry_steps` under `exit_dry_spec w0`:
  (a) not stuck (dry precondition holds at every external call; otherwise a core step or halted);
  (b) **returned outcome**:

  ```coq
  forall args, semantics.at_external csem q m = Some (exit_ef, args) ->
    exists status pending, args = [Vint (Int.repr status)] /\ outcome w0 status z pending
  ```

  where `exit_ef = EF_external "exit" (mksignature [AST.Xint] AST.Xvoid cc_default)`;
  (c) no `dry_step` leaves the exit call (the dry post is `False`). This is at the exit-CALL
  boundary, not a statement about `relay_main`'s halted return value.
- `Terminate.v` (no `Jsub`, no safety theorem used: a direct construction) proves that the
  exit call **is reached**:

  ```coq
  Theorem relay_exit_termination : forall w0 : world, valid_world w0 ->
    exists q0 : CC_core,
      initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
      exists k q m final status pending,
        ok_steps w0 k (q0, init_mem, w0) (q, m, final) /\
        semantics.at_external csem q m = Some (exit_ef, [Vint (Int.repr status)]) /\
        outcome w0 status final pending.
  Corollary relay_exit_termination_dry : (same with
        dry_steps csem (exit_dry_spec w0) semax.genv_symb_injective
          {| genv_genv := Genv.globalenv prog; genv_cenv := prog_comp_env prog |}
          k (q0, init_mem, w0) (q, m, final)).
  ```

  `ok_steps` is `Trace.dry_steps` strengthened so that every external call on the trace also
  satisfies the dry precondition for an explicit witness (`ext_ok`), i.e. no step of the
  witness execution is a vacuous environment step. The proof takes the Clight core steps
  literally on the generated AST (`relay_body_eq : fn_body f_relay = Sloop S1 Sskip` and
  `main_body_eq` are checked by `reflexivity`), evaluates the actual expressions
  (`sem_lt_n0`, `sem_eq_n0`, `sem_le_w0`, `sem_ltu`, `sem_add_ptr`, `sem_sub_ul`,
  `sem_add_ul`, the casts), allocates and frees the 32-byte `buf` (`Mem.alloc`,
  `Mem.free_list`), answers `read` by `Mem.storebytes` of the scheduled bytes and `write`
  after checking `Mem.loadbytes` of the suffix actually in memory (`loadbytes_suffix`,
  `bytes_to_memvals_inj`), and follows the abstract executable `RelayDeterminism.run`
  (which halts within `Evaluator.fuel w0` steps) through a simulation invariant
  `match_state` (`sim_step`, `sim_run`). Together with `outcome_unique`, the status on the
  witness execution is the unique abstract outcome of `w0`.

- `TerminateMain.v`: the same construction for the ORIGINAL wrapper `relay_main.prog`
  (`int main(void){ return relay(); }`, `Main.v`/`Dry.v`/`Safety.v` chain, environment
  `Dry.relay_dry_spec`, no `exit`), ending halted:

  ```coq
  Theorem relay_main_termination : forall w0 : world, valid_world w0 ->
    exists q0 : CC_core,
      initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
      exists k q m final status pending,
        ok_steps k (q0, init_mem, w0) (q, m, final) /\
        q = Returnstate (Vint (Int.repr status)) Kstop /\
        (forall i : int, semantics.halted csem q i) /\
        outcome w0 status final pending.
  Corollary relay_main_termination_dry : (same with dry_steps csem relay_dry_spec ...).
  ```

  (`csem := cl_core_sem (globalenv relay_main.prog)`, `init_mem`/`main_block` from
  `Safety.v`; `eq_refl : relay_main.f_relay = relay.f_relay` re-checked in the file.) So
  **main's actual return value on the concrete Clight execution of `relay_main.prog` is the
  protocol status of `w0`, and the execution halts** — the statement that VST's forced exit
  predicate could not deliver through `dry_safeN` is obtained by direct construction, with
  no `Jsub` and no safety theorem. Same assumption set as `Terminate.v`.
- `ShellExit.v` (compiled with `-Q /home/coq/phase5/shell-bridge ""`, the mirror of the
  way `shell-bridge/` imports this directory) composes the concrete execution with the
  shell layer of `../shell-bridge/Shell.v`/`Bridge.v`, whose relay primitive is exactly the
  `outcome` predicate:

  ```coq
  Theorem relay_exit_shell_witness : forall w0, valid_world w0 -> forall lost0 : list byte,
    exists q0 k q m final status pending,
      initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
      ok_steps w0 k (q0, init_mem, w0) (q, m, final) /\
      semantics.at_external csem q m = Some (exit_ef, [Vint (Int.repr status)]) /\
      ShellComposition.exec ShellComposition.relay_prim (call Relay)
        {| os := w0; lost := lost0 |} status {| os := final; lost := lost0 ++ pending |} /\
      exists c, ShellBridge.relay_command "relay && mark" = Some c /\
        ShellComposition.exec ShellComposition.relay_prim c {| os := w0; lost := lost0 |} status
          (if status =? 0 then {| os := deliver final bang; lost := lost0 ++ pending |}
           else {| os := final; lost := lost0 ++ pending |}).
  ```

  i.e. the integer the concrete C execution hands to `exit` is the exit status of the
  shell-level `relay` call, and the parsed text "relay && mark" executes from that state
  with that status. The shell layer's modelling assumptions (name binding; no pipes, fds
  or OS) are unchanged; this adds no C fact beyond `Terminate.v`.

Assumptions (`adequacy-auditexit-coqc-1.log`, `adequacy-auditterminate-coqc-1.log`,
`adequacy-shellexit-coqc-1.log`, `Print Assumptions`): `relay_body_eq`, `main_body_eq`, `init_mem_exists`, `exit_ef_in_prog`
closed. `prog_correct`, `exit_juicy_dry_specs`, `exit_dry_spec_mem`, `exit_dry_pre_inv`,
`exit_dry_post_False`: the standard classical set (`classic`, `prop_ext`,
`functional_extensionality_dep`, `eq_rect_eq`, `sig_not_dec`, `sig_forall_dec`,
`Extensionality_Ensembles`). `relay_exit_dry_safety`, `relay_exit_outcome`: additionally
`lib.Axioms.proof_irr`, `Clight_core.inline_external_call_mem_events`,
`Clight_core.ef_deterministic_fun` (VST), `Events.external_functions_sem`,
`Events.inline_assembly_sem` (CompCert parameters), and the quantified `Jsub` premise.
`relay_exit_termination`, `relay_exit_termination_dry`, every lemma of `Terminate.v`, and
`relay_exit_shell_witness`: only `classic`, `prop_ext`, `functional_extensionality_dep`, `sig_not_dec`,
`sig_forall_dec` and the two CompCert parameters (which enter through the type of
`Clight_core.step`); no `Jsub`, no VST axiom. No `Admitted`, no project axiom, no
contract weakened; all original modules byte-identical.

What is established for `relay_exit.prog`, precisely: in the scheduled environment model
(each `read`/`write` returns with the specified memory effect; `exit` does not return)
the concrete Clight core execution from `Genv.init_mem` reaches the external call
`exit(Vint (Int.repr status))` in world `final` after finitely many steps, every external
call on the way satisfies its dry precondition, and `outcome w0 status final pending`
holds (Terminate.v); and, under `Jsub`, every reachable exit-call state has this property
(ExitOutcome.v). For the original `relay_main.prog`, the concrete execution halts with
`main` returning `Vint (Int.repr status)` and `outcome w0 status final pending`
(TerminateMain.v). Still not established: anything about the host OS; termination against
environments other than the scheduled one (the witness is existential; all executions
differ only by `mem_equiv`, but that bisimulation is not proved); `Jsub` remains a library
boundary for the safety-derived theorems only. C→Clight translation is trusted as
documented (hashes).

Replay (repository root; container idle; fresh names; after the full chain above and the
adequacy section's `dry_mem_lemmas`/`Dry`/`Safety`):

```sh
R=research/libc-specs/phase5/relay
docker cp $R/adequacy/exit/relay_exit.c phase5-vst:/home/coq/phase5/relay/relay_exit.c
uv run --no-project python $R/../run_vst.py --name adequacy-exit-clightgen-replay --seconds 60 --workdir /home/coq/phase5/relay -- clightgen -normalize -dprepro -nostdinc -Iinclude -I/home/coq/.opam/4.13.1+flambda/lib/compcert/include -std=c11 -fnone relay_exit.c
docker cp $R/adequacy/Trace.v phase5-vst:/home/coq/phase5/relay/Trace.v
for f in relay_exit MainExit DryExit SafetyExit ExitOutcome AuditExit Terminate AuditTerminate TerminateMain; do docker cp $R/adequacy/exit/$f.v phase5-vst:/home/coq/phase5/relay/$f.v; done
for f in relay_exit MainExit DryExit SafetyExit Trace ExitOutcome AuditExit Terminate AuditTerminate TerminateMain; do uv run --no-project python $R/../run_vst.py --name adequacy-$(echo $f | tr A-Z a-z)-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc $f.v; done
docker cp $R/adequacy/exit/ShellExit.v phase5-vst:/home/coq/phase5/relay/ShellExit.v   # needs ../shell-bridge compiled (its README)
uv run --no-project python $R/../run_vst.py --name adequacy-shellexit-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc -Q /home/coq/phase5/shell-bridge "" ShellExit.v
docker exec phase5-vst sha256sum /home/coq/phase5/relay/relay_exit.i /home/coq/phase5/relay/relay_exit.v
```

## Negative controls (2026-09-07)

`controls/` holds two hand-mutated copies of `relay.v` (wrong pointer
`buf` instead of `buf+off`; zero-length write retried via `w < 0`) and the
unchanged contracts + proof script applied to them. Both proof attempts fail
at the expected step (`control-ptr-body-coqc-1`, `control-retry-body-coqc-1`,
exit 1); see `controls/README.md` for the exact failing obligations and the
argument why the retry mutant is excluded by the contract itself except for
non-terminating executions. The mutants are not generated from C and carry no
program claim.
