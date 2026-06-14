The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="dd"></span> <span id="tag_20_31"></span>

#### <span id="tag_20_31_01"></span>NAME

> dd — convert and copy a file

#### <span id="tag_20_31_02"></span>SYNOPSIS

> `dd`` `**`[`***`operand`*`...`**`]`**

#### <span id="tag_20_31_03"></span>DESCRIPTION

> The *dd* utility shall copy the specified input file to the specified output file with possible conversions using specific input and output block sizes. It shall read the input one block at a time, using the specified input block size; it shall then process the block of data actually returned, which could be smaller than the requested block size. It shall apply any conversions that have been specified and write the resulting data to the output in blocks of the specified output block size. If the **bs**=*expr* operand is specified and no conversions other than **sync**, **noerror**, or **notrunc** are requested, the data returned from each input block shall be written as a separate output block; if the read returns less than a full block and the **sync** conversion is not specified, the resulting output block shall be the same size as the input block. If the **bs**=*expr* operand is not specified, or a conversion other than **sync**, **noerror**, or **notrunc** is requested, the input shall be processed and collected into full-sized output blocks until the end of the input is reached.
>
> The processing order shall be as follows:
>
> 1.  An input block is read. If the **iflags**=fullblock operand is specified, this might entail multiple reads; otherwise, the input block shall be used even if the read was shorter than the specified block size.
>
> 2.  If the input block is shorter than the specified input block size and the **sync** conversion is specified, null bytes shall be appended to the input data up to the specified size. (If either **block** or **unblock** is also specified, \<space\> characters shall be appended instead of null bytes.) The remaining conversions and output shall include the pad characters as if they had been read from the input.
>
> 3.  If the **bs**=*expr* operand is specified and no conversion other than **sync** or **noerror** is requested, the resulting data shall be written to the output as a single block, and the remaining steps are omitted.
>
> 4.  If the **swab** conversion is specified, each pair of input data bytes shall be swapped. If there is an odd number of bytes in the input block, the last byte in the input record shall not be swapped.
>
> 5.  Any remaining conversions (**block**, **unblock**, **lcase**, and **ucase**) shall be performed. These conversions shall operate on the input data independently of the input blocking; an input or output fixed-length record may span block boundaries.
>
> 6.  The data resulting from input or conversion or both shall be aggregated into output blocks of the specified size. After the end of input is reached, any remaining output shall be written as a block without padding if **conv**=**sync** is not specified; thus, the final output block may be shorter than the output block size.

#### <span id="tag_20_31_04"></span>OPTIONS

> None.

#### <span id="tag_20_31_05"></span>OPERANDS

> All of the operands shall be processed before any input is read. The following operands shall be supported:
>
> **if**=*file*
>
> Specify the input pathname; the default is standard input.
>
> **of**=*file*
>
> Specify the output pathname; the default is standard output. If the **seek**=*expr* conversion is not also specified, the output file shall be truncated before the copy begins if an explicit **of**=*file* operand is specified, unless **conv**=**notrunc** is specified. If **seek**=*expr* is specified, but **conv**=**notrunc** is not, the effect of the copy shall be to preserve the blocks in the output file over which *dd* seeks, but no other portion of the output file shall be preserved. (If the size of the seek plus the size of the input file is less than the previous size of the output file, the output file shall be shortened by the copy. If the input file is empty and either the size of the seek is greater than the previous size of the output file or the output file did not previously exist, the size of the output file shall be set to the file offset after the seek.)
>
> **ibs**=*expr*
>
> Specify the input block size, in bytes, by *expr* (default is 512).
>
> **obs**=*expr*
>
> Specify the output block size, in bytes, by *expr* (default is 512).
>
> **bs**=*expr*
>
> Set both input and output block sizes to *expr* bytes, superseding **ibs**= and **obs**=. If no conversion other than **sync**, **noerror**, and **notrunc** is specified, each input block shall be copied to the output as a single block without aggregating short blocks.
>
> **cbs**=*expr*
>
> Specify the conversion block size for **block** and **unblock** in bytes by *expr* (default is zero). If **cbs**= is omitted or given a value of zero, using **block** or **unblock** produces unspecified results.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The application shall ensure that this operand is also specified if the **conv**= operand is specified with a value of **ascii**, **ebcdic**, or **ibm**. For a **conv**= operand with an **ascii** value, the input is handled as described for the **unblock** value, except that characters are converted to ASCII before any trailing \<space\> characters are deleted. For **conv**= operands with **ebcdic** or **ibm** values, the input is handled as described for the **block** value except that the characters are converted to EBCDIC or IBM EBCDIC, respectively, after any trailing \<space\> characters are added. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **skip**=*n*
>
> Skip *n* input blocks (using the specified input block size) before starting to copy. On seekable files, the implementation shall read the blocks or seek past them; on non-seekable files, the blocks shall be read and the data shall be discarded.
>
> **seek**=*n*
>
> Skip *n* blocks (using the specified output block size) from the beginning of the output file before copying. On non-seekable files, existing blocks shall be read and space from the current end-of-file to the specified offset, if any, filled with null bytes; on seekable files, the implementation shall seek to the specified offset or read the blocks as described for non-seekable files.
>
> **count**=*n*
>
> Copy only *n* input blocks. If *n* is zero, it is unspecified whether no blocks or all blocks are copied.
>
> **conv**=*value***\[**,*value* ...**\]**
>
> \
> Where *value*s are \<comma\>-separated symbols from the following list:
>
> **ascii**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Convert EBCDIC to ASCII; see [ASCII to EBCDIC Conversion](#tagtcjh_18). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **ebcdic**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Convert ASCII to EBCDIC; see [ASCII to EBCDIC Conversion](#tagtcjh_18). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **ibm**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Convert ASCII to a different EBCDIC set; see [ASCII to IBM EBCDIC Conversion](#tagtcjh_19). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The **ascii**, **ebcdic**, and **ibm** values are mutually-exclusive. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **block**
>
> Treat the input as a sequence of \<newline\>-terminated or end-of-file-terminated variable-length records independent of the input block boundaries. Each record shall be converted to a record with a fixed length specified by the conversion block size. Any \<newline\> shall be removed from the input line; \<space\> characters shall be appended to lines that are shorter than their conversion block size to fill the block. Lines that are longer than the conversion block size shall be truncated to the largest number of characters that fit into that size; the number of truncated lines shall be reported (see the STDERR section).
>
> The **block** and **unblock** values are mutually-exclusive.
>
> **unblock**
>
> Convert fixed-length records to variable length. Read a number of bytes equal to the conversion block size (or the number of bytes remaining in the input, if less than the conversion block size), delete all trailing \<space\> characters, and append a \<newline\>.
>
> **lcase**
>
> Map uppercase characters specified by the *LC_CTYPE* keyword **tolower** to the corresponding lowercase character. Characters for which no mapping is specified shall not be modified by this conversion.
>
> The **lcase** and **ucase** symbols are mutually-exclusive.
>
> **ucase**
>
> Map lowercase characters specified by the *LC_CTYPE* keyword **toupper** to the corresponding uppercase character. Characters for which no mapping is specified shall not be modified by this conversion.
>
> **swab**
>
> Swap every pair of input bytes.
>
> **noerror**
>
> Do not stop processing on an input error. When an input error occurs, a diagnostic message shall be written on standard error, followed by the current input and output block counts in the same format as used at completion (see the STDERR section). If the **sync** conversion is specified, the missing input shall be replaced with null bytes and processed normally; otherwise, the input block shall be omitted from the output.
>
> **notrunc**
>
> Do not truncate the output file. Preserve blocks in the output file not explicitly written by this invocation of the *dd* utility. (See also the preceding **of**=*file* operand.)
>
> **sync**
>
> Pad every input block to the size of the **ibs**= buffer, appending null bytes. (If either **block** or **unblock** is also specified, append \<space\> characters, rather than null bytes.)
>
> **iflags**=fullblock
>
> \
> Perform as many reads as required to reach the full input block size or end of file, rather than acting on partial reads. If this operand is in effect, then the **count**= operand refers to the number of full input blocks rather than reads. The behavior is unspecified if **iflags**=fullblock is requested alongside the **sync**, **block**, or **unblock** conversions.
>
> The behavior is unspecified if operands other than **conv**= are specified more than once.
>
> For the **bs**=, **cbs**=, **ibs**=, and **obs**= operands, the application shall supply an expression specifying a size in bytes. The expression, *expr*, can be:
>
> 1.  A positive decimal number
>
> 2.  A positive decimal number followed by *k*, specifying multiplication by 1024
>
> 3.  A positive decimal number followed by *b*, specifying multiplication by 512
>
> 4.  Two or more positive decimal numbers (with or without *k* or *b*) separated by *x*, specifying the product of the indicated values
>
> All of the operands are processed before any input is read.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The following two tables display the octal number character values used for the **ascii** and **ebcdic** conversions (first table) and for the **ibm** conversion (second table). In both tables, the ASCII values are the row and column headers and the EBCDIC values are found at their intersections. For example, ASCII 0012 (LF) is the second row, third column, yielding 0045 in EBCDIC. The inverted tables (for EBCDIC to ASCII conversion) are not shown, but are in one-to-one correspondence with these tables. The differences between the two tables are highlighted by small boxes drawn around five entries. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
>
> <span id="tagtcjh_18"></span> Table: ASCII to EBCDIC Conversion
>
> ![](.././Figures/ascebc.gif)
>
> <span id="tagtcjh_19"></span> Table: ASCII to IBM EBCDIC Conversion
>
> ![](.././Figures/ascibm.gif)

#### <span id="tag_20_31_06"></span>STDIN

> If no **if**= operand is specified, the standard input shall be used. See the INPUT FILES section.

#### <span id="tag_20_31_07"></span>INPUT FILES

> The input file can be any file type.

#### <span id="tag_20_31_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *dd*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files), the classification of characters as uppercase or lowercase, and the mapping of characters from one case to the other.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_31_09"></span>ASYNCHRONOUS EVENTS

> For SIGINT, the *dd* utility shall interrupt its current processing, write status information to standard error, and terminate abnormally as if by the default action for SIGINT. One or more implementation defined non-job-control signals other than SIGABRT, SIGHUP, and SIGTERM may write status information to standard error and continue processing. All other signals (including job control signals, SIGABRT, SIGHUP, and SIGTERM) shall take their default action; see the ASYNCHRONOUS EVENTS section in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04).

#### <span id="tag_20_31_10"></span>STDOUT

> If no **of**= operand is specified, the standard output shall be used. The nature of the output depends on the operands selected.

#### <span id="tag_20_31_11"></span>STDERR

> On completion, *dd* shall write the number of input and output blocks to standard error. In the POSIX locale the following formats shall be used:
>
>
>     "%u+%u records in\n", <number of whole input blocks>,
>         <number of partial input blocks>
>
>
>     "%u+%u records out\n", <number of whole output blocks>,
>         <number of partial output blocks>
>
> A partial input block is one for which [*read*()](../functions/read.html) returned less than the input block size. A partial output block is one that was written with fewer bytes than specified by the output block size.
>
> In addition, when there is at least one truncated block, the number of truncated blocks shall be written to standard error. In the POSIX locale, the format shall be:
>
>
>     "%u truncated %s\n", <number of truncated blocks>, "record" (if
>         <number of truncated blocks> is one) "records" (otherwise)
>
> Diagnostic messages may also be written to standard error.

#### <span id="tag_20_31_12"></span>OUTPUT FILES

> If the **of**= operand is used, the output shall be the same as described in the STDOUT section.

#### <span id="tag_20_31_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_31_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_31_15"></span>CONSEQUENCES OF ERRORS

> If an input error is detected and the **noerror** conversion has not been specified, any partial output block shall be written to the output file, a diagnostic message shall be written, and the copy operation shall be discontinued. If some other error is detected, a diagnostic message shall be written and the copy operation shall be discontinued.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_31_16"></span>APPLICATION USAGE

> The input and output block size can be specified to take advantage of raw physical I/O.
>
> There are many different versions of the EBCDIC codesets. The ASCII and EBCDIC conversions specified for the *dd* utility perform conversions for the version specified by the tables.
>
> Using the **count**= operand of *dd* with a pipe or FIFO as the input can lead to surprising results, since these file types are prone to encountering short reads for any input block size other than 1. Unless the **iflags**=fullblock operand is in effect, *dd* will stop after the specified number of reads, rather than full input blocks, and therefore can often result in fewer bytes being output than the product of the count and input block size.

#### <span id="tag_20_31_17"></span>EXAMPLES

> The following command:
>
>
>     dd if=/dev/rmt0h  of=/dev/rmt1h
>
> copies from tape drive 0 to tape drive 1, using a common historical device naming convention.
>
> The following command:
>
>
>     dd ibs=10  skip=1
>
> strips the first 10 bytes from standard input.
>
> This example reads an EBCDIC tape blocked ten 80-byte EBCDIC card images per block into the ASCII file **x**:
>
>
>     dd if=/dev/tape of=x ibs=800 cbs=80 conv=ascii,lcase

#### <span id="tag_20_31_18"></span>RATIONALE

> The OPTIONS section is listed as "None" because there are no options recognized by historical *dd* utilities. Certainly, many of the operands could have been designed to use the Utility Syntax Guidelines, which would have resulted in the classic hyphenated option letters. In this version of this volume of POSIX.1-2024, *dd* retains its curious JCL-like syntax due to the large number of applications that depend on the historical implementation.
>
> A suggested implementation technique for **conv**=**noerror**,**sync** is to zero (or \<space\>-fill, if **block**ing or **unblock**ing) the input buffer before each read and to write the contents of the input buffer to the output even after an error. In this manner, any data transferred to the input buffer before the error was detected is preserved. Another point is that a failed read on a regular file or a disk generally does not increment the file offset, and *dd* must then seek past the block on which the error occurred; otherwise, the input error occurs repetitively. When the input is a magnetic tape, however, the tape normally has passed the block containing the error when the error is reported, and thus no seek is necessary.
>
> The default **ibs**= and **obs**= sizes are specified as 512 bytes because there are historical (largely portable) scripts that assume these values. If they were left unspecified, unusual results could occur if an implementation chose an odd block size.
>
> Historical implementations of *dd* used [*creat*()](../functions/creat.html) when processing **of**=*file*. This makes the **seek**= operand unusable except on special files. The **conv**=**notrunc** feature was added because more recent BSD-based implementations use [*open*()](../functions/open.html) (without O_TRUNC) instead of [*creat*()](../functions/creat.html), but they fail to delete output file contents after the data copied.
>
> The *w* multiplier (historically meaning *word*), is used in System V to mean 2 and in 4.2 BSD to mean 4. Since *word* is inherently non-portable, its use is not supported by this volume of POSIX.1-2024.
>
> Standard EBCDIC does not have the characters `'['` and `']'`. The values used in the table are taken from a common print train that does contain them. Other than those characters, the print train values are not filled in, but appear to provide some of the motivation for the historical choice of translations reflected here.
>
> The Standard EBCDIC table provides a 1:1 translation for all 256 bytes.
>
> The IBM EBCDIC table does not provide such a translation. The marked cells in the tables differ in such a way that:
>
> 1.  EBCDIC 0112 (`'¢'`) and 0152 (broken pipe) do not appear in the table.
>
> 2.  EBCDIC 0137 (`'¬'`) translates to/from ASCII 0236 (`'^'`). In the standard table, EBCDIC 0232 (no graphic) is used.
>
> 3.  EBCDIC 0241 (`'~'`) translates to/from ASCII 0176 (`'~'`). In the standard table, EBCDIC 0137 (`'¬'`) is used.
>
> 4.  0255 (`'['`) and 0275 (`']'`) appear twice, once in the same place as for the standard table and once in place of 0112 (`'¢'`) and 0241 (`'~'`).
>
> In net result:
>
> > EBCDIC 0275 (`']'`) displaced EBCDIC 0241 (`'~'`) in cell 0345.
> >
> >     That displaced EBCDIC 0137 (`'¬'`) in cell 0176.
> >
> >     That displaced EBCDIC 0232 (no graphic) in cell 0136.
> >
> >     That replaced EBCDIC 0152 (broken pipe) in cell 0313.
> >
> > EBCDIC 0255 (`'['`) replaced EBCDIC 0112 (`'¢'`).
>
> This translation, however, reflects historical practice that (ASCII) `'~'` and `'¬'` were often mapped to each other, as were `'['` and `'¢'`; and `']'` and (EBCDIC) `'~'`.
>
> The **cbs** operand is required if any of the **ascii**, **ebcdic**, or **ibm** operands are specified. For the **ascii** operand, the input is handled as described for the **unblock** operand except that characters are converted to ASCII before the trailing \<space\> characters are deleted. For the **ebcdic** and **ibm** operands, the input is handled as described for the **block** operand except that the characters are converted to EBCDIC or IBM EBCDIC after the trailing \<space\> characters are added.
>
> The **block** and **unblock** keywords are from historical BSD practice.
>
> The consistent use of the word **record** in standard error messages matches most historical practice. An earlier version of System V used **block**, but this has been updated in more recent releases.
>
> Early proposals only allowed two numbers separated by **x** to be used in a product when specifying **bs**=, **cbs**=, **ibs**=, and **obs**= sizes. This was changed to reflect the historical practice of allowing multiple numbers in the product as provided by Version 7 and all releases of System V and BSD.
>
> A change to the **swab** conversion is required to match historical practice and is the result of IEEE PASC Interpretations 1003.2 \#03 and \#04, submitted for the ISO POSIX-2:1993 standard.
>
> A change to the handling of SIGINT is required to match historical practice and is the result of IEEE PASC Interpretation 1003.2 \#06 submitted for the ISO POSIX-2:1993 standard.

#### <span id="tag_20_31_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> A future version of this standard may introduce the SIGINFO signal; on platforms where such a signal is available, it is recommended that this signal be used for reporting status without terminating the process.

#### <span id="tag_20_31_20"></span>SEE ALSO

> [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04), [*sed*](../utilities/sed.html#), [*tr*](../utilities/tr.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_31_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_31_22"></span>Issue 5

> The second paragraph of the **cbs**= description is reworded and marked EX.
>
> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_31_23"></span>Issue 6

> Changes are made to **swab** conversion and SIGINT handling to align with the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> IEEE PASC Interpretation 1003.2 \#209 is applied, clarifying the interaction between *dd* **of**=*file* and **conv**=**notrunc**.

#### <span id="tag_20_31_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#102 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0081 \[907\] is applied.

#### <span id="tag_20_31_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 406 is applied, adding the **iflags**=fullblock operand.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1159 is applied, changing the ASYNCHRONOUS EVENTS and FUTURE DIRECTIONS sections.
>
> Austin Group Defect 1497 is applied, changing the EXIT STATUS section.

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
