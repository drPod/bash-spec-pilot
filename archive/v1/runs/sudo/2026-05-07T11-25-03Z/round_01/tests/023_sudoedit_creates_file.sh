#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
editor="$tmpdir/editor"
target="$tmpdir/newfile.txt"
out="$tmpdir/edit.out"
err="$tmpdir/edit.err"
cat >"$editor" <<'EOS'
#!/bin/sh
printf 'edited\n' > "$1"
exit 0
EOS
chmod +x "$editor"
if ! SUDO_EDITOR="$editor" "$UTIL" -n -e "$target" >"$out" 2>"$err"; then
  echo "sudo -e failed to create file" >&2
  exit 1
fi
if [[ "$(cat "$target" 2>/dev/null || true)" != "edited" ]]; then
  echo "sudoedit did not install edited content" >&2
  exit 1
fi
