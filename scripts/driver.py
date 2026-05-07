#!/usr/bin/env python3
"""Driver: render a prompt template against a frozen man page, call OpenAI,
save the request/response and extracted artifacts to
runs/<util>/<session_id>/round_<NN>/.

Usage:
    # First round of a new session (auto-generates session_id):
    python scripts/driver.py --util cp --prompt impl  --round 1
    python scripts/driver.py --util cp --prompt tests --round 1

    # Subsequent rounds within the same session (auto-finds latest session):
    python scripts/driver.py --util cp --prompt tests --round 2

    # Explicit session id (re-runs a specific trajectory):
    python scripts/driver.py --util cp --prompt tests --round 2 \\
        --session 2026-05-07T18-30-00Z

A `session_id` is one iteration trajectory (rounds 1, 2, 3, ...). It is an
ISO 8601 UTC timestamp with colons replaced by hyphens (filesystem-safe):
    YYYY-MM-DDTHH-MM-SSZ

# Iteration feedback (round >= 2)

When invoked with --round N where N >= 2, the driver looks up the
previous round's results JSONL and Rust build error (if any) and appends a
"Previous attempt feedback" section to the prompt. The feedback is
content-hashed separately from the base template so log.jsonl can record
both `prompt_template_sha256` (the canonical prompt) and `feedback_sha256`
(the round-specific error context).

Reads env (via .env): OPENAI_API_KEY, OPENAI_MODEL, OPENAI_MAX_OUTPUT_TOKENS,
OPENAI_REASONING_EFFORT (optional), OPENAI_TIMEOUT_S (optional, default 300),
OPENAI_MAX_RETRIES (optional, default 3).

# Why this driver does NOT pass `temperature` or `seed`

GPT-5.5 is a reasoning model. The OpenAI API rejects `temperature` on
reasoning models with the error "Unsupported parameter: 'temperature' is
not supported with this model." (Confirmed at the OpenAI Developer
Community thread on the GPT-5 family, 2026-05-07; see decisions.md.)

`seed` is also not on the Responses API at all - it's a Chat Completions
parameter. The SDK signature in openai==2.35.1 does not accept it; passing
it raises TypeError before the HTTP call. Likewise `system_fingerprint` is
not returned by Responses (it's a Chat Completions response field).
See docs/openai/responses_create.md for the verified parameter list.

For research reproducibility we now rely on:
    dated model snapshot in OPENAI_MODEL (e.g. gpt-5.5-2026-04-23)
    + content-hashed prompt template (detects prompt drift)
    + content-hashed manpage (detects input drift)
    + content-hashed feedback section (detects iteration-feedback drift)
    + response_id logged (server-side recall via previous_response_id).
"""
from __future__ import annotations

import argparse
import datetime as _dt
import hashlib
import json
import os
import re
import sys
import time
from pathlib import Path

from dotenv import load_dotenv
from openai import (
    OpenAI,
    APIConnectionError,
    APIStatusError,
    APITimeoutError,
    BadRequestError,
    RateLimitError,
)


# Cap on how many failing-test entries to surface in the iteration prompt.
# Top N by appearance order in the JSONL. Higher values risk pushing the
# prompt over the model's context budget; lower values lose signal. 10 is
# a deliberate trade-off, made a constant rather than a CLI flag so the
# experiment's prompt content is reproducible from the script alone.
MAX_FEEDBACK_FAILURES = 10
MAX_BUILD_ERROR_LINES = 50

# Strict JSON schemas matching prompts/impl.md and prompts/tests.md.
IMPL_SCHEMA: dict = {
    "type": "object",
    "additionalProperties": False,
    "required": ["cargo_toml", "main_rs", "deps_rationale"],
    "properties": {
        "cargo_toml": {"type": "string"},
        "main_rs": {"type": "string"},
        "deps_rationale": {"type": "string"},
    },
}

# `expected_to_fail` (boolean, required): true if the test exercises a
# documented error condition where the real utility must exit nonzero.
# See prompts/tests.md for the full semantic.
TESTS_SCHEMA: dict = {
    "type": "object",
    "additionalProperties": False,
    "required": ["tests"],
    "properties": {
        "tests": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": [
                    "filename",
                    "body",
                    "exercises",
                    "expected",
                    "expected_to_fail",
                ],
                "properties": {
                    "filename": {"type": "string"},
                    "body": {"type": "string"},
                    "exercises": {"type": "string"},
                    "expected": {"type": "string"},
                    "expected_to_fail": {"type": "boolean"},
                },
            },
        }
    },
}


# ---------- session id helpers --------------------------------------------------

_SESSION_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z$")


def fresh_session_id() -> str:
    """ISO 8601 UTC timestamp with colons replaced for filesystem safety."""
    return _dt.datetime.now(tz=_dt.timezone.utc).strftime("%Y-%m-%dT%H-%M-%SZ")


def is_session_id(name: str) -> bool:
    return bool(_SESSION_RE.match(name))


def latest_session(repo: Path, util: str) -> str | None:
    base = repo / "runs" / util
    if not base.is_dir():
        return None
    candidates = sorted(
        (p.name for p in base.iterdir() if p.is_dir() and is_session_id(p.name)),
    )
    return candidates[-1] if candidates else None


def resolve_session(repo: Path, util: str, round_n: int, requested: str | None) -> str:
    """Resolve the session id, possibly creating a fresh one for round 1.

    Rules per the brief:
      - Explicit --session always wins.
      - Round 1 with no --session: generate a fresh ISO timestamp.
      - Round >1 with no --session: re-use the most recent session for this
        util. Failing that, error loudly — round 2 cannot create a session.
    """
    if requested:
        if not is_session_id(requested):
            fail(
                f"--session must match YYYY-MM-DDTHH-MM-SSZ; got {requested!r}"
            )
        return requested
    if round_n == 1:
        return fresh_session_id()
    sid = latest_session(repo, util)
    if sid is None:
        fail(
            f"--round {round_n} with no --session and no prior session under "
            f"runs/{util}/. Start with --round 1 to create a session."
        )
        raise RuntimeError("unreachable")  # for type-checker
    return sid


# ---------- prompt rendering ---------------------------------------------------


def render_base_prompt(repo: Path, util: str, prompt_kind: str) -> tuple[str, str, str]:
    """Return (rendered_prompt_no_feedback, template_sha256, manpage_sha256)."""
    template_path = repo / "prompts" / f"{prompt_kind}.md"
    manpage_path = repo / "utils" / util / "manpage.txt"
    template_text = template_path.read_text()
    manpage_text = manpage_path.read_text()
    rendered = template_text.replace("{{manpage}}", manpage_text)
    template_sha = hashlib.sha256(template_text.encode()).hexdigest()
    manpage_sha = hashlib.sha256(manpage_text.encode()).hexdigest()
    return rendered, template_sha, manpage_sha


def build_feedback_section(
    repo: Path, util: str, session: str, round_n: int, prompt_kind: str
) -> str:
    """Render a 'Previous attempt feedback' block for round_n >= 2.

    Returns "" when no feedback exists or round_n == 1.
    """
    if round_n < 2:
        return ""
    prev = repo / "runs" / util / session / f"round_{round_n - 1:02d}"
    if not prev.is_dir():
        # Caller already validated round 1 exists; if it doesn't here,
        # produce an empty feedback section rather than crashing.
        return ""

    chunks: list[str] = [f"# Previous attempt feedback (round {round_n - 1})"]

    # Real-utility test failures.
    failures = _read_test_failures(prev)
    if failures:
        chunks.append(
            "In the previous attempt, the following tests FAILED against the real utility:"
        )
        for f in failures[:MAX_FEEDBACK_FAILURES]:
            chunks.append(_format_failure(f))
        if len(failures) > MAX_FEEDBACK_FAILURES:
            chunks.append(
                f"... and {len(failures) - MAX_FEEDBACK_FAILURES} more (truncated)."
            )
    else:
        chunks.append(
            "No real-utility test-result file was found for the previous round, "
            "or all previous tests passed."
        )

    # Rust build error (impl prompts only — but useful context for tests too,
    # since the test author may have to know what flags compile).
    build_err = prev / "impl" / "_logs" / "build_error.txt"
    if build_err.is_file():
        err_text = build_err.read_text().splitlines()[:MAX_BUILD_ERROR_LINES]
        if err_text:
            chunks.append("")
            chunks.append("Your implementation failed to compile with:")
            chunks.append("```")
            chunks.extend(err_text)
            chunks.append("```")

    # Analyst observations (manual, optional).
    obs = prev / "_observations.md"
    if obs.is_file():
        obs_text = obs.read_text().strip()
        if obs_text:
            chunks.append("")
            chunks.append("Manual analyst observations:")
            chunks.append(obs_text)

    chunks.append("")
    chunks.append(
        f"Produce a corrected `{prompt_kind}` JSON payload following the same "
        "schema as before. Address the issues above without regressing anything "
        "the previous round got right."
    )
    return "\n".join(chunks)


def _read_test_failures(prev_round: Path) -> list[dict]:
    """Read failing test rows from results_real-gnu.jsonl preferred, else
    results_real.jsonl. Returns a list of failure dicts in JSONL order."""
    for name in ("results_real-gnu.jsonl", "results_real.jsonl"):
        path = prev_round / name
        if path.is_file():
            failures: list[dict] = []
            for line in path.read_text().splitlines():
                line = line.strip()
                if not line:
                    continue
                try:
                    row = json.loads(line)
                except json.JSONDecodeError:
                    continue
                # A row "fails" when its `correct` flag is false (new schema)
                # OR when status != "pass" (legacy schema). Be liberal in
                # what we accept since results_real.jsonl from the
                # legacy_pre_session run uses the old schema.
                correct = row.get("correct")
                if correct is False:
                    failures.append(row)
                elif correct is None and row.get("status") not in ("pass", None):
                    failures.append(row)
            return failures
    return []


def _format_failure(row: dict) -> str:
    name = row.get("name", "<unknown>")
    exercises = row.get("exercises", "")
    expected = row.get("expected", "")
    rc = row.get("rc")
    stderr = (row.get("stderr") or "").replace("\n", " ").strip()
    if len(stderr) > 200:
        stderr = stderr[:200] + "..."
    chunks = [f"  - {name}: {exercises}".rstrip(": ")]
    if expected:
        chunks.append(f"    expected: {expected}")
    chunks.append(f"    actual stderr: {stderr or '<empty>'}")
    chunks.append(f"    actual exit: {rc}")
    return "\n".join(chunks)


def render_prompt(
    repo: Path, util: str, prompt_kind: str, session: str, round_n: int
) -> tuple[str, str, str, str]:
    """Return (rendered_prompt, template_sha, manpage_sha, feedback_sha)."""
    base, template_sha, manpage_sha = render_base_prompt(repo, util, prompt_kind)
    feedback = build_feedback_section(repo, util, session, round_n, prompt_kind)
    if feedback:
        rendered = base + "\n\n" + feedback + "\n"
    else:
        rendered = base
    feedback_sha = hashlib.sha256(feedback.encode()).hexdigest() if feedback else ""
    return rendered, template_sha, manpage_sha, feedback_sha


# ---------- arg parsing --------------------------------------------------------


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--util", required=True, help="utility name, e.g. cp")
    ap.add_argument("--prompt", required=True, choices=["impl", "tests"])
    ap.add_argument("--round", type=int, required=True)
    ap.add_argument(
        "--session",
        default=None,
        help=(
            "Session id (YYYY-MM-DDTHH-MM-SSZ). Omit on round 1 to mint a "
            "fresh one; omit on round >=2 to reuse the latest session."
        ),
    )
    return ap.parse_args()


def schema_for(prompt_kind: str) -> dict:
    return IMPL_SCHEMA if prompt_kind == "impl" else TESTS_SCHEMA


def call_openai(
    prompt: str, prompt_kind: str, logs_dir: Path
) -> tuple[dict, str, float]:
    # Defaults verified against docs/openai/errors.md (SDK 2.35.1):
    #   client-level timeout 600s, max_retries 2. We tighten the timeout to
    #   keep a stuck call from idling for ten minutes, and bump retries to 3
    #   so transient 429/5xx survive a flaky moment without manual restart.
    client = OpenAI(
        timeout=float(os.environ.get("OPENAI_TIMEOUT_S", "300")),
        max_retries=int(os.environ.get("OPENAI_MAX_RETRIES", "3")),
    )
    model = os.environ["OPENAI_MODEL"]
    schema = schema_for(prompt_kind)
    schema_name = f"{prompt_kind}_artifact"

    # Every key below is verified against the Responses.create signature
    # in docs/openai/responses_create.md (SDK 2.35.1).
    req: dict = {
        "model": model,
        "input": prompt,
        "max_output_tokens": int(os.environ.get("OPENAI_MAX_OUTPUT_TOKENS", "16000")),
        "text": {
            "format": {
                "type": "json_schema",
                "name": schema_name,
                "schema": schema,
                "strict": True,
            }
        },
    }
    effort = os.environ.get("OPENAI_REASONING_EFFORT")
    if effort:
        # Valid literals on gpt-5.5: minimal | low | medium | high.
        req["reasoning"] = {"effort": effort}

    t0 = time.time()
    try:
        resp = client.responses.create(**req)
    except BadRequestError as e:
        _dump_error(logs_dir, prompt_kind, "bad_request", e, req)
        raise
    except RateLimitError as e:
        _dump_error(logs_dir, prompt_kind, "rate_limit", e, req)
        raise
    except APITimeoutError as e:
        _dump_error(logs_dir, prompt_kind, "timeout", e, req)
        raise
    except APIConnectionError as e:
        _dump_error(logs_dir, prompt_kind, "connection", e, req)
        raise
    except APIStatusError as e:
        _dump_error(logs_dir, prompt_kind, f"http_{e.status_code}", e, req)
        raise
    dt = time.time() - t0
    return resp.model_dump(), getattr(resp, "output_text", "") or "", dt


def _dump_error(logs_dir: Path, prompt_kind: str, kind: str, err: Exception, req: dict) -> None:
    payload: dict = {
        "error_kind": kind,
        "error_class": type(err).__name__,
        "error_str": str(err),
        "request": {k: ("<prompt body>" if k == "input" else v) for k, v in req.items()},
    }
    body = getattr(err, "body", None)
    if body is not None:
        payload["body"] = body
    status = getattr(err, "status_code", None)
    if status is not None:
        payload["status_code"] = status
    (logs_dir / f"{prompt_kind}_error.json").write_text(json.dumps(payload, indent=2, default=str))


CARGO_TOML_FALLBACK = """[package]
name = "util"
version = "0.0.0"
edition = "2021"

[dependencies]
clap = { version = "4", features = ["derive"] }

[[bin]]
name = "util"
path = "src/main.rs"
"""


def fail(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def parse_json_loudly(text: str, schema: dict) -> dict:
    """Parse the LLM JSON output. Raise loudly on malformed payload."""
    try:
        obj = json.loads(text)
    except json.JSONDecodeError as e:
        fail(
            f"response is not valid JSON ({e}). raw response saved to "
            f"_logs/<prompt>_raw.json for inspection."
        )
        raise  # for type-checker
    for key in schema["required"]:
        if key not in obj:
            fail(f"response JSON missing required key '{key}': got keys {list(obj)}")
    return obj


def extract_impl(payload: dict, round_dir: Path) -> int:
    impl_dir = round_dir / "impl"
    (impl_dir / "src").mkdir(parents=True, exist_ok=True)
    (impl_dir / "src" / "main.rs").write_text(payload["main_rs"])
    cargo_toml = payload.get("cargo_toml") or CARGO_TOML_FALLBACK
    (impl_dir / "Cargo.toml").write_text(cargo_toml)
    (impl_dir / "_deps_rationale.txt").write_text(payload.get("deps_rationale", ""))
    return 1


def extract_tests(payload: dict, round_dir: Path) -> int:
    tests_dir = round_dir / "tests"
    tests_dir.mkdir(parents=True, exist_ok=True)
    n = 0
    manifest = []
    tests = payload.get("tests") or []
    if not isinstance(tests, list) or not tests:
        fail("response.tests is missing or empty")
    for t in tests:
        for key in ("filename", "body", "exercises", "expected", "expected_to_fail"):
            if key not in t:
                fail(f"test entry missing key '{key}': {list(t)}")
        path = tests_dir / t["filename"]
        path.write_text(t["body"])
        path.chmod(0o755)
        manifest.append(
            {k: t[k] for k in ("filename", "exercises", "expected", "expected_to_fail")}
        )
        n += 1
    (tests_dir / "_manifest.json").write_text(json.dumps(manifest, indent=2))
    return n


def main() -> None:
    load_dotenv()
    args = parse_args()
    repo = Path(__file__).resolve().parent.parent

    session = resolve_session(repo, args.util, args.round, args.session)
    round_dir = repo / "runs" / args.util / session / f"round_{args.round:02d}"
    logs_dir = round_dir / "_logs"
    logs_dir.mkdir(parents=True, exist_ok=True)

    prompt, template_sha, manpage_sha, feedback_sha = render_prompt(
        repo, args.util, args.prompt, session, args.round
    )
    (logs_dir / f"{args.prompt}_prompt.txt").write_text(prompt)

    raw, text, dt = call_openai(prompt, args.prompt, logs_dir)
    (logs_dir / f"{args.prompt}_response.json").write_text(json.dumps(raw, indent=2))
    (logs_dir / f"{args.prompt}_raw.json").write_text(text)

    usage = raw.get("usage") or {}
    output_details = usage.get("output_tokens_details") or {}
    reasoning_tokens = output_details.get("reasoning_tokens")

    log_entry = {
        "ts": time.time(),
        "util": args.util,
        "session": session,
        "prompt": args.prompt,
        "round": args.round,
        "model": raw.get("model"),
        "response_id": raw.get("id"),
        "status": raw.get("status"),
        "duration_s": dt,
        "usage": usage,
        "reasoning_tokens": reasoning_tokens,
        "prompt_template_sha256": template_sha,
        "manpage_sha256": manpage_sha,
        "feedback_sha256": feedback_sha or None,
        "reasoning_effort": os.environ.get("OPENAI_REASONING_EFFORT"),
    }
    with (logs_dir / "log.jsonl").open("a") as f:
        f.write(json.dumps(log_entry) + "\n")

    payload = parse_json_loudly(text, schema_for(args.prompt))

    if args.prompt == "impl":
        extract_impl(payload, round_dir)
        print(f"impl written: {round_dir / 'impl'}")
    else:
        n = extract_tests(payload, round_dir)
        print(f"{n} tests written: {round_dir / 'tests'}")

    print(f"session: {session}")
    print(f"duration: {dt:.1f}s, usage: {raw.get('usage')}")
    print(f"prompt_template_sha256: {template_sha[:16]}...")
    print(f"manpage_sha256:         {manpage_sha[:16]}...")
    if feedback_sha:
        print(f"feedback_sha256:        {feedback_sha[:16]}...")


if __name__ == "__main__":
    main()
