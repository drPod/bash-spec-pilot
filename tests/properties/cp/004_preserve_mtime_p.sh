#!/usr/bin/env bash
# Metamorphic invariant: cp -p must preserve modification time. Manpage
# line 58: "-p     same as --preserve=mode,ownership,timestamps".
# Filesystem mtime resolution varies (ext4 ns, FAT 2s); allow up to 1s
# difference to absorb integer-second rounding without masking real bugs.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src"
dst="$tmpdir/dst"

printf 'mtime-check\n' > "$src"
# Set an explicit past mtime so the test does not depend on copy latency.
touch -d '2020-01-02 03:04:05 UTC' "$src"
src_mtime=$(stat -c '%Y' "$src")

if ! "$UTIL" -p "$src" "$dst"; then
    echo "cp -p invocation failed" >&2
    exit 1
fi

dst_mtime=$(stat -c '%Y' "$dst")
delta=$(( src_mtime > dst_mtime ? src_mtime - dst_mtime : dst_mtime - src_mtime ))
if (( delta > 1 )); then
    echo "mtime drift: src=$src_mtime dst=$dst_mtime delta=${delta}s" >&2
    exit 1
fi
exit 0
