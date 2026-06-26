#!/usr/bin/env bash
# COLD adversarial: -name matches the base name only; a pattern with a slash
# (other than a sole "/") never matches.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/dir"
: > "$tmpdir/dir/target"

# Documented: "Base of file name (the path with the leading directories
# removed) matches shell pattern pattern. Because the leading directories of
# the file names are removed, the pattern should not include a slash, because
# `-name a/b' will never match anything"
# So -name "dir/target" must match nothing even though that path exists.
got="$("$UTIL" "$tmpdir" -name 'dir/target' | LC_ALL=C sort)"
want=""

if [[ "$got" != "$want" ]]; then
  echo "-name with slash should match nothing: got [$got]" >&2
  exit 1
fi
