"""Cross-version panel — replay a finding across pinned coreutils versions."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import streamlit as st

from data import load_crossver

crossver = load_crossver()

st.markdown(
    "A finding is only interesting if it isn't a one-version quirk. Each panel replays the exact "
    "repro against multiple pinned coreutils versions inside the trixie container (native, then "
    "`dpkg --force-downgrade` to snapshot .debs). **version-stable** means every version reproduced "
    "the finding; each version's `--version` is verified before its result is trusted."
)

if not crossver:
    st.info("No cross-version replay recorded. Run `scripts/eval/crossver_mv_strip_slash.sh`.")
    st.stop()

for res in crossver:
    with st.container(border=True):
        head = st.columns([3, 1])
        with head[0]:
            st.markdown(f"**`{res['util']}` — {res['ts']}**")
        with head[1]:
            if res.get("version_stable"):
                st.success("version-stable")
            else:
                st.warning("version-specific")

        st.markdown(f"**Finding:** {res.get('finding', '')}")
        st.markdown("**Repro:**")
        st.code(res.get("repro", ""))

        versions = res.get("versions") or []
        with st.container(horizontal=True):
            for v in versions:
                ok = v.get("reproduces_finding")
                st.metric(
                    f"coreutils {v.get('pinned_version')}",
                    "reproduces" if ok else "no repro",
                    delta="verified" if v.get("version_verified") else "UNVERIFIED",
                    delta_color="normal" if v.get("version_verified") else "inverse",
                    border=True,
                )

        st.dataframe(
            [
                {
                    "pinned": v.get("pinned_version"),
                    "reported": v.get("reported_version"),
                    "rc": v.get("rc"),
                    "reproduces": v.get("reproduces_finding"),
                    "verified": v.get("version_verified"),
                    "stderr": v.get("stderr_head"),
                }
                for v in versions
            ],
            hide_index=True,
            width="stretch",
        )
        st.caption(
            f"arch: `{res.get('container_arch', '?')}` · "
            f"all verified: `{res.get('all_versions_verified')}`"
        )
