The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="touch"></span> <span id="tag_20_124"></span>

#### <span id="tag_20_124_01"></span>NAME

> touch — change file access and modification times

#### <span id="tag_20_124_02"></span>SYNOPSIS

> `touch`` `**`[`**`-acm`**`] [`**`-r`` `*`ref_file`*`|-t`` `*`time`*`|-d`` `*`date_time`***`]`**` `*`file`*`...`

#### <span id="tag_20_124_03"></span>DESCRIPTION

> The *touch* utility shall change the last data modification timestamps, the last data access timestamps, or both.
>
> The time used can be specified by the **-t** *time* option-argument, the corresponding *time* fields of the file referenced by the **-r** *ref_file* option-argument, or the **-d** *date_time* option-argument, as specified in the following sections. If none of these are specified, *touch* shall use the current time.
>
> For each *file* operand, *touch* shall perform actions equivalent to the following functions defined in the System Interfaces volume of POSIX.1-2024:
>
> 1.  If *file* does not exist:
>
>     1.  The [*creat*()](../functions/creat.html) function is called with the following arguments:
>
>         - The *file* operand is used as the *path* argument.
>
>         - The value of the bitwise-inclusive OR of S_IRUSR, S_IWUSR, S_IRGRP, S_IWGRP, S_IROTH, and S_IWOTH is used as the *mode* argument.
>
>     2.  The [*futimens*()](../functions/futimens.html) function is called with the following arguments:
>
>         - The file descriptor opened in step 1a.
>
>         - The access time and the modification time, set as described in the OPTIONS section, are used as the first and second elements of the *times* array argument, respectively.
>
> 2.  If *file* exists, the [*utimensat*()](../functions/utimensat.html) function is called with the following arguments:
>
>     1.  The AT_FDCWD special value is used as the *fd* argument.
>
>     2.  The *file* operand is used as the *path* argument.
>
>     3.  The access time and the modification time, set as described in the OPTIONS section, are used as the first and second elements of the *times* array argument, respectively.
>
>     4.  The *flag* argument is set to zero.

#### <span id="tag_20_124_04"></span>OPTIONS

> The *touch* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a**
>
> Change the access time of *file*. Do not change the modification time unless **-m** is also specified.
>
> **-c**
>
> Do not create a specified *file* if it does not exist. Do not write any diagnostic messages concerning this condition.
>
> **-d ***date_time*
>
> Use the specified *date_time* instead of the current time. The option-argument shall be a string of the form:
>
>
>     YYYY-MM-DDThh:mm:SS[.frac][tz]
>
> or:
>
>
>     YYYY-MM-DDThh:mm:SS[,frac][tz]
>
> where:
>
> - *YYYY* are at least four decimal digits giving the year.
>
> - *MM*, *DD*, *hh*, *mm*, and *SS* are as with **-t** *time*.
>
> - `T` is the time designator, and can be replaced by a single \<space\>.
>
> - `[.`*frac*`]` and `[,`*frac*`]` are either empty, or a \<period\> (`'.'`) or a \<comma\> (`','`) respectively, followed by one or more decimal digits, specifying a fractional second.
>
> - `[`*tz*`]` is either empty, signifying local time, or the letter `'Z'`, signifying UTC. If `[`*tz*`]` is empty, the resulting time shall be affected by the value of the *TZ* environment variable.
>
> If the resulting time precedes the Epoch, the behavior is implementation-defined. If the time cannot be represented as the file's timestamp, *touch* shall exit immediately with an error status.
>
> **-m**
>
> Change the modification time of *file*. Do not change the access time unless **-a** is also specified.
>
> **-r ***ref_file*
>
> Use the corresponding time of the file named by the pathname *ref_file* instead of the current time.
>
> **-t ***time*
>
> Use the specified *time* instead of the current time. The option-argument shall be a decimal number of the form:
>
>
>     [[CC]YY]MMDDhhmm[.SS]
>
> where each two digits represents the following:
>
> *MM*
>
> The month of the year \[01,12\].
>
> *DD*
>
> The day of the month \[01,31\].
>
> *hh*
>
> The hour of the day \[00,23\].
>
> *mm*
>
> The minute of the hour \[00,59\].
>
> *CC*
>
> The first two digits of the year (the century).
>
> *YY*
>
> The second two digits of the year.
>
> *SS*
>
> The second of the minute \[00,60\].
>
> Both *CC* and *YY* shall be optional. If neither is given, the current year shall be assumed. If *YY* is specified, but *CC* is not, *CC* shall be derived as follows:
>
> | **If *YY* is:** | ***CC* becomes:** |
> |:---------------:|:------------------|
> |    \[69,99\]    | 19                |
> |    \[00,68\]    | 20                |
>
> **Note:**  
> It is expected that in a future version of this standard the default century inferred from a 2-digit year will change. (This would apply to all commands accepting a 2-digit year as input.)
>
> The resulting time shall be affected by the value of the *TZ* environment variable. If the resulting time value precedes the Epoch, the behavior is implementation-defined. If the time is out of range for the file's timestamp, *touch* shall exit immediately with an error status. The range of valid times past the Epoch is implementation-defined, but it shall extend to at least the time 0 hours, 0 minutes, 0 seconds, January 1, 2038, Coordinated Universal Time. Some implementations may not be able to represent dates beyond January 18, 2038, because they use **signed int** as a time holder.
>
> The range for *SS* is \[00,60\] rather than \[00,59\] because of leap seconds. If *SS* is 60, and the resulting time, as affected by the *TZ* environment variable, does not refer to a leap second, the resulting time shall be one second after a time where *SS* is 59. If *SS* is not given a value, it is assumed to be zero.
>
> If neither the **-a** nor **-m** options were specified, *touch* shall behave as if both the **-a** and **-m** options were specified.

#### <span id="tag_20_124_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file*
>
> A pathname of a file whose times shall be modified.

#### <span id="tag_20_124_06"></span>STDIN

> Not used.

#### <span id="tag_20_124_07"></span>INPUT FILES

> None.

#### <span id="tag_20_124_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *touch*:
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
> *TZ*
>
> Determine the timezone to be used for interpreting the *time* option-argument. If *TZ* is unset or null, an unspecified default timezone shall be used.

#### <span id="tag_20_124_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_124_10"></span>STDOUT

> Not used.

#### <span id="tag_20_124_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_124_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_124_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_124_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The utility executed successfully and all requested changes were made.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_124_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_124_16"></span>APPLICATION USAGE

> The interpretation of time is taken to be *seconds since the Epoch* (see XBD [*4.19 Seconds Since the Epoch*](../basedefs/V1_chap04.html#tag_04_19)). It should be noted that implementations conforming to the System Interfaces volume of POSIX.1-2024 do not take leap seconds into account when computing seconds since the Epoch. When *SS*=60 is used, the resulting time always refers to 1 plus *seconds since the Epoch* for a time when *SS*=59.
>
> Although the **-t** *time* option-argument specifies values in 1969, the access time and modification time fields are defined in terms of seconds since the Epoch (00:00:00 on 1 January 1970 UTC). Therefore, depending on the value of *TZ* when *touch* is run, there is never more than a few valid hours in 1969 and there need not be any valid times in 1969.
>
> If the *T* time designator is replaced by a \<space\> for the **-d** *date_time* option-argument, the \<space\> must be quoted to prevent the shell from splitting the argument.

#### <span id="tag_20_124_17"></span>EXAMPLES

> Create or update a file called **dwc**; the resulting file has both the last data modification and last data access timestamps set to November 12, 2007 at 10:15:30 local time:
>
>
>     touch -d 2007-11-12T10:15:30 dwc
>
> Create or update a file called **nick**; the resulting file has both the last data modification and last data access timestamps set to November 12, 2007 at 10:15:30 UTC:
>
>
>     touch -d 2007-11-12T10:15:30Z nick
>
> Create or update a file called **gwc**; the resulting file has both the last data modification and last data access timestamps set to November 12, 2007 at 10:15:30 local time with a fractional second timestamp of .002 seconds:
>
>
>     touch -d 2007-11-12T10:15:30,002 gwc
>
> Create or update a file called **ajosey**; the resulting file has both the last data modification and last data access timestamps set to November 12, 2007 at 10:15:30 UTC with a fractional second timestamp of .002 seconds:
>
>
>     touch -d "2007-11-12 10:15:30.002Z" ajosey
>
> Create or update a file called **cathy**; the resulting file has both the last data modification and last data access timestamps set to November 12, 2007 at 10:15:00 local time:
>
>
>     touch -t 200711121015 cathy
>
> Create or update a file called **drepper**; the resulting file has both the last data modification and last data access timestamps set to November 12, 2007 at 10:15:30 local time:
>
>
>     touch -t 200711121015.30 drepper
>
> Create or update a file called **ebb9**; the resulting file has both the last data modification and last data access timestamps set to November 12, 2007 at 10:15:30 local time:
>
>
>     touch -t 0711121015.30 ebb9
>
> Create or update a file called **eggert**; the resulting file has the last data access timestamp set to the corresponding time of the file named **mark** instead of the current time. If the file exists, the last data modification time is not changed:
>
>
>     touch -a -r mark eggert

#### <span id="tag_20_124_18"></span>RATIONALE

> The functionality of *touch* is described almost entirely through references to functions in the System Interfaces volume of POSIX.1-2024. In this way, there is no duplication of effort required for describing such side-effects as the relationship of user IDs to the user database, permissions, and so on.
>
> There are some significant differences between the *touch* utility in this volume of POSIX.1-2024 and those in System V and BSD systems. They are upwards-compatible for historical applications from both implementations:
>
> 1.  In System V, an ambiguity exists when a pathname that is a decimal number leads the operands; it is treated as a time value. In BSD, no *time* value is allowed; files may only be *touch*ed to the current time. The **-t** *time* construct solves these problems for future conforming applications (note that the **-t** option is not historical practice).
> 2.  The inclusion of the century digits, *CC*, is also new. Note that a ten-digit *time* value is treated as if *YY*, and not *CC*, were specified. The caveat about the range of dates following the Epoch was included as recognition that some implementations are not able to represent dates beyond 18 January 2038 because they use **signed int** as a time holder.
>
> The **-r** option was added because several comments requested this capability. This option was named **-f** in an early proposal, but was changed because the **-f** option is used in the BSD version of *touch* with a different meaning.
>
> At least one historical implementation of *touch* incremented the exit code if **-c** was specified and the file did not exist. This volume of POSIX.1-2024 requires exit status zero if no errors occur.
>
> In previous version of the standard, if at least two operands are specified, and the first operand is an eight or ten-digit decimal integer, the first operand was assumed to be a *date_time* operand. This usage was removed in this version of the standard since it had been marked obsolescent previously.
>
> The **-d** *date_time* format is an ISO 8601:2019 standard complete representation of date and time extended format with an optional decimal point or \<comma\> followed by a string of digits following the seconds portion to specify fractions of a second. It is not necessary to recognize `"[+/-]hh:mm"` and `"[+/-]hh"` to specify timezones other than local time and UTC. The *T* time designator in the ISO 8601:2019 standard extended format may be replaced by \<space\>.

#### <span id="tag_20_124_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_124_20"></span>SEE ALSO

> [*date*](../utilities/date.html#)
>
> XBD [*4.19 Seconds Since the Epoch*](../basedefs/V1_chap04.html#tag_04_19), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html)
>
> XSH [*creat*()](../functions/creat.html#), [*futimens*()](../functions/futimens.html#), [*time*()](../functions/time.html#tag_17_625)

#### <span id="tag_20_124_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_124_22"></span>Issue 6

> The obsolescent *date_time* operand is removed.
>
> The Open Group Corrigendum U027/1 is applied. This extends the range of valid time past the Epoch to at least the time 0 hours, 0 minutes, 0 seconds, January 1, 2038, Coordinated Universal Time. This is a new requirement on POSIX implementations.
>
> The range for seconds is changed from \[00,61\] to \[00,60\] to align with the ISO/IEC 9899:1999 standard, and to allow for positive leap seconds.

#### <span id="tag_20_124_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#118 is applied.
>
> Austin Group Interpretation 1003.1-2001 \#193 is applied, adding support for subsecond timestamps.
>
> SD5-XCU-ERN-45 is applied, adding a new paragraph to the RATIONALE.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> SD5-XCU-ERN-110 is applied, updating the OPTIONS section.
>
> Changes are made related to support for finegrained timestamps.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0195 \[474\] is applied.

#### <span id="tag_20_124_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*

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
