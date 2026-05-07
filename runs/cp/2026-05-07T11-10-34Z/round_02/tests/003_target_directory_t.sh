#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
out="$tmpdir/target"
printf 'via -t' > "$src"
mkdir "$out"
if ! "$UTIL" -t "$out" "$src"; then
  echo "cp -t failed" >&2
  exit 1
fi
if [[ $(cat "$out/source.txt") == 'via -t' ]]; then
  exit 0
else
  echo "target-directory copy content mismatch" >&2
  exit 1
fi
