# Reject silently discarded deletion descriptions

This is a separate, conservative prototype against original Astrogator commit `7c62afa51986d87033af5112cdccd3b104b1c120`. It mitigates the concrete a03 natural-language translation failure documented in `../end_to_end/A03-MECHANISM.md`. It does not modify the original verifier, its published experiment results, or the permission prototypes.

`description-guard.patch` changes only the `DeleteFile` and `DeleteDir` semantic-analysis branches when an explicit `at` path is present. Those branches previously ignored any description before the final `file`/`directory` token. The prototype rejects a nonempty unused prefix instead of silently discarding it. For example, `delete contents of directory at /home/mydata/web` now parses successfully but fails semantic analysis with a diagnostic naming `contents of`.

Canonical `delete file at ...` and `delete directory at ...` remain supported. Without an explicit `at`, existing knowledge-base resolution is unchanged, including `delete postfix configuration file` and `delete zsh configuration directory for user=foo`. A knowledge-base description combined with an explicit path is conservatively rejected rather than silently treating the descriptor as redundant. This compatibility choice should be reviewed as a language-design decision; no claim is made that every redundant human description is erroneous.

## Actual validation

- Nine compiled OCaml regressions pass, including canonical file/directory/contents forms, both misleading contents prefixes, legitimate knowledge-base file/directory forms, and conflicting descriptive-plus-explicit-path forms.
- All 21 supplied queries and all 252 frozen translations were processed by the original and patched diagnostic binaries: **270 outputs are identical; exactly three change**.
- Those three are the compact-guide GPT a03 outputs in repetitions 0, 1 and 2. They change from successful lowering to semantic query rejection. All supplied queries and all 126 handbook translations remain unchanged.
- The patch applies cleanly to an isolated original-source copy and exactly reproduces the delivered source. Source, inputs, binaries and raw diagnostics are hashed.

A semantic query rejection means **unavailable**, not that a candidate program is proved erroneous. Applied to the existing a03 compact-GPT cohort, the guard would make 43 previous acceptances and 36 previous rejections unavailable per repeat; another 31 programs were already unavailable. These are projections from frozen query decisions, not a rerun or replacement of the main pipeline experiment. The guard prevents this particular silent interpretation but does not repair the query, prove preservation of user intent, or audit other action branches.

## Reproduction

Run `make_patch.py`, then `build.sh` in the bounded job slice with Docker-client `GOMAXPROCS=2`. The build uses the pinned original image in an isolated disposable container and saves a separate diagnostic executable. Run `replay.py` inside that image with the artifact root mounted at `/suite`, then run `check.py` on the host. The build's nine regressions are in `regressions.txt`; all 273 paired diagnostics and input/binary hashes are in `replay.json`; `summary.json` records the application and compatibility checks. No candidate playbooks are executed by this prototype.
