# The foreign-language semantics gap: embedding and verifying non-Lean programs in Lean 4

Research note for the Astrogator-to-Lean pivot. Owner context: extending Astrogator
(formal verification of LLM-generated code) from Ansible toward Bash / Unix utilities,
now considering Lean 4 as the proof engine. This document is deliberately conservative
about difficulty. Where a claim is reasoning rather than a confirmed fact, it is marked.

## Why this document exists

VERINA (arXiv:2505.23135) is the anchor for the "verifiable code generation" shape: the
program, the specification, and the proof of their alignment all live in Lean, so the Lean
kernel checks everything natively. Our problem is not that problem. We want to say something
true about the behavior of a program that is *not* written in Lean: a Bash script, or the
real GNU `cp` / `mv` / `find` / `sudo` binary. To prove anything in Lean about such a program,
you must first encode that program's language semantics inside Lean and then prove theorems
against the encoded model. The fidelity of that encoding to the real language becomes its own
correctness burden.

A student's notes named the two hard, specific obstacles correctly:

- **(A) Lean reasons about itself better than about another language.** Reasoning about native
  Lean terms is essentially free, because the term *is* its meaning. A foreign language has no
  meaning inside Lean until you give it one, via a deep or shallow embedding of its operational
  or denotational semantics. The gap between that embedding and the real language is not
  provable inside Lean; it can only be tested or argued informally.
- **(B) Every program you can talk about as a Lean function terminates.** Lean's logic is total.
  A `def` is admitted into the kernel only if it is proven terminating (structurally or by a
  well-founded measure); otherwise the logic would be inconsistent. Real shell programs can loop
  forever (`while true; do ...`), so they cannot be modeled as ordinary Lean functions. You need
  step-indexed / fuel-based functions or relational (inductive `Prop`) semantics.

The rest of this note surveys how the landmark verified-semantics projects handle exactly (A)
and (B), what Lean 4 actually provides, whether Smoosh is reusable, how effects and the
filesystem get modeled, and what is honestly tractable for an undergraduate project this year.

## 1. Deep vs shallow embedding

Confirmed definitions (multiple sources, see references):

- **Shallow embedding.** The guest language's constructs are translated directly into
  constructs of the host logic, the way a compiler lowers source to target. There is no
  datatype for the guest's syntax; a guest program becomes a native Lean term, and you inherit
  Lean's own evaluation and equational theory. Adding a new guest construct is cheap. There is
  little inductive-proof overhead because you are not reasoning over an AST, you are reasoning
  about ordinary Lean values.
- **Deep embedding.** The guest's syntax is reified as a Lean datatype (an `inductive` AST), and
  its semantics is defined as a separate function or relation over that AST, like building a
  virtual machine. This is what lets you do meta-level reasoning: quantify over all programs,
  give multiple interpretations, prove properties of the language itself, or reason about
  optimizations. The cost is verbosity and heavy use of inductive proofs, which resist
  automation.

Tradeoff summary that the literature agrees on: shallow wins on linguistic reuse and low proof
overhead; deep wins on meta-reasoning and executability of the syntax as data. Real systems
often mix the two.

**Verdict for our use case.** The unit we care about is *per-utility behavior* (what `cp` does
to a filesystem), not the shell grammar. Two sub-cases:

- To build a Lean *reference model of one utility* (the tractable near-term goal), a **shallow**
  embedding is correct: write `cp` as a Lean function (or relation) over an explicit
  filesystem-state model. You reuse Lean's evaluation, you get an executable model for free, and
  you avoid formalizing any grammar. This is the VERINA shape applied to a utility.
- To eventually verify *arbitrary real Bash scripts* against specs, you need a **deep** embedding
  of the shell language (an AST plus an interpreter/relation), because you must reason over
  programs you did not write. That is precisely what Smoosh is (deep-embedded shell semantics),
  and it is the long-horizon, expensive path.

The canonical pattern for bridging the two is seL4's: start with a deep embedding for fidelity to
the real language, then refine down to a shallow monadic embedding for tractable reasoning
(section 3). For a first Lean experiment we should not attempt that pipeline; we should stay
shallow and single-utility.

## 2. Problem (B): non-termination inside a total logic, and the exact Lean 4 mechanisms

This is the sharper of the two problems because it is a hard wall, not a fidelity question. The
Lean 4 mechanisms, confirmed:

1. **`def` with structural or well-founded recursion.** The default. Lean must see that some
   measure decreases on every recursive call (structural decrease, or a user-supplied
   well-founded relation with a decreasing proof). Only terminating functions are admitted.
   Unusable for a shell program that may loop forever.
2. **`partial def`.** Marks a function whose termination Lean does not check. Confirmed behavior:
   the kernel treats a `partial def` as an *opaque constant* (it only requires the return type be
   inhabited, so you cannot derive `False`). Critically, you **cannot reason about a `partial def`
   in the logic**: there are no equations to rewrite with, even for inputs that do terminate.
   `partial def` is a trap for verification: it compiles and runs, but proves nothing. Do not use
   it to model utility behavior.
3. **`partial_fixpoint` (Lean 4.17.0+, confirmed).** A newer construct that models a possibly
   partial function returning `Option`, without a termination proof, while still letting you prove
   facts about it (via a fixed-point / domain-theoretic interpretation). Promising, but younger
   and less battle-tested than the two options below; note it as an option, not the first choice.
4. **Relational (inductive `Prop`) operational semantics.** Define execution as an inductive
   relation, e.g. `BigStep : Config -> Result -> Prop` (big-step / natural semantics) or
   `Step : Config -> Config -> Prop` (small-step / SOS), where each constructor is one derivation
   rule. A `Prop` relation is **not** required to be a total function, so a program that never
   reaches a final configuration simply has no `BigStep` derivation, and a non-terminating
   small-step program has an infinite chain of `Step`s. This sidesteps totality entirely. It is
   the standard textbook route (Software Foundations' `Smallstep`, the Lean-forward logical
   verification course both formalize operational semantics this way) and it is the one to reach
   for first for anything that can loop.
5. **Fuel-indexed / functional big-step interpreter.** Write a total `def eval : Nat -> Config ->
   Option Result` that decreases the fuel `Nat` on each recursive unfolding and returns `none`
   ("ran out of fuel / timed out") when fuel hits zero. This is total (structural recursion on the
   fuel argument), executable, and you can still prove properties like "if `eval n c = some r`
   then the relational semantics also gives `r`". This is exactly CakeML's *functional big-step
   semantics* (Owens et al., ESOP 2016): a definitional interpreter made total by a clock. Smoosh
   uses the same idea under the name "fuel" (section 4). For an executable Lean model of a utility
   that has bounded internal loops, fuel is the clean choice.

**The specific mechanism to use.** For the first experiment, model execution as an **inductive
`Prop` relation** (big-step is simplest), and, if you also want to *run* the model, add a
**fuel-indexed total interpreter** and prove it sound with respect to the relation. Avoid
`partial def` outright. Consider `partial_fixpoint` only if a later need for a directly-executable
partial function outweighs its immaturity. For genuinely trivial utilities (`true`, `false`,
`echo`, `head -n k`), the computation is bounded and you may not need fuel at all, a plain
terminating `def` or a small relation suffices.

## 3. How the landmark projects handle (A) and (B)

All facts below were confirmed against project pages / papers (see references). None of these
systems is in Lean, which is itself an important finding: the mature ecosystems for
foreign-language semantics are Coq, Isabelle/HOL, and HOL4.

| System | Host prover | Embedding style | Non-termination (B) | Effects / world state |
|---|---|---|---|---|
| CompCert | Coq | deep (C AST -> operational semantics) | small-step LTS; divergence via coinductive/infinite behaviors | explicit memory model, state in the transition relation |
| seL4 | Isabelle/HOL | deep (C -> Simpl via C-parser) then shallow (state monad via AutoCorres) | monadic; loops handled in refinement | nondeterministic state monad with exceptions, explicit C memory model |
| CakeML | HOL4 | deep (ML AST) | functional big-step with a **clock (fuel)** | I/O and state threaded through the interpreter |
| K framework / C | Maude/LLVM (rewriting, not a prover) | deep (executable rewrite rules) | rewriting need not terminate; matching/reachability logic | configuration as a nested structure; state is part of the configuration |
| Iris | Coq | shallow program logic over a deeply-embedded lambda calculus | step-indexing + later modality `▷` | concurrent separation logic, resources as ghost state |
| Interaction Trees | Coq | shallow (coinductive free monad) | `Tau` (silent step) coinductively represents divergence | `Vis` events + event handlers interpret effects |

Detail on each, focused on the two problems:

- **CompCert (Coq).** C's semantics is a deep embedding: C (and each intermediate language) has an
  AST, and behavior is given by small-step operational semantics cast as labeled transition
  systems, made executable as a reference interpreter. Divergence is a first-class *behavior* of
  the LTS rather than a stuck total function, so (B) is handled by having the semantics be a
  relation over transitions, not a function that must return. This is the single closest template
  for "model a real language's execution as a relation."
- **seL4 (Isabelle/HOL).** The most instructive for (A). A dedicated **C parser (StrictC)**
  translates a C99 subset into `Simpl`, an imperative language deeply embedded in Isabelle with an
  explicit C memory model. **AutoCorres** then abstracts that deep embedding into a shallow
  *state-monad* embedding (nondeterminism + exceptions), and the proof is a *refinement* between
  abstract spec, monadic spec, and C. The gap between real C and the logic is bridged by trusting
  the parser + memory model, then doing all real reasoning on the shallow monadic layer. Lesson:
  fidelity to the real language and tractable reasoning are achieved by *two different embeddings
  connected by refinement*, not one embedding doing both jobs.
- **CakeML (HOL4).** Directly relevant to (B). Its *functional big-step semantics* is a purely
  functional definitional interpreter equipped with a **clock (fuel)** so that the function is
  total in the logic even for diverging programs. This is the proof that "make the would-be-partial
  interpreter total by counting steps" is a mainstream, end-to-end-verified technique, not a hack.
- **K framework, executable C semantics (Ellison & Rosu, POPL 2012).** A different style entirely:
  languages are defined by **rewrite rules** over program configurations, executed by Maude/LLVM
  backends, and verified via matching logic / reachability logic rather than embedded in a
  proof assistant. Non-termination is unproblematic because rewriting systems need not terminate.
  Relevant as a contrast: this is closer in spirit to Astrogator's own bespoke symbolic
  interpreter (section 5) than to the Lean-proof approach, and it shows that "executable semantics
  as rewriting + a reachability checker" is a viable alternative to "embed in a total prover."
- **Iris (Coq).** A higher-order concurrent separation logic. Handles (B) via **step-indexing** and
  the **later modality `▷P`** ("P holds one step later"), which is what makes reasoning about
  recursive, effectful, possibly non-terminating and concurrent programs sound. Removing the later
  modality makes the logic inconsistent. Iris is the heavy artillery: only relevant if we later
  need to reason about concurrency or interleaved pipelines, which is far beyond a first experiment.
- **Interaction Trees (Xia et al., POPL 2019, arXiv:1906.00046).** A **coinductive** "free monad."
  A computation is an `itree E R` built from `Ret r` (halt with result), `Tau t` (silent internal
  step, whose explicit representation lets divergence be modeled coinductively without violating
  Coq's guardedness), and `Vis e k` (a visible event `e : E A` plus a continuation `k : A -> itree
  E R` consuming the environment's response). Effects are uninterpreted events; **event handlers**
  give them meaning as monadic actions, so the pure event-structure and its interpretation are
  cleanly separated. ITrees are executable via extraction and enjoy an equational theory up to weak
  bisimulation. This is the most principled way to model I/O + non-termination together, but it is
  a Coq library; there is no Lean port I could find (unconfirmed that a mature one exists).

## 4. Smoosh: the closest existing shell semantics, and whether it is reusable

Smoosh (Greenberg & Blatt, "Executable formal semantics for the POSIX shell", OOPSLA 2020,
arXiv:1907.05308; local PDF `literature/greenberg_2019_smoosh.pdf`) is the single most relevant
prior artifact. Confirmed facts from the paper:

- **Style.** A **small-step operational semantics** for the POSIX shell, deeply embedded. The two
  core stepping functions (`step_expansion`, `step_eval`) are ~1034 SLOC and correspond to the
  small-step relations for word expansion and command evaluation.
- **Meta-language.** Written primarily in **Lem** (Mulligan et al., ICFP 2014), ~10.8k SLOC total
  (9.3k Lem, 1.5k OCaml), using `libdash` (dash's parser). Lem is an ML-like specification language
  that generates code for **OCaml (testing), Coq, HOL4, and Isabelle/HOL (proof), plus LaTeX/HTML**.
  **Confirmed: Lem has no Lean backend.**
- **Non-termination (B).** Smoosh's symbolic stepper uses **fuel** to bound execution ("at the risk
  of nontermination, the fuel can be made infinite in the tracer"). Same clock idea as CakeML.
- **Effects (A).** Smoosh is *parameterized over an OS typeclass* with ~40 system calls (14 true
  syscalls, 24 filesystem calls, 2 parser interactions). Two instances exist: a `system` mode that
  makes real syscalls and a `symbolic` mode that simulates a POSIX OS and filesystem. The symbolic
  filesystem is deliberately coarse: a hierarchy of files and directories **without file contents**.
- **The crucial scoping fact for our project.** Smoosh formalizes the **shell language**: word
  expansion, control flow, redirections, the syscall *interface* (fork/execve/wait). It implements
  the special/mandatory builtins and a few others (`echo`, `printf`, `test`/`[`, `type`, ...). It
  does **not** formalize the per-utility semantics of external programs like `cp`, `mv`, `find`, or
  `sudo`; those are executed via `execve` and are opaque to Smoosh. This is exactly the project's
  key insight: *the shell language is formalized; the utility semantics remain informal.* Our
  research contribution lives in that gap.

**Reusability in Lean: low, and this should be stated plainly.**

- There is **no mechanical path** from Smoosh to Lean. Lem targets Coq/HOL4/Isabelle/OCaml, not
  Lean. You cannot press a button and get Lean definitions.
- Options if we wanted the shell language in Lean: (a) re-encode Smoosh's small-step rules by hand
  in Lean (large, and it would reproduce work that already exists in Coq/Isabelle); (b) write a
  Lem-to-Lean backend (a research project of its own, unconfirmed feasibility); (c) use Lem's Coq
  output and interoperate Coq with Lean (no sound bridge exists; effectively a non-starter).
- More importantly, **Smoosh does not solve our problem even if ported**, because it stops exactly
  where the utilities begin. What we need, a formal model of what `cp` does, is not in Smoosh and
  would have to be written from scratch regardless of host prover.

Practical use of Smoosh for us: as a **reference and validation oracle**, not as reusable code. Its
executable `system`/`symbolic` modes and its small-step rules are a high-quality guide to how the
shell surrounds a utility invocation, and a source of test cases. Treat it as documentation of the
shell layer, and build the utility models fresh in Lean.

## 5. Contrast with Astrogator's own approach

Astrogator (local `councilman_2025_astrogator.pdf` and `POPL_2027_Astrogator.pdf`) verifies
`p ∈ ⟦s⟧`, i.e. that a program `p` is in the set of programs satisfying spec `s`, using a **bespoke
symbolic interpreter plus unification**, not a proof assistant. Confirmed details:

- It compiles the target language (Ansible) into a **State Calculus**, an intermediate
  representation with its own symbolic interpreter (the indexed Delphi source shows this is
  hand-written OCaml: `lib/calculus/interp.ml`, `ast.ml`, with an `eval = Reduced | Stuck | Err`
  result type). Per-module behavior is supplied by a hand-written **Module Description Language**
  (e.g. a ~18-line description of `ansible.builtin.copy` over a coarse filesystem model that tracks
  path + system but not inodes/hard-links unless extended).
- The paper is explicit about the cost of the proof-assistant-style alternative: "One approach to
  prove correctness against a formal specification is to use symbolic execution. This requires the
  formal semantics of both the target and specification languages ... and a verification procedure
  that can prove equivalence between the two executions, a task that is often difficult to make
  scalable." Astrogator deliberately avoids that by doing bespoke symbolic execution + unification.
- On Bash (§7.2), Astrogator reports a **hand-translation** of one Bash script into the State
  Calculus plus a **hand-written spec**, and needs "definitions of the Linux utilities used in this
  script", i.e. the exact per-utility semantics gap. It also flags that **arbitrary `while` loops
  are hard** ("expanding to support these loops may be quite difficult as arbitrary loops are a
  common challenge in verification"), which is problem (B) surfacing inside Astrogator's own design.
- Related-work framing worth quoting for the pivot: Astrogator notes that generating proofs in Rocq
  (Coq) or Isabelle works because "the LLM generated proof can be checked ... by the theorem prover,
  but this approach does not generalize to general code where oracles for verifying correctness do
  not exist."

The contrast for the pivot: **Astrogator = bespoke symbolic interpreter + unification, no
termination worries because it is not a total logic, but every language and every utility needs a
hand-written model in its Description Language.** **Lean = a total logic with a trusted kernel and
LLM-checkable proofs, but you inherit both (A) the embedding-fidelity burden and (B) the totality
wall, and you must re-solve the per-utility modeling that Astrogator already does its own way.**
Moving to Lean buys kernel-checked proofs and an LLM-friendly proof target; it does not remove the
per-utility modeling work, and it adds the totality constraint.

## 6. Modeling I/O and filesystem effects

Real utilities read and write the filesystem and environment, so the model must carry a world state.
Confirmed techniques, ordered from simplest to heaviest:

- **Explicit state-passing / state monad.** Model the world as a plain Lean data structure: the
  filesystem as a finite map `Path -> FileContents × Metadata` (or a tree), the environment as
  `String -> Option String`, and thread it through the semantics: a utility is a function/relation
  `Args -> World -> World × ExitStatus`. This is what seL4 uses at its shallow layer (a state monad
  with nondeterminism and exceptions) and what Astrogator and Smoosh both do at a coarse grain
  (Smoosh omits file contents; Astrogator tracks path+system, omits inodes). **Recommended for the
  first experiment** because it is the least machinery and matches the coarse fidelity that the
  prior art already found adequate.
- **Free monad / Interaction Trees.** Represent the program as a tree of *uninterpreted* effect
  events with continuations, then give effects meaning with a separate handler/interpreter. Cleanly
  separates "what effects the program requests" from "how the world answers," and handles
  divergence coinductively (`Tau`). This is the principled option if we later need interleaving
  (pipelines), multiple interpretations of the same effect surface, or a divergence-aware model.
  Coq-native; a Lean port would be extra work. Defer.
- **Separation logic (Iris-style).** Only if reasoning about aliasing, sharing, or concurrency
  becomes central. Overkill for a single sequential utility. Defer indefinitely.

For fidelity, the honest point is that any of these models the *filesystem we invent*, not the real
kernel's filesystem. SibylFS (Ridge et al., SOSP 2015) is the reference for how exacting a real
POSIX filesystem spec has to be; we should not try to match it. The pragmatic answer is a coarse
model plus **differential validation against the real GNU binary** to bound the fidelity gap
empirically (section 8).

## 7. The two framings: "embed real Bash" vs "generate a Lean model"

**Path A: embed real Bash and verify the real binary.** Deep-embed the shell language in Lean
(re-create Smoosh-in-Lean), model each utility's semantics, encode the real binary's behavior, and
prove the script meets a spec.

- Pros: this is the "verify the thing that actually runs" dream; results would transfer to real
  scripts.
- Cons: pays the full price of (A) and (B). You must formalize the shell grammar and expansion
  (Smoosh is ~10k SLOC and is *only* the shell layer), add per-utility models, handle arbitrary
  loops with relational/fuel semantics, and still cannot prove the embedding faithful to the real
  shell inside Lean. Nothing is reusable from Smoosh mechanically. This is a multi-year effort and
  is not an undergraduate first experiment.

**Path B: generate a Lean model (the VERINA shape, adapted).** The LLM generates, in Lean, a
*reference implementation* of the utility, a *specification*, and a *proof* that the two align. The
real binary is used only for **differential validation of the Lean model** (does the Lean model
agree with GNU on sampled inputs?), never as the object of the proof.

- Pros: everything the proof touches is native Lean, so (A) collapses to "does my Lean model match
  the real utility?", which is answered empirically by differential testing rather than by an
  in-logic faithfulness proof. (B) is manageable because you choose utilities and model them with
  relational/fuel semantics. It is exactly the workflow VERINA studies, so there is a benchmark and
  tooling precedent.
- Cons: the proof does not certify the real binary, only the Lean model of it. The trust chain is
  "Lean proof about model" + "differential evidence that model ≈ binary." That is weaker than Path A
  in principle, but it is honest and it is the only version that is achievable soon.

**Recommendation: Path B.** It sidesteps both (A) and (B) as blocking problems, reuses the project's
existing strength (differential testing against the trixie GNU oracle), and matches the anchor
paper's shape. Path A is the eventual research frontier, not the starting point. This also inverts
the current project's data flow in a productive way: the frozen man page becomes the source for the
*spec*, the LLM writes the Lean *model + proof*, and the real binary validates the model.

## 8. What is actually tractable

Be blunt about the numbers. VERINA reports (confirmed from arXiv:2505.23135) that for pure Lean
functions the best frontier model (OpenAI o3) reaches **72.6% code correctness, 52.3% sound-and-
complete specs, and only 4.9% proof success (pass@1)**. (The project brief cited "~11%"; the paper's
headline is 4.9% pass@1, and I could not find an 11% figure, so treat single-digit proof success as the
planning assumption.) The proof step is the bottleneck by an order of magnitude, and that is *before*
any of the foreign-language complications in this document. Any plan that assumes the LLM will
routinely close proofs about `cp` or `sudo` is unrealistic this year.

Given (A), (B), and the ~5% proof reality, a realistic first target:

1. **Pick a trivial, terminating utility.** `true` / `false` (exit status only), `echo` (argument
   joining + trailing newline), or `head -n k` (bounded read). These have no unbounded loops, so (B)
   barely bites; `head` reads at most `k` lines, so even its loop is bounded and needs at most fuel,
   not coinduction.
2. **Shallow-embed it as a Lean model over a coarse world state** (section 6): a state-passing
   function/relation over a finite-map filesystem + argv + env. No shell embedding, no `execve`.
3. **Write one small spec as a Lean predicate.** Examples that are provable by hand or with light LLM
   help: `true` exits `0`; `echo` with no args outputs exactly `"\n"`; the output of `head -n k`
   has at most `k` lines; `echo` output equals `String.intercalate " " args ++ "\n"`.
4. **Prove exactly that one property.** Keep it small enough that a human can finish what the LLM
   starts. Do not aim for full functional correctness of the utility.
5. **Use fuel + a relational semantics only where a loop exists.** For `true`/`false`/`echo`,
   plain terminating `def`s suffice. For `head`, a fuel-indexed interpreter proven sound against a
   big-step `Prop` relation is the clean pattern, and doubles as a worked example of handling (B).
6. **Validate the model against real GNU `head`/`echo`** (trixie oracle) on sampled inputs. This is
   the empirical answer to (A): it does not prove faithfulness, but it bounds the gap and it is
   honest about what the Lean proof does and does not cover.

Explicit non-goals for the first experiment: no real-Bash embedding, no `sudo` (its behavior is a
policy-gated syscall model, not a data transformation, and is a poor fit for a first model), no
non-terminating utilities, no attempt to match SibylFS-level filesystem fidelity, no expectation of
high LLM proof-close rates.

The publishable contribution is not a number. It is the worked demonstration that the VERINA shape
extends from self-contained puzzles to *real-utility reference models validated against the real
binary*, together with an honest map of where (A) and (B) block the "verify real Bash" dream. That
map is the research output.

## Bottom line

- **Deep vs shallow:** shallow for a single-utility Lean model now; deep only for the eventual
  arbitrary-Bash goal. Follow seL4's deep-then-refine-to-shallow pattern only if that goal is ever
  pursued.
- **Non-termination (B):** model execution as an **inductive `Prop` relation** (big-step first),
  and add a **fuel-indexed total interpreter** proven sound against it when you need to run the
  model. Never use `partial def` for anything you want to prove about; `partial_fixpoint` is a
  newer fallback, not the first tool.
- **Effects (A):** explicit **state-passing over a coarse filesystem/env data structure**; escalate
  to Interaction Trees or Iris only if divergence-aware effects or concurrency become central.
- **Smoosh:** not mechanically reusable in Lean (Lem has no Lean backend), and it stops exactly at
  the utility boundary anyway. Use it as a reference oracle for the shell layer, not as code.
- **Recommendation:** take Path B (generate a Lean model + spec + proof, validate the model against
  the real binary), start with `echo`/`true`/`head`, prove one small property, and be explicit that
  the proof certifies the Lean model, not the real binary.

## References

Confirmed via web search (arXiv abstracts / project pages) or the local PDFs unless marked.

- **VERINA.** Ye et al., "VERINA: Benchmarking Verifiable Code Generation," arXiv:2505.23135, 2025.
  189 Lean tasks; best model o3 at 72.6% code / 52.3% spec / 4.9% proof (pass@1). Anchor paper.
- **Astrogator.** Councilman et al., "Towards Formal Verification of LLM-Generated Code from
  Natural Language Prompts," POPL 2027 submission (local `POPL_2027_Astrogator.pdf`) and
  `literature/councilman_2025_astrogator.pdf`. State Calculus, symbolic interpreter + unification,
  Module Description Language; §7.2 Bash discussion.
- **Smoosh.** Greenberg & Blatt, "Executable formal semantics for the POSIX shell," PACMPL OOPSLA
  2020, arXiv:1907.05308 (local `literature/greenberg_2019_smoosh.pdf`). Small-step POSIX shell
  semantics in Lem; OS typeclass; fuel; no per-utility semantics.
- **Lem.** Mulligan, Owens, Gray, Ridge, Sewell, "Lem: reusable engineering of real-world
  semantics," ICFP 2014. Backends: OCaml, Coq, HOL4, Isabelle/HOL, LaTeX, HTML. No Lean backend.
- **Interaction Trees.** Xia, Zakowski, He, Hur, Malecha, Pierce, Zdancewic, "Interaction Trees:
  Representing Recursive and Impure Programs in Coq," POPL 2019, arXiv:1906.00046. Coinductive free
  monad; `Ret`/`Tau`/`Vis`; event handlers; divergence via `Tau`. (Coq library; no confirmed Lean
  port.)
- **CompCert.** Leroy, "Formal verification of a realistic compiler," CACM 2009; Blazy & Leroy,
  "Mechanized semantics for the Clight subset of the C language," JAR 2009, arXiv:0901.3619.
  Deep-embedded C, small-step LTS, executable reference interpreter, in Coq.
- **seL4 / AutoCorres.** Klein et al., "seL4: Formal verification of an OS kernel," SOSP 2009;
  Greenaway, Lim, Andronick, Klein, "Don't sweat the small stuff: formal verification of C code
  without the pain," PLDI 2014. C-parser to `Simpl` (deep), AutoCorres to state-monad (shallow),
  refinement, in Isabelle/HOL.
- **CakeML functional big-step.** Owens, Myreen, Kumar, Tan, "Functional Big-Step Semantics,"
  ESOP 2016. Definitional interpreter with a clock (fuel) for totality in HOL4.
- **K framework / C semantics.** Ellison & Rosu, "An executable formal semantics of C with
  applications," POPL 2012; Rosu et al. on matching logic / reachability logic. Rewriting-based
  executable semantics; Maude/LLVM backends; not a proof assistant.
- **Iris.** Jung, Krebbers, Jourdan, Bizjak, Birkedal, Dreyer, "Iris from the ground up," JFP
  2018 (orig. POPL 2015). Higher-order concurrent separation logic in Coq; step-indexing; later
  modality `▷`.
- **SibylFS.** Ridge, Sheets, Tuerk, Giugliano, Madhavapeddy, Sewell, "SibylFS: formal
  specification and oracle-based testing for POSIX and real-world file systems," SOSP 2015.
  Reference point for how exacting a real filesystem spec is.
- **Lean 4.** de Moura & Ullrich, "The Lean 4 Theorem Prover and Programming Language," CADE 2021.
  `partial def` = opaque constant (no in-logic reasoning); `partial_fixpoint` added in Lean 4.17.0
  (release notes / J. Breitner, "Partially well-founded definitions in Lean," fixpt.de 2025);
  well-founded recursion and inductive `Prop` operational semantics are standard (Software
  Foundations `Smallstep`; Lean-forward logical verification course, operational-semantics lecture).
