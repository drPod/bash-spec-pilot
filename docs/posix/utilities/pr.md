The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="pr"></span> <span id="tag_20_95"></span>

#### <span id="tag_20_95_01"></span>NAME

> pr — print files

#### <span id="tag_20_95_02"></span>SYNOPSIS

> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` pr`` `**`[`**`+`*`page`***`] [`**`-`*`column`***`] [`**`-ad`<img src="../images/opt-start.gif" data-border="0" />`f`<img src="../images/opt-end.gif" data-border="0" />`Fmprt`**`] [`**`-e`**`[`***`char`***`][`***`gap`***`]] [`**`-h`` `*`header`***`]`\**
> ` ``      `` `**`[`**`-i`**`[`***`char`***`][`***`gap`***`]] [`**`-l`` `*`lines`***`] [`**`-n`**`[`***`char`***`][`***`width`***`]] [`**`-o`` `*`offset`***`] [`**`-s`**`[`***`char`***`]]`\**
> ` ``      `` `**`[`**`-w`` `*`width`***`] [`***`file`*`...`**`]`**

#### <span id="tag_20_95_03"></span>DESCRIPTION

> The *pr* utility is a printing and pagination filter. If multiple input files are specified, each shall be read, formatted, and written to standard output. By default, the input shall be separated into 66-line pages, each with:
>
> - A 5-line header that includes the page number, date, time, and the pathname of the file
>
> - A 5-line trailer consisting of blank lines
>
> If standard output is associated with a terminal, diagnostic messages shall be deferred until the *pr* utility has completed processing.
>
> When options specifying multi-column output are specified, output text columns shall be of equal width; input lines that do not fit into a text column shall be truncated. By default, text columns shall be separated with at least one \<blank\>.

#### <span id="tag_20_95_04"></span>OPTIONS

> The *pr* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that: the *page* option has a `'+'` delimiter; *page* and *column* can be multi-digit numbers; some of the option-arguments are optional; and some of the option-arguments cannot be specified as separate arguments from the preceding option letter. In particular, the **-s** option does not allow the option letter to be separated from its argument, and the options **-e**, **-i**, and **-n** require that both arguments, if present, not be separated from the option letter.
>
> The following options shall be supported. In the following option descriptions, *column*, *lines*, *offset*, *page*, and *width* are positive decimal integers; *gap* is a non-negative decimal integer.
>
> **+***page*
>
> Begin output at page number *page* of the formatted input.
>
> **-***column*
>
> Produce multi-column output that is arranged in *column* columns (the default shall be 1) and is written down each column in the order in which the text is received from the input file. This option should not be used with **-m**. The options **-e** and **-i** shall be assumed for multiple text-column output. Whether or not text columns are produced with identical vertical lengths is unspecified, but a text column shall never exceed the length of the page (see the **-l** option). When used with **-t**, use the minimum number of lines to write the output.
>
> **-a**
>
> Modify the effect of the **-***column* option so that the columns are filled across the page in a round-robin order (for example, when *column* is 2, the first input line heads column 1, the second heads column 2, the third is the second line in column 1, and so on).
>
> **-d**
>
> Produce output that is double-spaced; append an extra \<newline\> following every \<newline\> found in the input.
>
> **-e\[***char***\]\[***gap***\]**
>
> \
> Expand each input \<tab\> to the next greater column position specified by the formula *n*\**gap*+1, where *n* is an integer \> 0. If *gap* is zero or is omitted, it shall default to 8. All \<tab\> characters in the input shall be expanded into the appropriate number of \<space\> characters. If any non-digit character, *char*, is specified, it shall be used as the input \<tab\>. If the first character of the **-e** option-argument is a digit, the entire option-argument shall be assumed to be *gap*.
>
> **-f**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Use a \<form-feed\> for new pages, instead of the default behavior that uses a sequence of \<newline\> characters. Pause before beginning the first page if the standard output is associated with a terminal. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-F**
>
> Use a \<form-feed\> for new pages, instead of the default behavior that uses a sequence of \<newline\> characters.
>
> **-h ***header*
>
> Use the string *header* to replace the contents of the *file* operand in the page header.
>
> **-i\[***char***\]\[***gap***\]**
>
> In output, replace \<space\> characters with \<tab\> characters wherever one or more adjacent \<space\> characters reach column positions *gap*+1, 2\* *gap*+1, 3\* *gap*+1, and so on. If *gap* is zero or is omitted, default tab settings at every eighth column position shall be assumed. If any non-digit character, *char*, is specified, it shall be used as the output \<tab\>. If the first character of the **-i** option-argument is a digit, the entire option-argument shall be assumed to be *gap*.
>
> **-l ***lines*
>
> Override the 66-line default and reset the page length to *lines*. If *lines* is not greater than the sum of both the header and trailer depths (in lines), the *pr* utility shall suppress both the header and trailer, as if the **-t** option were in effect.
>
> **-m**
>
> Merge files. Standard output shall be formatted so the *pr* utility writes one line from each file specified by a *file* operand, side by side into text columns of equal fixed widths, in terms of the number of column positions. Implementations shall support merging of at least nine *file* operands.
>
> **-n\[***char***\]\[***width***\]**
>
> \
> Provide *width*-digit line numbering (default for *width* shall be 5). The number shall occupy the first *width* column positions of each text column of default output or each line of **-m** output. If *char* (any non-digit character) is given, it shall be appended to the line number to separate it from whatever follows (default for *char* is a \<tab\>).
>
> **-o ***offset*
>
> Each line of output shall be preceded by offset \<space\> characters. If the **-o** option is not specified, the default offset shall be zero. The space taken is in addition to the output line width (see the **-w** option below).
>
> **-p**
>
> Pause before beginning each page if the standard output is directed to a terminal; *pr* shall write an \<alert\> to standard error and wait for a \<newline\> to be read on **/dev/tty**.
>
> **-r**
>
> Write no diagnostic reports on failure to open files.
>
> **-s\[***char***\]**
>
> Separate text columns by the single character *char* instead of by the appropriate number of \<space\> characters (default for *char* shall be \<tab\>).
>
> **-t**
>
> Write neither the five-line identifying header nor the five-line trailer usually supplied for each page. Quit writing after the last line of each file without spacing to the end of the page.
>
> **-w ***width*
>
> Set the width of the line to *width* column positions for multiple text-column output only. If the **-w** option is not specified and the **-s** option is not specified, the default width shall be 72. If the **-w** option is not specified and the **-s** option is specified, the default width shall be 512.
>
> For single column output, input lines shall not be truncated.

#### <span id="tag_20_95_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a file to be written. If no *file* operands are specified, or if a *file* operand is `'-'`, the standard input shall be used.

#### <span id="tag_20_95_06"></span>STDIN

> The standard input shall be used only if no *file* operands are specified, or if a *file* operand is `'-'`. See the INPUT FILES section.

#### <span id="tag_20_95_07"></span>INPUT FILES

> The input files shall be text files. If the **-m** option is not specified, an empty input file may, but should not, be treated as an error.
>
> The file **/dev/tty** shall be used to read responses required by the **-p** option.

#### <span id="tag_20_95_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *pr*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and which characters are defined as printable (character class **print**). Non-printable characters are still written to standard output, but are not counted for the purpose for column-width and line-length calculations.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *LC_TIME*
>
> Determine the format of the date and time for use in writing header lines.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *TZ*
>
> Determine the timezone used to calculate date and time strings written in header lines. If *TZ* is unset or null, an unspecified default timezone shall be used.

#### <span id="tag_20_95_09"></span>ASYNCHRONOUS EVENTS

> If *pr* receives an interrupt while writing to a terminal, it shall flush all accumulated error messages to the screen before terminating.

#### <span id="tag_20_95_10"></span>STDOUT

> If the **-m** option is not specified, the *pr* utility output shall be as follows:
>
> - If an input file is empty and the implementation does not treat this as an error, no output shall be written for that file and this shall be considered to be successful completion of the processing for that file.
>
> - For each non-empty input file, the output shall be a paginated version of the original file.
>
> If the **-m** option is specified, the *pr* utility output shall be a paginated version of the merged file contents, as described in OPTIONS.
>
> In both cases, the pagination shall be accomplished using either \<form-feed\> characters or a sequence of \<newline\> characters, as controlled by the **-F** <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  or **-f** <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> option. Page headers shall be generated unless the **-t** option is specified, the **-l** option is specified with too small a value (see OPTIONS), or the **-m** option is specified and all of the input files are empty. The page headers shall be of the form:
>
>
>     "\n\n%s %s Page %d\n\n\n", <output of date>, <file>, <page number>
>
> In the POSIX locale, the \<*output of date*\> field shall be equivalent to the output of the following command:
>
>
>     date "+%b %e %H:%M %Y"
>
> without the trailing \<newline\>, as it would appear if executed at the current time if the **-m** option is specified, or at the following time otherwise:
>
> - The current time on pages being written from standard input.
>
> - The modification time of the file named by the corresponding *file* operand on pages not being written from standard input.
>
> When the *LC_TIME* locale category is not set to the POSIX locale, a different format and order of presentation of this field may be used.
>
> If the **-h** option is specified, the \<*file*\> field shall be replaced by the *header* argument. Otherwise:
>
> - If the **-m** option is specified, the \<*file*\> field shall be replaced by a null string on all pages.
>
> - If the **-m** option is not specified, the \<*file*\> field shall be replaced by a null string on pages containing output that was read from standard input.

#### <span id="tag_20_95_11"></span>STDERR

> The standard error shall be used for diagnostic messages and for alerting the terminal when **-p** is specified.

#### <span id="tag_20_95_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_95_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_95_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_95_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_95_16"></span>APPLICATION USAGE

> A conforming application must protect its first operand, if it starts with a \<plus-sign\>, by preceding it with the `"--"` argument that denotes the end of the options. For example, *pr*+*x* could be interpreted as an invalid page number or a *file* operand.
>
> If a *file* operand contains \<newline\>, \<form-feed\>, or \<vertical-tab\> characters, or is overly long, and the *pr* utility is instructed to include the pathname of that file in the header, pagination may not be handled correctly. Applications can guard against this by using the **-h** option (for example, passing a sanitized, truncated form of the pathname with **-h**).

#### <span id="tag_20_95_17"></span>EXAMPLES

> 1.  Print a numbered list of all files in the current directory:
>
>
>         ls -a | pr -n -h "Files in $(pwd)."
>
> 2.  Print **file1** and **file2** as a double-spaced, three-column listing headed by "file list":
>
>
>         pr -3d -h "file list" file1 file2
>
> 3.  Write **file1** on **file2**, expanding tabs to columns 10, 19, 28, ...:
>
>
>         pr -e9 -t <file1 >file2

#### <span id="tag_20_95_18"></span>RATIONALE

> This utility is one of those that does not follow the Utility Syntax Guidelines because of its historical origins. The standard developers could have added new options that obeyed the guidelines (and marked the old options obsolescent) or devised an entirely new utility; there are examples of both actions in this volume of POSIX.1-2024. Because of its widespread use by historical applications, the standard developers decided to exempt this version of *pr* from many of the guidelines.
>
> Implementations are required to accept option-arguments to the **-h**, **-l**, **-o**, and **-w** options whether presented as part of the same argument or as a separate argument to *pr*, as suggested by the Utility Syntax Guidelines. The **-n** and **-s** options, however, are specified as in historical practice because they are frequently specified without their optional arguments. If a \<blank\> were allowed before the option-argument in these cases, a *file* operand could mistakenly be interpreted as an option-argument in historical applications.
>
> The text about the minimum number of lines in multi-column output was included to ensure that a best effort is made in balancing the length of the columns. There are known historical implementations in which, for example, 60-line files are listed by *pr* -2 as one column of 56 lines and a second of 4. Although this is not a problem when a full page with headers and trailers is produced, it would be relatively useless when used with **-t**.
>
> Historical implementations of the *pr* utility have differed in the action taken for the **-f** option. BSD uses it as described here for the **-F** option; System V uses it to change trailing \<newline\> characters on each page to a \<form-feed\> and, if standard output is a TTY device, sends an \<alert\> to standard error and reads a line from **/dev/tty** before the first page. There were strong arguments from both sides of this issue concerning historical practice and as a result the **-F** option was added. XSI-conformant systems support the System V historical actions for the **-f** option.
>
> The \<*output of date*\> field in the **-l** format is specified only for the POSIX locale. As noted, the format can be different in other locales. No mechanism for defining this is present in this volume of POSIX.1-2024, as the appropriate vehicle is a message catalog; that is, the format should be specified as a "message".
>
> Some implementations of *pr* treat an empty file as an error when **-m** is not specified, but not when **-m** is specified (even if there is only one input file). Implementations are encouraged to eliminate this inconsistency by never treating an empty file as an error.

#### <span id="tag_20_95_19"></span>FUTURE DIRECTIONS

> A future version of this standard may require that an empty file is never treated as an error.

#### <span id="tag_20_95_20"></span>SEE ALSO

> [*expand*](../utilities/expand.html#), [*lp*](../utilities/lp.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_95_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_95_22"></span>Issue 6

> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - The **-p** option is added.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_95_23"></span>Issue 7

> PASC Interpretation 1003.2-92 \#151 (SD5-XCU-ERN-44) is applied.
>
> Austin Group Interpretation 1003.1-2001 \#093 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_95_24"></span>Issue 8

> Austin Group Defect 251 is applied, adding a paragraph about problematic pathnames to the APPLICATION USAGE section.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1433 is applied, changing \<carriage-return\> to \<newline\> in the description of the **-p** option.
>
> Austin Group Defect 1434 is applied, combining the two option groups in the SYNOPSIS into one.
>
> Austin Group Defect 1590 is applied, clarifying the requirements when an input file is empty and changing the STDOUT section.

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
