#!/usr/bin/env bash
# Hard-wrap README.md prose at 100 cols. Idempotent.
set -euo pipefail
cd "$(dirname "$0")/.."
uv run mdformat --wrap 100 README.md
