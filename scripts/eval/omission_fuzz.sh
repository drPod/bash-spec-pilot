#!/usr/bin/env bash
# Omission-fuzz: surface the behavior classes a man page is SILENT on.
#
# The man page's dominant failure as a spec source is omission, not falsehood
# (see runs/_posix_divergence_catalog_2026-06-26.md and docs/research/taxonomy.md
# § 6). Every utility HAS an exit status, routes diagnostics to some stream, and
# continues-or-aborts on per-operand error. A spec-extractor can only recover
# these if the page names them. This sweep checks, per frozen man page, whether
# the page documents each M-blind class -- so the omissions become a matrix
# instead of a per-util anecdote.
#
# Deterministic, host-runnable, no Docker, no network: it reads the frozen
# utils/<u>/manpage.txt only. The companion behavioral half (probe the real
# binary to confirm the omitted behavior exists) lives in the adjudication
# scripts; this tool reports the documentation gap, which is the spec-extraction
# hazard regardless of what the binary does.
#
# Usage:
#   scripts/eval/omission_fuzz.sh                # sweep every frozen util
#   scripts/eval/omission_fuzz.sh cp wc printf   # sweep named utils
#   scripts/eval/omission_fuzz.sh --self-check   # assert known ground truth
#
# ceiling: documentation-presence proxy via grep. To upgrade to a true B-vs-M
# omission confirmation, pair each SILENT cell with a trixie probe that shows the
# behavior is real -- the adjudication scripts already do this ad hoc; fold them
# in here if the matrix needs binary backing per cell.

set -uo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"

# Does the frozen page document this behavior class? Returns 0 (documented) / 1.
has_exit_status() { grep -qiE '(^|[[:space:]])(EXIT STATUS|RETURN VALUE)|exit (status|code)|return value' "$1"; }
names_stderr()    { grep -qiE 'standard error|stderr' "$1"; }
names_stdout()    { grep -qiE 'standard output|stdout' "$1"; }

cell() { if "$1" "$2"; then printf 'documented'; else printf 'SILENT'; fi; }

sweep() {
  local utils=("$@") u page
  printf '%-10s %-12s %-10s %-10s\n' "util" "exit-status" "stderr" "stdout"
  printf '%-10s %-12s %-10s %-10s\n' "----" "-----------" "------" "------"
  local n=0 sil_exit=0 sil_err=0
  for u in "${utils[@]}"; do
    page="$REPO/utils/$u/manpage.txt"
    [[ -f "$page" ]] || { printf '%-10s (no frozen manpage)\n' "$u"; continue; }
    n=$((n+1))
    has_exit_status "$page" || sil_exit=$((sil_exit+1))
    names_stderr "$page"    || sil_err=$((sil_err+1))
    printf '%-10s %-12s %-10s %-10s\n' "$u" \
      "$(cell has_exit_status "$page")" \
      "$(cell names_stderr "$page")" \
      "$(cell names_stdout "$page")"
  done
  echo
  printf 'omission rate: exit-status %d/%d silent, stderr %d/%d silent\n' \
    "$sil_exit" "$n" "$sil_err" "$n"
}

self_check() {
  # Ground truth from the catalog: find documents exit status; cp does not;
  # most coreutils pages never name "standard error".
  local fail=0
  has_exit_status "$REPO/utils/find/manpage.txt" || { echo "FAIL: find should document exit status"; fail=1; }
  has_exit_status "$REPO/utils/cp/manpage.txt"   && { echo "FAIL: cp should be SILENT on exit status"; fail=1; }
  names_stderr   "$REPO/utils/cp/manpage.txt"    && { echo "FAIL: cp should not name standard error"; fail=1; }
  [[ $fail -eq 0 ]] && echo "self-check OK" || exit 1
}

if [[ "${1:-}" == "--self-check" ]]; then
  self_check
  exit 0
fi

if [[ $# -gt 0 ]]; then
  sweep "$@"
else
  all=()  # portable (macOS bash 3.2 has no mapfile)
  for d in "$REPO"/utils/*/; do [[ -f "$d/manpage.txt" ]] && all+=("$(basename "$d")"); done
  sweep "${all[@]}"
fi
