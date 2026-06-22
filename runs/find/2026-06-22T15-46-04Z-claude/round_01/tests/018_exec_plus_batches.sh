#!/usr/bin/env bash
set -euo pipefail
# Documented: "-exec command {} +  ... the command line is built by appending
# each selected file name at the end; the total number of invocations of the
# command will be much less than the number of matched files."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/a"
: > "$tmpdir/b"
: > "$tmpdir/c"
log="$tmpdir/.log"
: > "$log"

# Each invocation appends exactly one line; batching yields fewer than 3 lines.
"$UTIL" "$tmpdir" -type f ! -name '.log' -exec sh -c 'echo invoked >> "$0"' "$log" {} +
invocations=$(wc -l < "$log" | tr -d ' ')
if [[ "$invocations" -ge 3 || "$invocations" -lt 1 ]]; then
    echo "FAIL: -exec ... {} + expected fewer than 3 invocations for 3 files, got: $invocations" >&2
    exit 1
fi
