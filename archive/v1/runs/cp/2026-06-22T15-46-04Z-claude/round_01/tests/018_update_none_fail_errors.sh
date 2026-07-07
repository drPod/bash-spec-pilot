#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'incoming\n' > "$src"
printf 'kept\n' > "$dst"

# --update=none-fail: no files replaced, but any skipped files are diagnosed and induce a failure.
set +e
"$UTIL" --update=none-fail "$src" "$dst"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "FAIL: --update=none-fail should induce a failure on a skipped file but exited 0" >&2
  exit 1
fi
