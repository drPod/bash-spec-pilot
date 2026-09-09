#!/usr/bin/env python3
"""Assemble a fresh container workdir from pinned fragments and replay tests.

Not a C proof. Uses run_vst.py (shared compiler lock). Expected nonzero
xwrite statuses are asserted from JSON receipts, not wrapper exceptions.
"""
from __future__ import annotations

import errno
import hashlib
import json
import os
import secrets
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

TESTS = Path(__file__).resolve().parent
CASE = TESTS.parent
PHASE5 = CASE.parent
REPO = PHASE5.parents[2]
TU = CASE / "src" / "tu"
FRAGMENTS_JSON = TU / "FRAGMENTS.json"
RUN_VST = PHASE5 / "run_vst.py"
CONTAINER = "phase5-vst"
LOGS = Path.home() / "agent-jobs/astra-research/phase5/runs"

PINNED = {
    "head_bytes.frag.c": "ae9f42de06cf55ca1bfcc8720986b32f8c8d14b8063af8374dece0b886bbc4b7",
    "xwrite_stdout.frag.c": "bb26b78f6b0df6e41c22497b27709f30225627f42326fa80fd85625ae8a5262c",
    "wc_lines.frag.c": "7d22d9fdfd6f97e3f149088c597840afc90f7912eba038fdf5941b94978c26fd",
}


def sha256_file(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def new_runid() -> str:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    return f"{stamp}-{secrets.token_hex(4)}"


def check_fragments() -> None:
    meta = json.loads(FRAGMENTS_JSON.read_text())
    by_name = {row["name"] + ".frag.c": row for row in meta}
    for name, expected in PINNED.items():
        path = TU / name
        got = sha256_file(path)
        if got != expected:
            raise SystemExit(f"hash mismatch {name}: {got} != {expected}")
        row = by_name[name]
        if row["fragment_sha256"] != expected:
            raise SystemExit(f"FRAGMENTS.json mismatch for {name}")
        if sha256_file(path) != row["fragment_sha256"]:
            raise SystemExit(f"file vs FRAGMENTS.json {name}")


def c_tokens(src: bytes) -> list[str]:
    """Crude C tokenizer sufficient to compare a function body."""
    text = src.decode("utf-8")
    out: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c.isspace():
            i += 1
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            i = text.find("\n", i)
            if i < 0:
                break
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "*":
            j = text.find("*/", i + 2)
            if j < 0:
                raise SystemExit("unterminated comment in token scan")
            i = j + 2
            continue
        if c in "\"'":
            q = c
            i += 1
            buf = [q]
            while i < n:
                buf.append(text[i])
                if text[i] == "\\" and i + 1 < n:
                    buf.append(text[i + 1])
                    i += 2
                    continue
                if text[i] == q:
                    i += 1
                    break
                i += 1
            out.append("".join(buf))
            continue
        if c.isalnum() or c == "_":
            j = i
            while j < n and (text[j].isalnum() or text[j] == "_"):
                j += 1
            out.append(text[i:j])
            i = j
            continue
        out.append(c)
        i += 1
    return out


def extract_xwrite_body_tokens(assembled: bytes) -> list[str]:
    tokens = c_tokens(assembled)
    try:
        i = tokens.index("xwrite_stdout")
    except ValueError as exc:
        raise SystemExit("assembled TU missing xwrite_stdout") from exc
    brace = tokens.index("{", i)
    depth = 0
    end = brace
    for j in range(brace, len(tokens)):
        if tokens[j] == "{":
            depth += 1
        elif tokens[j] == "}":
            depth -= 1
            if depth == 0:
                end = j
                break
    return tokens[i : end + 1]


def assemble_xwrite_body() -> bytes:
    opener = (TESTS / "xwrite_comment_open.h").read_bytes()
    frag = (TU / "xwrite_stdout.frag.c").read_bytes()
    if sha256_bytes(frag) != PINNED["xwrite_stdout.frag.c"]:
        raise SystemExit("xwrite fragment hash failed at concat")
    assembled = opener + frag
    frag_close = frag.find(b"*/")
    if frag_close < 0:
        raise SystemExit("fragment has no comment closer")
    remainder = frag[frag_close + 2 :]
    asm_close = assembled.find(b"*/")
    if assembled[asm_close + 2 :] != remainder:
        raise SystemExit("assembled body remainder != fragment after comment close")
    frag_tokens = extract_xwrite_body_tokens(b"/*" + frag)
    asm_tokens = extract_xwrite_body_tokens(assembled)
    if frag_tokens != asm_tokens:
        raise SystemExit("token extraction of xwrite body != assembled concatenation")
    return assembled


def docker_mkdir(workdir: str) -> None:
    # Fresh directory only; never rm -rf (would destroy earlier evidence).
    subprocess.check_call(
        ["docker", "exec", CONTAINER, "mkdir", workdir],
        timeout=30,
    )


def docker_cp(src: Path, workdir: str, dest_name: str) -> None:
    subprocess.check_call(
        ["docker", "cp", str(src), f"{CONTAINER}:{workdir}/{dest_name}"],
        timeout=30,
    )


def load_receipt(name: str) -> dict:
    path = LOGS / f"{name}.json"
    if not path.is_file():
        raise SystemExit(f"missing receipt {path}")
    return json.loads(path.read_text())


def assert_receipt(
    name: str,
    command: list[str],
    workdir: str,
    expected_exit: int,
) -> dict:
    receipt_path = LOGS / f"{name}.json"
    log_path = LOGS / f"{name}.log"
    if not receipt_path.is_file():
        raise SystemExit(f"{name}: missing receipt {receipt_path}")
    if not log_path.is_file():
        raise SystemExit(f"{name}: missing log {log_path}")
    rec = json.loads(receipt_path.read_text())
    if rec.get("command") != command:
        raise SystemExit(f"{name}: command mismatch {rec.get('command')!r} != {command!r}")
    if rec.get("workdir") != workdir:
        raise SystemExit(f"{name}: workdir mismatch {rec.get('workdir')!r} != {workdir!r}")
    if rec.get("exit_status") != expected_exit:
        raise SystemExit(
            f"{name}: exit_status {rec.get('exit_status')} != expected {expected_exit}"
        )
    if rec.get("timing_exit_status") != expected_exit:
        raise SystemExit(
            f"{name}: timing_exit_status {rec.get('timing_exit_status')} != expected {expected_exit}"
        )
    log_sha = sha256_file(log_path)
    if rec.get("log_sha256") != log_sha:
        raise SystemExit(f"{name}: log_sha256 mismatch")
    return rec


def run_vst(name: str, command: list[str], workdir: str, expected_exit: int, seconds: int = 60) -> dict:
    cmd = [
        sys.executable,
        str(RUN_VST),
        "--container",
        CONTAINER,
        "--seconds",
        str(seconds),
        "--name",
        name,
        "--workdir",
        workdir,
        "--",
        *command,
    ]
    print("+", " ".join(cmd), flush=True)
    proc = subprocess.run(cmd)
    # Wrapper returncode is not trusted as program outcome: wrapper argparse
    # errors also exit nonzero. Always read the newly created receipt.
    rec = assert_receipt(name, command, workdir, expected_exit)
    if proc.returncode != expected_exit:
        # Receipt already matched expected_exit; wrapper rc must agree too.
        raise SystemExit(
            f"{name}: wrapper returncode {proc.returncode} disagrees with receipt {expected_exit}"
        )
    return rec


def log_text(name: str) -> str:
    return (LOGS / f"{name}.log").read_text(errors="replace")


def fail_closed_negative_checks() -> None:
    """Exercise the real validator against missing and wrong-command receipts."""
    global LOGS
    original_logs = LOGS
    try:
        with tempfile.TemporaryDirectory() as tmp:
            LOGS = Path(tmp)
            for name, expected_message in (
                ("missing", "missing receipt"),
                ("mismatch", "command mismatch"),
            ):
                if name == "mismatch":
                    (LOGS / f"{name}.log").write_bytes(b"")
                    (LOGS / f"{name}.json").write_text(json.dumps({
                        "command": ["not-this"], "workdir": "/test",
                        "exit_status": 0, "timing_exit_status": 0,
                        "log_sha256": hashlib.sha256(b"").hexdigest(),
                    }))
                try:
                    assert_receipt(name, ["./harness"], "/test", 0)
                except SystemExit as exc:
                    if expected_message not in str(exc):
                        raise AssertionError(f"wrong rejection: {exc}") from exc
                else:
                    raise AssertionError(f"validator accepted {name} receipt")
    finally:
        LOGS = original_logs
    print("real receipt validator rejected missing and mismatched receipts")


def replay_once() -> dict:
    runid = new_runid()
    workdir = f"/home/coq/phase5/case-replay8-{runid}"
    prefix = f"case-replay8-{runid}"
    check_fragments()
    body = assemble_xwrite_body()
    docker_mkdir(workdir)
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        (tmp_path / "xwrite_body.c").write_bytes(body)
        shutil.copy(TESTS / "harness.c", tmp_path / "harness.c")
        shutil.copy(TESTS / "xwrite_main.c", tmp_path / "xwrite_main.c")
        shutil.copy(TU / "head_bytes.frag.c", tmp_path / "head_bytes.frag.c")
        shutil.copy(TU / "wc_lines.frag.c", tmp_path / "wc_lines.frag.c")
        shutil.copy(TU / "xwrite_stdout.frag.c", tmp_path / "xwrite_stdout.frag.c")
        for name in (
            "harness.c",
            "xwrite_main.c",
            "xwrite_body.c",
            "head_bytes.frag.c",
            "wc_lines.frag.c",
            "xwrite_stdout.frag.c",
        ):
            docker_cp(tmp_path / name, workdir, name)

    names = {}
    gcc_h = f"{prefix}-gcc-harness"
    run_vst(gcc_h, ["gcc", "-O0", "-std=c11", "-Wall", "-o", "harness", "harness.c"], workdir, 0)
    names["gcc_harness"] = gcc_h

    run_h = f"{prefix}-run-harness"
    run_vst(run_h, ["./harness"], workdir, 0)
    hlog = log_text(run_h)
    if "SUMMARY passed=100 failed=0" not in hlog:
        raise SystemExit(f"{run_h}: missing harness summary passed=100 failed=0")
    names["run_harness"] = run_h

    gcc_x = f"{prefix}-gcc-xwrite"
    run_vst(
        gcc_x,
        ["gcc", "-O0", "-std=c11", "-Wall", "-o", "xwrite_harness", "xwrite_main.c"],
        workdir,
        0,
    )
    names["gcc_xwrite"] = gcc_x

    ok_n = f"{prefix}-run-xwrite-ok"
    run_vst(ok_n, ["./xwrite_harness", "ok"], workdir, 0)
    ok_log = log_text(ok_n)
    if ok_log != "hello\n":
        raise SystemExit(f"{ok_n}: stdout must be exactly 'hello\\n', got {ok_log!r}")
    names["ok"] = ok_n

    zero_n = f"{prefix}-run-xwrite-zero"
    run_vst(zero_n, ["./xwrite_harness", "zero"], workdir, 0)
    zero_log = log_text(zero_n)
    if zero_log != "":
        raise SystemExit(f"{zero_n}: stdout must be empty, got {zero_log!r}")
    names["zero"] = zero_n

    full_n = f"{prefix}-run-xwrite-full"
    run_vst(full_n, ["./xwrite_harness", "full"], workdir, 1)
    full_log = log_text(full_n)
    if "ENOSPC" not in full_log and "No space left" not in full_log:
        # driver prints errnum; require diagnostic and errno 28 / ENOSPC
        if f"errnum={errno.ENOSPC}" not in full_log and "errnum=28" not in full_log:
            raise SystemExit(f"{full_n}: missing ENOSPC diagnostic: {full_log!r}")
    if f"errnum={errno.ENOSPC}" not in full_log and "errnum=28" not in full_log:
        raise SystemExit(f"{full_n}: missing errno ENOSPC/28: {full_log!r}")
    if "XWRITE_ERROR" not in full_log:
        raise SystemExit(f"{full_n}: missing XWRITE_ERROR line: {full_log!r}")
    names["full"] = full_n

    print(f"replay ok runid={runid} workdir={workdir}")
    return {"runid": runid, "workdir": workdir, "prefix": prefix, "names": names}


def main() -> None:
    fail_closed_negative_checks()
    first = replay_once()
    second = replay_once()
    if first["runid"] == second["runid"]:
        raise SystemExit("runids collided")
    if first["workdir"] == second["workdir"]:
        raise SystemExit("workdirs collided")
    print("replay ok twice: collision-free; receipts outside repo")
    print("scope: differential execution only; not a C proof")
    print(json.dumps({"first": first, "second": second}, indent=2))


if __name__ == "__main__":
    main()
