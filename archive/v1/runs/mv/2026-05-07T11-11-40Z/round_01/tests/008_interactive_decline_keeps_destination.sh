#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
"$UTIL" -i "$tmpdir/src" "$tmpdir/dst" <<< "n" >/dev/null 2>&1
if [[ "$(cat "$tmpdir/dst")" == "old" ]]; then
  exit 0
else
  echo "-i did not honor a negative overwrite response" >&2
  exit 1
fi
