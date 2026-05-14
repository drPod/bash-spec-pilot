#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/target"
printf 'a' > "$tmpdir/a"
printf 'b' > "$tmpdir/b"
"$UTIL" "$tmpdir/a" "$tmpdir/b" "$tmpdir/target"
if [[ -f "$tmpdir/target/a" && -f "$tmpdir/target/b" ]]; then
  exit 0
else
  echo "not all sources were moved into target directory" >&2
  exit 1
fi
