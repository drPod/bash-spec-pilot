#!/usr/bin/env bash
# Freeze a utility's man page to utils/<util>/manpage.txt for use as
# stable LLM input.
#
# Usage: scripts/freeze_manpage.sh <util>          # cp | mv | find | sudo
#        scripts/freeze_manpage.sh <util> --force  # overwrite without prompt
#
# Why not `man <util>`? The previous version of this script ran macOS BSD
# `man cp` and froze that. Wrong: this project targets Linux/GNU userland
# (it extends Astrogator to Bash on the systems Aaron's group runs), and BSD
# `cp(1)` documents a different option set than GNU `cp(1)` (no `--reflink`,
# different `-a`/`-p` semantics, different long-option support, etc.). Using
# BSD man pages on a macOS dev box would silently train the LLM against the
# wrong source.
#
# Source choice: manpages.debian.org, pinned to Debian 13 ("trixie", current
# stable as of 2025-08-09). Debian builds the *.gz file from the upstream
# tarball at package-build time, so the content is upstream-faithful but the
# URL is stable, versioned, and addressable. Each fetch records the package
# version under utils/<util>/_source.json so the input is reproducible.
#
# We considered fetching directly from upstream:
#   - GNU coreutils savannah cgit ships only the help2man preamble (cp.x);
#     the actual cp.1 is generated at build time. Reproducing requires
#     building coreutils, which is fragile on macOS.
#   - findutils savannah ships find.1 directly, but for consistency we route
#     all four utilities through Debian.
#   - sudo.ws ships its own tarball, also with .in templates that need
#     configure-time substitution. Same consistency argument.
# Debian's pre-rendered groff source is the deterministic re-runnable source.
#
# Render: mandoc(1) -> col(1) -bx. mandoc ships in macOS base; no Homebrew
# install required. groff is the fallback for Linux dev boxes where mandoc
# isn't installed.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <util> [--force]   util in (cp | mv | find | sudo)" >&2
  exit 2
fi
UTIL="$1"
FORCE="${2:-}"

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DST_DIR="$REPO/utils/$UTIL"

# (util)         (debian package, section, debian-release, package-version-pin)
# Trixie versions resolved 2026-05-07 via sources.debian.org/api.
case "$UTIL" in
  cp)   PKG=coreutils  ; SECTION=1 ; DEB_RELEASE=trixie ; PKG_VERSION="9.7-3"                ;;
  mv)   PKG=coreutils  ; SECTION=1 ; DEB_RELEASE=trixie ; PKG_VERSION="9.7-3"                ;;
  find) PKG=findutils  ; SECTION=1 ; DEB_RELEASE=trixie ; PKG_VERSION="4.10.0-3"             ;;
  sudo) PKG=sudo       ; SECTION=8 ; DEB_RELEASE=trixie ; PKG_VERSION="1.9.16p2-3+deb13u1"   ;;
  *) echo "error: unsupported util '$UTIL' (expected cp|mv|find|sudo)" >&2; exit 2 ;;
esac

URL="https://manpages.debian.org/${DEB_RELEASE}/${PKG}/${UTIL}.${SECTION}.en.gz"

# Pick renderer. mandoc is preferred (no formatting noise, ships with macOS
# base). groff is the fallback. col -bx strips backspace overstrikes that
# both tools emit when -Tutf8/-Tascii is requested for terminal display.
if command -v mandoc >/dev/null 2>&1; then
  RENDERER="mandoc"
elif command -v groff >/dev/null 2>&1; then
  RENDERER="groff"
else
  cat >&2 <<'EOF'
error: neither mandoc nor groff is available on PATH.
  - mandoc ships in macOS base at /usr/bin/mandoc; check that /usr/bin
    is on PATH.
  - On Linux dev boxes:  apt-get install mandoc  (preferred) or
                         apt-get install groff   (fallback)
  - On macOS where the base mandoc is missing for some reason:
                         brew install mandoc
EOF
  exit 3
fi

mkdir -p "$DST_DIR"
DST_GROFF="$DST_DIR/manpage.${SECTION}"
DST_TXT="$DST_DIR/manpage.txt"
DST_META="$DST_DIR/_source.json"

if [[ -e "$DST_TXT" && "$FORCE" != "--force" ]]; then
  echo "$DST_TXT exists. Pass --force to overwrite." >&2
  exit 0
fi

echo "fetching: $URL" >&2
# Debian's CDN auto-decompresses .gz when served as text/plain, so the
# response body is the raw groff source already. -L follows the cgi redirect.
HTTP_CODE=$(curl -sL --fail-with-body \
  -o "$DST_GROFF" \
  -w '%{http_code}' \
  "$URL" || true)

if [[ "$HTTP_CODE" != "200" ]]; then
  echo "error: fetch returned HTTP $HTTP_CODE for $URL" >&2
  exit 4
fi

# Sanity-check: the file should look like groff (.\" comment or '\" t header).
HEAD_BYTE=$(head -c 4 "$DST_GROFF" | od -An -c | tr -d ' \n')
if [[ "$HEAD_BYTE" != ".\\\"D"  && "$HEAD_BYTE" != "'\\\"t" && "$HEAD_BYTE" != ".\\\".\\" && "$HEAD_BYTE" != ".TH"* ]]; then
  # Permissive check; just warn loudly. Some manpages start with .\"<sp> or .TH directly.
  case "$(head -c 8 "$DST_GROFF")" in
    .\\\"*|\'\\\"*|.TH*) : ;;
    *) echo "warning: $DST_GROFF does not look like groff source (head: $(head -c 60 "$DST_GROFF"))" >&2 ;;
  esac
fi

echo "rendering with $RENDERER -> $DST_TXT" >&2
case "$RENDERER" in
  mandoc) mandoc -Tutf8 "$DST_GROFF" | col -bx > "$DST_TXT" ;;
  groff)  groff -man -Tutf8 "$DST_GROFF" | col -bx > "$DST_TXT" ;;
esac

# Write _source.json provenance record.
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
SHA_GROFF=$(shasum -a 256 "$DST_GROFF" | awk '{print $1}')
SHA_TXT=$(shasum -a 256 "$DST_TXT" | awk '{print $1}')
cat > "$DST_META" <<EOF
{
  "util": "$UTIL",
  "source_url": "$URL",
  "debian_release": "$DEB_RELEASE",
  "debian_package": "$PKG",
  "debian_package_version": "$PKG_VERSION",
  "man_section": $SECTION,
  "fetched_at": "$TIMESTAMP",
  "renderer": "$RENDERER",
  "groff_sha256": "$SHA_GROFF",
  "manpage_txt_sha256": "$SHA_TXT"
}
EOF

LINES=$(wc -l <"$DST_TXT" | tr -d ' ')
BYTES=$(wc -c <"$DST_TXT" | tr -d ' ')
echo "wrote $DST_GROFF (groff source, provenance)"
echo "wrote $DST_TXT (LLM input: $LINES lines, $BYTES bytes)"
echo "wrote $DST_META (source metadata)"
