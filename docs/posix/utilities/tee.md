The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="tee"></span> <span id="tag_20_120"></span>

#### <span id="tag_20_120_01"></span>NAME

> tee — duplicate standard input

#### <span id="tag_20_120_02"></span>SYNOPSIS

> `tee`` `**`[`**`-ai`**`] [`***`file`*`...`**`]`**

#### <span id="tag_20_120_03"></span>DESCRIPTION

> The *tee* utility shall copy standard input to standard output, making a copy in zero or more files. The *tee* utility shall not buffer output.
>
> If the **-a** option is not specified, output files shall be written (see [*1.1.1.4 File Read, Write, and Creation*](../utilities/V3_chap01.html#tag_18_01_01_04)).

#### <span id="tag_20_120_04"></span>OPTIONS

> The *tee* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a**
>
> Append the output to the files.
>
> **-i**
>
> Ignore the SIGINT signal.

#### <span id="tag_20_120_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file*
>
> A pathname of an output file. If a *file* operand is `'-'`, it shall refer to a file named **-**; implementations shall not treat it as meaning standard output. Processing of at least 13 *file* operands shall be supported.

#### <span id="tag_20_120_06"></span>STDIN

> The standard input can be of any type.

#### <span id="tag_20_120_07"></span>INPUT FILES

> None.

#### <span id="tag_20_120_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *tee*:
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

#### <span id="tag_20_120_09"></span>ASYNCHRONOUS EVENTS

> Default, except that if the **-i** option was specified, SIGINT shall be ignored.

#### <span id="tag_20_120_10"></span>STDOUT

> The standard output shall be a copy of the standard input.

#### <span id="tag_20_120_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_120_12"></span>OUTPUT FILES

> If any *file* operands are specified, the standard input shall be copied to each named file.

#### <span id="tag_20_120_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_120_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The standard input was successfully copied to all output files.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_120_15"></span>CONSEQUENCES OF ERRORS

> If a write to any successfully opened *file* operand fails, writes to other successfully opened *file* operands and standard output shall continue, but the exit status shall be non-zero. Otherwise, the default actions specified in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04) apply.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_120_16"></span>APPLICATION USAGE

> The *tee* utility is usually used in a pipeline, to make a copy of the output of some utility.
>
> The *file* operand is technically optional, but *tee* is no more useful than [*cat*](../utilities/cat.html) when none is specified.

#### <span id="tag_20_120_17"></span>EXAMPLES

> Save an unsorted intermediate form of the data in a pipeline:
>
>
>     ... | tee unsorted | sort > sorted

#### <span id="tag_20_120_18"></span>RATIONALE

> The buffering requirement means that *tee* is not allowed to use ISO C standard fully buffered or line-buffered writes. It does not mean that *tee* has to do 1-byte reads followed by 1-byte writes.
>
> It should be noted that early versions of BSD ignore any invalid options and accept a single `'-'` as an alternative to **-i**. They also print a message if unable to open a file:
>
>
>     "tee: cannot access %s\n", <pathname>
>
> Historical implementations ignore write errors. This is explicitly not permitted by this volume of POSIX.1-2024.
>
> Some historical implementations use O_APPEND when providing append mode; others use the [*lseek*()](../functions/lseek.html) function to seek to the end-of-file after opening the file without O_APPEND. This volume of POSIX.1-2024 requires functionality equivalent to using O_APPEND; see [*1.1.1.4 File Read, Write, and Creation*](../utilities/V3_chap01.html#tag_18_01_01_04).

#### <span id="tag_20_120_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_120_20"></span>SEE ALSO

> [*1. Introduction*](../utilities/V3_chap01.html#tag_18), [*cat*](../utilities/cat.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*lseek*()](../functions/lseek.html#)

#### <span id="tag_20_120_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_120_22"></span>Issue 6

> IEEE PASC Interpretation 1003.2 \#168 is applied.

#### <span id="tag_20_120_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#092 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_120_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1494 is applied, inserting a missing closing parenthesis.

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
