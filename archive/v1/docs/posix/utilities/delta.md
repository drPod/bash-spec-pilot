The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="delta"></span> <span id="tag_20_32"></span>

#### <span id="tag_20_32_01"></span>NAME

> delta — make a delta (change) to an SCCS file (**DEVELOPMENT**)

#### <span id="tag_20_32_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` delta`` `**`[`**`-nps`**`] [`**`-g`` `*`list`***`] [`**`-m`` `*`mrlist`***`] [`**`-r`` `*`SID`***`] [`**`-y`**`[`***`comment`***`]]`**` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_32_03"></span>DESCRIPTION

> The *delta* utility shall be used to permanently introduce into the named SCCS files changes that were made to the files retrieved by [*get*](../utilities/get.html) (called the *g-files*, or generated files).

#### <span id="tag_20_32_04"></span>OPTIONS

> The *delta* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that the **-y** option has an optional option-argument. This optional option-argument shall not be presented as a separate argument.
>
> The following options shall be supported:
>
> **-r ***SID*
>
> Uniquely identify which delta is to be made to the SCCS file. The use of this option shall be necessary only if two or more outstanding [*get*](../utilities/get.html) commands for editing ([*get*](../utilities/get.html) **-e**) on the same SCCS file were done by the same person (login name). The SID value specified with the **-r** option can be either the SID specified on the [*get*](../utilities/get.html) command line or the SID to be made as reported by the [*get*](../utilities/get.html) utility; see [*get*](../utilities/get.html#).
>
> **-s**
>
> Suppress the report to standard output of the activity associated with each *file*. See the STDOUT section.
>
> **-n**
>
> Specify retention of the edited *g-file* (normally removed at completion of delta processing).
>
> **-g ***list*
>
> Specify a *list* (see [*get*](../utilities/get.html#) for the definition of *list*) of deltas that shall be ignored when the file is accessed at the change level (SID) created by this delta.
>
> **-m ***mrlist*
>
> Specify a modification request (MR) number that the application shall supply as the reason for creating the new delta. This shall be used if the SCCS file has the **v** flag set; see [*admin*](../utilities/admin.html#).
>
> If **-m** is not used and `'-'` is not specified as a file argument, and the standard input is a terminal, the prompt described in the STDOUT section shall be written to standard output before the standard input is read; if the standard input is not a terminal, no prompt shall be issued.
>
> MRs in a list shall be separated by \<blank\> characters or escaped \<newline\> characters. An unescaped \<newline\> shall terminate the MR list. The escape character is \<backslash\>.
>
> If the **v** flag has a value, it shall be taken to be the name of a program which validates the correctness of the MR numbers. If a non-zero exit status is returned from the MR number validation program, the *delta* utility shall terminate. (It is assumed that the MR numbers were not all valid.)
>
> **-y\[***comment***\]**
>
> Describe the reason for making the delta. The *comment* shall be an arbitrary group of lines that would meet the definition of a text file. Implementations shall support *comment*s from zero to 512 bytes and may support longer values. A null string (specified as either **-y**, **-y**`""`, or in response to a prompt for a comment) shall be considered a valid *comment*.
>
> If **-y** is not specified and `'-'` is not specified as a file argument, and the standard input is a terminal, the prompt described in the STDOUT section shall be written to standard output before the standard input is read; if the standard input is not a terminal, no prompt shall be issued. An unescaped \<newline\> shall terminate the comment text. The escape character is \<backslash\>.
>
> The **-y** option shall be required if the *file* operand is specified as `'-'`.
>
> **-p**
>
> Write (to standard output) the SCCS file differences before and after the delta is applied in [*diff*](../utilities/diff.html) format; see [*diff*](../utilities/diff.html#).

#### <span id="tag_20_32_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an existing SCCS file or a directory. If *file* is a directory, the *delta* utility shall behave as though each file in the directory were specified as a named file, except that non-SCCS files (last component of the pathname does not begin with **s.**) and unreadable files shall be silently ignored.
>
> If exactly one *file* operand appears, and it is `'-'`, the standard input shall be read; each line of the standard input shall be taken to be the name of an SCCS file to be processed. Non-SCCS files and unreadable files shall be silently ignored.

#### <span id="tag_20_32_06"></span>STDIN

> The standard input shall be a text file used only in the following cases:
>
> - To read an *mrlist* or a *comment* (see the **-m** and **-y** options).
>
> - A *file* operand shall be specified as `'-'`. In this case, the **-y** option needs to be used to specify the comment, and if the SCCS file has the **v** flag set, the **-m** option also needs to be used to specify the MR list.

#### <span id="tag_20_32_07"></span>INPUT FILES

> Input files shall be text files whose data is to be included in the SCCS files. If the first character of any line of an input file is \<SOH\> in the POSIX locale, the results are unspecified. If this file contains more than 99999 lines, the number of lines recorded in the header for this file shall be 99999 for this delta.

#### <span id="tag_20_32_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *delta*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error, and informative messages written to standard output.
>
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.
>
> *TZ*
>
> Determine the timezone in which the time and date are written in the SCCS file. If the *TZ* variable is unset or NULL, an unspecified system default timezone is used.

#### <span id="tag_20_32_09"></span>ASYNCHRONOUS EVENTS

> If SIGINT is caught, temporary files shall be cleaned up and *delta* shall exit with a non-zero exit code. The standard action shall be taken for all other signals; see [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04).

#### <span id="tag_20_32_10"></span>STDOUT

> The standard output shall be used only for the following messages in the POSIX locale:
>
> - Prompts (see the **-m** and **-y** options) in the following formats:
>
>
>       "MRs? "
>
>
>       "comments? "
>
>   The MR prompt, if written, shall always precede the comments prompt.
>
> - A report of each file's activities (unless the **-s** option is specified) in the following format:
>
>
>       "%s\n%d inserted\n%d deleted\n%d unchanged\n", <New SID>,
>           <number of lines inserted>, <number of lines deleted>,
>           <number of lines unchanged>

#### <span id="tag_20_32_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_32_12"></span>OUTPUT FILES

> Any SCCS files updated shall be files of an unspecified format.

#### <span id="tag_20_32_13"></span>EXTENDED DESCRIPTION

> ##### <span id="tag_20_32_13_01"></span>System Date and Time
>
> When a delta is added to an SCCS file, the system date and time shall be recorded for the new delta. If a [*get*](../utilities/get.html) is performed using an SCCS file with a date recorded apparently in the future, the behavior is unspecified.

#### <span id="tag_20_32_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_32_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_32_16"></span>APPLICATION USAGE

> Problems can arise if the system date and time have been modified (for example, put forward and then back again, or unsynchronized clocks across a network) and can also arise when different values of the *TZ* environment variable are used.
>
> Problems of a similar nature can also arise for the operation of the [*get*](../utilities/get.html) utility, which records the date and time in the file body.

#### <span id="tag_20_32_17"></span>EXAMPLES

> None.

#### <span id="tag_20_32_18"></span>RATIONALE

> None.

#### <span id="tag_20_32_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_32_20"></span>SEE ALSO

> [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04), [*admin*](../utilities/admin.html#), [*diff*](../utilities/diff.html#), [*get*](../utilities/get.html#), [*prs*](../utilities/prs.html#), [*rmdel*](../utilities/rmdel.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_32_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_32_22"></span>Issue 5

> The output format description in the STDOUT section is corrected.

#### <span id="tag_20_32_23"></span>Issue 6

> The APPLICATION USAGE section is added.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> The Open Group Base Resolution bwg2001-007 is applied as follows:
>
> - The use of `'-'` as a file argument is clarified.
>
> - The use of STDIN is added.
>
> - The ASYNCHRONOUS EVENTS section is updated to remove the implicit requirement that implementations re-signal themselves when catching a normally fatal signal.
>
> - New text is added to the INPUT FILES section warning that the maximum lines recorded in the file is 99999.
>
> New text is added to the EXTENDED DESCRIPTION and APPLICATION USAGE sections regarding how the system date and time may be taken into account, and the *TZ* environment variable is added to the ENVIRONMENT VARIABLES section as per The Open Group Base Resolution bwg2001-007.

#### <span id="tag_20_32_24"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_32_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to behave as follows:
>
> 1.  Report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> 2.  Disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
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
