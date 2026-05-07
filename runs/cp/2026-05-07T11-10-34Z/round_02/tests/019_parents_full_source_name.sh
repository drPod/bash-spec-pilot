#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/a/b/file.txt"
out="$tmpdir/out"
mkdir -p "$tmpdir/a/b" "$out"
printf 'parents' > "$src"
if ! "$UTIL" --parents "$src" "$out"; then
  echo "cp --parents failed" >&2
  exit 1
fi
copied="$out$src"
if [[ $(cat "$copied") == 'parents' ]]; then
  exit 0
else
  echo "--parents did not create full source path under directory" >&2
  exit 1
fi
