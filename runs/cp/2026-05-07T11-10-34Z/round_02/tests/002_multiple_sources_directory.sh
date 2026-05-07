#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src1="$tmpdir/one.txt"
src2="$tmpdir/two.txt"
out="$tmpdir/out"
printf 'one' > "$src1"
printf 'two' > "$src2"
mkdir "$out"
if ! "$UTIL" "$src1" "$src2" "$out"; then
  echo "multi-source cp failed" >&2
  exit 1
fi
if [[ -f "$out/one.txt" && -f "$out/two.txt" ]]; then
  exit 0
else
  echo "not all sources copied to directory" >&2
  exit 1
fi
