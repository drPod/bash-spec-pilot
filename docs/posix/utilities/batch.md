The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="batch"></span> <span id="tag_20_08"></span>

#### <span id="tag_20_08_01"></span>NAME

> batch — schedule commands to be executed in a batch queue

#### <span id="tag_20_08_02"></span>SYNOPSIS

> *batch*

#### <span id="tag_20_08_03"></span>DESCRIPTION

> The *batch* utility shall read commands from standard input and schedule them for execution in a batch queue. It shall be the equivalent of the command:
>
>
>     at -q b -m now
>
> where queue *b* is a special [*at*](../utilities/at.html) queue, specifically for batch jobs. Batch jobs shall be submitted to the batch queue with no time constraints and shall be run by the system using algorithms, based on unspecified factors, that may vary with each invocation of *batch*.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Users shall be permitted to use *batch* if their name appears in the file **at.allow** which is located in an implementation-defined directory. If that file does not exist, the file **at.deny**, which is located in an implementation-defined directory, shall be checked to determine whether the user shall be denied access to *batch*. If neither file exists, only a process with appropriate privileges shall be allowed to submit a job. If only **at.deny** exists and is empty, global usage shall be permitted. The **at.allow** and **at.deny** files shall consist of one user name per line. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_08_04"></span>OPTIONS

> None.

#### <span id="tag_20_08_05"></span>OPERANDS

> None.

#### <span id="tag_20_08_06"></span>STDIN

> The standard input shall be a text file consisting of commands acceptable to the shell command language described in [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19).

#### <span id="tag_20_08_07"></span>INPUT FILES

> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The text files **at.allow** and **at.deny**, which are located in an implementation-defined directory, shall contain zero or more user names, one per line, of users who are, respectively, authorized or denied access to the [*at*](../utilities/at.html) and *batch* utilities. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_08_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *batch*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *LC_TIME*
>
> Determine the format and contents for date and time strings written by *batch*.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *SHELL*
>
> Determine the name of a command interpreter to be used to invoke the at-job. If the variable is unset or null, [*sh*](../utilities/sh.html) shall be used. If it is set to a value other than a name for [*sh*](../utilities/sh.html), the implementation shall do one of the following: use that shell; use [*sh*](../utilities/sh.html); use the login shell from the user database; any of the preceding accompanied by a warning diagnostic about which was chosen.
>
> *TZ*
>
> Determine the timezone. The job shall be submitted for execution at the time specified by *timespec* or **-t** *time* relative to the timezone specified by the *TZ* variable. If *timespec* specifies a timezone, it overrides *TZ .* If *timespec* does not specify a timezone and *TZ* is unset or null, an unspecified default timezone shall be used.

#### <span id="tag_20_08_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_08_10"></span>STDOUT

> When standard input is a terminal, prompts of unspecified format for each line of the user input described in the STDIN section may be written to standard output.

#### <span id="tag_20_08_11"></span>STDERR

> The following shall be written to standard error when a job has been successfully submitted:
>
>
>     "job %s at %s\n", at_job_id, <date>
>
> where *date* shall be equivalent in format to the output of:
>
>
>     date +"%a %b %e %T %Y"
>
> The date and time written shall be adjusted so that they appear in the timezone of the user (as determined by the *TZ* variable).
>
> Neither this, nor warning messages concerning the selection of the command interpreter, are considered a diagnostic that changes the exit status.
>
> Diagnostic messages, if any, shall be written to standard error.

#### <span id="tag_20_08_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_08_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_08_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_08_15"></span>CONSEQUENCES OF ERRORS

> The job shall not be scheduled.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_08_16"></span>APPLICATION USAGE

> It may be useful to redirect standard output within the specified commands.

#### <span id="tag_20_08_17"></span>EXAMPLES

> 1.  This sequence can be used at a terminal:
>
>
>         batch
>         sort < file >outfile
>         EOT
>
> 2.  This sequence, which demonstrates redirecting standard error to a pipe, is useful in a command procedure (the sequence of output redirection specifications is significant):
>
>
>         batch <<!
>         diff file1 file2 2>&1 >outfile | mailx -s "outfile update" mygroup
>         !
>
>     Note that this always sends mail when there has been an attempt to update **outfile** and the body of the message will be empty unless an error occurred.
>
> 3.  The following shows how to capture both standard error and standard output:
>
>
>         batch <<EOF
>         {
>             run-batch-processing |
>                 mailx -s "batch processing output" mygroup
>         } 2>&1 | mailx -E -s "errors during batch processing" mygroup
>         EOF

#### <span id="tag_20_08_18"></span>RATIONALE

> Early proposals described *batch* in a manner totally separated from [*at*](../utilities/at.html), even though the historical model treated it almost as a synonym for [*at*](../utilities/at.html) **-qb**. A number of features were added to list and control batch work separately from those in [*at*](../utilities/at.html). Upon further reflection, it was decided that the benefit of this did not merit the change to the historical interface.
>
> The **-m** option was included on the equivalent [*at*](../utilities/at.html) command because it is historical practice to mail results to the submitter, even if all job-produced output is redirected. As explained in the RATIONALE for [*at*](../utilities/at.html), the **now** keyword submits the job for immediate execution (after scheduling delays), despite some historical systems where [*at*](../utilities/at.html) **now** would have been considered an error.

#### <span id="tag_20_08_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_08_20"></span>SEE ALSO

> [*at*](../utilities/at.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_08_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_08_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The NAME is changed to align with the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_08_23"></span>Issue 7

> The *batch* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-95 is applied, removing the references to fixed locations for the files referenced by the *batch* utility.

#### <span id="tag_20_08_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1368 is applied, changing the EXAMPLES section.

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
