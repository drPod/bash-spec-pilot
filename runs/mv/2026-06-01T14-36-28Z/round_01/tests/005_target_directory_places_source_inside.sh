#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/target"
printf 'payload\n' > "$tmpdir/src"

"$UTIL" -t "$tmpdir/target" "$tmpdir/src"

actual="$(<"$tmpdir/target/src")"
if [[ "$actual" != "payload" ]]; then
  echo "-t did not move source into directory" >&2
  exit 1
fi
