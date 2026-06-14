The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="hash"></span> <span id="tag_20_56"></span>

#### <span id="tag_20_56_01"></span>NAME

> hash — remember or report utility locations

#### <span id="tag_20_56_02"></span>SYNOPSIS

> `hash`` `**`[`***`utility`*`...`**`]`**\
> \
> `hash -r`\

#### <span id="tag_20_56_03"></span>DESCRIPTION

> The *hash* utility shall affect the way the current shell environment remembers the locations of utilities found as described in [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04). Depending on the arguments specified, it shall add utility locations to its list of remembered locations or it shall purge the contents of the list. When no arguments are specified, it shall report on the contents of the list.
>
> Utilities provided as built-ins to the shell and functions shall not be reported by *hash*.

#### <span id="tag_20_56_04"></span>OPTIONS

> The *hash* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-r**
>
> Forget all previously remembered utility locations.

#### <span id="tag_20_56_05"></span>OPERANDS

> The following operand shall be supported:
>
> *utility*
>
> The name of a utility to be searched for and added to the list of remembered locations. If the search does not find *utility*, it is unspecified whether or not this is treated as an error. If *utility* contains one or more \<slash\> characters, the results are unspecified.

#### <span id="tag_20_56_06"></span>STDIN

> Not used.

#### <span id="tag_20_56_07"></span>INPUT FILES

> None.

#### <span id="tag_20_56_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *hash*:
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
> *PATH*
>
> Determine the location of *utility*, as described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08).

#### <span id="tag_20_56_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_56_10"></span>STDOUT

> The standard output of *hash* shall be used when no arguments are specified. Its format is unspecified, but includes the pathname of each utility in the list of remembered locations for the current shell environment. This list shall consist of those utilities named in previous *hash* invocations that have been invoked, and may contain those invoked and found through the normal command search process. This list shall be cleared when the contents of the *PATH* environment variable are changed.

#### <span id="tag_20_56_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_56_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_56_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_56_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_56_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_56_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> Since *hash* affects the current shell execution environment, it is always provided as a shell regular built-in. If it is called in a separate utility execution environment, such as one of the following:
>
>
>     nohup hash -r
>     find . -type f -exec hash {} +
>
> it does not affect the command search process of the caller's environment.
>
> The *hash* utility may be implemented as an alias—for example, [*alias*](../utilities/alias.html) **-t -**, in which case utilities found through normal command search are not listed by the *hash* command.
>
> The effects of *hash* **-r** can also be achieved portably by resetting the value of *PATH ;* in the simplest form, this can be:
>
>
>     PATH="$PATH"
>
> The use of *hash* with *utility* names is unnecessary for most applications, but may provide a performance improvement on a few implementations; normally, the hashing process is included by default.

#### <span id="tag_20_56_17"></span>EXAMPLES

> None.

#### <span id="tag_20_56_18"></span>RATIONALE

> None.

#### <span id="tag_20_56_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_56_20"></span>SEE ALSO

> [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_56_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_56_22"></span>Issue 7

> The *hash* utility is moved from the XSI option to the Base.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0093 \[241\] is applied.

#### <span id="tag_20_56_23"></span>Issue 8

> Austin Group Defect 248 is applied, changing a command line in the APPLICATION USAGE section.
>
> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
>
> Austin Group Defect 1063 is applied, clarifying that functions are not reported by *hash*, and that the list of remembered locations is cleared when the contents of *PATH* are changed.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1460 is applied, making it explicitly unspecified whether or not *hash* reports an error if it cannot find *utility*.

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
