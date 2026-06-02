#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
touch -t 202001010000 "$tmpdir/src"
touch -t 202201010000 "$tmpdir/dst"
set +e
"$UTIL" --update "$tmpdir/src" "$tmpdir/dst" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "mv unexpectedly failed" >&2
  exit 1
fi
if [[ "$(cat "$tmpdir/dst")" != "old" ]]; then
  echo "newer destination was replaced under --update=older" >&2
  exit 1
fi
