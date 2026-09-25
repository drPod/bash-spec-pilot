# Whole-task oracle sensitivity

Complete: True. Cases: 410/410; four reference controls.

All processed programs from a06 and a17 were selected before execution. The original observations remain unchanged. New a17 fixtures use a real SHA-512 crypt hash, establish a matching password before the baseline execution, and test both an unlocked and already-locked account.

The strengthened password check requires exactly one service shadow record with nine fields, one passwd record with seven fields, numeric-or-empty aging fields, an empty reserved field, an existing user, and a lock marker. These are declared conservative fixture constraints, not a complete validator of every permitted system configuration. The shadow manual describes the nine-field format and distinguishes disabling UNIX-password login from other authentication methods. [shadow(5)](https://man7.org/linux/man-pages/man5/shadow.5.html). This check does not establish full PAM/SSH authentication behavior.

a06 records exact bytes and separately allows one final newline when creating the new file. Preservation of the existing file remains exact. This alternative makes the interpretation sensitivity visible.

| Variant | Original pass → new fail | Original fail → new pass |
|---|---:|---:|
| new_fixture_old_oracle | 0 | 0 |
| strict_integrity | 1 | 0 |
| newline_sensitivity | 1 | 8 |

Changed sample identities, paired method tables, input hashes, and complete per-case observations are included in revised-summary.json and revised-execution.jsonl. No selectively relabeled disagreement is substituted into the original report.
