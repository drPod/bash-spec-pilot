The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="strip"></span> <span id="tag_20_115"></span>

#### <span id="tag_20_115_01"></span>NAME

> strip — remove unnecessary information from strippable files (**DEVELOPMENT**)

#### <span id="tag_20_115_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`SD`](javascript:open_code('SD'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` strip`` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_115_03"></span>DESCRIPTION

> A strippable file is defined as a relocatable, object, or executable file. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  On XSI-conformant systems, a strippable file can also be an archive of object or relocatable files. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The *strip* utility shall remove from strippable files named by the *file* operands any information the implementor deems unnecessary for execution of those files. The nature of that information is unspecified. The effect of *strip* on object and executable files shall be similar to the use of the **-s** option to [*c17*](../utilities/c17.html). <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  The effect of *strip* on an archive of object files shall be similar to the use of the **-s** option to [*c17*](../utilities/c17.html) for each object file in the archive. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_115_04"></span>OPTIONS

> None.

#### <span id="tag_20_115_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname referring to a strippable file.

#### <span id="tag_20_115_06"></span>STDIN

> Not used.

#### <span id="tag_20_115_07"></span>INPUT FILES

> The input files shall be in the form of strippable files successfully produced by any compiler defined by this volume of POSIX.1-2024 <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  or produced by creating or updating an archive of such files using the [*ar*](../utilities/ar.html) utility. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_115_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *strip*:
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

#### <span id="tag_20_115_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_115_10"></span>STDOUT

> Not used.

#### <span id="tag_20_115_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_115_12"></span>OUTPUT FILES

> The *strip* utility shall produce strippable files of unspecified format.

#### <span id="tag_20_115_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_115_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_115_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_115_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_115_17"></span>EXAMPLES

> None.

#### <span id="tag_20_115_18"></span>RATIONALE

> Historically, this utility has been used to remove the symbol table from a strippable file. It was included since it is known that the amount of symbolic information can amount to several megabytes; the ability to remove it in a portable manner was deemed important, especially for smaller systems.
>
> The behavior of *strip* on object and executable files is said to be the same as the **-s** option to a compiler. While the end result is essentially the same, it is not required to be identical.
>
> XSI-conformant systems support use of *strip* on archive files containing object files or relocatable files.

#### <span id="tag_20_115_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_115_20"></span>SEE ALSO

> [*ar*](../utilities/ar.html#), [*c17*](../utilities/c17.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_115_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_115_22"></span>Issue 6

> This utility is marked as part of the Software Development Utilities option.

#### <span id="tag_20_115_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#103 is applied.

#### <span id="tag_20_115_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1330 is applied, removing obsolescent interfaces.

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
