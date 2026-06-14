#!/usr/bin/env bash
# Mirror the POSIX (Open Group Base Specifications) corpus this project compares
# Linux man pages against. Idempotent: re-run to refresh. Default edition Issue 8
# (IEEE Std 1003.1-2024); set POSIX_ISSUE=7 for the 2018 edition.
#
# Mirrors EVERYTHING in the two volumes that bear on CLI-utility semantics:
#   - basedefs/  : all 14 Base Definitions (XBD) chapters (definitions,
#                  conformance, general concepts, environment, regex, ...)
#   - utilities/ : all 3 Shell & Utilities (XCU) front chapters (_chap01..03,
#                  including the Shell Command Language) + every POSIX utility
#                  page (~155), scraped live from idx/utilities.html.
#
# Deliberately NOT mirrored: the System Interfaces (XSH) volume (~1200 C
# function pages). That is the libc layer, not the CLI layer this project
# studies. Add an xsh leg here if that changes.
#
# Output layout mirrors the upstream URL paths. Provenance (per-page sha256 of
# the source HTML, fetch timestamp, edition) lands in _source.json; the flat URL
# list in _urls.txt. Source HTML is stripped of nav chrome, then rendered to
# GitHub markdown with pandoc.
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
STRIP="$REPO_ROOT/scripts/dev/_strip_posix_html.py"

command -v pandoc >/dev/null || { echo "pandoc required (brew install pandoc)" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 required" >&2; exit 1; }

# Friendly slugs for the fixed chapter sets (stable within an edition).
# bash 3.2 on macOS has no associative arrays -> flat "num|slug" lists.
XBD_CHAPTERS=(
  "01|introduction" "02|conformance" "03|definitions" "04|general_concepts"
  "05|file_format_notation" "06|character_set" "07|locale"
  "08|environment_variables" "09|regular_expressions"
  "10|directory_structure_and_devices" "11|general_terminal_interface"
  "12|utility_conventions" "13|namespace_and_future_directions" "14|headers"
)
XCU_CHAPTERS=( "01|introduction" "02|shell_command_language" "03|utilities" )

# Clean previously generated content; keep the hand-written README + provenance.
mkdir -p "$OUT/basedefs" "$OUT/utilities"
find "$OUT" -maxdepth 1 -name '*.md' ! -name 'README.md' -delete 2>/dev/null || true
rm -f "$OUT"/basedefs/*.md "$OUT"/utilities/*.md

FETCHED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
MANIFEST="$(mktemp)"
trap 'rm -f "$MANIFEST"' EXIT
: > "$OUT/_urls.txt"

# fetch <group> <out_relpath> <upstream_relpath>
fetch() {
  local group="$1" outrel="$2" rel="$3"
  local url="$BASE/$rel"
  local html sha
  html="$(curl -fsSL "$url")" || { echo "  ! fetch failed: $url" >&2; return 1; }
  sha="$(printf '%s' "$html" | shasum -a 256 | awk '{print $1}')"
  printf '%s' "$html" | python3 "$STRIP" | pandoc -f html -t gfm --wrap=none > "$OUT/$outrel"
  echo "$url" >> "$OUT/_urls.txt"
  printf '%s\t%s\t%s\t%s\n' "$group" "$outrel" "$rel" "$sha" >> "$MANIFEST"
}

echo "== Base Definitions (XBD) chapters =="
for c in "${XBD_CHAPTERS[@]}"; do
  num="${c%%|*}"; slug="${c##*|}"
  echo "  basedefs/${num}_${slug}"
  fetch "basedefs" "basedefs/${num}_${slug}.md" "basedefs/V1_chap${num}.html"
done

echo "== Shell & Utilities (XCU) chapters =="
for c in "${XCU_CHAPTERS[@]}"; do
  num="${c%%|*}"; slug="${c##*|}"
  echo "  utilities/_chap${num}_${slug}"
  fetch "xcu_chapter" "utilities/_chap${num}_${slug}.md" "utilities/V3_chap${num}.html"
done

echo "== POSIX utility pages (scraped from idx/utilities.html) =="
UTILS="$(curl -fsSL "$BASE/idx/utilities.html" \
  | grep -oiE 'utilities/[a-z0-9_]+\.html' \
  | sed -E 's#utilities/##; s#\.html##' \
  | sort -u | grep -vE '^(contents|index)$')"
N_UTILS="$(printf '%s\n' "$UTILS" | grep -c . || true)"
if [ "$N_UTILS" -lt 100 ]; then
  echo "  ! scrape returned only $N_UTILS utilities (<100) — aborting, not writing a partial mirror" >&2
  exit 1
fi
echo "  $N_UTILS utilities"
for u in $UTILS; do
  fetch "utility" "utilities/${u}.md" "utilities/${u}.html" || true
done

# Assemble provenance JSON from the manifest.
python3 - "$MANIFEST" "$OUT/_source.json" "$EDITION" "$ISSUE" "$BASE" "$FETCHED" <<'PY'
import json, sys
manifest, out, edition, issue, base, fetched = sys.argv[1:7]
pages = []
with open(manifest) as f:
    for line in f:
        group, outrel, rel, sha = line.rstrip("\n").split("\t")
        pages.append({"group": group, "file": outrel, "path": rel,
                      "url": f"{base}/{rel}", "sha256_html": sha})
pages.sort(key=lambda p: (p["group"], p["file"]))
doc = {
    "edition": edition,
    "issue": int(issue),
    "base_url": base,
    "fetched_utc": fetched,
    "renderer": "curl | strip-nav | pandoc -f html -t gfm",
    "not_mirrored": "System Interfaces (XSH) C-function volume — libc layer, out of CLI-utility scope",
    "counts": {
        "basedefs": sum(1 for p in pages if p["group"] == "basedefs"),
        "xcu_chapters": sum(1 for p in pages if p["group"] == "xcu_chapter"),
        "utilities": sum(1 for p in pages if p["group"] == "utility"),
        "total": len(pages),
    },
    "pages": pages,
}
with open(out, "w") as f:
    json.dump(doc, f, indent=2)
    f.write("\n")
print(f"  wrote {len(pages)} page records -> {out}")
PY

echo ""
echo "Mirrored to $OUT  ($EDITION)"
