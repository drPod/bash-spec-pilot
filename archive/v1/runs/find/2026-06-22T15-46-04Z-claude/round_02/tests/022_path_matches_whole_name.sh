#!/usr/bin/env bash
# COLD adversarial: -path matches the whole name from the start point, and its
# metacharacters do NOT treat "/" specially.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/src/misc"

# Documented: "File name matches shell pattern pattern. The metacharacters do
# not treat `/' or `.' specially; so, for example, find . -path "./sr*sc"
# will print an entry for a directory called ./src/misc (if one exists)."
# Analogously, -path "$tmpdir/sr*sc" must match $tmpdir/src/misc because the
# wildcard spans the slash.
got="$("$UTIL" "$tmpdir" -path "$tmpdir/sr*sc" | LC_ALL=C sort)"
want="$tmpdir/src/misc"

if [[ "$got" != "$want" ]]; then
  echo "-path wildcard-across-slash mismatch: got [$got] want [$want]" >&2
  exit 1
fi
