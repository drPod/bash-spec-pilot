# Shell expansion: pipes and one output redirection

Add `|` and one trailing `>`/`>>` as atoms of the same generic `command`/`exec` as [`../shell-bridge/Shell.v`](../shell-bridge/README.md), so `command_refines`/`query_transfer` apply without new composition proofs.

27 theorems/examples closed under the global context (`shell-expansion4-Audit-v2`). Parser for the new fragment is executable but **not** soundness-proved.

Modelled buffer/SIGPIPE, not kernel pipes; `PipeRR` is two `Relay`-shaped stages; one redirect on a bare atom; no `;`/`&&` composition in this directory (see [`extended/README.md`](extended/README.md)). Frozen `shell-bridge/` and `relay/` were read-only.

| File | Receipt (exit 0) | Content |
|---|---|---|
| `Pipeline.v` | `shell-expansion4-Pipeline-v23` | Bounded-buffer scheduler on `read32`/`write_block`; `PIPE_CAP = 4` |
| `Redirect.v` | `shell-expansion4-Redirect-v11` | `Direct`/`Redirect` over `relay_prim` |
| `Bridge2.v` | `shell-expansion4-Bridge2-v3` | `PipeRR` atom |
| `ParseExpansion.v` | `shell-expansion4-ParseExpansion-v1` | lexer/parser; **not** soundness-proved |
| `ShellExpansionAudit.v` | `shell-expansion4-Audit-v2` | 27 `Print Assumptions` closed |

Hashes: `results/source-sha256.txt`. No `Admitted`/`Axiom`/`Parameter`/`Conjecture`.

## Pipe semantics (`Pipeline.v`)

Finite buffer `pw_buf`, cap 4 (not POSIX `PIPE_BUF`). `pstep_fn` is one deterministic interleaving: prefer draining the consumer; else producer `read32` / push pending with backpressure / modelled SIGPIPE 141 if consumer gone; else consumer EOF. `pstep_fn_capacity` / `prun_capacity` for every step/fuel. Demos: `demo_backpressure_after_two_steps`, `demo_pipeline_success`, `demo_sigpipe` (same `"abcdef"`). `pipeline_status` matches bash pipefail on/off; `pipe_prim` hardwires pipefail off. Not modelled: fork/exec, real fds, N-stage, `$PIPESTATUS`, piping into `Mark`.

`Bridge2.v`: `pipe_command_refines`, `pipe_query_transfer`; `pipe_then_mark_exec`.

## Redirection (`Redirect.v`)

One trailing `>` or `>>` on a single atom. Writes diverted into `file_store : string -> list byte`. `os_reset` restores pre-command `delivered`. Empty path: status 1, atom does not run. `redirect_command_refines` / `redirect_query_transfer`. `redirect_within_seq`: `relay ; (mark > log)`. Not modelled: dup2, multiple redirects, `<`/`2>`, real filesystem.

## Text frontend (`ParseExpansion.v`)

Separate from frozen `Parse.v`/`Lex.v`. Covers bare `relay`/`mark` or `relay | relay`, optional trailing `> IDENT`/`>> IDENT` on a bare name. `vm_compute` accept/reject examples. `results/parseexpansion_bash_n.json`: `bash -n` accepts the rejected texts (fragment limit, not Bash invalidity). No soundness proof, no randomized execution differential.

## Replay

```sh
docker exec phase5-vst mkdir -p /home/coq/phase5/shell-expansion4
for f in Pipeline Bridge2 Redirect ParseExpansion ShellExpansionAudit; do
  docker cp research/libc-specs/phase5/shell-expansion/$f.v phase5-vst:/home/coq/phase5/shell-expansion4/$f.v
done
for f in Pipeline Bridge2 Redirect ParseExpansion ShellExpansionAudit; do
  uv run --no-project python research/libc-specs/phase5/run_vst.py --name shell-expansion-replay-$f --seconds 300 \
    --workdir /home/coq/phase5/shell-expansion4 -- \
    coqc -Q /home/coq/phase5/relay "" -Q /home/coq/phase5/shell-bridge "" $f.v
done
```

Requires compiled relay and shell-bridge. State Calculus correspondence (AST nodes for `|`/`>`) is not attempted.
