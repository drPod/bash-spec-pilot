# A valid generated query changes the deletion target

The supplied request is **“Delete the contents of the /home/mydata/web directory.”** We interpret contents deletion as preserving the containing directory, consistent with the supplied query's `delete_files/in_path` semantics. This interpretation is stated explicitly in the frozen diagnostic; it is not silently inferred from a new oracle.

The compact-guide GPT translation, in all three repetitions, is:

```text
delete contents of directory at /home/mydata/web
```

The original FQL parser and semantic analyzer accept it. Its actual normalized semantic AST is **`delete_directory`**, whereas the supplied `delete files in /home/mydata/web` becomes **`delete_files` within the path**. The implementation explains why: `lib/fql/semant.ml:478–500` chooses the last description token (`directory`), and an explicit `at` path bypasses checking the preceding description words (`contents of`). This is a demonstrated interpretation mismatch, not merely a query-format error.

On the 110 processed a03 programs, that query causes 43 supplied-reject → generated-accept transitions and 13 supplied-accept → generated-reject transitions. These are paired decisions, not accuracy estimates. The source-handbook translations use `delete files in "/home/mydata/web"`, restore the supplied semantic target, and remove those disagreements.

We selected `deepseek/p15/0` after observing the disagreement and froze two diagnostic fixtures before execution. Its actual processed playbook uses:

```yaml
ansible.builtin.file:
  path: /home/mydata/web/
  state: absent
```

The original verifier accepts this program against the compact generated query and rejects it against the supplied query. All six handbook outputs—two models and three repetitions—also reject the same program. Actual Ansible 2.19.11 execution exits successfully in both an initially empty directory and a directory containing visible, hidden, and nested files. **In both cases the directory itself is gone.** Thus a successful execution satisfies the accidentally generated directory-deletion target while violating the explicitly stated contents-only obligation.

The verifier acceptance remains conditional. Its branches require the initial path to be a directory with arbitrary contents, an unconstrained hostname, and permission to become root. Both fixtures establish the directory; the pinned image is Debian and runs as UID 0, and Ansible's `become` succeeds. These observations support the Debian branch's relevant assumptions. They are an operational correspondence check, not a proof of the verifier's entire abstraction.

This is one deliberately selected mechanism counterexample with two initial states. It does not label all 110 programs, establish an unbiased error rate, or prove that all handbook translations preserve user intent.

Evidence: `a03-runtime-frozen.json` records obligations, fixture contents, exact candidate/query hashes and limits; `a03-runtime-results.json` retains stdout, exit codes and before/after state; `a03-mechanism.json` joins the actual ASTs, full verifier residuals, all six handbook decisions and source hash. The container had no network, 384 MB memory, half a CPU and a 96-process limit; candidate code never ran on the host.
