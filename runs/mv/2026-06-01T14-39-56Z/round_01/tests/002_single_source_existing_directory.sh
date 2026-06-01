#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/item"
dir="$tmpdir/target"
mkdir "$dir"
printf 'payload' > "$src"
"$UTIL" "$src" "$dir"
if [[ -f "$dir/item" ]]; then
  exit 0
else
  echo "source was not moved into existing directory" >&2
  exit 1
fi
