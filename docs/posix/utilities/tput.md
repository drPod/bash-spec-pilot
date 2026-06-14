The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="tput"></span> <span id="tag_20_125"></span>

#### <span id="tag_20_125_01"></span>NAME

> tput — change terminal characteristics

#### <span id="tag_20_125_02"></span>SYNOPSIS

> `tput`` `**`[`**`-T`` `*`type`***`]`**` `*`operand`*`...`

#### <span id="tag_20_125_03"></span>DESCRIPTION

> The *tput* utility shall display terminal-dependent information. The manner in which this information is retrieved is unspecified. The information displayed shall clear the terminal screen, initialize the user's terminal, or reset the user's terminal, depending on the operand given. The exact consequences of displaying this information are unspecified.

#### <span id="tag_20_125_04"></span>OPTIONS

> The *tput* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-T ***type*
>
> Indicate the type of terminal. If this option is not supplied and the *TERM* variable is unset or null, an unspecified default terminal type shall be used. The setting of *type* shall take precedence over the value in *TERM .*

#### <span id="tag_20_125_05"></span>OPERANDS

> The following strings shall be supported as operands by the implementation in the POSIX locale:
>
> **clear**
>
> Display the clear-screen sequence.
>
> **init**
>
> Display the sequence that initializes the user's terminal in an implementation-defined manner.
>
> **reset**
>
> Display the sequence that resets the user's terminal in an implementation-defined manner.
>
> If a terminal does not support any of the operations described by these operands, this shall not be considered an error condition.

#### <span id="tag_20_125_06"></span>STDIN

> Not used.

#### <span id="tag_20_125_07"></span>INPUT FILES

> None.

#### <span id="tag_20_125_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *tput*:
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
>
> *TERM*
>
> Determine the terminal type. If this variable is unset or null, and if the **-T** option is not specified, an unspecified default terminal type shall be used.

#### <span id="tag_20_125_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_125_10"></span>STDOUT

> If standard output is a terminal device, it may be used for writing the appropriate sequence to clear the screen or reset or initialize the terminal. If standard output is not a terminal device, undefined results occur.

#### <span id="tag_20_125_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_125_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_125_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_125_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The requested string was written successfully.
>
>  1
>
> Unspecified.
>
>  2
>
> Usage error.
>
>  3
>
> No information is available about the specified terminal type.
>
>  4
>
> The specified operand is invalid.
>
> \>4
>
> An error occurred.

#### <span id="tag_20_125_15"></span>CONSEQUENCES OF ERRORS

> If one of the operands is not available for the terminal, *tput* continues processing the remaining operands.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_125_16"></span>APPLICATION USAGE

> The difference between resetting and initializing a terminal is left unspecified, as they vary greatly based on hardware types. In general, resetting is a more severe action.
>
> Some terminals use control characters to perform the stated functions, and on such terminals it might make sense to use *tput* to store the initialization strings in a file or environment variable for later use. However, because other terminals might rely on system calls to do this work, the standard output cannot be used in a portable manner, such as the following non-portable constructs:
>
>
>     ClearVar=`tput clear`
>     tput reset | mailx -s "Wake Up" ddg

#### <span id="tag_20_125_17"></span>EXAMPLES

> 1.  Initialize the terminal according to the type of terminal in the environmental variable *TERM .* This command can be included in a **.profile** file.
>
>
>         tput init
>
> 2.  Reset a 450 terminal.
>
>
>         tput -T 450 reset

#### <span id="tag_20_125_18"></span>RATIONALE

> The list of operands was reduced to a minimum for the following reasons:
>
> - The only features chosen were those that were likely to be used by human users interacting with a terminal.
>
> - Specifying the full *terminfo* set was not considered desirable, but the standard developers did not want to select among operands.
>
> - This volume of POSIX.1-2024 does not attempt to provide applications with sophisticated terminal handling capabilities, as that falls outside of its assigned scope and intersects with the responsibilities of other standards bodies.
>
> The difference between resetting and initializing a terminal is left unspecified as this varies greatly based on hardware types. In general, resetting is a more severe action.
>
> The exit status of 1 is historically reserved for finding out if a Boolean operand is not set. Although the operands were reduced to a minimum, the exit status of 1 should still be reserved for the Boolean operands, for those sites that wish to support them.

#### <span id="tag_20_125_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_125_20"></span>SEE ALSO

> [*stty*](../utilities/stty.html#), [*tabs*](../utilities/tabs.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_125_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_125_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.

#### <span id="tag_20_125_23"></span>Issue 7

> The *tput* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.

#### <span id="tag_20_125_24"></span>Issue 8

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
