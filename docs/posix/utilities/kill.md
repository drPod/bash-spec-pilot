The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="kill"></span> <span id="tag_20_64"></span>

#### <span id="tag_20_64_01"></span>NAME

> kill — terminate or signal processes

#### <span id="tag_20_64_02"></span>SYNOPSIS

> `kill`` `**`[`**`-s`` `*`signal_name`***`]`**` `*`pid`*`...`\
> \
> `kill -l`` `**`[`***`exit_status`***`]`**\
> \
>
> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` kill`` `**`[`**`-`*`signal_name`***`]`**` `*`pid`*`...`\
> \
> `kill`` `**`[`**`-`*`signal_number`***`]`**` `*`pid`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_64_03"></span>DESCRIPTION

> The *kill* utility shall send a signal to the process or processes specified by each *pid* operand.
>
> For each *pid* operand, the *kill* utility shall perform actions equivalent to the [*kill*()](../functions/kill.html) function defined in the System Interfaces volume of POSIX.1-2024 called with the following arguments:
>
> - The value of the *pid* operand shall be used as the *pid* argument.
>
> - The *sig* argument is the value specified by the **-s** option, **-***signal_number* option, or the **-***signal_name* option, or by SIGTERM, if none of these options is specified.

#### <span id="tag_20_64_04"></span>OPTIONS

> The *kill* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  except that in the last two SYNOPSIS forms, the **-***signal_number* and **-***signal_name* options are usually more than a single character. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The following options shall be supported:
>
> **-l**
>
> (The letter ell.) Write all values of *signal_name* supported by the implementation, if no operand is given. If an *exit_status* operand is given and it is a value of the `'?'` shell special parameter (see [*2.5.2 Special Parameters*](../utilities/V3_chap02.html#tag_19_05_02) and [*wait*](../utilities/wait.html)) corresponding to a process that was terminated or stopped by a signal, the *signal_name* corresponding to the signal that terminated or stopped the process shall be written. If an *exit_status* operand is given and it is the unsigned decimal integer value of a signal number, the *signal_name* (the symbolic constant name without the **SIG** prefix defined in the Base Definitions volume of POSIX.1-2024) corresponding to that signal shall be written. Otherwise, the results are unspecified.
>
> **-s ***signal_name*
>
> \
> Specify the signal to send, using one of the symbolic names defined in the [*\<signal.h\>*](../basedefs/signal.h.html) header. Values of *signal_name* shall be recognized in a case-independent fashion, without the **SIG** prefix. In addition, the symbolic name 0 shall be recognized, representing the signal value zero. The corresponding signal shall be sent instead of SIGTERM.
>
> **-***signal_name*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
> Equivalent to **-s** *signal_name*. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-***signal_number*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
> Specify a non-negative decimal integer, *signal_number*, representing the signal to be used instead of SIGTERM, as the *sig* argument in the effective call to [*kill*()](../functions/kill.html). The correspondence between integer values and the *sig* value used is shown in the following list.
>
> The effects of specifying any *signal_number* other than those listed below are undefined.
>
> 0
>
> 0
>
> 1
>
> SIGHUP
>
> 2
>
> SIGINT
>
> 3
>
> SIGQUIT
>
> 6
>
> SIGABRT
>
> 9
>
> SIGKILL
>
> 14
>
> SIGALRM
>
> 15
>
> SIGTERM
>
> If the first argument is a negative integer, it shall be interpreted as a **-***signal_number* option, not as a negative *pid* operand specifying a process group. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_64_05"></span>OPERANDS

> The following operands shall be supported:
>
> *pid*
>
> One of the following:
>
> 1.  A decimal integer specifying a process or process group to be signaled. The process or processes selected by positive, negative, and zero values of the *pid* operand shall be as described for the [*kill*()](../functions/kill.html) function. If process number 0 is specified, all processes in the current process group shall be signaled. For the effects of negative *pid* numbers, see the [*kill*()](../functions/kill.html) function defined in the System Interfaces volume of POSIX.1-2024. If the first *pid* operand is negative, it should be preceded by `"--"` to keep it from being interpreted as an option.
>
> 2.  A job ID (see XBD [*3.182 Job ID*](../basedefs/V1_chap03.html#tag_03_182)) that identifies a process group in the case of a job-control background job, or a process ID in the case of a non-job-control background job (if supported), to be signaled. The job ID notation is applicable only for invocations of *kill* in the current shell execution environment; see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13).
>
>     **Note:**  
>     The job ID type of *pid* is only available on systems supporting the User Portability Utilities option or supporting non-job-control background jobs.
>
> *exit_status*
>
> A decimal integer specifying a signal number or the exit status of a process terminated by a signal.

#### <span id="tag_20_64_06"></span>STDIN

> Not used.

#### <span id="tag_20_64_07"></span>INPUT FILES

> None.

#### <span id="tag_20_64_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *kill*:
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

#### <span id="tag_20_64_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_64_10"></span>STDOUT

> When the **-l** option is not specified, the standard output shall not be used.
>
> When the **-l** option is specified, the symbolic name of each signal shall be written in the following format:
>
>
>     "%s%c", <signal_name>, <separator>
>
> where the \<*signal_name*\> is in uppercase, without the **SIG** prefix, and the \<*separator*\> shall be either a \<newline\> or a \<space\>. For the last signal written, \<*separator*\> shall be a \<newline\>.
>
> When both the **-l** option and *exit_status* operand are specified, the symbolic name of the corresponding signal shall be written in the following format:
>
>
>     "%s\n", <signal_name>

#### <span id="tag_20_64_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_64_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_64_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_64_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The **-l** option was specified and the output specified in STDOUT was successfully written to standard output; or, the **-l** option was not specified, at least one matching process was found for each *pid* operand, and the specified signal was successfully processed for at least one matching process.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_64_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_64_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> Process numbers can be found by using [*ps*](../utilities/ps.html).
>
> The use of job ID notation is not dependent on job control being enabled. When job control has been disabled using [*set*](../utilities/set.html) **+m**, *kill* can still be used to signal the process group associated with a job-control background job, or the process ID associated with a non-control background job (if supported), using
>
>
>     kill %<background job number>
>
> See also the RATIONALE for [*jobs*](../utilities/jobs.html) and [*wait*](../utilities/wait.html).
>
> The job ID notation is not required to work as expected when *kill* is operating in its own utility execution environment. In either of the following examples:
>
>
>     nohup kill %1 &
>     system("kill %1");
>
> the *kill* operates in a different environment and does not share the shell's understanding of job numbers.

#### <span id="tag_20_64_17"></span>EXAMPLES

> Any of the commands:
>
>
>     kill -9 100 -165
>     kill -s kill 100 -165
>     kill -s KILL 100 -165
>
> sends the SIGKILL signal to the process whose process ID is 100 and to all processes whose process group ID is 165, assuming the sending process has permission to send that signal to the specified processes, and that they exist.
>
> The System Interfaces volume of POSIX.1-2024 and this volume of POSIX.1-2024 do not require specific signal numbers for any *signal_names*. Even the **-***signal_number* option provides symbolic (although numeric) names for signals. If a process is terminated by a signal, its exit status indicates the signal that killed it, but the exact values are not specified. The *kill* **-l** option, however, can be used to map decimal signal numbers and exit status values into the name of a signal. The following example reports the status of a terminated job:
>
>
>     job
>     stat=$?
>     if [ $stat -eq 0 ]
>     then
>         echo job completed successfully.
>     elif [ $stat -gt 128 ]
>     then
>         echo job terminated by signal SIG$(kill -l $stat).
>     else
>         echo job terminated with error code $stat.
>     fi
>
> To send the default signal to a process group (say 123), an application should use a command similar to one of the following:
>
>
>     kill -s TERM -- -123
>     kill -- -123

#### <span id="tag_20_64_18"></span>RATIONALE

> The **-l** option originated from the C shell, and is also implemented in the KornShell. The C shell output can consist of multiple output lines because the signal names do not always fit on a single line on some terminal screens. The KornShell output also included the implementation-defined signal numbers and was considered by the standard developers to be too difficult for scripts to parse conveniently. The specified output format is intended not only to accommodate the historical C shell output, but also to permit an entirely vertical or entirely horizontal listing on systems for which this is appropriate.
>
> An early proposal invented the name SIGNULL as a *signal_name* for signal 0 (used by the System Interfaces volume of POSIX.1-2024 to test for the existence of a process without sending it a signal). Since the *signal_name* 0 can be used in this case unambiguously, SIGNULL has been removed.
>
> An early proposal also required symbolic *signal_name*s to be recognized with or without the **SIG** prefix. Historical versions of *kill* have not written the **SIG** prefix for the **-l** option and have not recognized the **SIG** prefix on *signal_name*s. Since neither applications portability nor ease-of-use would be improved by requiring this extension, it is no longer required.
>
> To avoid an ambiguity of an initial negative number argument specifying either a signal number or a process group, POSIX.1-2024 mandates that it is always considered the former by implementations that support the XSI option. It also requires that conforming applications always use the `"--"` options terminator argument when specifying a process group.
>
> The **-s** option was added in response to international interest in providing some form of *kill* that meets the Utility Syntax Guidelines.
>
> The job ID notation is not required to work as expected when *kill* is operating in its own utility execution environment. In either of the following examples:
>
>
>     nohup kill %1 &
>     system("kill %1");
>
> the *kill* operates in a different environment and does not understand how the shell has managed its job numbers.

#### <span id="tag_20_64_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_64_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*ps*](../utilities/ps.html#), [*wait*](../utilities/wait.html#tag_20_147)
>
> XBD [*3.182 Job ID*](../basedefs/V1_chap03.html#tag_03_182), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), [*\<signal.h\>*](../basedefs/signal.h.html)
>
> XSH [*kill*()](../functions/kill.html#tag_17_296)

#### <span id="tag_20_64_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_64_22"></span>Issue 6

> The obsolescent versions of the SYNOPSIS are turned into non-obsolescent features of the XSI option, corresponding to a similar change in the [*trap*](../utilities/V3_chap02.html#trap) special built-in.

#### <span id="tag_20_64_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_64_24"></span>Issue 8

> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1254 is applied, clarifying the **-l** option with regard to an *exit_status* operand corresponding to a stopped process, changing "job control job ID" to "job ID", and adding a paragraph to the RATIONALE section.
>
> Austin Group Defect 1260 is applied, changing the SYNOPSIS and EXAMPLES sections in relation to the **-s** option, and the RATIONALE section in relation to the use of `"--"` when specifying a process group.
>
> Austin Group Defect 1504 is applied, changing the EXIT STATUS section.

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
