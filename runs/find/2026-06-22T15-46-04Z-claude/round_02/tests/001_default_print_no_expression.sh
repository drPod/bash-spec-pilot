#!/usr/bin/env bash
# COLD adversarial: with no expression, -print is the default action.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/d"
: > "$tmpdir/d/a"

# No expression given -> documented default is -print.
got="$("$UTIL" "$tmpdir/d" | LC_ALL=C sort)"
want="$(printf '%s\n%s\n' "$tmpdir/d" "$tmpdir/d/a" | LC_ALL=C sort)"

if [[ "$got" != "$want" ]]; then
  echo "default -print mismatch: got [$got] want [$want]" >&2
  exit 1
fi
