# Task

You are given the documentation of a program P (below: the POSIX specification
of `wc`). Produce, in Lean 4, three artifacts about a *model* q of P:

1. **Model**: a total Lean function implementing the documented behavior.
2. **Specification**: theorem statements capturing documented properties of P,
   quantified over all inputs in scope.
3. **Proof**: complete proofs of those theorems, checked by Lean's kernel.

Your output is compiled and kernel-checked, then the compiled model is run
head-to-head against the real program on random inputs. A compile error, a
rejected proof, or a behavioral mismatch comes back to you as feedback.

## Modeled scope

Model ONLY this slice of the utility: only `-l`; read stdin; print the number of lines (each line in the stdin list counts as one). Print just the decimal count, no filename.

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

<span id="top"></span> <span id="wc"></span> <span id="tag_20_148"></span>

#### <span id="tag_20_148_01"></span>NAME

> wc — word, line, and byte or character count

#### <span id="tag_20_148_02"></span>SYNOPSIS

> `wc`` `**`[`**`-c|-m`**`] [`**`-lw`**`] [`***`file`*`...`**`]`**

#### <span id="tag_20_148_03"></span>DESCRIPTION

> The *wc* utility shall read one or more input files and, by default, write the number of \<newline\> characters, words, and bytes contained in each input file to the standard output.
>
> The utility also shall write a total count for all named files, if more than one input file is specified.
>
> The *wc* utility shall consider a *word* to be a non-zero-length string of characters delimited by white space.

#### <span id="tag_20_148_04"></span>OPTIONS

> The *wc* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-c**
>
> Write to the standard output the number of bytes in each input file.
>
> **-l**
>
> Write to the standard output the number of \<newline\> characters in each input file.
>
> **-m**
>
> Write to the standard output the number of characters in each input file.
>
> **-w**
>
> Write to the standard output the number of words in each input file.
>
> When any option is specified, *wc* shall report only the information requested by the specified options.

#### <span id="tag_20_148_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an input file. If no *file* operands are specified, the standard input shall be used.

#### <span id="tag_20_148_06"></span>STDIN

> The standard input shall be used if no *file* operands are specified, and shall be used if a *file* operand is `'-'` and the implementation treats the `'-'` as meaning standard input. Otherwise, the standard input shall not be used. See the INPUT FILES section.

#### <span id="tag_20_148_07"></span>INPUT FILES

> The input files may be of any type.

#### <span id="tag_20_148_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *wc*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and which characters are defined as white-space characters.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_148_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_148_10"></span>STDOUT

> By default, the standard output shall contain an entry for each input file of the form:
>
>
>     "%d %d %d %s\n", <newlines>, <words>, <bytes>, <file>
>
> If the **-m** option is specified, the number of characters shall replace the \<*bytes*\> field in this format.
>
> If any options are specified and the **-l** option is not specified, the number of \<newline\> characters shall not be written.
>
> If any options are specified and the **-w** option is not specified, the number of words shall not be written.
>
> If any options are specified and neither **-c** nor **-m** is specified, the number of bytes or characters shall not be written.
>
> If no input *file* operands are specified, no name shall be written and no \<blank\> characters preceding the pathname shall be written.
>
> If more than one input *file* operand is specified, an additional line shall be written, of the same format as the other lines, except that the word **total** (in the POSIX locale) shall be written instead of a pathname and the total of each column shall be written as appropriate. Such an additional line, if any, is written at the end of the output.

#### <span id="tag_20_148_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_148_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_148_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_148_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_148_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_148_16"></span>APPLICATION USAGE

> The **-m** option is not a switch, but an option at the same level as **-c**. Thus, to produce the full default output with character counts instead of bytes, the command required is:
>
>
>     wc -mlw

#### <span id="tag_20_148_17"></span>EXAMPLES

> None.

#### <span id="tag_20_148_18"></span>RATIONALE

> The output file format pseudo-[*printf*()](../functions/printf.html) string differs from the System V version of *wc*:
>
>
>     "%7d%7d%7d %s\n"
>
> which produces possibly ambiguous and unparsable results for very large files, as it assumes no number shall exceed six digits.
>
> Some historical implementations use only \<space\>, \<tab\>, and \<newline\> as word separators. The equivalent of the ISO C standard [*isspace*()](../functions/isspace.html) function is more appropriate.
>
> The **-c** option stands for "character" count, even though it counts bytes. This stems from the sometimes erroneous historical view that bytes and characters are the same size. Due to international requirements, the **-m** option (reminiscent of "multi-byte") was added to obtain actual character counts.
>
> Early proposals only specified the results when input files were text files. The current specification more closely matches historical practice. (Bytes, words, and \<newline\> characters are counted separately and the results are written when an end-of-file is detected.)
>
> Historical implementations of the *wc* utility only accepted one argument to specify the options **-c**, **-l**, and **-w**. Some of them also had multiple occurrences of an option cause the corresponding count to be written multiple times and had the order of specification of the options affect the order of the fields on output, but did not document either of these. Because common usage either specifies no options or only one option, and because none of this was documented, the changes required by this volume of POSIX.1-2024 should not break many historical applications (and do not break any historical conforming applications).

#### <span id="tag_20_148_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_148_20"></span>SEE ALSO

> [*cksum*](../utilities/cksum.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_148_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_148_22"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#092 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_148_23"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
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



## Output format

Return JSON with two fields: `lean_source` — the complete module source,
starting with `namespace Pipeline.Generated` — and `spec_theorems` — one entry
per spec theorem you proved, each with `name` (the Lean identifier) and
`informal` (the documented property it captures, one sentence).
