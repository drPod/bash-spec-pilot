#!/usr/bin/env python3
"""Compare RawWc, C, and GNU wc against raw newline counts: exact stdout, empty stderr, exit 0.

The optional old line shim is measured separately, not graded. Outputs stay under --out."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import random
import re
import resource
import shutil
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEFAULT_MODEL = Path.home() / ".cache/bash-spec-pilot/libc-experiments/bytes/.lake/build/bin/rawwc"
DEFAULT_OLD_MODEL = HERE / "pipeline-model-snapshot"
RUN_TIMEOUT_S = 120


def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def sha256_file(p: Path) -> str:
    return sha256_bytes(p.read_bytes())


def version_of(cmd: list[str]) -> str:
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        out = (p.stdout or p.stderr).strip().splitlines()
        return out[0] if out else ""
    except Exception as e:  # noqa: BLE001
        return f"<unavailable: {e}>"


def find_gnu_wc(override: str | None) -> tuple[str, str, bool]:
    """Return (path, version line, is_gnu)."""
    candidates = [override] if override else ["gwc", "wc"]
    for c in candidates:
        path = shutil.which(c) if c else None
        if not path:
            continue
        ver = version_of([path, "--version"])
        is_gnu = "GNU coreutils" in ver
        if is_gnu or override:
            return path, ver, is_gnu
    path = shutil.which("wc") or "wc"
    return path, version_of([path, "--version"]), False


def timed_run(cmd: list[str], **kw) -> tuple[subprocess.CompletedProcess, float, int | None]:
    """Return process, wall seconds, and peak RSS in KiB.
    
    Without /usr/bin/time, RSS is the children-wide high-water mark, not a per-child measurement."""
    t = shutil.which("time", path="/usr/bin") or ("/usr/bin/time" if os.path.exists("/usr/bin/time") else None)
    if t:
        if sys.platform == "darwin":
            wrapped = [t, "-l"] + cmd
        else:
            wrapped = [t, "-f", "CBR_TIME %e %M"] + cmd
        t0 = time.monotonic()
        p = subprocess.run(wrapped, capture_output=True, timeout=RUN_TIMEOUT_S, **kw)
        wall = time.monotonic() - t0
        err = p.stderr
        rss_kib = None
        if sys.platform == "darwin":
            m = re.search(rb"(\d+)\s+maximum resident set size", err)
            if m:
                rss_kib = int(m.group(1)) // 1024
            # drop the BSD time report lines ("  0.01 real ...", "  123456  maximum resident ...")
            lines = [ln for ln in err.split(b"\n") if not re.match(rb"^\s*(\d+\.\d+ real|\d+\s+\w)", ln)]
            err = b"\n".join(lines)
        else:
            m = re.search(rb"CBR_TIME ([0-9.]+) (\d+)\n?$", err)
            if m:
                wall = float(m.group(1))
                rss_kib = int(m.group(2))
                err = err[: m.start()]
        p.stderr = err
        return p, wall, rss_kib
    before = resource.getrusage(resource.RUSAGE_CHILDREN)
    t0 = time.monotonic()
    p = subprocess.run(cmd, capture_output=True, timeout=RUN_TIMEOUT_S, **kw)
    wall = time.monotonic() - t0
    after = resource.getrusage(resource.RUSAGE_CHILDREN)
    rss = after.ru_maxrss
    rss_kib = rss // 1024 if sys.platform == "darwin" else rss
    return p, wall, rss_kib


def directed_cases() -> list[tuple[str, bytes]]:
    all256 = bytes(range(256))
    cases: list[tuple[str, bytes]] = [
        ("empty", b""),
        ("single_nl", b"\n"),
        ("single_byte_no_nl", b"a"),
        ("one_line_terminated", b"a\n"),
        ("two_lines_missing_final_nl", b"a\nb"),
        ("two_lines_terminated", b"a\nb\n"),
        ("blank_lines_3", b"\n\n\n"),
        ("blank_lines_100", b"\n" * 100),
        ("nul_only", b"\x00"),
        ("nul_then_nl", b"\x00\n"),
        ("nul_inside_lines", b"a\x00b\nc\x00\n\x00"),
        ("nul_run_1k", b"\x00" * 1024),
        ("all256", all256),
        ("all256_reversed", all256[::-1]),
        ("all256_plus_nl", all256 + b"\n"),
        ("all256_x4", all256 * 4),
        ("bad_utf8_ff_nl", b"\xff\n"),
        ("bad_utf8_c3_28_nl", b"\xc3\x28\n"),
        ("bad_utf8_truncated_e2_82", b"\xe2\x82"),
        ("bad_utf8_truncated_f0_9f_98_nl", b"\xf0\x9f\x98\n"),
        ("bad_utf8_surrogate_ed_a0_80_nl", b"\xed\xa0\x80\n"),
        ("bad_utf8_overlong_c0_af_nl", b"\xc0\xaf\n"),
        ("bad_utf8_lone_continuation_80", b"\x80\n\x80"),
        ("bad_utf8_f5_ff_between_nls", b"\n\xf5\xf8\xfe\xff\n"),
        ("valid_utf8_multibyte", "héllo wörld ✓ 😀\n日本語\n".encode("utf-8")),
        ("valid_utf8_no_final_nl", "ünïcödé".encode("utf-8")),
        ("cr_only", b"\r"),
        ("crlf_only", b"\r\n"),
        ("crlf_two_lines", b"a\r\nb\r\n"),
        ("crlf_missing_final", b"a\r\nb\r"),
        ("nl_cr", b"\n\r"),
        ("cr_cr_nl", b"\r\r\n"),
        ("mixed_endings", b"a\nb\r\nc\rd\n\r\n"),
        ("tabs_spaces_ff_vt", b" \t\x0b\x0c\n \t\x0b\x0c"),
        ("long_line_1MiB_no_nl", b"a" * (1 << 20)),
        ("long_newlines_1MiB", b"\n" * (1 << 20)),
        ("long_seq_1_to_200000", "".join(f"{i}\n" for i in range(1, 200001)).encode()),
    ]
    rng = random.Random(0xC0FFEE)  # fixed, independent of --seed: this case is "directed"
    cases.append(("long_random_1MiB", rng.randbytes(1 << 20)))
    return cases


def exhaustive_cases() -> list[tuple[str, bytes]]:
    cases = []
    alpha = [b"\n", b"a"]
    for n in range(0, 8):
        for i in range(2 ** n):
            s = b"".join(alpha[(i >> k) & 1] for k in range(n))
            cases.append((f"exh_nl_a_len{n}_{i}", s))
    alpha4 = [b"\n", b"\r", b"\x00", b"\xff"]
    for n in range(0, 5):
        for i in range(4 ** n):
            s = b"".join(alpha4[(i >> (2 * k)) & 3] for k in range(n))
            cases.append((f"exh_nl_cr_nul_ff_len{n}_{i}", s))
    return cases


def random_cases(seed: int, n: int) -> list[tuple[str, bytes]]:
    rng = random.Random(seed)
    cases = []
    for i in range(n):
        kind = rng.random()
        if kind < 0.6:
            length = rng.randint(0, 256)
        elif kind < 0.9:
            length = rng.randint(257, 4096)
        else:
            length = rng.randint(4097, 65536)
        mode = rng.random()
        if mode < 0.5:
            data = rng.randbytes(length)
        elif mode < 0.8:
            p = rng.choice([0.05, 0.2, 0.5])
            data = bytes(10 if rng.random() < p else rng.randrange(256) for _ in range(length))
        else:
            pieces = []
            for _ in range(rng.randint(0, 20)):
                ln = rng.randint(0, 40)
                pool = rng.choice([b"abc xyz", b"\x00\xff\xfe\x80", b"\r\t ", bytes(range(256))])
                pieces.append(bytes(pool[rng.randrange(len(pool))] for _ in range(ln)))
            data = b"\n".join(pieces) + (b"\n" if rng.random() < 0.5 else b"")
        cases.append((f"rand_{i}", data))
    return cases


def build_corpus(seed: int, n_random: int, total_target: int | None):
    directed = directed_cases()
    exhaustive = exhaustive_cases()
    if total_target is not None:
        n_random = max(0, total_target - len(directed) - len(exhaustive))
    rnd = random_cases(seed, n_random)
    corpus = [(n, d, "directed") for n, d in directed] + \
             [(n, d, "exhaustive") for n, d in exhaustive] + \
             [(n, d, "random") for n, d in rnd]
    h = hashlib.sha256()
    for name, data, _ in corpus:
        h.update(len(name).to_bytes(4, "big") + name.encode() + len(data).to_bytes(8, "big") + data)
    return corpus, h.hexdigest()


def old_shim_prediction(data: bytes) -> dict:
    """The line shim rejects invalid UTF-8 and loses final-newline presence."""
    try:
        s = data.decode("utf-8")  # Python's strict decoder == Lean String.fromUTF8? validity
    except UnicodeDecodeError:
        return {"kind": "invalid_utf8", "stdout": b"", "status": 1}
    parts = s.split("\n")
    if parts and parts[-1] == "":
        parts = parts[:-1]
    return {"kind": "lines", "stdout": f"{len(parts)}\n".encode(), "status": 0}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--model", default=str(DEFAULT_MODEL),
                    help="RawWc executable (Lean, built from byte-experiment/Main.lean). Default: %(default)s")
    ap.add_argument("--c-source", default=str(HERE / "wc.c"), help="minimal C wc -l source. Default: %(default)s")
    ap.add_argument("--out", default=str(Path.home() / ".cache/bash-spec-pilot/raw-wc-validation"), help="directory for binary, logs, results.json. Default: %(default)s")
    ap.add_argument("--results", default=None, help="results.json path (default: <out>/results.json)")
    ap.add_argument("--wc", default=None, help="GNU wc binary (default: gwc if present, else wc)")
    ap.add_argument("--cc", default=os.environ.get("CC", "cc"), help="C compiler. Default: %(default)s")
    ap.add_argument("--old-model", default=str(DEFAULT_OLD_MODEL) if DEFAULT_OLD_MODEL.exists() else None,
                    help="old pipeline line-shim executable (optional). Default: %(default)s")
    ap.add_argument("--seed", type=int, default=20260907, help="seed for the random cases. Default: %(default)s")
    ap.add_argument("--total", type=int, default=1000, help="target total case count (random cases fill up). Default: %(default)s")
    ap.add_argument("--extra-hash", nargs="*", default=[], help="extra files to sha256 into the metadata")
    args = ap.parse_args()

    out = Path(args.out).resolve()
    repo = HERE.parents[2]
    if out == repo or repo in out.parents:
        ap.error("--out must be outside the source repository (local build/cache only)")
    out.mkdir(parents=True, exist_ok=True)
    results_path = Path(args.results) if args.results else out / "results.json"
    model = Path(args.model).resolve()
    c_src = Path(args.c_source).resolve()
    if not model.is_file() or not os.access(model, os.X_OK):
        print(f"error: model executable not found/executable: {model}", file=sys.stderr)
        return 2
    if not c_src.is_file():
        print(f"error: C source not found: {c_src}", file=sys.stderr)
        return 2

    log = open(out / "validate.log", "w")

    def say(msg: str):
        print(msg)
        log.write(msg + "\n")
        log.flush()

    wc_path, wc_ver, wc_is_gnu = find_gnu_wc(args.wc)
    cc_path = shutil.which(args.cc) or args.cc
    meta = {
        "script": str(Path(__file__).resolve()),
        "script_sha256": sha256_file(Path(__file__).resolve()),
        "timestamp_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "platform": platform.platform(),
        "python": sys.version.split()[0],
        "model": str(model), "model_sha256": sha256_file(model), "model_size": model.stat().st_size,
        "c_source": str(c_src), "c_source_sha256": sha256_file(c_src),
        "cc": cc_path, "cc_version": version_of([cc_path, "--version"]),
        "wc": wc_path, "wc_version": wc_ver, "wc_is_gnu": wc_is_gnu,
        "time_binary": "/usr/bin/time" if os.path.exists("/usr/bin/time") else None,
        "time_version": version_of(["/usr/bin/time", "--version"]) if os.path.exists("/usr/bin/time") else None,
        "old_model": None,
        "extra_hashes": {p: sha256_file(Path(p)) for p in args.extra_hash if Path(p).is_file()},
    }
    old_model = Path(args.old_model).resolve() if args.old_model else None
    if old_model and old_model.is_file() and os.access(old_model, os.X_OK):
        meta["old_model"] = str(old_model)
        meta["old_model_sha256"] = sha256_file(old_model)
    else:
        old_model = None
    if not wc_is_gnu:
        say(f"WARNING: {wc_path} does not report GNU coreutils ({wc_ver!r}); BSD wc pads its output "
            "and will show as a raw-byte mismatch. Install coreutils (gwc) or pass --wc.")

    c_bin = out / "wc_c"
    if c_bin.exists():
        c_bin.unlink()
    cc_cmd = [cc_path, "-std=c11", "-O2", "-Wall", "-Wextra", "-o", str(c_bin), str(c_src)]
    say("compiling: " + " ".join(cc_cmd))
    p, wall, rss = timed_run(cc_cmd)
    (out / "cc.stderr").write_bytes(p.stderr)
    compile_info = {"cmd": cc_cmd, "returncode": p.returncode, "elapsed_s": round(wall, 3),
                    "peak_rss_kib": rss, "stderr": p.stderr.decode(errors="replace")}
    if p.returncode != 0:
        say(f"C compile FAILED (rc={p.returncode}):\n{p.stderr.decode(errors='replace')}")
        json.dump({"meta": meta, "compile": compile_info, "fatal": "compile failed"}, open(results_path, "w"), indent=1)
        return 1
    compile_info["binary_sha256"] = sha256_file(c_bin)
    say(f"compiled OK in {wall:.3f}s, peak RSS {rss} KiB, warnings: {len(p.stderr.strip()) > 0}")

    corpus, corpus_hash = build_corpus(args.seed, 0, args.total)
    counts = {}
    for _, _, cat in corpus:
        counts[cat] = counts.get(cat, 0) + 1
    say(f"corpus: {len(corpus)} cases {counts}, seed={args.seed}, sha256={corpus_hash}")

    subjects = {
        "rawwc": [str(model)],
        "c_wc": [str(c_bin)],
        "gnu_wc": [wc_path, "-l"],
    }
    if old_model:
        subjects["old_line_shim"] = [str(old_model)]

    totals = {s: {"pass": 0, "fail": 0, "elapsed_s": 0.0} for s in subjects}
    mismatches: list[dict] = []
    old_shim = {"agree_with_byte_count": 0, "collision_plus_one": 0, "invalid_utf8_exception": 0,
                "prediction_mismatch": 0, "other": 0, "examples": []}
    per_case = []
    long_stats = {}

    for idx, (name, data, cat) in enumerate(corpus):
        expected = f"{data.count(10)}\n".encode()
        rec = {"name": name, "cat": cat, "len": len(data), "sha256_16": sha256_bytes(data)[:16],
               "expected_count": data.count(10), "results": {}}
        is_long = name.startswith("long_")
        for subj, cmd in subjects.items():
            if is_long:
                p, wall, rss = timed_run(cmd, input=data)
                long_stats.setdefault(name, {})[subj] = {"elapsed_s": round(wall, 3), "peak_rss_kib": rss}
            else:
                t0 = time.monotonic()
                p = subprocess.run(cmd, input=data, capture_output=True, timeout=RUN_TIMEOUT_S)
                wall = time.monotonic() - t0
            totals[subj]["elapsed_s"] += wall
            ok = (p.stdout == expected and p.stderr == b"" and p.returncode == 0)
            r = {"ok": ok}
            if not ok:
                r.update({"stdout": p.stdout[:200].decode("latin-1"), "stderr": p.stderr[:300].decode("latin-1"),
                          "status": p.returncode})
            rec["results"][subj] = r
            if subj == "old_line_shim":
                pred = old_shim_prediction(data)
                matches_pred = (p.stdout == pred["stdout"] and p.returncode == pred["status"]
                                and ((p.stderr == b"") if pred["kind"] == "lines" else (b"non UTF-8" in p.stderr)))
                if not matches_pred:
                    old_shim["prediction_mismatch"] += 1
                    r["prediction"] = {"kind": pred["kind"], "stdout": pred["stdout"].decode("latin-1"), "status": pred["status"]}
                if ok:
                    old_shim["agree_with_byte_count"] += 1
                elif pred["kind"] == "invalid_utf8" and p.returncode != 0:
                    old_shim["invalid_utf8_exception"] += 1
                elif p.stdout == f"{data.count(10) + 1}\n".encode():
                    old_shim["collision_plus_one"] += 1
                    if len(old_shim["examples"]) < 6:
                        old_shim["examples"].append({"name": name, "input": data[:40].decode("latin-1"),
                                                     "byte_count": data.count(10), "old_shim_stdout": p.stdout.decode("latin-1")})
                else:
                    old_shim["other"] += 1
                continue  # old shim is documented, not a pass/fail subject
            totals[subj]["pass" if ok else "fail"] += 1
            if not ok:
                mismatches.append({"case": name, "subject": subj, "len": len(data), "expected": expected.decode(),
                                   "stdout": p.stdout[:200].decode("latin-1"), "stderr": p.stderr[:300].decode("latin-1"),
                                   "status": p.returncode, "input_head_hex": data[:64].hex()})
                say(f"MISMATCH {subj} on {name}: expected {expected!r} got stdout={p.stdout[:60]!r} "
                    f"stderr={p.stderr[:80]!r} rc={p.returncode}")
        rec["all_three_identical"] = all(rec["results"][s]["ok"] for s in ("rawwc", "c_wc", "gnu_wc"))
        per_case.append(rec)
        if (idx + 1) % 100 == 0:
            say(f"  {idx + 1}/{len(corpus)} done")

    for s in totals:
        totals[s]["elapsed_s"] = round(totals[s]["elapsed_s"], 3)
    verdict = "PASS" if all(t["fail"] == 0 for t in totals.values()) else "FAIL"
    summary = {
        "verdict": verdict,
        "cases": len(corpus), "by_category": counts, "seed": args.seed, "corpus_sha256": corpus_hash,
        "subjects": totals, "mismatch_count": len(mismatches),
        "old_line_shim": old_shim if old_model else None,
        "observation_contract": ("run subject with stdin=case bytes (GNU wc with argv ['-l']); PASS iff raw stdout == "
                                 "str(bytes.count(10)).encode()+b'\\n' and stderr == b'' and exit status == 0"),
    }
    results = {"meta": meta, "compile": compile_info, "summary": summary, "long_inputs": long_stats,
               "mismatches": mismatches, "cases": per_case}
    json.dump(results, open(results_path, "w"), indent=1)
    say(f"verdict: {verdict}; per-subject: " + ", ".join(f"{s}={t['pass']}/{t['pass'] + t['fail']} in {t['elapsed_s']}s"
                                                          for s, t in totals.items()))
    if old_model:
        say(f"old line shim: {old_shim}")
    say(f"results: {results_path}")
    return 0 if verdict == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
