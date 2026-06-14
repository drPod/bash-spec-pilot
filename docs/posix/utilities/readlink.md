The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="readlink"></span> <span id="tag_20_101"></span>

#### <span id="tag_20_101_01"></span>NAME

> readlink — display the contents of a symbolic link

#### <span id="tag_20_101_02"></span>SYNOPSIS

> `readlink`` `**`[`**`-n`**`]`**` `*`file`*

#### <span id="tag_20_101_03"></span>DESCRIPTION

> If the *file* operand names a symbolic link, the *readlink* utility shall not follow the symbolic link when resolving *file* and shall write the contents of the symbolic link to standard output. If the **-n** option is not specified, the output to standard output shall be followed by a \<newline\> character.
>
> If *file* does not name a symbolic link, *readlink* shall write a diagnostic message to standard error and exit with non-zero status.

#### <span id="tag_20_101_04"></span>OPTIONS

> The *readlink* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-n**
>
> Do not output a trailing \<newline\> character.

#### <span id="tag_20_101_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a symbolic link to be read.

#### <span id="tag_20_101_06"></span>STDIN

> Not used.

#### <span id="tag_20_101_07"></span>INPUT FILES

> None.

#### <span id="tag_20_101_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *readlink*:
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

#### <span id="tag_20_101_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_101_10"></span>STDOUT

> See DESCRIPTION.

#### <span id="tag_20_101_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_101_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_101_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_101_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_101_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_101_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_101_17"></span>EXAMPLES

> None.

#### <span id="tag_20_101_18"></span>RATIONALE

> The *readlink* utility was added because using [*ls*](../utilities/ls.html) **-l** to obtain the contents of a symbolic link is difficult if the output includes more than one occurrence of the string `" -> "`.
>
> The **-f** option found in many implementations was not included, as the [*realpath*](../utilities/realpath.html) utility provides equivalent functionality with a choice of behaviors.

#### <span id="tag_20_101_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_101_20"></span>SEE ALSO

> [*ln*](../utilities/ln.html#), [*ls*](../utilities/ls.html#), [*realpath*](../utilities/realpath.html#tag_20_102)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*readlink*()](../functions/readlink.html#)

#### <span id="tag_20_101_21"></span>CHANGE HISTORY

> First released in Issue 8.

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
