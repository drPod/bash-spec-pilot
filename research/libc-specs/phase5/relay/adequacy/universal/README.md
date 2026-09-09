# Universal execution theorems for the relay programs (universal-relay-4, 2026-09-07)

Everything in this directory is NEW (worker universal-relay-4). It builds on, and does not
modify, the frozen relay modules: `../Trace.v` (environment relation `dry_step`), `../Dry.v` /
`../exit/DryExit.v` (dry specifications), `../exit/Terminate.v` / `../exit/TerminateMain.v`
(existential execution witnesses), `Protocol/Reach/Determinism/Evaluator`.

## What was missing and what is now checked

`TerminateMain.relay_main_termination` and `Terminate.relay_exit_termination` exhibit ONE finite
Clight core execution (an existential witness) per valid initial world. The environment
relation `Trace.dry_step` is nondeterministic: a scheduled `read` may return any memory
`mem_equiv`-equivalent to the `Mem.storebytes` result, and an external call whose dry
precondition has no witness would be unconstrained. The universal statements below quantify
over EVERY `Trace.dry_steps` execution from the initial core, with `valid_world w0` as the only
premise, and no `Jsub`.

`UniversalMain.relay_main_universal` (original wrapper `relay_main.prog`, `int main(void){ return
relay(); }`): for every valid `w0` there are `q0 N status final pending` with
`initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) []`,
`outcome w0 status final pending`, and for every `k q m z` with
`dry_steps csem relay_dry_spec genv_symb_injective relay_ge k (q0, init_mem, w0) (q, m, z)`:

1. `k <= N` (uniform finite bound on every execution);
2. `ext_ok (q, m, z)` (at every reached external call the dry precondition holds for an explicit
   witness, so no vacuous environment step is reachable);
3. `k < N -> exists s', dry_step (q, m, z) s'` (no execution gets stuck early);
4. `k = N -> q = Returnstate (Vint (Int.repr status)) Kstop /\ z = final` (every execution of
   the maximal length is halted with the protocol status, in the protocol's final world);
5. `(forall i, halted csem q i) -> k = N` (halting happens only at length N);
6. `forall s', dry_step (q, m, z) s' -> k < N` (nothing steps past N: every execution is a prefix
   of a maximal one of length exactly N).

`UniversalExit.relay_exit_universal` (exit wrapper `relay_exit.prog`, `exit(relay())`): the same
with `exit_dry_spec w0`, where clause 4 reads `at_external csem q m = Some (exit_ef,
[Vint (Int.repr status)]) /\ z = final` and clause 5 reads "at an external `exit` call only at
length N". Together with `ExitOutcome.relay_exit_outcome` (under `Jsub`) and
`ShellExit.relay_exit_shell_witness`, this closes the exit-wrapper chain universally.

By `Determinism.outcome_unique`, `status`/`final`/`pending` are the unique abstract outcome of
`w0`; by clauses 1, 3, 4, 6, every maximal execution in the specified environment terminates
after exactly N steps with that status. Reachable states differ from the canonical ones only in
the memory, up to `mem_equiv` (`sequiv` in the proofs).

## How (files)

- `MemEquivStep.v` (program-generic): `mem_equiv` transfer of `Mem.alloc`, `Mem.free`,
  `Mem.free_list`, `Mem.storebytes` (through CompCert's exported theorems; the operations are
  `Global Opaque`), `Cop.bool_val`, `alloc_variables`, `function_entry2`; the side condition
  `nb q` (state not at `Sbuiltin`, not at `Sassign`, not an inlined external `Callstate`);
  `step_equiv_transfer : nb q -> step ge q m1 q1 m1' -> mem_equiv m1 m2 -> exists m2', step ge q
  m2 q1 m2' /\ mem_equiv m1' m2'`; `step_fun_nb` (determinism of `step` on `nb` states WITHOUT
  VST's `ef_deterministic_fun` axiom, which VST's `cl_corestep_fun` needs only for builtins).
  Uses VST's `eval_expr_mem_lessalloc` / `sem_cast_mem_lessaloc` (veric/Clight_mem_lessdef.v).
- `UniversalMain.v`, `UniversalExit.v`: the dry specification inspected along `mem_equiv`
  (`pre_transfer`, `post_pins`, `ext_transfer`: the precondition transfers; with ONE witness of
  the precondition any environment answer has the pinned result and world and an equivalent
  memory; the answer transfers to an equivalent call memory FOR EVERY witness there); one-step
  lemmas `dstep_fun` (functional modulo `sequiv`), `dstep_transfer`, `dstep_det`; the canonical
  trajectory re-derived as `csteps` (= `ok_steps` plus `nb` at every step; segments copied from
  Terminate*.v, only the step tactic changed); `canon_universal` (induction on the canonical
  trajectory); the theorems.
- `AuditUniversal.v`: `Check` / `Print Assumptions` of every main lemma; AST identities.
- `UniversalShell.v` (compiled with `-Q /home/coq/phase5/shell-bridge ""` in addition):
  `relay_exit_shell_universal` — the universal analogue of `ShellExit.relay_exit_shell_witness`:
  one status per valid `w0` is at once the exit status of the shell-level `relay` call
  (`ShellComposition.exec relay_prim (call Relay)`), the status the parsed text "relay && mark"
  runs with, and the argument that EVERY C execution hands to `exit` (any reached exit call has
  exactly that argument, in world `final`, at length exactly N; every execution is bounded by N
  and non-stuck below it).

- `MemEquivAssign.v` (NOT needed by the relay theorems; for the case studies): `equiv_load`,
  `equiv_store`, `equiv_assign_loc` (by-value, by-copy and bitfield stores transfer along
  `mem_equiv`) and `step_equiv_transfer_assign`, the transfer lemma with the weaker side
  condition `nb_ext` (only `Sbuiltin` states and inlined external Callstates excluded).
  Its axiom list additionally contains CompCert's `lib.Axioms.proof_irr` (entering through
  CompCert's `Mem.store`/`storebytes` lemmas); the relay theorems do not use this file.
- `MemEquivAssignFun.v`: `step_fun_nb_ext` — determinism of the core step on `nb_ext` states
  (assignments included), standard axioms only. With `step_equiv_transfer_assign` this is what
  the universal induction needs for a program that stores through pointers.

## Inspection result on the environment relation (asked by the task)

The full `dry_step` relation admits no counterexample to the universal statements: (a) the
read/write preconditions force the witness memory to equal the call memory, so with any one
witness the postcondition pins the result and world exactly and the memory up to `mem_equiv`
(`Mem.storebytes` is a function; write's byte list is pinned by `loadbytes` and the length
argument, `bytes_to_memvals_inj`); (b) `mem_equiv` preserves permissions and `loadbytes`
literally (VST's definition is functional equality), so it preserves the preconditions; (c) a
vacuous step (no witness) is never reachable because clause 2 is proved for every reachable
state. No contract was narrowed, no environment refinement was needed.

## Trust boundary (unchanged) and axioms

Assumptions of every theorem here (`universal-audit-coqc-1.log`): exactly `classic`,
`prop_ext`, `functional_extensionality_dep`, `sig_not_dec`, `sig_forall_dec`, and CompCert's
parameters `Events.external_functions_sem` / `Events.inline_assembly_sem` (they enter through
the type of `Clight_core.step`). NOT present: `Jsub`, `ef_deterministic_fun`, `proof_irr`,
`inline_external_call_mem_events`, any project axiom, any `Admitted`. Trusted, as before: the
environment model (each scheduled read/write returns with the specified effect; exit does not
return), the C-to-Clight translation (hashes in `../../README.md`), nothing about the host OS.
Limitation of the generic lemma: `Sassign` and inlined builtins are excluded by `nb` (the relay
programs contain neither); generalising to programs with pointer stores needs an `assign_loc`
transfer lemma (routine) and builtins would need external-call determinism (VST's axiom).

## Receipts (all `run_vst.py`, container phase5-vst, `coqc -Q /home/coq/phase5/relay "" -Q
/home/coq/phase5/relay/universal4 ""`, workdir `/home/coq/phase5/relay/universal4`)

| file | accepted receipt | started_unix (UTC) | s | KiB | sha256 (file) | replay (same log sha256) |
|---|---|---|---|---|---|---|
| MemEquivStep.v | universal-memequiv-coqc-10 | 1788819125.49 (22:12:05) | 3.99 | 764,328 | 05e33acc… | universal-replay-memequiv-1 |
| UniversalMain.v | universal-main-coqc-21 | 1788819129.86 (22:12:09) | 5.41 | 783,144 | 3232b186… | universal-replay-main-1 |
| UniversalExit.v | universal-exit-coqc-4 | 1788819188.52 (22:13:08) | 5.83 | 797,628 | 23fd0cd6… | universal-replay-exit-1 |
| AuditUniversal.v | universal-audit-coqc-1 | 1788819194.71 (22:13:14) | 9.48 | 864,644 | 36e6e217… | universal-replay-audit-1 |
| UniversalShell.v | universal-shell-coqc-1 (first compile) | 1788819442.64 (22:17:22) | 2.27 | 758,036 | see manifest | universal-replay-shell-1 (22:18:17, log identical) |
| MemEquivAssign.v | universal-assign-coqc-5 | 1788819774.89 (22:22:54) | 1.71 | 683,160 | see manifest | universal-replay-assign-1 |
| MemEquivAssignFun.v | universal-assignfun-coqc-1 (first compile) | 1788819856.58 (22:24:16) | 2.99 | see receipt | see manifest | universal-replay-assignfun-1 |

Replay (22:13:44–22:14:10 UTC) logs are byte-identical to the accepted logs. Earlier iterations:
`universal-memequiv-coqc-1..9`, `universal-main-coqc-1..20`, `universal-exit-coqc-1..3`,
debug receipts `universal-main-debug-1..4`, `universal-memequiv-debug-1`, `universal-dbg-lia-1..2`
(all in `~/agent-jobs/astra-research/phase5/runs/`). `universal-main-coqc-20` accepted an earlier
`UniversalMain.v` that still used VST's `cl_corestep_fun` and therefore listed
`ef_deterministic_fun`; `-21` is the final one.

Replay from the repository root:
```
uv run --no-project python research/libc-specs/phase5/run_vst.py --name universal-replay-<N>-memequiv --seconds 600 --workdir /home/coq/phase5/relay/universal4 -- coqc -Q /home/coq/phase5/relay "" -Q /home/coq/phase5/relay/universal4 "" MemEquivStep.v
```
(then `UniversalMain.v`, `UniversalExit.v`, `AuditUniversal.v` in this order; the files must be
copied to the container directory first, as `run_univ.py` in the job directory does).
