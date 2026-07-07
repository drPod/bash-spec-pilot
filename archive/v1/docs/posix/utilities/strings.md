The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="strings"></span> <span id="tag_20_114"></span>

#### <span id="tag_20_114_01"></span>NAME

> strings — find printable strings in files

#### <span id="tag_20_114_02"></span>SYNOPSIS

> `strings`` `**`[`**`-a`**`] [`**`-t`` `*`format`***`] [`**`-n`` `*`number`***`] [`***`file`*`...`**`]`**

#### <span id="tag_20_114_03"></span>DESCRIPTION

> The *strings* utility shall look for printable strings in regular files and shall write those strings to standard output. A printable string is any sequence of four (by default) or more printable characters terminated by a \<newline\> or NUL character. Additional implementation-defined strings may be written; see [*localedef*](../utilities/localedef.html).
>
> If any argument is `'-'`, the results are unspecified.

#### <span id="tag_20_114_04"></span>OPTIONS

> The *strings* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except for the unspecified usage of `'-'`.
>
> The following options shall be supported:
>
> **-a**
>
> Scan files in their entirety. If **-a** is not specified, it is implementation-defined what portion of each file is scanned for strings.
>
> **-n ***number*
>
> Specify the minimum string length, where the *number* argument is a positive decimal integer. The default shall be 4.
>
> **-t ***format*
>
> Write each string preceded by its byte offset from the start of the file. The format shall be dependent on the single character used as the *format* option-argument:
>
> `d`
>
> The offset shall be written in decimal.
>
> `o`
>
> The offset shall be written in octal.
>
> `x`
>
> The offset shall be written in hexadecimal.

#### <span id="tag_20_114_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a regular file to be used as input. If no *file* operand is specified, the *strings* utility shall read from the standard input.

#### <span id="tag_20_114_06"></span>STDIN

> See the INPUT FILES section.

#### <span id="tag_20_114_07"></span>INPUT FILES

> The input files named by the utility arguments or the standard input shall be regular files of any format.

#### <span id="tag_20_114_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *strings*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and to identify printable strings.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_114_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_114_10"></span>STDOUT

> Strings found shall be written to the standard output, one per line.
>
> When the **-t** option is not specified, the format of the output shall be:
>
>
>     "%s", <string>
>
> With the **-t o** option, the format of the output shall be:
>
>
>     "%o %s", <byte offset>, <string>
>
> With the **-t x** option, the format of the output shall be:
>
>
>     "%x %s", <byte offset>, <string>
>
> With the **-t d** option, the format of the output shall be:
>
>
>     "%d %s", <byte offset>, <string>

#### <span id="tag_20_114_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_114_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_114_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_114_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_114_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_114_16"></span>APPLICATION USAGE

> By default the data area (as opposed to the text, "bss", or header areas) of a binary executable file is scanned. Implementations document which areas are scanned.
>
> Some historical implementations do not require NUL or \<newline\> terminators for strings to permit those languages that do not use NUL as a string terminator to have their strings written.

#### <span id="tag_20_114_17"></span>EXAMPLES

> None.

#### <span id="tag_20_114_18"></span>RATIONALE

> Apart from rationalizing the option syntax and slight difficulties with object and executable binary files, *strings* is specified to match historical practice closely. The **-a** and **-n** options were introduced to replace the non-conforming **-** and **-***number* options. These options are no longer specified by POSIX.1-2024 but may be present in some implementations.
>
> The **-o** option historically means different things on different implementations. Some use it to mean "*offset* in decimal", while others use it as "*offset* in octal". Instead of trying to decide which way would be least objectionable, the **-t** option was added. It was originally named **-O** to mean "offset", but was changed to **-t** to be consistent with [*od*](../utilities/od.html).
>
> The ISO C standard function [*isprint*()](../functions/isprint.html) is restricted to a domain of **unsigned char**. This volume of POSIX.1-2024 requires implementations to write strings as defined by the current locale.

#### <span id="tag_20_114_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_114_20"></span>SEE ALSO

> [*localedef*](../utilities/localedef.html#), [*nm*](../utilities/nm.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_114_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_114_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The obsolescent SYNOPSIS is removed.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_114_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied, clarifying the behavior if the first argument is `'-'`.
>
> The *strings* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_114_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1599 is applied, making the behavior unspecified when any argument is `'-'`.

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
