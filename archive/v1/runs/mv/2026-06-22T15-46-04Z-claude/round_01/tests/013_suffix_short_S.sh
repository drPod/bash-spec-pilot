#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -S SUFFIX short form overrides the usual backup suffix.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" -b -S .bak "$tmpdir/src" "$tmpdir/dst"
if [[ -f "$tmpdir/dst.bak" && "$(cat "$tmpdir/dst.bak")" == old ]]; then
  exit 0
fi
echo "-S did not override backup suffix" >&2
exit 1
