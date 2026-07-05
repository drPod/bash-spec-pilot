#!/usr/bin/env bash
# Invariant: sudo -u TARGET id -un prints TARGET.
# Manpage backing: utils/sudo/manpage.txt lines 348-357 (`-u user`, runs
# command as target user).
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

target=root
out="$tmpdir/who.out"
err="$tmpdir/who.err"

if ! "$UTIL" -n -u "$target" id -un >"$out" 2>"$err"; then
  echo "sudo -u $target id -un failed: $(cat "$err")" >&2
  exit 1
fi

actual=$(tr -d '[:space:]' <"$out")
if [ "$actual" != "$target" ]; then
  echo "expected id -un = '$target', got '$actual'" >&2
  exit 1
fi
