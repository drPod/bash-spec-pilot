The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="du"></span> <span id="tag_20_36"></span>

#### <span id="tag_20_36_01"></span>NAME

> du — estimate file space usage

#### <span id="tag_20_36_02"></span>SYNOPSIS

> `du`` `**`[`**`-a|-s`**`] [`**`-kx`**`] [`**`-H|-L`**`] [`***`file`*`...`**`]`**

#### <span id="tag_20_36_03"></span>DESCRIPTION

> By default, the *du* utility shall write to standard output the size of the file space allocated to, and the size of the file space allocated to each subdirectory of, the file hierarchy rooted in each of the specified files. By default, when a symbolic link is encountered on the command line or in the file hierarchy, *du* shall count the size of the symbolic link (rather than the file referenced by the link), and shall not follow the link to another portion of the file hierarchy. The size of the file space allocated to a file of type directory shall be defined as the sum total of space allocated to all files in the file hierarchy rooted in the directory plus the space allocated to the directory itself.
>
> When *du* cannot [*stat*()](../functions/stat.html) files or [*stat*()](../functions/stat.html) or read directories, it shall report an error condition and the final exit status is affected. A file that occurs multiple times shall be counted and written for only one entry, even if the occurrences are under different file operands. The directory entry that is selected in the report is unspecified. By default, file sizes shall be written in 512-byte units, rounded up to the next 512-byte unit.

#### <span id="tag_20_36_04"></span>OPTIONS

> The *du* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a**
>
> In addition to the default output, report the size of each file not of type directory in the file hierarchy rooted in the specified file. The **-a** option shall not affect whether non-directories given as *file* operands are listed.
>
> **-H**
>
> If a symbolic link is specified on the command line, *du* shall count the size of the file or file hierarchy referenced by the link.
>
> **-k**
>
> Write the files sizes in units of 1024 bytes, rather than the default 512-byte units.
>
> **-L**
>
> If a symbolic link is specified on the command line or encountered during the traversal of a file hierarchy, *du* shall count the size of the file or file hierarchy referenced by the link.
>
> **-s**
>
> Instead of the default output, report only the total sum for each of the specified files.
>
> **-x**
>
> When evaluating file sizes, evaluate only those files that have the same device as the file specified by the *file* operand.
>
> Specifying more than one of the mutually-exclusive options **-H** and **-L** shall not be considered an error. The last option specified shall determine the behavior of the utility.

#### <span id="tag_20_36_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> The pathname of a file whose size is to be written. If no *file* is specified, the current directory shall be used.

#### <span id="tag_20_36_06"></span>STDIN

> Not used.

#### <span id="tag_20_36_07"></span>INPUT FILES

> None.

#### <span id="tag_20_36_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *du*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_36_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_36_10"></span>STDOUT

> The output from *du* shall consist of the amount of space allocated to a file and the name of the file, in the following format:
>
>
>     "%d %s\n", <size>, <pathname>

#### <span id="tag_20_36_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_36_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_36_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_36_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_36_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_36_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_36_17"></span>EXAMPLES

> None.

#### <span id="tag_20_36_18"></span>RATIONALE

> The use of 512-byte units is historical practice and maintains compatibility with [*ls*](../utilities/ls.html) and other utilities in this volume of POSIX.1-2024. This does not mandate that the file system itself be based on 512-byte blocks. The **-k** option was added as a compromise measure. It was agreed by the standard developers that 512 bytes was the best default unit because of its complete historical consistency on System V (*versus* the mixed 512/1024-byte usage on BSD systems), and that a **-k** option to switch to 1024-byte units was a good compromise. Users who prefer the 1024-byte quantity can easily alias *du* to *du* **-k** without breaking the many historical scripts relying on the 512-byte units.
>
> The **-b** option was added to an early proposal to provide a resolution to the situation where System V and BSD systems give figures for file sizes in *blocks*, which is an implementation-defined concept. (In common usage, the block size is 512 bytes for System V and 1024 bytes for BSD systems.) However, **-b** was later deleted, since the default was eventually decided as 512-byte units.
>
> Historical file systems provided no way to obtain exact figures for the space allocation given to files. There are two known areas of inaccuracies in historical file systems: cases of *indirect blocks* being used by the file system or *sparse* files yielding incorrectly high values. An indirect block is space used by the file system in the storage of the file, but that need not be counted in the space allocated to the file. A *sparse* file is one in which an [*lseek*()](../functions/lseek.html) call has been made to a position beyond the end of the file and data has subsequently been written at that point. A file system need not allocate all the intervening zero-filled blocks to such a file. It is up to the implementation to define exactly how accurate its methods are.
>
> The **-a** and **-s** options were mutually-exclusive in the original version of *du*. The POSIX Shell and Utilities description is implied by the language in the SVID where **-s** is described as causing "only the grand total" to be reported. Some systems may produce output for **-sa**, but a Strictly Conforming POSIX Shell and Utilities Application cannot use that combination.
>
> The **-a** and **-s** options were adopted from the SVID except that the System V behavior of not listing non-directories explicitly given as operands, unless the **-a** option is specified, was considered a bug; the BSD-based behavior (report for all operands) is mandated. The default behavior of *du* in the SVID with regard to reporting the failure to read files (it produces no messages) was considered counter-intuitive, and thus it was specified that the POSIX Shell and Utilities default behavior shall be to produce such messages. These messages can be turned off with shell redirection to achieve the System V behavior.
>
> The **-x** option is historical practice on recent BSD systems. It has been adopted by this volume of POSIX.1-2024 because there was no other historical method of limiting the *du* search to a single file hierarchy. This limitation of the search is necessary to make it possible to obtain file space usage information about a file system on which other file systems are mounted, without having to resort to a lengthy [*find*](../utilities/find.html) and [*awk*](../utilities/awk.html) script.
>
> The use of the **-L** option, or of multiple *file* operands, requires that *du* track all file entries encountered, even with a link count of one. However, when **-L** is not used and only a single *file* operand is given, an implementation can optimize by only tracking files with a link count greater than one, since in that scenario, those are the only files that could be encountered more than once.

#### <span id="tag_20_36_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_36_20"></span>SEE ALSO

> [*ls*](../utilities/ls.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*fstatat*()](../functions/fstatat.html#)

#### <span id="tag_20_36_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_36_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The APPLICATION USAGE section is added.
>
> The obsolescent **-r** option is removed.
>
> The Open Group Corrigendum U025/3 is applied. The *du* utility is reinstated, as it had incorrectly been marked LEGACY in Issue 5.
>
> The **-H** and **-L** options for symbolic links are added as described in the IEEE P1003.2b draft standard.

#### <span id="tag_20_36_23"></span>Issue 7

> The *du* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0089 \[527\] is applied.

#### <span id="tag_20_36_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 539 is applied, requiring a file that occurs multiple times to be counted and written for only one entry.
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
