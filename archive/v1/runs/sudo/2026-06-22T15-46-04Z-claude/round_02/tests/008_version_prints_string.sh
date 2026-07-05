#!/usr/bin/env bash
# -V, --version: "Print the sudo version string as well as the version string
# of any configured plugins."  Version output must contain the word "version"
# (case-insensitive) as part of the printed version string and exit 0.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

out="$("$UTIL" -V)"
if grep -qi "version" <<<"$out"; then
    exit 0
fi
echo "FAIL: '-V' output did not contain a version string" >&2
exit 1
