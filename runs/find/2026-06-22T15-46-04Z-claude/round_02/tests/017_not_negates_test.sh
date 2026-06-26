#!/usr/bin/env bash
# COLD adversarial: ! / -not negates a test (true iff expr is false).
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir "$tmpdir/adir"
: > "$tmpdir/afile"

# Documented: "! expr  True if expr is false." and "-not expr  Same as ! expr".
# Among the children, "not a directory" selects only the regular file.
got="$("$UTIL" "$tmpdir" -mindepth 1 ! -type d | LC_ALL=C sort)"
want="$tmpdir/afile"

if [[ "$got" != "$want" ]]; then
  echo "! -type d negation mismatch: got [$got] want [$want]" >&2
  exit 1
fi
