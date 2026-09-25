# Independent permission-model cross-check

This audit independently inspected the pinned upstream source after the specification-research agent reported a permission discrepancy. It also executes a separate, six-case Ansible probe (`independent_permissions.py`, results `independent-permissions.json`) without relying on that agent's runtime labels.

In `lib/fql/codegen.ml`, `codegen_file_perms` builds owner/group/other permission strings and drops a class entirely when its permission string is empty. Owner-only read/write/directory-list permission therefore yields `u=rwX`, not `u=rwX,g=,o=`. The explicit-empty cases needed to revoke group/other rights are lost.

In `modules/file.type`, the modeled `fs(...).mode` field receives the supplied `mode` string directly (for example lines 97–111 in the pinned source). It does not evaluate that symbolic update against the current permission bits. Consequently, agreement of mode strings in the abstract model does not establish agreement of resulting real permissions. Conversely, numeric `0700` and a complete symbolic form can differ as strings despite achieving the same real mode in these cases.

The runtime probe starts every object at 0777. For directories it applies `0700`, `u=rwX`, and `u=rwX,g=,o=`; for regular files it applies `0700`, `u=rwx`, and `u=rwx,g=,o=`. Incomplete symbolic modes preserve group/other rights; numeric and complete symbolic modes revoke them.

This independently supports the mechanism behind the seven-case runtime/verifier panel in `../adequacy/mode-summary.json`. The verifier panel was produced by the other agent; this cross-check does not claim a second independent verifier implementation or a formal soundness result. An omitted-class codegen patch addresses one defect but does not solve numeric/symbolic normalization, special bits, `X` dependence on file type/prior executable bits, or umask-dependent semantics. Those require a more expressive permission model and additional regression cases.

| Object | Requested mode | Result from 0777 |
|---|---|---|
| Directory | `0700` | `0700` |
| Directory | `u=rwX` | `0777` |
| Directory | `u=rwX,g=,o=` | `0700` |
| File | `0700` | `0700` |
| File | `u=rwx` | `0777` |
| File | `u=rwx,g=,o=` | `0700` |

All six Ansible executions returned success. This difference is semantic, not an execution failure.
