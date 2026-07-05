#!/usr/bin/env bash
set -euo pipefail
# Documented: "-size n[cwbkMG] ... `c'  for bytes". Exact byte count match.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# 10-byte file and a 20-byte file.
printf '0123456789' > "$tmpdir/ten"
printf '01234567890123456789' > "$tmpdir/twenty"

out=$("$UTIL" "$tmpdir" -type f -size 10c | sort)
expected="$tmpdir/ten"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -size 10c expected only $expected, got: $out" >&2
    exit 1
fi
