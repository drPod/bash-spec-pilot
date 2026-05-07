#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
set +e
"$UTIL" --update=none-fail "$tmpdir/src" "$tmpdir/dst" >/dev/null 2>&1
status=$?
set -e
if [[ $status -ne 0 ]]; then
  exit 0
else
  echo "--update=none-fail did not fail for skipped destination" >&2
  exit 1
fi
