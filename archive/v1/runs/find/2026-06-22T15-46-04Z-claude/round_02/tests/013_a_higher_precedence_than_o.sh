#!/usr/bin/env bash
# COLD adversarial: -a binds tighter than -o; the documented "never print afile"
# precedence surprise.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/afile"
: > "$tmpdir/bfile"

# Documented (NON-BUGS): "The command find . -name afile -o -name bfile -print
# will never print afile because this is actually equivalent to
# find . -name afile -o \( -name bfile -a -print \)."
# So the analogous command here prints only bfile, never afile.
got="$("$UTIL" "$tmpdir" -name afile -o -name bfile -print | LC_ALL=C sort)"
want="$tmpdir/bfile"

if [[ "$got" != "$want" ]]; then
  echo "precedence: -a tighter than -o mismatch: got [$got] want [$want]" >&2
  exit 1
fi
