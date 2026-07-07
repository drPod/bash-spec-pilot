The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="man"></span> <span id="tag_20_77"></span>

#### <span id="tag_20_77_01"></span>NAME

> man — display system documentation

#### <span id="tag_20_77_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`UP`](javascript:open_code('UP'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` man`` `**`[`**`-k`**`]`**` `*`name`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_77_03"></span>DESCRIPTION

> The *man* utility shall write information about each of the *name* operands. If *name* is the name of a standard utility, *man* at a minimum shall write a message describing the syntax used by the standard utility, its options, operands, environment variables affecting its execution, and its list of exit status codes. If more information is available, the *man* utility shall provide it in an implementation-defined manner.
>
> An implementation may provide information for values of *name* other than the standard utilities. Standard utilities that are listed as optional and that are not supported by the implementation either shall cause a brief message indicating that fact to be displayed or shall cause a full display of information as described previously.

#### <span id="tag_20_77_04"></span>OPTIONS

> The *man* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-k**
>
> Interpret *name* operands as keywords to be used in searching a utilities summary database that contains a brief purpose entry for each standard utility and write lines from the summary database that match any of the keywords. The keyword search shall produce results that are the equivalent of the output of the following command:
>
>
>     grep -Ei '
>     name
>     name
>     ...
>     ' summary-database
>
> This assumes that the *summary-database* is a text file with a single entry per line; this organization is not required and the example using [*grep*](../utilities/grep.html) **-Ei** is merely illustrative of the type of search intended. The purpose entry to be included in the database shall consist of a terse description of the purpose of the utility.

#### <span id="tag_20_77_05"></span>OPERANDS

> The following operand shall be supported:
>
> *name*
>
> A keyword or the name of a standard utility. When **-k** is not specified and *name* does not represent one of the standard utilities, the results are unspecified.

#### <span id="tag_20_77_06"></span>STDIN

> Not used.

#### <span id="tag_20_77_07"></span>INPUT FILES

> None.

#### <span id="tag_20_77_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *man*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and in the summary database). The value of *LC_CTYPE* need not affect the format of the information written about the *name* operands.
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
> *PAGER*
>
> Determine an output filtering command for writing the output to a terminal. Any string acceptable as a *command_string* operand to the [*sh*](../utilities/sh.html) **-c** command shall be valid. When standard output is a terminal device, the reference page output shall be piped through the command. If the *PAGER* variable is null or not set, the command shall be either [*more*](../utilities/more.html) or another paginator utility documented in the system documentation.

#### <span id="tag_20_77_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_77_10"></span>STDOUT

> The *man* utility shall write text describing the syntax of the utility *name*, its options and its operands, or, when **-k** is specified, lines from the summary database. The format of this text is implementation-defined.

#### <span id="tag_20_77_11"></span>STDERR

> The standard error shall be used for diagnostic messages, and may also be used for informational messages of unspecified format.

#### <span id="tag_20_77_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_77_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_77_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_77_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_77_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_77_17"></span>EXAMPLES

> None.

#### <span id="tag_20_77_18"></span>RATIONALE

> It is recognized that the *man* utility is only of minimal usefulness as specified. The opinion of the standard developers was strongly divided as to how much or how little information *man* should be required to provide. They considered, however, that the provision of some portable way of accessing documentation would aid user portability. The arguments against a fuller specification were:
>
> - Large quantities of documentation should not be required on a system that does not have excess disk space.
>
> - The current manual system does not present information in a manner that greatly aids user portability.
>
> - A "better help system" is currently an area in which vendors feel that they can add value to their POSIX implementations.
>
> The **-f** option was considered, but due to implementation differences, it was not included in this volume of POSIX.1-2024.
>
> The description was changed to be more specific about what has to be displayed for a utility. The standard developers considered it insufficient to allow a display of only the synopsis without giving a short description of what each option and operand does.
>
> The "purpose" entry to be included in the database can be similar to the section title (less the numeric prefix) from this volume of POSIX.1-2024 for each utility. These titles are similar to those used in historical systems for this purpose.
>
> See [*mailx*](../utilities/mailx.html) for rationale concerning the default paginator.
>
> The caveat in the *LC_CTYPE* description was added because it is not a requirement that an implementation provide reference pages for all of its supported locales on each system; changing *LC_CTYPE* does not necessarily translate the reference page into another language. This is equivalent to the current state of *LC_MESSAGES* in POSIX.1-2024—locale-specific messages are not yet a requirement.
>
> The historical *MANPATH* variable is not included in POSIX because no attempt is made to specify naming conventions for reference page files, nor even to mandate that they are files at all. On some implementations they could be a true database, a hypertext file, or even fixed strings within the *man* executable. The standard developers considered the portability of reference pages to be outside their scope of work. However, users should be aware that *MANPATH* is implemented on a number of historical systems and that it can be used to tailor the search pattern for reference pages from the various categories (utilities, functions, file formats, and so on) when the system administrator reveals the location and conventions for reference pages on the system.
>
> The keyword search can rely on at least the text of the section titles from these utility descriptions, and the implementation may add more keywords. The term "section titles" refers to the strings such as:
>
>
>     man — Display system documentation
>     ps — Report process status

#### <span id="tag_20_77_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_77_20"></span>SEE ALSO

> [*more*](../utilities/more.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_77_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_77_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_77_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#108 is applied, clarifying that informational messages may appear on standard error.

#### <span id="tag_20_77_24"></span>Issue 8

> Austin Group Defect 190 is applied, marking the *man* utility as part of the User Portability Utilities option, and adding a requirement for the message it writes for a standard utility to include the environment variables affecting its execution and its list of exit status codes.
>
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
