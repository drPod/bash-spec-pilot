#!/usr/bin/env bash
# COLD adversarial boundary: exact size in bytes; n does not match n+/-1.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf '%s' 'AAAAA' > "$tmpdir/five"    # exactly 5 bytes
printf '%s' 'AAAA'  > "$tmpdir/four"    # 4 bytes -> excluded by -size 5c

# Documented: "n  for exactly n." and (suffix table) "`c'  for bytes".
# -size 5c matches exactly the 5-byte file, not the 4-byte one.
got="$("$UTIL" "$tmpdir" -type f -size 5c | LC_ALL=C sort)"
want="$tmpdir/five"

if [[ "$got" != "$want" ]]; then
  echo "-size 5c exact-byte mismatch: got [$got] want [$want]" >&2
  exit 1
fi
