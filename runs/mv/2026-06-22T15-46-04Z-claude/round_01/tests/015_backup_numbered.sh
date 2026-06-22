#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --backup=numbered (t): make numbered backups -> dst.~1~ holds previous contents.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" --backup=numbered "$tmpdir/src" "$tmpdir/dst"
if [[ -f "$tmpdir/dst.~1~" && "$(cat "$tmpdir/dst.~1~")" == old && "$(cat "$tmpdir/dst")" == new ]]; then
  exit 0
fi
echo "--backup=numbered did not create dst.~1~ backup" >&2
exit 1
