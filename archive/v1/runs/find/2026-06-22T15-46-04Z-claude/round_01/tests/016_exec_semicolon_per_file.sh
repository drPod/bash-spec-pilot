#!/usr/bin/env bash
set -euo pipefail
# Documented: "-exec command ;  ... The string `{}' is replaced by the current
# file name ... The specified command is run once for each matched file."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/f1"
: > "$tmpdir/f2"
: > "$tmpdir/f3"
counter="$tmpdir/.count"
: > "$counter"

# One invocation per matched regular file appends one line.
"$UTIL" "$tmpdir" -type f ! -name '.count' -exec sh -c 'echo x >> "$0"' "$counter" {} \;
lines=$(wc -l < "$counter" | tr -d ' ')
if [[ "$lines" != "3" ]]; then
    echo "FAIL: -exec ... ; expected 3 per-file invocations, got: $lines" >&2
    exit 1
fi
