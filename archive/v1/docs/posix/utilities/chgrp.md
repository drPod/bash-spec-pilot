The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="chgrp"></span> <span id="tag_20_16"></span>

#### <span id="tag_20_16_01"></span>NAME

> chgrp — change the file group ownership

#### <span id="tag_20_16_02"></span>SYNOPSIS

> `chgrp`` `**`[`**`-h`**`]`**` `*`group file`*`...`\
> \
> `chgrp -R`` `**`[`**`-H|-L|-P`**`]`**` `*`group file`*`...`\

#### <span id="tag_20_16_03"></span>DESCRIPTION

> The *chgrp* utility shall set the group ID of the file named by each *file* operand to the group ID specified by the *group* operand.
>
> For each *file* operand, or, if the **-R** option is used, each file encountered while walking the directory trees specified by the *file* operands, the *chgrp* utility shall perform actions equivalent to the [*chown*()](../functions/chown.html) function defined in the System Interfaces volume of POSIX.1-2024, called with the following arguments:
>
> - The *file* operand shall be used as the *path* argument.
>
> - The user ID of the file shall be used as the *owner* argument.
>
> - The specified group ID shall be used as the *group* argument.
>
> Unless *chgrp* is invoked by a process with appropriate privileges, the set-user-ID and set-group-ID bits of a regular file shall be cleared upon successful completion; the set-user-ID and set-group-ID bits of other file types may be cleared.

#### <span id="tag_20_16_04"></span>OPTIONS

> The *chgrp* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported by the implementation:
>
> **-h**
>
> For each *file* operand that names a file of type symbolic link, *chgrp* shall attempt to set the group ID of the symbolic link instead of the file referenced by the symbolic link.
>
> **-H**
>
> If the **-R** option is specified and a symbolic link referencing a file of type directory is specified on the command line, *chgrp* shall change the group of the directory referenced by the symbolic link and all files in the file hierarchy below it.
>
> **-L**
>
> If the **-R** option is specified and a symbolic link referencing a file of type directory is specified on the command line or encountered during the traversal of a file hierarchy, *chgrp* shall change the group of the directory referenced by the symbolic link and all files in the file hierarchy below it.
>
> **-P**
>
> If the **-R** option is specified and a symbolic link is specified on the command line or encountered during the traversal of a file hierarchy, *chgrp* shall change the group ID of the symbolic link. The *chgrp* utility shall not follow the symbolic link to any other part of the file hierarchy.
>
> **-R**
>
> Recursively change file group IDs. For each *file* operand that names a directory, *chgrp* shall change the group of the directory and all files in the file hierarchy below it. Unless a **-H**, **-L**, or **-P** option is specified, it is unspecified which of these options will be used as the default.
>
> Specifying more than one of the mutually-exclusive options **-H**, **-L**, and **-P** shall not be considered an error. The last option specified shall determine the behavior of the utility.

#### <span id="tag_20_16_05"></span>OPERANDS

> The following operands shall be supported:
>
> *group*
>
> A group name from the group database or a numeric group ID. Either specifies a group ID to be given to each file named by one of the *file* operands. If a numeric *group* operand exists in the group database as a group name, the group ID number associated with that group name is used as the group ID.
>
> *file*
>
> A pathname of a file whose group ID is to be modified.

#### <span id="tag_20_16_06"></span>STDIN

> Not used.

#### <span id="tag_20_16_07"></span>INPUT FILES

> None.

#### <span id="tag_20_16_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *chgrp*:
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

#### <span id="tag_20_16_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_16_10"></span>STDOUT

> Not used.

#### <span id="tag_20_16_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_16_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_16_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_16_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The utility executed successfully and all requested changes were made.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_16_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_16_16"></span>APPLICATION USAGE

> Only the owner of a file or the user with appropriate privileges may change the owner or group of a file.
>
> Some implementations restrict the use of *chgrp* to a user with appropriate privileges when the *group* specified is not the effective group ID or one of the supplementary group IDs of the calling process.

#### <span id="tag_20_16_17"></span>EXAMPLES

> None.

#### <span id="tag_20_16_18"></span>RATIONALE

> The System V and BSD versions use different exit status codes. Some implementations used the exit status as a count of the number of errors that occurred; this practice is unworkable since it can overflow the range of valid exit status values. The standard developers chose to mask these by specifying only 0 and \>0 as exit values.
>
> The functionality of *chgrp* is described substantially through references to [*chown*()](../functions/chown.html). In this way, there is no duplication of effort required for describing the interactions of permissions, multiple groups, and so on.

#### <span id="tag_20_16_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_16_20"></span>SEE ALSO

> [*chmod*](../utilities/chmod.html#tag_20_17), [*chown*](../utilities/chown.html#tag_20_18)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*chown*()](../functions/chown.html#tag_17_73)

#### <span id="tag_20_16_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_16_22"></span>Issue 6

> New options **-H**, **-L**, and **-P** are added to align with the IEEE P1003.2b draft standard. These options affect the processing of symbolic links.
>
> IEEE PASC Interpretation 1003.2 \#172 is applied, changing the CONSEQUENCES OF ERRORS section to "Default.".
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/15 is applied, changing the SYNOPSIS to make it clear that **-h** and **-R** are optional.

#### <span id="tag_20_16_23"></span>Issue 7

> SD5-XCU-ERN-8 is applied, removing the **-R** from the first line of the SYNOPSIS.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0080 \[237,341\] is applied.

#### <span id="tag_20_16_24"></span>Issue 8

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
