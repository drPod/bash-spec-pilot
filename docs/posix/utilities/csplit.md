The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="csplit"></span> <span id="tag_20_26"></span>

#### <span id="tag_20_26_01"></span>NAME

> csplit — split files based on context

#### <span id="tag_20_26_02"></span>SYNOPSIS

> `csplit`` `**`[`**`-ks`**`] [`**`-f`` `*`prefix`***`] [`**`-n`` `*`number`***`]`**` `*`file arg`*`...`

#### <span id="tag_20_26_03"></span>DESCRIPTION

> The *csplit* utility shall read the file named by the *file* operand, write all or part of that file into other files as directed by the *arg* operands, and write the sizes of the files.

#### <span id="tag_20_26_04"></span>OPTIONS

> The *csplit* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-f ***prefix*
>
> Name the created files *prefix***00**, *prefix***01**, ..., *prefixn*. The default is **xx00** ... **xx***n*. If the *prefix* argument would create a filename exceeding {NAME_MAX} bytes, an error shall result, *csplit* shall exit with a diagnostic message, and no files shall be created.
>
> **-k**
>
> Leave previously created files intact. By default, *csplit* shall remove created files if an error occurs.
>
> **-n ***number*
>
> Use *number* decimal digits to form filenames for the file pieces. The default shall be 2.
>
> **-s**
>
> Suppress the output of file size messages.

#### <span id="tag_20_26_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file*
>
> The pathname of a text file to be split. If *file* is `'-'`, the standard input shall be used.
>
> Each *arg* operand can be one of the following:
>
> /*rexp*/**\[***offset***\]**
>
> \
> A file shall be created using the content of the lines from the current line up to, but not including, the line that results from the evaluation of the regular expression with *offset*, if any, applied. The regular expression *rexp* shall follow the rules for basic regular expressions described in XBD [*9.3 Basic Regular Expressions*](../basedefs/V1_chap09.html#tag_09_03). The application shall use the sequence `"\/"` to specify a \<slash\> character within the *rexp*. The optional offset shall be a positive or negative integer value representing a number of lines. A positive integer value can be preceded by `'+'`. If the selection of lines from an *offset* expression of this type would create a file with zero lines, or one with greater than the number of lines left in the input file, the results are unspecified. After the section is created, the current line shall be set to the line that results from the evaluation of the regular expression with any offset applied. If the current line is the first line in the file and a regular expression operation has not yet been performed, the pattern match of *rexp* shall be applied from the current line to the end of the file. Otherwise, the pattern match of *rexp* shall be applied from the line following the current line to the end of the file.
>
> %*rexp*%**\[***offset***\]**
>
> \
> Equivalent to /*rexp*/**\[***offset***\]**, except that no file shall be created for the selected section of the input file. The application shall use the sequence `"\%"` to specify a \<percent-sign\> character within the *rexp*.
>
> *line_no*
>
> Create a file from the current line up to (but not including) the line number *line_no*. Lines in the file shall be numbered starting at one. The current line becomes *line_no*.
>
> {*num*}
>
> Repeat operand. This operand can follow any of the operands described previously. If it follows a *rexp* type operand, that operand shall be applied *num* more times. If it follows a *line_no* operand, the file shall be split every *line_no* lines, *num* times, from that point.
>
> An error shall be reported if an operand does not reference a line between the current position and the end of the file.

#### <span id="tag_20_26_06"></span>STDIN

> See the INPUT FILES section.

#### <span id="tag_20_26_07"></span>INPUT FILES

> The input file shall be a text file.

#### <span id="tag_20_26_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *csplit*:
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
> Determine the locale for the behavior of ranges, equivalence classes, and multi-character collating elements within regular expressions.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and the behavior of character classes within regular expressions.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_26_09"></span>ASYNCHRONOUS EVENTS

> If the **-k** option is specified, created files shall be retained. Otherwise, the default action occurs.

#### <span id="tag_20_26_10"></span>STDOUT

> Unless the **-s** option is used, the standard output shall consist of one line per file created, with a format as follows:
>
>
>     "%d\n", <file size in bytes>

#### <span id="tag_20_26_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_26_12"></span>OUTPUT FILES

> The output files shall contain portions of the original input file; otherwise, unchanged.

#### <span id="tag_20_26_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_26_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_26_15"></span>CONSEQUENCES OF ERRORS

> By default, created files shall be removed if an error occurs. When the **-k** option is specified, created files shall not be removed if an error occurs.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_26_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_26_17"></span>EXAMPLES

> 1.  This example creates four files, **cobol00** ... **cobol03**:
>
>
>         csplit -f cobol file '/procedure division/' /par5./ /par16./
>
>     After editing the split files, they can be recombined as follows:
>
>
>         cat cobol0[0-3] > file
>
>     Note that this example overwrites the original file.
>
> 2.  This example would split the file after the first 99 lines, and every 100 lines thereafter, up to 9999 lines; this is because lines in the file are numbered from 1 rather than zero, for historical reasons:
>
>
>         csplit -k file  100  {99}
>
> 3.  Assuming that **prog.c** follows the C-language coding convention of ending routines with a `'}'` at the beginning of the line, this example creates a file containing each separate C routine (up to 21) in **prog.c**:
>
>
>         csplit -k prog.c '%main(%'  '/^}/+1' {20}

#### <span id="tag_20_26_18"></span>RATIONALE

> The **-n** option was added to extend the range of filenames that could be handled.
>
> Consideration was given to adding a **-a** flag to use the alphabetic filename generation used by the historical [*split*](../utilities/split.html) utility, but the functionality added by the **-n** option was deemed to make alphabetic naming unnecessary.

#### <span id="tag_20_26_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_26_20"></span>SEE ALSO

> [*sed*](../utilities/sed.html#), [*split*](../utilities/split.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*9.3 Basic Regular Expressions*](../basedefs/V1_chap09.html#tag_09_03), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_26_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_26_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_26_23"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The APPLICATION USAGE section is added.
>
> The description of regular expression operands is changed to align with the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_26_24"></span>Issue 7

> The *csplit* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The SYNOPSIS and OPERANDS sections are revised to use a single *arg* to split a file into two pieces.

#### <span id="tag_20_26_25"></span>Issue 8

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
