#!/usr/bin/env bash
set -euo pipefail
# --update=none-fail : "ensures no files are replaced in the destination, but
# any skipped files are diagnosed and induce a failure."
# Existing DEST is skipped => nonzero exit.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"

set +e
"$UTIL" --update=none-fail "$src" "$dst"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "FAIL: --update=none-fail did not induce a failure on a skipped file" >&2
  exit 1
fi
