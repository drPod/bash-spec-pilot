#!/usr/bin/env bash
# COLD adversarial: -quit stops find immediately; with two start points and
# -print -quit only the first is printed.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/foo" "$tmpdir/bar"

# Documented: "After -quit is executed, no more files specified on the command
# line will be processed. For example, `find /tmp/foo /tmp/bar -print -quit`
# will print only `/tmp/foo`."
got="$("$UTIL" "$tmpdir/foo" "$tmpdir/bar" -print -quit)"
want="$tmpdir/foo"

if [[ "$got" != "$want" ]]; then
  echo "-print -quit should stop after first start point: got [$got] want [$want]" >&2
  exit 1
fi
