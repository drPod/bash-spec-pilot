# Task

You are given the documentation of a program P (below: the POSIX specification
of `uniq`). Produce, in Lean 4, three artifacts about a *model* q of P:

1. **Model**: a total Lean function implementing the documented behavior.
2. **Specification**: theorem statements capturing documented properties of P,
   quantified over all inputs in scope.
3. **Proof**: complete proofs of those theorems, checked by Lean's kernel.

Your output is compiled and kernel-checked, then the compiled model is run
head-to-head against the real program on random inputs. A compile error, a
rejected proof, or a behavioral mismatch comes back to you as feedback.

## Modeled scope

Model ONLY this slice of the utility: no options; read stdin, write stdout; collapse ADJACENT duplicate lines to one occurrence.

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

<span id="top"></span> <span id="uniq"></span> <span id="tag_20_138"></span>

#### <span id="tag_20_138_01"></span>NAME

> uniq — report or filter out repeated lines in a file

#### <span id="tag_20_138_02"></span>SYNOPSIS

> `uniq`` `**`[`**`-c|-d|-u`**`] [`**`-f`` `*`fields`***`] [`**`-s`` `*`char`***`] [`***`input_file`*` `**`[`***`output_file`***`]]`**

#### <span id="tag_20_138_03"></span>DESCRIPTION

> The *uniq* utility shall read an input file comparing adjacent lines, and write one copy of each input line on the output. The second and succeeding copies of repeated adjacent input lines shall not be written. The trailing \<newline\> of each line in the input shall be ignored when doing comparisons.
>
> Repeated lines in the input shall not be detected if they are not adjacent.

#### <span id="tag_20_138_04"></span>OPTIONS

> The *uniq* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that `'+'` may be recognized as an option delimiter as well as `'-'`.
>
> The following options shall be supported:
>
> **-c**
>
> Precede each output line with a count of the number of times the line occurred in the input.
>
> **-d**
>
> Suppress the writing of lines that are not repeated in the input.
>
> **-f ***fields*
>
> Ignore the first *fields* fields on each input line when doing comparisons, where *fields* is a positive decimal integer. A field is the maximal string matched by the basic regular expression:
>
>
>     [[:blank:]]*[^[:blank:]]*
>
> If the *fields* option-argument specifies more fields than appear on an input line, a null string shall be used for comparison.
>
> **-s ***chars*
>
> Ignore the first *chars* characters when doing comparisons, where *chars* shall be a positive decimal integer. If specified in conjunction with the **-f** option, the first *chars* characters after the first *fields* fields shall be ignored. If the *chars* option-argument specifies more characters than remain on an input line, a null string shall be used for comparison.
>
> **-u**
>
> Suppress the writing of lines that are repeated in the input.

#### <span id="tag_20_138_05"></span>OPERANDS

> The following operands shall be supported:
>
> *input_file*
>
> A pathname of the input file. If the *input_file* operand is not specified, or if the *input_file* is `'-'`, the standard input shall be used.
>
> *output_file*
>
> A pathname of the output file. If the *output_file* operand is not specified, the standard output shall be used. The results are unspecified if the file named by *output_file* is the file named by *input_file*.

#### <span id="tag_20_138_06"></span>STDIN

> The standard input shall be used only if no *input_file* operand is specified or if *input_file* is `'-'`. See the INPUT FILES section.

#### <span id="tag_20_138_07"></span>INPUT FILES

> The input file shall be a text file.

#### <span id="tag_20_138_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *uniq*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and which characters constitute a \<blank\> in the current locale.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_138_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_138_10"></span>STDOUT

> The standard output shall be used if no *output_file* operand is specified, and shall be used if the *output_file* operand is `'-'` and the implementation treats the `'-'` as meaning standard output. Otherwise, the standard output shall not be used. See the OUTPUT FILES section.

#### <span id="tag_20_138_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_138_12"></span>OUTPUT FILES

> If the **-c** option is specified, the output file shall be empty or each line shall be of the form:
>
>
>     "%d %s", <number of duplicates>, <line>
>
> otherwise, the output file shall be empty or each line shall be of the form:
>
>
>     "%s", <line>

#### <span id="tag_20_138_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_138_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_138_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_138_16"></span>APPLICATION USAGE

> The [*sort*](../utilities/sort.html) utility can be used to cause repeated lines to be adjacent in the input file.
>
> If the collating sequence of the current locale does not have a total ordering of all characters, the behavior of `sort | uniq` differs from `sort -u`, as `uniq` treats lines as duplicates only if they are identical, whereas `sort -u` treats lines as duplicates if they collate equally.
>
> When using *uniq* to process pathnames, it is recommended that LC_ALL, or at least LC_CTYPE and LC_COLLATE, are set to POSIX or C in the environment, since pathnames can contain byte sequences that do not form valid characters in some locales, in which case the utility's behavior would be undefined. In the POSIX locale each byte is a valid single-byte character, and therefore this problem is avoided.

#### <span id="tag_20_138_17"></span>EXAMPLES

> The following input file data (but flushed left) was used for a test series on *uniq*:
>
>
>     #01 foo0 bar0 foo1 bar1
>     #02 bar0 foo1 bar1 foo1
>     #03 foo0 bar0 foo1 bar1
>     #04
>     #05 foo0 bar0 foo1 bar1
>     #06 foo0 bar0 foo1 bar1
>     #07 bar0 foo1 bar1 foo0
>
> What follows is a series of test invocations of the *uniq* utility that use a mixture of *uniq* options against the input file data. These tests verify the meaning of *adjacent*. The *uniq* utility views the input data as a sequence of strings delimited by `'\n'`. Accordingly, for the *fields*th member of the sequence, *uniq* interprets unique or repeated adjacent lines strictly relative to the *fields*+1th member.
>
> 1.  This first example tests the line counting option, comparing each line of the input file data starting from the second field:
>
>
>         uniq -c -f 1 uniq_0I.t
>             1 #01 foo0 bar0 foo1 bar1
>             1 #02 bar0 foo1 bar1 foo1
>             1 #03 foo0 bar0 foo1 bar1
>             1 #04
>             2 #05 foo0 bar0 foo1 bar1
>             1 #07 bar0 foo1 bar1 foo0
>
>     The number `'2'`, prefixing the fifth line of output, signifies that the *uniq* utility detected a pair of repeated lines. Given the input data, this can only be true when *uniq* is run using the **-f 1** option (which shall cause *uniq* to ignore the first field on each input line).
>
> 2.  The second example tests the option to suppress unique lines, comparing each line of the input file data starting from the second field:
>
>
>         uniq -d -f 1 uniq_0I.t
>         #05 foo0 bar0 foo1 bar1
>
> 3.  This test suppresses repeated lines, comparing each line of the input file data starting from the second field:
>
>
>         uniq -u -f 1 uniq_0I.t
>         #01 foo0 bar0 foo1 bar1
>         #02 bar0 foo1 bar1 foo1
>         #03 foo0 bar0 foo1 bar1
>         #04
>         #07 bar0 foo1 bar1 foo0
>
> 4.  This suppresses unique lines, comparing each line of the input file data starting from the third character:
>
>
>         uniq -d -s 2 uniq_0I.t
>
>     In the last example, the *uniq* utility found no input matching the above criteria.

#### <span id="tag_20_138_18"></span>RATIONALE

> Some historical implementations have limited lines to be 1080 bytes in length, which does not meet the implied {LINE_MAX} limit.
>
> Earlier versions of this standard allowed the **-***number* and **+***number* options. These options are no longer specified by POSIX.1-2024 but may be present in some implementations.

#### <span id="tag_20_138_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_138_20"></span>SEE ALSO

> [*comm*](../utilities/comm.html#), [*sort*](../utilities/sort.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_138_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_138_22"></span>Issue 6

> The obsolescent SYNOPSIS and associated text are removed.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/40 is applied, adding *LC_COLLATE* to the ENVIRONMENT VARIABLES section, and changing "the application shall ensure that" in the OUTPUT FILES section.

#### <span id="tag_20_138_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied, clarifying that `'+'` may be recognized as an option delimiter in the OPTIONS section.
>
> Austin Group Interpretation 1003.1-2001 \#092 is applied.
>
> Austin Group Interpretation 1003.1-2001 \#133 is applied, clarifying the behavior of the trailing \<newline\>.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> SD5-XCU-ERN-141 is applied, updating the EXAMPLES section.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0199 \[963\] and XCU/TC2-2008/0200 \[663\] are applied.

#### <span id="tag_20_138_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1070 is applied, changing the APPLICATION USAGE section.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1492 is applied, changing the EXIT STATUS section.

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


## Previous attempt feedback (round 2)

Your previous module (revise it; return the COMPLETE new module):

```lean
namespace Pipeline.Generated

def skipEqual (x : String) : List String → List String
  | [] => []
  | y :: ys => if y = x then skipEqual x ys else y :: skipEqual x ys

def uniq : List String → List String
  | [] => []
  | x :: xs => x :: skipEqual x xs

def run (args stdin : List String) : List String × UInt32 :=
  (uniq stdin, 0)

theorem skipEqual_mem (x a : String) (xs : List String) :
    a ∈ skipEqual x xs → a ∈ xs := by
  induction xs with
  | nil =>
      simp [skipEqual]
  | cons y ys ih =>
      by_cases h : y = x
      · simp only [skipEqual, h, if_pos]
        intro ha
        simp only [List.mem_cons]
        exact Or.inr (ih ha)
      · simp only [skipEqual, h, if_false]
        intro ha
        simp only [List.mem_cons] at ha ⊢
        cases ha with
        | inl hy =>
            subst a
            exact Or.inl rfl
        | inr hr =>
            exact Or.inr (ih hr)

theorem uniq_mem (a : String) (xs : List String) :
    a ∈ uniq xs → a ∈ xs := by
  cases xs with
  | nil =>
      simp [uniq]
  | cons x xs =>
      simp only [uniq, List.mem_cons]
      intro h
      cases h with
      | inl hx =>
          exact Or.inl hx
      | inr hr =>
          exact Or.inr (skipEqual_mem x a xs hr)

theorem uniq_length_le (xs : List String) :
    (uniq xs).length ≤ xs.length := by
  induction xs with
  | nil =>
      simp [uniq]
  | cons x xs ih =>
      have hs : (skipEqual x xs).length ≤ xs.length := by
        induction xs with
        | nil =>
            simp [skipEqual]
        | cons y ys ihs =>
            by_cases h : y = x
            · simpa [skipEqual, h] using
                (Nat.le_trans ihs (Nat.le_succ ys.length))
            · simpa [skipEqual, h] using (Nat.succ_le_succ ihs)
      simpa [uniq] using (Nat.succ_le_succ hs)

theorem skipEqual_idempotent (x : String) (xs : List String) :
    skipEqual x (skipEqual x xs) = skipEqual x xs := by
  induction xs with
  | nil =>
      simp [skipEqual]
  | cons y ys ih =>
      by_cases h : y = x
      · simp [skipEqual, h, ih]
      · simp [skipEqual, h, ih]

theorem uniq_idempotent (xs : List String) :
    uniq (uniq xs) = uniq xs := by
  cases xs with
  | nil =>
      rfl
  | cons x xs =>
      simp only [uniq]
      rw [skipEqual_idempotent]

theorem run_output (args stdin : List String) :
    (run args stdin).1 = uniq stdin := by
  rfl

theorem run_exit_success (args stdin : List String) :
    (run args stdin).2 = 0 := by
  rfl

theorem run_output_membership (args stdin : List String) (a : String) :
    a ∈ (run args stdin).1 → a ∈ stdin := by
  change a ∈ uniq stdin → a ∈ stdin
  exact uniq_mem a stdin

theorem run_output_length_bound (args stdin : List String) :
    (run args stdin).1.length ≤ stdin.length := by
  change (uniq stdin).length ≤ stdin.length
  exact uniq_length_le stdin

theorem run_idempotent (args stdin : List String) :
    (run args (run args stdin).1).1 = (run args stdin).1 := by
  change uniq (uniq stdin) = uniq stdin
  exact uniq_idempotent stdin

end Pipeline.Generated
```

**Failure:** Lean build failed:
✖ [2/9] Building Pipeline.Generated (162ms)
trace: .> LEAN_PATH=/Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean /Users/darshpoddar/.elan/toolchains/leanprover--lean4---v4.31.0/bin/lean /Users/darshpoddar/Coding/formal-verification/pipeline/lean/Pipeline/Generated.lean -o /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean/Pipeline/Generated.olean -i /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean/Pipeline/Generated.ilean -c /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/ir/Pipeline/Generated.c --setup /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/ir/Pipeline/Generated.setup.json --json
warning: Pipeline/Generated.lean:11:9: Variable name `args` is not explicitly referenced.

The binding can be removed (if unused) or named `_` (if used implicitly).

Note: This linter can be disabled with `set_option linter.unusedVariables false`
error: Pipeline/Generated.lean:62:30: Application type mismatch: The argument
  ihs
has type
  (uniq ys).length ≤ ys.length → (skipEqual x ys).length ≤ ys.length
but is expected to have type
  ?m.53 ≤ ?m.54
in the application
  Nat.le_trans ihs
error: Pipeline/Generated.lean:63:59: Application type mismatch: The argument
  ihs
has type
  (uniq ys).length ≤ ys.length → (skipEqual x ys).length ≤ ys.length
but is expected to have type
  ?m.64 ≤ ?m.65
in the application
  Nat.succ_le_succ ihs
error: Lean exited with code 1
Some required targets logged failures:
- Pipeline.Generated
error: build failed



## Output format

Return JSON with two fields: `lean_source` — the complete module source,
starting with `namespace Pipeline.Generated` — and `spec_theorems` — one entry
per spec theorem you proved, each with `name` (the Lean identifier) and
`informal` (the documented property it captures, one sentence).
