#!/usr/bin/env python3
"""Validate pointer events from frozen relay.c against independent traces and invariants.

Modes: selftest, dry-run (plan builds), full (serial bounded build and execution).
Output must be outside the repository; budget exhaustion is reported as INCOMPLETE."""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import io
import json
import os
import platform
import re
import shutil
import sys
import time
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from ptrcheck import FROZEN_RELAY_SHA256, __version__  # noqa: E402
from ptrcheck.build_probe import build_all, sha256_file  # noqa: E402
from ptrcheck.cases import CASE_BUDGET, Case, build_cases, corpus_hash, corpus_manifest  # noqa: E402
from ptrcheck.exec_bounded import (EXE_AS_BYTES, EXE_CPU_SECONDS, EXE_FSIZE_BYTES, EXE_WALL_SECONDS,  # noqa: E402
                                   Scratch, run_bounded)
from ptrcheck.invariants import check_invariants  # noqa: E402
from ptrcheck.judge import STATUS_ABORT, STATUS_USAGE, classify_distinction, compare_documents, wire_problems  # noqa: E402
from ptrcheck.pointer_model import run_pointer_machine  # noqa: E402
from ptrcheck.trace_format import (document_from_probe, expand_hand_traces, parse_probe_jsonl,  # noqa: E402
                                   trace_sha256, validate_document)

DEFAULT_SOURCE = HERE.parents[1] / "phase2" / "relay.c"
DEFAULT_OUT = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "bash-spec-pilot" / "phase3-ptrcheck"
PROBE_SRC = HERE / "probe" / "pointer_probe.c"
HAND_TRACES = HERE / "hand_traces.json"
PROBE_TIMEOUT_SECONDS = "2"
TRACE_FILE_CAP = 600
ZERO_COUNTERS = b"consumed=0\nread_calls=0\nwrite_calls=0\n"


def sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def safe_name(name: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", name)[:150]


def environment() -> dict:
    return {"timestamp_utc": dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds"),
            "uname": " ".join(platform.uname()), "python": sys.version.split()[0],
            "ptrcheck_version": __version__, "cwd": os.getcwd()}


def run_selftest() -> dict:
    suite = unittest.defaultTestLoader.discover(str(HERE / "tests"), pattern="test_*.py")
    stream = io.StringIO()
    result = unittest.TextTestRunner(stream=stream, verbosity=1).run(suite)
    return {"ran": result.testsRun, "failures": len(result.failures), "errors": len(result.errors),
            "skipped": len(result.skipped), "ok": result.wasSuccessful(), "output_tail": stream.getvalue()[-2000:]}


def expected_for(case: Case):
    if case.expect_reject:
        return None
    return run_pointer_machine(case.data, list(case.reads), list(case.writes), name=case.name)


def brief(rr) -> dict:
    return {"status": rr.status, "stdout_len": len(rr.stdout), "stdout_sha256": sha(rr.stdout),
            "stderr": rr.stderr_text[:200], "wall": round(rr.wall, 5), "maxrss_kb": rr.maxrss_kb,
            "timed_out": rr.timed_out}


class Harness:
    def __init__(self, build: dict, out: Path, hand_docs: dict):
        self.exes = build["executables"]
        self.scratch = Scratch(out / "tmp", "case")
        self.traces_dir = out / "traces"
        self.traces_dir.mkdir(exist_ok=True)
        self.trace_files = 0
        self.hand_docs = hand_docs
        self.originals = sorted(n for n, e in self.exes.items() if e["role"] == "original")
        self.mutants = sorted(n for n, e in self.exes.items() if e["role"] == "mutant")

    def argv(self, exe: str, case: Case, max_calls: int) -> list[str]:
        return [self.exes[exe]["path"], *case.schedule_argv(), "--trace", str(self.scratch.trace),
                "--max-calls", str(max_calls), "--timeout-seconds", PROBE_TIMEOUT_SECONDS]

    def save_trace(self, case: Case, tag: str, doc: dict) -> None:
        if self.trace_files >= TRACE_FILE_CAP:
            return
        p = self.traces_dir / f"{safe_name(case.name)}.{tag}.json"
        p.write_text(json.dumps(doc, indent=0, sort_keys=True))
        self.trace_files += 1

    def run_probe(self, exe: str, case: Case, exp: dict | None, max_calls: int) -> tuple[dict, dict | None]:
        rr = run_bounded(self.argv(exe, case, max_calls), case.data, self.scratch)
        rec = brief(rr)
        if exp is None:
            probs = []
            if rr.status != STATUS_USAGE:
                probs.append(f"reject: status {rr.status} != {STATUS_USAGE}")
            if rr.stdout:
                probs.append("reject: stdout not empty")
            if rr.trace.strip():
                probs.append("reject: trace file written before rejection")
            rec.update({"events": 0, "wire_problems": probs, "event_problems": [], "final_problems": [],
                        "probe_problems": [], "invariant_problems": [], "schema_problems": []})
            return rec, None
        parsed = parse_probe_jsonl(rr.trace)
        act = document_from_probe(case.as_case_dict(), parsed, rr.status, rr.stdout, producer=f"c:{exe}")
        cmp = compare_documents(exp, act)
        rec.update({
            "events": len(act["events"]), "trace_sha256": trace_sha256(act),
            "wire_problems": wire_problems(exp["final"], rr.status, rr.stdout, rr.stderr, rr.timed_out),
            "event_problems": cmp["event_problems"][:8], "final_problems": cmp["final_problems"][:8],
            "probe_problems": cmp["probe_problems"][:8],
            "invariant_problems": check_invariants(act)[:8] if rr.status != STATUS_ABORT else ["aborted"],
            "schema_problems": validate_document(act)[:8],
            "aborted": act.get("probe_abort"),
        })
        return rec, act

    def run_case(self, case: Case) -> dict:
        t0 = time.monotonic()
        exp = expected_for(case)
        max_calls = 0 if exp is None else exp["final"]["read_calls"] + exp["final"]["write_calls"]
        rec = {"name": case.name, "category": case.category, "schedule_argv": case.schedule_argv(),
               "data_len": len(case.data), "data_sha256": sha(case.data), "expect_reject": case.expect_reject,
               "expected": None if exp is None else {"events": len(exp["events"]), "trace_sha256": trace_sha256(exp),
                                                     **exp["final"]},
               "max_calls": max_calls, "results": {}}
        if exp is not None:
            rec["expected_invariant_problems"] = check_invariants(exp)[:5]
            hand = self.hand_docs.get(case.name)
            if hand is not None:
                hc = compare_documents(hand, exp)
                rec["hand_vs_model"] = hc["event_problems"][:5] + hc["final_problems"][:5]
        keep = case.category in ("hand", "directed", "noflags")
        for name in self.originals:
            r, act = self.run_probe(name, case, exp, max_calls)
            r["ok"] = not any(r[k] for k in ("wire_problems", "event_problems", "final_problems", "probe_problems",
                                             "invariant_problems", "schema_problems"))
            if exp is not None and self.hand_docs.get(case.name) is not None and act is not None:
                hc = compare_documents(self.hand_docs[case.name], act)
                r["hand_problems"] = (hc["event_problems"] + hc["final_problems"])[:5]
                r["ok"] = r["ok"] and not r["hand_problems"]
            rec["results"][name] = r
            if act is not None and (keep and name == self.originals[0] or not r["ok"]):
                self.save_trace(case, name, act)
                self.save_trace(case, "model", exp)
        # unshimmed control: relay's read(0) reaches libc on a closed fd => status 1, no probe events
        rr = run_bounded(self.argv("unshimmed_control", case, max_calls), case.data, self.scratch)
        probs = []
        if exp is None:
            if rr.status != STATUS_USAGE:
                probs.append(f"reject: status {rr.status} != {STATUS_USAGE}")
        else:
            if rr.status != 1:
                probs.append(f"status {rr.status} != 1 (real read on closed fd 0 must fail)")
            if rr.stdout:
                probs.append("stdout not empty")
            if rr.stderr != ZERO_COUNTERS:
                probs.append(f"probe counters touched: {rr.stderr_text!r}")
            if parse_probe_jsonl(rr.trace)["events"]:
                probs.append("probe events recorded although read/write bind to libc")
        rec["results"]["unshimmed_control"] = {**brief(rr), "ok": not probs, "problems": probs}
        for name in self.mutants:
            if exp is None:
                continue
            r, act = self.run_probe(name, case, exp, max_calls)
            cmpd = {"event_problems": r["event_problems"], "final_problems": r["final_problems"],
                    "probe_problems": r["probe_problems"]}
            r["distinguished_by"] = classify_distinction(r["status"], r["wire_problems"], cmpd)
            rec["results"][name] = r
        rec["case_seconds"] = round(time.monotonic() - t0, 4)
        return rec


def aggregate(records: list, build: dict) -> dict:
    names = sorted({n for r in records for n in r["results"]})
    agg = {}
    for n in names:
        runs = [(r, r["results"][n]) for r in records if n in r["results"]]
        walls = [x["wall"] for _, x in runs]
        a = {"role": build["executables"].get(n, {}).get("role", "?"), "runs": len(runs),
             "wall_mean_ms": round(1000 * sum(walls) / max(1, len(walls)), 3), "wall_max_ms": round(1000 * max(walls or [0]), 3),
             "maxrss_kb_max": max([x["maxrss_kb"] for _, x in runs] or [0]),
             "timeouts": sum(1 for _, x in runs if x["timed_out"]),
             "status_histogram": {str(s): sum(1 for _, x in runs if x["status"] == s) for s in sorted({x["status"] for _, x in runs})}}
        if a["role"] in ("original", "control"):
            a["ok"] = sum(1 for _, x in runs if x["ok"])
            a["all_ok"] = all(x["ok"] for _, x in runs)
            a["mismatches"] = [r["name"] for r, x in runs if not x["ok"]][:40]
        else:
            by = {}
            for _, x in runs:
                d = x.get("distinguished_by")
                by[d or "none"] = by.get(d or "none", 0) + 1
            a["distinguished_by"] = by
            a["distinguished_cases"] = sum(v for k, v in by.items() if k != "none")
            a["killed"] = a["distinguished_cases"] > 0
            first = next(((r, x) for r, x in runs if x.get("distinguished_by")), None)
            a["first_distinguishing"] = None if first is None else {
                "case": first[0]["name"], "by": first[1]["distinguished_by"],
                "problems": (first[1]["wire_problems"] + first[1]["event_problems"] + first[1]["probe_problems"])[:3]}
            first_ev = next(((r, x) for r, x in runs if x.get("distinguished_by") == "event_only"), None)
            a["first_event_only"] = None if first_ev is None else {
                "case": first_ev[0]["name"], "problems": (first_ev[1]["event_problems"] + first_ev[1]["probe_problems"])[:3]}
        agg[n] = a
    return agg


def render_summary(res: dict) -> str:
    L = [f"# ptrcheck summary\n\nOverall: **{res['overall']}** (mode {res['args']['mode']}, tier {res['corpus']['tier']})\n",
         f"Source `{res['source']['path']}` sha256 `{res['source']['sha256']}` matches frozen: {res['source']['matches_frozen']}\n",
         f"Corpus {res['corpus']['cases']} cases, sha256 `{res['corpus']['sha256']}`; executed {res.get('cases_executed')}\n",
         "## Checks\n"]
    for k, v in res.get("checks", {}).items():
        L.append(f"- {k}: {'PASS' if v else 'FAIL'}")
    if res.get("executables"):
        L += ["\n## Executables\n", "| executable | role | runs | ok / distinguished | mean ms | max RSS KB |", "|---|---|---:|---:|---:|---:|"]
        for n, a in res["executables"].items():
            okc = f"{a['ok']}/{a['runs']}" if "ok" in a else f"{a['distinguished_cases']}/{a['runs']} {a['distinguished_by']}"
            L.append(f"| {n} | {a['role']} | {a['runs']} | {okc} | {a['wall_mean_ms']} | {a['maxrss_kb_max']} |")
    L.append(f"\nTotal {res['total_seconds']}s.\n")
    return "\n".join(L)


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--mode", choices=["selftest", "dry-run", "full"], default="full")
    ap.add_argument("--tier", choices=["quick", "standard", "full"], default="standard")
    ap.add_argument("--source", type=Path, default=DEFAULT_SOURCE, help="frozen relay.c (read only)")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT, help="build/results directory outside the repository")
    ap.add_argument("--cc", default="cc")
    ap.add_argument("--budget-seconds", type=float, default=600.0, help="overall wall budget for corpus execution")
    ap.add_argument("--allow-large-corpus", action="store_true", help=f"permit tiers above {CASE_BUDGET} cases")
    ap.add_argument("--copy-results-to", type=Path, default=None)
    args = ap.parse_args(argv)

    repository = HERE.parents[3]
    out = args.out.expanduser().resolve()
    if out == repository or repository in out.parents:
        ap.error("--out must stay outside the repository")
    source = args.source.expanduser().resolve()
    if not source.is_file():
        ap.error(f"source not found: {source}")
    src_hash = sha256_file(source)
    if src_hash != FROZEN_RELAY_SHA256:
        ap.error("source does not match the frozen phase2 relay.c; refusing to build or run")

    t_start = time.monotonic()
    out.mkdir(parents=True, exist_ok=True)
    res: dict = {"environment": environment(), "args": {k: str(v) for k, v in vars(args).items()},
                 "source": {"path": str(source), "sha256": src_hash, "frozen_sha256": FROZEN_RELAY_SHA256,
                            "matches_frozen": True, "bytes": source.stat().st_size},
                 "probe_source_sha256": sha256_file(PROBE_SRC),
                 "validation_source_hashes": {str(p.relative_to(HERE)): sha256_file(p) for p in sorted(HERE.rglob("*"))
                                              if p.is_file() and p.suffix in (".py", ".c", ".json", ".md")}}

    res["selftest"] = run_selftest()
    print(f"[selftest] ran={res['selftest']['ran']} ok={res['selftest']['ok']}")
    if not res["selftest"]["ok"]:
        print(res["selftest"]["output_tail"], file=sys.stderr)
        res["overall"] = "FAIL_SELFTEST"
        (out / "results.json").write_text(json.dumps(res, indent=1))
        return 1
    if args.mode == "selftest":
        res["overall"] = "SELFTEST_ONLY"
        res["total_seconds"] = round(time.monotonic() - t_start, 3)
        (out / "results.json").write_text(json.dumps(res, indent=1))
        print(f"[done] overall={res['overall']} -> {out / 'results.json'}")
        return 0

    cases = build_cases(args.tier)
    if len(cases) > CASE_BUDGET and not args.allow_large_corpus:
        ap.error(f"tier {args.tier} has {len(cases)} cases > budget {CASE_BUDGET}; pass --allow-large-corpus")
    chash = corpus_hash(cases)
    (out / "corpus_manifest.json").write_text(json.dumps({"tier": args.tier, "sha256": chash, "cases": corpus_manifest(cases)}, indent=0))
    cats: dict = {}
    for c in cases:
        cats[c.category] = cats.get(c.category, 0) + 1
    res["corpus"] = {"tier": args.tier, "cases": len(cases), "sha256": chash, "by_category": cats}
    print(f"[corpus] tier={args.tier} cases={len(cases)} sha256={chash[:16]}... {cats}")

    t0 = time.monotonic()
    n_events = 0
    for c in cases:
        e = expected_for(c)
        if e is not None:
            n_events += len(e["events"])
    res["reference"] = {"seconds": round(time.monotonic() - t0, 3), "valid_cases": sum(1 for c in cases if not c.expect_reject),
                        "reject_cases": sum(1 for c in cases if c.expect_reject), "total_events": n_events}
    hand_docs = {"hand/" + d["case"]["name"]: d for d in expand_hand_traces(json.loads(HAND_TRACES.read_text()))}

    build_dir = out / "build"
    dry = args.mode == "dry-run"
    t0 = time.monotonic()
    build = build_all(source, PROBE_SRC, build_dir, cc=args.cc, with_mutants=True, dry_run=dry)
    build["wall_seconds"] = round(time.monotonic() - t0, 3)
    (out / "build.json").write_text(json.dumps(build, indent=1))
    res["build"] = {k: v for k, v in build.items() if k != "log"}
    res["build"]["commands"] = [e["bounded"] for e in build["log"]]
    print(f"[build] {'planned' if dry else 'built'} {len(build['executables'])} executables with "
          f"{build['compiler_invocations']} compiler invocations in {build['wall_seconds']}s")
    if dry:
        res["overall"] = "DRY_RUN"
        res["total_seconds"] = round(time.monotonic() - t_start, 3)
        (out / "results.json").write_text(json.dumps(res, indent=1))
        print(f"[done] overall={res['overall']} -> {out / 'results.json'}")
        return 0

    harness = Harness(build, out, hand_docs)
    records = []
    t0 = time.monotonic()
    incomplete = False
    with (out / "per_case.jsonl").open("w") as fh:
        for i, c in enumerate(cases, 1):
            if time.monotonic() - t0 > args.budget_seconds:
                incomplete = True
                print(f"[run] budget of {args.budget_seconds}s exhausted after {i - 1} cases; stopping")
                break
            rec = harness.run_case(c)
            records.append(rec)
            fh.write(json.dumps(rec, separators=(",", ":")) + "\n")
            if i % 200 == 0 or i == len(cases):
                print(f"[run] {i}/{len(cases)} cases, {time.monotonic() - t0:.1f}s")
    res["run_seconds"] = round(time.monotonic() - t0, 3)
    res["cases_executed"] = len(records)
    res["executables"] = agg = aggregate(records, build)
    res["per_case_sha256"] = sha256_file(out / "per_case.jsonl")
    res["trace_files_written"] = harness.trace_files

    checks = {
        "selftest_ok": res["selftest"]["ok"],
        "source_matches_frozen": True,
        "symbol_checks_ok": all(c["ok"] for c in build["symbol_checks"]),
        "reference_traces_satisfy_invariants": not any(r.get("expected_invariant_problems") for r in records),
        "hand_traces_match_reference": not any(r.get("hand_vs_model") for r in records),
        "c_originals_match_reference_events": all(agg[n]["all_ok"] for n in harness.originals),
        "unshimmed_control_isolated": agg["unshimmed_control"]["all_ok"],
        "all_mutants_distinguished": all(agg[n]["killed"] for n in harness.mutants),
        "no_timeouts": all(a["timeouts"] == 0 for a in agg.values()),
        "corpus_complete": not incomplete,
    }
    res["checks"] = checks
    res["limits"] = {"exe_address_space_bytes": EXE_AS_BYTES, "exe_cpu_seconds": EXE_CPU_SECONDS,
                     "exe_wall_seconds": EXE_WALL_SECONDS, "exe_fsize_bytes": EXE_FSIZE_BYTES,
                     "probe_alarm_seconds": int(PROBE_TIMEOUT_SECONDS), "per_case_call_cap": "expected read_calls + write_calls",
                     **build["limits"], "parent_address_space_bytes": 2147483648, "parent_cpu_seconds": 900,
                     "budget_seconds": args.budget_seconds}
    res["overall"] = ("INCOMPLETE" if incomplete else "PASS") if all(v for k, v in checks.items() if k != "corpus_complete") else "FAIL"
    res["total_seconds"] = round(time.monotonic() - t_start, 3)
    (out / "results.json").write_text(json.dumps(res, indent=1))
    (out / "summary.md").write_text(render_summary(res))
    if args.copy_results_to:
        args.copy_results_to.mkdir(parents=True, exist_ok=True)
        for f in ("results.json", "summary.md", "per_case.jsonl", "build.json", "corpus_manifest.json"):
            shutil.copyfile(out / f, args.copy_results_to / f)
    print(f"[done] overall={res['overall']} in {res['total_seconds']}s -> {out / 'results.json'}")
    return 0 if res["overall"] == "PASS" else 1


if __name__ == "__main__":
    import resource
    resource.setrlimit(resource.RLIMIT_AS, (2147483648, 2147483648))
    resource.setrlimit(resource.RLIMIT_CPU, (900, 900))
    resource.setrlimit(resource.RLIMIT_FSIZE, (268435456, 268435456))
    sys.exit(main())
