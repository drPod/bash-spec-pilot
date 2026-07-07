The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="echo"></span> <span id="tag_20_37"></span>

#### <span id="tag_20_37_01"></span>NAME

> echo — write arguments to standard output

#### <span id="tag_20_37_02"></span>SYNOPSIS

> `echo`` `**`[`***`string`*`...`**`]`**

#### <span id="tag_20_37_03"></span>DESCRIPTION

> The *echo* utility writes its arguments to standard output, followed by a \<newline\>. If there are no arguments, only the \<newline\> is written.

#### <span id="tag_20_37_04"></span>OPTIONS

> The *echo* utility shall not recognize the `"--"` argument in the manner specified by Guideline 10 of XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02); `"--"` shall be recognized as a string operand.
>
> Implementations shall not support any options.

#### <span id="tag_20_37_05"></span>OPERANDS

> The following operands shall be supported:
>
> *string*
>
> A string to be written to standard output. If the first operand consists of a `'-'` followed by one or more characters from the set {`'e'`, `'E'`, `'n'`}, or if any of the operands contain a \<backslash\> character, the results are implementation-defined.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> On XSI-conformant systems, if the first operand consists of a `'-'` followed by one or more characters from the set {`'e'`, `'E'`, `'n'`}, it shall be treated as a string to be written. The following character sequences shall be recognized on XSI-conformant systems within any of the arguments:
>
> `\a`
>
> Write an \<alert\>.
>
> `\b`
>
> Write a \<backspace\>.
>
> `\c`
>
> Suppress the \<newline\> that otherwise follows the final argument in the output. All characters following the `'\c'` in the arguments shall be ignored.
>
> `\f`
>
> Write a \<form-feed\>.
>
> `\n`
>
> Write a \<newline\>.
>
> `\r`
>
> Write a \<carriage-return\>.
>
> `\t`
>
> Write a \<tab\>.
>
> `\v`
>
> Write a \<vertical-tab\>.
>
> `\\`
>
> Write a \<backslash\> character.
>
> `\0`*num*
>
> Write an 8-bit value that is the zero, one, two, or three-digit octal number *num*.
>
> <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_37_06"></span>STDIN

> Not used.

#### <span id="tag_20_37_07"></span>INPUT FILES

> None.

#### <span id="tag_20_37_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *echo*:
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
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_37_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_37_10"></span>STDOUT

> The *echo* utility arguments shall be separated by single \<space\> characters and a \<newline\> character shall follow the last argument. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  Output transformations shall occur based on the escape sequences in the input. See the OPERANDS section. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_37_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_37_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_37_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_37_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_37_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_37_16"></span>APPLICATION USAGE

> It is not possible to use *echo* portably across all POSIX systems unless escape sequences are omitted, and the first argument does not consist of a `'-'` followed by one or more characters from the set {`'e'`, `'E'`, `'n'`}.
>
> The [*printf*](../utilities/printf.html) utility can be used portably to emulate any of the traditional behaviors of the *echo* utility as follows (assuming that *IFS* has its standard value or is unset):
>
> - The historic System V *echo* and the requirements on XSI implementations in this volume of POSIX.1-2024 are equivalent to:
>
>
>       printf "%b\n" "$*"
>
> - The BSD *echo* is equivalent to:
>
>
>       if [ "X$1" = "X-n" ]
>       then
>           shift
>           printf "%s" "$*"
>       else
>           printf "%s\n" "$*"
>       fi
>
> New applications are encouraged to use [*printf*](../utilities/printf.html) instead of *echo*.

#### <span id="tag_20_37_17"></span>EXAMPLES

> None.

#### <span id="tag_20_37_18"></span>RATIONALE

> The *echo* utility has not been made obsolescent because of its extremely widespread use in historical applications. Conforming applications that wish to do prompting without \<newline\> characters or that could possibly be expecting to echo a string consisting of a `'-'` followed by one or more characters from the set {`'e'`, `'E'`, `'n'`} should use the [*printf*](../utilities/printf.html) utility.
>
> At the time that the IEEE Std 1003.2-1992 standard was being developed, the two different historical versions of *echo* that were considered for standardization varied in incompatible ways.
>
> The BSD *echo* checked the first argument for the string **-n** which caused it to suppress the \<newline\> that would otherwise follow the final argument in the output.
>
> The System V *echo* treated all arguments as strings to be written, but allowed escape sequences within them, as described for XSI implementations in the OPERANDS section, including `\c` to suppress a trailing \<newline\>.
>
> Thus the IEEE Std 1003.2-1992 standard said that the behavior was implementation-defined if the first operand is **-n** or if any of the operands contain a \<backslash\> character. It also specified that the *echo* utility does not support Utility Syntax Guideline 10 because historical applications depended on *echo* to echo *all* of its arguments, except for the **-n** first argument in the BSD version.
>
> The Single UNIX Specification, Version 1 required the System V behavior, and this became the XSI requirement when Version 2 and POSIX.2 were merged with POSIX.1 to form the joint IEEE Std 1003.1-2001 / Single UNIX Specification, Version 3 standard.
>
> This standard now treats a first operand of **-e** or **-E** the same as **-n** in recognition that support for them has become more widespread in non-XSI implementations. Where supported, **-e** enables processing of escape sequences in the remaining operands (in situations where it is disabled by default), and **-E** disables it (in situations where it is enabled by default). A first operand containing a combination of these three letters, in the same manner as option grouping, also results in implementation-defined behavior.

#### <span id="tag_20_37_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_37_20"></span>SEE ALSO

> [*printf*](../utilities/printf.html#tag_20_96)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_37_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_37_22"></span>Issue 5

> In the OPTIONS section, the last sentence is changed to indicate that implementations "do not" support any options; in the previous issue this said "need not".

#### <span id="tag_20_37_23"></span>Issue 6

> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - A set of character sequences is defined as *string* operands.
>
> - *LC_CTYPE* is added to the list of environment variables affecting *echo*.
>
> - In the OPTIONS section, implementations shall not support any options.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/21 is applied, so that the *echo* utility can accommodate historical BSD behavior.

#### <span id="tag_20_37_24"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_37_25"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1222 is applied, making the results implementation-defined, on systems that are not XSI-conformant, if the first operand consists of a `'-'` followed by one or more characters from the set {`'e'`, `'E'`, `'n'`}.

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
