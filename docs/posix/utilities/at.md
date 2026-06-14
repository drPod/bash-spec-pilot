The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="at"></span> <span id="tag_20_05"></span>

#### <span id="tag_20_05_01"></span>NAME

> at — execute commands at a later time

#### <span id="tag_20_05_02"></span>SYNOPSIS

> `at`` `**`[`**`-m`**`] [`**`-f`` `*`file`***`] [`**`-q`` `*`queuename`***`]`**` ``-t`` `*`time_arg`*\
> \
> `at`` `**`[`**`-m`**`] [`**`-f`` `*`file`***`] [`**`-q`` `*`queuename`***`]`**` `*`timespec`*`...`\
> \
> `at -r`` `*`at_job_id`*`...`\
> \
> `at -l -q`` `*`queuename`*\
> \
> `at -l`` `**`[`***`at_job_id`*`...`**`]`**\

#### <span id="tag_20_05_03"></span>DESCRIPTION

> The *at* utility shall read commands from standard input and group them together as an *at-job*, to be executed at a later time.
>
> The at-job shall be executed in a separate invocation of the shell, running in a separate process group with no controlling terminal, except that the environment variables, current working directory, file creation mask, and other implementation-defined execution-time attributes in effect when the *at* utility is executed shall be retained and used when the at-job is executed.
>
> When the at-job is submitted, the *at_job_id* and scheduled time shall be written to standard error. The *at_job_id* is an identifier that shall be a string consisting solely of alphanumeric characters and the \<period\> character. The *at_job_id* shall be assigned by the system when the job is scheduled such that it uniquely identifies a particular job.
>
> User notification and the processing of the job's standard output and standard error are described under the **-m** option.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Users shall be permitted to use *at* if their name appears in the file **at.allow** which is located in an implementation-defined directory. If that file does not exist, the file **at.deny**, which is located in an implementation-defined directory, shall be checked to determine whether the user shall be denied access to *at*. If neither file exists, only a process with appropriate privileges shall be allowed to submit a job. If only **at.deny** exists and is empty, global usage shall be permitted. The **at.allow** and **at.deny** files shall consist of one user name per line. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_05_04"></span>OPTIONS

> The *at* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-f ***file*
>
> Specify the pathname of a file to be used as the source of the at-job, instead of standard input.
>
> **-l**
>
> (The letter ell.) Report all jobs scheduled for the invoking user if no *at_job_id* operands are specified. If *at_job_id*s are specified, report only information for these jobs. The output shall be written to standard output.
>
> **-m**
>
> Send mail to the invoking user after the at-job has run, announcing its completion. Standard output and standard error produced by the at-job shall be mailed to the user as well, unless redirected elsewhere. Mail shall be sent even if the job produces no output.
>
> If **-m** is not used, the job's standard output and standard error shall be provided to the user by means of mail, unless they are redirected elsewhere; if there is no such output to provide, the implementation need not notify the user of the job's completion.
>
> **-q ***queuename*
>
> \
> Specify in which queue to schedule a job for submission. When used with the **-l** option, limit the search to that particular queue. By default, at-jobs shall be scheduled in queue *a*. In contrast, queue *b* shall be reserved for batch jobs; see [*batch*](../utilities/batch.html). The meanings of all other *queuename*s are implementation-defined. If **-q** *b* is specified along with either of the **-t** *time_arg* or *timespec* arguments, the results are unspecified.
>
> **-r**
>
> Remove the jobs with the specified *at_job_id* operands that were previously scheduled by the *at* utility.
>
> **-t ***time_arg*
>
> Submit the job to be run at the time specified by the *time* option-argument, which the application shall ensure has the format as specified by the [*touch*](../utilities/touch.html) **-t** *time* utility.

#### <span id="tag_20_05_05"></span>OPERANDS

> The following operands shall be supported:
>
> *at_job_id*
>
> The name reported by a previous invocation of the *at* utility at the time the job was scheduled.
>
> *timespec*
>
> Submit the job to be run at the date and time specified. All of the *timespec* operands are interpreted as if they were separated by \<space\> characters and concatenated, and shall be parsed as described in the grammar at the end of this section. The date and time shall be interpreted as being in the timezone of the user (as determined by the *TZ* variable), unless a timezone name appears as part of *time*, below.
>
> In the POSIX locale, the following describes the three parts of the time specification string. All of the values from the *LC_TIME* categories in the POSIX locale shall be recognized in a case-insensitive manner.
>
> *time*
>
> The time can be specified as one, two, or four digits. One-digit and two-digit numbers shall be taken to be hours; four-digit numbers to be hours and minutes. The time can alternatively be specified as two numbers separated by a \<colon\>, meaning *hour*:*minute*. If the *LC_TIME* category of the locale supports 12-hour time format (see XBD [*7.3.5 LC_TIME*](../basedefs/V1_chap07.html#tag_07_03_05)), an AM/PM indication in the form of one of the values from the **am_pm** keywords in the *LC_TIME* locale category can follow the time; otherwise, a 24-hour clock time shall be understood. A timezone name can also follow to further qualify the time. The acceptable timezone names are implementation-defined, except that they shall be case-insensitive and the string **utc** is supported to indicate the time is in Coordinated Universal Time. In the POSIX locale, the *time* field can also be one of the following tokens:
>
> **midnight**
>
> Indicates the time 12:00 am (00:00).
>
> **noon**
>
> Indicates the time 12:00 pm.
>
> **now**
>
> Indicates the current day and time. Invoking *at* \<**now**\> shall submit an at-job for potentially immediate execution (that is, subject only to unspecified scheduling delays).
>
> *date*
>
> An optional *date* can be specified as either a month name (one of the values from the **mon** or **abmon** keywords in the *LC_TIME* locale category) followed by a day number (and possibly year number preceded by a comma), or a day of the week (one of the values from the **day** or **abday** keywords in the *LC_TIME* locale category). In the POSIX locale, two special days shall be recognized:
>
> **today**
>
> Indicates the current day.
>
> **tomorrow**
>
> Indicates the day following the current day.
>
> If no *date* is given, **today** shall be assumed if the given time is greater than the current time, and **tomorrow** shall be assumed if it is less. If the given month is less than the current month (and no year is given), next year shall be assumed.
>
> *increment*
>
> The optional *increment* shall be a number preceded by a \<plus-sign\> (`'+'`) and suffixed by one of the following: **minutes**, **hours**, **days**, **weeks**, **months**, or **years**. (The singular forms shall also be accepted.) The keyword **next** shall be equivalent to an increment number of +1. For example, the following are equivalent commands:
>
>
>     at 2pm + 1 week
>     at 2pm next week
>
> The following grammar describes the precise format of *timespec* in the POSIX locale. The general conventions for this style of grammar are described in [*1.3 Grammar Conventions*](../utilities/V3_chap01.html#tag_18_03). This formal syntax shall take precedence over the preceding text syntax description. The longest possible token or delimiter shall be recognized at a given point. When used in a *timespec*, white space shall also delimit tokens.
>
>
>     %token hr24clock_hr_min
>     %token hr24clock_hour
>     /*
>       An hr24clock_hr_min is a one, two, or four-digit number. A one-digit
>       or two-digit number constitutes an hr24clock_hour. An hr24clock_hour
>       may be any of the single digits [0,9], or may be double digits, ranging
>       from [00,23]. If an hr24clock_hr_min is a four-digit number, the
>       first two digits shall be a valid hr24clock_hour, while the last two
>       represent the number of minutes, from [00,59].
>     */
>
>
>     %token wallclock_hr_min
>     %token wallclock_hour
>     /*
>       A wallclock_hr_min is a one, two-digit, or four-digit number.
>       A one-digit or two-digit number constitutes a wallclock_hour.
>       A wallclock_hour may be any of the single digits [1,9], or may
>       be double digits, ranging from [01,12]. If a wallclock_hr_min
>       is a four-digit number, the first two digits shall be a valid
>       wallclock_hour, while the last two represent the number of
>       minutes, from [00,59].
>     */
>
>
>     %token minute
>     /*
>       A minute is a one or two-digit number whose value can be [0,9]
>       or [00,59].
>     */
>
>
>     %token day_number
>     /*
>       A day_number is a number in the range appropriate for the particular
>       month and year specified by month_name and year_number, respectively.
>       If no year_number is given, the current year is assumed if the given
>       date and time are later this year. If no year_number is given and
>       the date and time have already occurred this year and the month is
>       not the current month, next year is the assumed year.
>     */
>
>
>     %token year_number
>     /*
>       A year_number is a four-digit number representing the year A.D., in
>       which the at_job is to be run.
>     */
>
>
>     %token inc_number
>     /*
>       The inc_number is the number of times the succeeding increment
>       period is to be added to the specified date and time.
>     */
>
>
>     %token timezone_name
>     /*
>       The name of an optional timezone suffix to the time field, in an
>       implementation-defined format.
>     */
>
>
>     %token month_name
>     /*
>       One of the values from the mon or abmon keywords in the LC_TIME
>       locale category.
>     */
>
>
>     %token day_of_week
>     /*
>       One of the values from the day or abday keywords in the LC_TIME
>       locale category.
>     */
>
>
>     %token am_pm
>     /*
>       One of the values from the am_pm keyword in the LC_TIME locale
>       category.
>     */
>
>
>     %start timespec
>     %%
>     timespec    : time
>                 | time date
>                 | time increment
>                 | time date increment
>                 | nowspec
>                 ;
>
>
>     nowspec     : "now"
>                 | "now" increment
>                 ;
>
>
>     time        : hr24clock_hr_min
>                 | hr24clock_hr_min timezone_name
>                 | hr24clock_hour ":" minute
>                 | hr24clock_hour ":" minute timezone_name
>                 | wallclock_hr_min am_pm
>                 | wallclock_hr_min am_pm timezone_name
>                 | wallclock_hour ":" minute am_pm
>                 | wallclock_hour ":" minute am_pm timezone_name
>                 | "noon"
>                 | "midnight"
>                 ;
>
>
>     date        : month_name day_number
>                 | month_name day_number "," year_number
>                 | day_of_week
>                 | "today"
>                 | "tomorrow"
>                 ;
>
>
>     increment   : "+" inc_number inc_period
>                 | "next" inc_period
>                 ;
>
>
>     inc_period  : "minute" | "minutes"
>                 | "hour" | "hours"
>                 | "day" | "days"
>                 | "week" | "weeks"
>                 | "month" | "months"
>                 | "year" | "years"
>                 ;

#### <span id="tag_20_05_06"></span>STDIN

> The standard input shall be a text file consisting of commands acceptable to the shell command language described in [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19). The standard input shall only be used if no **-f** *file* option is specified.

#### <span id="tag_20_05_07"></span>INPUT FILES

> See the STDIN section.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The text files **at.allow** and **at.deny**, which are located in an implementation-defined directory, shall contain zero or more user names, one per line, of users who are, respectively, authorized or denied access to the *at* and [*batch*](../utilities/batch.html) utilities. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_05_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *at*:
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
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *LC_TIME*
>
> Determine the format and contents for date and time strings written and accepted by *at*.
>
> *SHELL*
>
> Determine a name of a command interpreter to be used to invoke the at-job. If the variable is unset or null, [*sh*](../utilities/sh.html) shall be used. If it is set to a value other than a name for [*sh*](../utilities/sh.html), the implementation shall do one of the following: use that shell; use [*sh*](../utilities/sh.html); use the login shell from the user database; or any of the preceding accompanied by a warning diagnostic about which was chosen.
>
> *TZ*
>
> Determine the timezone. The job shall be submitted for execution at the time specified by *timespec* or **-t** *time* relative to the timezone specified by the *TZ* variable. If *timespec* specifies a timezone, it shall override *TZ .* If *timespec* does not specify a timezone and *TZ* is unset or null, an unspecified default timezone shall be used.

#### <span id="tag_20_05_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_05_10"></span>STDOUT

> When standard input is a terminal, prompts of unspecified format for each line of the user input described in the STDIN section may be written to standard output.
>
> In the POSIX locale, the following shall be written to the standard output for each job when jobs are listed in response to the **-l** option:
>
>
>     "%s\t%s\n", at_job_id, <date>
>
> where *date* shall be equivalent in format to the output of:
>
>
>     date +"%a %b %e %T %Y"
>
> The date and time written shall be adjusted so that they appear in the timezone of the user (as determined by the *TZ* variable).

#### <span id="tag_20_05_11"></span>STDERR

> In the POSIX locale, the following shall be written to standard error when a job has been successfully submitted:
>
>
>     "job %s at %s\n", at_job_id, <date>
>
> where *date* has the same format as that described in the STDOUT section. Neither this, nor warning messages concerning the selection of the command interpreter, shall be considered a diagnostic that changes the exit status.
>
> Diagnostic messages, if any, shall be written to standard error.

#### <span id="tag_20_05_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_05_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_05_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Neither the **-l** option nor the **-r** option was specified and a job was successfully submitted; or, the **-l** option was specified with no *at_job_id* operands and there were no jobs to be listed; or, the **-l** option was specified and all job listings were successfully output; or, the **-r** option was specified and all of the specified jobs were successfully removed.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_05_15"></span>CONSEQUENCES OF ERRORS

> If neither the **-l** option nor the **-r** option was specified, the job shall not be scheduled. Otherwise, the default actions specified in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04) apply.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_05_16"></span>APPLICATION USAGE

> The format of the *at* command line shown here is guaranteed only for the POSIX locale. Other cultures may be supported with substantially different interfaces, although implementations are encouraged to provide comparable levels of functionality.
>
> Since the commands run in a separate shell invocation, running in a separate process group with no controlling terminal, open file descriptors, traps, and priority inherited from the invoking environment are lost.
>
> Some implementations do not allow substitution of different shells using *SHELL .* System V systems, for example, have used the login shell value for the user in **/etc/passwd**. To select reliably another command interpreter, the user must include it as part of the script, such as:
>
>
>     $ at 1800
>     myshell myscript
>     EOT
>     job ... at ...
>     $

#### <span id="tag_20_05_17"></span>EXAMPLES

> 1.  This sequence can be used at a terminal:
>
>
>         at -m 0730 tomorrow
>         sort < file >outfile
>         EOT
>
> 2.  This sequence, which demonstrates redirecting standard error to a pipe, is useful in a command procedure (the sequence of output redirection specifications is significant):
>
>
>         at now + 1 hour <<!
>         diff file1 file2 2>&1 >outfile | mailx -s "outfile update" mygroup
>         !
>
>     Note that this always sends mail when there has been an attempt to update **outfile** and the body of the message will be empty unless an error occurred.
>
> 3.  The following shows how to capture both standard error and standard output:
>
>
>         at now + 1 hour <<EOF
>         {
>             run-batch-processing |
>                 mailx -s "batch processing output" mygroup
>         } 2>&1 | mailx -E -s "errors during batch processing" mygroup
>         EOF
>
> 4.  To have a job reschedule itself, *at* can be invoked from within the at-job. For example, this daily processing script named **my.daily** runs every day (although [*crontab*](../utilities/crontab.html) is a more appropriate vehicle for such work):
>
>
>         # my.daily runs every day
>         daily processing
>         at now tomorrow < my.daily
>
> 5.  The spacing of the three portions of the POSIX locale *timespec* is quite flexible as long as there are no ambiguities. Examples of various times and operand presentation include:
>
>
>         at 0815am Jan 24
>         at 8 :15amjan24
>         at now "+ 1day"
>         at 5 pm FRIday
>         at '17
>             utc+
>             30minutes'

#### <span id="tag_20_05_18"></span>RATIONALE

> The *at* utility reads from standard input the commands to be executed at a later time. It may be useful to redirect standard output and standard error within the specified commands.
>
> The **-t** *time* option was added as a new capability to support an internationalized way of specifying a time for execution of the submitted job.
>
> Early proposals added a "jobname" concept as a way of giving submitted jobs names that are meaningful to the user submitting them. The historical, system-specified *at_job_id* gives no indication of what the job is. Upon further reflection, it was decided that the benefit of this was not worth the change in historical interface.
>
> The **-q** option historically has been an undocumented option, used mainly by the [*batch*](../utilities/batch.html) utility.
>
> The System V **-m** option was added to provide a method for informing users that an at-job had completed. Otherwise, users are only informed when output to standard error or standard output are not redirected.
>
> The behavior of *at* \<**now**\> was changed in an early proposal from being unspecified to submitting a job for potentially immediate execution. Historical BSD *at* implementations support this. Historical System V implementations give an error in that case, but a change to the System V versions should have no backwards-compatibility ramifications.
>
> On BSD-based systems, a **-u** *user* option has allowed those with appropriate privileges to access the work of other users. Since this is primarily a system administration feature and is not universally implemented, it has been omitted. Similarly, a specification for the output format for a user with appropriate privileges viewing the queues of other users has been omitted.
>
> The **-f** *file* option from System V is used instead of the BSD method of using the last operand as the pathname. The BSD method is ambiguous—does:
>
>
>     at 1200 friday
>
> mean the same thing if there is a file named **friday** in the current directory?
>
> The *at_job_id* is composed of a limited character set in historical practice, and it is mandated here to invalidate systems that might try using characters that require shell quoting or that could not be easily parsed by shell scripts.
>
> The *at* utility varies between System V and BSD systems in the way timezones are used. On System V systems, the *TZ* variable affects the at-job submission times and the times displayed for the user. On BSD systems, *TZ* is not taken into account. The BSD behavior is easily achieved with the current specification. If the user wishes to have the timezone default to that of the system, they merely need to issue the *at* command immediately following an unsetting or null assignment to *TZ .* For example:
>
>
>     TZ= at noon ...
>
> gives the desired BSD result.
>
> While the [*yacc*](../utilities/yacc.html)-like grammar specified in the OPERANDS section is lexically unambiguous with respect to the digit strings, a lexical analyzer would probably be written to look for and return digit strings in those cases. The parser could then check whether the digit string returned is a valid *day_number*, *year_number*, and so on, based on the context.

#### <span id="tag_20_05_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_05_20"></span>SEE ALSO

> [*batch*](../utilities/batch.html#), [*crontab*](../utilities/crontab.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_05_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_05_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - If **-m** is not used, the job's standard output and standard error are provided to the user by mail.
>
> The effects of using the **-q** and **-t** options as defined in the IEEE P1003.2b draft standard are specified.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_05_23"></span>Issue 7

> The *at* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-95 is applied, removing the references to fixed locations for the files referenced by the *at* utility.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_05_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1307 is applied, changing the *timespec* operand in relation to locales that do not support the 12-hour clock format.
>
> Austin Group Defect 1330 is applied, removing obsolescent interfaces.
>
> Austin Group Defect 1368 is applied, changing the EXAMPLES section.
>
> Austin Group Defect 1377 is applied, correcting a typographic error in the description of the **-q** option.
>
> Austin Group Defect 1495 is applied, changing the EXIT STATUS and CONSEQUENCES OF ERRORS sections.

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
