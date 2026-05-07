#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src1="$tmpdir/a.txt"
src2="$tmpdir/b.txt"
out="$tmpdir/out"
printf 'linked content' > "$src1"
ln "$src1" "$src2"
mkdir "$out"
if ! "$UTIL" -d "$src1" "$src2" "$out"; then
  echo "cp -d failed" >&2
  exit 1
fi
if [[ $(stat -c '%d:%i' "$out/a.txt") == $(stat -c '%d:%i' "$out/b.txt") ]]; then
  exit 0
else
  echo "-d did not preserve hard link relationship" >&2
  exit 1
fi
