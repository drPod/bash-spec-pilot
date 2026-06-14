The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="cxref"></span> <span id="tag_20_29"></span>

#### <span id="tag_20_29_01"></span>NAME

> cxref — generate a C-language program cross-reference table (**DEVELOPMENT**)

#### <span id="tag_20_29_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` cxref`` `**`[`**`-cs`**`] [`**`-o`` `*`file`***`] [`**`-w`` `*`num`***`] [`**`-D`` `*`name`***`[`**`=`*`def`***`]]`**`...`` `**`[`**`-I`` `*`dir`***`]`**`...`\
> `      `` `**`[`**`-U`` `*`name`***`]`**`...`` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_29_03"></span>DESCRIPTION

> The *cxref* utility shall analyze a collection of C-language *file*s and attempt to build a cross-reference table. Information from **\#define** lines shall be included in the symbol table. A sorted listing shall be written to standard output of all symbols (auto, static, and global) in each *file* separately, or with the **-c** option, in combination. Each symbol shall contain an \<asterisk\> before the declaring reference.

#### <span id="tag_20_29_04"></span>OPTIONS

> The *cxref* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that the order of the **-D**, **-I**, and **-U** options (which are identical to their interpretation by [*c17*](../utilities/c17.html)) is significant. The following options shall be supported:
>
> **-c**
>
> Write a combined cross-reference of all input files.
>
> **-s**
>
> Operate silently; do not print input filenames.
>
> **-o ***file*
>
> Direct output to named *file*.
>
> **-w ***num*
>
> Format output no wider than *num* (decimal) columns. This option defaults to 80 if *num* is not specified or is less than 51.
>
> **-D**
>
> Equivalent to [*c17*](../utilities/c17.html).
>
> **-I**
>
> Equivalent to [*c17*](../utilities/c17.html).
>
> **-U**
>
> Equivalent to [*c17*](../utilities/c17.html).

#### <span id="tag_20_29_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a C-language source file.

#### <span id="tag_20_29_06"></span>STDIN

> Not used.

#### <span id="tag_20_29_07"></span>INPUT FILES

> The input files are C-language source files.

#### <span id="tag_20_29_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *cxref*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
>
> *LC_COLLATE*
>
> \
> Determine the locale for the ordering of the output.
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
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_29_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_29_10"></span>STDOUT

> The standard output shall be used for the cross-reference listing, unless the **-o** option is used to select a different output file.
>
> The format of standard output is unspecified, except that the following information shall be included:
>
> - If the **-c** option is not specified, each portion of the listing shall start with the name of the input file on a separate line.
>
> - The name line shall be followed by a sorted list of symbols, each with its associated location pathname, the name of the function in which it appears (if it is not a function name itself), and line number references.
>
> - Each line number may be preceded by an \<asterisk\> (`'*'`) flag, meaning that this is the declaring reference. Other single-character flags, with implementation-defined meanings, may be included.

#### <span id="tag_20_29_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_29_12"></span>OUTPUT FILES

> The output file named by the **-o** option shall be used instead of standard output.

#### <span id="tag_20_29_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_29_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_29_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_29_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_29_17"></span>EXAMPLES

> None.

#### <span id="tag_20_29_18"></span>RATIONALE

> None.

#### <span id="tag_20_29_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_29_20"></span>SEE ALSO

> [*c17*](../utilities/c17.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_29_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_29_22"></span>Issue 5

> In the SYNOPSIS, \[**-U** *dir*\] is changed to \[**-U** *name*\].

#### <span id="tag_20_29_23"></span>Issue 6

> The APPLICATION USAGE section is added.

#### <span id="tag_20_29_24"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_29_25"></span>Issue 8

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
