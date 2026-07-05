#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
editor="$tmpdir/editor.sh"
target="$tmpdir/newfile"
cat >"$editor" <<'EOS'
#!/bin/sh
printf 'created\n' > "$1"
EOS
chmod +x "$editor"
set +e
SUDO_EDITOR="$editor" "$UTIL" -n -e "$target" >"$tmpdir/sudoedit.out" 2>"$tmpdir/sudoedit.err"
set -e
if [[ "$(cat "$target" 2>/dev/null || true)" != "created" ]]; then
  echo "sudoedit did not create file with edited contents" >&2
  exit 1
fi
