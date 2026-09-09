#!/usr/bin/env python3
"""Directed actual-execution checks of a small pipe/redirect fragment.

Compile and run the relay binary ONLY through research/libc-specs/phase5/run_vst.py
(phase5-vst container, shared flock, unique run names). Host gcc is not used.

Expectations are HAND-CODED in this file. There is no executable Coq oracle and
this script does not differentially execute Compose.v. Agreement means the
container bash/kernel observations matched those literals — not a proof that
the Coq model matches Bash.

Source provenance: exact sha256 of phase2/relay.c, phase5/relay/relay.i, the
staged copies, wrapper, and compiler receipt. Substring presence in relay.i is
NOT treated as identity of translation.
"""
from __future__ import annotations

import hashlib
import json
import os
import secrets
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
PHASE5 = HERE.parents[1]
REPO_ROOT = HERE.parents[4]
RELAY_C_SOURCE = REPO_ROOT / "research/libc-specs/phase2/relay.c"
RELAY_I_CHECKED = REPO_ROOT / "research/libc-specs/phase5/relay/relay.i"
RUN_VST = PHASE5 / "run_vst.py"
CONTAINER = "phase5-vst"
LOGS = Path.home() / "agent-jobs/astra-research/phase5/runs"
JOBDIR = Path.home() / "agent-jobs/astra-research/phase5/pi-reviews/shell-validation-repair-9"
MAX_LOCK_RETRIES = 5
LOCK_SLEEP = 8

PRELUDE = 'mark(){ printf "\\041"; }; '


def sha256_file(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def new_runid() -> str:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    return f"{stamp}-{secrets.token_hex(4)}"


def docker_mkdir(workdir: str) -> None:
    subprocess.check_call(["docker", "exec", CONTAINER, "mkdir", "-p", workdir], timeout=30)


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


def assert_receipt(name: str, command: list[str], workdir: str) -> dict:
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
        raise SystemExit(f"{name}: workdir mismatch")
    log_sha = sha256_file(log_path)
    if rec.get("log_sha256") != log_sha:
        raise SystemExit(f"{name}: log_sha256 mismatch receipt={rec.get('log_sha256')} file={log_sha}")
    return rec


def run_vst_lock_retry(name: str, command: list[str], workdir: str, seconds: int) -> dict:
    """Invoke run_vst.py; retry only lock/busy, never on compile/run failure."""
    last = ""
    for attempt in range(MAX_LOCK_RETRIES):
        cmd = [
            sys.executable,
            str(RUN_VST),
            "--container", CONTAINER,
            "--seconds", str(seconds),
            "--name", name if attempt == 0 else f"{name}-r{attempt}",
            "--workdir", workdir,
            "--",
            *command,
        ]
        use_name = name if attempt == 0 else f"{name}-r{attempt}"
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=seconds + 45)
        combined = (proc.stdout or "") + (proc.stderr or "")
        last = combined
        lockish = (
            "BlockingIOError" in combined
            or "existing job" in combined
            or "choose a new run name" in combined
        )
        if lockish and attempt + 1 < MAX_LOCK_RETRIES:
            time.sleep(min(LOCK_SLEEP, 60))
            continue
        if lockish:
            raise SystemExit(f"{name}: lock contention after {MAX_LOCK_RETRIES} tries: {combined[-1500:]}")
        rec = assert_receipt(use_name, command, workdir)
        rec["_wrapper_returncode"] = proc.returncode
        rec["_run_name"] = use_name
        rec["_wrapper_stdout_tail"] = combined[-2000:]
        return rec
    raise SystemExit(f"{name}: exhausted retries: {last[-800:]}")


def harness_script() -> str:
    # Prints one JSON object per line: name, status, stdout_b64-like latin1, files.
    # Hand-coded expected values live in Python, not here as an oracle of Coq.
    return r'''
set -eu
export LC_ALL=C
PATH="$(pwd):$PATH"
mark(){ printf "\041"; }
enc() { python3 -c 'import sys; sys.stdout.write(sys.stdin.buffer.read().decode("latin1"))'; }

record() {
  name="$1"; st="$2"; out="$3"; extra="$4"
  python3 - "$name" "$st" "$out" "$extra" <<'PY'
import json,sys
name,st,out,extra=sys.argv[1],int(sys.argv[2]),sys.argv[3],sys.argv[4]
rec={"name":name,"status":st,"stdout_latin1":out}
if extra:
    rec["file_latin1"]=extra
print(json.dumps(rec), flush=True)
PY
}

# 1 bare relay
out=$(printf 'abc' | relay; echo -n X); st=$?
# capture without the X sentinel if we used it — use python instead
python3 - <<'PY'
import json,subprocess,os
env=os.environ.copy()
def run(script, stdin=b""):
    p=subprocess.run(["bash","-c",script], input=stdin, capture_output=True, env=env)
    return p.returncode, p.stdout
recs=[]
prelude='mark(){ printf "\\041"; }; '
st,out=run(prelude+"relay", b"abc")
recs.append({"name":"bare_relay","status":st,"stdout_bytes":list(out)})
st,out=run(prelude+"mark")
recs.append({"name":"bare_mark","status":st,"stdout_bytes":list(out)})
st,out=run(prelude+"relay | relay", b"abcdef")
recs.append({"name":"pipe_relay_relay","status":st,"stdout_bytes":list(out)})
open("out1","wb").write(b"")
st,out=run(prelude+"relay > out1", b"abc")
recs.append({"name":"redirect_truncate","status":st,"stdout_bytes":list(out),"file_bytes":list(open("out1","rb").read())})
open("out2","wb").write(b"xy")
st,out=run(prelude+"relay >> out2", b"abc")
recs.append({"name":"redirect_append","status":st,"stdout_bytes":list(out),"file_bytes":list(open("out2","rb").read())})
st,out=run(prelude+"relay | relay > out3", b"abcdef")
fb=list(open("out3","rb").read()) if os.path.exists("out3") else []
recs.append({"name":"pipe_then_redirect","status":st,"stdout_bytes":list(out),"file_bytes":fb})
st,out=run(prelude+"relay ; mark > log1", b"abc")
fb=list(open("log1","rb").read()) if os.path.exists("log1") else []
recs.append({"name":"seq_then_redirect","status":st,"stdout_bytes":list(out),"file_bytes":fb})
st,out=run(prelude+"relay && mark", b"abc")
recs.append({"name":"and_success_runs_mark","status":st,"stdout_bytes":list(out)})
st,out=run(prelude+"relay <&- ; echo STATUS $?")
recs.append({"name":"read_error_closed_stdin","status":st,"stdout_bytes":list(out)})
st,out=run(prelude+"relay <&- && mark ; echo STATUS $?")
recs.append({"name":"and_short_circuits_on_read_error","status":st,"stdout_bytes":list(out)})
st,out=run(prelude+"relay <&- || mark ; echo STATUS $?")
recs.append({"name":"or_runs_mark_on_read_error","status":st,"stdout_bytes":list(out)})
st,out=run("set -o pipefail; yes | head -c 2000000 | relay | true; echo STATUS ${PIPESTATUS[0]}")
recs.append({"name":"real_sigpipe_matches_modelled_status","status":st,"stdout_bytes":list(out)})
for r in recs:
    print(json.dumps(r), flush=True)
PY
'''


# Hand-coded expected observations. Not derived from executing Coq.
EXPECTED = {
    "bare_relay": {"status": 0, "stdout_bytes": list(b"abc")},
    "bare_mark": {"status": 0, "stdout_bytes": [33]},
    "pipe_relay_relay": {"status": 0, "stdout_bytes": list(b"abcdef")},
    "redirect_truncate": {"status": 0, "stdout_bytes": [], "file_bytes": list(b"abc")},
    "redirect_append": {"status": 0, "file_bytes": list(b"xyabc")},
    "pipe_then_redirect": {"status": 0, "stdout_bytes": [], "file_bytes": list(b"abcdef")},
    "seq_then_redirect": {"status": 0, "stdout_bytes": list(b"abc"), "file_bytes": [33]},
    "and_success_runs_mark": {"status": 0, "stdout_bytes": list(b"abc") + [33]},
    "read_error_closed_stdin": {"closed_relay_status": 1},
    "and_short_circuits_on_read_error": {"stdout_bytes": list(b"STATUS 1\n")},
    "or_runs_mark_on_read_error": {"stdout_bytes": [33] + list(b"STATUS 0\n")},
    "real_sigpipe_matches_modelled_status": {"pipestatus0": 141},
}


def parse_status_echo(stdout_bytes: list[int]) -> int | None:
    text = bytes(stdout_bytes).decode("latin1", "replace")
    for line in text.splitlines():
        if line.startswith("STATUS "):
            return int(line.split()[1])
    return None


def check_case(obs: dict) -> tuple[bool, dict]:
    name = obs["name"]
    exp = EXPECTED[name]
    extra = {"observed": obs, "expected_hand_coded": exp}
    if name == "read_error_closed_stdin":
        got = parse_status_echo(obs["stdout_bytes"])
        ok = got == exp["closed_relay_status"]
        extra["parsed_status"] = got
        return ok, extra
    if name == "real_sigpipe_matches_modelled_status":
        got = parse_status_echo(obs["stdout_bytes"])
        ok = got == exp["pipestatus0"]
        extra["parsed_pipestatus0"] = got
        extra["note"] = (
            "Hand-coded 141 = 128+SIGPIPE; independent of PipeRR. "
            "Not a Coq-executed oracle."
        )
        return ok, extra
    ok = True
    if "status" in exp:
        ok = ok and obs.get("status") == exp["status"]
    if "stdout_bytes" in exp:
        ok = ok and obs.get("stdout_bytes") == exp["stdout_bytes"]
    if "file_bytes" in exp:
        ok = ok and obs.get("file_bytes") == exp["file_bytes"]
    return ok, extra


def main() -> int:
    LOGS.mkdir(parents=True, exist_ok=True)
    JOBDIR.mkdir(parents=True, exist_ok=True)
    runid = new_runid()
    workdir = f"/home/coq/phase5/shellexpval9-{runid}"
    prefix = f"shellexpval9-{runid}"

    relay_c_bytes = RELAY_C_SOURCE.read_bytes()
    relay_i_bytes = RELAY_I_CHECKED.read_bytes()
    main_c = b'#include "relay.c"\nint main(void) { return relay(); }\n'
    driver = harness_script().encode()

    provenance = {
        "relay_c_path": str(RELAY_C_SOURCE),
        "relay_c_sha256": sha256_bytes(relay_c_bytes),
        "relay_i_path": str(RELAY_I_CHECKED),
        "relay_i_sha256": sha256_bytes(relay_i_bytes),
        "relay_c_equals_relay_i": sha256_bytes(relay_c_bytes) == sha256_bytes(relay_i_bytes),
        "identity_claim": (
            "Exact file hashes recorded. relay.c and CompCert-preprocessed relay.i "
            "are different artifacts; this script does not claim substring presence "
            "proves translation identity."
        ),
        "wrapper": str(RUN_VST),
        "wrapper_sha256": sha256_file(RUN_VST),
        "container": CONTAINER,
        "expectations": "hand-coded literals in validate_extended.py; no executable Coq oracle",
        "scope": (
            "Finite directed container execution via run_vst.py. Not a parser/"
            "semantics completeness or correctness proof. Not an automated model differential."
        ),
    }

    docker_mkdir(workdir)
    with tempfile.TemporaryDirectory(dir=str(JOBDIR)) as td:
        tdp = Path(td)
        (tdp / "relay.c").write_bytes(relay_c_bytes)
        (tdp / "relay_main.c").write_bytes(main_c)
        (tdp / "driver.sh").write_bytes(driver)
        docker_cp(tdp / "relay.c", workdir, "relay.c")
        docker_cp(tdp / "relay_main.c", workdir, "relay_main.c")
        docker_cp(tdp / "driver.sh", workdir, "driver.sh")

    gcc_name = f"{prefix}-gcc"
    gcc_cmd = ["gcc", "-O0", "-o", "relay", "relay_main.c"]
    gcc_rec = run_vst_lock_retry(gcc_name, gcc_cmd, workdir, seconds=30)
    if gcc_rec.get("exit_status") != 0 or gcc_rec.get("timing_exit_status") != 0:
        raise SystemExit(f"gcc failed: {gcc_rec}")

    run_name = f"{prefix}-driver"
    run_cmd = ["bash", "driver.sh"]
    run_rec = run_vst_lock_retry(run_name, run_cmd, workdir, seconds=60)

    log_text = (LOGS / f"{run_rec['_run_name']}.log").read_text(errors="replace")
    observations = []
    for line in log_text.splitlines():
        line = line.strip()
        if line.startswith("{") and '"name"' in line:
            observations.append(json.loads(line))

    records = []
    failures = 0
    by_name = {o["name"]: o for o in observations}
    for name in EXPECTED:
        if name not in by_name:
            failures += 1
            records.append({"name": name, "agree": False, "error": "missing observation"})
            continue
        ok, extra = check_case(by_name[name])
        failures += 0 if ok else 1
        records.append({"name": name, "agree": ok, **extra})

    summary = {
        "runid": runid,
        "workdir": workdir,
        "provenance": provenance,
        "gcc_receipt": {
            "name": gcc_rec["_run_name"],
            "exit_status": gcc_rec["exit_status"],
            "timing_exit_status": gcc_rec["timing_exit_status"],
            "elapsed_seconds": gcc_rec.get("elapsed_seconds"),
            "host_elapsed_seconds": gcc_rec.get("host_elapsed_seconds"),
            "log_sha256": gcc_rec.get("log_sha256"),
            "peak_rss_kib": gcc_rec.get("peak_rss_kib"),
            "wrapper_returncode": gcc_rec["_wrapper_returncode"],
        },
        "driver_receipt": {
            "name": run_rec["_run_name"],
            "exit_status": run_rec["exit_status"],
            "timing_exit_status": run_rec["timing_exit_status"],
            "elapsed_seconds": run_rec.get("elapsed_seconds"),
            "host_elapsed_seconds": run_rec.get("host_elapsed_seconds"),
            "log_sha256": run_rec.get("log_sha256"),
            "peak_rss_kib": run_rec.get("peak_rss_kib"),
            "wrapper_returncode": run_rec["_wrapper_returncode"],
        },
        "historical_host_unwrapped": "results/bash_execution_validation.host-unwrapped.historical.json",
        "total": len(records),
        "disagreements": failures,
        "records": records,
    }

    results = HERE / "results"
    results.mkdir(exist_ok=True)
    hist = results / "bash_execution_validation.json"
    hist_dest = results / "bash_execution_validation.host-unwrapped.historical.json"
    if hist.is_file() and not hist_dest.is_file():
        hist.replace(hist_dest)
    out = results / "bash_execution_validation.corrected12.json"
    out.write_text(json.dumps(summary, indent=1) + "\n")
    # Convenience copy under the old name points at corrected run.
    (results / "bash_execution_validation.json").write_text(json.dumps(summary, indent=1) + "\n")
    print(json.dumps({k: v for k, v in summary.items() if k != "records"}, indent=1))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
