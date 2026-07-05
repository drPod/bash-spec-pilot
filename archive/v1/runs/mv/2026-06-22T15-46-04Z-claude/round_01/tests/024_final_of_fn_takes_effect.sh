#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# "If you specify more than one of -i, -f, -n, only the final one takes effect."
# -f then -n => -n wins => existing destination is NOT overwritten.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" -f -n "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == old ]]; then
  exit 0
fi
echo "final-of -f -n did not let -n preserve the destination" >&2
exit 1
