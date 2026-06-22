#!/usr/bin/env bash
set -euo pipefail
# Documented: "To search for more than one type at once, you can supply the
# combined list of type letters separated by a comma `,' (GNU extension)."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/reg"
mkdir "$tmpdir/dir"
ln -s "$tmpdir/reg" "$tmpdir/link"

# f,d,l should match the regular file, the dir, the link, and the start dir.
out=$("$UTIL" "$tmpdir" -type f,d,l | sort)
expected=$(printf '%s\n%s\n%s\n%s\n' \
    "$tmpdir" "$tmpdir/dir" "$tmpdir/link" "$tmpdir/reg" | sort)
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -type f,d,l expected all four entries, got: $out" >&2
    exit 1
fi
