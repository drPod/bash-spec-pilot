#!/usr/bin/env bash
# COLD adversarial: with no starting-point, "." is assumed.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/sub"
: > "$tmpdir/sub/f"

# Run from inside tmpdir with NO path and NO expression.
# Documented: "If no starting-point is specified, `.' is assumed."
# Plus default -print. So output paths begin with "." not the abs path.
got="$(cd "$tmpdir" && "$UTIL" | LC_ALL=C sort)"
want="$(printf '%s\n%s\n%s\n' "." "./sub" "./sub/f" | LC_ALL=C sort)"

if [[ "$got" != "$want" ]]; then
  echo "implicit dot start mismatch: got [$got] want [$want]" >&2
  exit 1
fi
