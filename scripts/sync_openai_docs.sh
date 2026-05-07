#!/usr/bin/env bash
# Refresh docs/openai/ from the installed openai-python SDK source.
# Idempotent. Run from the repo root.
#
# What this does:
#   1. Pin the installed SDK version + GitHub commit SHA into _pin.txt.
#   2. Dump inspect.signature(Responses.create) to _responses_create_signature.txt.
#   3. Leaves the hand-written .md files alone (they reference the
#      installed source paths and are accurate as long as the pin is the
#      same version they were authored for; bump = re-derive by reading
#      the SDK).
#
# Re-derivation policy: if the pinned version changes, regenerate the .md
# files by re-reading the type files listed at the top of each .md.

set -euo pipefail

cd "$(dirname "$0")/.."
DOCS_DIR="docs/openai"
mkdir -p "$DOCS_DIR"

VERSION=$(uv run python -c "import openai; print(openai.__version__)")
INSTALL_PATH=$(uv run python -c "import openai, os; print(os.path.dirname(openai.__file__))")
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Look up the GitHub SHA for the version tag.
SHA=$(git ls-remote --tags https://github.com/openai/openai-python "v${VERSION}" \
        | awk '{print $1}' | head -n1)
[ -z "$SHA" ] && SHA="(no tag found for v${VERSION})"

cat > "${DOCS_DIR}/_pin.txt" <<EOF
openai-python pin (ground truth source for docs/openai/)
=========================================================

Installed SDK version : ${VERSION}
GitHub repository     : https://github.com/openai/openai-python
GitHub tag            : v${VERSION}
GitHub commit SHA     : ${SHA}
Local install path    : ${INSTALL_PATH}
Fetched at (UTC)      : ${TS}

How this pin was determined:
    uv run python -c "import openai; print(openai.__version__)"
    git ls-remote --tags https://github.com/openai/openai-python v${VERSION}

All other files in this directory were derived by reading the installed
SDK Python source directly (no WebFetch, no paraphrase from memory).
EOF

uv run python - <<'PY' > "${DOCS_DIR}/_responses_create_signature.txt"
from openai.resources.responses import Responses
import inspect
print(inspect.signature(Responses.create))
PY

echo "Refreshed ${DOCS_DIR}/_pin.txt and ${DOCS_DIR}/_responses_create_signature.txt"
echo "Hand-authored .md files unchanged (they cite installed source paths)."
