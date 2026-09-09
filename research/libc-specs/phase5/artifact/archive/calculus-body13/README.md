# Immutable CalculusBody source archive (calculus-body13)

Distinct from `../CalculusNested.evaluation-frozen.lean` (evaluation-era hash
`36525e18cde92225dcaef9d30077565f1124a7c96782b22ef3e3366c75783587`). That file is
**unchanged**. This directory is the complete Lean *source* closure needed to rebuild the
accepted `CalculusBody.lean` / `CalculusBodyReceipts.lean` module after
`calculus13-step-repair` (2026-09-08).

## Files and sha256 (byte copies of live integration/lean at archive time)

| file | sha256 |
|---|---|
| CalculusBody.lean | `481d8d61041e2893697c03c2cc5db7cc92d1f7c8389041164d4b43ff3c3aa5c6` |
| CalculusBodyReceipts.lean | `5b89dced00bf7eb04420bb1483fe1a2d4e01c705b31f8ff5c9e7a869091cc344` |
| CalculusExport.lean | `d11ba63f0bd8f465bf60f489c3b5daab9bf4f46bc4c3f051361e8aae4083a763` |
| CalculusNested.lean | `e2a7cffb206b3669da4bb56961b22d6d676063feeebade3212be822ee1fd651d` |
| lean-toolchain | `efac0b94923b2d8b6840cd35be9177ad0fc5ab2332f4f4311c98712cee92fdee` (`leanprover/lean4:v4.31.0`) |
| export_input__byte_relay_exec.tsv | `5b3af9eae37aebcb02765294bcd7718262085f0665979f5e48c91d121c25a281` |

`CalculusNested.lean` here is the **body-era live** nested model (hash `e2a7cffb…`), not the
evaluation freeze. Stdlib `Std.Data.String.ToNat` comes from the pinned toolchain, not this
tree. No `lake-packages`, no network.

## Provenance

- Repair acceptance: Pi `calculus13-step-repair` REPORT — `lake build CalculusBody` exit 0,
  log `b85945e1…`; `CalculusBody.lean` `481d8d61…`; receipts file unmodified `5b89dced…`;
  axioms `propext` / `Classical.choice` / `Quot.sound` only; TSV line hashes
  `8fcd4fe0…` / `7af2a25a…`.
- Terminal audit (`calculus13-terminal-audit`) recorded the **pre-repair** FAIL (`simp`
  max-steps on `relay_inner_step`); do not treat that audit log as the accepted build.
- Sources copied from `phase5/integration/lean/` and
  `phase5/calculus-correspondence/results/export_input__byte_relay_exec.tsv` (read-only;
  calculus/proof/ledger/evaluation not edited by the artifact worker).

## Scope (honest)

Kernel-checked: export token identity (`writeBlock_parse`/`_render`, `relay_parse`/`_render`)
and whole-`write_block` body/assert theorems plus **one** `relay_inner_step`. Runtime `#eval`
in receipts is **finite text→token identity**, not a theorem tokenizer. **Not** relay loop
termination and **not** general OCaml correspondence. `range:0:4611686018427387903` /
`range-list:0:255` wrappers are in the untyped TSV snapshot; typed export
(`export_input__byte_relay_exec_typed.tsv`, sha256
`e0a90fc1d229b6854f20433a637bb01bcd9da74274ef69bcb4fdca373bbf7761`) is a **different** file
and is not this archive.

## Replay

`lean_calculus_body_replay` in `../../replay.py` stages a **fresh isolated** Lake project from
these files only, under `~/.cache/bash-spec-pilot/phase3-compiler.lock`, no `lake update`.
