The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="iconv"></span> <span id="tag_20_58"></span>

#### <span id="tag_20_58_01"></span>NAME

> iconv — codeset conversion

#### <span id="tag_20_58_02"></span>SYNOPSIS

> `iconv`` `**`[`**`-cs`**`]`**` ``-f`` `*`frommap`*` ``-t`` `*`tomap`*` `**`[`***`file`*`...`**`]`**\
> \
> `iconv -f`` `*`fromcode`*` `**`[`**`-cs`**`] [`**`-t`` `*`tocode`***`] [`***`file`*`...`**`]`**\
> \
> `iconv -t`` `*`tocode`*` `**`[`**`-cs`**`] [`**`-f`` `*`fromcode`***`] [`***`file`*`...`**`]`**\
> \
> `iconv -l`\

#### <span id="tag_20_58_03"></span>DESCRIPTION

> The *iconv* utility shall convert the encoding of characters in *file* from one codeset to another and write the results to standard output.
>
> When the options indicate that charmap files are used to specify the codesets (see OPTIONS), the codeset conversion shall be accomplished by performing a logical join on the symbolic character names in the two charmaps. The implementation need not support the use of charmap files for codeset conversion unless the POSIX2_LOCALEDEF symbol is defined on the system.

#### <span id="tag_20_58_04"></span>OPTIONS

> The *iconv* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-c**
>
> Omit any characters that are invalid in the codeset of the input file from the output. When **-c** is not used, the results of encountering invalid characters in the input stream (either those that are not characters in the codeset of the input file or that have no corresponding character in the codeset of the output file) shall be specified in the system documentation. The presence or absence of **-c** shall not affect the exit status of *iconv*.
>
> **-f ***fromcodeset*
>
> \
> Identify the codeset of the input file. The implementation shall recognize the following two forms of the *fromcodeset* option-argument:
>
> *fromcode*
>
> The *fromcode* option-argument can not contain a \<slash\> character. It shall be interpreted as the name of one of the codeset descriptions provided by the implementation in an unspecified format. Valid values of *fromcode* are implementation-defined.
>
> *frommap*
>
> The *frommap* option-argument needs to contain a \<slash\> character. It shall be interpreted as the pathname of a charmap file as defined in XBD [*6.4 Character Set Description File*](../basedefs/V1_chap06.html#tag_06_04). If the pathname does not represent a valid, readable charmap file, the results are undefined.
>
> If this option is omitted, the codeset of the current locale shall be used.
>
> **-l**
>
> Write all supported *fromcode* and *tocode* values to standard output in an unspecified format.
>
> **-s**
>
> Suppress any messages written to standard error concerning invalid characters. When **-s** is not used, the results of encountering invalid characters in the input stream (either those that are not valid characters in the codeset of the input file or that have no corresponding character in the codeset of the output file) shall be specified in the system documentation. The presence or absence of **-s** shall not affect the exit status of *iconv*.
>
> **-t ***tocodeset*
>
> Identify the codeset to be used for the output file. The implementation shall recognize the following two forms of the *tocodeset* option-argument:
>
> *tocode*
>
> The semantics shall be equivalent to the **-f** *fromcode* option.
>
> *tomap*
>
> The semantics shall be equivalent to the **-f** *frommap* option.
>
> If this option is omitted, the codeset of the current locale shall be used.
>
> If either **-f** or **-t** represents a charmap file, but the other does not (or is omitted), or both **-f** and **-t** are omitted, the results are undefined.

#### <span id="tag_20_58_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an input file. If no *file* operands are specified, or if a *file* operand is `'-'`, the standard input shall be used.

#### <span id="tag_20_58_06"></span>STDIN

> The standard input shall be used only if no *file* operands are specified, or if a *file* operand is `'-'`.

#### <span id="tag_20_58_07"></span>INPUT FILES

> The input file shall be a text file.

#### <span id="tag_20_58_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *iconv*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments). During translation of the file, this variable is superseded by the use of the *fromcode* option-argument.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_58_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_58_10"></span>STDOUT

> When the **-l** option is used, the standard output shall contain all supported *fromcode* and *tocode* values, written in an unspecified format.
>
> When the **-l** option is not used, the standard output shall contain the sequence of characters read from the input files, translated to the specified codeset. Nothing else shall be written to the standard output.

#### <span id="tag_20_58_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_58_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_58_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_58_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_58_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_58_16"></span>APPLICATION USAGE

> The user must ensure that both charmap files use the same symbolic names for characters the two codesets have in common.

#### <span id="tag_20_58_17"></span>EXAMPLES

> The following example converts the contents of file **mail.x400** from the ISO/IEC 6937:2001 standard codeset to the ISO/IEC 8859-1:1998 standard codeset, and stores the results in file **mail.local**:
>
>
>     iconv -f IS6937 -t IS8859 mail.x400 > mail.local

#### <span id="tag_20_58_18"></span>RATIONALE

> The *iconv* utility can be used portably only when the user provides two charmap files as option-arguments. This is because a single charmap provided by the user cannot reliably be joined with the names in a system-provided character set description. The valid values for *fromcode* and *tocode* are implementation-defined and do not have to have any relation to the charmap mechanisms. As an aid to interactive users, the **-l** option was adopted from the Plan 9 operating system. It writes information concerning these implementation-defined values. The format is unspecified because there are many possible useful formats that could be chosen, such as a matrix of valid combinations of *fromcode* and *tocode*. The **-l** option is not intended for shell script usage; conforming applications will have to use charmaps.
>
> The *iconv* utility may support the conversion between ASCII and EBCDIC-based encodings, but is not required to do so. In an XSI-compliant implementation, the [*dd*](../utilities/dd.html) utility is the only method guaranteed to support conversion between these two character sets.

#### <span id="tag_20_58_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_58_20"></span>SEE ALSO

> [*dd*](../utilities/dd.html#), [*gencat*](../utilities/gencat.html#)
>
> XBD [*6.4 Character Set Description File*](../basedefs/V1_chap06.html#tag_06_04), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_58_21"></span>CHANGE HISTORY

> First released in Issue 3.

#### <span id="tag_20_58_22"></span>Issue 6

> This utility has been rewritten to align with the IEEE P1003.2b draft standard. Specifically, the ability to use charmap files for conversion has been added.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/29 is applied, making changes to address inconsistencies with the [*iconv*()](../functions/iconv.html) function in the System Interfaces volume of POSIX.1-2024.

#### <span id="tag_20_58_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#206 is applied, correcting the *tomap* option.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0094 \[291\] and XCU/TC1-2008/0095 \[291\] are applied.

#### <span id="tag_20_58_24"></span>Issue 8

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
