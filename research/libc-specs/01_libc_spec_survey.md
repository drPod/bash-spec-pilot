# Survey: existing formal specifications of libc and adjacent semantics

Survey conducted 7 September 2026. **Reusable memory and I/O specifications exist, but this search did not establish a complete Lean-native libc library suitable for the project.** The practical question is the cost of adapting existing contracts, memory models and environment assumptions.

Evidence depth varies: some rows inspect source or papers, while others use abstracts or search results only. The last column records that distinction. Numerical inventories are preliminary source counts, not coverage or quality estimates. Version statements refer to the inspected release. The [I/O review](04_io_prior_art.md) examines the most relevant functional I/O work in more detail.

## 1. Required specification

The meeting's plan needs, for each libc function `f` a utility calls, a formal object that says
what `f` does to the program state (memory, streams, file system, environment) and what it
returns, in a form that (a) composes with a C semantics, (b) compiles to the State Calculus or to
Lean, and (c) is *executable* so the differential layer can check it against the real libc. The
complaint recorded in the notes ("fputs described only as 'updates the file pointer'") is a
complaint about depth: a footprint (`assigns`) clause without a functional postcondition.

## 2. Sources by role

| Need | Candidates identified | Main adaptation issue |
|---|---|---|
| Memory and string contracts | Frama-C, VST, VeriFast, VerKer | Preconditions and memory representations differ between systems. |
| Content-sensitive I/O | VeriFast I/O protocols, DeepWeb and interaction trees | Preserve external-operation assumptions and failure behavior. See the [I/O review](04_io_prior_art.md). |
| Filesystem behavior | SibylFS, FSCQ | Filesystem and crash models have different scopes; neither is a ready-made Lean libc. |
| C representation | CompCert/Clight, Cerberus; Lean IR work | A translation into Lean still needs a correctness argument. |
| Shell behavior | Smoosh, the project's State Calculus | Utility behavior and OS operations remain separate dependencies. |
| Executable library models | KLEE's libc/runtime, angr summaries | Executability alone does not establish contract correctness. |

The detailed inventory below preserves the original counts, source locations and inspection depth. Entries based only on abstracts or search results need further source review before supporting a paper claim.

<details>
<summary>Detailed inventory of 19 systems and libraries</summary>

| # | Artifact | What is specified | State modelled | Formalism / host | Depth | Machine-checked? | Reusable for us? | Verified how |
|---|---|---|---|---|---|---|---|---|
| 1 | **Frama-C libc** (`share/libc`, Frama-C 30.0 Zinc) | 1,111 `extern` function declarations across 155 headers; `ensures` clauses: string.h 88, stdlib.h 83, unistd.h 42, stdio.h 33 (of 78 externs), fcntl.h 6 | Memory: yes (ACSL `\valid`, `\initialized`, `assigns ... \from`). Streams: **no contents**. `FILE` is `struct __fc_FILE { unsigned int __fc_FILE_id; unsigned int __fc_FILE_data; }`. File descriptors: ghost array `__fc_fds[fd]`, no contents | ACSL (first-order contracts over C memory), consumed by Frama-C WP/Eva | **string/memory: functional** (e.g. `strcpy`: `ensures strcmp(dest,src) == 0`; `memcpy`: `ensures memcmp{Post,Pre}(dest,src,n) == 0`). **stdio/fd I/O: footprint only** (see §3) | Contracts are checked when a client is verified with WP; the headers themselves are trusted axioms | Not directly (ACSL is not Lean); but the `assigns` footprints are an independent reference for "which state component does `f` touch", and the string.h postconditions are a ready-made list of properties to prove of a Lean model | Release tarball `frama-c-30.0-Zinc.tar.gz` from frama-c.com, files `share/libc/stdio.h` (lines 289–304, 323–334), `__fc_define_file.h` (33–37), `string.h` (158–160, 420–426), `unistd.h` (1026–1035, 1160–1166); counts by `grep -c` |
| 2 | **VeriFast** prelude (`bin/stdio.h`, GitHub master) | stdio declarations with separation-logic contracts | Streams as an abstract `file(fp)` predicate, **no contents** | VeriFast separation logic (symbolic execution) | Footprint/ownership only: `fputs`: `requires [?fs]string(s, ?cs) &*& [?ff]file(fp); ensures [fs]string(s, cs) &*& [ff]file(fp)`; `getchar`: `requires true; ensures true`; `putchar`: `ensures c == result \|\| EOF == result` | Prelude is trusted | The inspected default header is shallow; alternative `stdio_simple.h` and I/O examples have functional protocols (see `04_io_prior_art.md`) | Fetched `raw.githubusercontent.com/verifast/verifast/master/bin/stdio.h` 2026-09-07 |
| 3 | **VST / Verifiable C**, "Verif_strlib" (Software Foundations vol. 5) | `strlen`, `strcpy`, `strcmp` (the latter "underspecified" per the chapter) | C memory via separation logic; C strings as `cstring sh s str` (byte list, no embedded zeros, terminating zero) | Coq (Rocq), VST funspecs over CompCert Clight | Functional: `strlen` returns `Zlength s`; `strcpy` postcondition `cstringn wsh s n dest` | Yes (Coq proofs of the implementations) | Model of specs, not code: the `cstring` representation is exactly the kind of heap predicate a Lean heap model needs; Coq is not Lean | Fetched softwarefoundations.cis.upenn.edu/vc-current/Verif_strlib.html 2026-09-07 |
| 4 | **VerKer** (Efremov & Mandrykin; arXiv 1809.00626; GitHub `evdenis/verker`) | Linux kernel `lib/string.c`-style functions: paper: 26 functions; repo README today lists 38 (`memchr, memcmp, memcpy, memmove, memset, strcat, strchr, strcmp, strcpy, strlen, strncpy, strnlen, strsep, strstr, ...`) | C memory (AstraVer/Jessie memory model) | ACSL + AstraVer (Frama-C plugin, Why3 backend) | Functional correctness contracts "extracted from their source code"; paper: 23/26 completely proved, 11 needing two new spec constructs, 2 after minor source changes, 1 unprovable in the existing memory model | Yes (deductive proofs) | A candidate functional contract corpus for the string/memory family; ACSL, so manual port | `literature/efremov_2018_verker_linux_libc.pdf` (abstract read); GitHub README fetched 2026-09-07 |
| 5 | **ACSL by Example** (Fraunhofer FOKUS, v33.0.1 for Frama-C 33.0) | C re-implementations of standard *algorithms* (STL-like: find, count, copy, sort, ...), not libc stdio | C arrays | ACSL/WP with Alt-Ergo, CVC5, Z3, Coq | Functional | Yes | Specification idioms only | GitHub README fetched 2026-09-07 (function list not confirmed) |
| 6 | **CN** (Pulte et al., POPL 2023, DOI 10.1145/3571194) + **Fulminate** (POPL 2025) | Verifier for systems C (pKVM buddy allocator); Fulminate tests CN specs at runtime | C memory via separation-logic refinement types over Cerberus semantics | Cerberus/Core, SMT | Functional for user code; no libc corpus found | Yes (SMT-checked) | Idea-level: Fulminate's "test the spec against the implementation" is the same move as our differential layer | **search only** (abstract pages) |
| 7 | **Cerberus** (Memarian et al., PLDI 2016; UCAM-CL-TR-981) | Executable semantics of a large C11 fragment via elaboration to Core | C memory object model (provenance) | Lem/OCaml | Language semantics, libc external | n/a | The C-side reference if a C→calculus compiler is built; Lem has no Lean backend | **search only** |
| 8 | **K C semantics** (`kframework/c-semantics`, kcc / RV-Match) | C11 semantics incl. undefined behaviour | C memory in K configurations | K rewriting | README: "KCC comes by default with relatively limited support for the C library ... [RV-Match] linking against the native code provided on your system" | Executable, not proof | Confirms the pattern: C semantics projects leave libc to the native library | **search only** (README quote via search) |
| 9 | **CompCert** | Verified C compiler; external calls (incl. libc) are trace events with axiomatized properties | CompCert memory model | Coq | n/a for libc | n/a | Clight is a candidate IR; invoking `clightgen` alone does not establish a verified C-to-Lean translation | Leroy, CACM 2009; not re-read today |
| 10 | **KLEE** (+ klee-uclibc, POSIX runtime) | Symbolic execution of C; libc = "modified ... uClibc C library implementation for use with KLEE" linked as bitcode (`--libc=uclibc`), plus "a POSIX runtime ... to provide the majority of operating system facilities used by command line applications" | Concrete/symbolic memory | LLVM IR interpreter | Implementation, not spec | no | Shows the "use the real implementation as the spec" option; its classic evaluation target is GNU coreutils | klee-se.org "Testing Coreutils" tutorial fetched 2026-09-07 |
| 11 | **angr SimProcedures** | Python summaries of libc functions (`printf`, `scanf`, `puts`, `atoi`, ...) | angr symbolic state | Python | Executable models, "far from perfect ... buggy/incomplete" (docs) | no | Closest existing *executable libc model corpus*; informal, untested against a spec | docs.angr.io via search result quotes |
| 12 | **SibylFS** (Ridge et al., SOSP 2015) | "the range of allowed behaviours of a file system for any sequence of the system calls within our scope"; POSIX plus Linux/OS X/FreeBSD variants; 21,000+ tests; ~40 configurations tested | File system incl. contents, at the syscall layer | Lem → HOL4, Isabelle/HOL, OCaml (per sibylfs.github.io) | Functional, nondeterministic envelope | Model is executable and was used as a test oracle; not a proof of a system | The reference for what `open/read/write/...` must mean; no Lean backend | `literature/ridge_2015_sibylfs.pdf` abstract read; backends from project site via search |
| 13 | **FSCQ** (Chen et al., SOSP 2015; `mit-pdos/fscq`) | Verified file system; "specifications for a subset of the POSIX system calls" in Crash Hoare Logic | Disk + FS state | Coq | Functional + crash safety | Yes | Coq; a second reference for fs-call semantics | **search only** |
| 14 | **Smoosh** (Greenberg & Blatt, OOPSLA 2020) | POSIX shell semantics parameterised over an OS typeclass of ~40 calls; symbolic FS **without file contents**; utilities opaque via `execve` | Shell state; coarse FS | Lem (OCaml/Coq/HOL4/Isabelle) | Shell language functional; syscall layer abstract | Executable, tested against POSIX suites | Lists the syscall surface a shell needs; no Lean backend | `literature/greenberg_2019_smoosh.pdf` (see `research/lean-verification/03_*.md` §4) |
| 15 | **Astrogator MDL** (Councilman et al., POPL 2027 submission; prelim ch. 4–5) | Per-module descriptions (Ansible); hand-written utility specs for one Bash script (`tee`, `wc`, `gzip`, Fig. 4.1) | State Calculus: attributes + elements (files, fds as `fd(0).kind`), no byte-level memory | State Calculus, symbolic interpreter | Coarse functional | Symbolic execution, not proof | It *is* our target calculus; the gap it names (utility specs) is what libc specs replace | `POPL_2027_Astrogator.pdf` §5.2; `literature/councilman_2025_prelim_proposal.pdf` ch. 4–5 |
| 16 | **Caruca** (Lamprou et al., arXiv 2510.14279) | Mined *utility-level* specs: parallelizability, input/output files, fs pre/postconditions, for 60 commands (59/60 correct); syntax inference correct on 99.7% of flags over 120 commands | FS effects observed via syscall tracing | JSON/YAML/Haskell adapters for PaSh/POSH/Shellcheck/Shseer | Coarse, property-level; "does not generate environment variables"; finite invocation coverage | No (dynamic mining) | Method, not artifact: LLM reads docs → structured syntax → execute + trace → derive spec; directly transferable to libc functions (§ approach) | `literature/caruca_2025_spec_mining.pdf` read (abstract, §2 limitations, §6) |
| 17 | **LeanCP** ("Toward Lean-Native C Program Verification", progress report, April 2026, ResearchGate 403194505) | "embeds a C memory model, value semantics, and control flow into Lean's type theory ... pointer arithmetic, bounded memory, and iterative control structures" | C memory in Lean 4 | Lean 4 | unknown | unknown | Potentially the closest thing to a Lean 4 C semantics; **abstract only**, page returned 403, no repository found | **abstract only** (search snippet) |
| 18 | **lean-mlir** (Bhat et al., ITP 2024, arXiv 2407.03685) | SSA IR calculus generic over dialects, MLIR frontend, LLVM bitvector rewrites verified | SSA values, regions | Lean 4 | Language semantics | Yes | Evidence that Lean 4 can host a production IR semantics with tactic support; LLVM-dialect subset could be a target for compiled C | `literature/bhat_2024_lean_mlir.pdf` abstract read |
| 19 | **CSLib** (arXiv 2602.04846, "The Lean Computer Science Library") | Lean 4 library for CS formalisation | unknown | Lean 4 | unknown | unknown | Check for reusable operational-semantics infrastructure | **search only** |

</details>

### LLM-based specification generation

| Work | Target | What is generated | Checked against | Headline | Verified how |
|---|---|---|---|---|---|
| nl2postcond (Endres et al., FSE 2024) | Python/Java | postconditions from docstrings | tests, Defects4J bugs | catches 64 historical bugs | `literature/endres_2024_postconditions.pdf` (prior notes) |
| AutoSpec (Wen et al., 2024) | C/C++ | ACSL specs + annotations | Frama-C | 79% of benchmark programs verified (per abstract via search) | `research/lean-verification/02_prior_art_landscape.md` |
| SpecGen (Ma et al., 2025) | Java | JML specs | OpenJML | 279/385 programs | same |
| **AutoACSL** (Zhou, Luo, Xu; arXiv 2606.20969, June 2026) | C | ACSL contracts incl. runtime-error guards, from LLM + Code Property Graph features, Frama-C/WP feedback loop | Frama-C/WP | 604 programs; 98% generation success, 96% full-proof ratio with Gemini-3; +24.7% to +51.7% full-proof over a code-only baseline across GPT-o4 Mini, GPT-5.2, Grok-4.1, Gemini-3 | `literature/zhou_2026_autoacsl.pdf` abstract read |
| **Beg, O'Donoghue, Monahan** (arXiv 2602.13851, Feb/Apr 2026) | C | one-shot ACSL annotations: rule-based script vs Frama-C RTE vs DeepSeek-V3.2, GPT-5.2, OLMo 3.1 32B | Frama-C/WP, several SMT solvers, CASP subset | "rule-based approaches remain more reliable for verification success, while LLM-based methods exhibit more variable performance" | `literature/beg_2026_llm_acsl_eval.pdf` abstract read |
| SpecSyn (Ma et al., arXiv 2604.21570, Apr 2026) | real-world programs | interprocedural specs, refined with semantic-non-equivalent mutations | verifier (unspecified in abstract) | >90% precision, 75% recall, 1071/1365 properties | arXiv abstract fetched |
| **SynVer** (Mukherjee & Delaware, arXiv 2410.14835, CoqPL 2025) | C | programs *and* VST/Rocq proofs from specs; syntactic restrictions to keep programs verifiable | VST | qualitative; no headline number in abstract | `literature/mukherjee_2024_synver.pdf` abstract read |
| VeCoGen (arXiv 2411.19275), CASP dataset (arXiv 2508.18798) | C | verified C from specs; evaluation dataset | Frama-C | — | **search only** |
| Caruca (row 16) | shell commands | syntax + behavioural properties | execution traces | 59/60 | read |

These works address different combinations of contract discovery, code generation, proof,
execution and testing. Their benchmark success rates are not directly comparable to this task.
The initial abstract-level review does not establish that no prior work generates or executes
library models. In particular, the I/O developments in `04_io_prior_art.md` are relevant to this
architecture and must appear in any paper's related work. Caruca supplies a useful trace-driven
specification-discovery pattern, but its utility-level scope differs from libc memory and I/O.

## 3. Findings

### 3.1 Default stdio contracts omit stream contents

Frama-C 30.0, `share/libc/stdio.h`:

```c
/*@
  requires valid_string_s: valid_read_string(s);
  assigns *stream \from s[0..strlen(s)], *stream;
  assigns \result \from indirect:s[0..strlen(s)], indirect:*stream;
*/
extern int fputs(const char * restrict s, FILE * restrict stream);

/*@
  assigns \result, *__fc_stdin \from *__fc_stdin;
*/
extern int getchar(void);

/*@
  assigns *__fc_stdout \from c, *__fc_stdout;
  assigns \result \from indirect:*__fc_stdout;
*/
extern int putchar(int c);
```

and `__fc_define_file.h`:

```c
struct __fc_FILE {
  unsigned int __fc_FILE_id;
  unsigned int __fc_FILE_data;
};
typedef struct __fc_FILE FILE;
```

These inspected contracts do not state a stream-content relation. That does not preclude
functional postconditions through ghost state or trace predicates in other specifications. Where Frama-C does give `ensures` on I/O they are range or initialization facts:
`fgetc`: `0 <= \result <= __FC_UCHAR_MAX || \result == EOF`; `read`: bounds on the result and
`\initialized(((char*)buf)+(0..\result-1))`; `write`: `\result == -1 || 0 <= \result <= count`.
These clauses support client-code analysis but do not supply the stream-content relation needed here.
VeriFast's default `bin/stdio.h` is similarly shallow; its alternative `stdio_simple.h`
and I/O examples have content-bearing contracts, as detailed in `04_io_prior_art.md`.

### 3.2 String and memory contracts provide reusable content

Frama-C `string.h` carries 88 `ensures` clauses with real content (`strcpy`, `strncpy` with two
behaviours, `memcpy`, `strcat`, `strchr` found/not-found), VerKer proves functional contracts of
23 kernel string/memory functions, and VST's `Verif_strlib` gives the separation-logic idiom
(`cstring`) for C strings in a prover. So for tier 1 of the approach document (memory functions),
substantial contract content can be reused. Their scope, memory models and preconditions
must still be reconciled. A Lean port needs a representation/refinement argument; the three
tool families are useful evidence, not mutually interchangeable trusted oracles.

### 3.3 SibylFS models filesystem behavior outside Lean

SibylFS gives an executable, nondeterministic model of file-system syscalls with contents and uses
it as a test oracle, in Lem with HOL4/Isabelle backends. There is no Lean backend for Lem (already
established for Smoosh in `research/lean-verification/03_*.md`). SibylFS is a relevant
reference when writing `open/read/write/close/stat/unlink/rename` in Lean: it fixes the scope and
the allowed nondeterminism. Its reported 21,000-test suite is a candidate corpus for comparison after adapting the model interface.

### 3.4 Symbolic execution provides another class of library models

KLEE links a modified real libc (uClibc) as bitcode plus a hand-written POSIX runtime; angr
replaces libc with Python "SimProcedures" that the docs themselves call "far from perfect". These are two engineering approaches. They do not characterize the entire field;
functional trace contracts and executable formal effect models also exist (see `04`).

### 3.5 Lean-native C infrastructure was not established by this search

No mature Lean 4 C semantics with a libc was found. LeanCP (April 2026) claims a C memory model
in Lean 4 but I could only read its abstract. lean-mlir shows Lean 4 can host an LLVM-dialect
semantics with usable automation. This means a "C → calculus in Lean" step would either be written
by the group (as the meeting already assumes: "parser written but untested") or connected to an
existing verified front-end (Clight/Cerberus Core) with an unverified printer to Lean.

## 4. Answer to the meeting's question

Usable **scoped** memory and I/O specifications exist, including ACSL/VST memory predicates,
VeriFast's simplified stdio protocol and buffered-I/O examples, and VST/interaction-tree socket
contracts. None was established here to be a complete ready-to-import Lean libc for this project.
Adaptation costs include host logic, coverage, environment assumptions, memory representation,
allowed errors/nondeterminism, and correspondence to the particular libc implementation. SibylFS
is relevant filesystem/syscall prior art, not the sole substantive I/O model.

The checked example in `example/` shows the shape that *does* fit: an idealized libc call as a total state
transformer over explicit stream contents, composed with a manually authored MiniC semantics, proved about, and
diffed against GNU. The [historical proposal](02_spec_generation_approach.md) describes the next experiments; scalability was not established.
