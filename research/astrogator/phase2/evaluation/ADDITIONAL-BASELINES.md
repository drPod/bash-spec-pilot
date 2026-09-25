# Conventional-tool baseline and metadata-scope ablation

Native syntax-check complete: True; Debian-metadata ablation complete: True.

Ansible syntax-check uses the same processed programs and lab image, with four reference controls. Passing means only that this conventional check accepted the playbook. Verifier mode is pinned upstream default permission semantics. The second arm changes only heuristic metadata scope from all supplied distributions to Debian rows; it does not remove OS branches from verification.

| Label variant | Method | Accept pass | Accept fail | Reject pass | Reject fail | Unavailable |
|---|---|---:|---:|---:|---:|---:|
| original | astrogator | 282 | 9 | 1 | 56 | 74 |
| original | astrogator_configured_heuristics | 277 | 0 | 6 | 65 | 74 |
| original | judge | 270 | 129 | 13 | 10 | 0 |
| original | native_syntax | 283 | 133 | 0 | 6 | 0 |
| original | debian_metadata_heuristics | 282 | 0 | 1 | 65 | 74 |
| strict_integrity | astrogator | 282 | 9 | 0 | 57 | 74 |
| strict_integrity | astrogator_configured_heuristics | 277 | 0 | 5 | 66 | 74 |
| strict_integrity | judge | 269 | 130 | 13 | 10 | 0 |
| strict_integrity | native_syntax | 282 | 134 | 0 | 6 | 0 |
| strict_integrity | debian_metadata_heuristics | 282 | 0 | 0 | 66 | 74 |
| newline_sensitivity | astrogator | 282 | 9 | 7 | 50 | 74 |
| newline_sensitivity | astrogator_configured_heuristics | 277 | 0 | 12 | 59 | 74 |
| newline_sensitivity | judge | 277 | 122 | 13 | 10 | 0 |
| newline_sensitivity | native_syntax | 290 | 126 | 0 | 6 | 0 |
| newline_sensitivity | debian_metadata_heuristics | 282 | 0 | 7 | 59 | 74 |

Metadata-only changes: 5. Identities and directions are in additional-baselines.json.
