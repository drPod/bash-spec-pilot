#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/root"
: > "$tmpdir/root/victim"
if ! "$UTIL" "$tmpdir/root" -name victim -delete; then
  echo "find invocation failed" >&2
  exit 1
fi
if [[ -e "$tmpdir/root/victim" ]]; then
  echo "-delete did not remove the matched file" >&2
  exit 1
fi
