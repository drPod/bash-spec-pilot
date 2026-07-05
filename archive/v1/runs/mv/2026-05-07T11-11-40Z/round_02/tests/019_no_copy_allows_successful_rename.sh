#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'payload' > "$tmpdir/src"
"$UTIL" --no-copy "$tmpdir/src" "$tmpdir/dst"
if [[ $(cat "$tmpdir/dst") == "payload" ]]; then
  exit 0
else
  echo "--no-copy prevented a successful rename" >&2
  exit 1
fi
