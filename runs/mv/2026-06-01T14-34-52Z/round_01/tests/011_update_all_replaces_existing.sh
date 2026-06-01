#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new' > "$tmpdir/src"
printf 'old' > "$tmpdir/dst"

"$UTIL" --update=all "$tmpdir/src" "$tmpdir/dst"
content="$(cat "$tmpdir/dst" 2>/dev/null || true)"

if [[ $content == "new" ]]; then
  exit 0
else
  echo "expected --update=all to replace destination" >&2
  exit 1
fi
