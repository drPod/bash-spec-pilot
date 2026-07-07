#!/usr/bin/env bash
set -euo pipefail
# Documented: "-prune  True; if the file is a directory, do not descend into
# it." Using the documented idiom: -path DIR -prune -o -print.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/skip"
: > "$tmpdir/skip/hidden"
mkdir "$tmpdir/keep"
: > "$tmpdir/keep/shown"

# Prune the 'skip' directory; its contents must not appear, nor 'skip' itself
# (the -prune branch is true so default -print does not apply to it).
out=$("$UTIL" "$tmpdir" -path "$tmpdir/skip" -prune -o -print | sort)
if printf '%s\n' "$out" | grep -qF "$tmpdir/skip"; then
    echo "FAIL: -prune did not exclude the pruned directory subtree, got: $out" >&2
    exit 1
fi
