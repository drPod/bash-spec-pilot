#!/usr/bin/env bash
# COLD adversarial ERROR: a starting point that cannot be examined is an error;
# find exits nonzero.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

missing="$tmpdir/does_not_exist"

# Documented (EXIT STATUS): "find exits with status 0 if all files are
# processed successfully, greater than 0 if errors occur." A nonexistent
# starting point cannot be processed successfully.
set +e
"$UTIL" "$missing" >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "nonexistent start path should be an error, got status 0" >&2
  exit 1
fi
