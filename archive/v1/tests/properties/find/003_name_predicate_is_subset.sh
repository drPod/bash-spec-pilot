#!/usr/bin/env bash
# Invariant: adding a `-name` predicate to a `-type f` query produces a
# subset of the unrestricted `-type f` result. Predicates restrict; they
# never introduce new matches.
#
# Manpage backing: utils/find/manpage.txt lines 601-606 (-name pattern:
# "Base of file name ... matches shell pattern pattern") combined with the
# DESCRIPTION (lines 10-13) explaining that expressions filter the tree.
#
# Bug class (taxonomy.md): Misinterpretation — impls that mis-handle the
# `*` glob (e.g. matching path components instead of base name) can
# introduce names absent from the unfiltered set.

set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/dir.x"
touch "$tmpdir/a.x" "$tmpdir/b.y" "$tmpdir/dir.x/c.x" "$tmpdir/dir.x/d.z"

unrestricted=$("$UTIL" "$tmpdir" -type f | sort)
filtered=$("$UTIL" "$tmpdir" -type f -name '*.x' | sort)

# Sanity: the filtered set must be non-empty (a.x and dir.x/c.x both qualify).
# Run this BEFORE the subset check so an empty `filtered` doesn't feed
# `comm` an empty stdin (which would be a vacuous subset).
if [ -z "$filtered" ]; then
  printf 'fail: -name "*.x" returned no results; expected at least 2\n' >&2
  exit 1
fi

# Every line in `filtered` must appear in `unrestricted`.
extras=$(comm -23 <(printf '%s\n' "$filtered") <(printf '%s\n' "$unrestricted") || true)

if [ -n "$extras" ]; then
  printf 'fail: -name "*.x" emitted paths absent from unrestricted -type f:\n' >&2
  printf '%s\n' "$extras" >&2
  exit 1
fi
