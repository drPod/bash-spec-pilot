#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/dirnamedest"
printf 'payload' > "$tmpdir/src"
"$UTIL" -T "$tmpdir/src" "$tmpdir/destfile"
if [[ $(cat "$tmpdir/destfile") == "payload" ]]; then
  exit 0
else
  echo "-T file-to-file move did not create destination file" >&2
  exit 1
fi
