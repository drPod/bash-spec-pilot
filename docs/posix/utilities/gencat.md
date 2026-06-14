The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="gencat"></span> <span id="tag_20_50"></span>

#### <span id="tag_20_50_01"></span>NAME

> gencat — generate a formatted message catalog

#### <span id="tag_20_50_02"></span>SYNOPSIS

> `gencat`` `*`catfile msgfile`*`...`

#### <span id="tag_20_50_03"></span>DESCRIPTION

> The *gencat* utility shall merge the message text source file *msgfile* into a formatted message catalog *catfile*. The file *catfile* shall be created if it does not already exist. If *catfile* does exist, its messages shall be included in the new *catfile*. If set and message numbers collide, the new message text defined in *msgfile* shall replace the old message text currently contained in *catfile*.

#### <span id="tag_20_50_04"></span>OPTIONS

> None.

#### <span id="tag_20_50_05"></span>OPERANDS

> The following operands shall be supported:
>
> *catfile*
>
> A pathname of the formatted message catalog. If `'-'` is specified, standard output shall be used. The format of the message catalog produced is unspecified.
>
> *msgfile*
>
> A pathname of a message text source file. If `'-'` is specified for an instance of *msgfile*, standard input shall be used. The format of message text source files is defined in the EXTENDED DESCRIPTION section.

#### <span id="tag_20_50_06"></span>STDIN

> The standard input shall not be used unless a *msgfile* operand is specified as `'-'`.

#### <span id="tag_20_50_07"></span>INPUT FILES

> The input files shall be text files.

#### <span id="tag_20_50_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *gencat*:
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

#### <span id="tag_20_50_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_50_10"></span>STDOUT

> The standard output shall not be used unless the *catfile* operand is specified as `'-'`.

#### <span id="tag_20_50_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_50_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_50_13"></span>EXTENDED DESCRIPTION

> The content of a message text file shall be in the format defined as follows. Note that the fields of a message text source line are separated by a single \<blank\> character. Any other \<blank\> characters are considered to be part of the subsequent field.
>
> **\$set ***n comment*
>
> \
> This line specifies the set identifier of the following messages until the next **\$set** or end-of-file appears. The *n* denotes the set identifier, which is defined as a number in the range \[1, {NL_SETMAX}\] (see the [*\<limits.h\>*](../basedefs/limits.h.html) header defined in the Base Definitions volume of POSIX.1-2024). The application shall ensure that set identifiers are presented in ascending order within a single source file, but need not be contiguous. Any string following the set identifier shall be treated as a comment. If no **\$set** directive is specified in a message text source file, all messages shall be located in an implementation-defined default message set NL_SETD (see the [*\<nl_types.h\>*](../basedefs/nl_types.h.html) header defined in the Base Definitions volume of POSIX.1-2024).
>
> **\$delset ***n comment*
>
> \
> This line deletes message set *n* from an existing message catalog. The *n* denotes the set number \[1, {NL_SETMAX}\]. Any string following the set number shall be treated as a comment.
>
> **\$ ***comment*
>
> A line beginning with `'$'` followed by a \<blank\> shall be treated as a comment.
>
> *m message-text*
>
> \
> The *m* denotes the message identifier, which is defined as a number in the range \[1, {NL_MSGMAX}\] (see the [*\<limits.h\>*](../basedefs/limits.h.html) header). The *message-text* shall be stored in the message catalog with the set identifier specified by the last **\$set** directive, and with message identifier *m*. If the *message-text* is empty, and a \<blank\> field separator is present, an empty string shall be stored in the message catalog. If a message source line has a message number, but neither a field separator nor *message-text*, the existing message with that number (if any) shall be deleted from the catalog. The application shall ensure that message identifiers are in ascending order within a single set, but need not be contiguous. The application shall ensure that the length of *message-text* is in the range \[0, {NL_TEXTMAX}\] (see the [*\<limits.h\>*](../basedefs/limits.h.html) header).
>
> **\$quote ***c*
>
> This line specifies an optional quote character *c*, which can be used to surround *message-text* so that trailing \<space\> characters or null (empty) messages are visible in a message source line. By default, or if an empty **\$quote** directive is supplied, no quoting of *message-text* shall be recognized.
>
> Empty lines in a message text source file shall be ignored. The effects of lines starting with any character other than those defined above are implementation-defined.
>
> Text strings can contain the special characters and escape sequences defined in the following table:
>
> | **Description**     | **Symbol** | **Sequence** |
> |:--------------------|:-----------|:-------------|
> | \<newline\>         | NL(LF)     | \n           |
> | Horizontal-tab      | HT         | \t           |
> | \<vertical-tab\>    | VT         | \v           |
> | \<backspace\>       | BS         | \b           |
> | \<carriage-return\> | CR         | \r           |
> | \<form-feed\>       | FF         | \f           |
> | Backslash           | `\`        | \\           |
> | Bit pattern         | `ddd`      | \ddd         |
>
> The escape sequence `"\ddd"` consists of \<backslash\> followed by one, two, or three octal digits, which shall be taken to specify the value of the desired character. If the character following a \<backslash\> is not one of those specified, the \<backslash\> shall be ignored.
>
> A \<backslash\> followed by a \<newline\> is also used to continue a string on the following line. Thus, the following two lines describe a single message string:
>
>
>     1 This line continues \
>     to the next line
>
> which shall be equivalent to:
>
>
>     1 This line continues to the next line

#### <span id="tag_20_50_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_50_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_50_16"></span>APPLICATION USAGE

> Message catalogs produced by *gencat* are binary encoded, meaning that their portability cannot be guaranteed between different types of machine. Thus, just as C programs need to be recompiled for each type of machine, so message catalogs must be recreated via *gencat*.

#### <span id="tag_20_50_17"></span>EXAMPLES

> None.

#### <span id="tag_20_50_18"></span>RATIONALE

> None.

#### <span id="tag_20_50_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_50_20"></span>SEE ALSO

> [*iconv*](../utilities/iconv.html#tag_20_58)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*\<limits.h\>*](../basedefs/limits.h.html), [*\<nl_types.h\>*](../basedefs/nl_types.h.html)

#### <span id="tag_20_50_21"></span>CHANGE HISTORY

> First released in Issue 3.

#### <span id="tag_20_50_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_50_23"></span>Issue 7

> The *gencat* utility is moved from the XSI option to the Base.

#### <span id="tag_20_50_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1463 is applied, changing *n* to *c* in the definition of **\$quote**.
>
> Austin Group Defect 1516 is applied, adding XSI shading to text relating to *NLSPATH .*

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
