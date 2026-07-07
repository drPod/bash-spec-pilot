The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="paste"></span> <span id="tag_20_91"></span>

#### <span id="tag_20_91_01"></span>NAME

> paste — merge corresponding or subsequent lines of files

#### <span id="tag_20_91_02"></span>SYNOPSIS

> `paste`` `**`[`**`-s`**`] [`**`-d`` `*`list`***`]`**` `*`file`*`...`

#### <span id="tag_20_91_03"></span>DESCRIPTION

> The *paste* utility shall concatenate the corresponding lines of the given input files, and write the resulting lines to standard output.
>
> The default operation of *paste* shall concatenate the corresponding lines of the input files. The \<newline\> of every line except the line from the last input file shall be replaced with a \<tab\>.
>
> If an end-of-file condition is detected on one or more input files, but not all input files, *paste* shall behave as though empty lines were read from the files on which end-of-file was detected, unless the **-s** option is specified.

#### <span id="tag_20_91_04"></span>OPTIONS

> The *paste* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-d ***list*
>
> Unless a \<backslash\> character appears in *list*, each character in *list* is an element specifying a delimiter character. If a \<backslash\> character appears in *list*, the \<backslash\> character and one or more characters following it are an element specifying a delimiter character as described below. These elements specify one or more delimiters to use, instead of the default \<tab\>, to replace the \<newline\> of the input lines. The elements in *list* shall be used circularly; that is, when the list is exhausted the first element from the list is reused. When the **-s** option is specified:
>
> - The last \<newline\> in a file shall not be modified.
>
> - The delimiter shall be reset to the first element of *list* after each *file* operand is processed.
>
> When the **-s** option is not specified:
>
> - The \<newline\> characters in the file specified by the last *file* operand shall not be modified.
>
> - The delimiter shall be reset to the first element of list each time a line is processed from each file.
>
> If a \<backslash\> character appears in *list*, it and the character following it shall be used to represent the following delimiter characters:
>
> `\n`
>
> \<newline\>.
>
> `\t`
>
> \<tab\>.
>
> `\\`
>
> \<backslash\> character.
>
> `\0`
>
> Empty string (not a null character). If `'\0'` is immediately followed by the character `'x'`, the character `'X'`, or any character defined by the *LC_CTYPE* **digit** keyword (see XBD [*7. Locale*](../basedefs/V1_chap07.html#tag_07)), the results are unspecified.
>
> If any other characters follow the \<backslash\>, the results are unspecified.
>
> **-s**
>
> Concatenate all of the lines from each input file into one line of output per file, in command line order. The \<newline\> of every line except the last line in each input file shall be replaced with a \<tab\>, unless otherwise specified by the **-d** option. If an input file is empty, the output line corresponding to that file shall consist of only a \<newline\> character.

#### <span id="tag_20_91_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an input file. If `'-'` is specified for one or more of the *file*s, the standard input shall be used; the standard input shall be read one line at a time, circularly, for each instance of `'-'`. Implementations shall support pasting of at least 12 *file* operands.

#### <span id="tag_20_91_06"></span>STDIN

> The standard input shall be used only if one or more *file* operands is `'-'`. See the INPUT FILES section.

#### <span id="tag_20_91_07"></span>INPUT FILES

> The input files shall be text files, except that line lengths shall be unlimited.

#### <span id="tag_20_91_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *paste*:
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

#### <span id="tag_20_91_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_91_10"></span>STDOUT

> Concatenated lines of input files shall be separated by the \<tab\> (or other characters under the control of the **-d** option) and terminated by a \<newline\>.

#### <span id="tag_20_91_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_91_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_91_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_91_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_91_15"></span>CONSEQUENCES OF ERRORS

> If one or more input files cannot be opened when the **-s** option is not specified, a diagnostic message shall be written to standard error, but no output is written to standard output. If the **-s** option is specified, the *paste* utility shall provide the default behavior described in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04).

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_91_16"></span>APPLICATION USAGE

> When the escape sequences of the *list* option-argument are used in a shell script, they must be quoted; otherwise, the shell treats the \<backslash\> as a special character.
>
> Conforming applications should only use the specific \<backslash\>-escaped delimiters presented in this volume of POSIX.1-2024. Historical implementations treat `'\x'`, where `'x'` is not in this list, as `'x'`, but future implementations are free to expand this list to recognize other common escapes similar to those accepted by [*printf*](../utilities/printf.html) and other standard utilities.
>
> Most of the standard utilities work on text files. The [*cut*](../utilities/cut.html) utility can be used to turn files with arbitrary line lengths into a set of text files containing the same data. The *paste* utility can be used to create (or recreate) files with arbitrary line lengths. For example, if *file* contains long lines:
>
>
>     cut -b 1-500 -n file > file1
>     cut -b 501- -n file > file2
>
> creates **file1** (a text file) with lines no longer than 500 bytes (plus the \<newline\>) and **file2** that contains the remainder of the data from *file*. Note that **file2** is not a text file if there are lines in *file* that are longer than 500 + {LINE_MAX} bytes. The original file can be recreated from **file1** and **file2** using the command:
>
>
>     paste -d "\0" file1 file2 > file
>
> The commands:
>
>
>     paste -d "\0" ...
>     paste -d "" ...
>
> are not necessarily equivalent; the latter is not specified by this volume of POSIX.1-2024 and may result in an error. The construct `'\0'` is used to mean "no separator" because historical versions of *paste* did not follow the syntax guidelines, and the command:
>
>
>     paste -d"" ...
>
> could not be handled properly by [*getopt*()](../functions/getopt.html).

#### <span id="tag_20_91_17"></span>EXAMPLES

> 1.  Write out a directory in four columns:
>
>
>         ls | paste - - - -
>
> 2.  Combine pairs of lines from a file into single lines:
>
>
>         paste -s -d "\t\n" file

#### <span id="tag_20_91_18"></span>RATIONALE

> None.

#### <span id="tag_20_91_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_91_20"></span>SEE ALSO

> [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04), [*cut*](../utilities/cut.html#), [*grep*](../utilities/grep.html#), [*pr*](../utilities/pr.html#)
>
> XBD [*7. Locale*](../basedefs/V1_chap07.html#tag_07), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_91_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_91_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_91_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0149 \[973\] is applied.

#### <span id="tag_20_91_24"></span>Issue 8

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
