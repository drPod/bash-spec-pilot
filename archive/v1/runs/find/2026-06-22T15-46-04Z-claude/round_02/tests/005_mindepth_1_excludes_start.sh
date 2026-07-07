#!/usr/bin/env bash
# COLD adversarial boundary: -mindepth 1 processes everything except the start.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/c"
: > "$tmpdir/c/f"

# Documented: "Using -mindepth 1 means process all files except the
# starting-points."
got="$("$UTIL" "$tmpdir" -mindepth 1 | LC_ALL=C sort)"
want="$(printf '%s\n%s\n' "$tmpdir/c" "$tmpdir/c/f" | LC_ALL=C sort)"

if [[ "$got" != "$want" ]]; then
  echo "mindepth 1 mismatch: got [$got] want [$want]" >&2
  exit 1
fi
