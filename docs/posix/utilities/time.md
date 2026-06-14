The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="time"></span> <span id="tag_20_122"></span>

#### <span id="tag_20_122_01"></span>NAME

> time — time a simple command

#### <span id="tag_20_122_02"></span>SYNOPSIS

> `time`` `**`[`**`-p`**`]`**` `*`utility`*` `**`[`***`argument`*`...`**`]`**

#### <span id="tag_20_122_03"></span>DESCRIPTION

> The *time* utility shall invoke the utility named by the *utility* operand with arguments supplied as the *argument* operands and write a message to standard error that lists timing statistics for the utility. The message shall include the following information:
>
> - The elapsed (real) time between invocation of *utility* and its termination.
>
> - The User CPU time, equivalent to the sum of the *tms_utime* and *tms_cutime* fields returned by the [*times*()](../functions/times.html) function defined in the System Interfaces volume of POSIX.1-2024 for the process in which *utility* is executed.
>
> - The System CPU time, equivalent to the sum of the *tms_stime* and *tms_cstime* fields returned by the [*times*()](../functions/times.html) function for the process in which *utility* is executed.
>
> The precision of the timing shall be no less than the granularity defined for the size of the clock tick unit on the system, but the results shall be reported in terms of standard time units (for example, 0.02 seconds, 00:00:00.02, 1m33.75s, 365.21 seconds), not numbers of clock ticks.
>
> When *time* is used in any of the following circumstances, via a simple command for which the word **time** is the command name (see [*2.9.1.1 Order of Processing*](../utilities/V3_chap02.html#tag_19_09_01_01)), and none of the characters in the word **time** is quoted, the results (including parsing of later words) are unspecified:
>
> - The simple command for which the word **time** is the command name includes one or more redirections (see [*2.7 Redirection*](../utilities/V3_chap02.html#tag_19_07)) or is (directly) part of a pipeline (see [*2.9.2 Pipelines*](../utilities/V3_chap02.html#tag_19_09_02)).
>
> - The next word that follows **time** would, if the word **time** were not present, be recognized as a reserved word (see [*2.4 Reserved Words*](../utilities/V3_chap02.html#tag_19_04)) or a control operator (see XBD [*3.85 Control Operator*](../basedefs/V1_chap03.html#tag_03_85)).
>
> Since these limitations only apply when *time* is executed via a simple command for which the word **time** is the command name and none of the characters in the word **time** is quoted, they can be avoided by quoting all or part of the word **time**, by arranging for the command name not to be **time** (for example, by having the command name be a word expansion), or by executing *time* via another utility such as [*command*](../utilities/command.html) or [*env*](../utilities/env.html).
>
> The limitations on redirections and pipelines can also be overcome by embedding the simple command within a compound command—most commonly a grouping command (see [*2.9.4.1 Grouping Commands*](../utilities/V3_chap02.html#tag_19_09_04_01))—and applying the redirections or piping to the compound command instead.
>
> Note that in no circumstances where the results are specified is it possible to apply different redirections to the *time* utility than are applied to the utility it invokes.
>
> The following examples (where *a* and *b* are assumed to be the names of utilities found by searching *PATH )* show unspecified usages:
>
>
>     time a arg1 arg2 | b    # part of a pipeline
>     a | time -p b           # part of a pipeline
>     time a >/dev/null       # output redirection
>     </dev/null time a       # input redirection
>     time while anything...  # reserved word after time
>     time ( cmd )            # control operator after time
>     time;                   # control operator after time
>     time shift              # special built-in utility
>     time -p cd /            # intrinsic utility
>
> The following examples have specified results and can be used as alternatives for the first four of the above when the *time* utility as specified here is intended to be invoked:
>
>
>     { time a arg1 arg2; } | b
>     t=time; a | $t -p b
>     command time a >/dev/null
>     </dev/null \time a

#### <span id="tag_20_122_04"></span>OPTIONS

> The *time* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-p**
>
> Write the timing output to standard error in the format shown in the STDERR section.

#### <span id="tag_20_122_05"></span>OPERANDS

> The following operands shall be supported:
>
> *utility*
>
> The name of a utility that is to be invoked. If the *utility* operand names a special built-in utility (see [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15)), an intrinsic utility (see [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07)), or a function (see [*2.9.5 Function Definition Command*](../utilities/V3_chap02.html#tag_19_09_05)), the results are unspecified.
>
> *argument*
>
> Any string to be supplied as an argument when invoking the utility named by the *utility* operand.

#### <span id="tag_20_122_06"></span>STDIN

> Not used.

#### <span id="tag_20_122_07"></span>INPUT FILES

> None.

#### <span id="tag_20_122_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *time*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic and informative messages written to standard error.
>
> *LC_NUMERIC*
>
> \
> Determine the locale for numeric formatting.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *PATH*
>
> Determine the search path that shall be used to locate the utility to be invoked; see XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08).

#### <span id="tag_20_122_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_122_10"></span>STDOUT

> Not used.

#### <span id="tag_20_122_11"></span>STDERR

> If the *utility* utility is invoked, the standard error shall be used to write the timing statistics and may be used to write a diagnostic message if the utility terminates abnormally; otherwise, the standard error shall be used to write diagnostic messages and may also be used to write the timing statistics.
>
> If **-p** is specified, the following format shall be used for the timing statistics in the POSIX locale:
>
>
>     "real %f\nuser %f\nsys %f\n", <real seconds>, <user seconds>,
>         <system seconds>
>
> where each floating-point number shall be expressed in seconds. The precision used may be less than the default six digits of `%f`, but shall be sufficiently precise to accommodate the size of the clock tick on the system (for example, if there were 60 clock ticks per second, at least two digits shall follow the radix character). The number of digits following the radix character shall be no less than one, even if this always results in a trailing zero. The implementation may append white space and additional information following the format shown here. The implementation may also prepend a single empty line before the format shown here.

#### <span id="tag_20_122_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_122_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_122_14"></span>EXIT STATUS

> If the *utility* utility is invoked, the exit status of *time* shall be the exit status of *utility*; otherwise, the *time* utility shall exit with one of the following values:
>
> 1-125
>
> An error occurred in the *time* utility.
>
>   126
>
> The utility specified by *utility* was found but could not be invoked.
>
>   127
>
> The utility specified by *utility* could not be found.

#### <span id="tag_20_122_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_122_16"></span>APPLICATION USAGE

> The [*command*](../utilities/command.html), [*env*](../utilities/env.html), [*nice*](../utilities/nice.html), [*nohup*](../utilities/nohup.html), *time*, [*timeout*](../utilities/timeout.html), and [*xargs*](../utilities/xargs.html) utilities have been specified to use exit code 127 if a utility to be invoked cannot be found, so that applications can distinguish "failure to find a utility" from "invoked utility exited with an error indication". The value 127 was chosen because it is not commonly used for other meanings; most utilities use small values for "normal error conditions" and the values above 128 can be confused with termination due to receipt of a signal. The value 126 was chosen in a similar manner to indicate that the utility could be found, but not invoked. Some scripts produce meaningful error messages differentiating the 126 and 127 cases. The distinction between exit codes 126 and 127 is based on KornShell practice that uses 127 when all attempts to *exec* the utility fail with \[ENOENT\], and uses 126 when any attempt to *exec* the utility fails for any other reason.

#### <span id="tag_20_122_17"></span>EXAMPLES

> It is frequently desirable to apply *time* to pipelines or lists of commands. This can be done by placing pipelines and command lists in a single file; this file can then be invoked as a utility, and the *time* applies to everything in the file.
>
> Alternatively, the following command can be used to apply *time* to a complex command:
>
>
>     time sh -c -- 'complex-command-line'

#### <span id="tag_20_122_18"></span>RATIONALE

> When the *time* utility was originally proposed to be included in the ISO POSIX-2:1993 standard, questions were raised about its suitability for inclusion on the grounds that it was not useful for conforming applications, specifically:
>
> - The underlying CPU definitions from the System Interfaces volume of POSIX.1-2024 are vague, so the numeric output could not be compared accurately between systems or even between invocations.
>
> - The creation of portable benchmark programs was outside the scope this volume of POSIX.1-2024.
>
> However, *time* does fit in the scope of user portability. Human judgement can be applied to the analysis of the output, and it could be very useful in hands-on debugging of applications or in providing subjective measures of system performance. Hence it has been included in this volume of POSIX.1-2024.
>
> The default output format has been left unspecified because historical implementations differ greatly in their style of depicting this numeric output. The **-p** option was invented to provide scripts with a common means of obtaining this information.
>
> In the KornShell, *time* is a shell reserved word that can be used to time an entire pipeline, rather than just a simple command. The POSIX definition has been worded to allow this implementation. Consideration was given to invalidating this approach because of the historical model from the C shell and System V shell. However, since the System V *time* utility historically has not produced accurate results in pipeline timing (because the constituent processes are not all owned by the same parent process, as allowed by POSIX), it did not seem worthwhile to break historical KornShell usage.
>
> The term *utility* is used, rather than *command*, to highlight the fact that shell compound commands, pipelines, special built-ins, and so on, cannot be used directly. However, *utility* includes user application programs and shell scripts, not just the standard utilities.

#### <span id="tag_20_122_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_122_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*sh*](../utilities/sh.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*times*()](../functions/times.html#tag_17_629)

#### <span id="tag_20_122_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_122_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.

#### <span id="tag_20_122_23"></span>Issue 7

> The *time* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-115 is applied, updating the example in the DESCRIPTION.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0144 \[266\] is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0194 \[723\] is applied.

#### <span id="tag_20_122_24"></span>Issue 8

> Austin Group Defect 267 is applied, allowing **time** to be a reserved word.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1530 is applied, changing "`sh -c`" to "`sh -c --`".
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
