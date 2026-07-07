#!/usr/bin/env bash
# COLD adversarial boundary: -maxdepth 1 descends one level below start, not two.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/a/b"
: > "$tmpdir/a/x"      # depth 2 below start
: > "$tmpdir/a/b/y"   # depth 3 below start -> excluded

# Documented: "Descend at most levels (a non-negative integer) levels of
# directories below the starting-points."
# maxdepth 1: start (depth 0) + immediate children (depth 1). a/x is depth 2.
got="$("$UTIL" "$tmpdir" -maxdepth 1 | LC_ALL=C sort)"
want="$(printf '%s\n%s\n' "$tmpdir" "$tmpdir/a" | LC_ALL=C sort)"

if [[ "$got" != "$want" ]]; then
  echo "maxdepth 1 boundary mismatch: got [$got] want [$want]" >&2
  exit 1
fi
