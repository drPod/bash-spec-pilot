The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="ulimit"></span> <span id="tag_20_131"></span>

#### <span id="tag_20_131_01"></span>NAME

> ulimit — report or set resource limits

#### <span id="tag_20_131_02"></span>SYNOPSIS

> `ulimit`` `**`[`**`-H|-S`**`]`**` ``-a`\
> \
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` ulimit`` `**`[`**`-H|-S`**`] [`**`-c|-d|-f|-n|-s|`<img src="../images/opt-start.gif" data-border="0" />`-t`<img src="../images/opt-end.gif" data-border="0" />`|-v`**`] [`***`newlimit`***`]`**\

#### <span id="tag_20_131_03"></span>DESCRIPTION

> The *ulimit* utility shall report or set the resource limits in effect in the process in which it is executed.
>
> Soft limits can be changed by a process to any value that is less than or equal to the hard limit. A process can (irreversibly) lower its hard limit to any value that is greater than or equal to the soft limit. Only a process with appropriate privileges can raise a hard limit.
>
> The value **unlimited** for a resource shall be considered to be larger than any other limit value. When a resource has this limit value, the implementation shall not enforce limits on that resource. In locales other than the POSIX locale, *ulimit* may support additional non-numeric values with the same meaning as **unlimited**.
>
> The behavior when resource limits are exceeded shall be as described in the System Interfaces volume of POSIX.1-2024 for the [*setrlimit*()](../functions/setrlimit.html) function.

#### <span id="tag_20_131_04"></span>OPTIONS

> The *ulimit* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that:
>
> - The order in which options other than **-H**, **-S**, and **-a** are specified may be significant.
>
> - Conforming applications shall specify each option separately; that is, grouping option letters (for example, **-fH**) need not be recognized by all implementations.
>
> The following options shall be supported:
>
> **-H**
>
> Report hard limit(s) or set only a hard limit.
>
> **-S**
>
> Report soft limit(s) or set only a soft limit.
>
> **-a**
>
> Report the limit value for all of the resources named below and for any implementation-specific additional resources.
>
> **-c**
>
> Report, or set if the *newlimit* operand is present, the core image size limit(s) in units of 512 bytes. \[RLIMIT_CORE\]
>
> **-d**
>
> Report, or set if the *newlimit* operand is present, the data segment size limit(s) in units of 1024 bytes. \[RLIMIT_DATA\]
>
> **-f**
>
> Report, or set if the *newlimit* operand is present, the file size limit(s) in units of 512 bytes. \[RLIMIT_FSIZE\]
>
> **-n**
>
> Report, or set if the *newlimit* operand is present, the limit(s) on the number of open file descriptors, given as a number one greater than the maximum value that the system assigns to a newly-created descriptor. \[RLIMIT_NOFILE\]
>
> **-s**
>
> Report, or set if the *newlimit* operand is present, the stack size limit(s) in units of 1024 bytes. \[RLIMIT_STACK\]
>
> **-t**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Report, or set if the *newlimit* operand is present, the per-process CPU time limit(s) in units of seconds. \[RLIMIT_CPU\] <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-v**
>
> Report, or set if the *newlimit* operand is present, the address space size limit(s) in units of 1024 bytes. \[RLIMIT_AS\]
>
> Where an option description is followed by \[RLIMIT\_*name*\] it indicates which resource for the [*getrlimit*()](../functions/getrlimit.html) and [*setrlimit*()](../functions/setrlimit.html) functions, defined in the System Interfaces volume of POSIX.1-2024, the option corresponds to.
>
> If neither the **-H** nor **-S** option is specified:
>
> - If the *newlimit* operand is present, it shall be used as the new value for both the hard and soft limits.
>
> - If the *newlimit* operand is not present, **-S** shall be the default.
>
> If no options other than **-H** or **-S** are specified, the behavior shall be as if the **-f** option was (also) specified.
>
> If any option other than **-H** or **-S** is repeated, the behavior is unspecified.

#### <span id="tag_20_131_05"></span>OPERANDS

> The following operand shall be supported:
>
> *newlimit*
>
> Either an integer value to use as the new limit(s) for the specified resource, in the units specified in OPTIONS, or a non-numeric string indicating no limit, as described in the DESCRIPTION section. Numerals in the range 0 to the maximum limit value supported by the implementation for any resource shall be syntactically recognized as numeric values.

#### <span id="tag_20_131_06"></span>STDIN

> Not used.

#### <span id="tag_20_131_07"></span>INPUT FILES

> None.

#### <span id="tag_20_131_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *ulimit*:
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
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_131_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_131_10"></span>STDOUT

> The standard output shall be used when no *newlimit* operand is present.
>
> If the **-a** option is specified, the output written for each resource shall consist of one line that includes:
>
> - A short phrase identifying the resource (for example "file size").
>
> - An indication of the units used for the resource, if the corresponding option description in OPTIONS specifies the units to be used.
>
> - The *ulimit* option used to specify the resource.
>
> - The limit value.
>
> The format used within each line is unspecified, except that the format used for the limit value shall be as described below for the case where a single limit value is written.
>
> If a single limit value is to be written; that is, the **-a** option is not specified and at most one option other than **-H** or **-S** is specified:
>
> - If the resource being reported has a numeric limit, the limit value shall be written in the following format:
>
>
>       "%1d\n", <limit value>
>
>   where \<*limit value*\> is the value of the limit in the units specified in OPTIONS.
>
> - If the resource being reported does not have a numeric limit, in the POSIX locale the following format shall be used:
>
>
>       "unlimited\n"

#### <span id="tag_20_131_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_131_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_131_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_131_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> A request for a higher limit was rejected or an error occurred.

#### <span id="tag_20_131_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_131_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> Since *ulimit* affects the current shell execution environment, it is always provided as a shell regular built-in. If it is called with an operand in a separate utility execution environment, such as one of the following:
>
>
>     nohup ulimit -f 10000
>     env ulimit -S -c 10000
>
> it does not affect the limit(s) in the caller's environment.
>
> See also the APPLICATION USAGE for [*getrlimit*()](../functions/getrlimit.html#).

#### <span id="tag_20_131_17"></span>EXAMPLES

> Set the hard and soft file size limits to 51200 bytes:
>
>
>     ulimit -f 100
>
> Save and restore a soft resource limit (where *X* is an option letter specifying a resource):
>
>
>     saved=$(ulimit -X)
>
>     ...
>
>     ulimit -X -S "$saved"
>
> Execute a utility with a CPU limit of 5 minutes (using an asynchronous subshell to ensure the limit is set in a child process):
>
>
>     (ulimit -t 300; exec utility_name </dev/null) &
>     wait $!

#### <span id="tag_20_131_18"></span>RATIONALE

> The *ulimit* utility has no equivalent of the special values RLIM_SAVED_MAX and RLIM_SAVED_CUR returned by [*getrlimit*()](../functions/getrlimit.html), as *ulimit* is required to be able to output, and accept as input, all numeric limit values supported by the system.
>
> Implementations differ in their behavior when the **-a** option is not specified and more than one option other than **-H** or **-S** is specified. Some write output for all of the specified resources in the same format as for **-a**; others write only the value for the last specified option. Both behaviors are allowed by the standard, since the SYNOPSIS lists the options as mutually exclusive.

#### <span id="tag_20_131_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_131_20"></span>SEE ALSO

> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*getrlimit*()](../functions/getrlimit.html#)

#### <span id="tag_20_131_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_131_22"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_131_23"></span>Issue 8

> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1418 is applied, adding the **-H**, **-S**, **-a**, **-c**, **-d**, **-n**, **-s**, **-t**, and **-v** options, and relating the **-f** option to the RLIMIT_FSIZE resource for [*setrlimit*()](../functions/setrlimit.html).
>
> Austin Group Defect 1669 is applied, moving the *ulimit* utility, excluding the **-t** option, from the XSI option to the Base.

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
