#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
set +e
"$UTIL" --update=invalid "$src" "$dst"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "invalid --update value was accepted" >&2
  exit 1
fi
