# Adversarial test generation — prior art and design implications

Pre-design literature pass for the wave-4 adversarial pipeline. Compiled 2026-05-31
from a delphi `search_papers` sweep + WebSearch arxiv pass. Twelve new papers indexed
this session; combined corpus now covers the LLM-based adversarial test-generation
subfield through arXiv 2603 (March 2026).

## 1. The "sibling, not adversary" problem is named in the literature

Two independent papers name the exact failure mode we observed in wave 3:

- **Homogenization trap** (Ma et al. 2025, [arXiv 2507.06920](https://arxiv.org/abs/2507.06920)).
  LLM-generated test suites "mirror the generating models' error patterns and cognitive
  biases, focusing on LLM-like failures while neglecting diverse human programming errors."
  This matches `find` round 1 in our taxonomy (§4.3 self-cut scope): impl trimmed to
  272 LOC, tests stayed inside that subset, 30/30 pass rate on a self-selected slice.
- **Self-collusion** (Wang et al. 2026, [arXiv 2603.15611](https://arxiv.org/abs/2603.15611)).
  When one model generates both code and tests under shared white-box context, "the
  model produces trivial tests for easy rewards." This matches `mv` round 2 in our
  taxonomy (§5.2 test relaxation): the feedback loop preferred relaxing the test
  (`out=$(... 2>&1)`) over fixing the stream-convention bug in the impl.

Underlying mechanism: **self-bias amplification in self-refinement loops** (Xu et al.
2024, [arXiv 2402.11436](https://arxiv.org/abs/2402.11436)). Quantifies how iterative
self-correction by the same model amplifies rather than corrects its own systematic
errors. Directly explains why our round 1 → round 2 step produced lateral or worse
outputs in three of four utilities.

The motivation section of any wave-4 writeup can now cite all three by name — strong
literature footing for a finding we had previously framed only empirically.

## 2. Two viable adversarial architectures from prior work

### 2.1 Mutation-driven adversary (ACH / Meta, [arXiv 2501.12862](https://arxiv.org/abs/2501.12862))

Foster et al. (FSE 2025) generate undetected-fault mutants of a production impl, then
prompt an LLM to write tests that kill those mutants. Industrial-scale validation at
Meta. The flow:

1. Mutate the impl in semantically meaningful ways (drop a check, return wrong errno,
   skip a flag).
2. Run the existing test suite against each mutant.
3. For surviving mutants, prompt the LLM with `(impl, mutant, test suite)` and ask
   for a new test that distinguishes them.

Maps directly onto our **post-hoc adversarial flavor** with the round-N Rust impl as
the "production code."

### 2.2 Two-agent opposing-reward (Code-A1, [arXiv 2603.15611](https://arxiv.org/abs/2603.15611))

Wang et al. (March 2026) train a code-LLM and a test-LLM with opposing RL rewards:
code-LLM rewarded for passing tests, test-LLM rewarded for exposing defects.
Architectural separation eliminates self-collusion; white-box test generation becomes
safe because the test-LLM is in a different optimization frame.

We will not run RL. But the architectural insight — **fresh-context-window separation
of the test-generator from the impl-generator** — is portable as a zero-cost prompt-level
change. Different system prompt, different task framing, no shared context.

## 3. Mutation has a caveat — do not auto-mutate the Rust AST

Wang et al. 2024 ([arXiv 2406.09843](https://arxiv.org/abs/2406.09843)) study LLM-based
mutation testing across 8 LLMs + 851 real bugs from 770 Java subjects. GPT-4 mutants
closely mimic real bugs but suffer:

- **26.6 pp higher non-compilability** than handwritten mutants.
- **10.1 pp higher duplication** rate.
- **3.5 pp higher equivalent-mutant** rate.

Implication: do not blindly auto-mutate the Rust impl AST and ask the LLM to kill the
mutants. Hand-curate a small mutation taxonomy aligned with our existing failure
taxonomy (`docs/research/taxonomy.md` §4-5) — e.g. "drop the `--preserve=mode` check,"
"return `EACCES` instead of `EPERM`," "ignore `$LC_ALL`." Targeted semantic mutants
beat machine-generated syntactic ones.

## 4. Coverage feedback is a cheap mechanic worth borrowing

CoverUp (Pizzorno & Berger, FSE 2025, [arXiv 2403.16218](https://arxiv.org/abs/2403.16218))
reports **80% median line + branch coverage** vs. CODAMOSA's 47% by iteratively
prompting the LLM with the specific lines and branches that remain uncovered after
running the current test suite.

Direct port to our pipeline:

- Already have `scripts/eval/coverage_rust.sh` (cargo tarpaulin) and
  `scripts/eval/coverage_flags.py` (manpage flag coverage).
- Feed the union of uncovered Rust branches + un-exercised manpage flags into a
  follow-up adversarial test-gen prompt: *"the current test suite exercises X but
  not Y; write tests for Y."*
- This is the **cold adversarial flavor done structurally** — no impl visible, but
  the gap data is.

## 5. Add a metamorphic / property layer

Wang & Zhu 2024 ([arXiv 2406.06864](https://arxiv.org/abs/2406.06864)) demonstrate
metamorphic prompt testing — paraphrase the prompt N times, generate N impls,
cross-validate by semantic equivalence — achieving 75% bug detection at 8.6% false
positive rate on HumanEval/GPT-4. No oracle required.

Property-based testing for LLM code (combined PBT + EBT results, [arXiv 2510.25297](https://arxiv.org/abs/2510.25297))
reports 81.25% bug detection for the combination vs. 68.75% for either alone.

Coreutils-specific metamorphic properties that are cheap to write and would have
caught wave-3 bugs:

- `cp X Y && diff X Y` exits 0 (round-trip identity).
- `mv A B && mv B A` is identity (the round 2 test-relaxation bug failed this
  silently because nobody checked the post-condition).
- `find $d -type f | wc -l` equals `ls -1R $d | grep -v '/$' | wc -l` modulo dot
  handling.

These are not tests in the per-flag sense — they are **invariants the implementation
must preserve**, and they do not need GNU as oracle. They catch what example tests
miss.

## 6. ATGen and the reward signal even without RL

Li et al. 2025 ([arXiv 2510.14635](https://arxiv.org/abs/2510.14635)) train a test-LLM
with RL where the reward is the count of impl divergences from oracle. We are not
doing RL, but the reward shape — **count of behavioral divergences from real GNU
binary per generated test** — is the right ranking signal. We can use it as an
offline scoring function over a single round's tests to surface the most adversarial
ones, without any training loop. Cheap eval, useful diagnostic.

## 7. Design implications for the wave-4 prompt

In priority order:

1. **Two separate prompts, two separate calls, no shared context.** Borrow Code-A1's
   architectural separation. The impl prompt sees the man page. The adversarial test
   prompt sees the man page *and a different framing instruction* — e.g. "your goal
   is to find documented behavior that a hasty implementer would skip." Different
   prompt = different priors = different blind spots.
2. **Cold adversarial = manpage-section-targeted.** Per Ma et al.'s SAGA coverage
   logic, do not ask "write tests"; ask "write tests for the ERRORS section,"
   "write tests for the ENVIRONMENT section," "write tests for every documented
   error condition." Section-level slicing makes the model produce coverage it
   would have skipped under a holistic prompt.
3. **Post-hoc adversarial = bug-targeted.** For round N+1, give the LLM the round-N
   Rust impl + man page, and ask: "find documented behaviors this impl does not
   handle correctly." This is ACH-without-mutants — the LLM gets to read the source,
   find the gap, and write a test that exposes it.
4. **Coverage feedback as auto-prompt augmentation.** Already have the coverage
   tooling. Plumb the gap into the adversarial test-gen prompt as a structured
   "uncovered" block. Same shape as the existing round-N feedback block, different
   payload.
5. **Add a metamorphic / property suite alongside example tests.** Hand-write ~5
   invariants per utility (`cp` round-trip, `mv` reversibility, `find` count
   consistency). These are not LLM-generated; they are the lab's adversarial floor.
6. **Hand-curated semantic mutation set, not auto-AST mutants.** Build a small
   mutation taxonomy from the existing failure taxonomy. Use mutants as adversarial
   seeds for prompt 3, not as the test target.

## 8. Gaps unique to our experiment

No prior work targets **adversarial test generation against a CLI-utility Rust
re-implementation derived from a frozen man page, with a real binary as oracle in
a pinned container**. The closest cousins all operate on:

- Python or Java algorithmic problems (Code-A1, ACH, CoverUp, SAGA, ATGen).
- Handwritten ground-truth solutions (most leaderboard-style work).
- LLM-judge or test-suite oracles (the EvalPlus critique — our setup sidesteps it
  by using the real binary).

The man-page-as-spec angle remains uniquely ours, extending Caruca's spec-mining
lineage ([arXiv 2510.14279](https://arxiv.org/abs/2510.14279)) into the test
generation half. The empirical claim worth making in any wave-4 writeup is the
**prompt-set asymmetry measurement**: does prompting the test-generator differently
from the impl-generator actually break the homogenization trap, or does it just
shift the blind spot? No prior paper measures this directly because no prior paper
has a stable, behaviorally-rich oracle on a documented-but-not-fully-specified
input contract.

## 9. Reading order for the wave-4 design

1. **Ma et al. 2025** ([arXiv 2507.06920](https://arxiv.org/abs/2507.06920)) — the
   homogenization trap framing + SAGA workflow. Read first.
2. **Wang et al. 2026** ([arXiv 2603.15611](https://arxiv.org/abs/2603.15611)) —
   self-collusion + two-agent separation. The architectural template.
3. **Foster et al. 2025** ([arXiv 2501.12862](https://arxiv.org/abs/2501.12862)) —
   ACH at Meta. Mutation-as-adversary applied at industrial scale.
4. **Pizzorno & Berger 2025** ([arXiv 2403.16218](https://arxiv.org/abs/2403.16218)) —
   CoverUp coverage-feedback loop. The mechanic we can directly port.
5. **Wang et al. 2024** ([arXiv 2406.09843](https://arxiv.org/abs/2406.09843)) —
   LLM mutation testing caveat. Read before deciding to auto-mutate.

Glance at Xu et al. 2024 ([arXiv 2402.11436](https://arxiv.org/abs/2402.11436)) for
the self-bias mechanism if a deeper "why does the loop drift" framing is needed in
the writeup.

## 10. Indexed this session

Added to delphi corpus for future `search_papers` / `research` calls:

```
2402.11436  Pride and Prejudice: LLM Amplifies Self-Bias in Self-Refinement
2403.16218  CoverUp: Coverage-Guided LLM-Based Test Generation
2406.06864  Validating LLM-Generated Programs with Metamorphic Prompt Testing
2406.09843  A Comprehensive Study on LLMs for Mutation Testing
2501.12862  Mutation-Guided LLM-based Test Generation at Meta (ACH)
2507.06920  Rethinking Verification for LLM Code Generation (SAGA, homogenization trap)
2510.14635  ATGen: Adversarial RL for Test Case Generation
2510.25297  Property-Based Testing for LLM-Generated Code
2603.15611  Code-A1: Adversarial Evolving of Code LLM and Test LLM via RL
```

Plus three peripheral indexed via the same sweep (`2502.10802`, `2408.11324`,
`2302.06527`) that turned out less directly relevant; kept in the corpus for
future queries.

---

# Part II: Implementation-phase research (added 2026-05-31)

Wave-4 is moving from motivation to code. Second-pass research focused on
concrete techniques we need before writing the driver, the prompts, and the
evaluation. Sections 11-19 below cover prompt engineering, LLM-as-fuzzer
priors, classical CLI testing, test minimization, iteration patterns,
spec-mining ontology, Rust verification tooling, boundary-value technique
explicitness, and evaluation metric selection.

## 11. Adversarial prompt engineering — what actually works

The decisive recent finding is **Hu, Rostami & Thomason 2026 — Expert
Personas Improve Alignment but Damage Accuracy** ([arXiv 2603.18507](https://arxiv.org/abs/2603.18507)):
expert-persona prompts (`"you are an expert QA engineer"`) help alignment,
extraction, and writing tasks (+0.65 on MT-Bench Extraction) but **measurably
damage accuracy on knowledge-retrieval tasks including code and math
benchmarks**. The wave-4 prompts must not use persona framing. Use task
framing instead: `"find documented behavior the implementer would skip"`,
`"identify sections of this man page the test suite does not exercise"`.

The Schulhoff prompt-engineering survey
([`literature/schulhoff_2024_prompt_report.pdf`](../../literature/schulhoff_2024_prompt_report.pdf))
treats persona prompting as "may improve, may not" with no zero-temperature
evidence for adversarial tasks. The 2603.18507 paper supplies the missing
RCT.

For decomposition, **HITS** ([arXiv 2408.11324](https://arxiv.org/abs/2408.11324),
already in corpus) demonstrates that slicing a focal method and prompting
test-by-slice beats holistic prompting on coverage — but raises the
runtime-error rate on the generated tests. Section-level decomposition for
us (per-manpage-section prompts: ERRORS, ENVIRONMENT, locale, OPTIONS)
inherits this trade-off. Plan for a **static-validator filter pass** between
generation and scoring: parse the JSON, dry-run each test under `bash -n`,
drop unparseable / fundamentally broken tests before they hit the eval loop.

The "devil's advocate" framing studied in DEBATE
([arXiv 2405.09935](https://arxiv.org/abs/2405.09935)) supports the
architectural separation already argued for in §2, but it is for evaluator
debate, not test generation. Cite only if a deeper justification for the
prompt separation is needed.

Negative-test generation has no dedicated paper. The closest signal is the
Tambon ([arXiv 2403.08937](https://arxiv.org/abs/2403.08937)) and Dou
([arXiv 2407.06153](https://arxiv.org/abs/2407.06153)) bug taxonomies (both
already in corpus): "missing condition checks" and "wrong/missing exception
handling" are top bug classes. The adversarial prompt should be primed to
target these categories explicitly.

## 12. LLM-as-fuzzer literature

Three transferable templates.

- **Fuzz4All** ([arXiv 2308.04748](https://arxiv.org/abs/2308.04748), ICSE
  2024). Universal fuzzer across 9 languages, 98 bugs in 5 months on
  production systems. Architecture: **auto-prompting** (LLM generates inputs)
  + **coverage-based steering** (uncovered branches feed the next prompt).
  Maps onto our cold-adversarial flavor: LLM generates Bash tests,
  `cargo tarpaulin` and `coverage_flags.py` produce the steering signal,
  next round's prompt asks for tests covering the gap.
- **WhiteFox** ([arXiv 2310.15991](https://arxiv.org/abs/2310.15991)).
  White-box compiler fuzzing: the LLM sees the optimizer source and generates
  programs targeted at weak code paths. Direct template for **post-hoc
  adversarial**: the LLM sees the round-N Rust impl and generates tests
  targeted at logic the impl handles weakly.
- **TitanFuzz** ([arXiv 2212.14834](https://arxiv.org/abs/2212.14834), ISSTA
  2023). 30-50% higher coverage than baseline fuzzers on DL libraries, 65
  bugs in TF/PyTorch. The seed-and-mutate pattern (LLM generates seed
  programs, classical mutator perturbs them) is worth considering as a
  cheap third flavor for high-volume runs.

Engineering note worth surfacing: the **uutils project ships its own
differential fuzzer (`uufuzz`)** that runs against GNU coreutils and reports
uutils 0.6 passes 96.3% of the GNU test suite. No academic paper exists for
this. If we want a secondary oracle for our tests (test passes against GNU
*and* uutils, or surfaces a divergence between them), `uufuzz` is the
existing engineering reference. Worth flagging as a gap: published academic
work on `uutils`-vs-GNU differential testing does not exist.

## 13. Classical CLI / system testing anchor

**KLEE on coreutils** (Cadar, Dunbar, Engler — OSDI 2008). 89 coreutils
binaries, median 94% line coverage, beat the developers' hand-written test
suite, found 10 crash bugs of which three had been undiscovered for 15+
years. No arxiv preprint. Cite by venue. This is the canonical anchor for
"automated test generation on coreutils has a 17-year track record of
finding bugs the human-written suite misses." Use it in the wave-4
motivation to frame our work as the LLM-era successor with **man-page-as-spec
as the novel input constraint** (KLEE used symbolic execution on the binary
itself; we work from documentation forward).

POSIX Test Suite, LTP, GNU autotest: focused on syscalls and binary-level
conformance, not utility CLI semantics. Independent measurements report LTP
covers ~35% of VFS basic blocks. Not a substitute for our oracle, not a
template for our test design.

EvalPlus ([arXiv 2305.01210](https://arxiv.org/abs/2305.01210), in corpus)
is the LLM-era analogue of Csmith / EMI differential testing: LLM seeds
plus type-aware mutation plus differential test against ground truth. The
methodology slot we occupy with `--target real-gnu` is structurally similar.

## 14. Test minimization with LLMs

**ReduceFix** ([arXiv 2507.15251](https://arxiv.org/abs/2507.15251)). LLM
prompted to generate a reducer that shrinks failure-inducing inputs by
89.1% on average, improving program-repair pass@10 by up to 53.8%. Direct
port: when a wave-4 adversarial test exposes a GNU-vs-Rust divergence,
dispatch an LLM-shrink pass to minimize the failing invocation before the
divergence enters the taxonomy. Concrete deliverable:
`scripts/eval/minimize_failure.py` taking a failing test + the two outputs,
producing the smallest invocation that still surfaces the divergence.

The classical foundation (Zeller 1999, ddmin / delta debugging) remains
relevant — `cvise` and `creduce` work on source-level inputs and would
shrink a failing Bash test deterministically, but neither was built for
shell input minimization specifically. LLM-driven shrink is the cheaper
path given we already have the LLM in the loop.

Gap: no published work on LLM-driven **test-suite** minimization (vs.
test-input minimization). EvalPlus appendix B.4 documents set-cover
reduction of an inflated test suite, which is the available baseline if we
ever need to compress our generated suites for shareability.

## 15. Iteration patterns — repair vs regenerate, feedback shape

The literature converges on **structured iteration beats free-form "fix
it"**, and the structure that wins is decomposing iteration into phases.

- **Self-Debug** ([arXiv 2304.05128](https://arxiv.org/abs/2304.05128)).
  Rubber-duck debugging: prompt the LLM to explain its own code, then
  identify the bug, then fix. Explanation + execution result beats execution
  result alone on Spider, MBPP, TransCoder.
- **LDB** ([arXiv 2402.16906](https://arxiv.org/abs/2402.16906)). Segments
  code into basic blocks, inspects intermediate variable values per block.
  +9.8% on HumanEval / MBPP / TransCoder. The block-level granularity is
  worth borrowing for our Rust impl — feed back which Rust function the
  failing test exercised, not just the failing test.
- **AlphaCodium** ([arXiv 2401.08500](https://arxiv.org/abs/2401.08500),
  Ridnik 2024). Flow engineering: spec reflection → public-test reasoning →
  AI-generated tests → iterate. Raised GPT-4 pass@5 from 19% to 44% on
  CodeContests. **Pattern: decompose iteration into named phases**, not one
  monolithic feedback prompt. Most directly portable insight: our wave-4
  round-N+1 should be phased (parse manpage → identify uncovered region →
  generate tests for that region → validate → score), not "here is feedback,
  improve."

These confirm the SLMFix sibling pattern referenced in
[`literature/_synthesis.md`](../../literature/_synthesis.md): a
deterministic static-validator pre-filter pass between rounds is supported
by the broader literature, not just by the in-lab paper. Self-Debug uses
compiler/test output, AlphaCodium uses syntactic validation, ReduceFix uses
input shrinking. All three put a cheap deterministic check in front of the
LLM repair step.

Concrete: the round-N+1 feedback block should contain (a) the specific
failing test, (b) the diff between expected and actual output, (c) the
fault category from `docs/research/taxonomy.md`. **Not** "here is the test,
fix it."

## 16. Spec inference from documentation — alignment with Caruca

DocTer (Xie et al., ISSTA 2022, [arXiv 2109.04835](https://arxiv.org/abs/2109.04835))
extracts API constraints from natural-language DL framework docs — closest
published cousin to man-page constraint extraction before Caruca. Caruca
([`literature/caruca_2025_spec_mining.pdf`](../../literature/caruca_2025_spec_mining.pdf),
already in corpus) supersedes it for our domain.

Caruca contributes a **published ontology** for decomposing CLI semantics:
flag-level, option-level, positional-argument-level. We should reuse this
vocabulary in the cold-adversarial prompt rather than invent our own. It
lets us position the wave-4 contribution as "Caruca's spec-mining input
contract, extended to test generation."

No prior work extracts semantic post-conditions ("exits 0 iff X happened")
from man pages — Caruca handles argument grammar and types but not
behavioral post-conditions. This is open territory and the natural framing
for our Rust-impl-as-spec angle.

## 17. Rust verification tooling — what's usable now

- **Kani** (Amazon model checker). Bit-precise bounded model checking.
  Production-used on AWS Firecracker, s2n-quic, parts of the Rust stdlib.
  Most mature option. Integrates as `cargo kani` with `assert!`,
  `kani::assume`, function contracts.
- **Prusti**. Deductive verification on Viper backend. Pre/postconditions on
  functions. Mature but research-grade tooling around it.
- **Creusot**. SMT-based, requires explicit specs. Less mature.
- **MIRAI** (Facebook abstract interpreter). Effectively abandoned in 2023.

Recommendation: **do not put Kani in the differential-test loop yet**. Kani
requires impls to be small and assertion-rich. LLM-generated Rust impls
satisfy neither — wave-3 saw 272-LOC `find` and compile failures in three
of four round-2 impls. Revisit Kani as a post-SLMFix-style-fix verification
layer once impls are smaller and more structured.

For the metamorphic / property suite (§5 of part I), use **`proptest`** —
~10M downloads/month, de facto Rust default. `quickcheck` is older and less
maintained. Both work as `#[test]` decorators inside the Cargo crate the
driver emits.

## 18. Boundary value analysis / equivalence partitioning

Literature is thin. The combined PBT + EBT result (§5, [arXiv 2510.25297](https://arxiv.org/abs/2510.25297))
is the strongest evidence that systematic boundary thinking complements
example-based testing. No paper directly teaches an LLM Beizer/Myers-style
test-design heuristics; the closest published prompt is EvalPlus's
"come up with interesting inputs" + reference-oracle-shown framing.

The practical takeaway: **name the technique explicitly in the prompt**.
The model knows what boundary-value analysis and equivalence partitioning
are, but does not apply them unprompted. Wave-4 cold-adversarial prompt
should include explicit "apply boundary value analysis on numeric flags"
and "produce one test per equivalence class of input shapes" instructions.

Real research opportunity for the writeup: measure whether explicit
boundary-value / equivalence-partition prompting changes test distribution
on a man-page-driven task. No prior paper measures this.

## 19. Evaluation metrics — what to report

Mutation score has the auto-mutation caveat (§3,
[arXiv 2406.09843](https://arxiv.org/abs/2406.09843)). The cleaner metrics
SAGA, Code-A1, and CoverUp report:

- **`mut@k`** (Code-A1): fraction of buggy code samples killed by the test
  suite. Computed for us by running round-N+1 tests against round-N impl
  (which we already know diverges from GNU) and counting kills. **Strongest
  candidate for wave-4 headline metric.**
- **DEPC — Distinct Error Pattern Coverage** (SAGA). Count of distinct
  divergence patterns surfaced by the test suite, where patterns are our
  existing failure taxonomy categories. Directly portable.
- **Coverage delta over baseline** (CoverUp). Line + branch coverage on the
  Rust impl, computed by `cargo tarpaulin`. Already wired up in
  `scripts/eval/coverage_rust.sh`.
- **Effective-test rate** (CoverUp): fraction of generated tests that are
  both executable and coverage-increasing. Filters out the
  HITS-style decomposition noise (§11).

**Stop reporting raw pass rate as the wave-4 headline.** Pass rate
incentivizes exactly the homogenization trap we are trying to break — a
test suite that mirrors the impl's blind spots will report 100% pass and
catch nothing.

## 20. Updated reading order

For the wave-4 design and code:

1. **Ma et al. 2025** ([arXiv 2507.06920](https://arxiv.org/abs/2507.06920)) — homogenization trap framing. Read first.
2. **Hu et al. 2026** ([arXiv 2603.18507](https://arxiv.org/abs/2603.18507)) — settles the persona question. **Do not use expert-persona prompts.**
3. **Wang et al. 2026** ([arXiv 2603.15611](https://arxiv.org/abs/2603.15611)) — Code-A1 architectural template.
4. **Xia et al. 2024** ([arXiv 2308.04748](https://arxiv.org/abs/2308.04748)) — Fuzz4All auto-prompting + coverage-feedback loop. Template for cold-adversarial.
5. **Yang et al. 2024** ([arXiv 2310.15991](https://arxiv.org/abs/2310.15991)) — WhiteFox source-conditioned fuzzing. Template for post-hoc adversarial.
6. **Ridnik 2024** ([arXiv 2401.08500](https://arxiv.org/abs/2401.08500)) — AlphaCodium flow engineering. Shape for the round-N+1 driver.
7. **Pizzorno & Berger 2025** ([arXiv 2403.16218](https://arxiv.org/abs/2403.16218)) — CoverUp coverage-feedback mechanic.
8. **ReduceFix 2025** ([arXiv 2507.15251](https://arxiv.org/abs/2507.15251)) — LLM-driven test-input minimization.

KLEE (Cadar 2008, OSDI) cited as motivation anchor for "automated test gen
on coreutils finds bugs the hand-written suite misses." Not an arxiv read;
just a citation.

## 21. Indexed in implementation pass (2026-05-31)

```
2304.05128  Teaching LLMs to Self-Debug (Chen et al., 2023)
2308.04748  Fuzz4All: Universal Fuzzing with LLMs (Xia, ICSE 2024)
2310.15991  WhiteFox: White-Box Compiler Fuzzing with LLMs (Yang, 2024)
2401.08500  AlphaCodium: Flow Engineering for Code Generation (Ridnik, 2024)
2402.16906  LDB: LLM Debugger via Runtime Execution Verification (Zhong, 2024)
2212.14834  TitanFuzz: Zero-Shot LLM Fuzzing of DL Libraries (Deng, ISSTA 2023)
2405.09935  DEBATE: Devil's Advocate-Based Assessment and Text Evaluation
2507.15251  ReduceFix: Input Reduction Enhanced LLM Program Repair
2603.18507  Expert Personas Improve Alignment but Damage Accuracy (Hu, 2026)
```

DocTer ([arXiv 2109.04835](https://arxiv.org/abs/2109.04835)) noted as
foundational but not indexed — superseded by Caruca for our domain.
