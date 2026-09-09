#!/usr/bin/env python3
"""Serial C/Lean differential replay against the independent relay oracle. See CONTRACT.md.

Requires Linux; writes results.json, per_case.jsonl, and summary.md under --out."""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import io
import json
import os
import platform
import shutil
import stat
import subprocess
import sys
import time
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from relaycheck import FROZEN_RELAY_SHA256, __version__  # noqa: E402
from relaycheck.build import build_all, sha256_file  # noqa: E402
from relaycheck.corpus import Case, build_corpus, corpus_hash, corpus_manifest  # noqa: E402
from relaycheck.oracle import Outcome, run_relay  # noqa: E402
from relaycheck.runner import RunResult, run_exe, scratch_for_thread  # noqa: E402
from relaycheck.schedule import ScheduleError  # noqa: E402

DEFAULT_SOURCE = HERE.parent / "relay.c"
DEFAULT_OUT = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "relaycheck"
DRIVER_EXTRA = ["--max-calls", "20000", "--timeout-seconds", "10"]
STATUS_USAGE = 64
STATUS_ABORT = 3


def sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def first_line(cmd: list[str]) -> str | None:
    try:
        cp = subprocess.run(cmd, capture_output=True, text=True, timeout=20)
        out = (cp.stdout or cp.stderr).strip().splitlines()
        return out[0] if out else None
    except (OSError, subprocess.TimeoutExpired):
        return None


def environment() -> dict:
    return {
        "timestamp_utc": dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds"),
        "uname": " ".join(platform.uname()),
        "python": sys.version.split()[0],
        "cc": first_line(["cc", "--version"]),
        "nm": first_line(["nm", "--version"]),
        "strace": first_line(["strace", "-V"]),
        "lean": first_line(["lean", "--version"]),
        "relaycheck_version": __version__,
        "cwd": os.getcwd(),
    }


def expected_for(case: Case) -> Outcome | None:
    """Oracle expectation; None for cases expected to be rejected by the CLI."""
    if case.expect_reject:
        return None
    return run_relay(case.data, list(case.reads), list(case.writes))


def summarize_run(rr: RunResult) -> dict:
    return {
        "status": rr.status,
        "stdout_len": len(rr.stdout),
        "stdout_sha256": sha(rr.stdout),
        "stderr": rr.stderr_text[:400],
        "wall": round(rr.wall, 5),
        "maxrss_kb": rr.maxrss_kb,
        "timed_out": rr.timed_out,
    }


def judge_protocol(case: Case, exp: Outcome | None, rr: RunResult, strict_64: bool) -> list[str]:
    problems = []
    if rr.timed_out:
        problems.append("timed out")
    if exp is None:
        if strict_64 and rr.status != STATUS_USAGE:
            problems.append(f"reject: status {rr.status} != 64")
        if not strict_64 and rr.status in (0, 1, 2):
            problems.append(f"reject: status {rr.status} looks like a relay result")
        if rr.stdout:
            problems.append(f"reject: stdout not empty ({len(rr.stdout)} bytes)")
        return problems
    if rr.status != exp.status:
        problems.append(f"status {rr.status} != {exp.status}")
    if rr.stdout != exp.output:
        if len(rr.stdout) != len(exp.output):
            problems.append(f"stdout length {len(rr.stdout)} != {len(exp.output)}")
        else:
            i = next(k for k in range(len(exp.output)) if rr.stdout[k] != exp.output[k])
            problems.append(f"stdout differs at byte {i}: {rr.stdout[i]:#04x} != {exp.output[i]:#04x}")
    if rr.stderr != exp.stderr_text().encode():
        problems.append(f"stderr {rr.stderr_text!r} != {exp.stderr_text()!r}")
    return problems


def judge_control(case: Case, rr: RunResult) -> list[str]:
    """Under fd isolation, unshimmed read(0) must fail with EBADF without calling the shims."""
    problems = []
    if case.expect_reject:
        if rr.status != STATUS_USAGE:
            problems.append(f"reject: status {rr.status} != 64")
        return problems
    if rr.status != 1:
        problems.append(f"status {rr.status} != 1 (real read on closed fd 0 should fail)")
    if rr.stdout:
        problems.append("stdout not empty")
    if rr.stderr != b"consumed=0\nread_calls=0\nwrite_calls=0\n":
        problems.append(f"shim counters touched: {rr.stderr_text!r}")
    return problems


def judge_real(case: Case, rr: RunResult) -> list[str]:
    problems = []
    if rr.status != 0:
        problems.append(f"status {rr.status} != 0")
    if rr.stdout != case.data:
        problems.append("stdout != input")
    if rr.stderr:
        problems.append(f"stderr not empty: {rr.stderr_text[:100]!r}")
    return problems


class Harness:
    def __init__(self, build: dict, out: Path, model: Path | None, timeout: float):
        self.exes = build["executables"]
        self.tmp = out / "tmp"
        self.model = model
        self.timeout = timeout
        self.originals = sorted(n for n, e in self.exes.items() if e["role"] == "original")
        self.mutants = sorted(n for n, e in self.exes.items() if e["role"] == "mutant")

    def driver_argv(self, exe: str, case: Case) -> list[str]:
        argv = [self.exes[exe]["path"], *case.argv()]
        if case.extra_argv is None and case.pass_flags:
            argv += DRIVER_EXTRA
        return argv

    def run_case(self, case: Case) -> dict:
        scratch = scratch_for_thread(self.tmp)
        t0 = time.monotonic()
        try:
            exp = expected_for(case)
            oracle_err = None
        except ScheduleError as e:
            exp, oracle_err = None, str(e)
        rec = {
            "name": case.name,
            "category": case.category,
            "argv": case.argv(),
            "data_len": len(case.data),
            "expect_reject": case.expect_reject,
            "expected": None if exp is None else {
                "status": exp.status, "output_len": len(exp.output), "output_sha256": sha(exp.output),
                "consumed": exp.consumed, "read_calls": exp.read_calls, "write_calls": exp.write_calls,
            },
            "oracle_error": oracle_err,
            "results": {},
        }
        for name in self.originals:
            rr = run_exe(self.driver_argv(name, case), case.data, scratch, self.timeout)
            probs = judge_protocol(case, exp, rr, strict_64=True)
            rec["results"][name] = {**summarize_run(rr), "ok": not probs, "problems": probs}
        rr = run_exe(self.driver_argv("unshimmed_control", case), case.data, scratch, self.timeout)
        probs = judge_control(case, rr)
        rec["results"]["unshimmed_control"] = {**summarize_run(rr), "ok": not probs, "problems": probs}
        # real kernel relay on default-only, flag-free-equivalent cases
        if exp is not None and not case.reads and not case.writes and case.extra_argv is None:
            rr = run_exe([self.exes["relay_real"]["path"]], case.data, scratch, self.timeout)
            probs = judge_real(case, rr)
            rec["results"]["relay_real"] = {**summarize_run(rr), "ok": not probs, "problems": probs}
        # mutants: "ok" here means "matches the oracle", i.e. NOT distinguished on this case
        for name in self.mutants:
            rr = run_exe(self.driver_argv(name, case), case.data, scratch, self.timeout)
            probs = judge_protocol(case, exp, rr, strict_64=True)
            rec["results"][name] = {**summarize_run(rr), "matches_oracle": not probs, "problems": probs[:3]}
        if self.model is not None:
            rr = run_exe([str(self.model), *case.argv()], case.data, scratch, self.timeout)
            if rr.status < 0 or rr.timed_out:
                raise RuntimeError(f'model runtime failure on {case.name}: status={rr.status} stderr={rr.stderr_text[:300]}')
            probs = judge_protocol(case, exp, rr, strict_64=True)
            r = {**summarize_run(rr), "ok": not probs, "problems": probs}
            if exp is None:
                r["reject_status_is_64"] = rr.status == STATUS_USAGE
            rec["results"]["model"] = r
        rec["case_seconds"] = round(time.monotonic() - t0, 4)
        return rec


def kernel_smoke_tests(build: dict, out: Path, timeout: float) -> list[dict]:
    """Check real kernel IO and verify shimmed calls do not reach the kernel."""
    real = build["executables"]["relay_real"]["path"]
    orig = build["executables"]["orig_macro_O2"]["path"]
    scratch = scratch_for_thread(out / "tmp")
    tests = []

    def rec(name, ok, detail):
        tests.append({"name": name, "ok": None if ok is None else bool(ok), **detail})

    data = bytes(range(256)) * 4 + b"tail"
    rr = run_exe([real], data, scratch, timeout)
    rec("real/copy_1028_bytes", rr.status == 0 and rr.stdout == data and not rr.stderr, summarize_run(rr))
    big = hashlib.sha256(b"big").digest() * (1 << 15)
    rr = run_exe([real], big, scratch, timeout)
    rec("real/copy_1MiB", rr.status == 0 and rr.stdout == big, summarize_run(rr))
    rr = run_exe([real], b"", scratch, timeout)
    rec("real/empty_input_status0", rr.status == 0 and rr.stdout == b"", summarize_run(rr))
    rr = run_exe([real], b"abc", scratch, timeout, preexec_fn=lambda: os.close(0))
    rec("real/closed_stdin_EBADF_status1", rr.status == 1 and rr.stdout == b"", summarize_run(rr))
    if Path("/dev/full").exists():
        rr = run_exe([real], b"abc", scratch, timeout, stdout_path="/dev/full")
        rec("real/stdout_dev_full_ENOSPC_status2", rr.status == 2, {**summarize_run(rr), "stdout_len": None})
        rr = run_exe([real], b"", scratch, timeout, stdout_path="/dev/full")
        rec("real/stdout_dev_full_empty_input_status0", rr.status == 0, {**summarize_run(rr), "stdout_len": None})
    rr = run_exe([real], b"abc", scratch, timeout, preexec_fn=lambda: os.close(1))
    rec("real/closed_stdout_EBADF_status2", rr.status == 1 + 1, summarize_run(rr))
    # stdin from a file rather than a pipe (different read path in the kernel)
    f = out / "tmp" / "smoke_file_input.bin"
    f.write_bytes(data)
    rr = run_exe([real], b"", scratch, timeout, stdin_from=str(f))
    rec("real/stdin_regular_file", rr.status == 0 and rr.stdout == data, summarize_run(rr))

    # strace: count kernel-level read(0,...) / write(1,...) for the real relay vs the shimmed driver
    if shutil.which("strace"):
        def traced(argv, stdin_bytes):
            log = out / "tmp" / "strace.log"
            if log.exists():
                log.unlink()
            rr = run_exe(["strace", "-e", "trace=read,write", "-o", str(log), *argv], stdin_bytes, scratch, timeout)
            lines = log.read_text().splitlines() if log.exists() else []
            return rr, {
                "kernel_read_fd0": sum(1 for l in lines if l.startswith("read(0,")),
                "kernel_write_fd1": sum(1 for l in lines if l.startswith("write(1,")),
                "kernel_write_other": sum(1 for l in lines if l.startswith("write(") and not l.startswith("write(1,")),
                "strace_lines": len(lines),
            }

        d40 = bytes(range(40))
        rr, k = traced([real], d40)
        ok = rr.status == 0 and k["kernel_read_fd0"] == 3 and k["kernel_write_fd1"] == 2
        rec("strace/real_relay_40B_read3_write2", ok, {**summarize_run(rr), **k,
                                                      "note": "relay_real: read 32, read 8, read 0; write 32, write 8"})
        rr, k = traced([orig, "--reads", "1,1,1,1", "--writes", "1,1,1"], d40)
        exp = run_relay(d40, [1, 1, 1, 1], [1, 1, 1])
        ok = (rr.status == 0 and rr.stdout == d40 and rr.stderr == exp.stderr_text().encode()
              and k["kernel_write_fd1"] == 0 and k["kernel_read_fd0"] <= 2 and exp.read_calls == 7)
        rec("strace/shimmed_driver_no_kernel_relay_io", ok, {
            **summarize_run(rr), **k, "shim_read_calls": exp.read_calls, "shim_write_calls": exp.write_calls,
            "note": "shim counted 7 reads / 6 writes; kernel saw only the driver's stdin slurp on fd 0 and no write(1,...)",
        })
        if not ok and rr.status != 0 and k["strace_lines"] == 0:
            tests[-1]["note"] += " (strace produced no trace: ptrace may be restricted here)"
    else:
        rec("strace/unavailable", None, {"note": "strace not installed; skipped"})
    return tests


def run_selftest() -> dict:
    suite = unittest.defaultTestLoader.discover(str(HERE / "tests"), pattern="test_*.py")
    stream = io.StringIO()
    result = unittest.TextTestRunner(stream=stream, verbosity=1).run(suite)
    return {
        "ran": result.testsRun,
        "failures": len(result.failures),
        "errors": len(result.errors),
        "ok": result.wasSuccessful(),
        "output_tail": stream.getvalue()[-1500:],
    }


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", type=Path, default=DEFAULT_SOURCE, help="frozen relay.c (read only)")
    ap.add_argument("--model", type=Path, default=None, help="Lean model executable implementing the wire protocol")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT, help="external cache/results directory")
    ap.add_argument("--tier", choices=["quick", "standard", "full"], default="standard")
    ap.add_argument("--workers", type=int, default=1, choices=[1])
    ap.add_argument("--timeout", type=float, default=30.0, help="per-process kill timeout (s)")
    ap.add_argument("--cc", default="cc")
    ap.add_argument("--driver-dir", type=Path, default=HERE / "driver")
    ap.add_argument("--copy-results-to", type=Path, default=None, help="also copy results.json/summary.md here")
    args = ap.parse_args(argv)
    repository = HERE.parents[3]
    candidate_out = args.out.expanduser().resolve()
    if candidate_out == repository or repository in candidate_out.parents:
        ap.error("build/output directory must stay outside the repository")
    # Reject changed C before building or reusing any executable. This is provenance,
    # not a translation correctness proof.
    if sha256_file(args.source.expanduser().resolve()) != FROZEN_RELAY_SHA256:
        ap.error("source does not match the frozen relay")

    out: Path = args.out.expanduser().resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "tmp").mkdir(exist_ok=True)
    t_start = time.monotonic()
    results: dict = {"environment": environment(), "args": {k: str(v) for k, v in vars(args).items()}}

    results["selftest"] = run_selftest()
    print(f"[selftest] ran={results['selftest']['ran']} ok={results['selftest']['ok']}")

    if not results['selftest']['ok']:
        print(results['selftest']['output_tail'], file=sys.stderr)
        raise RuntimeError('self-test failed; refusing corpus execution')

    source: Path = args.source.expanduser().resolve()
    if not source.is_file():
        print(f"source not found: {source}", file=sys.stderr)
        return 2
    src_hash = sha256_file(source)
    results["source"] = {
        "path": str(source), "sha256": src_hash, "frozen_sha256": FROZEN_RELAY_SHA256,
        "matches_frozen": src_hash == FROZEN_RELAY_SHA256, "bytes": source.stat().st_size,
    }
    print(f"[source] {source} sha256={src_hash[:16]}... matches_frozen={results['source']['matches_frozen']}")

    build_dir = out / "build"
    build_json = build_dir / "build.json"
    # C builds are tiny; always rebuild the complete fixed suite. This removes
    # stale compiler/mutant/recipe reuse rather than treating old binaries as current.
    t0 = time.monotonic()
    build = build_all(source, args.driver_dir.resolve(), build_dir, cc=args.cc, with_mutants=True)
    build["wall_seconds"] = round(time.monotonic() - t0, 3)
    build_json.write_text(json.dumps(build, indent=1))
    print(f"[build] {len(build['executables'])} executables in {build['wall_seconds']}s; "
          f"symbol checks ok={all(c['ok'] for c in build['symbol_checks'])}")
    results["build"] = {k: v for k, v in build.items() if k != "log"}
    results["build"]["log_entries"] = len(build["log"])

    model: Path | None = None
    if args.model is not None:
        model = args.model.expanduser().resolve()
        if not model.is_file() or not (model.stat().st_mode & stat.S_IXUSR):
            print(f"model is not an executable file: {model}", file=sys.stderr)
            return 2
        results["model"] = {"status": "supplied", "path": str(model), "sha256": sha256_file(model),
                            "mtime_utc": dt.datetime.fromtimestamp(model.stat().st_mtime, dt.timezone.utc).isoformat()}
    else:
        results["model"] = {"status": "waiting-model", "path": None,
                            "note": "no --model supplied; C-vs-oracle only. Re-run with --model PATH when available."}

    cases = build_corpus(args.tier)
    manifest = corpus_manifest(cases)
    chash = corpus_hash(cases)
    (out / "corpus_manifest.json").write_text(json.dumps({"tier": args.tier, "sha256": chash, "cases": manifest}, indent=0))
    cats: dict[str, int] = {}
    for c in cases:
        cats[c.category] = cats.get(c.category, 0) + 1
    results["corpus"] = {"tier": args.tier, "cases": len(cases), "sha256": chash, "by_category": cats,
                         "manifest": str(out / "corpus_manifest.json")}
    print(f"[corpus] tier={args.tier} cases={len(cases)} sha256={chash[:16]}... {cats}")

    t0 = time.monotonic()
    n_valid = sum(1 for c in cases if expected_for(c) is not None)
    results["oracle"] = {"seconds_all_cases": round(time.monotonic() - t0, 4), "valid_cases": n_valid,
                         "reject_cases": len(cases) - n_valid}

    harness = Harness(build, out, model, args.timeout)
    per_case_path = out / "per_case.jsonl"
    t0 = time.monotonic()
    records = []
    with per_case_path.open("w") as fh:
        for i, rec in enumerate(map(harness.run_case, cases), 1):
            records.append(rec)
            fh.write(json.dumps(rec, separators=(",", ":")) + "\n")
            if i % 500 == 0 or i == len(cases):
                print(f"[run] {i}/{len(cases)} cases, {time.monotonic() - t0:.1f}s")
    results["run_seconds"] = round(time.monotonic() - t0, 3)

    exe_names = sorted({n for r in records for n in r["results"]})
    agg: dict[str, dict] = {}
    for n in exe_names:
        runs = [r["results"][n] for r in records if n in r["results"]]
        walls = [x["wall"] for x in runs]
        agg[n] = {
            "role": build["executables"].get(n, {}).get("role", "model" if n == "model" else "?"),
            "runs": len(runs),
            "wall_sum_s": round(sum(walls), 3),
            "wall_mean_ms": round(1000 * sum(walls) / len(walls), 3),
            "wall_max_ms": round(1000 * max(walls), 3),
            "maxrss_kb_max": max(x["maxrss_kb"] for x in runs),
            "timeouts": sum(1 for x in runs if x["timed_out"]),
            "status_histogram": {str(s): sum(1 for x in runs if x["status"] == s) for s in sorted({x["status"] for x in runs})},
        }
        if "ok" in runs[0]:
            agg[n]["ok"] = sum(1 for x in runs if x["ok"])
            agg[n]["mismatches"] = [r["name"] for r in records if n in r["results"] and not r["results"][n]["ok"]][:50]
            agg[n]["all_ok"] = all(x["ok"] for x in runs)
        else:
            differing = [r for r in records if n in r["results"] and not r["results"][n]["matches_oracle"]]
            valid = [r for r in records if n in r["results"] and not r["expect_reject"]]
            agg[n]["distinguished_cases"] = len(differing)
            agg[n]["valid_cases"] = len(valid)
            agg[n]["killed"] = len(differing) > 0
            agg[n]["aborts_status3"] = sum(1 for r in records if n in r["results"] and r["results"][n]["status"] == STATUS_ABORT)
            agg[n]["first_distinguishing"] = None if not differing else {
                "case": differing[0]["name"], "problems": differing[0]["results"][n]["problems"]}
            bycat: dict[str, int] = {}
            for r in differing:
                bycat[r["category"]] = bycat.get(r["category"], 0) + 1
            agg[n]["distinguished_by_category"] = bycat
    results["executables"] = agg

    results["kernel_smoke"] = kernel_smoke_tests(build, out, args.timeout)
    passed = sum(t["ok"] is True for t in results["kernel_smoke"])
    skipped = [t["name"] for t in results["kernel_smoke"] if t["ok"] is None]
    results["kernel_smoke_skipped"] = skipped
    print(f"[smoke] {passed} passed; skipped={skipped}")

    orig_ok = all(agg[n]["all_ok"] for n in harness.originals)
    control_ok = agg["unshimmed_control"]["all_ok"]
    real_ok = agg.get("relay_real", {}).get("all_ok", True)
    mutants_ok = all(agg[n]["killed"] for n in harness.mutants) if harness.mutants else True
    smoke_ok = all(t["ok"] for t in results["kernel_smoke"] if t["ok"] is not None)
    sym_ok = all(c["ok"] for c in build["symbol_checks"])
    oracle_consistent = not any(r["oracle_error"] for r in records)
    checks = {
        "selftest_ok": results["selftest"]["ok"],
        "source_matches_frozen": results["source"]["matches_frozen"],
        "symbol_checks_ok": sym_ok,
        "c_originals_match_oracle": orig_ok,
        "unshimmed_control_fails_as_predicted": control_ok,
        "real_relay_default_cases_ok": real_ok,
        "all_mutants_distinguished": mutants_ok,
        "kernel_smoke_ok": smoke_ok,
        "oracle_accepts_all_valid_cases": oracle_consistent,
    }
    if model is not None:
        checks["model_matches_oracle"] = agg["model"]["all_ok"]
        results["model"]["status"] = "PASS" if agg["model"]["all_ok"] else "FAIL"
        results["model"]["reject_cases_status_64"] = sum(
            1 for r in records if r["expect_reject"] and r["results"]["model"].get("reject_status_is_64"))
    results["checks"] = checks
    c_side = all(v for k, v in checks.items() if k != "model_matches_oracle")
    if not c_side:
        overall = "FAIL"
    elif model is None:
        overall = "PASS_WAITING_MODEL"
    else:
        overall = "PASS" if checks["model_matches_oracle"] else "FAIL"
    results["validation_source_hashes"] = {
        str(p.relative_to(HERE)): sha256_file(p) for p in sorted(HERE.rglob('*'))
        if p.is_file() and p.suffix in ('.py', '.c', '.json')}
    results["per_case_sha256"] = sha256_file(per_case_path)
    results["limits"] = {"workers": 1, "parallel_compilers": 1,
                         "parent_address_space_bytes": 3221225472,
                         "parent_cpu_seconds": 600, "child_address_space_bytes": 3221225472,
                         "child_cpu_seconds": 30, "child_wall_seconds": args.timeout,
                         "capture_file_cap_bytes": 134217728,
                         "compiler_address_space_bytes": 1073741824, "compiler_wall_seconds": 60}
    results["overall"] = overall
    results["total_seconds"] = round(time.monotonic() - t_start, 3)

    (out / "results.json").write_text(json.dumps(results, indent=1))
    (out / "summary.md").write_text(render_summary(results))
    if args.copy_results_to:
        args.copy_results_to.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(out / "results.json", args.copy_results_to / "results.json")
        shutil.copyfile(out / "summary.md", args.copy_results_to / "summary.md")
    for p in (out / "tmp").glob("t*.in"):
        p.unlink(missing_ok=True)
    print(f"[done] overall={overall} in {results['total_seconds']}s -> {out / 'results.json'}")
    return 0 if overall.startswith("PASS") else 1


def render_summary(res: dict) -> str:
    L = []
    L.append(f"# relaycheck summary\n\nOverall: **{res['overall']}**  (model: {res['model']['status']})\n")
    L.append(f"Source `{res['source']['path']}` sha256 `{res['source']['sha256']}` "
             f"matches frozen: {res['source']['matches_frozen']}\n")
    L.append(f"Corpus tier {res['corpus']['tier']}, {res['corpus']['cases']} cases, sha256 `{res['corpus']['sha256']}`\n")
    L.append("## Checks\n")
    for k, v in res["checks"].items():
        L.append(f"- {k}: {'PASS' if v else 'FAIL'}")
    L.append("\n## Executables\n")
    L.append("| executable | role | runs | ok / killed | mean ms | max RSS KB |")
    L.append("|---|---|---:|---:|---:|---:|")
    for n, a in res["executables"].items():
        okc = f"{a['ok']}/{a['runs']}" if "ok" in a else f"killed on {a['distinguished_cases']}/{a['valid_cases']}"
        L.append(f"| {n} | {a['role']} | {a['runs']} | {okc} | {a['wall_mean_ms']} | {a['maxrss_kb_max']} |")
    if res.get("kernel_smoke"):
        L.append("\n## Kernel I/O smoke tests\n")
        for t in res["kernel_smoke"]:
            L.append(f"- {t['name']}: {'SKIPPED' if t['ok'] is None else ('PASS' if t['ok'] else 'FAIL')} (status {t.get('status')})")
    L.append(f"\nTotal {res['total_seconds']}s; build {res['build'].get('wall_seconds')}s; run {res['run_seconds']}s.\n")
    return "\n".join(L)


if __name__ == "__main__":
    import resource
    resource.setrlimit(resource.RLIMIT_AS, (3221225472, 3221225472))
    resource.setrlimit(resource.RLIMIT_CPU, (600, 600))
    resource.setrlimit(resource.RLIMIT_FSIZE, (134217728, 134217728))
    sys.exit(main())
