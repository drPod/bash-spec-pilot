#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/mode640"
: > "$tmpdir/mode600"
chmod 640 "$tmpdir/mode640"
chmod 600 "$tmpdir/mode600"
if ! actual=$("$UTIL" "$tmpdir" -maxdepth 1 -type f -perm 640 -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "mode640" ]]; then
  echo "-perm exact octal mode did not match only mode640" >&2
  exit 1
fi
