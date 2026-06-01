#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/target"
printf 'payload\n' > "$tmpdir/src"

set +e
"$UTIL" -T -t "$tmpdir/target" "$tmpdir/src" >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "-T and -t were both accepted" >&2
  exit 1
fi
