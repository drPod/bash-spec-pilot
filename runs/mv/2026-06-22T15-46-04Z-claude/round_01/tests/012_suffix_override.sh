#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -S, --suffix=SUFFIX: override the usual backup suffix.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" --backup --suffix=.bak "$tmpdir/src" "$tmpdir/dst"
if [[ -f "$tmpdir/dst.bak" && "$(cat "$tmpdir/dst.bak")" == old && ! -e "$tmpdir/dst~" ]]; then
  exit 0
fi
echo "--suffix did not override backup suffix" >&2
exit 1
