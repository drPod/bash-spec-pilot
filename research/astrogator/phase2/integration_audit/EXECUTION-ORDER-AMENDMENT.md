# Launcher recovery and execution-order amendment

At 14:22 UTC, host process-cap exhaustion made a polling `systemctl` fork fail with `BlockingIOError`. The original launchers also treated failed/inactive dependencies as completion, allowing the downstream Python finalizer to run before inputs existed. No model prediction or execution outcome motivated this change.

Launcher-only `orchestration.py` now retries process-creation EAGAIN, requires successful dependency termination, and checks retained journal success if systemd has collected a transient unit. Seven mocked regression tests cover resource exhaustion, dependency failure, successful exit, and collected-unit provenance.

To finish bounded execution within the deadline, the schedule is now:

1. Complete original and full-cohort inference and declared infrastructure recovery.
2. Generate and settle the 16 frozen Python-test predictions.
3. Write a completion marker containing all 16 output hashes; release the Python runtime worker pool.
4. Run the frozen handbook translation inference while Python Docker execution proceeds.
5. Run environment-context inference after handbook completion. Only one inference pool runs at a time.
6. Each execution finalizer waits for successful completion before its declared one-pass harness recovery and summary.

The frozen prompts, selections, inference settings, model adapters and execution runners are unchanged by this scheduling amendment. Invalid terminal records remain invalid. The marker asserts completion, not success of every model prediction. Launcher source changes do not retroactively change frozen experimental inputs.

A follow-up observed that this host suppresses the usual explicit success message for collected transient units. The fallback therefore requires a clean terminal manager history (no failed or manually stopped invocation) plus complete, hash-validated expected records; resource consumption alone is insufficient. Newly queued translation and Python launchers also write explicit success markers only after their checked work completes. The existing declarative runner and inference adapter were not modified.

Before Python execution started, launcher environments set `GOMAXPROCS=2` to bound Docker Go-client thread creation under the host task cap. This affects orchestration resources, not generated programs, inputs, labels or frozen runtime source. The same setting applies to finalizer Docker calls and translation diagnostics.
