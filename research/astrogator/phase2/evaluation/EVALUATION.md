# Evaluation corrected for coverage, task mix, and conditional verification

This is a reanalysis of the frozen 422-program, four-task development study, not new paper-wide accuracy evidence. All rates use the original local checks; new oracle observations are reported separately. Verifier mode: pinned upstream default permission semantics; heuristic flags define the separate named arm.

| Method | Decisions / 422 | Failed among accepted | Failures rejected / 139 | Failing programs unavailable | Passing programs rejected / 283 |
|---|---:|---:|---:|---:|---:|
| astrogator | 348 | 9 / 291 | 56 | 74 | 1 |
| astrogator_configured_heuristics | 348 | 0 / 277 | 65 | 74 | 6 |
| Qwen 2.5 1.5B judge | 422 | 129 / 399 | 10 | 0 | 13 |
| generated_checks_gated | 0 | 0 / 0 | 0 | 139 | 0 |
| always_accept | 422 | 139 / 422 | 0 | 0 | 0 |
| base_then_judge_on_abstention | 422 | 77 / 359 | 62 | 0 | 1 |
| heuristics_then_judge_on_abstention | 422 | 68 / 345 | 71 | 0 | 6 |

## What changes the interpretation

The 74 verifier-unavailable programs all fail the local checks. Counting only decided programs hides this concentration: base verification rejects 56/139 failures, and configured heuristics reject 65/139. Blocking unavailable programs is a valid deployment policy, but is not evidence that the verifier proved them incorrect.

The fallback policies use the already-recorded judge only when the verifier abstains; they are deterministic retrospective compositions. They expose whether extra decision coverage introduces accepted failures. No new inference calls or tuned thresholds are involved.

All 110 a01 programs pass locally. Per-task tables, task-macro rates, and leave-one-task-out results are in analysis.json. Failure recall is undefined on a01 and is excluded, explicitly, from that macro average.

The 2,000 paired bootstrap replicates resample the eleven generator-model clusters, retaining all programs from each sampled model. These descriptive intervals concern this fixed four-task suite. Four selected tasks cannot support a credible generalization interval over Ansible workloads; no significance claim is made.

Configured heuristics additionally reject five Debian-local passes using www-data, which upstream metadata does not assume exists on RedHat. Those are environment-scope disagreements, not demonstrated false alarms. The remaining rejected local pass has a malformed shadow entry and is under revised-oracle review.

## Residual reporting

All 909 accepted corpus records have printable unification output. See residual-audit.jsonl for initial differences, constraints, and final differences per printed branch. Their presence does not establish whether obligations are discharged. Treating VERIFIED as unconditional correctness is unsupported.

## Reproduction

`python3 research/astrogator/phase2/evaluation/analyze.py`

Inputs are byte-hashed in analysis.json. The source study is not modified.
