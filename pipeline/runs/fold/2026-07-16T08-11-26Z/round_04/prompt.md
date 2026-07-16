# Task

You are given the documentation of a program P (below: the POSIX specification
of `fold`). Produce, in Lean 4, three artifacts about a *model* q of P:

1. **Model**: a total Lean function implementing the documented behavior.
2. **Specification**: theorem statements capturing documented properties of P,
   quantified over all inputs in scope.
3. **Proof**: complete proofs of those theorems, checked by Lean's kernel.

Your output is compiled and kernel-checked, then the compiled model is run
head-to-head against the real program on random inputs. A compile error, a
rejected proof, or a behavioral mismatch comes back to you as feedback.

## Modeled scope

Model ONLY this slice of the utility: only `-w WIDTH` with WIDTH >= 1; read stdin; break each line into chunks of at most WIDTH characters (no tab/column subtleties: count plain characters).

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

<span id="top"></span> <span id="fold"></span> <span id="tag_20_48"></span>

#### <span id="tag_20_48_01"></span>NAME

> fold — filter for folding lines

#### <span id="tag_20_48_02"></span>SYNOPSIS

> `fold`` `**`[`**`-bs`**`] [`**`-w`` `*`width`***`] [`***`file`*`...`**`]`**

#### <span id="tag_20_48_03"></span>DESCRIPTION

> The *fold* utility is a filter that shall fold lines from its input files, breaking the lines to have a maximum of *width* column positions (or bytes, if the **-b** option is specified). Lines shall be broken by the insertion of a \<newline\> such that each output line (referred to later in this section as a *segment*) is the maximum width possible that does not exceed the specified number of column positions (or bytes). A line shall not be broken in the middle of a character. The behavior is undefined if *width* is less than the number of columns any single character in the input would occupy.
>
> If the \<carriage-return\>, \<backspace\>, or \<tab\> characters are encountered in the input, and the **-b** option is not specified, they shall be treated specially:
>
> \<backspace\>
>
> The current count of line width shall be decremented by one, although the count never shall become negative. The *fold* utility shall not insert a \<newline\> immediately before or after any \<backspace\>, unless the following character has a width greater than 1 and would cause the line width to exceed *width*.
>
> \<carriage-return\>
>
> \
> The current count of line width shall be set to zero. The *fold* utility shall not insert a \<newline\> immediately before or after any \<carriage-return\>.
>
> \<tab\>
>
> Each \<tab\> encountered shall advance the column position pointer to the next tab stop. Tab stops shall be at each column position *n* such that *n* modulo 8 equals 1.

#### <span id="tag_20_48_04"></span>OPTIONS

> The *fold* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-b**
>
> Count *width* in bytes rather than column positions.
>
> **-s**
>
> If a segment of a line contains a \<blank\> within the first *width* column positions (or bytes), break the line after the last such \<blank\> meeting the width constraints. If there is no \<blank\> meeting the requirements, the **-s** option shall have no effect for that output segment of the input line.
>
> **-w ***width*
>
> Specify the maximum line length, in column positions (or bytes if **-b** is specified). The results are unspecified if *width* is not a positive decimal number. The default value shall be 80.

#### <span id="tag_20_48_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a text file to be folded. If no *file* operands are specified, the standard input shall be used.

#### <span id="tag_20_48_06"></span>STDIN

> The standard input shall be used if no *file* operands are specified, and shall be used if a *file* operand is `'-'` and the implementation treats the `'-'` as meaning standard input. Otherwise, the standard input shall not be used. See the INPUT FILES section.

#### <span id="tag_20_48_07"></span>INPUT FILES

> If the **-b** option is specified, the input files shall be text files except that the lines are not limited to {LINE_MAX} bytes in length. If the **-b** option is not specified, the input files shall be text files.

#### <span id="tag_20_48_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *fold*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files), and for the determination of the width in column positions each character would occupy on a constant-width font output device.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_48_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_48_10"></span>STDOUT

> The standard output shall be a file containing a sequence of characters whose order shall be preserved from the input files, possibly with inserted \<newline\> characters.

#### <span id="tag_20_48_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_48_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_48_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_48_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> All input files were processed successfully.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_48_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_48_16"></span>APPLICATION USAGE

> The [*cut*](../utilities/cut.html) and *fold* utilities can be used to create text files out of files with arbitrary line lengths. The [*cut*](../utilities/cut.html) utility should be used when the number of lines (or records) needs to remain constant. The *fold* utility should be used when the contents of long lines need to be kept contiguous.
>
> The *fold* utility is frequently used to send text files to printers that truncate, rather than fold, lines wider than the printer is able to print (usually 80 or 132 column positions).

#### <span id="tag_20_48_17"></span>EXAMPLES

> An example invocation that submits a file of possibly long lines to the printer (under the assumption that the user knows the line width of the printer to be assigned by [*lp*](../utilities/lp.html)):
>
>
>     fold -w 132 bigfile | lp

#### <span id="tag_20_48_18"></span>RATIONALE

> Although terminal input in canonical processing mode requires the erase character (frequently set to \<backspace\>) to erase the previous character (not byte or column position), terminal output is not buffered and is extremely difficult, if not impossible, to parse correctly; the interpretation depends entirely on the physical device that actually displays/prints/stores the output. In all known internationalized implementations, the utilities producing output for mixed column-width output assume that a \<backspace\> character backs up one column position and outputs enough \<backspace\> characters to return to the start of the character when \<backspace\> is used to provide local line motions to support underlining and emboldening operations. Since *fold* without the **-b** option is dealing with these same constraints, \<backspace\> is always treated as backing up one column position rather than backing up one character.
>
> Historical versions of the *fold* utility assumed 1 byte was one character and occupied one column position when written out. This is no longer always true. Since the most common usage of *fold* is believed to be folding long lines for output to limited-length output devices, this capability was preserved as the default case. The **-b** option was added so that applications could *fold* files with arbitrary length lines into text files that could then be processed by the standard utilities. Note that although the width for the **-b** option is in bytes, a line is never split in the middle of a character. (It is unspecified what happens if a width is specified that is too small to hold a single character found in the input followed by a \<newline\>.)
>
> The tab stops are hardcoded to be every eighth column to meet historical practice. No new method of specifying other tab stops was invented.

#### <span id="tag_20_48_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_48_20"></span>SEE ALSO

> [*cut*](../utilities/cut.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_48_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_48_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_48_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#092 is applied.\
>
> Austin Group Interpretation 1003.1-2001 \#204 is applied, updating the DESCRIPTION to clarify when a \<newline\> can be inserted before or after a \<backspace\>.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_48_24"></span>Issue 8

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


## Previous attempt feedback (round 3)

Your previous module (revise it; return the COMPLETE new module):

```lean
namespace Pipeline.Generated

def digitValue (c : Char) : Nat :=
  if c.val.toNat < 48 then 0 else c.val.toNat - 48

def decimalAux : Nat → List Char → Nat
  | n, [] => n
  | n, c :: cs => decimalAux (n * 10 + digitValue c) cs

def decimal (s : String) : Nat :=
  decimalAux 0 s.toList

def widthOf : List String → Nat
  | ["-w", s] => decimal s
  | _ => 80

def chunkGo (w : Nat) : List Char → Nat → List (List Char)
  | _, 0 => []
  | xs, n + 1 =>
      match xs with
      | [] => []
      | _ => xs.take w :: chunkGo w (xs.drop w) n

def chunks (w : Nat) (xs : List Char) : List (List Char) :=
  if w = 0 then [] else chunkGo w xs (xs.length + 1)

def foldLine (w : Nat) (s : String) : List String :=
  if s.toList = [] then [""] else
    (chunks w s.toList).map String.ofList

def run (args stdin : List String) : List String × UInt32 :=
  (stdin.flatMap (foldLine (widthOf args)), 0)

theorem run_output_shape (args stdin : List String) :
    (run args stdin).1 = stdin.flatMap (foldLine (widthOf args)) := by
  rfl

theorem run_exit_code (args stdin : List String) :
    (run args stdin).2 = 0 := by
  rfl

theorem foldLine_empty (w : Nat) :
    foldLine w "" = [""] := by
  simp [foldLine, chunks]

theorem run_cons_lines (args : List String) (line : String) (rest : List String) :
    (run args (line :: rest)).1 =
      foldLine (widthOf args) line ++ (run args rest).1 := by
  rfl

theorem run_single_line (args : List String) (line : String) :
    (run args [line]).1 = foldLine (widthOf args) line := by
  rfl

theorem width_option_is_used (s : String) :
    widthOf ["-w", s] = decimal s := by
  rfl

end Pipeline.Generated
```

**Failure:** Lean build failed:
✖ [2/9] Building Pipeline.Generated (154ms)
trace: .> LEAN_PATH=/Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean /Users/darshpoddar/.elan/toolchains/leanprover--lean4---v4.31.0/bin/lean /Users/darshpoddar/Coding/formal-verification/pipeline/lean/Pipeline/Generated.lean -o /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean/Pipeline/Generated.olean -i /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/lib/lean/Pipeline/Generated.ilean -c /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/ir/Pipeline/Generated.c --setup /Users/darshpoddar/Coding/formal-verification/pipeline/lean/.lake/build/ir/Pipeline/Generated.setup.json --json
warning: Pipeline/Generated.lean:44:18: This simp argument is unused:
  chunks

Hint: Omit it from the simp argument list.
  simp [foldLine,̵ ̵c̵h̵u̵n̵k̵s̵]

Note: This linter can be disabled with `set_option linter.unusedSimpArgs false`
error: Pipeline/Generated.lean:53:2: Tactic `rfl` failed: The left-hand side
  (run args [line]).fst
is not definitionally equal to the right-hand side
  foldLine (widthOf args) line

args : List String
line : String
⊢ (run args [line]).fst = foldLine (widthOf args) line
error: Lean exited with code 1
Some required targets logged failures:
- Pipeline.Generated
error: build failed



## Output format

Return JSON with two fields: `lean_source` — the complete module source,
starting with `namespace Pipeline.Generated` — and `spec_theorems` — one entry
per spec theorem you proved, each with `name` (the Lean identifier) and
`informal` (the documented property it captures, one sentence).
