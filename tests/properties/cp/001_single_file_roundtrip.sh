#!/usr/bin/env bash
# Metamorphic invariant: cp X Y must produce a destination whose contents
# byte-for-byte equal the source. Manpage DESCRIPTION (line 12):
# "Copy SOURCE to DEST, or multiple SOURCE(s) to DIRECTORY."
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src"
dst="$tmpdir/dst"

# Mix of printable, whitespace, and a NUL byte to flush byte-level copy bugs.
printf 'hello\nworld\t%s\n' 'with spaces' > "$src"
printf '\x00\x01\x02binary tail' >> "$src"

if ! "$UTIL" "$src" "$dst"; then
    echo "cp invocation failed" >&2
    exit 1
fi

if ! diff -q "$src" "$dst" >/dev/null; then
    echo "round-trip failed: dst does not byte-equal src" >&2
    exit 1
fi
exit 0
