#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'payload\n' > "$tmpdir/src"
mkdir "$tmpdir/destdir"
set +e
"$UTIL" -T "$tmpdir/src" "$tmpdir/destdir" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "-T moved source into directory instead of treating DEST as a normal file" >&2
  exit 1
fi
