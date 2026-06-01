<!--
  Wave-4 post-hoc adversarial test-gen prompt.

  Lineage:
    - WhiteFox / ACH whitebox lineage — model sees both the manpage AND
      a frozen LLM-generated Rust impl, and is tasked with finding
      documented behaviors the impl handles incorrectly or skips.
    - Architectural separation: runs in a fresh session ID, separate from
      the impl-gen session (Code-A1, Wang et al. 2026). The impl text is
      injected as a string, not via shared reasoning state.
    - No expert persona (Hu et al. 2026).

  Schema identical to prompts/baseline/tests.md and cold_section.md so
  run_tests.py and the divergence classifier consume them uniformly.
-->

You are reviewing an LLM-generated Rust re-implementation of a documented
Unix utility against its manpage. Your job is to produce a Bash test suite
that surfaces documented behaviors the implementation **handles incorrectly,
inconsistently, or not at all**.

The same suite will be executed against the real GNU binary (the oracle)
and against the Rust re-implementation. A test that the oracle passes and
the re-implementation fails is the headline signal: a divergence backed by
the manpage.

# How to read the impl

The Rust source is below. Read it for what it does *and what it does not
do*:

- Flags accepted by the CLI parser but with no semantic effect.
- Documented behaviors not represented in any code path.
- Branches that diverge from the manpage's stated semantics (off-by-one
  on depth limits, wrong exit code on documented errors, inverted flag
  semantics, missing error cases).
- Edge cases the manpage commits to but the impl skips (empty inputs,
  trailing slashes, type mismatches, permission errors, special-character
  filenames inside the documented set).

You may *cite the impl* by behavior in the `exercises` field, but every
test must be backed by manpage language. Tests that "the impl is wrong
about X" must come with a clear statement of what the *manpage* says X
must do. Hallucinated specs (tests that assert behavior the manpage does
not commit to) are explicitly out of scope.

# Per-test requirements

Every test:

- Is a self-contained Bash script.
- Begins with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Creates its own temporary working directory via `mktemp -d` and removes
  it on exit via `trap '...' EXIT`.
- Invokes the utility through the `$UTIL` environment variable, never the
  literal command name. Always quoted: `"$UTIL"`.
- Asserts exactly one thing about post-state.
- Uses absolute paths inside `$tmpdir`.
- Exits 0 on pass, nonzero on fail. On failure, print one short diagnostic
  line to stderr first.
- Tests only documented behavior, even when targeting an impl bug.
- For `expected_to_fail: true` tests: capture the utility's exit code
  (`set +e; "$UTIL" ...; status=$?; set -e`) and assert `[[ $status -ne 0
  ]]`. The test body itself still exits 0 iff the utility errored exactly
  as documented.

# Suite-level requirements

- **10 to 25 tests total.**
- At least 3 `expected_to_fail: true` tests covering documented errors.
- Skip the same areas as the baseline: SELinux, locale, ACLs, xattrs,
  sparse files, `--reflink=`, signals, network.
- Every `exercises` field names the specific documented behavior under
  test (e.g. `"-i prompts for overwrite even on stdin redirect: documented"`).

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

# Frozen Rust implementation under test

`Cargo.toml`:

```toml
{{rust_cargo_toml}}
```

`src/main.rs`:

```rust
{{rust_main_rs}}
```
