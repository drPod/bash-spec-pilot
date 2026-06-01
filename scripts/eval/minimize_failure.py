#!/usr/bin/env python3
"""Wave-4 ReduceFix-style divergence minimizer.

Given a divergence row from divergences.jsonl, ask the LLM to produce the
smallest invocation still surfacing the same real-vs-rust disagreement.
Lineage: ReduceFix (arXiv 2507.15251). Deferred run until at least one
divergence appears in the pilot.

Usage:
    scripts/eval/minimize_failure.py <util> <session> <round> <test_name>

Writes:
    runs/<util>/<session>/round_NN/minimized/<test_name>          (shrunk body)
    runs/<util>/<session>/round_NN/minimized/<test_name>.json     (rationale)
"""
from __future__ import annotations

import argparse
import json
import os
import pathlib
import sys

from dotenv import load_dotenv
from openai import OpenAI


PROMPT_TEMPLATE = """\
You are minimizing a Bash test that surfaces a divergence between two
implementations of `{util}`. The original test is below. The real GNU
binary produced one result; the LLM-generated Rust re-implementation
produced a different result. Both outputs are recorded.

Your task: produce the smallest self-contained Bash script that still
surfaces the same divergence (different exit code or different stderr
between the two implementations). Strip any setup that does not
contribute to the divergence. Preserve:

  - `#!/usr/bin/env bash` + `set -euo pipefail`
  - `mktemp -d` + EXIT trap
  - invocation through `$UTIL`, always quoted
  - one assertion (the one that distinguishes the two implementations)

Respond with one fenced JSON code block matching this schema:

{{
  "type": "object",
  "additionalProperties": false,
  "required": ["body", "rationale"],
  "properties": {{
    "body": {{"type": "string"}},
    "rationale": {{"type": "string"}}
  }}
}}

# Original test (`{test_name}`)

```bash
{test_body}
```

# Divergence record

real GNU exit code: {real_rc}
real GNU stderr (first 3 lines):
{real_stderr}

rust impl exit code: {rust_rc}
rust impl stderr (first 3 lines):
{rust_stderr}
"""


MIN_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["body", "rationale"],
    "properties": {
        "body": {"type": "string"},
        "rationale": {"type": "string"},
    },
}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("util")
    ap.add_argument("session")
    ap.add_argument("round", type=int)
    ap.add_argument("test_name", help="test filename, e.g. 007_foo.sh")
    args = ap.parse_args()
    load_dotenv()

    repo = pathlib.Path(__file__).resolve().parents[2]
    rdir = repo / "runs" / args.util / args.session / f"round_{args.round:02d}"
    test_path = rdir / "tests" / args.test_name
    div_path = rdir / "divergences.jsonl"
    if not test_path.is_file() or not div_path.is_file():
        print(
            f"missing tests/{args.test_name} or divergences.jsonl in {rdir}",
            file=sys.stderr,
        )
        return 2

    div_row = None
    for line in div_path.read_text().splitlines():
        if not line.strip():
            continue
        row = json.loads(line)
        if row.get("name") == args.test_name:
            div_row = row
            break
    if div_row is None:
        print(f"no divergence row for {args.test_name}", file=sys.stderr)
        return 2

    prompt = PROMPT_TEMPLATE.format(
        util=args.util,
        test_name=args.test_name,
        test_body=test_path.read_text(),
        real_rc=div_row.get("real_rc"),
        real_stderr="\n".join(div_row.get("real_stderr_head") or []),
        rust_rc=div_row.get("rust_rc"),
        rust_stderr="\n".join(div_row.get("rust_stderr_head") or []),
    )

    client = OpenAI(
        timeout=float(os.environ.get("OPENAI_TIMEOUT_S", "300")),
        max_retries=int(os.environ.get("OPENAI_MAX_RETRIES", "3")),
    )
    req: dict = {
        "model": os.environ["OPENAI_MODEL"],
        "input": prompt,
        "max_output_tokens": int(os.environ.get("OPENAI_MAX_OUTPUT_TOKENS", "8000")),
        "text": {
            "format": {
                "type": "json_schema",
                "name": "minimized_test",
                "schema": MIN_SCHEMA,
                "strict": True,
            }
        },
    }
    effort = os.environ.get("OPENAI_REASONING_EFFORT")
    if effort:
        req["reasoning"] = {"effort": effort}

    resp = client.responses.create(**req)
    text = getattr(resp, "output_text", "") or ""
    payload = json.loads(text)

    out_dir = rdir / "minimized"
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / args.test_name).write_text(payload["body"])
    (out_dir / (args.test_name + ".json")).write_text(
        json.dumps(
            {"rationale": payload["rationale"], "response_id": resp.id},
            indent=2,
        )
    )
    print(f"minimized: {out_dir / args.test_name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
