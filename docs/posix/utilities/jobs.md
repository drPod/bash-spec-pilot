The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="jobs"></span> <span id="tag_20_62"></span>

#### <span id="tag_20_62_01"></span>NAME

> jobs — display status of jobs in the current shell execution environment

#### <span id="tag_20_62_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`UP`](javascript:open_code('UP'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` jobs`` `**`[`**`-l|-p`**`] [`***`job_id`*`...`**`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_62_03"></span>DESCRIPTION

> If the current shell execution environment (see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13)) is not a subshell environment, the *jobs* utility shall display the status of background jobs that were created in the current shell execution environment; it may also do so if the current shell execution environment is a subshell environment.
>
> When *jobs* reports the termination status of a job, the shell shall remove the job from the background jobs list and the associated process ID from the list of those "known in the current shell execution environment"; see [*2.9.3.1 Asynchronous AND-OR Lists*](../utilities/V3_chap02.html#tag_19_09_03_02). If a write error occurs when *jobs* writes to standard output, some process IDs might have been removed from the list but not successfully reported.

#### <span id="tag_20_62_04"></span>OPTIONS

> The *jobs* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-l**
>
> (The letter ell.) Provide more information about each job listed. See STDOUT for details.
>
> **-p**
>
> Display only the process IDs for the process group leaders of job-control background jobs and the process IDs associated with non-job-control background jobs (if supported).
>
> By default, the *jobs* utility shall display the status of all background jobs, both running and suspended, and all jobs whose status has changed and have not been reported by the shell.

#### <span id="tag_20_62_05"></span>OPERANDS

> The following operand shall be supported:
>
> *job_id*
>
> Specifies the jobs for which the status is to be displayed. If no *job_id* is given, the status information for all jobs shall be displayed. The format of *job_id* is described in XBD [*3.182 Job ID*](../basedefs/V1_chap03.html#tag_03_182).

#### <span id="tag_20_62_06"></span>STDIN

> Not used.

#### <span id="tag_20_62_07"></span>INPUT FILES

> None.

#### <span id="tag_20_62_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *jobs*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_62_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_62_10"></span>STDOUT

> If the **-p** option is specified, the output shall consist of one line for each process ID:
>
>
>     "%d\n", <process ID>
>
> Otherwise, if the **-l** option is not specified, the output shall be a series of lines of the form:
>
>
>     "[%d] %c %s %s\n", <job-number>, <current>, <state>, <command>
>
> where the fields shall be as follows:
>
> \<*current*\>
>
> The character `'+'` identifies the job that would be used as a default for the [*fg*](../utilities/fg.html) or [*bg*](../utilities/bg.html) utilities; this job can also be specified using the *job_id* %+ or `"%%"`. The character `'-'` identifies the job that would become the default if the current default job were to exit; this job can also be specified using the *job_id* %-. For other jobs, this field is a \<space\>. At most one job can be identified with `'+'` and at most one job can be identified with `'-'`. If there is any suspended job, then the current job shall be a suspended job. If there are at least two suspended jobs, then the previous job also shall be a suspended job.
>
> \<*job-number*\>
>
> A number that can be used to identify the job to the [*wait*](../utilities/wait.html), [*fg*](../utilities/fg.html), [*bg*](../utilities/bg.html), and [*kill*](../utilities/kill.html) utilities. Using these utilities, the job can be identified by prefixing the job number with `'%'`.
>
> \<*state*\>
>
> One of the following strings (in the POSIX locale):
>
> **Running**
>
> Indicates that the job has not been suspended by a signal and has not exited.
>
> **Done**
>
> Indicates that the job completed and returned exit status zero.
>
> **Done**(*code*)
>
> Indicates that the job completed normally and that it exited with the specified non-zero exit status, *code*, expressed as a decimal number.
>
> **Stopped**
>
> Indicates that the job was suspended by the SIGTSTP signal.
>
> **Stopped** (**SIGTSTP**)
>
> \
> Indicates that the job was suspended by the SIGTSTP signal.
>
> **Stopped** (**SIGSTOP**)
>
> \
> Indicates that the job was suspended by the SIGSTOP signal.
>
> **Stopped** (**SIGTTIN**)
>
> \
> Indicates that the job was suspended by the SIGTTIN signal.
>
> **Stopped** (**SIGTTOU**)
>
> \
> Indicates that the job was suspended by the SIGTTOU signal.
>
> The implementation may substitute the string **Suspended** in place of **Stopped**. If the job was terminated by a signal, the format of \<*state*\> is unspecified, but it shall be visibly distinct from all of the other \<*state*\> formats shown here and shall indicate the name or description of the signal causing the termination.
>
> \<*command*\>
>
> The associated command that was given to the shell.
>
> If the **-l** option is specified:
>
> - For job-control background jobs, a field containing the process group ID shall be inserted before the \<*state*\> field. Also, more processes in a process group may be output on separate lines, using only the process ID and \<*command*\> fields.
>
> - For non-job-control background jobs (if supported), a field containing the process ID associated with the job shall be inserted before the \<*state*\> field. Also, more processes created to execute the job may be output on separate lines, using only the process ID and \<*command*\> fields.

#### <span id="tag_20_62_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_62_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_62_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_62_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The output specified in STDOUT was successfully written to standard output.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_62_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_62_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> The **-p** option is the only portable way to find out the process group of a job-control background job because different implementations have different strategies for defining the process group of the job. Usage such as \$(*jobs* **-p**) provides a way of referring to the process group of the job in an implementation-independent way.
>
> The *jobs* utility does not work as expected when it is operating in its own utility execution environment because that environment has no applicable jobs to manipulate. See the APPLICATION USAGE section for [*bg*](../utilities/bg.html#). For this reason, *jobs* is generally implemented as a shell regular built-in.

#### <span id="tag_20_62_17"></span>EXAMPLES

> None.

#### <span id="tag_20_62_18"></span>RATIONALE

> Both `"%%"` and `"%+"` are used to refer to the current job. Both forms are of equal validity—the `"%%"` mirroring `"$$"` and `"%+"` mirroring the output of *jobs*. Both forms reflect historical practice of the KornShell and the C shell with job control.
>
> The job control features provided by [*bg*](../utilities/bg.html), [*fg*](../utilities/fg.html), and *jobs* are based on the KornShell. The standard developers examined the characteristics of the C shell versions of these utilities and found that differences exist. Despite widespread use of the C shell, the KornShell versions were selected for this volume of POSIX.1-2024 to maintain a degree of uniformity with the rest of the KornShell features selected (such as the very popular command line editing features).
>
> The *jobs* utility is not dependent on job control being enabled, as are the seemingly related [*bg*](../utilities/bg.html) and [*fg*](../utilities/fg.html) utilities because *jobs* is useful for examining background jobs, regardless of the current state of job control. When job control has been disabled using [*set*](../utilities/V3_chap02.html#set) **+m**, the *jobs* utility can still be used to examine the job-control background jobs and (if supported) non-job-control background jobs that were created in the current shell execution environment. See also the RATIONALE for [*kill*](../utilities/kill.html) and [*wait*](../utilities/wait.html).
>
> The output for terminated jobs is left unspecified to accommodate various historical systems. The following formats have been witnessed:
>
> 1.  **Killed**(*signal name*)
>
> 2.  *signal name*
>
> 3.  *signal name*(**coredump**)
>
> 4.  *signal description*- **core dumped**
>
> Most users should be able to understand these formats, although it means that applications have trouble parsing them.
>
> The calculation of job IDs was not described since this would suggest an implementation, which may impose unnecessary restrictions.
>
> In an early proposal, a **-n** option was included to "Display the status of jobs that have changed, exited, or stopped since the last status report". It was removed because the shell always writes any changed status of jobs before each prompt.
>
> If *jobs* uses buffered writes to standard output, a write error could be detected when attempting to flush a buffer containing multiple reports of terminated jobs, resulting in some unreported jobs having their process IDs removed from the list of those known in the current shell execution environment (because they were removed when the report was added to the buffer).

#### <span id="tag_20_62_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_62_20"></span>SEE ALSO

> [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13), [*bg*](../utilities/bg.html#), [*fg*](../utilities/fg.html#), [*kill*](../utilities/kill.html#tag_20_64), [*wait*](../utilities/wait.html#tag_20_147)
>
> XBD [*3.182 Job ID*](../basedefs/V1_chap03.html#tag_03_182), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_62_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_62_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The JC shading is removed as job control is mandatory in this version.

#### <span id="tag_20_62_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_62_24"></span>Issue 8

> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1254 is applied, updating various requirements for the *jobs* utility to account for the addition of [*2.11 Job Control*](../utilities/V3_chap02.html#tag_19_11).
>
> Austin Group Defect 1492 is applied, clarifying the requirements when a write error to standard output occurs.

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
