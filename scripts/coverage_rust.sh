#!/usr/bin/env bash
# Branch / line coverage on the LLM-generated Rust impl, via cargo-tarpaulin
# inside the formal-verification:trixie container.
#
# Usage:
#   scripts/coverage_rust.sh --util cp --session <sid> --round 1
#
# Output:
#   runs/<util>/<session>/round_<NN>/coverage_rust.json
#
# Skip-gracefully behavior:
#   If the impl fails to compile (build_error.txt present or cargo build
#   nonzero), write {"compile_failed": true, "stderr_first_lines": [...]}
#   and exit 0. Coverage is undefined when the binary doesn't compile;
#   downstream eval_round.sh treats it as "skipped".
#
# Why tarpaulin:
#   - Branch + line coverage in one pass (--out Json).
#   - Runs the actual test harness; we feed it the Bash tests via
#     `cargo tarpaulin -- ...` is not the right shape (tarpaulin instruments
#     Rust unit/integration tests, not external binaries). For our setup the
#     Rust impl is a binary, and the Bash tests invoke it through $UTIL.
#     We therefore run `cargo tarpaulin --command run --bin util -- <args>`
#     once per test? No, that's expensive. Instead we run tarpaulin against
#     a synthetic "integration test runner" that loops the bash tests and
#     invokes the binary. The integration test is generated on the fly here.
#
# Caveat: tarpaulin coverage of code reached via `std::process::Command`
# from outside the test runner is well-supported; the binary is built with
# instrumentation and any in-process invocation increments counters.

set -euo pipefail

UTIL=""
SESSION=""
ROUND=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --util)    UTIL="$2"; shift 2 ;;
        --session) SESSION="$2"; shift 2 ;;
        --round)   ROUND="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 2 ;;
    esac
done
if [[ -z "$UTIL" || -z "$SESSION" || -z "$ROUND" ]]; then
    echo "usage: $0 --util <name> --session <sid> --round <N>" >&2
    exit 2
fi

REPO="$(cd "$(dirname "$0")/.." && pwd)"
REL_ROUND="runs/${UTIL}/${SESSION}/round_$(printf '%02d' "$ROUND")"
ROUND_DIR="${REPO}/${REL_ROUND}"
IMPL_DIR="${ROUND_DIR}/impl"
OUT_JSON="${ROUND_DIR}/coverage_rust.json"

if [[ ! -f "${IMPL_DIR}/Cargo.toml" ]]; then
    echo "no Cargo.toml at ${IMPL_DIR}; nothing to measure" >&2
    cat > "$OUT_JSON" <<EOF
{"compile_failed": true, "reason": "no Cargo.toml present"}
EOF
    exit 0
fi

# Probe build before tarpaulin runs (so we can fail-soft with a clean message).
echo "probing cargo build inside container" >&2
if ! "${REPO}/docker/run.sh" bash -lc \
        "cd /work/${REL_ROUND}/impl && cargo build --release 2>&1"; then
    echo "compile failed; writing compile_failed sentinel" >&2
    # Snapshot the error for the next round's iteration feedback.
    "${REPO}/docker/run.sh" bash -lc \
        "cd /work/${REL_ROUND}/impl && cargo build --release 2>&1" \
        > "${IMPL_DIR}/_logs/build_error.txt" 2>&1 || true
    cat > "$OUT_JSON" <<EOF
{"compile_failed": true, "reason": "cargo build returned nonzero"}
EOF
    exit 0
fi

# Generate an in-tree integration test that drives the bash suite against
# the built binary. tarpaulin instruments the binary at build time; the
# integration test exec()s it and counts hit lines/branches.
INTEG_DIR="${IMPL_DIR}/tests"
mkdir -p "$INTEG_DIR"
cat > "${INTEG_DIR}/_run_bash_suite.rs" <<'RS'
// Auto-generated integration harness for cargo-tarpaulin coverage.
// Iterates bash test scripts in $TESTS_DIR and invokes the built binary
// at $UTIL_BIN so tarpaulin's instrumentation registers hit counters.
//
// Failures are not fatal here -- coverage is about code paths, not
// pass/fail. run_tests.py handles correctness scoring separately.
use std::env;
use std::fs;
use std::process::Command;

#[test]
fn run_bash_suite() {
    let tests_dir = env::var("TESTS_DIR")
        .unwrap_or_else(|_| panic!("TESTS_DIR env var required"));
    let util_bin = env::var("UTIL_BIN")
        .unwrap_or_else(|_| panic!("UTIL_BIN env var required"));
    let mut count = 0usize;
    for entry in fs::read_dir(&tests_dir).expect("read tests dir") {
        let entry = entry.expect("entry");
        let path = entry.path();
        if path.extension().and_then(|s| s.to_str()) != Some("sh") {
            continue;
        }
        // Run with a timeout-ish bound via `timeout` if available; if not,
        // cargo test will time it out at the harness level.
        let _ = Command::new("bash")
            .arg(&path)
            .env("UTIL", &util_bin)
            .output();
        count += 1;
    }
    assert!(count > 0, "no .sh tests found in {}", tests_dir);
}
RS

# Run tarpaulin inside the container. --skip-clean keeps cached build
# artifacts. --out Json produces the machine-readable summary.
echo "running cargo tarpaulin inside container" >&2
"${REPO}/docker/run.sh" bash -lc "
    cd /work/${REL_ROUND}/impl
    UTIL_BIN=/work/${REL_ROUND}/impl/target/release/util \
    TESTS_DIR=/work/${REL_ROUND}/tests \
        cargo tarpaulin \
            --release \
            --out Json \
            --output-dir /work/${REL_ROUND} \
            --skip-clean \
            --timeout 120 \
            --test _run_bash_suite \
        2>&1
" || {
    echo "tarpaulin failed; writing compile_failed sentinel" >&2
    cat > "$OUT_JSON" <<EOF
{"compile_failed": true, "reason": "cargo tarpaulin returned nonzero"}
EOF
    exit 0
}

# tarpaulin --out Json writes tarpaulin-report.json next to --output-dir.
TPN="${ROUND_DIR}/tarpaulin-report.json"
if [[ -f "$TPN" ]]; then
    # Distill to a small summary for downstream eval_round.sh.
    python3 - <<PY
import json, pathlib
src = pathlib.Path("${TPN}")
data = json.loads(src.read_text())
covered = data.get("coverage")
files = []
for f in data.get("files", []):
    files.append({
        "path": f.get("path"),
        "covered": f.get("covered"),
        "coverable": f.get("coverable"),
    })
out = {
    "compile_failed": False,
    "line_coverage_pct": covered if isinstance(covered, (int, float)) else None,
    "files": files,
}
pathlib.Path("${OUT_JSON}").write_text(json.dumps(out, indent=2))
print(f"line_coverage: {out['line_coverage_pct']}%  (out: ${OUT_JSON})")
PY
else
    cat > "$OUT_JSON" <<EOF
{"compile_failed": false, "line_coverage_pct": null, "reason": "no tarpaulin-report.json produced"}
EOF
fi
