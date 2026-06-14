The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="uudecode"></span> <span id="tag_20_141"></span>

#### <span id="tag_20_141_01"></span>NAME

> uudecode — decode a binary file

#### <span id="tag_20_141_02"></span>SYNOPSIS

> `uudecode`` `**`[`**`-o`` `*`outfile`***`] [`***`file`***`]`**

#### <span id="tag_20_141_03"></span>DESCRIPTION

> The *uudecode* utility shall read a file, or standard input if no file is specified, that includes data created by the [*uuencode*](../utilities/uuencode.html) utility. The *uudecode* utility shall scan the input file, searching for data compatible with one of the formats specified in [*uuencode*](../utilities/uuencode.html), and determine the pathname for the output file from the **-o** option if given, otherwise from the input data. If the pathname for the output file is either of the magic cookies **-** or **/dev/stdout**, *uudecode* shall write the decoded file to standard output, otherwise it shall attempt to create or overwrite the file named by the pathname. The file access permission bits and contents for the file to be produced shall be contained in the input data. The mode bits of the created file (other than standard output) shall be set from the file access permission bits contained in the data; that is, other attributes of the mode, including the file mode creation mask (see [*umask*](../utilities/umask.html)), shall not affect the file being produced. If either of the *op* characters `'+'` and `'-'` (see [*chmod*](../utilities/chmod.html)) are specified in symbolic mode, the initial mode on which those operations are based is unspecified.
>
> If the pathname of the file resolves to an existing file and the user does not have write permission on that file, *uudecode* shall terminate with an error. If the pathname of the file resolves to an existing file and the user has write permission on that file, the existing file shall be overwritten and, if possible, the mode bits of the file (other than standard output) shall be set as described above; if the mode bits cannot be set, *uudecode* shall not treat this as an error.
>
> If the input data was produced by [*uuencode*](../utilities/uuencode.html) on a system with a different number of bits per byte than on the target system, the results of *uudecode* are unspecified.

#### <span id="tag_20_141_04"></span>OPTIONS

> The *uudecode* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported by the implementation:
>
> **-o ***outfile*
>
> A pathname of a file that shall be used instead of any pathname contained in the input data. Specifying an *outfile* option-argument of **-** or **/dev/stdout** shall indicate standard output.

#### <span id="tag_20_141_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> The pathname of a file containing the output of [*uuencode*](../utilities/uuencode.html).

#### <span id="tag_20_141_06"></span>STDIN

> See the INPUT FILES section.

#### <span id="tag_20_141_07"></span>INPUT FILES

> The input files shall be files containing the output of [*uuencode*](../utilities/uuencode.html).

#### <span id="tag_20_141_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *uudecode*:
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
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_141_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_141_10"></span>STDOUT

> If the pathname specified for the output file is **-** or **/dev/stdout**, the standard output shall be in the same format as the file originally encoded by [*uuencode*](../utilities/uuencode.html). Otherwise, the standard output shall not be used.

#### <span id="tag_20_141_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_141_12"></span>OUTPUT FILES

> The output file shall be in the same format as the file originally encoded by [*uuencode*](../utilities/uuencode.html).

#### <span id="tag_20_141_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_141_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_141_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_141_16"></span>APPLICATION USAGE

> The user who is invoking *uudecode* must have write permission on any file being created.
>
> The output of [*uuencode*](../utilities/uuencode.html) is essentially an encoded bit stream that is not cognizant of byte boundaries. It is possible that a 9-bit byte target machine can process input from an 8-bit source, if it is aware of the requirement, but the reverse is unlikely to be satisfying. Of course, the only data that is meaningful for such a transfer between architectures is generally character data.
>
> In order to create an output file named **-**, it needs to be specified using an alternative pathname, for example, **-o** **./-**, since **-** alone is considered a magic cookie by *uudecode*. Likewise, in order to write to an output file named **/dev/stdout** it also needs to be specified as, for example, **-o** **///dev/stdout**.

#### <span id="tag_20_141_17"></span>EXAMPLES

> None.

#### <span id="tag_20_141_18"></span>RATIONALE

> Input files are not necessarily text files, as stated by an early proposal. Although the [*uuencode*](../utilities/uuencode.html) output is a text file, that output could have been wrapped within another file or mail message that is not a text file.
>
> The **-o** option is not historical practice, but was added at the request of WG15 so that the user could override the target pathname without having to edit the input data itself.
>
> In early drafts, the \[**-o** *outfile*\] option-argument allowed the use of **-** to mean standard output. The standard developers did not wish to overload the meaning of **-** in this manner, resulting in previous versions only using **/dev/stdout** for this purpose. POSIX.1-2024 now allows it as most implementations were already supporting **-** as an extension. The file **/dev/stdout** exists as a special file on most modern systems. However, the **/dev/stdout** syntax in *uudecode* does not refer to a new file. It is just a magic cookie to specify standard output.

#### <span id="tag_20_141_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_141_20"></span>SEE ALSO

> [*chmod*](../utilities/chmod.html#tag_20_17), [*umask*](../utilities/umask.html#tag_20_132), [*uuencode*](../utilities/uuencode.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_141_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_141_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The **-o** *outfile* option is added, as specified in the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/35 is applied, clarifying in the DESCRIPTION that the initial mode used if either of the *op* characters is `'+'` or `'-'` is unspecified.

#### <span id="tag_20_141_23"></span>Issue 7

> The *uudecode* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0201 \[635\] is applied.

#### <span id="tag_20_141_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1544 is applied, changing the **-o** option to require that an option-argument of **-** is treated as meaning standard output.

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
