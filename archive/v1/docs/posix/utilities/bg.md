The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="bg"></span> <span id="tag_20_10"></span>

#### <span id="tag_20_10_01"></span>NAME

> bg — run jobs in the background

#### <span id="tag_20_10_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`UP`](javascript:open_code('UP'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` bg`` `**`[`***`job_id`*`...`**`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_10_03"></span>DESCRIPTION

> If job control is enabled (see the description of [*set*](../utilities/V3_chap02.html#set) **-m**), the shell is interactive, and the current shell execution environment (see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13)) is not a subshell environment, the *bg* utility shall resume suspended jobs from the current shell execution environment by running them as background jobs, as described in [*2.11 Job Control*](../utilities/V3_chap02.html#tag_19_11); it may also do so if the shell is non-interactive or the current shell execution environment is a subshell environment. If the job specified by *job_id* is already a running background job, the *bg* utility shall have no effect and shall exit successfully.

#### <span id="tag_20_10_04"></span>OPTIONS

> None.

#### <span id="tag_20_10_05"></span>OPERANDS

> The following operand shall be supported:
>
> *job_id*
>
> Specify the job to be resumed as a background job. If no *job_id* operand is given, the most recently suspended job shall be used. The format of *job_id* is described in XBD [*3.182 Job ID*](../basedefs/V1_chap03.html#tag_03_182) .

#### <span id="tag_20_10_06"></span>STDIN

> Not used.

#### <span id="tag_20_10_07"></span>INPUT FILES

> None.

#### <span id="tag_20_10_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *bg*:
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

#### <span id="tag_20_10_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_10_10"></span>STDOUT

> The output of *bg* shall consist of a line in the format:
>
>
>     "[%d] %s\n", <job-number>, <command>
>
> where the fields are as follows:
>
> \<*job-number*\>
>
> A number that can be used to identify the job to the [*wait*](../utilities/wait.html), [*fg*](../utilities/fg.html), and [*kill*](../utilities/kill.html) utilities. Using these utilities, the job can be identified by prefixing the job number with `'%'`.
>
> \<*command*\>
>
> The associated command that was given to the shell.

#### <span id="tag_20_10_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_10_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_10_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_10_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_10_15"></span>CONSEQUENCES OF ERRORS

> If job control is disabled, the *bg* utility shall exit with an error and no job shall be placed in the background.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_10_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> A job is generally suspended by typing the SUSP character (\<control\>-Z on most systems); see XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). At that point, *bg* can put the job into the background. This is most effective when the job is expecting no terminal input and its output has been redirected to non-terminal files. A background job can be forced to stop when it has terminal output by issuing the command:
>
>
>     stty tostop
>
> A background job can be stopped with the command:
>
>
>     kill -s stop job ID
>
> The *bg* utility does not work as expected when it is operating in its own utility execution environment because that environment has no suspended jobs. In the following examples:
>
>
>     ... | xargs bg
>     (bg)
>
> each *bg* operates in a different environment and does not share its parent shell's understanding of jobs. For this reason, *bg* is generally implemented as a shell regular built-in.

#### <span id="tag_20_10_17"></span>EXAMPLES

> None.

#### <span id="tag_20_10_18"></span>RATIONALE

> The extensions to the shell specified in this volume of POSIX.1-2024 have mostly been based on features provided by the KornShell. The job control features provided by *bg*, [*fg*](../utilities/fg.html), and [*jobs*](../utilities/jobs.html) are also based on the KornShell. The standard developers examined the characteristics of the C shell versions of these utilities and found that differences exist. Despite widespread use of the C shell, the KornShell versions were selected for this volume of POSIX.1-2024 to maintain a degree of uniformity with the rest of the KornShell features selected (such as the very popular command line editing features).
>
> The *bg* utility is expected to wrap its output if the output exceeds the number of display columns.
>
> The *bg* and [*fg*](../utilities/fg.html) utilities are not symmetric as regards the list of process IDs known in the current shell execution environment. Whereas [*fg*](../utilities/fg.html) removes a process ID from this list, *bg* has no need to add one to this list when it resumes execution of a suspended job in the background, because this has already been done by the shell when the suspended background job was created (see [*2.11 Job Control*](../utilities/V3_chap02.html#tag_19_11)).

#### <span id="tag_20_10_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_10_20"></span>SEE ALSO

> [*2.9.3.1 Asynchronous AND-OR Lists*](../utilities/V3_chap02.html#tag_19_09_03_02), [*fg*](../utilities/fg.html#), [*kill*](../utilities/kill.html#tag_20_64), [*jobs*](../utilities/jobs.html#), [*wait*](../utilities/wait.html#tag_20_147)
>
> XBD [*3.182 Job ID*](../basedefs/V1_chap03.html#tag_03_182), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11)

#### <span id="tag_20_10_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_10_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The JC margin marker on the SYNOPSIS is removed since support for Job Control is mandatory in this version. This is a FIPS requirement.

#### <span id="tag_20_10_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_10_24"></span>Issue 8

> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1254 is applied, updating the DESCRIPTION to account for the addition of [*2.11 Job Control*](../utilities/V3_chap02.html#tag_19_11) and adding a paragraph to RATIONALE.

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
