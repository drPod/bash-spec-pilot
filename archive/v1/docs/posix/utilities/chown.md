The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="chown"></span> <span id="tag_20_18"></span>

#### <span id="tag_20_18_01"></span>NAME

> chown — change the file ownership

#### <span id="tag_20_18_02"></span>SYNOPSIS

> `chown`` `**`[`**`-h`**`]`**` `*`owner`***`[`**`:`*`group`***`]`**` `*`file`*`...`\
> \
> `chown -R`` `**`[`**`-H|-L|-P`**`]`**` `*`owner`***`[`**`:`*`group`***`]`**` `*`file`*`...`\

#### <span id="tag_20_18_03"></span>DESCRIPTION

> The *chown* utility shall set the user ID of the file named by each *file* operand to the user ID specified by the *owner* operand.
>
> For each *file* operand, or, if the **-R** option is used, each file encountered while walking the directory trees specified by the *file* operands, the *chown* utility shall perform actions equivalent to the [*chown*()](../functions/chown.html) function defined in the System Interfaces volume of POSIX.1-2024, called with the following arguments:
>
> 1.  The *file* operand shall be used as the *path* argument.
>
> 2.  The user ID indicated by the *owner* portion of the first operand shall be used as the *owner* argument.
>
> 3.  If the *group* portion of the first operand is given, the group ID indicated by it shall be used as the *group* argument; otherwise, the group ownership shall not be changed.
>
> Unless *chown* is invoked by a process with appropriate privileges, the set-user-ID and set-group-ID bits of a regular file shall be cleared upon successful completion; the set-user-ID and set-group-ID bits of other file types may be cleared.

#### <span id="tag_20_18_04"></span>OPTIONS

> The *chown* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported by the implementation:
>
> **-h**
>
> For each file operand that names a file of type symbolic link, *chown* shall attempt to set the user ID of the symbolic link. If a group ID was specified, for each file operand that names a file of type symbolic link, *chown* shall attempt to set the group ID of the symbolic link.
>
> **-H**
>
> If the **-R** option is specified and a symbolic link referencing a file of type directory is specified on the command line, *chown* shall change the user ID (and group ID, if specified) of the directory referenced by the symbolic link and all files in the file hierarchy below it.
>
> **-L**
>
> If the **-R** option is specified and a symbolic link referencing a file of type directory is specified on the command line or encountered during the traversal of a file hierarchy, *chown* shall change the user ID (and group ID, if specified) of the directory referenced by the symbolic link and all files in the file hierarchy below it.
>
> **-P**
>
> If the **-R** option is specified and a symbolic link is specified on the command line or encountered during the traversal of a file hierarchy, *chown* shall change the owner ID (and group ID, if specified) of the symbolic link. The *chown* utility shall not follow the symbolic link to any other part of the file hierarchy.
>
> **-R**
>
> Recursively change file user and group IDs. For each *file* operand that names a directory, *chown* shall change the user ID (and group ID, if specified) of the directory and all files in the file hierarchy below it. Unless a **-H**, **-L**, or **-P** option is specified, it is unspecified which of these options will be used as the default.
>
> Specifying more than one of the mutually-exclusive options **-H**, **-L**, and **-P** shall not be considered an error. The last option specified shall determine the behavior of the utility.

#### <span id="tag_20_18_05"></span>OPERANDS

> The following operands shall be supported:
>
> *owner***\[**:*group***\]**
>
> A user ID and optional group ID to be assigned to *file*. The *owner* portion of this operand shall be a user name from the user database or a numeric user ID. Either specifies a user ID which shall be given to each file named by one of the *file* operands. If a numeric *owner* operand exists in the user database as a user name, the user ID number associated with that user name shall be used as the user ID. Similarly, if the *group* portion of this operand is present, it shall be a group name from the group database or a numeric group ID. Either specifies a group ID which shall be given to each file. If a numeric group operand exists in the group database as a group name, the group ID number associated with that group name shall be used as the group ID.
>
> *file*
>
> A pathname of a file whose user ID is to be modified.

#### <span id="tag_20_18_06"></span>STDIN

> Not used.

#### <span id="tag_20_18_07"></span>INPUT FILES

> None.

#### <span id="tag_20_18_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *chown*:
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

#### <span id="tag_20_18_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_18_10"></span>STDOUT

> Not used.

#### <span id="tag_20_18_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_18_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_18_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_18_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The utility executed successfully and all requested changes were made.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_18_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_18_16"></span>APPLICATION USAGE

> Only the owner of a file or the user with appropriate privileges may change the owner or group of a file.
>
> Some implementations restrict the use of *chown* to a user with appropriate privileges.

#### <span id="tag_20_18_17"></span>EXAMPLES

> None.

#### <span id="tag_20_18_18"></span>RATIONALE

> The System V and BSD versions use different exit status codes. Some implementations used the exit status as a count of the number of errors that occurred; this practice is unworkable since it can overflow the range of valid exit status values. These are masked by specifying only 0 and \>0 as exit values.
>
> The functionality of *chown* is described substantially through references to functions in the System Interfaces volume of POSIX.1-2024. In this way, there is no duplication of effort required for describing the interactions of permissions, multiple groups, and so on.
>
> The 4.3 BSD method of specifying both owner and group was included in this volume of POSIX.1-2024 because:
>
> - There are cases where the desired end condition could not be achieved using the [*chgrp*](../utilities/chgrp.html) and *chown* (that only changed the user ID) utilities. (If the current owner is not a member of the desired group and the desired owner is not a member of the current group, the [*chown*()](../functions/chown.html) function could fail unless both owner and group are changed at the same time.)
>
> - Even if they could be changed independently, in cases where both are being changed, there is a 100% performance penalty caused by being forced to invoke both utilities.
>
> The BSD syntax *user*\[.*group*\] was changed to *user*\[:*group*\] in this volume of POSIX.1-2024 because the \<period\> is a valid character in login names (as specified by the Base Definitions volume of POSIX.1-2024, login names consist of characters in the portable filename character set). The \<colon\> character was chosen as the replacement for the \<period\> character because it would never be allowed as a character in a user name or group name on historical implementations.
>
> The **-R** option is considered by some observers as an undesirable departure from the historical UNIX system tools approach; since a tool, [*find*](../utilities/find.html), already exists to recurse over directories, there seemed to be no good reason to require other tools to have to duplicate that functionality. However, the **-R** option was deemed an important user convenience, is far more efficient than forking a separate process for each element of the directory hierarchy, and is in widespread historical use.

#### <span id="tag_20_18_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_18_20"></span>SEE ALSO

> [*chgrp*](../utilities/chgrp.html#), [*chmod*](../utilities/chmod.html#tag_20_17)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*chown*()](../functions/chown.html#tag_17_73)

#### <span id="tag_20_18_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_18_22"></span>Issue 6

> New options **-h**, **-H**, **-L**, and **-P** are added to align with the IEEE P1003.2b draft standard. These options affect the processing of symbolic links.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> IEEE PASC Interpretation 1003.2 \#172 is applied, changing the CONSEQUENCES OF ERRORS section to "Default.".
>
> The "otherwise, ..." text in item 3. of the DESCRIPTION is changed to "otherwise, the group ownership shall not be changed".
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/17 is applied, changing the SYNOPSIS to make it clear that **-h** and **-R** are optional.

#### <span id="tag_20_18_23"></span>Issue 7

> SD5-XCU-ERN-9 is applied, removing the **-R** from the first line of the SYNOPSIS.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The description of the **-h** and **-P** options is revised.

#### <span id="tag_20_18_24"></span>Issue 8

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
