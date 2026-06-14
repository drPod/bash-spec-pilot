The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="comm"></span> <span id="tag_20_21"></span>

#### <span id="tag_20_21_01"></span>NAME

> comm — select or reject lines common to two files

#### <span id="tag_20_21_02"></span>SYNOPSIS

> `comm`` `**`[`**`-123`**`]`**` `*`file1 file2`*

#### <span id="tag_20_21_03"></span>DESCRIPTION

> The *comm* utility shall read *file1* and *file2*, which should be ordered in the current collating sequence, and produce three text columns as output: lines only in *file1*, lines only in *file2*, and lines in both files.
>
> If the lines in both files are not ordered according to the collating sequence of the current locale, the results are unspecified.
>
> If the collating sequence of the current locale does not have a total ordering of all characters (see XBD [*7.3.2 LC_COLLATE*](../basedefs/V1_chap07.html#tag_07_03_02)) and any lines from the input files collate equally but are not identical, *comm* shall treat them as different lines and shall expect them to be ordered according to a further byte-by-byte comparison using the collating sequence for the POSIX locale; if they are not ordered in this way, the output of *comm* can identify such lines as being both unique to *file1* and unique to *file2* instead of being in both files.

#### <span id="tag_20_21_04"></span>OPTIONS

> The *comm* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-1**
>
> Suppress the output column of lines unique to *file1*.
>
> **-2**
>
> Suppress the output column of lines unique to *file2*.
>
> **-3**
>
> Suppress the output column of lines duplicated in *file1* and *file2*.

#### <span id="tag_20_21_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file1*
>
> A pathname of the first file to be compared. If *file1* is `'-'`, the standard input shall be used.
>
> *file2*
>
> A pathname of the second file to be compared. If *file2* is `'-'`, the standard input shall be used.
>
> If both *file1* and *file2* refer to standard input or to the same FIFO special, block special, or character special file, the results are undefined.

#### <span id="tag_20_21_06"></span>STDIN

> The standard input shall be used only if one of the *file1* or *file2* operands refers to standard input. See the INPUT FILES section.

#### <span id="tag_20_21_07"></span>INPUT FILES

> The input files shall be text files.

#### <span id="tag_20_21_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *comm*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
>
> *LC_COLLATE*
>
> \
> Determine the locale for the collating sequence *comm* expects to have been used when the input files were sorted.
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
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_21_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_21_10"></span>STDOUT

> The *comm* utility shall produce output depending on the options selected. If the **-1**, **-2**, and **-3** options are all selected, *comm* shall write nothing to standard output.
>
> If the **-1** option is not selected, lines contained only in *file1* shall be written using the format:
>
>
>     "%s\n", <line in file1>
>
> If the **-2** option is not selected, lines contained only in *file2* are written using the format:
>
>
>     "%s%s\n", <lead>, <line in file2>
>
> where the string \<*lead*\> is as follows:
>
> \<tab\>
>
> The **-1** option is not selected.
>
> null string
>
> The **-1** option is selected.
>
> If the **-3** option is not selected, lines contained in both files shall be written using the format:
>
>
>     "%s%s\n", <lead>, <line in both>
>
> where the string \<*lead*\> is as follows:
>
> \<tab\>\<tab\>
>
> Neither the **-1** nor the **-2** option is selected.
>
> \<tab\>
>
> Exactly one of the **-1** and **-2** options is selected.
>
> null string
>
> Both the **-1** and **-2** options are selected.
>
> If the input files were ordered according to the collating sequence of the current locale, the lines written shall be in the collating sequence of the current locale. If the input files contained any lines that collated equally but were not identical and within each file those lines were ordered according to a further byte-by-byte comparison using the collating sequence for the POSIX locale, then lines written that collate equally but are not identical shall be ordered according to a further byte-by-byte comparison using the collating sequence for the POSIX locale.

#### <span id="tag_20_21_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_21_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_21_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_21_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> All input files were successfully output as specified.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_21_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_21_16"></span>APPLICATION USAGE

> If the input files are not properly presorted, the output of *comm* might not be useful.
>
> When using *comm* to process pathnames, it is recommended that LC_ALL, or at least LC_CTYPE and LC_COLLATE, are set to POSIX or C in the environment, since pathnames can contain byte sequences that do not form valid characters in some locales, in which case the utility's behavior would be undefined. In the POSIX locale each byte is a valid single-byte character, and therefore this problem is avoided.
>
> If the collating sequence of the current locale does not have a total ordering of all characters, since *comm* treats lines as being the same only if they are identical, some lines can be misleadingly identified as being both unique to *file1* and unique to *file2* if lines that collate equally but are not identical are not ordered in the way that *comm* expects. If the input does not come from utilities (such as [*ls*](../utilities/ls.html) and [*sort*](../utilities/sort.html)) which provide this ordering, the problem can be avoided by pre-sorting the input files using [*sort*](../utilities/sort.html).

#### <span id="tag_20_21_17"></span>EXAMPLES

> If a file named **xcu** contains a sorted list of the utilities in this volume of POSIX.1-2024, a file named **xpg3** contains a sorted list of the utilities specified in the X/Open Portability Guide, Issue 3, and a file named **svid89** contains a sorted list of the utilities in the System V Interface Definition Third Edition:
>
>
>     comm -23 xcu xpg3 | comm -23 - svid89
>
> would print a list of utilities in this volume of POSIX.1-2024 not specified by either of the other documents:
>
>
>     comm -12 xcu xpg3 | comm -12 - svid89
>
> would print a list of utilities specified by all three documents, and:
>
>
>     comm -12 xpg3 svid89 | comm -23 - xcu
>
> would print a list of utilities specified by both XPG3 and the SVID, but not specified in this volume of POSIX.1-2024.

#### <span id="tag_20_21_18"></span>RATIONALE

> None.

#### <span id="tag_20_21_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_21_20"></span>SEE ALSO

> [*cmp*](../utilities/cmp.html#), [*diff*](../utilities/diff.html#), [*sort*](../utilities/sort.html#), [*uniq*](../utilities/uniq.html#)
>
> XBD [*7.3.2 LC_COLLATE*](../basedefs/V1_chap07.html#tag_07_03_02), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_21_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_21_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_21_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0076 \[963\], XCU/TC2-2008/0077 \[663\], and XCU/TC2-2008/0078 \[963\] are applied.

#### <span id="tag_20_21_24"></span>Issue 8

> Austin Group Defect 1070 is applied, changing the requirements when any lines from the input files collate equally but are not identical.
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
