#!/usr/bin/env bash
# COLD adversarial: comma-separated -type list (GNU extension) matches the union.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/adir"
: > "$tmpdir/afile"
ln -s "$tmpdir/afile" "$tmpdir/alink"

# Documented: "To search for more than one type at once, you can supply the
# combined list of type letters separated by a comma `,' (GNU extension)."
# -type f,l matches the regular file and the symlink, not the directory.
got="$("$UTIL" "$tmpdir" -type f,l | LC_ALL=C sort)"
want="$(printf '%s\n%s\n' "$tmpdir/afile" "$tmpdir/alink" | LC_ALL=C sort)"

if [[ "$got" != "$want" ]]; then
  echo "-type f,l union mismatch: got [$got] want [$want]" >&2
  exit 1
fi
