#!/usr/bin/env bash
# Invariant: `-maxdepth N` results monotonically grow with N. The result
# set for -maxdepth k is a subset of the result set for -maxdepth (k+1),
# because increasing the depth ceiling can only admit more entries.
#
# Manpage backing: utils/find/manpage.txt lines 403-407 (-maxdepth levels:
# "Descend at most levels (a non-negative integer) levels of directories
# below the starting-points").
#
# Bug class (taxonomy.md): Missing Corner Case — off-by-one bugs at the
# depth boundary (treating -maxdepth 1 as "starting point only" or
# -maxdepth 0 as "starting point plus its children") would break the
# subset relation.

set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/l1/l2/l3"
touch "$tmpdir/r" "$tmpdir/l1/a" "$tmpdir/l1/l2/b" "$tmpdir/l1/l2/l3/c"

prev=$("$UTIL" "$tmpdir" -maxdepth 0 | sort)
for k in 1 2 3 4; do
  cur=$("$UTIL" "$tmpdir" -maxdepth "$k" | sort)
  missing=$(comm -23 <(printf '%s\n' "$prev") <(printf '%s\n' "$cur") || true)
  if [ -n "$missing" ]; then
    printf 'fail: -maxdepth %s lost entries present at -maxdepth %s:\n' \
      "$k" "$((k - 1))" >&2
    printf '%s\n' "$missing" >&2
    exit 1
  fi
  prev=$cur
done
