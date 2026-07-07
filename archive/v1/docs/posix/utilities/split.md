The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="split"></span> <span id="tag_20_113"></span>

#### <span id="tag_20_113_01"></span>NAME

> split — split a file into pieces

#### <span id="tag_20_113_02"></span>SYNOPSIS

> `split`` `**`[`**`-l`` `*`line_count`***`] [`**`-a`` `*`suffix_length`***`] [`***`file`*` `**`[`***`name`***`]]`**\
> \
> `split -b`` `*`n`***`[`**`k|m`**`] [`**`-a`` `*`suffix_length`***`] [`***`file`*` `**`[`***`name`***`]]`**\

#### <span id="tag_20_113_03"></span>DESCRIPTION

> The *split* utility shall read an input file and write zero or more output files. The default size of each output file shall be 1000 lines. The size of the output files can be modified by specification of the **-b** or **-l** options. Each output file shall be created with a unique suffix. The suffix shall consist of exactly *suffix_length* lowercase letters from the POSIX locale. The letters of the suffix shall be used as if they were a base-26 digit system, with the first suffix to be created consisting of all `'a'` characters, the second with a `'b'` replacing the last `'a'`, and so on, until a name of all `'z'` characters is created. By default, the names of the output files shall be `'x'`, followed by a two-character suffix from the character set as described above, starting with `"aa"`, `"ab"`, `"ac"`, and so on, and continuing until the suffix `"zz"`, for a maximum of 676 files.
>
> If the number of files required exceeds the maximum allowed by the suffix length provided, such that the last allowable file would be larger than the requested size, the *split* utility shall fail after creating the last file with a valid suffix; *split* shall not delete the files it created with valid suffixes. If the file limit is not exceeded, the last file created shall contain the remainder of the input file, and may be smaller than the requested size. If the input is an empty file, no output file shall be created and this shall not be considered to be an error.

#### <span id="tag_20_113_04"></span>OPTIONS

> The *split* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a ***suffix_length*
>
> \
> Use *suffix_length* letters to form the suffix portion of the filenames of the split file. If **-a** is not specified, the default suffix length shall be two. If the sum of the *name* operand and the *suffix_length* option-argument would create a filename exceeding {NAME_MAX} bytes, an error shall result; *split* shall exit with a diagnostic message and no files shall be created.
>
> **-b ***n*
>
> Split a file into pieces *n* bytes in size.
>
> **-b ***n***k**
>
> Split a file into pieces *n*\*1024 bytes in size.
>
> **-b ***n***m**
>
> Split a file into pieces *n*\*1048576 bytes in size.
>
> **-l ***line_count*
>
> Specify the number of lines in each resulting file piece. The *line_count* argument is an unsigned decimal integer. The default is 1000. If the input does not end with a \<newline\>, the partial line shall be included in the last output file.

#### <span id="tag_20_113_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file*
>
> The pathname of the ordinary file to be split. If no input file is given or *file* is `'-'`, the standard input shall be used.
>
> *name*
>
> The prefix to be used for each of the files resulting from the split operation. If no *name* argument is given, `'x'` shall be used as the prefix of the output files. The combined length of the basename of *prefix* and *suffix_length* cannot exceed {NAME_MAX} bytes. See the OPTIONS section.

#### <span id="tag_20_113_06"></span>STDIN

> See the INPUT FILES section.

#### <span id="tag_20_113_07"></span>INPUT FILES

> Any file can be used as input.

#### <span id="tag_20_113_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *split*:
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

#### <span id="tag_20_113_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_113_10"></span>STDOUT

> Not used.

#### <span id="tag_20_113_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_113_12"></span>OUTPUT FILES

> The output files contain portions of the original input file; otherwise, unchanged.

#### <span id="tag_20_113_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_113_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_113_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_113_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_113_17"></span>EXAMPLES

> In the following examples **foo** is a text file that contains 5000 lines.
>
> 1.  Create five files, **xaa**, **xab**, **xac**, **xad**, and **xae**:
>
>
>         split foo
>
> 2.  Create five files, but the suffixed portion of the created files consists of three letters, **xaaa**, **xaab**, **xaac**, **xaad**, and **xaae**:
>
>
>         split -a 3 foo
>
> 3.  Create three files with four-letter suffixes and a supplied prefix, **bar_aaaa**, **bar_aaab**, and **bar_aaac**:
>
>
>         split -a 4 -l 2000 foo bar_
>
> 4.  Create as many files as are necessary to contain at most 20\*1024 bytes, each with the default prefix of **x** and a five-letter suffix:
>
>
>         split -a 5 -b 20k foo

#### <span id="tag_20_113_18"></span>RATIONALE

> The **-b** option was added to provide a mechanism for splitting files other than by lines. While most uses of the **-b** option are for transmitting files over networks, some believed it would have additional uses.
>
> The **-a** option was added to overcome the limitation of being able to create only 676 files.
>
> Consideration was given to deleting this utility, using the rationale that the functionality provided by this utility is available via the [*csplit*](../utilities/csplit.html) utility (see [*csplit*](../utilities/csplit.html#)). Upon reconsideration of the purpose of the User Portability Utilities option, it was decided to retain both this utility and the [*csplit*](../utilities/csplit.html) utility because users use both utilities and have historical expectations of their behavior. Furthermore, the splitting on byte boundaries in *split* cannot be duplicated with the historical [*csplit*](../utilities/csplit.html).
>
> The text "[*split*](../utilities/split.html) shall not delete the files it created with valid suffixes" would normally be assumed, but since the related utility, [*csplit*](../utilities/csplit.html), does delete files under some circumstances, the historical behavior of *split* is made explicit to avoid misinterpretation.
>
> Earlier versions of this standard allowed a **-***line_count* option. This form is no longer specified by POSIX.1-2024 but may be present in some implementations.

#### <span id="tag_20_113_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_113_20"></span>SEE ALSO

> [*csplit*](../utilities/csplit.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_113_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_113_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The APPLICATION USAGE section is added.
>
> The obsolescent SYNOPSIS is removed.

#### <span id="tag_20_113_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied.
>
> The *split* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0188 \[731\] is applied.

#### <span id="tag_20_113_24"></span>Issue 8

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
