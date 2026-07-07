#!/usr/bin/env bash
# COLD adversarial: -prune on a directory prevents descent into it; the
# documented "-path ... -prune -o -print" idiom.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/skipme/deep"
: > "$tmpdir/skipme/deep/buried"
: > "$tmpdir/keep"

# Documented: "-prune True; if the file is a directory, do not descend into it."
# and the example "find . -path ./src/emacs -prune -o -print".
# Contents of skipme must not appear; the pruned dir name itself is not printed
# here because -prune returns true and short-circuits the -o (only the RHS
# -print runs for non-pruned files).
got="$("$UTIL" "$tmpdir" -path "$tmpdir/skipme" -prune -o -print | LC_ALL=C sort)"
want="$(printf '%s\n%s\n' "$tmpdir" "$tmpdir/keep" | LC_ALL=C sort)"

if [[ "$got" != "$want" ]]; then
  echo "-prune subtree-skip mismatch: got [$got] want [$want]" >&2
  exit 1
fi
