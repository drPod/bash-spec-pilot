#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out=$("$UTIL" -D help 2>&1)
if [[ "$out" != *"Valid arguments"* ]]; then echo "-D help did not list debug arguments" >&2; exit 1; fi
