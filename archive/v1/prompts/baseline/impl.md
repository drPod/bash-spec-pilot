<!--
  Prompt: man-page -> Rust implementation.

  Schulhoff (Prompt Report, arXiv 2406.06608) techniques applied:
    - Plain "Role + Task" framing (Sec. 2.2.1.3 "Role Prompting"). Survey
      reports role prompting may improve benchmark accuracy and shapes
      open-ended outputs. Used here to anchor on "GNU userland".
    - Output-format constraint via JSON Schema (Sec. 2.2.5 / Tam et al.
      2024 rebuttal in survey). Schulhoff cites evidence that structuring
      outputs can improve, not degrade, performance.
    - Decomposition via "first analyze, then produce" framing (Sec. 2.2.2
      "Plan-and-Solve" Wang et al. 2023f). The model is asked to think
      about the man page (in its own internal reasoning when used with a
      reasoning model) before emitting the schema.
    - Negative constraints (out-of-scope features) up front - reduces
      hallucination of irrelevant flags. Schulhoff Sec. 2.2.6.

  Deliberately rejected:
    - "Think step by step" / "let's take a deep breath" CoT triggers.
      Schulhoff notes these are most effective at non-zero temperature
      and on multi-step reasoning tasks. We are at temperature=0 (or
      the GPT-5.5 reasoning-model equivalent) on a structured-extraction
      task; the survey does not establish CoT triggers as a benefit
      here, and they bloat the prompt.
    - Few-shot exemplars. We have only four utilities; a worked example
      for `cp` would bias the other three toward the example's style.
      Schulhoff (Sec. 2.2.1.1, Exemplar Selection) emphasizes example
      selection sensitivity - so we omit examples entirely rather than
      pick a biased one.
    - Persona ("you are a senior Rust engineer..."). No evidence in the
      survey it improves code-gen at zero-shot. Folklore.

  Versioning: the driver writes sha256(this file) into runs/<...>/log.jsonl
  as `prompt_template_sha256` so each run records which prompt produced it.
-->

You are translating a Linux man page into a single-file Rust implementation
of the documented utility. The audience for the implementation is a research
test harness running on Linux/GNU userland.

# Task

Read the man page below carefully. Then produce:

1. A `Cargo.toml` declaring the package and any third-party dependencies you
   need (you decide; pick what you would actually use).
2. A single `src/main.rs` that implements the documented behavior of the
   utility well enough that a behaviorally-faithful test suite drawn from
   the same man page would pass.
3. A short rationale (one or two sentences) explaining your dependency
   choice.

# Implementation constraints

- **Single-file Rust**, in `src/main.rs`. The crate has no other modules.
- Target **POSIX/Linux** semantics as documented. Where the man page is
  silent, follow POSIX defaults rather than inventing behavior.
- Implement the **commonly-used flags** documented in the man page. Be
  honest in your rationale about what you covered and what you skipped.
- **Skip these areas** unless the man page makes them central to the
  utility's identity (they introduce platform-specific complexity that
  this experiment does not measure):
  - SELinux / MAC contexts and `--context` flags
  - locale / NLS / collation / multibyte
  - extended attributes (`xattr`) and ACLs
  - sparse-file handling, `--sparse=`, `--reflink=`
  - signal handling beyond the default
  - network filesystems, remote protocols, `rsync`-like behavior
- Errors must go to **stderr** with a nonzero exit code consistent with the
  man page (or POSIX defaults if the man page is silent).
- Code must compile under `cargo build --release` without errors. Warnings
  are acceptable.
- The binary name should be `util`. Set `[[bin]] name = "util"` in
  `Cargo.toml`.

# Output format - strict

Respond with exactly one fenced JSON code block, no prose before or after.
The JSON must validate against this schema:

```json
{
  "type": "object",
  "additionalProperties": false,
  "required": ["cargo_toml", "main_rs", "deps_rationale"],
  "properties": {
    "cargo_toml":      { "type": "string", "description": "full text of Cargo.toml" },
    "main_rs":         { "type": "string", "description": "full text of src/main.rs" },
    "deps_rationale":  { "type": "string", "description": "1-2 sentences on dep choice and what was skipped" }
  }
}
```

The `cargo_toml` and `main_rs` strings must contain raw file contents
(newlines preserved, no JSON-escaping beyond what the JSON encoding
requires). Do not wrap them in additional Markdown fences.

# Manual page

{{manpage}}
