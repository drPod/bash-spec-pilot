#!/usr/bin/env bash
# Invariant: for filenames containing no NUL or newline characters,
# `-print0` emits the same set of paths as the default `-print`, only
# delimited by NUL instead of newline.
#
# Manpage backing: utils/find/manpage.txt lines 1009-1024. -print: "print
# the full file name on the standard output, followed by a newline".
# -print0: "print the full file name on the standard output, followed by a
# null character (instead of the newline character that -print uses)".
#
# Bug class (taxonomy.md): Hallucinated Object / Wrong Attribute — impls
# that build -print0 output via a different codepath (e.g. forget to emit
# the starting-point, or use a different field separator inside paths)
# would diverge from -print on a vanilla tree.

set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/d"
touch "$tmpdir/d/file1" "$tmpdir/d/file2" "$tmpdir/d/file3"

print_out=$("$UTIL" "$tmpdir" -print | sort)
# Translate NULs to newlines for comparison; safe because filenames here
# contain neither NUL nor newline.
print0_out=$("$UTIL" "$tmpdir" -print0 | tr '\0' '\n' | sort)

if [ "$print_out" != "$print0_out" ]; then
  printf 'fail: -print and -print0 disagree on a NUL/newline-free tree\n' >&2
  diff <(printf '%s\n' "$print_out") <(printf '%s\n' "$print0_out") >&2 || true
  exit 1
fi
