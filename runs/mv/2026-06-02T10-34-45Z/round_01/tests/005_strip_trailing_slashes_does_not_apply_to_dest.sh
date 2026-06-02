#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'payload\n' > "$tmpdir/src"
set +e
"$UTIL" --strip-trailing-slashes "$tmpdir/src" "$tmpdir/newname/" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "destination trailing slash was stripped even though only SOURCE slashes are documented" >&2
  exit 1
fi
