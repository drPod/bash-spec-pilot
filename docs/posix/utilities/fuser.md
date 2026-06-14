The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="fuser"></span> <span id="tag_20_49"></span>

#### <span id="tag_20_49_01"></span>NAME

> fuser — list process IDs of all processes that are using one or more named files

#### <span id="tag_20_49_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` fuser`` `**`[`**`-cfu`**`]`**` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_49_03"></span>DESCRIPTION

> For each *file* operand, in order, *fuser* shall write one line of output, some of it to standard output, and the rest to standard error, giving information about processes running on the local system that are using the file. A process shall be considered to be using a file if it has at least one open file descriptor associated with the file or if the file is a directory that is the current working directory or the root directory for the process, and may be considered to be using a file for other implementation-dependent reasons. If *file* names a block special device that contains a mounted file system, and the **-f** option is not specified, any processes using any file on that mounted file system and any processes that are using the device file itself shall be listed.
>
> Any output for processes running on remote systems that are using a named file is unspecified.
>
> A user may need appropriate privileges to invoke the *fuser* utility.
>
> When standard output and standard error are directed to the same file, the output for each *file* operand shall be interleaved so that it is written to the file in the following order:
>
> - On standard error, a pathname for the file, immediately followed by a \<colon\> and zero or more \<blank\> characters. The pathname shall be either the file operand (unaltered) or the pathname that would result from a successful call to the [*realpath*()](../functions/realpath.html) function, defined in the System Interfaces volume of POSIX.1-2024, with the *file* operand as its *file_name* argument.
>
> - For each process using the file:
>
>   - On standard output, the process ID in the format:
>
>
>         " %1d", <process ID>
>
>   - On standard error, information about the file's use by the process, in the following format:
>
>
>         "%s", <use chars>
>
>     if the **-u** option is not specified, or in the following format:
>
>
>         "%s(%s)", <use chars>, <user name>
>
>     if the **-u** option is specified, where \<*use chars*\> is a string of zero or more characters indicating the use of the file and \<*user name*\> is the user name corresponding to the real user ID of the process or, if the user name cannot be resolved from the real user ID of the process, the real user ID of the process in decimal. The value of \<*use chars*\> shall include the character `'c'` if the process is using the file as its current directory and the character `'r'` if the process is using the file as its root directory; implementations may include other alphabetic characters to indicate other uses of the file.
>
> - On standard error, a \<newline\> character.
>
> When standard output and standard error are not directed to the same file, the data written to each shall be as described above but the ordering of writes to standard output relative to writes to standard error is unspecified. For example, *fuser* might first write the information for all file operands to standard error and then write all of the process IDs to standard output.

#### <span id="tag_20_49_04"></span>OPTIONS

> The *fuser* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-c**
>
> If a *file* operand names a directory that is the mount point of a mounted file system, all processes using any file on that file system shall be listed as if they were using the named directory. The behavior for any *file* operand that names an existing file that is not the mount point of a mounted file system is unspecified.
>
> **-f**
>
> The report shall be only for the named files.
>
> **-u**
>
> The user name, in parentheses, associated with each process ID written to standard output shall be written to standard error.

#### <span id="tag_20_49_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a file for which the processes using the file are to be reported.

#### <span id="tag_20_49_06"></span>STDIN

> Not used.

#### <span id="tag_20_49_07"></span>INPUT FILES

> The user database.

#### <span id="tag_20_49_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *fuser*:
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
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_49_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_49_10"></span>STDOUT

> See DESCRIPTION.

#### <span id="tag_20_49_11"></span>STDERR

> The *fuser* utility shall write diagnostic messages to standard error.
>
> The *fuser* utility also shall write information to standard error as specified in the DESCRIPTION section.

#### <span id="tag_20_49_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_49_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_49_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_49_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_49_16"></span>APPLICATION USAGE

> Things can change while *fuser* is running; the snapshot it gives is only true for an instant, and might not be accurate by the time it is displayed.

#### <span id="tag_20_49_17"></span>EXAMPLES

> The command:
>
>
>     fuser -fu .
>
> writes to standard output the process IDs of processes that are using the current directory and writes to standard error an indication of how those processes are using the directory and the user names associated with the processes that are using the current directory.
>
>
>     fuser -c <mount point>
>
> writes to standard output the process IDs of processes that are using any file in the file system which is mounted on \<*mount point*\> and writes to standard error an indication of how those processes are using the files.
>
>
>     fuser <mount point>
>
> writes to standard output the process IDs of processes that are using the file which is named by \<*mount point*\> and writes to standard error an indication of how those processes are using the file.
>
>
>     fuser <mounted block device>
>
> writes to standard output the process IDs of processes that are using any file on the mounted file system contained by \<*mounted block device*\> and of processes that are using the device file \<*mounted block device*\> itself, and writes to standard error an indication of how those processes are using the files.
>
>
>     fuser -f <mounted block device>
>
> writes to standard output the process IDs of processes that are using the file \<*mounted block device*\> itself and writes to standard error an indication of how those processes are using the file.

#### <span id="tag_20_49_18"></span>RATIONALE

> The definition of the *fuser* utility follows existing practice.

#### <span id="tag_20_49_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_49_20"></span>SEE ALSO

> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_49_21"></span>CHANGE HISTORY

> First released in Issue 5.

#### <span id="tag_20_49_22"></span>Issue 7

> SD5-XCU-ERN-90 is applied, updating the EXAMPLES section.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_49_23"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1746 is applied, clarifying the output written to standard output and standard error.

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
