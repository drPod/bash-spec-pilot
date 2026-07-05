#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'A\n' > "$tmpdir/a"
printf 'B\n' > "$tmpdir/b"
"$UTIL" --exchange "$tmpdir/a" "$tmpdir/b"
if [[ "$(cat "$tmpdir/a")" == "B" ]]; then
  exit 0
else
  echo "--exchange did not put destination content at source path" >&2
  exit 1
fi
