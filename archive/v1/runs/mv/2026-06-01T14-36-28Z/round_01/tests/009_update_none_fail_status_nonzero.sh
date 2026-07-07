#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

set +e
"$UTIL" --update=none-fail "$tmpdir/src" "$tmpdir/dest" >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "--update=none-fail did not fail on skipped file" >&2
  exit 1
fi
