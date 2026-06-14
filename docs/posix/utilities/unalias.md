The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="unalias"></span> <span id="tag_20_133"></span>

#### <span id="tag_20_133_01"></span>NAME

> unalias — remove alias definitions

#### <span id="tag_20_133_02"></span>SYNOPSIS

> `unalias`` `*`alias-name`*`...`\
> \
> `unalias -a`\

#### <span id="tag_20_133_03"></span>DESCRIPTION

> The *unalias* utility shall remove the definition for each alias name specified. See [*2.3.1 Alias Substitution*](../utilities/V3_chap02.html#tag_19_03_01). The aliases shall be removed from the current shell execution environment; see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13).

#### <span id="tag_20_133_04"></span>OPTIONS

> The *unalias* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-a**
>
> Remove all alias definitions from the current shell execution environment.

#### <span id="tag_20_133_05"></span>OPERANDS

> The following operand shall be supported:
>
> *alias-name*
>
> The name of an alias to be removed.

#### <span id="tag_20_133_06"></span>STDIN

> Not used.

#### <span id="tag_20_133_07"></span>INPUT FILES

> None.

#### <span id="tag_20_133_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *unalias*:
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

#### <span id="tag_20_133_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_133_10"></span>STDOUT

> Not used.

#### <span id="tag_20_133_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_133_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_133_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_133_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> One of the *alias-name* operands specified did not represent a valid alias definition, or an error occurred.

#### <span id="tag_20_133_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_133_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> Since *unalias* affects the current shell execution environment, it is generally provided as a shell regular built-in.

#### <span id="tag_20_133_17"></span>EXAMPLES

> None.

#### <span id="tag_20_133_18"></span>RATIONALE

> The *unalias* description is based on that from historical KornShell implementations. Known differences exist between that and the C shell. The KornShell version was adopted to be consistent with all the other KornShell features in this volume of POSIX.1-2024, such as command line editing.
>
> The **-a** option is the equivalent of the *unalias* \* form of the C shell and is provided to address security concerns about unknown aliases entering the environment of a user (or application) through the allowable implementation-defined predefined alias route or as a result of an *ENV* file. (Although *unalias* could be used to simplify the "secure" shell script shown in the [*command*](../utilities/command.html) rationale, it does not obviate the need to quote all command names. An initial call to *unalias* **-a** would have to be quoted in case there was an alias for *unalias*.)

#### <span id="tag_20_133_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_133_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*alias*](../utilities/alias.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_133_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_133_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.

#### <span id="tag_20_133_23"></span>Issue 7

> The *unalias* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.

#### <span id="tag_20_133_24"></span>Issue 8

> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
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
