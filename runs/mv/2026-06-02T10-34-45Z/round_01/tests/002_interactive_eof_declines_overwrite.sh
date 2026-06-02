#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
set +e
"$UTIL" -i "$tmpdir/src" "$tmpdir/dst" </dev/null >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "mv unexpectedly failed" >&2
  exit 1
fi
if [[ "$(cat "$tmpdir/dst")" != "old" ]]; then
  echo "destination was overwritten despite EOF at interactive prompt" >&2
  exit 1
fi
