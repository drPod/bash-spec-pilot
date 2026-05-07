#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'new' > "$src"
printf 'old' > "$dst"
set +e
"$UTIL" --update=none-fail "$src" "$dst" >/dev/null 2>&1
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "--update=none-fail unexpectedly succeeded when skipping" >&2
  exit 1
fi
