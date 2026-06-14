The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="renice"></span> <span id="tag_20_103"></span>

#### <span id="tag_20_103_01"></span>NAME

> renice — set nice values of running processes

#### <span id="tag_20_103_02"></span>SYNOPSIS

> `renice`` `**`[`**`-g|-p|-u`**`]`**` ``-n`` `*`increment ID`*`...`

#### <span id="tag_20_103_03"></span>DESCRIPTION

> The *renice* utility shall request that the nice values (see XBD [*3.225 Nice Value*](../basedefs/V1_chap03.html#tag_03_225)) of one or more running processes be changed. By default, the applicable processes are specified by their process IDs. When a process group is specified (see **-g**), the request shall apply to all processes in the process group.
>
> The nice value shall be bounded in an implementation-defined manner. If the requested *increment* would raise or lower the nice value of the executed utility beyond implementation-defined limits, then the limit whose value was exceeded shall be used.
>
> When a user is *renice*d, the request applies to all processes whose saved set-user-ID matches the user ID corresponding to the user.
>
> Regardless of which options are supplied or any other factor, *renice* shall not alter the nice values of any process unless the user requesting such a change has appropriate privileges to do so for the specified process. If the user lacks appropriate privileges to perform the requested action, the utility shall return an error status.
>
> The saved set-user-ID of the user's process shall be checked instead of its effective user ID when *renice* attempts to determine the user ID of the process in order to determine whether the user has appropriate privileges.

#### <span id="tag_20_103_04"></span>OPTIONS

> The *renice* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except for Guideline 9.
>
> The following options shall be supported:
>
> **-g**
>
> Interpret the following operands as unsigned decimal integer process group IDs.
>
> **-n ***increment*
>
> Specify how the nice value of the specified process or processes is to be adjusted. The *increment* option-argument is a positive or negative decimal integer that shall be used to modify the nice value of the specified process or processes. Negative *increment* values may require appropriate privileges.
>
> **-p**
>
> Interpret the following operands as unsigned decimal integer process IDs. The **-p** option is the default if no options are specified.
>
> **-u**
>
> Interpret the following operands as users. If a user exists with a user name equal to the operand, then the user ID of that user is used in further processing. Otherwise, if the operand represents an unsigned decimal integer, it shall be used as the numeric user ID of the user.

#### <span id="tag_20_103_05"></span>OPERANDS

> The following operands shall be supported:
>
> *ID*
>
> A process ID, process group ID, or user name/user ID, depending on the option selected.

#### <span id="tag_20_103_06"></span>STDIN

> Not used.

#### <span id="tag_20_103_07"></span>INPUT FILES

> None.

#### <span id="tag_20_103_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *renice*:
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

#### <span id="tag_20_103_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_103_10"></span>STDOUT

> Not used.

#### <span id="tag_20_103_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_103_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_103_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_103_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_103_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_103_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_103_17"></span>EXAMPLES

> 1.  Adjust the nice value so that process IDs 987 and 32 would have a lower nice value:
>
>
>         renice -n 5 -p 987 32
>
> 2.  Adjust the nice value so that group IDs 324 and 76 would have a higher nice value, if the user has appropriate privileges to do so:
>
>
>         renice -n -4 -g 324 76
>
> 3.  Adjust the nice value so that numeric user ID 8 and user **sas** would have a lower nice value:
>
>
>         renice -n 4 -u 8 sas
>
> Useful nice value increments on historical systems include 19 or 20 (the affected processes run only when nothing else in the system attempts to run) and any negative number (to make processes run faster).

#### <span id="tag_20_103_18"></span>RATIONALE

> The *gid*, *pid*, and *user* specifications do not fit either the definition of operand or option-argument. However, for clarity, they have been included in the OPTIONS section, rather than the OPERANDS section.
>
> The definition of nice value is not intended to suggest that all processes in a system have priorities that are comparable. Scheduling policy extensions such as the realtime priorities in the System Interfaces volume of POSIX.1-2024 make the notion of a single underlying priority for all scheduling policies problematic. Some implementations may implement the [*nice*](../utilities/nice.html)-related features to affect all processes on the system, others to affect just the general time-sharing activities implied by this volume of POSIX.1-2024, and others may have no effect at all. Because of the use of "implementation-defined" in [*nice*](../utilities/nice.html) and *renice*, a wide range of implementation strategies are possible.
>
> Originally, this utility was written in the historical manner, using the term "nice value". This was always a point of concern with users because it was never intuitively obvious what this meant. With a newer version of *renice*, which used the term "system scheduling priority", it was hoped that novice users could better understand what this utility was meant to do. Also, it would be easier to document what the utility was meant to do. Unfortunately, the addition of the POSIX realtime scheduling capabilities introduced the concepts of process and thread scheduling priorities that were totally unaffected by the [*nice*](../utilities/nice.html)/[*renice*](../utilities/renice.html) utilities or the [*nice*()](../functions/nice.html)/[*setpriority*()](../functions/setpriority.html) functions. Continuing to use the term "system scheduling priority" would have incorrectly suggested that these utilities and functions were indeed affecting these realtime priorities. It was decided to revert to the historical term "nice value" to reference this unrelated process attribute.
>
> Although this utility has use by system administrators (and in fact appears in the system administration portion of the BSD documentation), the standard developers considered that it was very useful for individual end users to control their own processes.
>
> Earlier versions of this standard allowed the following forms in the SYNOPSIS:
>
>
>     renice nice_value[-p] pid...[-g gid...][-p pid...][-u user...]
>     renice nice_value -g gid...[-g gid...]-p pid...][-u user...]
>     renice nice_value -u user...[-g gid...]-p pid...][-u user...]
>
> These forms are no longer specified by POSIX.1-2024 but may be present in some implementations.

#### <span id="tag_20_103_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_103_20"></span>SEE ALSO

> [*nice*](../utilities/nice.html#tag_20_86)
>
> XBD [*3.225 Nice Value*](../basedefs/V1_chap03.html#tag_03_225), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_103_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_103_22"></span>Issue 5

> In the SYNOPSIS, an ellipsis is added to the **-u** option in all three obsolescent forms.

#### <span id="tag_20_103_23"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The APPLICATION USAGE section is added.
>
> The obsolescent forms of the SYNOPSIS are removed.
>
> Text previously conditional on POSIX_SAVED_IDS is mandatory in this version. This is a FIPS requirement.

#### <span id="tag_20_103_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied, clarifying that Guideline 9 of the Utility Syntax Guidelines does not apply.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The *renice* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.

#### <span id="tag_20_103_25"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1286 is applied, changing the description of the **-n** option.

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
