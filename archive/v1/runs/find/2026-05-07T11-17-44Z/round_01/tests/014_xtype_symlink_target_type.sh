#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
: > "$tmpdir/target"
ln -s "$tmpdir/target" "$tmpdir/link"
if ! actual=$("$UTIL" -P "$tmpdir" -maxdepth 1 -type l -xtype f -printf '%f\n'); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != "link" ]]; then
  echo "-xtype f did not match a symlink to a regular file under -P" >&2
  exit 1
fi
