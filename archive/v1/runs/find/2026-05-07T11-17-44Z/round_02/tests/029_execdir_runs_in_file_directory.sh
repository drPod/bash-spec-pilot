#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root/sub"
: > "$tmpdir/root/sub/target"
PATH=/usr/bin:/bin "$UTIL" "$tmpdir/root" -type f -name target -execdir /bin/sh -c 'pwd > "$1"' sh "$tmpdir/pwdout" ';'
out=$(cat "$tmpdir/pwdout")
expected="$tmpdir/root/sub"
if [[ "$out" != "$expected" ]]; then echo "-execdir did not run command in containing directory" >&2; exit 1; fi
