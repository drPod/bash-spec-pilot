# Task

You are given the documentation of a program P (below: the POSIX specification
of `cut`). Produce, in Lean 4, three artifacts about a *model* q of P:

1. **Model**: a total Lean function implementing the documented behavior.
2. **Specification**: theorem statements capturing documented properties of P,
   quantified over all inputs in scope.
3. **Proof**: complete proofs of those theorems, checked by Lean's kernel.

Your output is compiled and kernel-checked, then the compiled model is run
head-to-head against the real program on random inputs. A compile error, a
rejected proof, or a behavioral mismatch comes back to you as feedback.

## Modeled scope

Model ONLY this slice of the utility: only `-c A-B` with 1 <= A <= B (a single closed character range); read stdin; per line emit characters A..B (1-indexed); lines shorter than A become empty lines.

## The contract (fixed)

Your entire output is one Lean module with exactly this shape:

- Everything inside `namespace Pipeline.Generated` ... `end Pipeline.Generated`.
- Define `def run (args stdin : List String) : List String × UInt32` — argv
  (excluding the program name) and stdin as a list of lines (no newline
  characters), returning (stdout lines, exit code).
- `run` and every helper must be TOTAL functions the kernel can reason about.
  Forbidden anywhere in the file: `partial`, `unsafe`, `axiom`, `sorry`,
  `admit`, `opaque`, `@[extern]`, `@[implemented_by]`, `native_decide`,
  `macro`, `elab`, and `import` lines (the module is compiled inside a project
  that already provides Lean core; Mathlib is NOT available).
- 3 to 6 spec theorems, each fully proved, each derived from the documentation
  (output shape, length bounds, content preservation, idempotence, relation
  between input and output, exit code). Universally quantify over inputs where
  meaningful; concrete-example theorems don't count toward the 3.
- Lean version: 4.31.0. Use core lemmas only (`List`/`String`/`Nat` from Init).

## Environment semantics

The harness reads stdin, splits on `\n`, drops the single trailing empty
element a final newline produces (so `"a\nb\n"` and `"a\nb"` both become
`["a", "b"]`), calls `run`, prints each returned line followed by a newline,
and exits with the returned code. Model behavior at this line-level
abstraction; never put `\n` inside a returned line.

## Documentation of P

The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="cut"></span> <span id="tag_20_28"></span>

#### <span id="tag_20_28_01"></span>NAME

> cut — cut out selected fields of each line of a file

#### <span id="tag_20_28_02"></span>SYNOPSIS

> `cut -b`` `*`list`*` `**`[`**`-n`**`] [`***`file`*`...`**`]`**\
> \
> `cut -c`` `*`list`*` `**`[`***`file`*`...`**`]`**\
> \
> `cut -f`` `*`list`*` `**`[`**`-d`` `*`delim`***`] [`**`-s`**`] [`***`file`*`...`**`]`**\

#### <span id="tag_20_28_03"></span>DESCRIPTION

> The *cut* utility shall cut out bytes (**-b** option), characters (**-c** option), or character-delimited fields (**-f** option) from each line in one or more files, concatenate them, and write them to standard output.

#### <span id="tag_20_28_04"></span>OPTIONS

> The *cut* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The application shall ensure that the option-argument *list* (see options **-b**, **-c**, and **-f** below) is a \<comma\>-separated list or \<blank\>-separated list of positive numbers and ranges. Ranges can be in three forms. The first is two positive numbers separated by a \<hyphen-minus\> (*low*-*high*), which represents all fields from the first number to the second number. The second is a positive number preceded by a \<hyphen-minus\> (-*high*), which represents all fields from field number 1 to that number. The third is a positive number followed by a \<hyphen-minus\> (*low*-), which represents that number to the last field, inclusive. The elements in *list* can be repeated, can overlap, and can be specified in any order, but the bytes, characters, or fields selected shall be written in the order of the input data. If an element appears in the selection list more than once, it shall be written exactly once.
>
> The following options shall be supported:
>
> **-b ***list*
>
> Cut based on a *list* of bytes. Each selected byte shall be output unless the **-n** option is also specified. It shall not be an error to select bytes not present in the input line.
>
> **-c ***list*
>
> Cut based on a *list* of characters. Each selected character shall be output. It shall not be an error to select characters not present in the input line.
>
> **-d ***delim*
>
> Set the field delimiter to the character *delim*. The default is the \<tab\>.
>
> **-f ***list*
>
> Cut based on a *list* of fields, assumed to be separated in the file by a delimiter character (see **-d**). Each selected field shall be output. Output fields shall be separated by a single occurrence of the field delimiter character. Lines with no field delimiters shall be passed through intact, unless **-s** is specified. It shall not be an error to select fields not present in the input line.
>
> **-n**
>
> Do not split characters. When specified with the **-b** option, each element in *list* of the form *low*-*high* (\<hyphen-minus\>-separated numbers) shall be modified as follows:
>
> - If the byte selected by *low* is not the first byte of a character, *low* shall be decremented to select the first byte of the character originally selected by *low*. If the byte selected by *high* is not the last byte of a character, *high* shall be decremented to select the last byte of the character prior to the character originally selected by *high*, or zero if there is no prior character. If the resulting range element has *high* equal to zero or *low* greater than *high*, the list element shall be dropped from *list* for that input line without causing an error.
>
> Each element in *list* of the form *low*- shall be treated as above with *high* set to the number of bytes in the current line, not including the terminating \<newline\>. Each element in *list* of the form -*high* shall be treated as above with *low* set to 1. Each element in *list* of the form *num* (a single number) shall be treated as above with *low* set to *num* and *high* set to *num*.
>
> **-s**
>
> Suppress lines with no delimiter characters, when used with the **-f** option. Unless specified, lines with no delimiters shall be passed through untouched.

#### <span id="tag_20_28_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an input file. If no *file* operands are specified, or if a *file* operand is `'-'`, the standard input shall be used.

#### <span id="tag_20_28_06"></span>STDIN

> The standard input shall be used only if no *file* operands are specified, or if a *file* operand is `'-'`. See the INPUT FILES section.

#### <span id="tag_20_28_07"></span>INPUT FILES

> The input files shall be text files, except that line lengths shall be unlimited.

#### <span id="tag_20_28_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *cut*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_28_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_28_10"></span>STDOUT

> The *cut* utility output shall be a concatenation of the selected bytes, characters, or fields (one of the following):
>
>
>     "%s\n", <concatenation of bytes>
>
>
>     "%s\n", <concatenation of characters>
>
>
>     "%s\n", <concatenation of fields and field delimiters>

#### <span id="tag_20_28_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_28_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_28_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_28_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> All input files were output successfully.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_28_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_28_16"></span>APPLICATION USAGE

> The *cut* and [*fold*](../utilities/fold.html) utilities can be used to create text files out of files with arbitrary line lengths. The *cut* utility should be used when the number of lines (or records) needs to remain constant. The [*fold*](../utilities/fold.html) utility should be used when the contents of long lines need to be kept contiguous.
>
> Earlier versions of the *cut* utility worked in an environment where bytes and characters were considered equivalent (modulo \<backspace\> and \<tab\> processing in some implementations). In the extended world of multi-byte characters, the new **-b** option has been added. The **-n** option (used with **-b**) allows it to be used to act on bytes rounded to character boundaries. The algorithm specified for **-n** guarantees that:
>
>
>     cut -b 1-500 -n file > file1
>     cut -b 501- -n file > file2
>
> ends up with all the characters in **file** appearing exactly once in **file1** or **file2**. (There is, however, a \<newline\> in both **file1** and **file2** for each \<newline\> in **file**.)

#### <span id="tag_20_28_17"></span>EXAMPLES

> Examples of the option qualifier list:
>
> 1,4,7
>
> Select the first, fourth, and seventh bytes, characters, or fields and field delimiters.
>
> 1-3,8
>
> Equivalent to 1,2,3,8.
>
> -5,10
>
> Equivalent to 1,2,3,4,5,10.
>
> 3-
>
> Equivalent to third to last, inclusive.
>
> The *low*-*high* forms are not always equivalent when used with **-b** and **-n** and multi-byte characters; see the description of **-n**.
>
> The following command:
>
>
>     cut -d : -f 1,6 /etc/passwd
>
> reads the System V password file (user database) and produces lines of the form:
>
>
>     <user ID>:<home directory>
>
> Most utilities in this volume of POSIX.1-2024 work on text files. The *cut* utility can be used to turn files with arbitrary line lengths into a set of text files containing the same data. The [*paste*](../utilities/paste.html) utility can be used to create (or recreate) files with arbitrary line lengths. For example, if **file** contains long lines:
>
>
>     cut -b 1-500 -n file > file1
>     cut -b 501- -n file > file2
>
> creates **file1** (a text file) with lines no longer than 500 bytes (plus the \<newline\>) and **file2** that contains the remainder of the data from **file**. (Note that **file2** is not a text file if there are lines in **file** that are longer than 500 + {LINE_MAX} bytes.) The original file can be recreated from **file1** and **file2** using the command:
>
>
>     paste -d "\0" file1 file2 > file

#### <span id="tag_20_28_18"></span>RATIONALE

> Some historical implementations do not count \<backspace\> characters in determining character counts with the **-c** option. This may be useful for using *cut* for processing *nroff* output. It was deliberately decided not to have the **-c** option treat either \<backspace\> or \<tab\> characters in any special fashion. The [*fold*](../utilities/fold.html) utility does treat these characters specially.
>
> Unlike other utilities, some historical implementations of *cut* exit after not finding an input file, rather than continuing to process the remaining *file* operands. This behavior is prohibited by this volume of POSIX.1-2024, where only the exit status is affected by this problem.
>
> The behavior of *cut* when provided with either mutually-exclusive options or options that do not work logically together has been deliberately left unspecified in favor of global wording in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04).
>
> The OPTIONS section was changed in response to IEEE PASC Interpretation 1003.2 \#149. The change represents historical practice on all known systems. The original standard was ambiguous on the nature of the output.
>
> The *list* option-arguments are historically used to select the portions of the line to be written, but do not affect the order of the data. For example:
>
>
>     echo abcdefghi | cut -c6,2,4-7,1
>
> yields `"abdefg"`.
>
> A proposal to enhance *cut* with the following option:
>
> **-o**
>
> Preserve the selected field order. When this option is specified, each byte, character, or field (or ranges of such) shall be written in the order specified by the *list* option-argument, even if this requires multiple outputs of the same bytes, characters, or fields.
>
> was rejected because this type of enhancement is outside the scope of the IEEE P1003.2b draft standard.

#### <span id="tag_20_28_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_28_20"></span>SEE ALSO

> [*2.5 Parameters and Variables*](../utilities/V3_chap02.html#tag_19_05), [*fold*](../utilities/fold.html#), [*grep*](../utilities/grep.html#), [*paste*](../utilities/paste.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_28_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_28_22"></span>Issue 6

> The OPTIONS section is changed to align with the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_28_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> SD5-XCU-ERN-171 is applied, adding APPLICATION USAGE.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0080 \[584\] is applied.

#### <span id="tag_20_28_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------


## Previous attempt feedback (round 1)

Your previous module (revise it; return the COMPLETE new module):

```lean
namespace Pipeline.Generated

def digitValue (c : Char) : Nat :=
  if 48 ≤ c.toNat ∧ c.toNat ≤ 57 then c.toNat - 48 else 0

def parseRangeAux : List Char → Nat → Nat → Bool → Nat × Nat
  | [], a, b, seen => (a, b)
  | c :: cs, a, b, seen =>
      if c = '-' then
        parseRangeAux cs a b true
      else if seen then
        parseRangeAux cs a (b * 10 + digitValue c) seen
      else
        parseRangeAux cs (a * 10 + digitValue c) b seen

def parseRange (s : String) : Nat × Nat :=
  parseRangeAux s.toList 0 0 false

def selectAux (a b i : Nat) : List Char → List Char
  | [] => []
  | c :: cs =>
      if a ≤ i ∧ i ≤ b then
        c :: selectAux a b (i + 1) cs
      else
        selectAux a b (i + 1) cs

def cutLine (a b : Nat) (s : String) : String :=
  String.mk (selectAux a b 1 s.toList)

def cutSpec (spec : String) (s : String) : String :=
  let p := parseRange spec
  cutLine p.1 p.2 s

def run (args stdin : List String) : List String × UInt32 :=
  match args with
  | ["-c", spec] => (stdin.map (fun s => cutSpec spec s), 0)
  | _ => ([], 1)

theorem select_length_le (a b i : Nat) (xs : List Char) :
    (selectAux a b i xs).length ≤ xs.length := by
  induction xs generalizing i with
  | nil => simp [selectAux]
  | cons x xs ih =>
      by_cases h : a ≤ i ∧ i ≤ b
      · simp [selectAux, h]
        exact Nat.add_le_add_right (ih (i + 1)) 1
      · simp [selectAux, h]
        exact Nat.le_trans (ih (i + 1)) (Nat.le_succ _)

theorem select_mem (a b i : Nat) (xs : List Char) :
    ∀ {c : Char}, c ∈ selectAux a b i xs → c ∈ xs := by
  induction xs generalizing i with
  | nil =>
      intro c h
      simp [selectAux] at h
  | cons x xs ih =>
      intro c hmem
      by_cases h : a ≤ i ∧ i ≤ b
      · simp [selectAux, h] at hmem
        rcases hmem with hmem | hmem
        · simp [hmem]
        · have ht : c ∈ xs := ih (i + 1) hmem
          simp [ht]
      · simp [selectAux, h] at hmem
        have ht : c ∈ xs := ih (i + 1) hmem
        simp [ht]

theorem run_valid_shape (spec : String) (lines : List String) :
    run ["-c", spec] lines =
      (lines.map (fun s => cutSpec spec s), 0) := by
  rfl

theorem cutLine_length_bound (a b : Nat) (s : String) :
    (cutLine a b s).toList.length ≤ s.toList.length := by
  unfold cutLine
  simpa using (select_length_le a b 1 s.toList)

theorem cutLine_content_preserved (a b : Nat) (s : String) {c : Char} :
    c ∈ (cutLine a b s).toList → c ∈ s.toList := by
  unfold cutLine
  simpa using (select_mem a b 1 s.toList)

theorem run_exit_code_on_valid_input (spec : String) (lines : List String) :
    (run ["-c", spec] lines).2 = 0 := by
  rw [run_valid_shape]
  rfl

end Pipeline.Generated
```

**Failure:** Lean build failed:
✖ [2/9] Building Pipeline.Generated (1.0s)
trace: .> LEAN_PATH=/Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean /Users/darshpoddar/.elan/toolchains/leanprover--lean4---v4.31.0/bin/lean /Users/darshpoddar/Coding/formal-verification/pipeline/lean/Pipeline/Generated.lean -o /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean/Pipeline/Generated.olean -i /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean/Pipeline/Generated.ilean -c /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/ir/Pipeline/Generated.c --setup /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/ir/Pipeline/Generated.setup.json --json
warning: Pipeline/Generated.lean:7:14: Variable name `seen` is not explicitly referenced.

The binding can be removed (if unused) or named `_` (if used implicitly).

Note: This linter can be disabled with `set_option linter.unusedVariables false`
warning: Pipeline/Generated.lean:28:2: `String.mk` has been deprecated: Use `String.ofList` instead
error: Pipeline/Generated.lean:46:8: Type mismatch
  Nat.add_le_add_right (ih (i + 1)) 1
has type
  (selectAux a b (i + 1) xs).length + 1 ≤ xs.length + 1
but is expected to have type
  (selectAux a b (i + 1) xs).length ≤ xs.length
error: Pipeline/Generated.lean:76:2: Type mismatch: After simplification, term
  select_length_le a b 1 s.toList
 has type
  (selectAux a b 1 s.toList).length ≤ s.toList.length
but is expected to have type
  (String.mk (selectAux a b 1 s.toList)).toList.length ≤ s.toList.length
error: Pipeline/Generated.lean:81:2: Type mismatch: After simplification, term
  select_mem a b 1 s.toList
 has type
  ?m.11 ∈ selectAux a b 1 s.toList → ?m.11 ∈ s.toList
but is expected to have type
  c ∈ (String.mk (selectAux a b 1 s.toList)).toList → c ∈ s.toList
error: Pipeline/Generated.lean:86:2: No goals to be solved
error: Lean exited with code 1
Some required targets logged failures:
- Pipeline.Generated
error: build failed



## Output format

Return JSON with two fields: `lean_source` — the complete module source,
starting with `namespace Pipeline.Generated` — and `spec_theorems` — one entry
per spec theorem you proved, each with `name` (the Lean identifier) and
`informal` (the documented property it captures, one sentence).
