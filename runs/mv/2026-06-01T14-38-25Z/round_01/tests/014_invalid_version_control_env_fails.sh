#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset SIMPLE_BACKUP_SUFFIX
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
set +e
VERSION_CONTROL=bogus "$UTIL" --backup "$tmpdir/src" "$tmpdir/dst" >/dev/null 2>&1
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "invalid VERSION_CONTROL value succeeded" >&2
  exit 1
fi
