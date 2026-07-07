#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -n, --no-clobber: do not overwrite an existing file. dst keeps old content.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" -n "$tmpdir/src" "$tmpdir/dst"
if [[ "$(cat "$tmpdir/dst")" == old ]]; then
  exit 0
fi
echo "-n overwrote an existing destination" >&2
exit 1
