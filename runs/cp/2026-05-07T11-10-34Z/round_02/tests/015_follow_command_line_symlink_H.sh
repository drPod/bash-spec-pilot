#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
realdir="$tmpdir/realdir"
linkdir="$tmpdir/linkdir"
dstdir="$tmpdir/copy"
mkdir "$realdir"
printf 'inside' > "$realdir/file.txt"
ln -s "$realdir" "$linkdir"
if ! "$UTIL" -R -H "$linkdir" "$dstdir"; then
  echo "cp -R -H failed" >&2
  exit 1
fi
if [[ $(cat "$dstdir/file.txt") == 'inside' ]]; then
  exit 0
else
  echo "-H did not follow command-line directory symlink" >&2
  exit 1
fi
