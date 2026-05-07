# OpenAI Python SDK — local mirror

Pinned, ground-truth reference for `openai-python==2.35.1` (the version
this project depends on). All content here is derived from reading the
installed SDK source at
`.venv/lib/python3.12/site-packages/openai/`. **Not paraphrased from
memory or web docs.** Refresh with `scripts/sync_openai_docs.sh`.

Last verified: 2026-05-07.

## When to consult what

| File | Bytes | Read when |
|------|-------|-----------|
| `_pin.txt` | ~0.6k | Confirming exact SDK version + commit you're aligned to. |
| `_responses_create_signature.txt` | ~2k | Quick sanity check of the raw `inspect.signature` output. |
| `responses_create.md` | ~5k | About to call `client.responses.create(...)`, want to confirm a parameter exists / has a given type / works on GPT-5.5. Lists params the SDK does NOT accept. |
| `structured_outputs.md` | ~3k | Setting `text.format` for JSON-schema output, or considering `responses.parse(...)`. |
| `reasoning.md` | ~2.5k | Configuring `reasoning.effort`, sizing `max_output_tokens`, or accounting for reasoning tokens in usage. |
| `errors.md` | ~3.5k | Wrapping API calls in `try/except`, configuring retries, configuring per-call timeouts. |

## Project usage map

This project's only OpenAI surface is `scripts/driver.py`. Every parameter
that file passes to `client.responses.create(...)` should appear in
`responses_create.md`. Every error path it could hit lives in `errors.md`.

If a file in this project imports something from `openai`, the symbol
should exist in the SDK at the pinned version. If you can't find it here,
it doesn't exist on 2.35.1 — go fix the caller, do not `pip install`-bump.

## Why mirror at all

Per `~/.claude/rules/docs.md`: when the project lives in a library, mirror
the docs for deterministic version pin + offline access + cheap repeated
reads. The SDK type files are also the only fully accurate reference —
the platform.openai.com docs lag the SDK by anywhere from days to a major
version.

## Topics intentionally NOT mirrored

- Realtime API
- Audio (TTS / Whisper)
- Images
- Embeddings
- Files
- Batch API
- Vector Stores
- Assistants

This project only uses Responses + structured outputs + reasoning. Adding
those topics later is one curl + one SDK source read away.
