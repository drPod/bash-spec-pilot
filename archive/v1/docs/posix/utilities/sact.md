The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="sact"></span> <span id="tag_20_107"></span>

#### <span id="tag_20_107_01"></span>NAME

> sact — print current SCCS file-editing activity (**DEVELOPMENT**)

#### <span id="tag_20_107_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` sact`` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_107_03"></span>DESCRIPTION

> The *sact* utility shall inform the user of any impending deltas to a named SCCS file by writing a list to standard output. This situation occurs when [*get*](../utilities/get.html) **-e** has been executed previously without a subsequent execution of [*delta*](../utilities/delta.html), [*unget*](../utilities/unget.html), or [*sccs*](../utilities/sccs.html) **unedit**.

#### <span id="tag_20_107_04"></span>OPTIONS

> None.

#### <span id="tag_20_107_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an existing SCCS file or a directory. If *file* is a directory, the *sact* utility shall behave as though each file in the directory were specified as a named file, except that non-SCCS files (last component of the pathname does not begin with **s.**) and unreadable files shall be silently ignored.
>
> If exactly one *file* operand appears, and it is `'-'`, the standard input shall be read; each line of the standard input shall be taken to be the name of an SCCS file to be processed. Non-SCCS files and unreadable files shall be silently ignored.

#### <span id="tag_20_107_06"></span>STDIN

> The standard input shall be a text file used only when the *file* operand is specified as `'-'`. Each line of the text file shall be interpreted as an SCCS pathname.

#### <span id="tag_20_107_07"></span>INPUT FILES

> Any SCCS files interrogated are files of an unspecified format.

#### <span id="tag_20_107_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *sact*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_107_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_107_10"></span>STDOUT

> The output for each named file shall consist of a line in the following format:
>
>
>     "%sΔ%sΔ%sΔ%sΔ%s\n", <SID>, <new SID>, <login>, <date>, <time>
>
> \<*SID*\>
>
> Specifies the SID of a delta that currently exists in the SCCS file to which changes are made to make the new delta.
>
> \<*new SID*\>
>
> Specifies the SID for the new delta to be created.
>
> \<*login*\>
>
> Contains the login name of the user who makes the delta (that is, who executed a [*get*](../utilities/get.html) for editing).
>
> \<*date*\>
>
> Contains the date that [*get*](../utilities/get.html) **-e** was executed, in the format used by the [*prs*](../utilities/prs.html) **:D:** data keyword.
>
> \<*time*\>
>
> Contains the time that [*get*](../utilities/get.html) **-e** was executed, in the format used by the [*prs*](../utilities/prs.html) **:T:** data keyword.
>
> If there is more than one named file or if a directory or standard input is named, each pathname shall be written before each of the preceding lines:
>
>
>     "\n%s:\n", <pathname>

#### <span id="tag_20_107_11"></span>STDERR

> The standard error shall be used only for optional informative messages concerning SCCS files with no impending deltas, and for diagnostic messages.

#### <span id="tag_20_107_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_107_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_107_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_107_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_107_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_107_17"></span>EXAMPLES

> None.

#### <span id="tag_20_107_18"></span>RATIONALE

> None.

#### <span id="tag_20_107_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_107_20"></span>SEE ALSO

> [*delta*](../utilities/delta.html#), [*get*](../utilities/get.html#), [*sccs*](../utilities/sccs.html#), [*unget*](../utilities/unget.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_107_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_107_22"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
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
