#!/usr/bin/env bash
# Invariant: `find $d -type f` enumerates exactly the regular files reachable
# from $d, matching an independent shell-based recursive walk.
#
# Manpage backing: utils/find/manpage.txt lines 779-790 (-type c, with `f`
# = "regular file") combined with the SYNOPSIS/DESCRIPTION lines 7-17
# stating find evaluates the expression against every file in the rooted
# tree.
#
# Bug class (taxonomy.md): Hallucinated Object / Missing Corner Case —
# impls that miscount due to skipping hidden files, skipping the
# starting-point, or mis-classifying entries (symlinks as regular files).

set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Build a tree of regular files plus directories and a symlink (which must
# NOT count as a regular file under default -P semantics).
mkdir -p "$tmpdir/a/b" "$tmpdir/c"
touch "$tmpdir/x" "$tmpdir/a/y" "$tmpdir/a/b/z" "$tmpdir/c/w"
ln -s "$tmpdir/x" "$tmpdir/c/link_to_x"

# Independent oracle: count regular non-symlink files via a breadth-first walk
# that does not shell out to `find`. Uses Bash arrays as the queue (not POSIX
# sh), matching this script's bash shebang. The three globs cover normal,
# single-dot-hidden, and double-dot-hidden (`..foo`) names; non-matching globs
# stay literal and are filtered by the existence guard below.
expected=0
queue=("$tmpdir")
while [ "${#queue[@]}" -gt 0 ]; do
  d=${queue[0]}
  queue=("${queue[@]:1}")
  for entry in "$d"/* "$d"/.[!.]* "$d"/..?*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    if [ -L "$entry" ]; then
      continue
    elif [ -d "$entry" ]; then
      queue+=("$entry")
    elif [ -f "$entry" ]; then
      expected=$((expected + 1))
    fi
  done
done

actual=$("$UTIL" "$tmpdir" -type f | wc -l | tr -d '[:space:]')

if [ "$actual" != "$expected" ]; then
  printf 'fail: find -type f count=%s, manual walk count=%s\n' \
    "$actual" "$expected" >&2
  "$UTIL" "$tmpdir" -type f >&2
  exit 1
fi
