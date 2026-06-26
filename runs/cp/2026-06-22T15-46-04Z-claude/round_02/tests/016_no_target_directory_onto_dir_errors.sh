#!/usr/bin/env bash
set -euo pipefail
# -T, --no-target-directory : "treat DEST as a normal file".
# DEST is an existing directory; treating it as a normal file to receive a
# regular-file SOURCE cannot succeed => nonzero exit.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.txt"
dst="$tmpdir/destdir"
printf 'data' > "$src"
mkdir -p "$dst"

set +e
"$UTIL" -T "$src" "$dst"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "FAIL: -T onto an existing directory did not error" >&2
  exit 1
fi
