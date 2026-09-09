# Universal execution theorems for the relay wrappers

`TerminateMain.relay_main_termination` and `Terminate.relay_exit_termination` exhibit one finite Clight execution per valid world. These theorems quantify over **every** `Trace.dry_steps` execution, with `valid_world w0` as the only premise and no `Jsub`.

`UniversalMain.relay_main_universal` and `UniversalExit.relay_exit_universal` checked. Frozen relay modules unmodified.

Scheduled environment (read/write return with specified effect; exit does not return). C-to-Clight trusted. Not host OS. Generic `nb` excludes `Sassign` and inlined builtins (relay programs contain neither). `MemEquivAssign.v` is for case studies, not used by relay theorems.

Does not modify `../Trace.v`, `../Dry.v`, `../exit/DryExit.v`, `../exit/Terminate.v`, `../exit/TerminateMain.v`.

## Statements

For `relay_main.prog` (`int main(void){ return relay(); }`): exist `q0 N status final pending` with `initial_core …` and `outcome w0 status final pending`, and for every `dry_steps` state `(q, m, z)` of length `k`:

1. `k <= N`
2. `ext_ok` at every reached external call (no vacuous environment step)
3. `k < N -> exists s', dry_step …` (not stuck early)
4. `k = N -> q = Returnstate (Vint (Int.repr status)) Kstop /\ z = final`
5. halted only at length N
6. nothing steps past N

For `relay_exit.prog`, clause 4 is `at_external … exit(Vint (Int.repr status))` at world `final`. With `outcome_unique`, every maximal execution terminates after exactly N steps with that status. Reachable memories differ up to `mem_equiv`.

`UniversalShell.relay_exit_shell_universal`: that status is also the shell-level `relay` / `"relay && mark"` status.

## Files

- `MemEquivStep.v`: `mem_equiv` transfer of alloc/free/storebytes; `step_equiv_transfer` under `nb`; `step_fun_nb` without `ef_deterministic_fun`.
- `UniversalMain.v`, `UniversalExit.v`: dry spec along `mem_equiv`; canonical trajectory; theorems.
- `AuditUniversal.v`: Check / Print Assumptions / AST identities.
- `UniversalShell.v`: compiled with `-Q …/shell-bridge ""`.
- `MemEquivAssign.v` / `MemEquivAssignFun.v`: pointer stores (`proof_irr` on Assign only).

Inspection: read/write preconditions pin result/world; `mem_equiv` preserves permissions/`loadbytes`; vacuous steps unreachable. No contract narrowed.

Axioms (`universal-audit-coqc-1.log`): `classic`, `prop_ext`, `functional_extensionality_dep`, `sig_not_dec`, `sig_forall_dec`, CompCert `external_functions_sem` / `inline_assembly_sem`. Not present: `Jsub`, `ef_deterministic_fun`, `proof_irr` (relay theorems), `inline_external_call_mem_events`.

## Receipts

| file | accepted receipt | s | KiB | replay |
|---|---|---|---|---|
| MemEquivStep.v | `universal-memequiv-coqc-10` | 3.99 | 764,328 | `universal-replay-memequiv-1` |
| UniversalMain.v | `universal-main-coqc-21` | 5.41 | 783,144 | `universal-replay-main-1` |
| UniversalExit.v | `universal-exit-coqc-4` | 5.83 | 797,628 | `universal-replay-exit-1` |
| AuditUniversal.v | `universal-audit-coqc-1` | 9.48 | 864,644 | `universal-replay-audit-1` |
| UniversalShell.v | `universal-shell-coqc-1` | 2.27 | 758,036 | `universal-replay-shell-1` |
| MemEquivAssign.v | `universal-assign-coqc-5` | 1.71 | 683,160 | `universal-replay-assign-1` |
| MemEquivAssignFun.v | `universal-assignfun-coqc-1` | 2.99 | — | `universal-replay-assignfun-1` |

`universal-main-coqc-20` used `cl_corestep_fun` (`ef_deterministic_fun`); `-21` is the final file. Workdir `/home/coq/phase5/relay/universal4`. Copy files first, then `coqc -Q /home/coq/phase5/relay "" -Q /home/coq/phase5/relay/universal4 ""`.
