#!/usr/bin/env bash
set -euo pipefail
# Documented: "-print0  ... print the full file name on the standard output,
# followed by a null character (instead of the newline character ...)".
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/only"

# Single match: output must be "<path>\0" with no trailing newline.
"$UTIL" "$tmpdir/only" -print0 > "$tmpdir/out.bin"
# Count NUL bytes; exactly one expected.
nul_count=$(tr -dc '\0' < "$tmpdir/out.bin" | wc -c | tr -d ' ')
# Ensure there is no newline terminator.
nl_count=$(tr -dc '\n' < "$tmpdir/out.bin" | wc -c | tr -d ' ')
if [[ "$nul_count" != "1" || "$nl_count" != "0" ]]; then
    echo "FAIL: -print0 expected 1 NUL and 0 newline, got NUL=$nul_count NL=$nl_count" >&2
    exit 1
fi
