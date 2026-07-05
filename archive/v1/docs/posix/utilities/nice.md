The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="nice"></span> <span id="tag_20_86"></span>

#### <span id="tag_20_86_01"></span>NAME

> nice — invoke a utility with an altered nice value

#### <span id="tag_20_86_02"></span>SYNOPSIS

> `nice`` `**`[`**`-n`` `*`increment`***`]`**` `*`utility`*` `**`[`***`argument`*`...`**`]`**

#### <span id="tag_20_86_03"></span>DESCRIPTION

> The *nice* utility shall invoke a utility, requesting that it be run with a different nice value (see XBD [*3.225 Nice Value*](../basedefs/V1_chap03.html#tag_03_225)). With no options, the executed utility shall be run with a nice value that is some implementation-defined quantity greater than or equal to the nice value of the current process. If the user lacks appropriate privileges to affect the nice value in the requested manner, the *nice* utility shall not affect the nice value; in this case, a warning message may be written to standard error, but this shall not prevent the invocation of *utility* or affect the exit status.

#### <span id="tag_20_86_04"></span>OPTIONS

> The *nice* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option is supported:
>
> **-n ***increment*
>
> A positive or negative decimal integer which shall have the same effect on the execution of the utility as if the utility had called the [*nice*()](../functions/nice.html) function with the numeric value of the *increment* option-argument.

#### <span id="tag_20_86_05"></span>OPERANDS

> The following operands shall be supported:
>
> *utility*
>
> The name of a utility that is to be invoked. If the *utility* operand names any of the special built-in utilities in [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15), the results are undefined.
>
> *argument*
>
> Any string to be supplied as an argument when invoking the utility named by the *utility* operand.

#### <span id="tag_20_86_06"></span>STDIN

> Not used.

#### <span id="tag_20_86_07"></span>INPUT FILES

> None.

#### <span id="tag_20_86_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *nice*:
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
> Determine the search path used to locate the utility to be invoked. See XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08).

#### <span id="tag_20_86_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_86_10"></span>STDOUT

> Not used.

#### <span id="tag_20_86_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_86_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_86_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_86_14"></span>EXIT STATUS

> If *utility* is invoked, the exit status of *nice* shall be the exit status of *utility*; otherwise, the *nice* utility shall exit with one of the following values:
>
> 1-125
>
> An error occurred in the *nice* utility.
>
>   126
>
> The utility specified by *utility* was found but could not be invoked.
>
>   127
>
> The utility specified by *utility* could not be found.

#### <span id="tag_20_86_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_86_16"></span>APPLICATION USAGE

> The only guaranteed portable uses of this utility are:
>
> *nice utility*
>
> \
> Run *utility* with the default higher or equal nice value.
>
> *nice ***-n **\<*positive integer*\>* utility*
>
> \
> Run *utility* with a higher nice value.
>
> On some implementations they have no discernible effect on the invoked utility and on some others they are exactly equivalent.
>
> Historical systems have frequently supported the \<*positive integer*\> up to 20. Since there is no error penalty associated with guessing a number that is too high, users without access to the system conformance document (to see what limits are actually in place) could use the historical 1 to 20 range or attempt to use very large numbers if the job should be truly low priority.
>
> The nice value of a process can be displayed using the command:
>
>
>     ps -o nice
>
> The [*command*](../utilities/command.html), [*env*](../utilities/env.html), *nice*, [*nohup*](../utilities/nohup.html), [*time*](../utilities/time.html), [*timeout*](../utilities/timeout.html), and [*xargs*](../utilities/xargs.html) utilities have been specified to use exit code 127 if a utility to be invoked cannot be found, so that applications can distinguish "failure to find a utility" from "invoked utility exited with an error indication". The value 127 was chosen because it is not commonly used for other meanings; most utilities use small values for "normal error conditions" and the values above 128 can be confused with termination due to receipt of a signal. The value 126 was chosen in a similar manner to indicate that the utility could be found, but not invoked. Some scripts produce meaningful error messages differentiating the 126 and 127 cases. The distinction between exit codes 126 and 127 is based on KornShell practice that uses 127 when all attempts to *exec* the utility fail with \[ENOENT\], and uses 126 when any attempt to *exec* the utility fails for any other reason.

#### <span id="tag_20_86_17"></span>EXAMPLES

> None.

#### <span id="tag_20_86_18"></span>RATIONALE

> The 4.3 BSD version of *nice* does not check whether *increment* is a valid decimal integer. The command *nice* **-x** *utility*, for example, would be treated the same as the command *nice* **--1** *utility*. If the user does not have appropriate privileges, this results in a "permission denied" error. This is considered a bug.
>
> When a user without appropriate privileges gives a negative *increment*, System V treats it like the command *nice* **-0** *utility*, while 4.3 BSD writes a "permission denied" message and does not run the utility. The standard specifies the System V behavior together with an optional BSD-style "permission denied" message.
>
> The C shell has a built-in version of *nice* that has a different interface from the one described in this volume of POSIX.1-2024.
>
> The term "utility" is used, rather than "command", to highlight the fact that shell compound commands, pipelines, and so on, cannot be used. Special built-ins also cannot be used. However, "utility" includes user application programs and shell scripts, not just utilities defined in this volume of POSIX.1-2024.
>
> Historical implementations of *nice* provide a nice value range of 40 or 41 discrete steps, with the default nice value being the midpoint of that range. By default, they raise the nice value of the executed utility by 10.
>
> Some historical documentation states that the *increment* value must be within a fixed range. This is misleading; the valid *increment* values on any invocation are determined by the current process nice value, which is not always the default.
>
> The definition of nice value is not intended to suggest that all processes in a system have priorities that are comparable. Scheduling policy extensions such as the realtime priorities in the System Interfaces volume of POSIX.1-2024 make the notion of a single underlying priority for all scheduling policies problematic. Some implementations may implement the *nice*-related features to affect all processes on the system, others to affect just the general time-sharing activities implied by this volume of POSIX.1-2024, and others may have no effect at all. Because of the use of "implementation-defined" in *nice* and [*renice*](../utilities/renice.html), a wide range of implementation strategies are possible.
>
> Earlier versions of this standard allowed a **-***increment* option. This form is no longer specified by POSIX.1-2024 but may be present in some implementations.

#### <span id="tag_20_86_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_86_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*renice*](../utilities/renice.html#)
>
> XBD [*3.225 Nice Value*](../basedefs/V1_chap03.html#tag_03_225), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*nice*()](../functions/nice.html#tag_17_370)

#### <span id="tag_20_86_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_86_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The obsolescent SYNOPSIS is removed.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/18 is applied, deleting a paragraph of RATIONALE that referred to text no longer in the standard.

#### <span id="tag_20_86_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied.
>
> SD5-XCU-ERN-32 and SD5-XCU-ERN-33 are applied, updating the DESCRIPTION, APPLICATION USAGE, and RATIONALE sections.
>
> The *nice* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.

#### <span id="tag_20_86_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1586 is applied, adding the [*timeout*](../utilities/timeout.html) utility.
>
> Austin Group Defect 1594 is applied, changing the APPLICATION USAGE section.

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
