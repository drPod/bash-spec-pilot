#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/root/all"
: > "$tmpdir/root/extra"
: > "$tmpdir/root/no"
chmod 664 "$tmpdir/root/all"
chmod 775 "$tmpdir/root/extra"
chmod 644 "$tmpdir/root/no"
out=$("$UTIL" "$tmpdir/root" -type f -perm -664 -printf '%f\n' | sort)
expected=$'all\nextra'
if [[ "$out" != "$expected" ]]; then echo "-perm -mode did not require all requested bits" >&2; exit 1; fi
