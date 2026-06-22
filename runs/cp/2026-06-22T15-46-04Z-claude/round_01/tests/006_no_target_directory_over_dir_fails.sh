#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
existingdir="$tmpdir/adir"
printf 'data\n' > "$src"
mkdir "$existingdir"

# -T treats DEST as a normal file; pointing it at an existing directory must fail.
set +e
"$UTIL" -T "$src" "$existingdir"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "FAIL: -T against an existing directory should fail but exited 0" >&2
  exit 1
fi
