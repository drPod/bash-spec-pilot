#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
real="$tmpdir/realfile"
link="$tmpdir/linkfile"
printf 'data\n' >"$real"
ln -s "$real" "$link"
set +e
SUDO_EDITOR=/bin/true "$UTIL" -n -e "$link" >"$tmpdir/symlink.out" 2>"$tmpdir/symlink.err"
status=$?
set -e
if [[ $status -eq 0 ]]; then
  echo "sudoedit of symbolic link unexpectedly succeeded" >&2
  exit 1
fi
