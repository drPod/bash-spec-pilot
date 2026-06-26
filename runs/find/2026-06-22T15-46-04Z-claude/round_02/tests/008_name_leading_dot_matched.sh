#!/usr/bin/env bash
# COLD adversarial: a glob metacharacter matches a leading dot (PASC interp 126).
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/.hidden"

# Documented (STANDARDS CONFORMANCE / COMPATIBILITY): "As of findutils-4.2.2,
# shell metacharacters (`*', `?' or `[]' for example) match a leading `.',
# because IEEE PASC interpretation 126 requires this."
# So -name '*' must match the file ".hidden".
got="$("$UTIL" "$tmpdir" -name '*hidden' | LC_ALL=C sort)"
want="$tmpdir/.hidden"

if [[ "$got" != "$want" ]]; then
  echo "-name glob should match leading dot: got [$got] want [$want]" >&2
  exit 1
fi
