#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/target.txt"
link="$tmpdir/link.txt"
dst="$tmpdir/copied.txt"
printf 'referent\n' > "$target"
ln -s "$target" "$link"
if ! "$UTIL" -L "$link" "$dst"; then echo "cp -L failed" >&2; exit 1; fi
if [[ ! -L "$dst" ]]; then exit 0; fi
echo "-L copied the symlink instead of its referent" >&2
exit 1
