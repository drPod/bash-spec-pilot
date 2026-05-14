#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir "$tmpdir/target"
printf 'payload' > "$tmpdir/src"
"$UTIL" -t "$tmpdir/target" "$tmpdir/src"
if [[ $(cat "$tmpdir/target/src") == "payload" ]]; then
  exit 0
else
  echo "-t did not move source into target directory" >&2
  exit 1
fi
