#!/usr/bin/env bash
# COLD adversarial ERROR: -files0-from and a command-line starting point are
# mutually exclusive.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

list="$tmpdir/list"
printf '%s\0' "$tmpdir" > "$list"

# Documented: "Using this option and passing starting points on the command
# line is mutually exclusive, and is therefore not allowed at the same time."
# Pass BOTH a command-line start point and -files0-from -> error.
set +e
"$UTIL" "$tmpdir" -files0-from "$list" >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "-files0-from + cmdline start point should error, got status 0" >&2
  exit 1
fi
