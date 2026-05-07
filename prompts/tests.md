<!--
  Prompt: man-page -> Bash test suite.

  Schulhoff (Prompt Report, arXiv 2406.06608) techniques applied:
    - Role + Task framing (Sec. 2.2.1.3) anchored on "differential testing
      between two implementations of the same documented utility".
    - Structured JSON output with a defined schema (Sec. 2.2.5; Tam et al.
      2024 rebuttal cited in the survey). The schema includes per-test
      `exercises` and `expected` fields explicitly to aid downstream
      failure-taxonomy analysis - this is the "answer engineering" angle
      from Sec. 2.5.
    - Decomposition (Plan-and-Solve, Sec. 2.2.2). Reasoning models are
      asked to enumerate flags from the man page first, then pick which
      to test, then write tests. The reasoning is internal when running
      against gpt-5.5 (a reasoning model); the prompt asks for the result
      only, not a visible reasoning trace.
    - Negative constraints (test-quality requirements) up front.

  Deliberately rejected:
    - "Think step by step" / explicit CoT trigger in the prompt body.
      gpt-5.5 is a reasoning model and decides its own reasoning depth;
      adding a CoT trigger duplicates that and Schulhoff (Sec. 2.2.2)
      offers no zero-temperature evidence that CoT triggers help on
      structured-extraction tasks.
    - "Pretend you are a QA engineer..." style persona prompts.
      Schulhoff notes role prompting helps style; it does not help here.

  Versioning: driver writes sha256(this file) to log.jsonl as
  `prompt_template_sha256`.
-->

You are writing a differential test suite for a documented Unix utility.
The same suite will be executed twice - once against the real system
binary (the oracle), and once against an LLM-generated re-implementation.
A test that passes against the oracle and fails against the
re-implementation reveals a bug in the re-implementation. A test that
fails against the oracle reveals a misreading of the man page.

# Task

Read the man page below carefully. Identify the documented flags and
behaviors. Produce a Bash test suite that exercises that documented
behavior on a Linux/GNU userland system.

# Per-test requirements

Every test:

- Is a **self-contained Bash script**.
- **Begins with** `#!/usr/bin/env bash` and `set -euo pipefail`.
- Creates its own temporary working directory via `mktemp -d` and removes
  it on exit via `trap '...' EXIT`.
- Invokes the utility through the **`$UTIL` environment variable**, never
  the literal command name. Always quoted: `"$UTIL"`.
- **Asserts exactly one thing** about post-state - one assertion per
  test. (Asserting an exit code AND a stderr substring against the same
  invocation counts as one assertion if both express the same expected
  behavior; do not bundle independent assertions.)
- **Uses absolute paths** inside `$tmpdir`. Do not rely on `cd` leaking
  out of the test or out of subshells.
- **Exits 0 on pass, nonzero on fail.** On failure, print one short
  diagnostic line to stderr first.
- Tests **only documented behavior**. If the man page is silent on a
  point, do not test it - silence is not a specification.

# `expected_to_fail`: documented-error tests

Each test carries a per-test boolean `expected_to_fail`.

- Set `expected_to_fail: false` for normal positive tests. The test body
  runs the utility, asserts the expected post-state, and exits 0 on success.
- Set `expected_to_fail: true` when the test exercises a **documented
  error condition** — i.e. the man page itself states the utility must
  fail (nonzero exit) on this input. Examples:
    * passing a nonexistent SOURCE,
    * `cp -T <src> <existing-directory>` with `-T` / `--no-target-directory`,
    * `--update=none-fail` against an existing destination,
    * any "diagnose and induce a failure" the man page commits to.

  In `expected_to_fail: true` tests the **test body itself still exits 0
  iff the utility errored exactly as documented**. Capture the utility's
  exit code (`set +e; "$UTIL" ...; status=$?; set -e`) and assert
  `[[ $status -ne 0 ]]`. Do not let an unguarded utility call propagate a
  nonzero exit out of the test through `set -e` — that conflates "real
  utility errored as documented" with "the test itself crashed".

  These tests are first-class evidence: a real utility that errors as
  documented is the strongest possible behavioral signal we can extract
  from the man page.

# Suite-level requirements

- **15 to 30 tests total.** Quality over quantity.
- **At least one positive test per major flag** the man page documents.
- Documented edge cases (e.g. trailing slashes, missing files,
  type mismatches, permission errors that the man page mentions).
- Documented **error cases** - covered via `expected_to_fail: true` tests
  per the spec above. Aim for at least 3 of these in any suite.
- Skip the same areas as the implementation prompt: SELinux, locale,
  ACLs, xattrs, sparse files, `--reflink=`, signals, network. Tests
  that depend on these are not portable across the experiment's
  environments.

# Output format - strict

Respond with exactly one fenced JSON code block, no prose before or
after. The JSON must validate against this schema:

```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["tests"],
  "properties": {
    "tests": {
      "type": "array",
      "minItems": 15,
      "maxItems": 30,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["filename", "body", "exercises", "expected", "expected_to_fail"],
        "properties": {
          "filename":  {
            "type": "string",
            "pattern": "^[0-9]{3}_[a-z0-9_]+\\.sh$",
            "description": "NNN_short_description.sh; 3-digit zero-padded sequence"
          },
          "body":      {
            "type": "string",
            "description": "full Bash test script, starting with shebang"
          },
          "exercises": {
            "type": "string",
            "description": "<=120 chars naming the flag/behavior under test"
          },
          "expected":  {
            "type": "string",
            "description": "<=120 chars naming the post-state being asserted"
          },
          "expected_to_fail": {
            "type": "boolean",
            "description": "true iff this test exercises a documented error case (the real utility is expected to exit nonzero, and the test body asserts that). Aim for at least 3 of these per suite."
          }
        }
      }
    }
  }
}
```

The `body` field must contain the raw Bash script (newlines preserved,
no JSON-escaping beyond what JSON encoding requires). Do not wrap
`body` in additional Markdown fences.

# Manual page

{{manpage}}
