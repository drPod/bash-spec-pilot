#!/usr/bin/env bash
set -euo pipefail
# -f : "(this option is ignored when the -n option is also used)"
# With -f -n together, -f is ignored, so existing DEST is NOT overwritten.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"

set +e
"$UTIL" -f -n "$src" "$dst"
set -e

if [[ "$(cat "$dst")" != "OLD" ]]; then
  echo "FAIL: -f was not ignored under -n; DEST overwritten" >&2
  exit 1
fi
