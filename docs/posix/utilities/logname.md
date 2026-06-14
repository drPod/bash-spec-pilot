The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="logname"></span> <span id="tag_20_71"></span>

#### <span id="tag_20_71_01"></span>NAME

> logname — return the user's login name

#### <span id="tag_20_71_02"></span>SYNOPSIS

> `logname`

#### <span id="tag_20_71_03"></span>DESCRIPTION

> The *logname* utility shall write the user's login name to standard output. The login name shall be the string that would be returned by the [*getlogin*()](../functions/getlogin.html) function defined in the System Interfaces volume of POSIX.1-2024. Under the conditions where the [*getlogin*()](../functions/getlogin.html) function would fail, the *logname* utility shall write a diagnostic message to standard error and exit with a non-zero exit status.

#### <span id="tag_20_71_04"></span>OPTIONS

> None.

#### <span id="tag_20_71_05"></span>OPERANDS

> None.

#### <span id="tag_20_71_06"></span>STDIN

> Not used.

#### <span id="tag_20_71_07"></span>INPUT FILES

> None.

#### <span id="tag_20_71_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *logname*:
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

#### <span id="tag_20_71_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_71_10"></span>STDOUT

> The *logname* utility output shall be a single line consisting of the user's login name:
>
>
>     "%s\n", <login name>

#### <span id="tag_20_71_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_71_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_71_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_71_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_71_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_71_16"></span>APPLICATION USAGE

> The *logname* utility explicitly ignores the *LOGNAME* environment variable because environment changes could produce erroneous results.

#### <span id="tag_20_71_17"></span>EXAMPLES

> None.

#### <span id="tag_20_71_18"></span>RATIONALE

> The **passwd** file is not listed as required because the implementation may have other means of mapping login names.

#### <span id="tag_20_71_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_71_20"></span>SEE ALSO

> [*id*](../utilities/id.html#), [*who*](../utilities/who.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)
>
> XSH [*getlogin*()](../functions/getlogin.html#)

#### <span id="tag_20_71_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_71_22"></span>Issue 8

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
