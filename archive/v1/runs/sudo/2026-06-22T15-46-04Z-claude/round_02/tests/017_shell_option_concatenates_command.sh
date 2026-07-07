#!/usr/bin/env bash
# -s, --shell: "Run the shell specified by the SHELL environment variable if it
# is set ... If a command is specified, it is passed to the shell as a simple
# command using the -c option. The command and any args are concatenated,
# separated by spaces".  With SHELL=/bin/sh, '-s echo A B' runs '/bin/sh -c
# "echo A B"', emitting the two args joined by a single space.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

out="$(SHELL=/bin/sh "$UTIL" -n -s echo sudoMarkerC sudoMarkerD 2>/dev/null)"
if grep -qx "sudoMarkerC sudoMarkerD" <<<"$out"; then
    exit 0
fi
echo "FAIL: '-s echo A B' did not emit 'sudoMarkerC sudoMarkerD'; got: $out" >&2
exit 1
