# Synthesis: Where this experiment sits in the literature

## What's been tried for NL → formal-or-code that's relevant

The closest line of work is **autoformalization**: Wu et al. 2022 (Isabelle from English math) opened the modern LLM-based variant; Endres et al. 2024 specialized it to formal postconditions extracted from English code-comments / docstrings. Cosler et al. 2023 (nl2spec) extends the same shape to LTL/temporal-logic specifications and contributes the dominant insight that **NL ambiguity, not LLM "intelligence," is the limiting factor** — they handle it by decomposing and looping a human in. Across all three, raw one-shot autoformalization tops out around 25–60% perfect translation; everything beyond that requires repair, decomposition, or interactive correction.

For Bash specifically, Lin et al. 2018 (NL2Bash) is the foundational dataset but pre-LLM. Westenfelder et al. 2025 is the modern reference and contributes a methodology directly portable to the student's evaluation: **execute candidate commands and diff outputs**, optionally judged by an LLM, achieving 95% confidence on functional equivalence; GPT-4-as-judge alone is documented to fail because LLMs cannot reliably simulate command execution.

For shell semantics, Greenberg & Blatt 2019 (Smoosh) gave executable POSIX-shell semantics — but only for the shell language. **Per-utility semantics remain informal**, which is exactly the gap.

## Known LLM failure modes from prior empirical studies

Three concurrent taxonomies, mostly converging:

- **Tambon et al. 2025** (10 patterns from 333 bugs): Misinterpretations, Syntax Error, Silly Mistake, Prompt-biased code, **Missing Corner Case**, Wrong Input Type, **Hallucinated Object**, Wrong Attribute, Incomplete Generation, Non-Prompted Consideration.
- **Dou et al. 2024**: 3 categories / 10 sub-categories spanning syntactic, functional-misuse, and reasoning bugs; introduces the RWPB real-world bug benchmark showing distribution differs sharply from HumanEval-like benchmarks.
- **Zhang et al. 2025**: hallucination-specific taxonomy — fabricated APIs, fabricated arguments, intent conflicts, knowledge conflicts.
- **Liu et al. 2023 (EvalPlus)** is methodological but cuts the same way: pass@k drops 19–29% when test suites are inflated 80×, meaning under-tested code looks correct but isn't.

For the man-page-to-impl task specifically, the high-prior failures are: **flag misinterpretation** (man pages describe corner cases tersely, e.g. `cp -a` ≡ `-dR --preserve=all`), **hallucinated flags** (LLM invents options from a sibling utility), **silent omission of error conditions** (man-page ERRORS sections under-described), **POSIX-vs-GNU drift** (LLM confuses behaviors), and **missing corner cases** for symlink/permission/sparse-file behavior. Expect these categories to dominate the student's taxonomy.

## Has anyone done man-page → impl specifically?

**Spec-half: yes, very recently (Caruca, Lamprou et al. 2025, arXiv 2510.14279).** Caruca uses LLMs to translate Unix-command documentation into structured invocation syntax, then dynamically executes commands with syscall/filesystem interposition to extract pre/post-conditions; evaluated on 60 GNU coreutils + POSIX + third-party commands, correct on 59/60. Same vocabulary, same target utilities, same upstream goal (machine-checked specs for shell verification). The student must read this and explicitly position against it.

**Impl-half: no public paper does man-page → executable Rust implementation + behavioral test suite, with a flag-coverage and failure-taxonomy evaluation.** This half remains open. The closest cousin in spirit is the `uutils` project (Rust GNU-coreutils rewrite), but uutils is human-written. Differential fuzzing of `uutils` vs. GNU coreutils does happen in the wild — that's a method the student should borrow, not a paper to cite.

## Is the student's design novel or duplicative?

**Partially novel.** The spec extraction angle is now occupied by Caruca; redoing it would be duplicative. The novel contributions remaining are:

1. **Executable Rust implementation as the artifact, not just a spec.** Caruca outputs structured specifications; the student outputs runnable Rust. This is harder (compile-correctness + behavior-correctness) and produces a richer failure surface.
2. **Co-generated test suite vs. real binary.** Asking whether LLM-generated Bash *tests* pass against `/bin/cp` is a separate empirical claim from "can LLMs extract specs." This bears on Astrogator's downstream test-driven verification story.
3. **Failure taxonomy specifically scoped to man-page → behavior extraction**, with `sudo` (security-critical, complex semantics) deliberately included alongside benign utilities.

## Open gaps the student's work could plausibly fill

- **Quantify man-page vs. POSIX-spec gap empirically.** Does the LLM do better when given the man page, the POSIX spec, both, or neither? Caruca didn't compare doc sources rigorously.
- **Are LLM-generated Bash test suites adequate evidence for spec correctness?** Westenfelder showed LLM-judge alone is unreliable; the student can directly measure whether an LLM-generated test suite exposes the same bugs that GNU's hand-written test suite catches.
- **Failure-mode predictiveness for spec-language pipelines.** If man-page→Rust fails on flag X for utility Y, does man-page→formal-spec also fail there? This is the bridge to Astrogator's eventual Bash work.
- **`sudo` is uniquely useful** because security-relevant misinterpretations matter more — almost no prior work tackles security-critical CLI tools.

## Recommended reading order (3–4 papers first)

1. **Caruca** (`caruca_2025_spec_mining.pdf`) — read first. This is the closest published prior art and directly bounds the student's contribution.
2. **Endres 2024 postconditions** (`endres_2024_postconditions.pdf`) — methodological template for evaluating NL → formal correctness.
3. **Tambon 2025 bug taxonomy** (`tambon_2025_bugs_in_llm_code.pdf`) — the categorization the student should report failures against.
4. **Westenfelder 2025 NL2SH** (`westenfelder_2025_nl2sh.pdf`) — the execute-and-diff evaluation methodology to adopt for the test-suite half.

After those four, glance at Greenberg 2019 (Smoosh) for the shell-semantics framing, Wu 2022 for autoformalization priors, and Zhang 2025 for hallucination-specific failure modes. Liu 2023 (EvalPlus), Dou 2024, Cosler 2023, and Lin 2018 are useful background but not blocking.
