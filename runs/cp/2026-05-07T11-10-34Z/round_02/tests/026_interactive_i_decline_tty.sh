#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'new' > "$src"
printf 'old' > "$dst"
export UTIL SRC="$src" DST="$dst"
if ! printf 'n\n' | script -q -e -c '"$UTIL" -i "$SRC" "$DST"' /dev/null >/dev/null 2>&1; then
  echo "cp -i failed under pseudo-tty" >&2
  exit 1
fi
if [[ $(cat "$dst") == 'old' ]]; then
  exit 0
else
  echo "negative interactive response did not leave destination unchanged" >&2
  exit 1
fi
