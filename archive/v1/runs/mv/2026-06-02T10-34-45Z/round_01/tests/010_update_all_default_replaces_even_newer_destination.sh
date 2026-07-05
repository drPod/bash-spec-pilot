#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
touch -t 202001010000 "$tmpdir/src"
touch -t 202201010000 "$tmpdir/dst"
set +e
"$UTIL" "$tmpdir/src" "$tmpdir/dst" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "mv unexpectedly failed" >&2
  exit 1
fi
if [[ "$(cat "$tmpdir/dst")" != "new" ]]; then
  echo "default update=all did not replace existing destination" >&2
  exit 1
fi
