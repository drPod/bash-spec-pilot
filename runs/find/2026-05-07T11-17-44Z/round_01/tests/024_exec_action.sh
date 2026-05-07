#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/root/target"
marker="$tmpdir/marker"
if ! "$UTIL" "$tmpdir/root" -name target -exec /bin/sh -c 'printf done > "$1"' sh "$marker" ';'; then
  echo "find invocation failed" >&2
  exit 1
fi
actual=$(cat "$marker")
if [[ "$actual" != "done" ]]; then
  echo "-exec did not run the command for the matched file" >&2
  exit 1
fi
