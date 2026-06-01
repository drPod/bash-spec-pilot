#!/usr/bin/env bash
# Metamorphic invariant: cp -p must preserve file mode bits. Manpage line 58:
# "-p     same as --preserve=mode,ownership,timestamps".
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src"
dst="$tmpdir/dst"

printf 'mode-check\n' > "$src"
# Distinctive non-default mode unlikely to collide with umask defaults.
chmod 0741 "$src"
src_mode=$(stat -c '%a' "$src")

if ! "$UTIL" -p "$src" "$dst"; then
    echo "cp -p invocation failed" >&2
    exit 1
fi

dst_mode=$(stat -c '%a' "$dst")
if [[ "$src_mode" != "$dst_mode" ]]; then
    echo "mode mismatch: src=$src_mode dst=$dst_mode" >&2
    exit 1
fi
exit 0
