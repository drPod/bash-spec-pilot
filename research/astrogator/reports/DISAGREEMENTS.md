# Cases for specification and oracle review

These cases were found in the in-progress four-task slice. They are selected for
inspection, not a random accuracy estimate. IDs identify byte-preserved processed
programs in `data/manifest.jsonl`; execution traces are in
`experiments/four-task-full-v1/execution.jsonl`, and full residuals are in
`corpus-verifier.jsonl`.

| Sample | Observation | Review question |
|---|---|---|
| gpt-5-mini/p10/7 | Uses `password: '*'` with `update_password: on_create`. Existing unlocked user fails the local password-lock check; already-locked user passes. Base verifier accepts. | Does the user model account for `on_create` on an existing account, and what residual obligations remain? |
| gpt-oss/p10/2 | Also uses `on_create`, and sets `/sbin/nologin`. Local password-hash check fails for the unlocked user. Base verifier accepts. | Does “disable password” mean locking the hash, preventing interactive login, or both? The oracle and specification must agree. |
| gpt-oss/p10/6 | Only changes the login shell. Same local disagreement as above. | Is changing the shell an accepted implementation under the original benchmark's intended semantics? |
| granite/p13/7 | Copies `beginning` unconditionally. Baseline passes, existing-content scenario fails. Base verifier accepts. | Does the query/model retain the conditional creation obligation, or leave the extra overwrite effect for residual review? |
| granite/p10/4 | Replaces the shadow entry with a malformed-looking multi-field line. The local oracle sees an existing user and a locked hash prefix, so passes; base verifier rejects. | The oracle does not validate all shadow fields or account-database integrity. Passing it must not be reported as universal correctness or as a demonstrated verifier false rejection. |

The password cases expose two separate issues: differing interpretations of the
request and a narrow local oracle. Keep the frozen run unchanged so its results
remain reproducible. A revised oracle belongs in a new version with explicitly
reviewed requirements; do not selectively relabel only the disagreement cases.

The password fixture uses the placeholder string `$6$salt$hash`, with or without
a leading lock marker. This exercises marker transitions, not a demonstrated
successful password authentication before the playbook. Authentication-level claims
would require a suitable fixture and an additional behavioral check.

## Configured heuristics and environment scope

The completed heuristic arm rejects all nine base-verifier accepts that fail the
local checks, but also rejects five additional local passes: deepseek/p01/7,
granite/p01/8, and qwen2.5-coder/p01/{0,4,6}. Each assigns owner or group `www-data`.
The pinned `heuristics/users.txt` and `groups.txt` include `www-data` for Debian and
Ubuntu, but not RedHat. The playbooks are unconditional across these systems.
Thus these are concrete environment-scope disagreements with our Debian-only run,
not demonstrated false rejections. The sixth rejected local pass is the malformed
shadow-entry example already rejected by the base verifier.

The configured arm rejects 183 of the base verifier's 909 accepted processed
programs across the complete corpus; 726 remain accepted with possible residuals.
The 619 base verification rejections and 710 Ansible-lowering errors are unchanged.
