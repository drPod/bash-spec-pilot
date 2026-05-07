#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
if ! actual=$("$UTIL" -D help 2>&1); then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ "$actual" != *exec* ]]; then
  echo "-D help output did not mention the exec debug option" >&2
  exit 1
fi
