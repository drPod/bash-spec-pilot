The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="asa"></span> <span id="tag_20_04"></span>

#### <span id="tag_20_04_01"></span>NAME

> asa — interpret carriage-control characters

#### <span id="tag_20_04_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`FR`](javascript:open_code('FR'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` asa`` `**`[`***`file`*`...`**`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_04_03"></span>DESCRIPTION

> The *asa* utility shall write its input files to standard output, mapping carriage-control characters from the text files to line-printer control sequences in an implementation-defined manner.
>
> The first character of every line shall be removed from the input, and the following actions are performed.
>
> If the character removed is:
>
> \<space\>
>
> The rest of the line is output without change.
>
> 0
>
> A \<newline\> is output, then the rest of the input line.
>
> 1
>
> One or more implementation-defined characters that causes an advance to the next page shall be output, followed by the rest of the input line.
>
> `+`
>
> The \<newline\> of the previous line shall be replaced with one or more implementation-defined characters that causes printing to return to column position 1, followed by the rest of the input line. If the `'+'` is the first character in the input, it shall be equivalent to \<space\>.
>
> The action of the *asa* utility is unspecified upon encountering any character other than those listed above as the first character in a line.

#### <span id="tag_20_04_04"></span>OPTIONS

> None.

#### <span id="tag_20_04_05"></span>OPERANDS

> *file*
>
> A pathname of a text file used for input. If no *file* operands are specified, the standard input shall be used.

#### <span id="tag_20_04_06"></span>STDIN

> The standard input shall be used if no *file* operands are specified, and shall be used if a *file* operand is `'-'` and the implementation treats the `'-'` as meaning standard input. Otherwise, the standard input shall not be used. See the INPUT FILES section.

#### <span id="tag_20_04_07"></span>INPUT FILES

> The input files shall be text files.

#### <span id="tag_20_04_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *asa*:
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

#### <span id="tag_20_04_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_04_10"></span>STDOUT

> The standard output shall be the text from the input file modified as described in the DESCRIPTION section.

#### <span id="tag_20_04_11"></span>STDERR

> None.

#### <span id="tag_20_04_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_04_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_04_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> All input files were output successfully.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_04_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_04_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_04_17"></span>EXAMPLES

> 1.  The following command:
>
>
>         asa file
>
>     permits the viewing of *file* (created by a program using FORTRAN-style carriage-control characters) on a terminal.
>
> 2.  The following command:
>
>
>         a.out | asa | lp
>
>     formats the FORTRAN output of **a.out** and directs it to the printer.

#### <span id="tag_20_04_18"></span>RATIONALE

> The *asa* utility is needed to map "standard" FORTRAN 77 output into a form acceptable to contemporary printers. Usually, *asa* is used to pipe data to the [*lp*](../utilities/lp.html) utility; see [*lp*](../utilities/lp.html).
>
> This utility is generally used only by FORTRAN programs. The standard developers decided to retain *asa* to avoid breaking the historical large base of FORTRAN applications that put carriage-control characters in their output files. There is no requirement that a system have a FORTRAN compiler in order to run applications that need *asa*.
>
> Historical implementations have used an ASCII \<form-feed\> in response to a 1 and an ASCII \<carriage-return\> in response to a `'+'`. It is suggested that implementations treat characters other than 0, 1, and `'+'` as \<space\> in the absence of any compelling reason to do otherwise. However, the action is listed here as "unspecified", permitting an implementation to provide extensions to access fast multiple-line slewing and channel seeking in a non-portable manner.

#### <span id="tag_20_04_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_04_20"></span>SEE ALSO

> [*lp*](../utilities/lp.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_04_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_04_22"></span>Issue 6

> This utility is marked as part of the FORTRAN Runtime Utilities option.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_04_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#092 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_04_24"></span>Issue 8

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
