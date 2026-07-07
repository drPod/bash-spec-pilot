#!/usr/bin/env bash
# COLD adversarial equivalence: -iname is case-insensitive vs -name case-sensitive.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/Foo"

# Documented: "Like -name, but the match is case insensitive. For example,
# the patterns `fo*' and `F??' match the file names `Foo', `FOO', `foo',
# `fOo', etc."
got="$("$UTIL" "$tmpdir" -iname 'fo*' | LC_ALL=C sort)"
want="$tmpdir/Foo"

if [[ "$got" != "$want" ]]; then
  echo "-iname case-insensitive mismatch: got [$got] want [$want]" >&2
  exit 1
fi
