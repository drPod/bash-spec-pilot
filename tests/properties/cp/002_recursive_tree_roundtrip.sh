#!/usr/bin/env bash
# Metamorphic invariant: cp -r DIR1 DIR2 must produce a tree whose files
# and subdirs recursively match DIR1. Manpage line 69:
# "-R, -r, --recursive    copy directories recursively".
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src"
dst="$tmpdir/dst"

mkdir -p "$src/a/b" "$src/c"
printf 'top\n' > "$src/top.txt"
printf 'nested-ab\n' > "$src/a/b/leaf.txt"
printf 'nested-c\n' > "$src/c/leaf.txt"
# Empty subdir — recursive copy should preserve the directory itself.
mkdir -p "$src/empty"

if ! "$UTIL" -r "$src" "$dst"; then
    echo "cp -r invocation failed" >&2
    exit 1
fi

if ! diff -r "$src" "$dst" >/dev/null; then
    echo "recursive tree diverged from source" >&2
    exit 1
fi
exit 0
