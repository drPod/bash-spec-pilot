# Historical audit: `utility-leaf-adequacy-12` (quota exit)

**Local-stage result only.** Session `utility-leaf-adequacy-12` **failed by session-limit** (exit 1). **Not** a completed POST theorem at that time. **No** `JuicyPost.v` and **no** leaf12 compiler receipts from that job. Quota exit and ProbePost are not `iow_juicy_dry_post`.

**Later jobs closed** `iow_juicy_dry_post` and `iow_juicy_dry_specs` ([`README.md`](README.md) job 13–14). Do not treat this file as current theorem status.

## Theorem state *at audit time*

- **Then missing:** `iow_juicy_dry_post`; `iow_juicy_dry_specs` record.
- **Already closed (job 11):** `iow_juicy_dry_pre`, `dry_spec_exit`, ErrnoLoad, PostLemmas, PostLemmas2.
- **Probe only:** `utility-leaf11-probe-post-1` (ProbePost.v) — residual `exists phi2 phi3, join …` on the read branch; not Qed.

Source sha256 at audit (job 11): ErrnoLoad `4cbe7ee6…be57fa`, JuicyPre `ec7c9bcc…2f9bca`, PostLemmas `ad343911…b2194c`, PostLemmas2 `9c19879b…6352f6`, JuicyDry `fc9f3af3…2d0b6f`, ErrnoBridge `7f3229c3…53d292`, MemAdequacy `b87e9e61…4ea34ac`, DryPost `828b7b2c…1ad62d`, AssertionBridge `36cf021d…6acf42`, Specialize `d3216a1e…133b5d`. No `coqc` in this audit.
