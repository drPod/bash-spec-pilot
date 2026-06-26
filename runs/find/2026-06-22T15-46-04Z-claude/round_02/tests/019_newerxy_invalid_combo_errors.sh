#!/usr/bin/env bash
# COLD adversarial ERROR: -newerXY with X=t is documented as invalid -> fatal.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

ref="$tmpdir/ref"
: > "$ref"

# Documented: "Some combinations are invalid; for example, it is invalid for X
# to be t. ... If an invalid or unsupported combination of XY is specified, a
# fatal error results."
# -newertm uses X=t, which is invalid -> nonzero exit.
set +e
"$UTIL" "$tmpdir" -newertm "$ref" >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "-newertm (X=t) should be a fatal error, got status 0" >&2
  exit 1
fi
