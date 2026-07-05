#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset VERSION_CONTROL
unset SIMPLE_BACKUP_SUFFIX
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
set +e
"$UTIL" --backup=bogus "$tmpdir/src" "$tmpdir/dst" >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "invalid --backup control value succeeded" >&2
  exit 1
fi
