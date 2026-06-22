#!/usr/bin/env bash
set -euo pipefail
# Documented: "If no expression is given, the expression -print is used".
# With no expression, find prints the starting point itself.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out=$("$UTIL" "$tmpdir")
if ! printf '%s\n' "$out" | grep -qxF "$tmpdir"; then
    echo "FAIL: default -print did not print starting point $tmpdir" >&2
    exit 1
fi
