Hi Aaron!

I’ve been working across all three directions and put together a reproducible
artifact with the source data, prompts, outputs, execution logs, and a task review page.

- **Benchmark expansion:** 49 additions bring the candidate suite to 70 tasks across
  eight new-task families. Each addition has two initial states, a reference, state
  checks, and a deliberately wrong variant. All references pass; the checks catch
  every selected wrong variant. There are 52 queries that currently pass the actual
  FQL pipeline, with the remaining capability gaps documented.
- **NL → FQL:** I tested retrieval and constrained decoding with an available small
  local model. The matched constrained arm parses 21/21 outputs, but only 9 lower
  successfully and 7 match the reference semantic effects. I also tracked how wrong
  queries change verifier outcomes—parser success alone misses important errors.
- **Comparisons:** I reran the base and configured heuristic verifiers over all 2,238
  processed programs, built independent local execution checks for a 422-program
  slice, and added direct-judge and generated-test baselines. Generated tests are
  checked against good references before trusting their verdicts.

The most useful review cases involve conditional overwrites, password disabling,
and preservation requirements. Some apparent disagreements come from environment
scope or narrow oracles, so I’ve kept those explicit rather than calling them
verifier errors. These are Debian-only development results, not final paper accuracy.

I’d especially like to go over what should qualify as a good FQL query and how we
should align the new fixtures with your original evaluation environments.

Darsh

---
Draft only; not sent. The recorded runs and paired report are complete. See [the research brief](AARON-BRIEF.md) and [results](reports/RESULTS.md).
