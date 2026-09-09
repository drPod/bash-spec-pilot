# Relay: generated Clight, VST body, and whole-program wrappers

Take CompCert 3.15 Clight of the unchanged phase-2 `relay.c` (32-byte copy with partial writes) through VST contracts, a body proof, wrapper `semax_prog`, dry safety, and concrete termination with `outcome`.

`body_relay`, `prog_correct`, `relay_dry_safety` (under `Jsub`), `relay_main_termination` / `relay_exit_termination` (no `Jsub`), and universal executions in [`adequacy/universal/`](adequacy/universal/README.md) are checked. This is the C-side of the prototype in [`../evaluation/DRAFT-PAPER.md`](../evaluation/DRAFT-PAPER.md). Only relay has the generated-C connection used by the Lean script fragment.

Trusted: C-to-Clight, scheduled `read`/`write`, not host OS. `semax_body` is partial correctness. Dry exit predicate is `True` (`funspec2extspec`); functional returned status on concrete execution is `TerminateMain.v`, not `dry_safeN`. `Jsub` undischarged for safety-derived theorems. Negative UTF-8 calibration is separate ([`../calibration/`](../calibration/README.md)).

`relay.v` is normalized Clight for unchanged phase-2 relay. `relay.i` retains preprocessed input. `frontend-results.json` records hashes and commands. AST accepted by Coq 8.20.1 in 0.72 s, 507,948 KiB. **Not** a functional proof or verified C-to-AST translation. See `../FRONTEND.md`.

## Frontend replay

Rootless `phase5-vst` (Coq 8.20.1, CompCert 3.15). From repository root; fresh run names; logs under `~/agent-jobs/astra-research/phase5/runs`:

```sh
docker exec phase5-vst mkdir -p /home/coq/phase5/relay/include
docker cp research/libc-specs/phase2/relay.c phase5-vst:/home/coq/phase5/relay/relay.c
docker cp research/libc-specs/phase5/relay/include/unistd.h phase5-vst:/home/coq/phase5/relay/include/unistd.h
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-clightgen-replay --seconds 60 --workdir /home/coq/phase5/relay -- clightgen -normalize -dprepro -nostdinc -Iinclude -I/home/coq/.opam/4.13.1+flambda/lib/compcert/include -std=c11 -fnone relay.c
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-ast-coqc-replay --seconds 120 --workdir /home/coq/phase5/relay -- coqc relay.v
docker exec phase5-vst sha256sum /home/coq/phase5/relay/relay.i /home/coq/phase5/relay/relay.v
```

`.vo` is a compiled AST, not a correctness certificate.

## Body proof

`Body.v` vs unchanged `Specs.v`:

```coq
Lemma body_relay : semax_body Vprog Gprog f_relay relay_spec.
```

Receipt `relay-body-coqc-16` (exit 0, 5.46 s, 641,524 KiB); `Body.v` sha256 `88768fc4c0128475ae44b4689d79e5f0b08f24d5f70c63f6eac15f8b39522aa2`. Then `Progress.v` (`3586494810f119ad264d02bf50c649c887f7b380bcf20765407c734e96a3fc43`, `relay-progress-coqc-5`) and `Audit.v` (`32128f3c8abf8b89534ea9db679b89678642f13c8d8603034adcbfe0400e65f1`, `relay-audit-3`).

Under `read_spec`/`write_spec` (scheduled `read32`/`write_block` on `has_ext`), every terminating execution returns `Vint (Int.repr status)` with `outcome initial status final pending` (`reaches initial (Halt status pending) final`). Invariants: `reaches initial Ready s` with empty 32-byte buffer before each read; `reaches initial (Drain chunk off) t` with `buffer_prefix` inside the write loop. Write receives `offset_val off v_buf` holding `suffix off chunk` (`byte_array_split`). With `Conservation.v`: `delivered final = delivered initial ++ extra` and `extra ++ pending ++ unread final = unread initial`.

Does not say: C-loop termination, host `read`/`write`, `juicy_dry_ext_spec` (proved later in `adequacy/`), `semax_prog` (wrapper below), CompCert compilation. 64-bit comparisons use `-1 <= read_ret <= 32` and `-1 <= write_ret <= n - off`.

`Progress.v`: `reaches_progress` (measure `3*(33*|unread| + |pending|) + phase_rank`) and `outcome_exists`. Abstract primitives, not Clight steps.

Assumptions (`relay-audit-3`): Protocol/Reach/Conservation/Progress closed. `body_relay` uses only standard VST/CompCert axioms (`classic`, `prop_ext`, `functional_extensionality_dep`, `eq_rect_eq`, `Extensionality_Ensembles`, `sig_not_dec`/`sig_forall_dec`). No `Admitted`.

```sh
for f in Body Progress Audit; do docker cp research/libc-specs/phase5/relay/$f.v phase5-vst:/home/coq/phase5/relay/$f.v; done
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-body-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc Body.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-progress-replay --seconds 120 --workdir /home/coq/phase5/relay -- coqc Progress.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name relay-audit-replay --seconds 300 --workdir /home/coq/phase5/relay -- coqc Audit.v
```

## Wrapper `semax_prog`

`relay_main.c`: `#include "relay.c"` plus `int main(void) { return relay(); }`. Frozen `relay.c` sha256 `c5abc06f…`. Hashes: `relay_main.c` `3fb8a9a21991e8905907eb72b87d94408c69b5c6cae93504ccca10e1d64a0910`, `.i` `384aa1af1eeb3dde5af1ad1513c3222fdc63e5943d77486af26945bb457b8c50`, `.v` `a3f914f5c2d655aee4c23bcd271c84c61b4be998cbb6b53fd6d00729bbaf9d9c`. `f_relay` textually identical to `relay.v`.

`Main.v` sha256 `99127b18627c71d298805746457d542a102a3d02fd7d742c79d221aba6a54f02`, `relay-main-coqc-4` (14.46 s, 871,452 KiB):

```coq
Definition main_spec (w0 : world) :=
 DECLARE _main WITH gv : globals
 PRE [] main_pre prog w0 gv
 POST [ tint ]
   EX status : Z, EX final : world, EX pending : list byte,
   PROP (outcome w0 status final pending)
   RETURN (Vint (Int.repr status)) SEP (has_ext final).
Lemma body_main w0 (Hv : valid_world w0) :
  semax_body Vprog (Gprog w0) f_main (main_spec w0).
Lemma prog_correct w0 : valid_world w0 -> semax_prog prog w0 Vprog (Gprog w0).
```

`Espec := Relay_Espec (ext_link_prog prog)`. Dry/`juicy_dry` and `whole_program_sequential_safety_ext` follow in `adequacy/`. Source-fidelity remains `relay.c`/`relay.v`.

## Determinism and evaluator

`Determinism.v` (`98ccb12f86ee949b12ec2d39c92be4b6f1776b50174cd104c0fd39e4fcc0c700`, `relay-determinism-coqc-4`): `outcome_run` and `outcome_unique`. Audit `relay-audit-5`: 60 closed, 12 standard-axiom blocks.

`Evaluator.v` (`d323c48109e26b65db1aecb1ad5086bd49275413b40f1eb1d8479526397696a9`): `eval_sound`, `eval_total` with `fuel initial := Z.to_nat (measure Ready initial)` (= 99·|unread| + 1). Witnesses `eval_a` / `eval_b` by `vm_compute`. Audit `relay-audit-6`: 66 closed.

`Distinguish.v` (`b40707330c90456eb5ae16724648b0ffb3686c1b625211dd055e78c4846fd14e`): unique status per witness (`no_false_success_a`, etc.). Infinite zero-write retry unconstrained by `semax_body`. Audit `relay-audit-7`: 71 closed.

From-scratch replay directory `/home/coq/phase5/relay/replay/`: 16 receipts, all exit 0, 58 s; hashes match `frontend-results.json`.

Full order: `relay`, `relay_main`, `Protocol`, `Reach`, `ReachExamples`, `Specs`, `Conservation`, `Progress`, `Body`, `Main`, `Determinism`, `Evaluator`, `Distinguish`, `Audit`.

## Dry adequacy (`adequacy/`)

`dry_mem_lemmas.v` is a verbatim copy of VST 2.15 `progs64/dry_mem_lemmas.v` (sha256 `cdeeaa5ab3de6bc6bd18014af191749c0767e227fb7ca980f1759630562bf564`).

- `Dry.v` (`370fe484c02e739dc1d8b5edf622349aa2b971beae57f7596bb81f77ba06435d`, `adequacy-dry-coqc-20`): `relay_dry_spec`; `juicy_dry_specs`; `dry_spec_mem`.
- `Safety.v` (`62e0748b9bf06d942f1df06ec17cf15a8a2672cd914a7dda805cffc25eaf5977`, `adequacy-safety-coqc-2`): `relay_dry_safety` via `whole_program_sequential_safety_ext`. Hypothesis `Jsub` **not discharged** (CompCert builtins `ef_inline = true` even though unused). Dry exit predicate `True`; functional outcome is **not** a consequence of `relay_dry_safety`.

Replay: `coqc` `dry_mem_lemmas`, `Dry`, `Safety`, `AuditAdequacy` in `/home/coq/phase5/relay` after the chain above.

## Exit wrapper and concrete termination (`adequacy/exit/`)

`relay_exit.c` sha256 `bc6b2fa785304d9949f256fce9023783267b64e74e542e59890598ef48885030`: `exit(relay())`. `relay_exit.i` `7394626fdf8595ef6f787da51b23eb8f4080dad2117e54c54cc0bc0b5b562c2f`, `.v` `374f75b84767a5fcd5725406d98e0e0a7423ccd46c63fcc57160c146eb78be33`. `eq_refl : relay_exit.f_relay = relay.f_relay`.

| File | sha256 | First receipt | Replay |
|---|---|---|---|
| `MainExit.v` | `ce6f4da289f5d577a5cfa1e166d61a3f04a00c32bcd55a3ce7ade46f08270921` | `adequacy-mainexit-coqc-1` | `adequacy-replay3-mainexit-1` |
| `DryExit.v` | `7920afdbdbddfd625fcd0cc50ee689ca116362c8a41c772f7942d0df0e52c967` | `adequacy-dryexit-coqc-3` | `adequacy-replay3-dryexit-1` |
| `SafetyExit.v` | `41d782b5f1df55e96ecc88273e4df1bfc2e6f5cbf13c7978c0a9bd1e79674893` | `adequacy-safetyexit-coqc-2` | `adequacy-replay3-safetyexit-1` |
| `Trace.v` | `887784249be08dc5ac55c5e0e9b3c8db3373df50e99e55b0d22c496de5940a6c` | `adequacy-trace-coqc-10` | `adequacy-replay3-trace-1` |
| `ExitOutcome.v` | `8c986887e8f60c084764c959d1e5dd3452fbcd307409d24b2f0c29e3d13a7ca2` | `adequacy-exitoutcome-coqc-3` | `adequacy-replay3-exitoutcome-1` |
| `AuditExit.v` | `2e8b4d9c6c80545d2120cefa7cd802979dce736b733d805f4a40a13bbfe0b374` | `adequacy-auditexit-coqc-1` | `adequacy-replay3-auditexit-1` |
| `Terminate.v` | `27be473e969cf1c7eb73872a3bd00265992a6eee2e6f98261f39e1e569d689bc` | `adequacy-terminate-coqc-19` | `adequacy-replay3-terminate-1` |
| `AuditTerminate.v` | `1d89e08d623607bb86e79e618772c44487efff14621df96ab0bc526dd5981a12` | `adequacy-auditterminate-coqc-1` | `adequacy-replay3-auditterminate-1` |
| `ShellExit.v` | `759b596f92cf8faf91713187857144823985c15c51a1c6cdcac2342a402f9a4e` | `adequacy-shellexit-coqc-1` | — |
| `TerminateMain.v` | `2b52a82e924c205f659c482b9dce7e5b440e544108963c29fd426c5f8e0ff644` | `adequacy-terminatemain-coqc-3` | — |

`Terminate.v` / `TerminateMain.v`: direct construction, no `Jsub`. `relay_exit_termination` reaches `exit(Vint (Int.repr status))` with `outcome`. `relay_main_termination` halts `Returnstate (Vint (Int.repr status)) Kstop` with `outcome`. `ExitOutcome.v` (under `Jsub`): every reachable exit call has that property. `ShellExit.relay_exit_shell_witness` composes with `../shell-bridge`.

Replay after Dry/Safety: copy `relay_exit.c` and the `.v` files; `clightgen` then `coqc` in the table order; `ShellExit.v` needs `-Q /home/coq/phase5/shell-bridge ""`.

## Negative controls

[`controls/README.md`](controls/README.md): pointer and retry mutants; `coqc` exit 1 as expected (`control-ptr-body-coqc-1`, `control-retry-body-coqc-1`).
