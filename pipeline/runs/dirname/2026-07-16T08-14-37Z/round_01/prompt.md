# Task

You are given the documentation of a program P (below: the POSIX specification
of `dirname`). Produce, in Lean 4, three artifacts about a *model* q of P:

1. **Model**: a total Lean function implementing the documented behavior.
2. **Specification**: theorem statements capturing documented properties of P,
   quantified over all inputs in scope.
3. **Proof**: complete proofs of those theorems, checked by Lean's kernel.

Your output is compiled and kernel-checked, then the compiled model is run
head-to-head against the real program on random inputs. A compile error, a
rejected proof, or a behavioral mismatch comes back to you as feedback.

## Modeled scope

Model ONLY this slice of the utility: exactly one PATH operand; print the parent directory per the POSIX algorithm; stdin is empty and ignored.

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

<span id="top"></span> <span id="dirname"></span> <span id="tag_20_35"></span>

#### <span id="tag_20_35_01"></span>NAME

> dirname — return the directory portion of a pathname

#### <span id="tag_20_35_02"></span>SYNOPSIS

> `dirname`` `*`string`*

#### <span id="tag_20_35_03"></span>DESCRIPTION

> The *string* operand shall be treated as a pathname, as defined in XBD [*3.254 Pathname*](../basedefs/V1_chap03.html#tag_03_254), and shall be converted to a pathname of the directory containing the entry of the final pathname component. The resulting string shall be written to standard output. The *dirname* utility shall not perform pathname resolution; the result shall not be affected by whether or not a file with the pathname *string* exists or by its file type. Trailing `'/'` characters in *string* that are not also leading `'/'` characters shall not be counted as part of the pathname. If the pathname does not contain a `'/'`, the resulting string shall be `"."`. If *string* is an empty string, the resulting string shall be `"."`.
>
> It is unspecified whether redundant `'/'` characters and `'.'` pathname components in *string* are removed after determining the pathname to output. However, `".."` pathname components occurring prior to the final component shall not be removed.

#### <span id="tag_20_35_04"></span>OPTIONS

> None.

#### <span id="tag_20_35_05"></span>OPERANDS

> The following operand shall be supported:
>
> *string*
>
> A string.

#### <span id="tag_20_35_06"></span>STDIN

> Not used.

#### <span id="tag_20_35_07"></span>INPUT FILES

> None.

#### <span id="tag_20_35_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *dirname*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_35_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_35_10"></span>STDOUT

> The *dirname* utility shall write a line to the standard output in the following format:
>
>
>     "%s\n", <resulting string>

#### <span id="tag_20_35_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_35_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_35_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_35_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_35_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_35_16"></span>APPLICATION USAGE

> The definition of *pathname* specifies implementation-defined behavior for pathnames starting with two \<slash\> characters. Therefore, applications shall not arbitrarily add \<slash\> characters to the beginning of a pathname unless they can ensure that there are more or less than two or are prepared to deal with the implementation-defined consequences.

#### <span id="tag_20_35_17"></span>EXAMPLES

> The EXAMPLES section of the [*basename*()](../functions/basename.html) function (see XSH [*basename*()](../functions/basename.html#tag_17_42)) includes a table showing examples of the results of processing several sample pathnames by the [*basename*()](../functions/basename.html) and [*dirname*()](../functions/dirname.html) functions and by the [*basename*](../utilities/basename.html) and *dirname* utilities.
>
> See also the examples for the [*basename*](../utilities/basename.html) utility.

#### <span id="tag_20_35_18"></span>RATIONALE

> The behaviors of [*basename*](../utilities/basename.html) and *dirname* in this volume of POSIX.1-2024 have been coordinated so that when *string* is a valid pathname:
>
>
>     $(basename -- "string")
>
> would be a valid filename for the file in the directory:
>
>
>     $(dirname -- "string")
>
> This would not work for the versions of these utilities in early proposals due to the way processing of trailing \<slash\> characters was specified. Consideration was given to leaving processing unspecified if there were trailing \<slash\> characters, but this cannot be done; XBD [*3.254 Pathname*](../basedefs/V1_chap03.html#tag_03_254) allows trailing \<slash\> characters. The [*basename*](../utilities/basename.html) and *dirname* utilities have to specify consistent handling for all valid pathnames.
>
> The *dirname* utility is not specified in terms of the [*dirname*()](../functions/dirname.html) function, because the two may produce slightly different output where both output forms are still compliant. An implementation should prefer the shortest output possible; however, this is not required, in part because earlier versions of the standard did not permit elision of redundant \<slash\> characters or dot (`'.'`) components. Removal of the dot-dot (`".."`) pathname component is not permitted, because eliding it correctly would require performing pathname resolution to ensure the resulting string would still point to the correct pathname if the original string resolved as a pathname. On implementations where pathname `"//"` has an implementation-defined meaning distinct from the pathname `"/"`, the dirname of `"//"` will be `"//"`.

#### <span id="tag_20_35_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_35_20"></span>SEE ALSO

> [*2.5 Parameters and Variables*](../utilities/V3_chap02.html#tag_19_05), [*basename*](../utilities/basename.html#tag_20_07)
>
> XBD [*3.254 Pathname*](../basedefs/V1_chap03.html#tag_03_254), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)
>
> XSH [*basename*()](../functions/basename.html#tag_17_42), [*dirname*()](../functions/dirname.html#tag_17_108)

#### <span id="tag_20_35_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_35_22"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0083 \[192,430\], XCU/TC1-2008/0084 \[192\], and XCU/TC1-2008/0085 \[192\] are applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0086 \[612\], XCU/TC2-2008/0087 \[620\], and XCU/TC2-2008/0088 \[612\] are applied.

#### <span id="tag_20_35_23"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 1073 is applied, replacing the DESCRIPTION section with one that matches the [*dirname*()](../functions/dirname.html) function.
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
