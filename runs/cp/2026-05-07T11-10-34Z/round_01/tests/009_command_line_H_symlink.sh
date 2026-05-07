#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
realdir="$tmpdir/real"
linkdir="$tmpdir/linkdir"
dst="$tmpdir/copy"
mkdir "$realdir"
printf 'inside\n' > "$realdir/file.txt"
ln -s "$realdir" "$linkdir"
if ! "$UTIL" -RH "$linkdir" "$dst"; then echo "cp -RH failed" >&2; exit 1; fi
if [[ "$(cat "$dst/file.txt")" == "inside" ]]; then exit 0; fi
echo "-H did not follow command-line directory symlink" >&2
exit 1
