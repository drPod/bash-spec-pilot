#!/usr/bin/env bash
# Mirror the POSIX (Open Group Base Specifications) pages this project compares
# man pages against. Idempotent: re-run to refresh. Default edition Issue 8
# (IEEE Std 1003.1-2024); set POSIX_ISSUE=7 for the 2018 edition.
#
# Output: docs/posix/<name>.md  + _source.json (provenance, per-page sha256 of
# the source HTML) + _urls.txt. Source HTML is stripped of nav chrome, then
# rendered to GitHub markdown with pandoc.
set -euo pipefail

ISSUE="${POSIX_ISSUE:-8}"
case "$ISSUE" in
  8) PUBNUM=9799919799; EDITION="Issue 8 / IEEE Std 1003.1-2024" ;;
  7) PUBNUM=9699919799; EDITION="Issue 7 / IEEE Std 1003.1-2017 (2018 edition)" ;;
  *) echo "unknown POSIX_ISSUE=$ISSUE (use 7 or 8)" >&2; exit 1 ;;
esac

BASE="https://pubs.opengroup.org/onlinepubs/${PUBNUM}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$REPO_ROOT/docs/posix"
mkdir -p "$OUT"

command -v pandoc >/dev/null || { echo "pandoc required (brew install pandoc)" >&2; exit 1; }

# name | relative URL path on pubs.opengroup.org
PAGES=(
  "cp|utilities/cp.html"
  "mv|utilities/mv.html"
  "find|utilities/find.html"
  "general_concepts|basedefs/V1_chap04.html"
  "utility_conventions|basedefs/V1_chap12.html"
  "shell_utilities_intro|utilities/V3_chap01.html"
)

FETCHED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
: > "$OUT/_urls.txt"
SRC_ENTRIES=()

for entry in "${PAGES[@]}"; do
  name="${entry%%|*}"
  rel="${entry##*|}"
  url="$BASE/$rel"
  echo "→ $name  ($url)"

  html="$(curl -fsSL "$url")"
  sha="$(printf '%s' "$html" | shasum -a 256 | awk '{print $1}')"

  # Strip nav chrome + scripts, then HTML → markdown.
  printf '%s' "$html" \
    | python3 "$REPO_ROOT/scripts/dev/_strip_posix_html.py" \
    | pandoc -f html -t gfm --wrap=none \
    > "$OUT/$name.md"

  echo "$url" >> "$OUT/_urls.txt"
  SRC_ENTRIES+=("$name|$rel|$url|$sha")
done

# Provenance JSON (mirrors utils/<util>/_source.json shape).
{
  printf '{\n'
  printf '  "edition": "%s",\n' "$EDITION"
  printf '  "issue": %s,\n' "$ISSUE"
  printf '  "base_url": "%s",\n' "$BASE"
  printf '  "fetched_utc": "%s",\n' "$FETCHED"
  printf '  "renderer": "curl | strip-nav | pandoc -f html -t gfm",\n'
  printf '  "pages": [\n'
  last=$(( ${#SRC_ENTRIES[@]} - 1 ))
  for i in "${!SRC_ENTRIES[@]}"; do
    IFS='|' read -r n rel url sha <<< "${SRC_ENTRIES[$i]}"
    sep=","; [ "$i" -eq "$last" ] && sep=""
    printf '    {"name": "%s", "file": "%s.md", "path": "%s", "url": "%s", "sha256_html": "%s"}%s\n' \
      "$n" "$n" "$rel" "$url" "$sha" "$sep"
  done
  printf '  ]\n}\n'
} > "$OUT/_source.json"

echo ""
echo "Mirrored ${#PAGES[@]} pages → $OUT  ($EDITION)"
