#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'left' > "$tmpdir/a"
printf 'right' > "$tmpdir/b"
"$UTIL" --exchange "$tmpdir/a" "$tmpdir/b"
if [[ $(cat "$tmpdir/a") == "right" ]]; then
  exit 0
else
  echo "--exchange did not swap destination into source path" >&2
  exit 1
fi
