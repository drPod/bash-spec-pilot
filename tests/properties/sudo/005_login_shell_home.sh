#!/usr/bin/env bash
# Invariant: sudo -u TARGET -i <cmd> resolves $HOME to TARGET's home
# directory (from passwd db).
# Manpage backing: utils/sudo/manpage.txt lines 185-202 (`-i, --login`:
# runs login shell, sudo attempts to chdir to that user's home, environment
# resembles a fresh login) and lines 563-568 (HOME set to target user's
# home dir under -i).
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

target=root
expected_home=$(getent passwd "$target" | cut -d: -f6)
if [ -z "$expected_home" ]; then
  echo "could not look up home dir for $target via getent" >&2
  exit 1
fi

out="$tmpdir/home.out"
err="$tmpdir/home.err"

# Use single-quoted argument so the parent shell does not expand $HOME;
# the inner bash -c must see the child's HOME.
if ! "$UTIL" -n -u "$target" -i bash -c 'echo "$HOME"' >"$out" 2>"$err"; then
  echo "sudo -u $target -i bash -c failed: $(cat "$err")" >&2
  exit 1
fi

actual=$(tr -d '[:space:]' <"$out")
if [ "$actual" != "$expected_home" ]; then
  echo "expected HOME='$expected_home' under -i, got '$actual'" >&2
  exit 1
fi
