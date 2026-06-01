#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'payload\n' > "$tmpdir/src"
mkdir "$tmpdir/destdir"

set +e
"$UTIL" -T "$tmpdir/src" "$tmpdir/destdir" >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "-T unexpectedly accepted directory destination" >&2
  exit 1
fi
