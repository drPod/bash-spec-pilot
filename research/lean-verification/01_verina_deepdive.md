# VERINA: benchmarking verifiable code generation (deep dive)

**Paper**: Zhe Ye, Zhengxu Yan, Jingxuan He, Timothe Kasriel, Kaiyu Yang, Dawn Song. "VERINA: Benchmarking Verifiable Code Generation." arXiv:2505.23135 (v1: 29 May 2025, v3: 16 Mar 2026). Published as a conference paper at ICLR 2026. Code: `github.com/sunblaze-ucb/verina`. Data: `huggingface.co/datasets/sunblaze-ucb/verina`.

This document is grounded in the full extracted text of the paper (abstract, all main sections, and appendices A-F) via Delphi (`paper_id b6d08d23-9a49-4a64-bc52-e92064b24c01`), cross-checked against the arXiv abstract page. All numbers below are quoted or paraphrased directly from the paper; nothing is reconstructed from memory.

---

## 1. What VERINA is, and what "verifiable code generation" means

VERINA (Verifiable Code Generation Arena) is a benchmark for a task the authors call **verifiable code generation**: jointly generating (1) code, (2) a formal specification, and (3) a formal proof that the code satisfies the specification, all in the same target language. VERINA uses Lean 4 as that language for all three artifacts.

The paper's framing of the problem, from the introduction: LLM-generated code lacks formal correctness guarantees and typically needs costly human review to catch bugs (functional errors, security vulnerabilities). Formal verification is the traditional fix but has "traditionally been limited to safety-critical applications due to high cost" (seL4, CompCert, verified TLS). Verifiable code generation is the bet that LLMs can lower that cost barrier the same way they lowered the cost of code generation itself, by automating not just the code but the spec and the proof of alignment between them.

### The three components and their relationship

Each VERINA instance has, per Figure 1 of the paper:

1. **Natural language description**: an informal statement of programmer intent (median 110 words).
2. **Code**: a ground-truth Lean implementation solving the problem, taking an explicit precondition hypothesis as an argument.
3. **Specification**: a **precondition** (`_pre`, a `Prop` over inputs, stating what inputs are legal) and a **postcondition** (`_post`, a `Prop` over inputs, the precondition proof, and outputs, stating the required input-output relationship).
4. **Proof** (optional in the dataset, required as a model output for ProofGen): a Lean theorem, of the shape `theorem f_spec ... : f_post args (f impl_args) h_precond`, establishing that the implementation satisfies the postcondition whenever the precondition holds.
5. **Test suite**: positive tests (valid input/output pairs satisfying both pre- and post-condition) and negative tests (inputs violating the precondition, or outputs violating the postcondition), used to evaluate model outputs, not just the ground truth.

Worked example from the paper (`removeElement`, Figure 1): removes the element at index `k` from array `s`. Precondition: `k < s.size`. Postcondition: three conjuncts constraining output size and which elements shift where. The proof body is elided in the figure (`by sorry` stands in for the real proof). Four negative tests are given, one violating the precondition and three each violating a different postcondition conjunct.

Why this three-way split matters: code, spec, and proof are three genuinely different skills (code = produce a solution; spec = correctly formalize intent; proof = construct a valid logical argument), and a benchmark that conflates them (e.g., asks for spec+proof together, or code+proof together) can't tell you which capability is the bottleneck. VERINA's explicit design goal is **modularity**: evaluate each of the three tasks independently, then compose them to mimic realistic workflows. The paper's related-work table (Table 1) scores prior benchmarks/techniques against exactly this axis and finds that no prior Lean or Dafny benchmark is both fully three-task-covering and compositional; Dafny-Synthesis and Clover cover all three tasks but "mix specification and proof generation into a single task, lacking support for separate evaluation of each," and have only 50 and 62 human-written samples respectively, versus VERINA's 189.

---

## 2. The benchmark: size, sourcing, curation, decontamination, license

**Size**: 189 standalone Lean programs, each with description + code + precondition + postcondition + test suite; 46 of the 189 additionally ship a hand-written ground-truth proof (proofs are optional in the dataset because they aren't needed for evaluation: model proofs are checked directly by the Lean compiler).

**Sourcing** (three streams, combined into two named subsets used throughout the results):

- **MBPP-DFY-50** (Misu et al., 2024): MBPP coding problems paired with human-verified Dafny solutions. The authors manually translated 49 of the 50 problems into Lean, "refining and verifying each translation."
- **CloverBench** (Sun et al., 2024): 59 more human-authored Dafny instances, translated into Lean using OpenAI o3-mini with few-shot prompting (bootstrapped from the manual MBPP-DFY-50 translations), then manually inspected and corrected.
- **Student submissions**: problems adapted from a university course on theorem proving and program verification. Students sourced problems from LeetCode and the harder LiveCodeBench, formalized and solved them in Lean in VERINA's format, and the authors "carefully selected the most suitable and high-quality submissions," yielding 81 instances, followed by manual review and editing.

The paper defines **VERINA-A** = the 49+59 = 108 instances translated from human-written Dafny datasets, and **VERINA-B** = the 81 student-submission instances written from scratch. VERINA-B is empirically much harder (Section 6 below): "problems adapted from student submissions are generally more difficult than problems translated from Dafny datasets on all models."

**Curation / quality assurance** (Section 3.2), enforced mechanisms:
- Original problem descriptions (e.g., from MBPP-DFY-50) were "short and ambiguous," so descriptions were manually rewritten with explicit intent, input types, and output behavior.
- Test suites were expanded (manually and with LLM assistance) to hit **100% line coverage** on the ground-truth Lean code, verified via Python's `coverage.py` on parallel Python reference implementations (since "Lean lacks a robust coverage tool"), then manually re-checked for 100% coverage transfer onto the actual Lean code.
- Ground truth code and specs were run against the full test suite and confirmed to pass all positive tests and fail all negative tests.
- Each positive test was mutated into **at least three distinct negative tests** violating either the pre- or post-condition (fewer only when the output type is boolean, where a single negation suffices), each tagged with which condition it targets, to allow separately scoring soundness vs completeness.
- Ground-truth specifications were deliberately written so they **cannot be trivially reused as the implementation** ("preventing trivial code generation"): this stops a model from generating code that is definitionally identical to the spec, which would make CodeGen vacuous.
- Every instance was manually reviewed and edited by at least two authors.

**Benchmark statistics** (Table 2, as stated in prose): natural-language descriptions have median length 110 words; code runs up to 38 lines; specifications run up to 62 lines; median 5 positive tests and 12 negative tests per instance (max 13 positive / 27 negative).

**Decontamination** (Appendix B): the authors ran 10-gram overlap detection (the Qwen2.5-Coder decontamination standard) between VERINA's Lean ground-truth solutions and the ~550M-row bigcode/the-stack pretraining corpus, and **found zero matches**: the Lean artifacts are novel, so there's no direct-contamination risk from the Lean code itself. They separately argue indirect contamination is unlikely to matter: even on algorithmically familiar problems (the underlying algorithm topics are drawn from well-known sources like LeetCode/MBPP), models still do dramatically worse on SpecGen and ProofGen than on CodeGen, which the authors read as evidence that "memorized algorithmic solutions do not transfer to verification tasks," meaning knowledge of the algorithm doesn't help a model formalize or prove it.

**License**: MBPP-DFY-50 is GPL-3.0; CloverBench and LiveCodeBench are MIT. VERINA itself will be released under **GPL-3.0**. The authors note VERINA "involves no model training or fine-tuning processes" and problems from platforms like LeetCode were used strictly for academic research.

**Difficulty tiers**: VERINA does not have named Easy/Medium/Hard tiers; the operative difficulty split is source-based (VERINA-A translated-from-Dafny vs. VERINA-B written-from-scratch-by-students), and the paper treats VERINA-B as the harder tier throughout.

---

## 3. Task decomposition and metrics

### The three foundational tasks (Figure 2)

All three tasks always receive the natural-language description and the function signature as input (this fixes the "shape" of the output and keeps evaluation comparable across models):

- **CodeGen**: description + signature (+ optionally the ground-truth specification) → code. Evaluated with the standard **pass@k** metric (Chen et al., 2021) against the positive test cases.
- **SpecGen**: description + signature (+ optionally the ground-truth code) → precondition + postcondition. Evaluated via the soundness/completeness framework described in Section 4 below.
- **ProofGen**: description + signature + code + specification → a Lean proof that the code satisfies the spec. Evaluated by literally running the Lean compiler on the generated proof; any proof using a placeholder tactic like `sorry` is marked incorrect regardless of whether it otherwise "compiles."

### Task combinations (Figure 4, Section 4.2)

Because the three tasks are modular, VERINA composes them into three realistic end-to-end scenarios:
- **Specification-guided code generation**: description + ground-truth spec → code, then prove the generated code against the ground-truth spec. (Matches the setting in FVAPPS and AlphaVerus.)
- **Specification inference from code**: description + ground-truth code → spec, then prove alignment. (Matches AutoSpec, SpecGen, SAFE.)
- **End-to-end verifiable code generation**: description only → code and spec generated *independently*, then a proof that the generated code satisfies the **ground-truth** specification (not the model's own generated spec) is required. Forcing the proof target to be the ground-truth spec, rather than the model's own generated spec, is a deliberate anti-gaming measure: it prevents a model from producing a trivially provable pair by making its code and its spec definitionally equivalent to each other.

VERINA is the first of these benchmarks, per the paper's comparison table, to support all three foundational tasks *and* all three combinations in a genuinely modular way; concurrent work CLEVER (Thakur et al., 2025, 161 problems from HumanEval) supports only SpecGen and specification-guided CodeGen, and additionally "assumes access to a sound and complete ground truth specification for certification" during its own SpecGen evaluation, which VERINA's authors argue limits real-world applicability, since if you already have a sound/complete spec you don't need to generate one.

### Metrics used

- **pass@k** (Chen et al., 2021) for CodeGen (against positive tests) and ProofGen (Lean-checked). The paper samples 5 responses per instance per model and reports **pass@1** as the primary metric in the main results (with pass@k curves, k up to 64, used specifically for the ProofGen iterative-refinement experiments).
- **Soundness and completeness** pass@k scores for SpecGen (defined formally in Section 4 below), reported per pre-condition, per post-condition, and as an aggregate requiring both simultaneously.
- **Code&Spec Score** and **End-to-End Score** for the combined end-to-end task (Section 6 below).

---

## 4. Spec quality evaluation: the soundness/completeness mechanism

This is VERINA's most novel methodological contribution, so it's worth reproducing precisely.

### The formal definitions

Let φ be the set of programs satisfying the ground-truth spec, and φ̂ the set satisfying the model-generated spec. An ideal generated spec has φ̂ = φ, which splits into two properties:
- **Soundness** (φ̂ ⊆ φ): the generated spec is "small enough," it only accepts programs that are actually correct. An unsound spec would let a *buggy* implementation pass.
- **Completeness** (φ ⊆ φ̂): the generated spec is "large enough," it accepts every actually-correct program. An incomplete spec would reject a *correct* implementation.

Specs decompose into precondition P̂ (model) vs P (ground truth), and postcondition Q̂ vs Q. The paper's four defining implications (direct quote of the logic, x = inputs, y = output):

- P̂ is **sound** iff ∀x. P(x) ⇒ P̂(x): P̂ must accept everything P accepts (i.e., P̂ is *at least as permissive* as P, so it doesn't wrongly reject legal inputs the real precondition allows; the paper's own framing is that the *set of programs* accepted under P̂ ends up a subset of those under P, because a more permissive precondition is a harder bar for an implementation to satisfy against the same postcondition).
- P̂ is **complete** iff ∀x. P̂(x) ⇒ P(x): P̂ must not accept more than P does.
- Q̂ is **sound** iff ∀x,y. P(x) ∧ Q̂(x,y) ⇒ Q(x,y): for legal inputs, anything Q̂ accepts as output, Q must also accept.
- Q̂ is **complete** iff ∀x,y. P(x) ∧ Q(x,y) ⇒ Q̂(x,y): for legal inputs, anything Q accepts, Q̂ must also accept.

### The multi-stage evaluator (Figure 3)

Checking these universally-quantified implications in general requires either a proof or exhaustive enumeration, neither fully available. VERINA's evaluator is a **cascade**:

1. **Try to prove it.** Attempt to establish the soundness/completeness relation R (or its negation ¬R) with an LLM-based Lean theorem prover. If the proof succeeds, the result is certified formally (`R holds` / `R does not hold`).
2. **If proving is inconclusive, simplify to a test-indexed proposition R′** and try `decide` (Lean's built-in decision procedure) case by case over the concrete test-suite values.
3. **If `decide` doesn't resolve it, fall back to property-based testing** using the `plausible` tactic (Lean Prover Community, 2024), which generates diverse concrete instantiations for the remaining quantified variables and searches for counterexamples.
4. **If none of the above resolve it, the evaluator returns "unknown."** The paper reports these as **error bars**: a lower bound treating "unknown" as failure, an upper bound treating it as success.
5. The whole procedure is run **twice**, once for R and once for ¬R, and the definitive outcome (proved / disproved) is preferred over "unknown" whichever direction produces it.

### Why test cases suffice in practice (the concrete mechanism)

Because the benchmark's own QA process guarantees that ground-truth P and Q pass every positive test and fail every negative test, the paper shows the four abstract relations collapse to simple, checkable statements over the existing test suite:

- **P̂ soundness** ⟺ P̂(x) holds for every **positive** test x (because for negative x, P(x) is already false, so the implication is vacuously true).
- **P̂ completeness** ⟺ P̂(x) is **false** for every **negative** test x.
- **Q̂ soundness** is checked with **negative** tests.
- **Q̂ completeness** is checked with **positive** tests.

The concrete Lean mechanism (Figures 10-12, using `removeElement` as the running example) is:
```lean
-- Code correctness (Figure 10)
#guard removeElement (#[1, 2, 3, 4, 5]) (2) (by sorry) == (#[1, 2, 4, 5])
```
and for specs (Figure 11, precondition soundness/completeness):
```lean
#guard decide (removeElement_precond (#[1, 2, 3, 4, 5]) (2))          -- soundness via decide
example : (removeElement_precond (#[1, 2, 3, 4, 5]) (2)) := by
  unfold removeElement_precond
  simp_all! (config := { failIfUnchanged := false })
  simp (config := { failIfUnchanged := false }) [*]
  plausible (config := { numInst := 1000, maxSize := 100, numRetries := 20, randomSeed := some 42})
```
i.e. exactly `#guard`/`decide` where the proposition is directly decidable, falling back to the `plausible` property-testing tactic (1000 random instances by default) when it isn't. Postcondition soundness/completeness (Figure 12) is the mirror image, run over negative and positive tests respectively.

### Worked soundness/completeness failure examples from the paper (Appendix E)

These four case studies are the clearest illustration of the mechanism in action:

1. **Unsound precondition** (`topKFrequent`, task: "assuming k ≤ number of distinct elements"). Ground truth: `k ≤ nums.eraseDups.length`. o4-mini generated: `k < (distinct nums).length` (strict inequality). This wrongly excludes the boundary case k = (number of distinct elements). The evaluator catches this because the positive test `nums = [5], k = 1` satisfies the ground truth but is *rejected* by the generated precondition, an unsound precondition that rejects a legitimately positive case.

2. **Incomplete precondition** (`nextGreaterElement`, task states both arrays contain unique elements and one is a subset of the other). Ground truth: `List.Nodup nums1 ∧ List.Nodup nums2 ∧ nums1.all (· ∈ nums2)`. o4-mini generated: `True`, dropping every constraint. The evaluator catches this via the negative test `nums1 = [1,1], nums2 = [1,2]` (violates uniqueness), which the ground truth correctly rejects but the generated `True` precondition wrongly accepts: an incomplete precondition, too permissive.

3. **Unsound postcondition** (`addTwoNumbers`, digit-list addition in reverse order). Ground truth requires arithmetic correctness, all digits < 10, **and** no leading zeros (except for a literal-zero result). o4-mini's generated postcondition dropped the leading-zero clause, so it would wrongly accept output `[2,1,0]` (representing "012") where the ground truth requires `[2,1]`. Caught by a negative test built exactly around that boundary case.

4. **Unsound *and* incomplete postcondition** (`singleDigitPrimeFactor`, smallest single-digit prime factor of n, defined to return 0 for n = 0 or when no small prime divides n). o4-mini's generated postcondition silently mishandles n = 0 (because `n % p ≠ 0` is *false* when n = 0, for any p, breaking the intended disjunct). The evaluator flags this as **both** unsound and incomplete using a paired positive test (n=0, result=0, wrongly rejected) and negative test (n=0, result=2, wrongly accepted).

The paper also documents where the testing-based fallback itself breaks down: a generated postcondition for "length of longest increasing subsequence" contained an unbounded `∀s : List Int` quantifier ranging over *all* integer lists. Neither `decide` nor `plausible` can meaningfully test an unbounded universal quantifier, so the evaluator correctly (and honestly) returns "unknown" rather than a wrong answer.

### How reliable is the testing fallback, versus proving?

Table 5 in the paper is a direct empirical check: the authors had o4-mini and Claude Sonnet 3.7 try to *prove* soundness/completeness of specs generated by o4-mini, and compared against the testing-based verdict. Result: **proof success rates were below 4% in all cases**, while the testing-based pipeline judged **over 40%** of the same specs sound-and-complete. Critically, whenever a proof *did* succeed, it always agreed with the testing verdict (no false positives from testing when a formal proof exists); and manual inspection of 20 randomly sampled disagreements (proof failed, testing said pass) confirmed the testing verdict was correct every time. The paper's conclusion: proving gives a strictly stronger guarantee when it works, but at under-4% success it cannot carry the evaluation on its own: the comprehensive positive/negative test suite is what actually makes VERINA's SpecGen metric practical today. A sensitivity analysis (Table 6) further shows the property-based testing budget (10 to 2,000 generated instances) barely changes the verdict distribution once it clears ~100 instances, and property-based testing itself contributes to the final call in under 13% of cases; `decide` on the literal test suite already resolves the overwhelming majority of cases.

---

## 5. Headline results

### Abstract-level numbers (the ones to cite)

> "The best model, OpenAI o3, achieves a 72.6% code correctness rate, 52.3% for specification soundness and completeness, and a mere 4.9% proof success rate (based on one trial per task)."

This is pass@1, one trial per task, and o3 is the best of ten evaluated general-purpose LLMs (GPT-4o-mini, GPT-4o, GPT-4.1, o4-mini, o3, Claude Sonnet 3.7, Claude Opus 4.0, Gemini 2.5 Flash, DeepSeek V3, Qwen3-235B-A22B-FP8). The ordering CodeGen > SpecGen > ProofGen holds for essentially every model: "proof generation remains the most challenging with pass@1 rates below 4.9% for all general purpose models."

### Specialized theorem provers do better, but not by much

Beyond the ten general-purpose LLMs, the paper separately evaluates three provers/frameworks purpose-built for theorem proving: **Goedel-Prover-V2 32B**, **DeepSeek-Prover-V2 7B**, and **Copra** (an agentic, tree-search-based theorem-proving framework, run here with o4-mini as its backbone LLM, allowed up to 64 LLM queries per sample).

> "Among theorem-proving LLMs, the best model, Goedel Prover V2 32B, achieved an **11.2%** proof success rate in one trial."

This 11.2% is the single most important number for gauging feasibility: it is the best pass@1 proof-generation result **anywhere in the paper**, achieved by a model trained specifically to write Lean proofs, on VERINA's already-easy (pure, finite, decidable) proof obligations. General-purpose frontier LLMs (o3, o4-mini, Claude Opus 4.0, Gemini 2.5 Flash, GPT-4.1) all score below 4.9% pass@1 on the same task.

Copra "demonstrates clear improvements over direct single-pass generation," but the paper does not report a single comparable pass@1 percentage for Copra in the main results figure; instead it runs a **budget-normalized comparison** (Appendix D) against iterative refinement, both using o4-mini:
- At a 50k-token budget: iterative refinement reaches **8.99%** overall success vs. Copra's **4.76%**.
- At a 350k-token budget: iterative refinement reaches **14.29%** vs. Copra's **7.94%**.
- Average token cost per successful proof: **57,594** (iterative refinement) vs. **84,027** (Copra): refinement is not just more successful but cheaper per success.
- On the harder VERINA-B subset specifically, iterative refinement saturates early at **3.70%**, vs Copra's **1.23%**. The conclusion drawn is that "increased inference budgets alone cannot overcome fundamental reasoning gaps in complex verification tasks."

### Iterative refinement (compiler-feedback loop)

For ProofGen, the paper additionally evaluates **iterative refinement**: feed the Lean compiler's error message back to the model and let it revise, for up to k = 64 rounds, versus **direct generation** (independent i.i.d. samples with no feedback, same k). Refinement "reliably outperforms direct generation at matched query budgets on both general purpose and proof-specific models."

> "Interestingly, iterative refinement using Lean compiler feedback can increase the proof success rate up to **20.1%** with 64 refinement steps. However, this approach significantly raises costs and the success rate remains low."

Refinement gains are strongly difficulty-dependent: on the easier VERINA-A subset, o4-mini improves from 7.41% (k=1) to 22.22% (k=64); on the harder VERINA-B subset, it only rises from 1.23% to 6.17%. "Naive proof refinement gains diminish when the problem is difficult," meaning throwing more inference-time compute at a hard proof does not reliably close the gap.

A related qualitative finding: refinement makes proofs longer, not more elegant. Human-written ground-truth proofs (from the 46 hand-proved instances) average **169.6 characters** and rely heavily on Lean automation tactics (`simp`, `aesop`) and standard-library lemmas. Model proofs after 64 refinement rounds grow to over **1,200 characters** for the worst case (Gemini 2.5 Flash) because models "often cannot correctly identify or use relevant lemmas from the standard library," so they explicitly re-derive intermediate steps a human would automate away.

### Task-combination (end-to-end) results

> "Simultaneously generating correct code and specifications is difficult, with the leading model, o3, achieving only **41.2%**" (Code&Spec Score: both code and spec correct, no proof required).

> "The evaluation results confirm that ProofGen is the bottleneck in end-to-end verifiable code generation setting, with the leading models, o4-mini and o3, achieving only **3.2%**" (End-to-End Score: code, spec, and a proof that the generated code satisfies the *ground-truth* spec, all required).

The drop from 72.6% (code alone) → 41.2% (code+spec) → 3.2% (code+spec+proof) is the paper's core empirical result: each additional required artifact compounds the failure rate, and the proof requirement alone accounts for the overwhelming majority of the final collapse.

### VERINA-A vs VERINA-B

Across all three foundational tasks, VERINA-B (student-submission, LeetCode/LiveCodeBench-sourced) is substantially harder than VERINA-A (translated-from-Dafny). Representative pass@1 gaps for the strongest models: CodeGen ~72-78% on VERINA-A vs. ~60-68% on VERINA-B (varies by model); ProofGen collapses even further on VERINA-B, in some cases to effectively 0%. The paper attributes this to VERINA-B problems more often requiring genuinely novel algorithmic reasoning rather than "translation" of an already-solved Dafny problem.

### Failure-mode taxonomy for ProofGen (Tables 17-19)

Manually categorized failure causes across four top models (Claude Sonnet 3.7, Gemini 2.5 Flash, GPT-4.1, o4-mini), up to 64 refinements:
- **Incomplete Proof** (unsolved goals left over): dominates for Gemini 2.5 Flash (77.55%) and GPT-4.1 (38.24%).
- **Cheat Code Usage** (i.e., emitting `sorry` or similar placeholders instead of a real proof): dominates for Claude Sonnet 3.7 (48.53%) and is also large for o4-mini (28.30%), read by the authors as models "explicitly acknowledging their inability to complete the proof" rather than confabulating something plausible.
- **Unknown Identifier / Unknown Tactic / Unknown Constant** collectively account for **15-30% of failures across every model**, a "pervasive lack of familiarity with the specific syntax and standard library of the Lean ecosystem." Models don't reliably know what lemmas or tactics actually exist in Lean's Mathlib.
- Syntax errors and type mismatches are present but minor by comparison.

For CodeGen, the paper separately highlights a concrete hallucination case: o4-mini writes syntactically plausible code calling `Int.xor`, a method that **does not exist** in Lean 4's standard library, despite correctly identifying the right algorithmic approach (XOR-based duplicate cancellation) and commenting it accurately. The model "understands the algorithm" but doesn't reliably know the target language's actual API surface.

### Other notable findings

- Providing the **ground-truth specification** as context reliably improves CodeGen for every model, and the authors argue this improvement is genuine (not spec-copying, since specs are deliberately non-trivial-to-reuse); a good formal spec is a *useful* guide for code synthesis.
- Providing the **ground-truth code** as context for SpecGen gives minimal or even *negative* benefit: verbose implementation detail seems to introduce noise rather than help a model infer the right level of abstraction for a spec.
- Replacing ground-truth references with the model's *own* generated artifacts (in the combined tasks) degrades performance across the board, confirming that "combined tasks are more challenging than individual tasks," meaning errors compound rather than cancel.

---

## 6. Stated limitations and future work

Directly from the paper's Conclusion/Limitations section:

1. **Size.** 189 examples is "modest"; scaling to a dataset suitable for fine-tuning would likely require LLM-assisted automated annotation.
2. **Scope/representativeness.** VERINA emphasizes "simple, standalone coding problems," which is good for benchmarking but "not fully representative of complex real-world verification projects." The paper explicitly cites seL4 and CompCert as the kind of large, multi-person-year verification effort VERINA does not attempt to approximate. Performance already drops substantially on VERINA's own harder instances (VERINA-B), "indicating these fundamental capabilities must improve before tackling more difficult verification challenges."
3. **Evaluation pipeline dependence on testing.** The current SpecGen evaluator leans on comprehensive testing precisely because current LLM theorem provers are too weak to serve as the primary metric; the authors frame this as provisional, expecting testing's role to shrink as "LLM theorem prover capabilities" improve.
4. **Single proof paradigm (ITP only).** Extending VERINA to automated-theorem-proving (ATP) verification systems like Dafny or Verus "can strengthen VERINA's generalizability but requires significant effort," and is explicitly left as future work. (Appendix A separately argues, without new data, that VERINA's findings should transfer conceptually to ATP settings, since both paradigms require the same underlying semantic understanding for CodeGen/SpecGen and similar proof-search reasoning for ProofGen; this is an argument, not an experiment.)
5. **Contamination risk from topic reuse.** Even though the Lean artifacts themselves show zero 10-gram overlap with pretraining data, the underlying problem *topics* are drawn from widely used sources (LeetCode, MBPP, LiveCodeBench), so some indirect contamination risk on the algorithmic-familiarity dimension remains, discussed at length in Appendix B (see Section 2 above for the authors' mitigating argument).

---

## 7. Relevance to our Bash-verification direction

This is the section that matters for deciding whether/how to adapt VERINA's methodology to our project (LLM-generated Rust re-implementations of GNU/Bash utilities, differential-tested against a real-GNU oracle derived from frozen man pages).

### (a) What transfers directly

1. **The code + spec + proof triple as a target shape, even if the proof stays aspirational.** VERINA's core insight, that "does the code pass some tests" is a strictly weaker claim than "the code provably satisfies a formal spec," maps onto our own pipeline directly. We already produce two of VERINA's three artifacts (Rust impl, Bash test suite); VERINA suggests the natural next artifact isn't more tests, it's a **formal specification distinct from the test suite**, derived from the man page, expressed as explicit pre/post-conditions rather than only implicit in test assertions.

2. **The soundness/completeness spec-quality framework is the single most reusable idea here**, and it is close to something we already do implicitly. Our differential-testing pipeline against real-gnu, our `classify_divergence.py` 5-bucket classifier, and our `mut@k`/DEPC metrics already distinguish "spec too strict" from "spec too loose" in spirit. VERINA gives this a clean formal vocabulary we could adopt wholesale:
   - **Soundness** = the spec doesn't accept behavior that isn't actually correct (an unsound spec would let a buggy Rust reimplementation "pass").
   - **Completeness** = the spec doesn't reject behavior that is actually correct/documented (an incomplete spec would fail a correct implementation, or worse, silently fail to catch documented edge cases the man page requires).
   - The **positive-test-checks-completeness / negative-test-checks-soundness** split, and the **decide-then-property-test-then-unknown** cascade, is a genuinely practical pattern we could implement over our own `real-gnu` oracle: use real-gnu executions as "positive tests" and known-bad/edge-case invocations as "negative tests" for a candidate formal spec of a flag's behavior, exactly as VERINA does for a Lean postcondition.
   - VERINA's explicit finding that **proof-based spec evaluation is unreliable (<4%) while testing-based evaluation is robust (>40%)** (Table 5) is itself a transferable methodological lesson, independent of language: don't build our spec-quality metric on top of automated proving; build it on top of comprehensive differential testing, and treat any proof that does succeed as a bonus stronger guarantee, not the backbone.

3. **pass@k and modular independent evaluation of sub-tasks.** Evaluating CodeGen, SpecGen (if we add it), and ProofGen (if we ever add it) *separately* rather than only end-to-end is directly applicable to our round-based driver architecture, and would let us localize whether a given failure is "the Rust impl is wrong" vs. "the derived spec is wrong" vs. (eventually) "the alignment proof is wrong," mirroring VERINA's finding that these are dissociable failure modes with very different success rates.

4. **Decontamination discipline.** VERINA's 10-gram-overlap-against-the-stack check is a good template, but notably **our risk profile is worse than VERINA's**: VERINA's Lean solutions are novel by construction (freshly written, never existed before), so the check finds zero overlap almost by design. Our target utilities (`cp`, `mv`, `sudo`, etc.) and their C source and man pages are near-certainly present verbatim in pretraining corpora. This means our decontamination story cannot rely on "the artifact is novel"; it has to rely on argument by construction (frozen man page + genuinely novel Rust translation + real-gnu behavioral oracle, not memorized GNU coreutils source) the way our project's `CLAUDE.md` already frames it, and VERINA's clean-decontamination result is *not* precedent we can claim for ourselves.

### (b) What does not transfer

1. **VERINA's programs are pure, terminating, side-effect-free Lean functions over algebraic data (`List Int`, `Array Int`, `Nat`).** Every one of the 189 problems is closed: fixed input, deterministic output, no external state. GNU utilities are the opposite of this on every axis:
   - They perform **I/O and mutate global, shared, ambient state**: the filesystem tree, inode metadata, permission bits, the environment, `stdin`/`stdout`/`stderr`, sometimes the TTY, sometimes other processes (`sudo`, signals). A Lean postcondition of the VERINA shape (`Prop` over pure inputs/outputs) has no natural slot for "and also this directory now exists with these permissions and this parent-directory mtime changed."
   - Some utilities are **intentionally non-terminating** (`tail -f`, `watch`, `yes`) or their termination is a function of interactive/external input, which sits entirely outside VERINA's total-function model (Lean requires proving termination to even *state* a function in the base logic; the whole benchmark is implicitly restricted to problems where that's tractable).
   - VERINA's "reference implementation" is a Lean function; **ours is a foreign binary** (GNU coreutils C source, or literally an opaque process boundary) with no machine-checked semantics at all. There is no Lean (or any proof assistant) formalization of "what GNU `cp` does" to prove *against*; we would first have to build one, which is a research project in its own right (compare: CompCert formalized C semantics over a decade of dedicated work; there is no comparable formalization of the Linux syscall/VFS layer usable off the shelf in Lean today).

2. **The "ground truth spec" premise breaks down for us in a way it doesn't for VERINA.** VERINA's ground-truth specs are hand-written and hand-verified by the paper's authors, and are treated as unimpeachable; the entire soundness/completeness apparatus is defined *relative to* that trusted ground truth. Our own prior research (see `docs/research/decisions.md`, the man-page-vs-POSIX divergence-mining work in memory) has already established that **our "ground truth" is itself contested**: the man page, POSIX, and the real binary's actual behavior diverge from each other, sometimes because the man page is simply wrong (omission-dominant defects, e.g. EXIT STATUS undocumented in 41/47 mined utilities) and sometimes because POSIX and the man page disagree on deleted/legacy constructs. VERINA never has to ask "which of my three sources of truth do I even trust here"; we do, on essentially every utility.

3. **The proof target language mismatch is structurally deeper than a syntax difference.** VERINA's code, spec, and proof are all Lean, so "prove the code satisfies the spec" is a same-language, same-logic exercise (Lean checking Lean). For us, code is Rust, the informal spec source is English prose (a man page), and any proof would need a third formal system (Lean, or some other proof assistant) capable of modeling *both* Rust program semantics *and* enough of a POSIX/Linux filesystem and process model to state a meaningful postcondition. That's not a translation step, it's building two new formal models (a Rust semantics embedding and a filesystem/OS model) before the VERINA-style machinery could even be applied. Nothing in VERINA addresses this because VERINA never needed a semantics for anything other than Lean itself.

4. **VERINA's anti-gaming device (prove against the *ground-truth* spec in the end-to-end task) presupposes a ground-truth spec exists to prove against.** For Bash utilities, there frequently isn't one authoritative ground-truth postcondition to target: the man page is prose, not a `Prop`, and turning it into one *is* the open research problem, not a solved precondition of the benchmark the way it is for VERINA.

### (c) What the ~11% (best case) / ~4.9% (best general-purpose LLM) proof success rate implies for feasibility

This is the sharpest and most useful number in the paper for calibrating expectations, and it should be read as an **upper bound**, not a representative estimate, on how well LLM-based proving would do on anything Bash-shaped:

- VERINA's ProofGen task is close to the best case realistically achievable for LLM theorem proving today: **finite, decidable, side-effect-free, list/array/int reasoning**, with 2-shot prompted general LLMs *and* two theorem-provers trained specifically for Lean proof search (Goedel-Prover-V2, DeepSeek-Prover-V2), plus an agentic tree-search framework (Copra) given up to 64 queries, plus a 64-round compiler-feedback refinement loop. Even stacking all of that, the best single number anywhere in the paper is **11.2%** pass@1 (Goedel-Prover-V2-32B), rising to **20.1%** only with 64 rounds of iterative refinement and a real cost increase, and the best *general-purpose* frontier model (o3) manages only **4.9%**.
- Even the *strictly easier* sub-problem of proving a soundness/completeness relation about a spec (a simpler proposition than full functional-correctness alignment) succeeds via formal proof **under 4% of the time** (Table 5). The paper's own testing-based fallback exists precisely because proving essentially doesn't work yet, even in this friendliest-possible setting.
- Real Unix-utility verification would need to state and prove properties over a *strictly harder* space: quantifying over filesystem trees, byte streams, error/errno codes, environment variables, and time-dependent state, with no equivalent of Lean's `Mathlib`/`plausible`/`decide`/`simp`/`aesop` automation tuned for that domain (those tactics are tuned for algebra, lists, and arithmetic, not POSIX semantics), and with essentially zero training data of "proofs about filesystem operations in Lean" for a Lean-tuned prover to have learned from (contrast with the abundant math-competition-style Lean/Mathlib corpus that Goedel-Prover-V2 and DeepSeek-Prover-V2 are trained on).
- **Practical implication for our roadmap**: auto-proving that our Rust reimplementation of `cp`/`mv`/`sudo` satisfies a man-page-derived spec is not a near-term automatable target with current LLM-based theorem proving. VERINA shows the field can't yet reliably do this for the *easy* version of the problem. The right move, mirrored directly from VERINA's own methodological choice, is to **build the soundness/completeness spec-quality machinery on top of our existing differential-testing oracle (real-gnu) as the primary metric**, and treat formal proof as a strictly optional, future, best-effort layer, reserved, if pursued at all, for the small subset of utility behavior that actually is pure/stateless enough to formalize (e.g., pure string-formatting or arithmetic logic embedded inside a utility, not the filesystem side effects that define most of what these utilities actually do). VERINA's own Limitation #2, that its "simple, standalone" problems are already "not fully representative" of seL4/CompCert-scale verification, is itself the tell: verifying a real, stateful system utility sits on the far, expensive end of that spectrum, not adjacent to VERINA's benchmark at all.

---

## 8. Reference list

- Ye, Z., Yan, Z., He, J., Kasriel, T., Yang, K., Song, D. **VERINA: Benchmarking Verifiable Code Generation.** arXiv:2505.23135, ICLR 2026. (Primary source for this document.)
- Endres, M., Fakhoury, S., Chakraborty, S., Lahiri, S. K. **Can Large Language Models Transform Natural Language Intent into Formal Method Postconditions?** FSE 2024 / arXiv:2310.01831. (`nl2postcond`; cited by VERINA as related technique-level work on spec generation; local copy: `literature/endres_2024_postconditions.pdf`; confirmed indexed in Delphi as paper_id `944764c1-d3b1-4b8c-9518-1b782c1d05b1`.)
- Misu, M. R. H., Lopes, C. V., Ma, I., Noble, J. **Towards AI-assisted synthesis of verified Dafny methods.** (MBPP-DFY-50, one of VERINA's two Dafny-translation source datasets.)
- Sun, C., Sheng, Y., Padon, O., Barrett, C. **Clover: Closed-loop verifiable code generation.** (CloverBench, VERINA's second Dafny-translation source dataset.)
- Thakur, A., Lee, J., Tsoukalas, G., et al. **CLEVER: A curated benchmark for formally verified code generation.** arXiv:2505.13938. (Concurrent work; SpecGen + spec-guided CodeGen only, assumes ground-truth-spec access for certification; VERINA's direct point of comparison, Table 4.)
- Lin, Y. et al. **Goedel-Prover-V2.** arXiv:2508.03613. (Best specialized prover in VERINA's evaluation, 11.2% pass@1 / up to 20.1% with refinement.)
- Ren, Z. Z. et al. **DeepSeek-Prover-V2.** arXiv:2504.21801. (Second specialized prover evaluated.)
- Thakur, A. et al. **Copra: An in-context learning agent for formal theorem-proving.** arXiv:2310.04353. (Agentic tree-search prover, evaluated with o4-mini backbone.)
- Dougherty, Q., Mehta, R. **FVAPPS: Proving the coding interview.** arXiv:2502.05714. (4,715 Lean programs, fully automated pipeline, no human validation; VERINA's contrast case on quality control.)
- Lohn, E., Welleck, S. **miniCodeProps.** arXiv:2406.11915. (201 Haskell-to-Lean proof-generation-only benchmark.)
