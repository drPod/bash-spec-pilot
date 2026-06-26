#!/usr/bin/env bash
# -g group: "The group may be either a group name or a numeric group-ID (GID)
# prefixed with the '#' character (e.g., '#0' for GID 0)." plus "In either
# case, the primary group will be set to group."  Group 0 is the target (root)
# user's own group, which the sudoers policy permits ("any of the target
# user's groups ... as long as the -P option is not in use"; -P is not used
# here).  Running '-g #0' must set the primary group to GID 0 (`id -g`).
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

out="$("$UTIL" -n -g '#0' id -g)"
if [[ "$out" == "0" ]]; then
    exit 0
fi
echo "FAIL: '-g #0 id -g' reported '$out'; #0 must set primary group to GID 0" >&2
exit 1
