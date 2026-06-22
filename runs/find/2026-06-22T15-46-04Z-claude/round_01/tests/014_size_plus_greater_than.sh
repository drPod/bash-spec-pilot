#!/usr/bin/env bash
set -euo pipefail
# Documented: "+n  for greater than n" and "an exact size of n units does not
# match". -size +10c matches files strictly larger than 10 bytes.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

printf '0123456789' > "$tmpdir/ten"          # exactly 10 bytes -> NOT matched
printf '0123456789X' > "$tmpdir/eleven"       # 11 bytes -> matched

out=$("$UTIL" "$tmpdir" -type f -size +10c | sort)
expected="$tmpdir/eleven"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -size +10c expected only $expected (exact 10 excluded), got: $out" >&2
    exit 1
fi
