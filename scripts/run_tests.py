#!/usr/bin/env python3
"""Run a round's bash test suite against either the GNU oracle in the
trixie container or the LLM-generated Rust impl. Logs per-test results
as JSONL.

The pre-2026-05-07 driver also exposed `--target real`, which routed to
whatever `<util>` the macOS host had on PATH (BSD `cp` in practice). That
was removed once the GNU oracle in trixie was wired up: the host BSD
binary is not the experiment's behavioral truth source, and keeping it
as an option invited oracle-confusion bugs of the kind documented in
`runs/cp/legacy_pre_session/_README.md`. See `decisions.md` § 4.4 for
the removal note.

Usage:
    # Linux/GNU oracle inside the trixie container (the canonical oracle):
    python scripts/run_tests.py --util cp --session <sid> --round 1 --target real-gnu

    # LLM-generated Rust impl, host-side (fast iteration on macOS):
    python scripts/run_tests.py --util cp --session <sid> --round 1 --target rust

    # LLM-generated Rust impl built and run inside trixie:
    python scripts/run_tests.py --util cp --session <sid> --round 1 --target rust --in-docker

# Scoring with `expected_to_fail`

Each test in the round's `_manifest.json` carries `expected_to_fail` (bool).
A test is `correct` when:

    expected_to_fail == false:  test body itself exits 0 (test asserts the
                                positive post-state and passes)
    expected_to_fail == true:   test body itself exits 0 (test verified the
                                utility errored as documented)

In both cases the test body wraps the utility call to interpret a nonzero
utility exit appropriately. The driver writes each entry to the manifest;
this script joins back on `filename`.

The JSONL row records both `expected_to_fail` and `correct` for downstream
analysis (observations.md breakdown by category).
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--util", required=True)
    ap.add_argument("--session", required=True)
    ap.add_argument("--round", type=int, required=True)
    ap.add_argument(
        "--target",
        required=True,
        choices=["real-gnu", "rust"],
        help=(
            "real-gnu = GNU userland inside the trixie container (the canonical oracle). "
            "rust    = LLM-generated Rust impl (host or container, see --in-docker)."
        ),
    )
    ap.add_argument(
        "--in-docker",
        action="store_true",
        help="Run --target rust inside the trixie container instead of host.",
    )
    ap.add_argument("--timeout", type=float, default=30.0)
    return ap.parse_args()


def round_dir_for(repo: Path, util: str, session: str, round_n: int) -> Path:
    return repo / "runs" / util / session / f"round_{round_n:02d}"


def load_manifest(round_dir: Path) -> dict[str, dict]:
    """Map filename -> manifest entry. Empty dict if manifest is missing or
    the entry doesn't carry `expected_to_fail` (legacy schema)."""
    path = round_dir / "tests" / "_manifest.json"
    if not path.is_file():
        return {}
    try:
        rows = json.loads(path.read_text())
    except json.JSONDecodeError:
        return {}
    return {r["filename"]: r for r in rows if isinstance(r, dict) and "filename" in r}


# ----------------------------- host execution path ---------------------------


def resolve_target_host(util: str, round_dir: Path, target: str) -> str:
    if target == "rust":
        impl_dir = round_dir / "impl"
        if not (impl_dir / "Cargo.toml").exists():
            print(f"no rust impl at {impl_dir}", file=sys.stderr)
            sys.exit(2)
        print(f"building rust impl at {impl_dir}", file=sys.stderr)
        rc = subprocess.run(
            ["cargo", "build", "--release", "--quiet"],
            cwd=impl_dir,
        ).returncode
        if rc != 0:
            print(f"cargo build failed (rc={rc})", file=sys.stderr)
            # Persist the build error so the next round's driver can include
            # it in the iteration feedback. We re-run capturing stderr.
            err = subprocess.run(
                ["cargo", "build", "--release"],
                cwd=impl_dir,
                capture_output=True,
                text=True,
            )
            log_dir = round_dir / "impl" / "_logs"
            log_dir.mkdir(parents=True, exist_ok=True)
            (log_dir / "build_error.txt").write_text(err.stderr)
            sys.exit(2)
        return str(impl_dir / "target" / "release" / "util")

    raise ValueError(f"unknown host target {target}")


def run_one_host(test_path: Path, util_bin: str, timeout: float) -> dict:
    t0 = time.time()
    try:
        proc = subprocess.run(
            ["bash", str(test_path)],
            env={**os.environ, "UTIL": util_bin},
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return {
            "name": test_path.name,
            "status": "pass" if proc.returncode == 0 else "fail",
            "rc": proc.returncode,
            "stdout": proc.stdout,
            "stderr": proc.stderr,
            "duration_s": time.time() - t0,
        }
    except subprocess.TimeoutExpired:
        return {
            "name": test_path.name,
            "status": "timeout",
            "rc": None,
            "stdout": "",
            "stderr": "",
            "duration_s": time.time() - t0,
        }


# ----------------------------- docker batch path ----------------------------


def docker_run_path(repo: Path) -> Path:
    return repo / "docker" / "run.sh"


def ensure_docker_image() -> None:
    """Soft-verify the trixie image exists; build it if missing."""
    proc = subprocess.run(
        ["docker", "image", "inspect", "formal-verification:trixie"],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        print(
            "formal-verification:trixie image not found; run docker/build.sh first",
            file=sys.stderr,
        )
        sys.exit(2)


def build_rust_in_docker(repo: Path, util: str, session: str, round_n: int) -> str:
    """Cargo-build the impl inside the trixie container and return the
    resulting binary path *as seen from inside the container* (mounted at
    /work)."""
    rel = f"runs/{util}/{session}/round_{round_n:02d}/impl"
    print(f"building rust impl at {rel} inside trixie", file=sys.stderr)
    proc = subprocess.run(
        [str(docker_run_path(repo)), "bash", "-lc",
         f"cd /work/{rel} && cargo build --release 2>&1"],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        log_dir = repo / rel / "_logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        (log_dir / "build_error.txt").write_text(proc.stdout + proc.stderr)
        print(f"cargo build (in docker) failed (rc={proc.returncode})", file=sys.stderr)
        sys.exit(2)
    return f"/work/{rel}/target/release/util"


def run_batch_in_docker(
    repo: Path,
    util: str,
    session: str,
    round_n: int,
    target: str,
    util_bin_inside: str,
    test_names: list[str],
    timeout: float,
) -> list[dict]:
    """Run all tests in a single container invocation. Returns a list of
    per-test result dicts in the same order as `test_names`.

    Why batch? Container startup is ~0.5-2s on macOS Docker Desktop. With 30
    tests that's 15-60s of pure overhead per run. The tests themselves take
    ~10ms each. Batching collapses container startup to one invocation.

    Protocol: we feed the container a small bash script that loops over the
    test names, runs each, and emits one `RESULT:<json>` line per test on
    stdout. Stderr is captured per-test via a temp file inside the container.
    """
    rel_round = f"runs/{util}/{session}/round_{round_n:02d}"
    # Build a here-doc style script. Each test is invoked with the right
    # UTIL set; we time it, capture stdout+stderr separately, write a JSON
    # row per test. The protocol marker `__RESULT__` lets us slice the
    # combined stdout back into rows.
    script = f"""
set +e
export UTIL={util_bin_inside}
ROUND_DIR=/work/{rel_round}
TIMEOUT={int(timeout)}
for fn in {' '.join(test_names)}; do
    t0=$(date +%s.%N)
    out_f=$(mktemp)
    err_f=$(mktemp)
    timeout $TIMEOUT bash "$ROUND_DIR/tests/$fn" >"$out_f" 2>"$err_f"
    rc=$?
    t1=$(date +%s.%N)
    dur=$(awk "BEGIN{{printf \\"%.4f\\", $t1 - $t0}}")
    python3 -c "
import json, sys
out = open('$out_f').read()
err = open('$err_f').read()
rc = $rc
status = 'pass' if rc == 0 else ('timeout' if rc == 124 else 'fail')
sys.stdout.write('__RESULT__' + json.dumps({{
    'name': '$fn',
    'status': status,
    'rc': None if status == 'timeout' else rc,
    'stdout': out,
    'stderr': err,
    'duration_s': float('$dur'),
}}) + '\\n')
"
    rm -f "$out_f" "$err_f"
done
"""
    cmd = [str(docker_run_path(repo)), "bash", "-lc", script]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    rows: list[dict] = []
    for line in proc.stdout.splitlines():
        if line.startswith("__RESULT__"):
            try:
                rows.append(json.loads(line[len("__RESULT__"):]))
            except json.JSONDecodeError:
                pass
    if not rows:
        sys.stderr.write(
            "no test results parsed from container; raw stdout follows:\n"
            + proc.stdout
            + "\nraw stderr:\n"
            + proc.stderr
            + "\n"
        )
        sys.exit(2)
    # Re-order rows to match test_names so the output ordering is stable
    # across runs even if the container shuffles them.
    by_name = {r["name"]: r for r in rows}
    return [by_name[n] for n in test_names if n in by_name]


# ----------------------------- scoring ---------------------------------------


def score(row: dict, expected_to_fail: bool | None) -> bool:
    """Return True if the row counts as 'correct' under the expected_to_fail
    semantic. `expected_to_fail=None` falls back to the legacy semantic
    (status == 'pass'), which is what the legacy_pre_session run uses.
    """
    if expected_to_fail is None:
        return row.get("status") == "pass"
    # Test body exits 0 iff it confirmed the documented behavior (whether
    # that behavior was a positive post-state or a documented error). The
    # interpretation is baked into the test body per prompts/tests.md.
    return row.get("status") == "pass"


# ----------------------------- main ------------------------------------------


def main() -> None:
    args = parse_args()
    repo = Path(__file__).resolve().parent.parent
    round_dir = round_dir_for(repo, args.util, args.session, args.round)
    tests_dir = round_dir / "tests"
    if not tests_dir.exists():
        print(f"no tests at {tests_dir}", file=sys.stderr)
        sys.exit(2)

    manifest = load_manifest(round_dir)
    tests = sorted(tests_dir.glob("*.sh"))
    if not tests:
        print(f"no .sh tests in {tests_dir}", file=sys.stderr)
        sys.exit(2)

    # Decide execution path.
    in_docker = args.in_docker or args.target == "real-gnu"

    rows: list[dict]
    if in_docker:
        ensure_docker_image()
        if args.target == "real-gnu":
            util_bin_inside = f"/usr/bin/{args.util}"
        elif args.target == "rust":
            util_bin_inside = build_rust_in_docker(
                repo, args.util, args.session, args.round
            )
        else:
            raise ValueError(f"unknown in-docker target {args.target}")
        print(f"target binary (in docker): {util_bin_inside}", file=sys.stderr)
        test_names = [t.name for t in tests]
        rows = run_batch_in_docker(
            repo, args.util, args.session, args.round, args.target,
            util_bin_inside, test_names, args.timeout,
        )
    else:
        util_bin = resolve_target_host(args.util, round_dir, args.target)
        print(f"target binary: {util_bin}", file=sys.stderr)
        rows = [run_one_host(t, util_bin, args.timeout) for t in tests]

    counts: dict[str, int] = {"pass": 0, "fail": 0, "timeout": 0}
    correct_count = 0
    incorrect_count = 0
    results_path = round_dir / f"results_{args.target}.jsonl"
    with results_path.open("w") as out:
        for r in rows:
            mentry = manifest.get(r["name"], {})
            etf = mentry.get("expected_to_fail")
            r_with = {
                **r,
                "expected_to_fail": etf,
                "exercises": mentry.get("exercises"),
                "expected": mentry.get("expected"),
            }
            correct = score(r_with, etf)
            r_with["correct"] = correct
            counts[r["status"]] = counts.get(r["status"], 0) + 1
            if correct:
                correct_count += 1
            else:
                incorrect_count += 1
            out.write(json.dumps(r_with) + "\n")
            mark = {"pass": ".", "fail": "F", "timeout": "T"}[r["status"]]
            sys.stderr.write(mark)
            sys.stderr.flush()
    sys.stderr.write("\n")

    total = sum(counts.values())
    print(
        f"{args.target}: correct={correct_count}/{total}  "
        f"incorrect={incorrect_count}  "
        f"raw_pass={counts['pass']}  raw_fail={counts['fail']}  "
        f"timeout={counts['timeout']}"
    )
    print(f"results: {results_path}")


if __name__ == "__main__":
    main()
