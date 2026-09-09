# Shell expansion: pipes and one output redirection, over the actual relay contract

Date: 2026-09-07. Worker: Claude CLI (shell-expansion-4). Everything below is checked by Coq
8.20.1 in the shared `phase5-vst` container (CompCert 3.15, VST 2.15) through `../run_vst.py`.
Nothing is committed, nothing upstream is touched. `shell-bridge/`, `relay/` and the
calculus/integration trees are FROZEN and were only read, never edited, from this worker.

## Why a new directory

The user's requirement for this assignment was specifically PIPES and at least one
REDIRECTION, "under the existing `command_refines`/query discipline" (`shell-bridge/Shell.v`,
unchanged). `Shell.v`'s own grammar (`call`/`seq`/`and_then`/`or_else`) and its two atoms
(`Relay`, `Mark`) have neither; `Parse.v`'s lexer explicitly rejects `|` and `>` as out of its
accepted fragment (`shell-bridge/README.md` "Remaining limits"). This directory adds both,
as NEW atoms of the same generic `command`/`exec`, so `Shell.v`'s own `command_refines` and
`query_transfer` (universally quantified over the atom and state types) already cover any
composition without new proof.

## Files (final receipts; earlier development iterations, including compile-error attempts, are preserved unmodified alongside these in the same runs directory)

| File | Receipt (exit 0) | sha256 | Content |
|---|---|---|---|
| `Pipeline.v` | `shell-expansion4-Pipeline-v23` (0.6 s, 485,060 KiB) | `60db44d4...d541d72` | Bounded-buffer, byte-chunked pipe scheduler (`pworld`/`pstep_fn`/`prun`), built directly on `Protocol.v`'s `read32`/`write_block` (unchanged); capacity invariant; concrete backpressure/EOF/SIGPIPE traces; pipefail combinator |
| `Redirect.v` | `shell-expansion4-Redirect-v11` (0.59 s, 484,448 KiB) | `c2c5279e...f36048` | `Direct`/`Redirect` atoms (a file-store layered on `relay_prim`, unchanged) as an instantiation of `Shell.v`'s `command`/`exec`; truncate/append/restoration/error examples; one `seq`-composed example |
| `Bridge2.v` | `shell-expansion4-Bridge2-v3` (0.47 s, 423,648 KiB) | `cd71b25b...8e22f718150a` | `PipeRR`, wrapping one `Pipeline.v` run, as another atom of the same `command`/`exec`; one `and_then`-composed example |
| `ParseExpansion.v` | `shell-expansion4-ParseExpansion-v1` (0.49 s, 438,364 KiB) | see `results/source-sha256.txt` | Executable lexer/parser for one pipe-or-bare unit plus one optional `>`/`>>` target, into `atom2`/`ratom`; NOT soundness-proved (see its own header and "What this does not establish" below) |
| `ShellExpansionAudit.v` | `shell-expansion4-Audit-v2` (3.97 s, 512,452 KiB) | see `results/source-sha256.txt` | `Print Assumptions` of all 27 theorems/examples across all four files above: every line "Closed under the global context" |

Machine-readable receipt list and source hashes: `results/receipts.json`, `results/source-sha256.txt`.
No `Admitted`, `Axiom`, `Parameter` or `Conjecture` anywhere in these files (checked by grep,
consistent with the `Print Assumptions` audit above).

## Pipe semantics (`Pipeline.v`)

**The model, stated precisely, once, here** (not re-litigated per theorem):

- **Finite buffer.** The channel `pw_buf` is a plain `list byte`, capped at `PIPE_CAP = 4`.
  This is deliberately far below POSIX `PIPE_BUF` (4096): no claim about a real pipe's
  capacity is made, only that SOME finite cap is enforced and actually exercised by a short
  example. `pstep_fn_capacity` / `prun_capacity` prove the cap holds after every step and
  every fuel value, not just in the examples below.
- **Scheduler.** `pstep_fn` is ONE deterministic, byte-chunked interleaving, not an
  unconstrained nondeterministic relation: (1) if the buffer is non-empty and the consumer
  hasn't halted, drain one consumer `write_block` call; (2) else if the producer hasn't
  halted, do one `read32` call, or push its pending carry into the buffer (partial if the
  buffer has less room than the carry — this IS backpressure), or halt at the modelled
  SIGPIPE status if the consumer is already gone; (3) else, if the buffer is empty and the
  producer has halted, the consumer sees EOF; (4) otherwise no step. This is "prefer draining
  the reader"; it is not claimed to be the only correct scheduling choice, only a genuine
  byte-level interleaving that a real kernel's freedom to schedule would also permit.
- **Backpressure / partial write.** `read32` (unchanged, up to 32 bytes/call) can return more
  bytes than the 4-byte buffer has room for; only what fits is pushed, the remainder is put
  back on the producer's own `unread` list and re-read (as new bytes) once room frees up.
  `demo_backpressure_after_two_steps` shows this concretely: after one read of 6 bytes and one
  push, only 4 bytes are in the buffer and 2 are still sitting on the producer's input — a
  state a naive "just concatenate both sides' streams" model has no room to represent.
- **EOF.** The producer's own `read32` returning 0 is `Reach.v`'s own EOF convention,
  unchanged. The consumer sees status 0 once the buffer is drained AND the producer has
  halted — the condition under which a real pipe `read()`, after the writer closes, returns 0.
- **SIGPIPE — modelled, not delivered.** If the consumer has already halted and the producer
  still has queued bytes, the producer halts at status 141 (bash's 128+SIGPIPE) and the queued
  bytes are recorded in `pw_prod_lost`, never silently dropped (`demo_sigpipe`). This is a
  deterministic function step taken under a stated condition; there is no asynchronous signal,
  no interrupted instruction pointer, no real `SIGPIPE` delivery mechanism.
- **pipefail.** `pipeline_status pipefail_on left right` is a total function matching bash's
  two-stage rule exactly (`pipeline_status_examples`). `Bridge2.v`'s `pipe_prim` hardwires
  pipefail OFF (bash's default): the pipeline's own status is the CONSUMER's, never the
  producer's, matching `and_then`/`seq` composition downstream seeing only `rc`.
- **Precedence.** Real bash: a pipeline is a single unit at the level `&&`/`||` connect, i.e.
  `|` binds tighter than `&&`, `||`, `;`. `PipeRR` is one atom (`Bridge2.v`), so it already sits
  at exactly that tightest level inside `Shell.v`'s existing `call`/`and_then`/`or_else`/`seq`
  grammar; no new precedence rule needed to be stated or proved.
- **What is explicitly NOT modelled:** process creation/exec, real fds/dup2, the actual kernel
  pipe capacity or `SIGPIPE` delivery mechanism, more than two pipeline stages, `$PIPESTATUS`,
  and any pipeline stage other than the two `Relay`-shaped endpoints used here. `PipeRR`'s two
  endpoints are both `Relay`-shaped (one reads the ambient stdin, one writes the ambient
  stdout); piping into `Mark` (which has no stdin of its own) is out of scope.

Checked in `Pipeline.v`: `pstep_fn_capacity`, `prun_capacity` (the buffer bound, for every
step/every fuel); `demo_backpressure_after_two_steps`, `demo_pipeline_success`, `demo_sigpipe`
(concrete `vm_compute` traces of backpressure, clean completion, and modelled SIGPIPE, all
against the SAME "abcdef" input); `pipeline_status_examples` (pipefail on/off, bash's rule).

`Bridge2.v` embeds one `PipeRR` run as an atom `atom2 := FromShell (a : atom) | PipeRR` of
`Shell.v`'s generic `command`/`exec` (`pipe_prim`), so `command_refines`/`query_transfer`
already apply (`pipe_command_refines`, `pipe_query_transfer` — direct instantiations, no new
proof). `pipe_then_mark_exec` is one worked composition: `PipeRR ; mark` from the pipeline's
own "abcdef" example, its final state exactly `demo_pw0`'s completed run plus the mark byte.

## Redirection semantics (`Redirect.v`)

**Scope:** ONE trailing redirection (`>` or `>>`) on a single atom (`relay > out`,
`relay >> out`); not a compound command, not more than one redirection, no `<`, no `2>`.

- **File-descriptor binding.** For the duration of the redirected atom's own execution, its
  writes are diverted from the ambient, terminal-visible `delivered` stream into a NAMED
  file's content (`file_store : string -> list byte`, a total map). This reuses the relay
  atoms' own byte-conservation fact (`relay_step_shape`, `Shell.v`, unchanged) to learn exactly
  which bytes the atom produced (`extra`), rather than inventing new write semantics.
- **Restoration.** `os_reset` puts the PRE-command `delivered` value back once the atom
  finishes, keeping the unread input / schedules / call counters as the atom's own run advanced
  them. `redirect_truncate_observations` shows the terminal-visible stream is unchanged after
  the redirected atom ran; `redirect_then_direct_sees_restored_stream` and `redirect_within_seq`
  show a SUBSEQUENT ordinary atom sees the restored stream, not the file — redirection does not
  leak past the one atom it is attached to, because there is no state left pointing at the file.
- **Truncate vs append.** Decided once, at "open" time, by a boolean flag: `>` starts from `[]`
  (drops prior content), `>>` starts from the file's current content. Both then simply append
  the atom's output. `redirect_append_vs_truncate` runs the SAME relay call against the SAME
  pre-existing file content ("xy") under both flags and gets different file contents — a real
  semantic difference, not a rename.
- **Error case.** An empty filename fails to open: status 1, the underlying atom does not run,
  the state is untouched (`redirect_empty_path_rejected`, `redirect_open_failure`).
- **Composition.** `ratom := Direct (a : atom) | Redirect (append : bool) (path : string) (a :
  atom)` is one more instantiation of `Shell.v`'s `command`/`exec`; `redirect_command_refines` /
  `redirect_query_transfer` are direct instantiations of `command_refines`/`query_transfer`.
  `redirect_within_seq` is the worked example: `relay ; (mark > log)` — the SEQUENCE's final
  terminal-visible stream is exactly the first command's alone, even though a second command
  ran afterward and genuinely wrote a byte (just not to the terminal).
- **What is NOT modelled:** real fd numbers/dup2, more than one redirection per atom,
  redirecting a compound command, input redirection, `2>`, and any interaction with a real
  filesystem (`file_store` is a pure map, not backed by any OS call).

## Text frontend (`ParseExpansion.v`)

A NEW, separate lexer/parser (not a change to the frozen `shell-bridge/Parse.v`/`Lex.v`, whose
own fragment still excludes `|`/`>`/`>>` by design) covering exactly: a bare `relay`/`mark`, or
`relay | relay` (matching `PipeRR`'s two-stage scope), with an optional trailing `> IDENT` or
`>> IDENT` on a BARE name only (redirecting a pipe result needs `ratom` generalized to wrap
`atom2` instead of `atom`, not done here — see "Interface"/NEXT.md). Checked by `vm_compute`
against literal texts: `parse_relay_pipe_relay`, `parse_relay_gt_out`, `parse_relay_gtgt_log`,
`parse_mark_bare` accept and produce the expected AST; `parse_rejects_oror`,
`parse_rejects_unknown_name`, `parse_rejects_three_pipe`, `parse_rejects_double_redirect`
reject. `results/parseexpansion_bash_n.json` records that `bash -n` accepts every one of the
rejected texts too — the rejections are this fragment's OWN scope limit, not a claim that Bash
itself considers them invalid. `parse_relay_gt_out_runs_as_checked` ties the parsed text
directly to `Redirect.v`'s own checked `redirect_truncate_witness`/`_observations`.

**Explicitly NOT done:** no soundness proof (`Parse.v`'s own `parse_program_sound` is the
model to follow; not attempted here under the time budget — see `ParseExpansion.v`'s header),
no composition with `;`/`&&`/`||`/parens (would need `ratom`/`atom2` unified first), no
randomized differential test against real Bash (there is no real `relay`/`mark` binary to run
bash against here; `results/parseexpansion_bash_n.json`'s `bash -n` check is syntax-only,
weaker than `shell-bridge/validate_text.py`'s actual-execution comparison).

## What this does not establish

- Bash's actual process/fork/exec model, real fd tables, or the kernel's real pipe
  implementation and `SIGPIPE` delivery — all named as MODELLED, not real, above.
- Parser soundness (see "Text frontend" above) and any composition of the new fragment with
  the existing `;`/`&&`/`||`/parens grammar. `Bridge.v`'s existing `relay_command` text path
  is UNCHANGED and still only covers the old fragment on its own.
- Completeness or uniqueness of anything; `PipeRR`'s two stages are both `Relay`-shaped
  (no general N-stage, heterogeneous pipeline); `Redirect` covers one atom, not a subshell.
- Any claim that this is "real Bash concurrency": `pstep_fn` is a single deterministic
  function: it is a genuine byte-level interleaving of two schedules, not two OS processes.

## Interface for a later State Calculus correspondence worker

`atom2` (`Bridge2.v`) and `ratom` (`Redirect.v`) are ordinary instantiations of `Shell.v`'s
`command`/`exec`, exactly like the original `atom := Relay | Mark`. A worker connecting
Aaron's State Calculus interpreter (`calculus-bytes`/`calculus-resume-3`, frozen, unrelated to
this directory) to a pipe/redirect-aware AST would need: (1) State Calculus AST nodes for
`|`/`>`/`>>` (none exist today — `calculus-bytes/build/bash-verifier/lib/frontend/ast.ml` has
no pipe/redirect constructor); (2) a `map_command`-style translation (`shell-bridge/Bridge.v`'s
pattern) from those nodes to `atom2`/`ratom`; (3) the correspondence theorem itself, relating
the interpreter's own byte/state observations to `pipe_prim`/`redirect_prim`. None of that is
attempted here; this directory only supplies the target (`atom2`, `ratom`) to translate into.

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

Requires `Protocol`, `Reach`, `ReachExamples`, `Conservation` compiled in
`/home/coq/phase5/relay` and `Shell`, `Parse`, `Bridge` compiled in `/home/coq/phase5/shell-bridge`
(both frozen, see their own READMEs for replay).

## Assumptions

`ShellExpansionAudit.v` (receipt `shell-expansion4-Audit-v2`, `results/receipts.json`) runs
`Print Assumptions` on all 27 theorems/examples across `Pipeline.v`/`Redirect.v`/`Bridge2.v`/
`ParseExpansion.v`: every line reads "Closed under the global context". No axiom, no
`Admitted`, no project-local hypothesis was introduced by this worker; every theorem above is
`Qed`-closed against `relay`/`shell-bridge`'s own already-frozen, already-audited facts
(`relay_step_shape`, `success_outcome`, `command_refines`, `query_transfer`, `deliver`, etc.).
