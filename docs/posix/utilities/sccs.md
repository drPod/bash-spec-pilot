The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="sccs"></span> <span id="tag_20_108"></span>

#### <span id="tag_20_108_01"></span>NAME

> sccs — front end for the SCCS subsystem (**DEVELOPMENT**)

#### <span id="tag_20_108_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` sccs`` `**`[`**`-r`**`] [`**`-d`` `*`path`***`] [`**`-p`` `*`path`***`]`**` `*`command`*` `**`[`***`options`*`...`**`] [`***`operands`*`...`**`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_108_03"></span>DESCRIPTION

> The *sccs* utility is a front end to the SCCS programs. It also includes the capability to run set-user-id to another user to provide additional protection.
>
> The *sccs* utility shall invoke the specified *command* with the specified *options* and *operands*. By default, each of the *operands* shall be modified by prefixing it with the string `"SCCS/s."`.
>
> The *command* can be the name of one of the SCCS utilities in this volume of POSIX.1-2024 ([*admin*](../utilities/admin.html), [*delta*](../utilities/delta.html), [*get*](../utilities/get.html), [*prs*](../utilities/prs.html), [*rmdel*](../utilities/rmdel.html), [*sact*](../utilities/sact.html), [*unget*](../utilities/unget.html), [*val*](../utilities/val.html), or [*what*](../utilities/what.html)) or one of the pseudo-utilities listed in the EXTENDED DESCRIPTION section.

#### <span id="tag_20_108_04"></span>OPTIONS

> The *sccs* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that *options* operands are actually options to be passed to the utility named by *command*. When the portion of the command:
>
>
>     command [options ... ] [operands ... ]
>
> is considered, all of the pseudo-utilities used as *command* shall support the Utility Syntax Guidelines. Any of the other SCCS utilities that can be invoked in this manner support the Guidelines to the extent indicated by their individual OPTIONS sections.
>
> The following options shall be supported preceding the *command* operand:
>
> **-d ***path*
>
> A pathname of a directory to be used as a root directory for the SCCS files. The default shall be the current directory. The **-d** option shall take precedence over the *PROJECTDIR* variable. See **-p**.
>
> **-p ***path*
>
> A pathname of a directory in which the SCCS files are located. The default shall be the **SCCS** directory.
>
> The **-p** option differs from the **-d** option in that the **-d** option-argument shall be prefixed to the entire pathname and the **-p** option-argument shall be inserted before the final component of the pathname. For example:
>
>
>     sccs -d /x -p y get a/b
>
> converts to:
>
>
>     get /x/a/y/s.b
>
> This allows the creation of aliases such as:
>
>
>     alias syssccs="sccs -d /usr/src"
>
> which is used as:
>
>
>     syssccs get cmd/who.c
>
> **-r**
>
> Invoke *command* with the real user ID of the process, not any effective user ID that the *sccs* utility is set to. Certain commands ([*admin*](../utilities/admin.html), **check**, **clean**, **diffs**, **info**, [*rmdel*](../utilities/rmdel.html), and **tell**) cannot be run set-user-ID by all users, since this would allow anyone to change the authorizations. These commands are always run as the real user.

#### <span id="tag_20_108_05"></span>OPERANDS

> The following operands shall be supported:
>
> *command*
>
> An SCCS utility name or the name of one of the pseudo-utilities listed in the EXTENDED DESCRIPTION section.
>
> *options*
>
> An option or option-argument to be passed to *command*.
>
> *operands*
>
> An operand to be passed to *command*.

#### <span id="tag_20_108_06"></span>STDIN

> See the utility description for the specified *command*.

#### <span id="tag_20_108_07"></span>INPUT FILES

> See the utility description for the specified *command*.

#### <span id="tag_20_108_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *sccs*:
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
> Determine the location of messages objects and message catalogs.
>
> *PROJECTDIR*
>
> \
> Provide a default value for the **-d** *path* option. If the value of *PROJECTDIR* begins with a \<slash\>, it shall be considered an absolute pathname; otherwise, the value of *PROJECTDIR* is treated as a user name and that user's initial working directory shall be examined for a subdirectory **src** or **source**. If such a directory is found, it shall be used. Otherwise, the value shall be used as a relative pathname.
>
> Additional environment variable effects may be found in the utility description for the specified *command*.

#### <span id="tag_20_108_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_108_10"></span>STDOUT

> See the utility description for the specified *command*.

#### <span id="tag_20_108_11"></span>STDERR

> See the utility description for the specified *command*.

#### <span id="tag_20_108_12"></span>OUTPUT FILES

> See the utility description for the specified *command*.

#### <span id="tag_20_108_13"></span>EXTENDED DESCRIPTION

> The following pseudo-utilities shall be supported as *command* operands. All options referred to in the following list are values given in the *options* operands following *command*.
>
> **check**
>
> Equivalent to **info**, except that nothing shall be printed if nothing is being edited, and a non-zero exit status shall be returned if anything is being edited. The intent is to have this included in an "install" entry in a makefile to ensure that everything is included into the SCCS file before a version is installed.
>
> **clean**
>
> Remove everything from the current directory that can be recreated from SCCS files, but do not remove any files being edited. If the **-b** option is given, branches shall be ignored in the determination of whether they are being edited; this is dangerous if branches are kept in the same directory.
>
> **create**
>
> Create an SCCS file, taking the initial contents from the file of the same name. Any options to [*admin*](../utilities/admin.html) are accepted. If the creation is successful, the original files shall be renamed by prefixing the basenames with a comma. These renamed files should be removed after it has been verified that the SCCS files have been created successfully.
>
> **delget**
>
> Perform a [*delta*](../utilities/delta.html) on the named files and then [*get*](../utilities/get.html) new versions. The new versions shall have ID keywords expanded and shall not be editable. Any **-m**, **-p**, **-r**, **-s**, and **-y** options shall be passed to [*delta*](../utilities/delta.html), and any **-b**, **-c**, **-e**, **-i**, **-k**, **-l**, **-s**, and **-x** options shall be passed to [*get*](../utilities/get.html).
>
> **deledit**
>
> Equivalent to **delget**, except that the [*get*](../utilities/get.html) phase shall include the **-e** option. This option is useful for making a checkpoint of the current editing phase. The same options shall be passed to [*delta*](../utilities/delta.html) as described above, and all the options listed for [*get*](../utilities/get.html) above except **-e** shall be passed to **edit**.
>
> **diffs**
>
> Write a difference listing between the current version of the files checked out for editing and the versions in SCCS format. Any **-r**, **-c**, **-i**, **-x**, and **-t** options shall be passed to [*get*](../utilities/get.html); any **-l**, **-s**, **-e**, **-f**, **-h**, and **-b** options shall be passed to [*diff*](../utilities/diff.html). A **-C** option shall be passed to [*diff*](../utilities/diff.html) as **-c**.
>
> **edit**
>
> Equivalent to [*get*](../utilities/get.html) **-e**.
>
> **fix**
>
> Remove the named delta, but leave a copy of the delta with the changes that were in it. It is useful for fixing small compiler bugs, and so on. The application shall ensure that it is followed by a **-r** *SID* option. Since **fix** does not leave audit trails, it should be used carefully.
>
> **info**
>
> Write a listing of all files being edited. If the **-b** option is given, branches (that is, SIDs with two or fewer components) shall be ignored. If a **-u** *user* option is given, then only files being edited by the named user shall be listed. A **-U** option shall be equivalent to **-u**\<*current user*\>.
>
> **print**
>
> Write out verbose information about the named files, equivalent to *sccs* [*prs*](../utilities/prs.html).
>
> **tell**
>
> Write a \<newline\>-separated list of the files being edited to standard output. Takes the **-b**, **-u**, and **-U** options like **info** and **check**.
>
> **unedit**
>
> This is the opposite of an **edit** or a [*get*](../utilities/get.html) **-e**. It should be used with caution, since any changes made since the [*get*](../utilities/get.html) are lost.
>
> \

#### <span id="tag_20_108_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_108_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_108_16"></span>APPLICATION USAGE

> Many of the SCCS utilities take directory names as operands as well as specific filenames. The pseudo-utilities supported by *sccs* are not described as having this capability, but are not prohibited from doing so.

#### <span id="tag_20_108_17"></span>EXAMPLES

> 1.  To get a file for editing, edit it and produce a new delta:
>
>
>         sccs get -e file.c
>         ex file.c
>         sccs delta file.c
>
> 2.  To get a file from another directory:
>
>
>         sccs -p /usr/src/sccs/s. get cc.c
>
>     or:
>
>
>         sccs get /usr/src/sccs/s.cc.c
>
> 3.  To make a delta of a large number of files in the current directory:
>
>
>         sccs delta *.c
>
> 4.  To get a list of files being edited that are not on branches:
>
>
>         sccs info -b
>
> 5.  To delta everything being edited by the current user:
>
>
>         sccs delta $(sccs tell -U)
>
> 6.  In a makefile, to get source files from an SCCS file if it does not already exist:
>
>
>         SRCS = <list of source files>
>         $(SRCS):
>             sccs get $(REL) $@

#### <span id="tag_20_108_18"></span>RATIONALE

> *sccs* and its associated utilities are part of the XSI Development Utilities option within the XSI option.
>
> SCCS is an abbreviation for Source Code Control System. It is a maintenance and enhancement tracking tool. When a file is put under SCCS, the source code control system maintains the file and, when changes are made, identifies and stores them in the file with the original source code and/or documentation. As other changes are made, they too are identified and retained in the file.
>
> Retrieval of the original and any set of changes is possible. Any version of the file as it develops can be reconstructed for inspection or additional modification. History data can be stored with each version, documenting why the changes were made, who made them, and when they were made.

#### <span id="tag_20_108_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_108_20"></span>SEE ALSO

> [*admin*](../utilities/admin.html#), [*delta*](../utilities/delta.html#), [*get*](../utilities/get.html#), [*make*](../utilities/make.html#), [*prs*](../utilities/prs.html#), [*rmdel*](../utilities/rmdel.html#), [*sact*](../utilities/sact.html#), [*unget*](../utilities/unget.html#), [*val*](../utilities/val.html#), [*what*](../utilities/what.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_108_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_108_22"></span>Issue 6

> In the ENVIRONMENT VARIABLES section, the *PROJECTDIR* description is updated from "otherwise, the home directory of a user of that name is examined" to "otherwise, the value of *PROJECTDIR* is treated as a user name and that user's initial working directory is examined".
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_108_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_108_24"></span>Issue 8

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
