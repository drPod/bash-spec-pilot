#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/real"
printf 'payload\n' > "$tmpdir/real/file"
ln -s "$tmpdir/real" "$tmpdir/link"
set +e
"$UTIL" --strip-trailing-slashes "$tmpdir/link/" "$tmpdir/moved" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "mv unexpectedly failed" >&2
  exit 1
fi
if [[ ! -L "$tmpdir/moved" ]]; then
  echo "stripped symlink source was not moved as a symlink" >&2
  exit 1
fi
