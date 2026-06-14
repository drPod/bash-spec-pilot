The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="newgrp"></span> <span id="tag_20_84"></span>

#### <span id="tag_20_84_01"></span>NAME

> newgrp — change to a new group

#### <span id="tag_20_84_02"></span>SYNOPSIS

> `newgrp`` `**`[`**`-l`**`] [`***`group`***`]`**

#### <span id="tag_20_84_03"></span>DESCRIPTION

> The *newgrp* utility shall create a new shell execution environment with a new real and effective group identification. Of the attributes listed in [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13), the new shell execution environment shall retain the working directory, file creation mask, and exported variables from the previous environment (that is, open files, traps, unexported variables, alias definitions, shell functions, and [*set*](../utilities/V3_chap02.html#set) options may be lost). All other aspects of the process environment that are preserved by the *exec* family of functions defined in the System Interfaces volume of POSIX.1-2024 shall also be preserved by *newgrp*; whether other aspects are preserved is unspecified.
>
> A failure to assign the new group identifications (for example, for security or password-related reasons) shall not prevent the new shell execution environment from being created.
>
> The *newgrp* utility shall affect the supplemental groups for the process as follows:
>
> - On systems where the effective group ID is normally in the supplementary group list (or whenever the old effective group ID actually is in the supplementary group list):
>
>   - If the new effective group ID is also in the supplementary group list, *newgrp* shall change the effective group ID.
>
>   - If the new effective group ID is not in the supplementary group list, *newgrp* shall add the new effective group ID to the list, if there is room to add it.
>
> - On systems where the effective group ID is not normally in the supplementary group list (or whenever the old effective group ID is not in the supplementary group list):
>
>   - If the new effective group ID is in the supplementary group list, *newgrp* shall delete it.
>
>   - If the old effective group ID is not in the supplementary list, *newgrp* shall add it if there is room.
>
> **Note:**  
> The System Interfaces volume of POSIX.1-2024 does not specify whether the effective group ID of a process is included in its supplementary group list.
>
> With no operands, *newgrp* shall change the effective group back to the groups identified in the user's user entry, and shall set the list of supplementary groups to that set in the user's group database entries.
>
> If the first argument is `'-'`, the results are unspecified.
>
> If a password is required for the specified group, and the user is not listed as a member of that group in the group database, the user shall be prompted to enter the correct password for that group. If the user is listed as a member of that group, no password shall be requested. If no password is required for the specified group, it is implementation-defined whether users not listed as members of that group can change to that group. Whether or not a password is required, implementation-defined system accounting or security mechanisms may impose additional authorization restrictions that may cause *newgrp* to write a diagnostic message and suppress the changing of the group identification.

#### <span id="tag_20_84_04"></span>OPTIONS

> The *newgrp* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except for the unspecified usage of `'-'`.
>
> The following option shall be supported:
>
> **-l**
>
> (The letter ell.) Change the environment to what would be expected if the user actually logged in again.

#### <span id="tag_20_84_05"></span>OPERANDS

> The following operand shall be supported:
>
> *group*
>
> A group name from the group database or a non-negative numeric group ID. Specifies the group ID to which the real and effective group IDs shall be set. If *group* is a non-negative numeric string and exists in the group database as a group name (see [*getgrnam*()](../functions/getgrnam.html)), the numeric group ID associated with that group name shall be used as the group ID.

#### <span id="tag_20_84_06"></span>STDIN

> Not used.

#### <span id="tag_20_84_07"></span>INPUT FILES

> The file **/dev/tty** shall be used to read a single line of text for password checking, when one is required.

#### <span id="tag_20_84_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *newgrp*:
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

#### <span id="tag_20_84_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_84_10"></span>STDOUT

> Not used.

#### <span id="tag_20_84_11"></span>STDERR

> The standard error shall be used for diagnostic messages and a prompt string for a password, if one is required. Diagnostic messages may be written in cases where the exit status is not available. See the EXIT STATUS section.

#### <span id="tag_20_84_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_84_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_84_14"></span>EXIT STATUS

> If *newgrp* succeeds in creating a new shell execution environment, whether or not the group identification was changed successfully, the exit status shall be the exit status of the shell. Otherwise, the following exit value shall be returned:
>
> \>0
>
> An error occurred.

#### <span id="tag_20_84_15"></span>CONSEQUENCES OF ERRORS

> The invoking shell may terminate.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_84_16"></span>APPLICATION USAGE

> There is no convenient way to enter a password into the group database. Use of group passwords is not encouraged, because by their very nature they encourage poor security practices. Group passwords may disappear in the future.
>
> A common implementation of *newgrp* is that the current shell uses *exec* to overlay itself with *newgrp*, which in turn overlays itself with a new shell after changing group. On some implementations, however, this may not occur and *newgrp* may be invoked as a subprocess.
>
> The *newgrp* command is intended only for use from an interactive terminal. It does not offer a useful interface for the support of applications.
>
> The exit status of *newgrp* is generally inapplicable. If *newgrp* is used in a script, in most cases it successfully invokes a new shell and the rest of the original shell script is bypassed when the new shell exits. Used interactively, *newgrp* displays diagnostic messages to indicate problems. But usage such as:
>
>
>     newgrp foo
>     echo $?
>
> is not useful because the new shell might not have access to any status *newgrp* may have generated (and most historical systems do not provide this status). A zero status echoed here does not necessarily indicate that the user has changed to the new group successfully. Following *newgrp* with the [*id*](../utilities/id.html) command provides a portable means of determining whether the group change was successful or not.

#### <span id="tag_20_84_17"></span>EXAMPLES

> None.

#### <span id="tag_20_84_18"></span>RATIONALE

> Most historical implementations use one of the *exec* functions to implement the behavior of *newgrp*. Errors detected before the *exec* leave the environment unchanged, while errors detected after the *exec* leave the user in a changed environment. While it would be useful to have *newgrp* issue a diagnostic message to tell the user that the environment changed, it would be inappropriate to require this change to some historical implementations.
>
> The password mechanism is allowed in the group database, but how this would be implemented is not specified.
>
> The *newgrp* utility was retained in this volume of POSIX.1-2024, even given the existence of the multiple group permissions feature in the System Interfaces volume of POSIX.1-2024, for several reasons. First, in some implementations, the group ownership of a newly created file is determined by the group of the directory in which the file is created, as allowed by the System Interfaces volume of POSIX.1-2024; on other implementations, the group ownership of a newly created file is determined by the effective group ID. On implementations of the latter type, *newgrp* allows files to be created with a specific group ownership. Finally, many implementations use the real group ID in accounting, and on such systems, *newgrp* allows the accounting identity of the user to be changed.

#### <span id="tag_20_84_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_84_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*sh*](../utilities/sh.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*exec*](../functions/exec.html#tag_17_129), [*getgrnam*()](../functions/getgrnam.html#)

#### <span id="tag_20_84_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_84_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The obsolescent SYNOPSIS is removed.
>
> The text describing supplemental groups is no longer conditional on {NGROUPS_MAX} being greater than 1. This is because {NGROUPS_MAX} now has a minimum value of 8. This is a FIPS requirement.

#### <span id="tag_20_84_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied, clarifying the behavior if the first argument is `'-'`.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The *newgrp* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.

#### <span id="tag_20_84_24"></span>Issue 8

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
