#!/usr/bin/env bash
# Invariant: find's default behavior on a starting-point directory includes
# the starting-point itself in the output.
#
# Manpage backing: utils/find/manpage.txt lines 403-407 (-maxdepth definition
# says "Using -maxdepth 0 means only apply the tests and actions to the
# starting-points themselves") and lines 410-413 (-mindepth definition says
# "Using -mindepth 1 means process all files except the starting-points").
# Together these imply the starting-point IS in the default traversal set.
#
# Bug class (taxonomy.md): Missing Corner Case — implementations frequently
# skip the starting-point itself and only emit descendants.

set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/sub"
touch "$tmpdir/a" "$tmpdir/sub/b"

out=$("$UTIL" "$tmpdir")

# Default action is -print; starting-point must appear as its own line.
if ! printf '%s\n' "$out" | grep -Fxq "$tmpdir"; then
  printf 'fail: starting-point %q absent from default find output\n' "$tmpdir" >&2
  printf '%s\n' "$out" >&2
  exit 1
fi
