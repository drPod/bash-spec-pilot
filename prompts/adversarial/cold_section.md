<!--
  Wave-4 cold adversarial test-gen prompt.

  Lineage:
    - SAGA (Ma et al. 2025, arXiv 2507.06920) — homogenization-trap framing:
      same model writing impl + tests blinds to its own implementation
      assumptions. Cold flavor blinds the test-LLM to the impl: the model
      sees only the manpage, never the Rust source. The driver runs this
      template in a fresh session ID so no impl-gen tokens leak into
      reasoning state (Code-A1, Wang et al. 2026, zero-RL adaptation).
    - Boundary-value + equivalence-partition language inline per §18 of
      docs/research/adversarial_prior_art.md (manpage-anchored test design).
    - No expert persona (Hu et al. 2026, arXiv 2603.18507): personas hurt
      code/math accuracy.

  Slice scoping:
    `{{slice_name}}` is one of: errors | flags | environment | examples.
    The slice is a *thematic frame*, not a literal manpage section: mv's
    manpage has no ERRORS/ENVIRONMENT block. The model is told to focus on
    the slice while still reading the whole manpage.

  Output schema is identical to prompts/baseline/tests.md so run_tests.py
  and the classifier consume both with one parser.
-->

You are writing a Bash test suite targeting the **`{{slice_name}}`** slice of
a documented Unix utility. The suite will be executed twice: against the real
GNU binary (the oracle), and against an LLM-generated Rust re-implementation
of the same utility that *you have not seen*. The goal is to surface
documented behaviors that an off-the-shelf impl is likely to skip,
misinterpret, or implement inconsistently with the manpage.

# Slice focus

This run targets the `{{slice_name}}` slice. Interpret it as a thematic
frame, not a literal manpage section header:

{{slice_focus_hint}}

Read the full manpage below carefully, but bias test selection toward the
slice. Every test must be backed by language in the manpage — silence is
not a specification.

# Adversarial design

You are not writing easy-to-pass smoke tests. You are writing tests that an
impl writer who skimmed the manpage might trip on. Apply two techniques:

- **Boundary-value analysis.** For any documented quantity (count, depth,
  flag combination, exit code), test the value *and one beyond it*. For
  options that take an argument, exercise the smallest and largest
  documented inputs, the empty input, and the absent input.
- **Equivalence partitioning.** For each documented category of input or
  flag interaction, pick one representative test plus one test from the
  adjacent category whose behavior the manpage distinguishes.

When the manpage documents an *error* condition (the utility must exit
nonzero), set `expected_to_fail: true`. Aim for at least 3 such tests per
suite. These are the strongest single signal for differential testing.

# Per-test requirements

Every test:

- Is a self-contained Bash script.
- Begins with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Creates its own temporary working directory via `mktemp -d` and removes
  it on exit via `trap '...' EXIT`.
- Invokes the utility through the `$UTIL` environment variable, never the
  literal command name. Always quoted: `"$UTIL"`.
- Asserts exactly one thing about post-state. One assertion per test.
- Uses absolute paths inside `$tmpdir`.
- Exits 0 on pass, nonzero on fail. On failure, print one short diagnostic
  line to stderr first.
- Tests only documented behavior. If the manpage is silent on a point, do
  not test it.
- For `expected_to_fail: true` tests: capture the utility's exit code
  (`set +e; "$UTIL" ...; status=$?; set -e`) and assert `[[ $status -ne 0
  ]]`. The test body itself still exits 0 iff the utility errored exactly
  as documented.

# Suite-level requirements

- **10 to 25 tests total.** Smaller than the baseline suite — this slice
  is targeted, not exhaustive.
- Documented error cases covered via `expected_to_fail: true`.
- Skip the same areas as the baseline: SELinux, locale, ACLs, xattrs,
  sparse files, `--reflink=`, signals, network.
- Every `exercises` field must name the specific documented behavior the
  test is probing (e.g. `"-T with directory target: documented to fail"`).

# Output format

Respond with exactly one fenced JSON code block, no prose before or after.

```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["tests"],
  "properties": {
    "tests": {
      "type": "array",
      "minItems": 10,
      "maxItems": 25,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["filename", "body", "exercises", "expected", "expected_to_fail"],
        "properties": {
          "filename": {
            "type": "string",
            "pattern": "^[0-9]{3}_[a-z0-9_]+\\.sh$"
          },
          "body": {"type": "string"},
          "exercises": {"type": "string"},
          "expected": {"type": "string"},
          "expected_to_fail": {"type": "boolean"}
        }
      }
    }
  }
}
```

# Manual page

{{manpage}}
