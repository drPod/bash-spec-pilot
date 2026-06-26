#!/usr/bin/env bash
# COLD adversarial boundary: -maxdepth 0 -> only the starting-points themselves.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/child"
: > "$tmpdir/child/leaf"

# Documented: "Using -maxdepth 0 means only apply the tests and actions to
# the starting-points themselves."
got="$("$UTIL" "$tmpdir" -maxdepth 0 | LC_ALL=C sort)"
want="$tmpdir"

if [[ "$got" != "$want" ]]; then
  echo "maxdepth 0 mismatch: got [$got] want [$want]" >&2
  exit 1
fi
