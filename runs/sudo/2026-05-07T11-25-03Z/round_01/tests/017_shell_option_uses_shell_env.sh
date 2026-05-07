#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
shell="$tmpdir/fakeshell"
marker="$tmpdir/shell_used"
out="$tmpdir/shell.out"
err="$tmpdir/shell.err"
cat >"$shell" <<EOF
#!/bin/sh
printf 'used' > "$marker"
exit 0
EOF
chmod +x "$shell"
if ! SHELL="$shell" "$UTIL" -n -s ignored >"$out" 2>"$err"; then
  echo "sudo -s command failed" >&2
  exit 1
fi
if [[ "$(cat "$marker" 2>/dev/null || true)" != "used" ]]; then
  echo "SHELL program was not used by -s" >&2
  exit 1
fi
