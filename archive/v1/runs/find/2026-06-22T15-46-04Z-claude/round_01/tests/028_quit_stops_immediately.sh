#!/usr/bin/env bash
set -euo pipefail
# Documented: "After -quit is executed, no more files specified on the command
# line will be processed. For example, `find /tmp/foo /tmp/bar -print -quit`
# will print only `/tmp/foo`."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/foo"
mkdir "$tmpdir/bar"

out=$("$UTIL" "$tmpdir/foo" "$tmpdir/bar" -print -quit)
expected="$tmpdir/foo"
if [[ "$out" != "$expected" ]]; then
    echo "FAIL: -print -quit over two start points expected only $expected, got: $out" >&2
    exit 1
fi
