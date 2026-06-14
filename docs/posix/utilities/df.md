The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="df"></span> <span id="tag_20_33"></span>

#### <span id="tag_20_33_01"></span>NAME

> df — report free disk space

#### <span id="tag_20_33_02"></span>SYNOPSIS

> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` df`` `**`[`**`-k`**`] [`**`-P|`<img src="../images/opt-start.gif" data-border="0" />`-t`**<img src="../images/opt-end.gif" data-border="0" />`] [`***`file`*`...`**`]`**

#### <span id="tag_20_33_03"></span>DESCRIPTION

> The *df* utility shall write the amount of available space <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  and file slots <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> for file systems on which the invoking user has appropriate read access. File systems shall be specified by the *file* operands; when none are specified, information shall be written for all file systems. The format of the default output from *df* is unspecified, but all space figures are reported in 512-byte units, unless the **-k** option is specified. This output shall contain at least the file system names, amount of available space on each of these file systems, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  and, if no options other than **-t** are specified, the number of free file slots, or *inode*s, available; when **-t** is specified, the output shall contain the total allocated space as well. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_33_04"></span>OPTIONS

> The *df* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-k**
>
> Use 1024-byte units, instead of the default 512-byte units, when writing space figures.
>
> **-P**
>
> Produce output in the format described in the STDOUT section.
>
> **-t**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Include total allocated-space figures in the output. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_33_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a file within the hierarchy of the desired file system. If a file other than a FIFO, a regular file, a directory, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  or a special file representing the device containing the file system (for example, **/dev/dsk/0s1**) <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> is specified, the results are unspecified. If the *file* operand names a file other than a special file containing a file system, *df* shall write the amount of free space in the file system containing the specified *file* operand. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  Otherwise, *df* shall write the amount of free space in that file system. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_33_06"></span>STDIN

> Not used.

#### <span id="tag_20_33_07"></span>INPUT FILES

> None.

#### <span id="tag_20_33_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *df*:
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

#### <span id="tag_20_33_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_33_10"></span>STDOUT

> When both the **-k** and **-P** options are specified, the following header line shall be written (in the POSIX locale):
>
>
>     "Filesystem 1024-blocks Used Available Capacity Mounted on\n"
>
> When the **-P** option is specified without the **-k** option, the following header line shall be written (in the POSIX locale):
>
>
>     "Filesystem 512-blocks Used Available Capacity Mounted on\n"
>
> The implementation may adjust the spacing of the header line and the individual data lines so that the information is presented in orderly columns.
>
> The remaining output with **-P** shall consist of one line of information for each specified file system. These lines shall be formatted as follows:
>
>
>     "%s %d %d %d %d%% %s\n", <file system name>, <total space>,
>         <space used>, <space free>, <percentage used>,
>         <file system root>
>
> In the following list, all quantities expressed in 512-byte units (1024-byte when **-k** is specified) shall be rounded up to the next higher unit. The fields are:
>
> \<*file system name*\>
>
> \
> The name of the file system, in an implementation-defined format.
>
> \<*total space*\>
>
> The total size of the file system in 512-byte units. The exact meaning of this figure is implementation-defined, but should include \<*space used*\>, \<*space free*\>, plus any space reserved by the system not normally available to a user.
>
> \<*space used*\>
>
> The total amount of space allocated to existing files in the file system, in 512-byte units.
>
> \<*space free*\>
>
> The total amount of space available within the file system for the creation of new files by unprivileged users, in 512-byte units. When this figure is less than or equal to zero, it shall not be possible to create any new files on the file system without first deleting others, unless the process has appropriate privileges. The figure written may be less than zero.
>
> \<*percentage used*\>
>
> \
> The percentage of the normally available space that is currently allocated to all files on the file system. This shall be calculated using the fraction:
>
>
>     <space used>/( <space used>+ <space free>)
>
> expressed as a percentage. This percentage may be greater than 100 if \<*space free*\> is less than zero. The percentage value shall be expressed as a positive integer, with any fractional result causing it to be rounded to the next highest integer.
>
> \<*file system root*\>
>
> \
> The directory below which the file system hierarchy appears.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The output format is unspecified when **-t** is used. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_33_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_33_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_33_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_33_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_33_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_33_16"></span>APPLICATION USAGE

> On most systems, the "name of the file system, in an implementation-defined format" is the special file on which the file system is mounted.
>
> On large file systems, the calculation specified for percentage used can create huge rounding errors.

#### <span id="tag_20_33_17"></span>EXAMPLES

> 1.  The following example writes portable information about the **/usr** file system:
>
>
>         df -P /usr
>
> 2.  Assuming that **/usr/src** is part of the **/usr** file system, the following produces the same output as the previous example:
>
>
>         df -P /usr/src

#### <span id="tag_20_33_18"></span>RATIONALE

> The behavior of *df* with the **-P** option is the default action of the 4.2 BSD *df* utility. The uppercase **-P** was selected to avoid collision with a known industry extension using **-p**.
>
> Historical *df* implementations vary considerably in their default output. It was therefore necessary to describe the default output in a loose manner to accommodate all known historical implementations and to add a portable option (**-P**) to provide information in a portable format.
>
> The use of 512-byte units is historical practice and maintains compatibility with [*ls*](../utilities/ls.html) and other utilities in this volume of POSIX.1-2024. This does not mandate that the file system itself be based on 512-byte blocks. The **-k** option was added as a compromise measure. It was agreed by the standard developers that 512 bytes was the best default unit because of its complete historical consistency on System V (*versus* the mixed 512/1024-byte usage on BSD systems), and that a **-k** option to switch to 1024-byte units was a good compromise. Users who prefer the more logical 1024-byte quantity can easily alias *df* to *df* **-k** without breaking many historical scripts relying on the 512-byte units.
>
> It was suggested that *df* and the various related utilities be modified to access a *BLOCKSIZE* environment variable to achieve consistency and user acceptance. Since this is not historical practice on any system, it is left as a possible area for system extensions and will be re-evaluated in a future version if it is widely implemented.

#### <span id="tag_20_33_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_33_20"></span>SEE ALSO

> [*find*](../utilities/find.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_33_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_33_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.

#### <span id="tag_20_33_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#099 is applied.
>
> The *df* utility is removed from the User Portability Utilities option. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0082 \[156\] is applied.

#### <span id="tag_20_33_24"></span>Issue 8

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
