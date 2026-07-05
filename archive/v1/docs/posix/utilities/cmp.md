The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="cmp"></span> <span id="tag_20_20"></span>

#### <span id="tag_20_20_01"></span>NAME

> cmp — compare two files

#### <span id="tag_20_20_02"></span>SYNOPSIS

> `cmp`` `**`[`**`-l|-s`**`]`**` `*`file1 file2`*

#### <span id="tag_20_20_03"></span>DESCRIPTION

> The *cmp* utility shall compare two files. The *cmp* utility shall write no output if the files are the same. Under default options, if they differ, it shall write to standard output the byte and line number at which the first difference occurred. Bytes and lines shall be numbered beginning with 1.

#### <span id="tag_20_20_04"></span>OPTIONS

> The *cmp* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-l**
>
> (Lowercase ell.) Write the byte number (decimal) and the differing bytes (octal) for each difference.
>
> **-s**
>
> Write nothing to standard output or standard error when files differ; indicate differing files through exit status only. It is unspecified whether a diagnostic message is written to standard error when an error is encountered; if a message is not written, the error is indicated through exit status only.

#### <span id="tag_20_20_05"></span>OPERANDS

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
> If both *file1* and *file2* refer to standard input or refer to the same FIFO special, block special, or character special file, the results are undefined.

#### <span id="tag_20_20_06"></span>STDIN

> The standard input shall be used only if the *file1* or *file2* operand refers to standard input. See the INPUT FILES section.

#### <span id="tag_20_20_07"></span>INPUT FILES

> The input files can be any file type.

#### <span id="tag_20_20_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *cmp*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_20_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_20_10"></span>STDOUT

> In the POSIX locale, results of the comparison shall be written to standard output. When no options are used, the format shall be:
>
>
>     "%s %s differ: char %d, line %d\n", file1, file2,
>         <byte number>, <line number>
>
> When the **-l** option is used, the format shall be:
>
>
>     "%d %o %o\n", <byte number>, <differing byte>,
>         <differing byte>
>
> for each byte that differs. The first \<*differing byte*\> number is from *file1* while the second is from *file2*. In both cases, \<*byte number*\> shall be relative to the beginning of the file, beginning with 1.
>
> No output shall be written to standard output when the **-s** option is used.

#### <span id="tag_20_20_11"></span>STDERR

> The standard error shall be used only for diagnostic messages. If the **-l** option is used and *file1* and *file2* differ in length, or if the **-s** option is not used and *file1* and *file2* are identical for the entire length of the shorter file, in the POSIX locale the following diagnostic message shall be written:
>
>
>     "cmp: EOF on %s%s\n", <name of shorter file>, <additional info>
>
> The \<*additional info*\> field shall either be null or a string that starts with a \<blank\> and contains no \<newline\> characters. Some implementations report on the number of lines in this case.
>
> If the **-s** option is used and an error occurs, it is unspecified whether a diagnostic message is written to standard error.

#### <span id="tag_20_20_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_20_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_20_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The files are identical.
>
>  1
>
> The files are different; this includes the case where one file is identical to the first part of the other.
>
> \>1
>
> An error occurred.

#### <span id="tag_20_20_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_20_16"></span>APPLICATION USAGE

> Although input files to *cmp* can be any type, the results might not be what would be expected on character special device files or on file types not described by the System Interfaces volume of POSIX.1-2024. Since this volume of POSIX.1-2024 does not specify the block size used when doing input, comparisons of character special files need not compare all of the data in those files.
>
> For files which are not text files, line numbers simply reflect the presence of a \<newline\>, without any implication that the file is organized into lines.
>
> Since the behavior of **-s** differs between implementations as to whether error messages are written, the only way to ensure consistent behavior of *cmp* when **-s** is used is to redirect standard error to **/dev/null**.
>
> If error messages are wanted, instead of using **-s** standard output should be redirected to **/dev/null**, and anything written to standard error should be discarded if the exit status is 1. For example:
>
>
>     silent_cmp() {
>         # compare files with no output except error messages
>         message=$(cmp "$@" 2>&1 >/dev/null)
>         status=$?
>         case $status in
>         (0|1) ;;
>         (*) printf '%s\n' "$message" ;;
>         esac
>         return $status
>     }

#### <span id="tag_20_20_17"></span>EXAMPLES

> None.

#### <span id="tag_20_20_18"></span>RATIONALE

> The global language in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04) indicates that using two mutually-exclusive options together produces unspecified results. Some System V implementations consider the option usage:
>
>
>     cmp -l -s ...
>
> to be an error. They also treat:
>
>
>     cmp -s -l ...
>
> as if no options were specified. Both of these behaviors are considered bugs, but are allowed.
>
> The word **char** in the standard output format comes from historical usage, even though it is actually a byte number. When *cmp* is supported in other locales, implementations are encouraged to use the word *byte* or its equivalent in another language. Users should not interpret this difference to indicate that the functionality of the utility changed between locales.
>
> Some implementations report on the number of lines in the identical-but-shorter file case. This is allowed by the inclusion of the \<*additional info*\> fields in the output format. The restriction on having a leading \<blank\> and no \<newline\> characters is to make parsing for the filename easier. It is recognized that some filenames containing white-space characters make parsing difficult anyway, but the restriction does aid programs used on systems where the names are predominantly well behaved.

#### <span id="tag_20_20_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> Future versions of this standard may require that diagnostic messages are written to standard error when the **-s** option is specified.

#### <span id="tag_20_20_20"></span>SEE ALSO

> [*comm*](../utilities/comm.html#), [*diff*](../utilities/diff.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_20_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_20_22"></span>Issue 7

> SD5-XCU-ERN-96 is applied, updating the STDERR section.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0075 \[478\] is applied.

#### <span id="tag_20_20_23"></span>Issue 8

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
