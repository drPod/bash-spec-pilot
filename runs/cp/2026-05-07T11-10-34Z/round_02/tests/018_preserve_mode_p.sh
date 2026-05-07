#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'mode' > "$src"
chmod 754 "$src"
if ! "$UTIL" -p "$src" "$dst"; then
  echo "cp -p failed" >&2
  exit 1
fi
if [[ $(stat -c '%a' "$dst") == '754' ]]; then
  exit 0
else
  echo "mode was not preserved by -p" >&2
  exit 1
fi
