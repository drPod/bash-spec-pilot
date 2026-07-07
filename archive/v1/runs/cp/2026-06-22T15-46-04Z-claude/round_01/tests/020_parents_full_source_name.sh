#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/a/b"
printf 'leaf\n' > "$tmpdir/a/b/c.txt"
destdir="$tmpdir/dest"
mkdir "$destdir"

# --parents: use full source file name under DIRECTORY
( cd "$tmpdir" && "$UTIL" --parents a/b/c.txt "$destdir" )

if [[ ! -f "$destdir/a/b/c.txt" ]]; then
  echo "FAIL: --parents did not recreate full source path under DIRECTORY" >&2
  exit 1
fi
