# Evaluating Astrogator from natural-language formalization through verification

**Main contribution:** a measured implementation of the paper's proposed formalizer, connected to the actual verifier and evaluated against credible alternatives. A handbook derived from the existing FQL implementation substantially improves generated-query processing and preserves most supplied-query decisions across the full original corpus. A reproduced runtime counterexample explains why syntactic validity alone is insufficient.

This advances an unevaluated component of the local public-v2 paper; it does not claim a new general prompting technique or a fully automated guarantee of user intent. [Paper positioning](PAPER-ADVANCEMENT.md) maps the findings to replacement evaluation questions. The recent private submission may differ from public v2.

## 1. A working formalizer, with a matched intervention

Two models generate FQL for all 21 original tasks, with three fresh calls per task and prompt arm. The handbook replaces only the compact system guide; the same four demonstrations and target request remain. It documents the actual parser, semantic interface, and existing knowledge base. Its 48 source-derived signature checks all pass the real compiler.

| Model | Compact: compile /63 | Handbook: compile /63 | Compact: effect agreement /63 | Handbook: effect agreement /63 |
|---|---:|---:|---:|---:|
| GPT-6 requested alias | 36 | **63** | 27 | **53** |
| Opus 5.5 | 33 | **60** | 27 | **57** |

Effect agreement is equality of normalized compiler representations with the supplied query, not independent confirmation of user intent. The handbook adds both information and prompt length, so the intervention does not isolate the knowledge base's individual contribution. These are 21 tasks with repeated generations, not 63 independent problems. [Exact design](translation_method/README.md), [full results](integration/TRANSLATION.md).

## 2. The improvement survives connection to the actual verifier

Every generated query is applied to the supplied programs for its task using the **unchanged original verifier**. All model/guide/repeat combinations are retained: 26,856 processed logical program–query cells across 2,238 distinct program records. Exact duplicate inputs share a cached invocation; repetitions are not extra independent evidence.

Among the 1,528 programs decidable with the verbatim supplied-query control:

| Model | Compact: same decision | Handbook: same decision | Compact: became unavailable | Handbook: became unavailable |
|---|---:|---:|---:|---:|
| GPT-6 | 872 / 872 / 949 | **1,525 / 1,525 / 1,525** | 516 each | **0 each** |
| Opus 5.5 | 926 each | **1,469 each** | 595 each | **57 each** |

Three numbers denote the three separate repetitions. Remaining handbook differences are three verdict flips per GPT repetition and two per Opus repetition. Opus's unavailable results come from one query-processing failure repeated across attempts. The 710 programs already unavailable under the control are excluded from this primary denominator. Acceptance still carries assumptions and possible residual effects.

**This is decision preservation, not accuracy.** Supplied queries are controls, not independently adjudicated gold. The high decision agreement also does not erase the remaining effect mismatches: this finite corpus may fail to distinguish different specifications. Nine a18 decisions differ from the older corpus sweep because that sweep normalized a URL; the new paired control and generated queries both retain the supplied URL. [All21-task results](end_to_end/ALL-RESULTS.md), [exportable main figure](evaluation/figures-paper/paper-contribution.pdf).

## 3. A complete failure mechanism, reproduced at runtime

Request: “Delete the contents of the /home/mydata/web directory.” Compact GPT emits:

```text
delete contents of directory at /home/mydata/web
```

It parses and compiles, but the semantic analyzer takes the final noun and ignores preceding description words in this branch: the operation becomes **delete the directory**, not delete its contents. This changes 43 supplied rejections into acceptances on that task.

We selected one actual supplied program, `deepseek/p15/0`, and executed it in two frozen diagnostic fixtures. Both runs succeed but remove the parent directory. The compact query conditionally accepts it; the supplied query and all six handbook queries reject it. The relevant Debian-branch assumptions are checked operationally against the fixtures and successful privilege escalation. This is a deliberately selected counterexample, not an error-rate estimate or proof about every residual. [Code, ASTs, assumptions, and executions](end_to_end/A03-MECHANISM.md). A separate conservative [description guard](description_guard/README.md) rejects unused prefixes in explicit-path file/directory deletion instead of dropping them. Nine compiled regressions pass; replaying 21 supplied queries and 252 frozen translations changes only the three problematic compact a03 outputs. The guard makes those queries unavailable; it does not prove their candidate programs wrong. Main experiment binaries remain unchanged.

## 4. Strong baselines change the paper's empirical argument

The behavioral comparison covers 422 programs from four original tasks, or 233 conservative code structures. On the original local labels, GPT-6 judgment rejects 136/139 failures and accepts 283/283 passes. Default Astrogator rejects 56 failures, accepts 9, and cannot lower 74; configured heuristics reject 65, accept none, and remain unavailable on 74. This evidence does **not** support a blanket claim that Astrogator outperforms strong judges.

A whole-task rerun adds structural password-record checks and a separate final-newline interpretation. These change one false pass and eight newline-sensitive labels. Under strict labels, the verifier catches one GPT-accepted malformed-shadow program; its other three accepted failures are verifier-unavailable. Both strong judges reject all nine default-verifier-accepted failures. Most extra rejections relative to Opus depend on newline policy. Complementarity exists on this cohort, but must be described with exact identities and assumptions.

Generated declarative checks are also competitive: on the 420 resolved programs, three of four test sets miss one strict-label failure; the fourth misses nine. Two programs remain unresolved after infrastructure recovery. The models generate postconditions on researcher-provided initial states; reference gating supplies additional information after generation. All comparisons restrict methods to the same resolved IDs and retain each generated test set. The Python baseline also finished 844 states: 418 programs have resolved labels and four remain unresolved after execution timeouts. Both GPT test repetitions miss one strict-label failure on that resolved cohort. Thirteen of 16 generated Python test sets pass the gate; the three Opus gate abstentions arise from static-screen restrictions, not failing reference assertions. The joint comparison restricts every method to the same 416 programs resolved in both test arms. [Full judge comparison](evaluation/FRONTIER-FULL-COMPARISON.md), [joint matched checks](evaluation/COMMON-ALL-CHECKS.md), [complementarity](evaluation/COMPLEMENTARITY.md).

## Supporting work and remaining judgment

The 70-task catalog consists of 21 original tasks plus 49 authored candidates. There are 52 processable formal queries and 18 unsupported additions; machine checks do not establish human-reviewed intent. Strengthened benchmark checks reject reproduced bypasses while preserving reference controls. Separate permission patches expose and address bounded representation problems; the opt-in prototype sacrifices 57 original-corpus decisions and is not an overall accuracy improvement. These belong primarily in supporting material. [Benchmark audit](benchmark_audit/README.md), [adequacy](adequacy/README.md), [permission semantics](permission_semantics/README.md).

Aaron's most important decisions are the intended FQL permission and preservation semantics, acceptable residual assumptions, and which candidate tasks merit inclusion. Broader human-reviewed execution labels are needed before a paper-wide method-ranking claim. The handbook uses task-related source knowledge; no unseen-domain claim is supported. CLI configurations and inference budgets differ, and global Claude plugin hooks remained active despite disabled model tools/MCP. Exact model-identity evidence, failed attempts, source hashes, and review limitations are retained in the [integration audit](integration_audit/REVIEW.md).

No changes have been merged upstream and no message has been sent to Aaron.
