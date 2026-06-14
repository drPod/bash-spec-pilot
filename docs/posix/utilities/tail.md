The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="tail"></span> <span id="tag_20_118"></span>

#### <span id="tag_20_118_01"></span>NAME

> tail — copy the last part of a file

#### <span id="tag_20_118_02"></span>SYNOPSIS

> `tail`` `**`[`**`-f`**`] [`**`-c`` `*`number`*`|-n`` `*`number`***`] [`***`file`***`]`**\
> \
> `tail -r`` `**`[`**`-n`` `*`number`***`] [`***`file`***`]`**\

#### <span id="tag_20_118_03"></span>DESCRIPTION

> The *tail* utility shall copy its input file to the standard output beginning at a designated place.
>
> Copying shall begin at the point in the file indicated by the **-c** *number* or **-n** *number* options. The option-argument *number* shall be counted in units of lines or bytes, according to the options **-n** and **-c**. Both line and byte counts start from 1.
>
> Tails relative to the end of the file may be saved in an internal buffer, and thus may be limited in length. Such a buffer, if any, shall be no smaller than {LINE_MAX}\*10 bytes.

#### <span id="tag_20_118_04"></span>OPTIONS

> The *tail* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that `'+'` may be recognized as an option delimiter as well as `'-'`.
>
> The following options shall be supported:
>
> **-c ***number*
>
> The application shall ensure that the *number* option-argument is a decimal integer, optionally including a sign. The sign shall affect the location in the file, measured in bytes, to begin the copying:
>
> | **Sign** | **Copying Starts**                     |
> |:--------:|:---------------------------------------|
> |    \+    | Relative to the beginning of the file. |
> |    \-    | Relative to the end of the file.       |
> |  *none*  | Relative to the end of the file.       |
>
> The application shall ensure that if the sign of the *number* option-argument is `'+'`, the *number* option-argument is a non-zero decimal integer.
>
> The origin for counting shall be 1; that is, **-c** +1 represents the first byte of the file, **-c** -1 the last.
>
> **-f**
>
> If the input file is a regular file or if the *file* operand specifies a FIFO, do not terminate after the last line of the input file has been copied, but read and copy further bytes from the input file when they become available. If no *file* operand is specified and standard input is a pipe or FIFO, the **-f** option shall be ignored. If the input file is not a FIFO, pipe, or regular file, it is unspecified whether or not the **-f** option shall be ignored.
>
> **-n ***number*
>
> If **-r** is not specified, this option shall be equivalent to **-c** *number*, except the starting location in the file shall be measured in lines instead of bytes. The origin for counting shall be 1; that is, **-n** +1 represents the first line of the file, **-n** -1 the last.
>
> If **-r** is specified, *number* shall specify the number of lines to read (in reverse) from the end of the input file. The application shall ensure that *number* does not have a sign.
>
> **-r**
>
> Copy the lines in reverse order (last line first). If **-n** is specified, that many lines of the file, starting with the last line, shall be copied. If **-n** is not specified, every line of the input file shall be copied.
>
> If none of the **-c**, **-n** or **-r** options is specified, **-n** 10 shall be assumed.

#### <span id="tag_20_118_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an input file. If no *file* operand is specified, the standard input shall be used.

#### <span id="tag_20_118_06"></span>STDIN

> The standard input shall be used if no *file* operand is specified, and shall be used if the *file* operand is `'-'` and the implementation treats the `'-'` as meaning standard input. Otherwise, the standard input shall not be used. See the INPUT FILES section.

#### <span id="tag_20_118_07"></span>INPUT FILES

> If the **-c** option is specified, the input file can contain arbitrary data; otherwise, the input file shall be a text file.

#### <span id="tag_20_118_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *tail*:
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

#### <span id="tag_20_118_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_118_10"></span>STDOUT

> The designated portion of the input file shall be written to standard output.

#### <span id="tag_20_118_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_118_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_118_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_118_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_118_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_118_16"></span>APPLICATION USAGE

> The **-c** option should be used with caution when the input is a text file containing multi-byte characters; it may produce output that does not start on a character boundary.
>
> Although the input file to *tail* can be any type, the results might not be what would be expected on some character special device files or on file types not described by the System Interfaces volume of POSIX.1-2024. Since this volume of POSIX.1-2024 does not specify the block size used when doing input, *tail* need not read all of the data from devices that only perform block transfers.
>
> When using *tail* to process pathnames, and the **-c** option is not specified, it is recommended that LC_ALL, or at least LC_CTYPE and LC_COLLATE, are set to POSIX or C in the environment, since pathnames can contain byte sequences that do not form valid characters in some locales, in which case the utility's behavior would be undefined. In the POSIX locale each byte is a valid single-byte character, and therefore this problem is avoided.

#### <span id="tag_20_118_17"></span>EXAMPLES

> The **-f** option can be used to monitor the growth of a file that is being written by some other process. For example, the command:
>
>
>     tail -f fred
>
> prints the last ten lines of the file **fred**, followed by any lines that are appended to **fred** between the time *tail* is initiated and killed. As another example, the command:
>
>
>     tail -f -c 15 fred
>
> prints the last 15 bytes of the file **fred**, followed by any bytes that are appended to **fred** between the time *tail* is initiated and killed.

#### <span id="tag_20_118_18"></span>RATIONALE

> This version of *tail* was created to allow conformance to the Utility Syntax Guidelines. The historical **-b** option was omitted because of the general non-portability of block-sized units of text. The **-c** option historically meant "characters", but this volume of POSIX.1-2024 indicates that it means "bytes". This was selected to allow reasonable implementations when multi-byte characters are possible; it was not named **-b** to avoid confusion with the historical **-b**.
>
> The origin of counting both lines and bytes is 1, matching all widespread historical implementations. Hence *tail* **-n** +0 is not conforming usage because it attempts to output line zero; but note that *tail* **-n** 0 does conform, and outputs nothing.
>
> Earlier versions of this standard allowed the following forms in the SYNOPSIS:
>
>
>     tail -[number][b|c|l][f] [file]
>     tail +[number][b|c|l][f] [file]
>
> These forms are no longer specified by POSIX.1-2024, but may be present in some implementations.
>
> The restriction on the internal buffer is a compromise between the historical System V implementation of 4096 bytes and the BSD 32768 bytes.
>
> The **-f** option has been implemented as a loop that sleeps for 1 second and copies any bytes that are available. This is sufficient, but if more efficient methods of determining when new data are available are developed, implementations are encouraged to use them.
>
> Historical documentation indicates that *tail* ignores the **-f** option if the input file is a pipe (pipe and FIFO on systems that support FIFOs). On BSD-based systems, this has been true; on System V-based systems, this was true when input was taken from standard input, but it did not ignore the **-f** flag if a FIFO was named as the *file* operand. Since the **-f** option is not useful on pipes and all historical implementations ignore **-f** if no *file* operand is specified and standard input is a pipe, this volume of POSIX.1-2024 requires this behavior. However, since the **-f** option is useful on a FIFO, this volume of POSIX.1-2024 also requires that if a FIFO is named, the **-f** option shall not be ignored. Earlier versions of this standard did not state any requirement for the case where no *file* operand is specified and standard input is a FIFO. The standard has been updated to reflect current practice which is to treat this case the same as a pipe on standard input. Although historical behavior does not ignore the **-f** option for other file types, this is unspecified so that implementations are allowed to ignore the **-f** option if it is known that the file cannot be extended.
>
> The functionality made available by *tail* **-r** has been historically provided on some systems by a separate utility (*tac*), although *tac* traditionally lacked support for **-n** to limit the output. While both `tail -n$n | tac` and `tac | head -n$n` can be used to output a fixed length of reversed line output, the standard developers decided that it was preferable to have a single utility `tail -r -n$n` for the same purpose. Furthermore, in deciding whether to standardize *tac* rather than *tail* **-r**, it was determined that more implementations that have achieved POSIX certification had already implemented *tail* **-r** as an extension.

#### <span id="tag_20_118_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_118_20"></span>SEE ALSO

> [*head*](../utilities/head.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_118_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_118_22"></span>Issue 6

> The obsolescent SYNOPSIS lines and associated text are removed.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_118_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied, clarifying that `'+'` may be recognized as an option delimiter in the OPTIONS section.
>
> Austin Group Interpretation 1003.1-2001 \#092 is applied.
>
> Austin Group Interpretation 1003.1-2001 \#100 is applied, adding the requirement on applications that if the sign of the option-argument *number* is `'+'`, the *number* option-argument is a non-zero decimal integer.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> SD5-XCU-ERN-114 is applied, updating the OPTIONS section (the **-f** option).
>
> SD5-XCU-ERN-149 is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0190 \[663\] is applied.

#### <span id="tag_20_118_24"></span>Issue 8

> Austin Group Defect 877 is applied, adding the **-r** option.
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
