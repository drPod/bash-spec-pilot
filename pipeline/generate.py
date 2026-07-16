#!/usr/bin/env python3
"""LLM-in-the-loop driver: generate a Lean model+spec+proof, kernel-check, validate.

Per round: compose prompt (POSIX doc + contract + feedback) -> Responses API with
strict JSON schema -> check.py gates (static guard, `lake build` kernel check,
axiom gate, differential vs the GNU binary). Kernel rejection or behavioral
mismatch becomes the next round's feedback. Success = kernel-accepted AND 100%
fidelity within the round budget.

This is the OpenAI backend; check.py is generator-agnostic, so a Claude subagent
(or a human) can drive the same loop without this file; see README.

Every round's prompt, raw response, Lean source, build log, and result land in
runs/<target>/<session>/round_NN/; one summary line per round in log.jsonl.

Usage: uv run generate.py --target uniq [--rounds 4] [--trials 200]
                          [--model gpt-5.6-luna] [--effort low]
"""

import argparse
import hashlib
import json
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

from openai import OpenAI

from check import check
from targets import TARGETS, Target

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
TEMPLATE = (HERE / "prompts" / "generate.md").read_text()

# The cheap prototyping default (Aaron: cheaper models first, frontier later).
# Frontier runs: --model gpt-5.5-2026-04-23 (the project's pinned snapshot).
DEFAULT_MODEL = "gpt-5.6-luna"

OUTPUT_SCHEMA = {
    "type": "object",
    "properties": {
        "lean_source": {"type": "string"},
        "spec_theorems": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {"name": {"type": "string"},
                               "informal": {"type": "string"}},
                "required": ["name", "informal"],
                "additionalProperties": False,
            },
        },
    },
    "required": ["lean_source", "spec_theorems"],
    "additionalProperties": False,
}


def load_env() -> None:
    """Minimal .env loader (repo root); real environment wins over the file."""
    envf = REPO / ".env"
    if not envf.exists():
        return
    for line in envf.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())


def compose_prompt(target: Target, feedback: str) -> str:
    return (TEMPLATE
            .replace("{utility}", target.name)
            .replace("{scope}", target.scope)
            .replace("{doc}", target.doc_text())
            .replace("{feedback}", feedback))


def call_llm(client: OpenAI, model: str, prompt: str, effort: str | None) -> tuple[dict, str, float]:
    # Request shape verified against archive/v1/docs/openai/responses_create.md
    # (SDK 2.35.1). Reasoning models reject temperature/seed/top_p; never add them.
    req: dict = {
        "model": model,
        "input": prompt,
        "max_output_tokens": int(os.environ.get("OPENAI_MAX_OUTPUT_TOKENS", "16000")),
        "text": {"format": {"type": "json_schema", "name": "lean_artifact",
                            "schema": OUTPUT_SCHEMA, "strict": True}},
    }
    if effort:
        req["reasoning"] = {"effort": effort}
    t0 = time.time()
    resp = client.responses.create(**req)
    return resp.model_dump(), getattr(resp, "output_text", "") or "", time.time() - t0


def format_feedback(round_no: int, source: str, failures: list[str],
                    mismatches: list[dict]) -> str:
    parts = [f"\n## Previous attempt feedback (round {round_no})\n",
             "Your previous module (revise it; return the COMPLETE new module):\n",
             "```lean\n" + source + "\n```\n"]
    for f in failures:
        parts.append(f"**Failure:** {f}\n")
    if mismatches:
        parts.append("**Behavioral mismatches vs the real program** "
                     "(model = your compiled Lean, gnu = ground truth):\n")
        for m in mismatches[:5]:
            parts.append(f"- args={m['args']} stdin={m['stdin']!r}\n"
                         f"  model={m['model_out']!r} (exit {m['model_code']})  "
                         f"gnu={m['oracle_out']!r} (exit {m['oracle_code']})\n")
    return "\n".join(parts)


def run_target(target: Target, model: str, effort: str | None,
               rounds: int, trials: int) -> dict:
    client = OpenAI(timeout=float(os.environ.get("OPENAI_TIMEOUT_S", "300")),
                    max_retries=int(os.environ.get("OPENAI_MAX_RETRIES", "3")))
    session = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H-%M-%SZ")
    session_dir = HERE / "runs" / target.name / session
    log_path = session_dir / "log.jsonl"
    feedback, result = "", {"target": target.name, "session": session,
                            "kernel_accepted": False, "fidelity": None}

    for rnd in range(1, rounds + 1):
        rdir = session_dir / f"round_{rnd:02d}"
        rdir.mkdir(parents=True, exist_ok=True)
        prompt = compose_prompt(target, feedback)
        (rdir / "prompt.md").write_text(prompt)

        raw, text, llm_secs = call_llm(client, model, prompt, effort)
        (rdir / "response.json").write_text(json.dumps(raw, indent=2, default=str))
        row = {"ts": datetime.now(timezone.utc).isoformat(),
               "target": target.name, "model": model, "round": rnd,
               "response_id": raw.get("id"),
               "usage": {"input_tokens": raw.get("usage", {}).get("input_tokens"),
                         "output_tokens": raw.get("usage", {}).get("output_tokens"),
                         "reasoning_tokens": (raw.get("usage", {})
                                              .get("output_tokens_details", {}) or {})
                                              .get("reasoning_tokens")},
               "prompt_sha256": hashlib.sha256(prompt.encode()).hexdigest(),
               "secs": {"llm": round(llm_secs, 1)}}

        failures, mismatches, source, theorems = [], [], "", []
        try:
            artifact = json.loads(text)
            source = artifact["lean_source"]
            theorems = artifact["spec_theorems"]
        except (json.JSONDecodeError, KeyError, TypeError) as e:
            failures.append(f"response was not the required JSON shape: {e!r}")

        if source:
            (rdir / "Generated.lean").write_text(source)
            c = check(target, source, theorems, trials)
            failures.extend(c["failures"])
            mismatches = c["mismatches"]
            row.update(guard_hits=c["guard_hits"], build_ok=c["build_ok"],
                       axioms_ok=c["axioms_ok"], diff=c["diff"])
            row["secs"].update(c["secs"])
            if c["build_log"]:
                (rdir / "build.log").write_text(c["build_log"])
            if c["axioms_log"]:
                (rdir / "axioms.log").write_text(c["axioms_log"])
            if c["axioms_ok"]:
                result["kernel_accepted"] = True
            if c["diff"]:
                result["fidelity"] = c["diff"]["passed"] / c["diff"]["trials"]

        row["n_theorems"] = len(theorems)
        row["status"] = "success" if (source and not failures) else "retry"
        (rdir / "result.json").write_text(json.dumps(
            {"failures": failures, "mismatches": mismatches,
             "spec_theorems": theorems}, indent=2))
        with log_path.open("a") as f:
            f.write(json.dumps(row) + "\n")
        print(f"[{target.name} r{rnd}] status={row['status']} "
              f"build={row.get('build_ok')} axioms={row.get('axioms_ok')} "
              f"diff={row.get('diff')}", flush=True)

        if row["status"] == "success":
            result["rounds"] = rnd
            break
        feedback = format_feedback(rnd, source, failures, mismatches)
    else:
        result["rounds"] = rounds

    result["success"] = result["kernel_accepted"] and result.get("fidelity") == 1.0
    (session_dir / "summary.json").write_text(json.dumps(result, indent=2))
    return result


def main() -> int:
    load_env()  # before the parser: --effort's default comes from .env
    ap = argparse.ArgumentParser()
    ap.add_argument("--target", required=True,
                    choices=[*TARGETS, "all"])
    ap.add_argument("--model", default=DEFAULT_MODEL)
    ap.add_argument("--effort", default=os.environ.get("OPENAI_REASONING_EFFORT"))
    ap.add_argument("--rounds", type=int, default=4)
    ap.add_argument("--trials", type=int, default=200)
    args = ap.parse_args()
    if not os.environ.get("OPENAI_API_KEY"):
        sys.exit("OPENAI_API_KEY not set (repo-root .env or environment)")

    names = list(TARGETS) if args.target == "all" else [args.target]
    results = [run_target(TARGETS[n], args.model, args.effort,
                          args.rounds, args.trials) for n in names]
    for r in results:
        fid = "-" if r["fidelity"] is None else f"{100 * r['fidelity']:.1f}%"
        print(f"{r['target']}: kernel={'PASS' if r['kernel_accepted'] else 'FAIL'} "
              f"fidelity={fid} rounds={r['rounds']} session={r['session']}")
    return 0 if all(r["success"] for r in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
