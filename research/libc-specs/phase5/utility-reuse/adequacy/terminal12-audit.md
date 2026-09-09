# terminal12-audit (Pi, read-only)

**Verdict:** `utility-leaf-adequacy-12` **failed by session-limit** (exit 1,
reset 11:30 UTC). **Not** a completed POST theorem. **No** `JuicyPost.v`.
**No** leaf12 compiler receipts. Do not treat quota exit or ProbePost as
`iow_juicy_dry_post`.

## Theorem state

- **Missing:** `iow_juicy_dry_post`; `iow_juicy_dry_specs` record.
- **Closed (job 11, ROOT-RECEIPT-AUDIT all exit/timing 0, hash_ok):**
  `iow_juicy_dry_pre`, `dry_spec_exit`, ErrnoLoad, PostLemmas,
  PostLemmas2 (see README table).
- **Probe only:** `utility-leaf11-probe-post-1` (ProbePost.v) — residual
  `exists phi2 phi3, join … /\ (EX x0, PROP/RETURN/SEP …) phi2 /\ necR phi1 phi3`
  on the read branch. That is the assembly goal, not a Qed.

## Source sha256 (audit time; unchanged vs job 11)

ErrnoLoad `4cbe7ee6…be57fa`, JuicyPre `ec7c9bcc…2f9bca`,
PostLemmas `ad343911…b2194c`, PostLemmas2 `9c19879b…6352f6`,
JuicyDry `fc9f3af3…2d0b6f`, ErrnoBridge `7f3229c3…53d292`,
MemAdequacy `b87e9e61…4ea34ac`, DryPost `828b7b2c…1ad62d`,
AssertionBridge `36cf021d…6acf42`, Specialize `d3216a1e…133b5d`.

No coqc this audit. Resume after 11:30 UTC from job-11 NEXT.
