#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# "If you specify more than one of -i, -f, -n, only the final one takes effect."
# -n then -f => -f wins => existing destination is overwritten.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" -n -f "$tmpdir/src" "$tmpdir/dst" < /dev/null
if [[ "$(cat "$tmpdir/dst")" == new ]]; then
  exit 0
fi
echo "final-of -n -f did not let -f overwrite the destination" >&2
exit 1
