# Extended parser/semantics: pipe + redirect + `;`/`&&`/`||`/parens

Close four gaps from `shell-expansion-4`: parser soundness, redirect of a piped result, composition with `;`/`&&`/`||`/parens, and a real-execution test (not only `bash -n`). Unify `atom2` and `ratom` as `yatom`.

`parse_program3_sound` checked; 30 `Print Assumptions` closed (`shellexp8-ComposeAudit-v1`). 12 directed container execution cases (hand-coded expectations, not a Coq oracle).

Still modelled pipes (two Relay stages); no redirect of compound commands; parser completeness unproved; 12 directed cases, no randomized sweep. Parent `Pipeline.v`/`Redirect.v` frozen.

| File | Receipt (exit 0) | Content |
|---|---|---|
| `Compose.v` | `shellexp8-Compose-v16` (1.14 s) | `yatom`, `yredirect_prim`, grammar, parser, `parse_program3_sound` |
| `ComposeAudit.v` | `shellexp8-ComposeAudit-v1` (4.74 s) | 30 closed assumptions |

`results/receipts.json`, `results/source-sha256.txt`. Frozen expansion files recompiled unmodified in `/home/coq/phase5/shell-expansion8`.

## Generalized redirect

`yatom := YDirect a2 | YRedirect append path a2` wraps `atom2` (bare or `PipeRR`). `pipe_prim_delivered_extra` generalizes `relay_prim_delivered_extra`. `pipe_redirect_witness` / `pipe_redirect_observations`: `"abcdef"` / `PIPE_CAP=4` file `"out"` equals `demo_bytes`. `yredirect_relay_gt_out_matches_old` reproduces `redirect_truncate_witness`. `YRedirect` still wraps one `atom2`, not an arbitrary `command`.

## Grammar and soundness

Four-level `rcmd_derives` / `uandor_derives` / `ulist_derives` / `ubody_derives` mirror `Parse.v`; bottom is `redir_derives` (bare, or `relay | relay`, optional `>`/`>>`). `|` and redirect bind inside a unit, tighter than `&&`/`||` than `;`. Completeness not proved. `compose_command_refines` / `compose_query_transfer` are instantiations; the new content is the grammar producing mixed trees.

Rejected (not mis-parsed): `relay | mark`, three-stage pipe, double redirect, unknown name, `(relay | relay) > out` (parens group; `relay | relay > out` without parens is the attachment level).

## Execution tests

`validate_extended.py` compiles `phase2/relay.c` through `run_vst.py` only. Historical host-unwrapped JSON kept; corrected: `results/bash_execution_validation.corrected12.json`. Cases include bare relay/mark, `relay | relay`, truncate/append, `relay | relay > out`, `relay ; mark > log`, `relay && mark`, closed-stdin read error (status 1 from `relay.c`), and `yes | head -c 2000000 | relay | true` for SIGPIPE status 141 (convention check, not `PipeRR` end-to-end).

`relay.c` vs CompCert `relay.i` hashes differ; substring checks are not translation identity.

## Coq pitfall (parser tactics)

Non-recursive `parse_redir` can fully compute under `simpl` on an abstract tail when the head token already rejects. A `try (destruct (parse_redir …))` then fails silently. Handle always-reducible branches with `discriminate`; destruct only the `UIdent` branch.

## Replay

```sh
docker exec phase5-vst mkdir -p /home/coq/phase5/shell-expansion8
for f in Pipeline Bridge2 Redirect ParseExpansion; do
  docker cp research/libc-specs/phase5/shell-expansion/$f.v phase5-vst:/home/coq/phase5/shell-expansion8/$f.v
done
for f in Compose ComposeAudit; do
  docker cp research/libc-specs/phase5/shell-expansion/extended/$f.v phase5-vst:/home/coq/phase5/shell-expansion8/$f.v
done
for f in Pipeline Bridge2 Redirect ParseExpansion Compose ComposeAudit; do
  uv run --no-project python research/libc-specs/phase5/run_vst.py --name shellexp8-replay-$f --seconds 180 \
    --workdir /home/coq/phase5/shell-expansion8 -- \
    coqc -Q /home/coq/phase5/relay "" -Q /home/coq/phase5/shell-bridge "" $f.v
done
python3 research/libc-specs/phase5/shell-expansion/extended/validate_extended.py
```
