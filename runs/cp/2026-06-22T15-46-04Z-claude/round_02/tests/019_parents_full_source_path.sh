#!/usr/bin/env bash
set -euo pipefail
# --parents : "use full source file name under DIRECTORY".
# Copying a/b/c.txt into DIR recreates the a/b/ path under DIR.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --parents derives the path from the SOURCE argument as given, so run from
# a known cwd and pass a relative multi-component SOURCE.
mkdir -p "$tmpdir/a/b"
printf 'C' > "$tmpdir/a/b/c.txt"
dir="$tmpdir/into"
mkdir -p "$dir"

( cd "$tmpdir" && "$UTIL" --parents "a/b/c.txt" "$dir" )

if [[ "$(cat "$dir/a/b/c.txt" 2>/dev/null)" != "C" ]]; then
  echo "FAIL: --parents did not recreate full source path under DIRECTORY" >&2
  exit 1
fi
