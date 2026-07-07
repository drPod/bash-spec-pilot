#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/src"
dst="$tmpdir/dst"
printf 'new' > "$src"
printf 'old' > "$dst"
"$UTIL" --update=none "$src" "$dst"
if [[ "$(<"$dst")" == "old" ]]; then
  exit 0
else
  echo "--update=none overwrote destination" >&2
  exit 1
fi
