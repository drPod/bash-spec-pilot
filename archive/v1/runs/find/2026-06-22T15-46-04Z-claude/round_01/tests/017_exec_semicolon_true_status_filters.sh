#!/usr/bin/env bash
set -euo pipefail
# Documented: "-exec command ;  Execute command; true if 0 status is returned."
# Used as a test, -exec only keeps files for which the command exits 0.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

printf 'match' > "$tmpdir/has_match"
printf 'nope'  > "$tmpdir/no_match"

# grep -q exits 0 only for files containing 'match'; -print then runs for those.
out=$("$UTIL" "$tmpdir" -type f -exec grep -q match {} \; -print | sort)
expected="$tmpdir/has_match"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -exec ... ; should keep only files where cmd exits 0, got: $out" >&2
    exit 1
fi
