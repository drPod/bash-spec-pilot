#!/usr/bin/env bash
# -i, --login: "If a command is specified, it is passed to the shell as a
# simple command using the -c option. The command and any args are
# concatenated, separated by spaces".  So '-i echo A B' runs the login shell
# with '-c "echo A B"', emitting the two args joined by a single space on one
# line.  (Login resource files may add other output, so the assertion matches a
# line rather than the whole stream.)
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

out="$("$UTIL" -n -i echo sudoMarkerA sudoMarkerB 2>/dev/null)"
if grep -qx "sudoMarkerA sudoMarkerB" <<<"$out"; then
    exit 0
fi
echo "FAIL: '-i echo A B' did not emit 'sudoMarkerA sudoMarkerB'; got: $out" >&2
exit 1
