# Astrogator: progress across all three workstreams

I put together a working research artifact connecting the benchmark expansion,
NL-to-FQL experiments, and error-detection comparisons. Source data, prompts,
model outputs, environment versions, and execution logs are retained.

**Benchmark expansion.** The candidate suite now contains 70 tasks: your 21 plus
49 additions across filesystem, configuration, identity, packages, Git, services,
scheduling, and archives. Each addition includes a reference playbook, two initial
states, independent state checks, and a deliberately wrong variant. All 49 references
pass both states and a second execution; the checks catch all 49 selected wrong
variants in at least one state. These runs are Debian 13 only. They establish useful
executable cases, not complete multi-OS validation or oracle completeness.

**Formal-language coverage.** I found and pinned `counc009/state_based` at
`7c62afa51986d87033af5112cdccd3b104b1c120`. All 21 supplied queries and 31 of the new
candidates pass its parser, semantic analyzer and module-language code generator.
The other 18 expose specific capability gaps. I kept those separate from supported
queries, and none of the new queries is designated independently reviewed gold FQL.

**NL-to-FQL experiment.** I ran all 21 descriptions through an available local
Qwen2.5-1.5B-Instruct Q4 model. With three examples from other task families, 8/21
outputs parsed and 4/21 passed semantic analysis and code generation. An audit found
that the first constrained grammar excluded four supplied reference queries, so I
preserved that development run and corrected the grammar. The corrected grammar
admits all 21 references: 18/21 generated queries parsed and 4/21 lowered. One round
of machine-diagnostic feedback raised those counts to 19/21 and 6/21, but only 1/21
matched the reference's normalized semantic effect tree in either condition.
That comparison is an inspectable proxy, not a semantic-equivalence proof. The
small-model experiment demonstrates why parser feedback alone is insufficient;
it does not establish performance for stronger models. Readable field-level
differences expose dropped conditions, changed paths, and altered actions.

A separate four-shot lexical-retrieval ablation gives 9/21 lowered queries with
either demonstration pool. Normalized effect matches are 6/21 using other original
tasks and 7/21 when adding the 31 lowered expansion candidates. Same-family examples
are allowed and the target itself is excluded. The one-match difference is a
development observation, not a reliable gain estimate from a single sample.
Adding the corrected grammar to the exact expanded-pool prompts raises parsing
from 13/21 to 21/21, while lowering and normalized effect matches remain 9/21 and
7/21. This isolates a useful syntax gain without overstating semantic improvement.

I also ran the repaired queries through the actual verifier on the supplied corpus.
Invalid generated queries block 1,590 processed programs. The six lowered queries
cover 648 programs; relative to supplied FQL, 125 programs change from acceptance
to rejection and three change the other way. These are query-sensitivity measurements,
not accuracy. A missing reboot guard changes no categorical outcomes, illustrating
why outcome agreement alone is insufficient query validation.

**Error-detection comparisons.** I ran the base verifier across all 2,238 supplied
processed programs: 909 accepted with possible residuals, 619 verification rejections,
710 Ansible-lowering errors. The 72 raw attempts without processed files remain
explicit. These are outcomes, not accuracy measurements. I also ran direct-judge and
generated-test pilots on six controlled reference/wrong-program pairs and eight of
your supplied programs with independent local execution checks. The small model's
generated tests often assert initial rather than final state or reject good references;
their own quality therefore needs an explicit validation gate. A larger frozen run
covers all 422 processed programs on four original tasks, with two initial states
per program and a separately generated, blinded judge prediction. All 844 candidate-state executions are complete: 283 programs pass both local
checks and 139 fail execution or a check, with 18 missing processed files separate.
All 422 judge predictions are complete. The small-model judge accepts 129 local
failures and rejects 13 local passes; these are scoped check disagreements, not
frontier-model results. The configured heuristic sweep is complete: it rejects 183 additional
programs across the full corpus. In the local slice, it rejects all nine base accepts
that fail our checks, plus five additional local passes whose `www-data` assumptions
conflict with the upstream Red Hat metadata. This is an environment-scope distinction,
not five demonstrated false rejections. Exact flags and metadata hashes are retained.
A new task-level generated-check arm failed its reference gate on all four tasks:
one check set was invalid, and three rejected known-good reference states. It
therefore abstains for the entire slice instead of producing misleading code labels.

**Useful cases for the query-validation discussion.** There are seven reference/wrong
program pairs that the independent execution checks distinguish but the base verifier
accepts under the candidate query. Examples include overwriting existing configuration,
deleting a home that should be preserved, and recursively changing child ownership.
The full residual traces are included. These are concrete cases for deciding which
obligations belong in FQL, the models, or human residual review—not a claim of verifier
unsoundness.

The next paper-scale step is to review the new specifications and coverage gaps,
repeat the frozen experiments with stronger models, and attach the original multi-OS
execution labels and heuristic settings. The artifact includes the executable cases, reproduction commands, and evidence
needed for that review.

[Results and evidence](reports/RESULTS.md) · [Task review page](reports/review.html) ·
[Reproduction instructions](README.md) · [Protocol](experiments/protocol.md)
