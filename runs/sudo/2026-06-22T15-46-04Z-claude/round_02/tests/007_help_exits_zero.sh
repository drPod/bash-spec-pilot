#!/usr/bin/env bash
# -h, --help: "Display a short help message to the standard output and exit."
# Help must succeed (exit 0) and write to standard output.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

out="$("$UTIL" -h)"
if [[ -n "$out" ]]; then
    exit 0
fi
echo "FAIL: '-h' produced no output on stdout; man page says it displays a help message" >&2
exit 1
