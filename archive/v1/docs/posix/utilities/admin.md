The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="admin"></span> <span id="tag_20_01"></span>

#### <span id="tag_20_01_01"></span>NAME

> admin — create and administer SCCS files (**DEVELOPMENT**)

#### <span id="tag_20_01_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` admin -i`**`[`***`name`***`] [`**`-n`**`] [`**`-a`` `*`login`***`] [`**`-d`` `*`flag`***`] [`**`-e`` `*`login`***`] [`**`-f`` `*`flag`***`]`\**
> ` ``      `` `**`[`**`-m`` `*`mrlist`***`] [`**`-r`` `*`rel`***`] [`**`-t`**`[`***`name`***`] [`**`-y`**`[`***`comment`***`]]`**` `*`newfile`*\
> \
> `admin -n`` `**`[`**`-a`` `*`login`***`] [`**`-d`` `*`flag`***`] [`**`-e`` `*`login`***`] [`**`-f`` `*`flag`***`] [`**`-m`` `*`mrlist`***`]`\**
> ` ``      `` `**`[`**`-t`**`[`***`name`***`]] [`**`-y`**`[`***`comment`***`]]`**` `*`newfile`*`...`\
> \
> `admin`` `**`[`**`-a`` `*`login`***`] [`**`-d`` `*`flag`***`] [`**`-m`` `*`mrlist`***`] [`**`-r`` `*`rel`***`] [`**`-t`**`[`***`name`***`]]`**` `*`file`*`...`\
> \
> `admin -h`` `*`file`*`...`\
> \
> `admin -z`` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_01_03"></span>DESCRIPTION

> The *admin* utility shall create new SCCS files or change parameters of existing ones. If a named file does not exist, it shall be created, and its parameters shall be initialized according to the specified options. Parameters not initialized by an option shall be assigned a default value. If a named file does exist, parameters corresponding to specified options shall be changed, and other parameters shall be left as is.
>
> All SCCS filenames supplied by the application shall be of the form s.*filename*. New SCCS files shall be given read-only permission mode. Write permission in the parent directory is required to create a file. All writing done by *admin* shall be to a temporary *x-file*, named x.*filename* (see [*get*](../utilities/get.html#)) created with read-only mode if *admin* is creating a new SCCS file, or created with the same mode as that of the SCCS file if the file already exists. After successful execution of *admin*, the SCCS file shall be removed (if it exists), and the *x-file* shall be renamed with the name of the SCCS file. This ensures that changes are made to the SCCS file only if no errors occur.
>
> The *admin* utility shall also use a transient lock file (named z.*filename*), which is used to prevent simultaneous updates to the SCCS file; see [*get*](../utilities/get.html#).

#### <span id="tag_20_01_04"></span>OPTIONS

> The *admin* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that the **-i**, **-t**, and **-y** options have optional option-arguments. These optional option-arguments shall not be presented as separate arguments. The following options are supported:
>
> **-n**
>
> Create a new SCCS file. When **-n** is used without **-i**, the SCCS file shall be created with control information but without any file data.
>
> **-i\[***name***\]**
>
> Specify the *name* of a file from which the text for a new SCCS file shall be taken. The text constitutes the first delta of the file (see the **-r** option for the delta numbering scheme). If the **-i** option is used, but the *name* option-argument is omitted, the text shall be obtained by reading the standard input. If this option is omitted, the SCCS file shall be created with control information but without any file data. The **-i** option implies the **-n** option.
>
> **-r ***SID*
>
> Specify the SID of the initial delta to be inserted. This SID shall be a trunk SID; that is, the branch and sequence numbers shall be zero or missing. The level number is optional, and defaults to 1.
>
> **-t\[***name***\]**
>
> Specify the *name* of a file from which descriptive text for the SCCS file shall be taken. In the case of existing SCCS files (neither **-i** nor **-n** is specified):
>
> - A **-t** option without a *name* option-argument shall cause the removal of descriptive text (if any) currently in the SCCS file.
>
> - A **-t** option with a *name* option-argument shall cause the text (if any) in the named file to replace the descriptive text (if any) currently in the SCCS file.
>
> **-f ***flag*
>
> Specify a *flag*, and, possibly, a value for the *flag*, to be placed in the SCCS file. Several **-f** options may be supplied on a single *admin* command line. Implementations shall recognize the following flags and associated values:
>
> **b**
>
> Allow use of the **-b** option on a [*get*](../utilities/get.html) command to create branch deltas.
>
> **c***ceil*
>
> Specify the highest release (that is, ceiling), a number less than or equal to 9999, which may be retrieved by a [*get*](../utilities/get.html) command for editing. The default value for an unspecified **c** flag shall be 9999.
>
> **f***floor*
>
> Specify the lowest release (that is, floor), a number greater than 0 but less than 9999, which may be retrieved by a [*get*](../utilities/get.html) command for editing. The default value for an unspecified **f** flag shall be 1.
>
> **d***SID*
>
> Specify the default delta number (SID) to be used by a [*get*](../utilities/get.html) command.
>
> **i***str*
>
> Treat the "No ID keywords" message issued by [*get*](../utilities/get.html) or [*delta*](../utilities/delta.html) as a fatal error. In the absence of this flag, the message is only a warning. The message is issued if no SCCS identification keywords (see [*get*](../utilities/get.html#)) are found in the text retrieved or stored in the SCCS file. If a value is supplied, the application shall ensure that the keywords exactly match the given string; however, the string shall contain a keyword, and no embedded \<newline\> characters.
>
> **j**
>
> Allow concurrent [*get*](../utilities/get.html) commands for editing on the same SID of an SCCS file. This allows multiple concurrent updates to the same version of the SCCS file.
>
> **l***list*
>
> Specify a *list* of releases to which deltas can no longer be made (that is, [*get*](../utilities/get.html) **-e** against one of these locked releases fails). Conforming applications shall use the following syntax to specify a *list*. Implementations may accept additional forms as an extension:
>
>
>     <list> ::= a | <range-list>
>     <range-list> ::= <range> | <range-list>, <range>
>     <range> ::= <SID>
>
> The character *a* in the *list* shall be equivalent to specifying all releases for the named SCCS file. The non-terminal \<*SID*\> in range shall be the delta number of an existing delta associated with the SCCS file.
>
> **n**
>
> Cause [*delta*](../utilities/delta.html) to create a null delta in each of those releases (if any) being skipped when a delta is made in a new release (for example, in making delta 5.1 after delta 2.7, releases 3 and 4 are skipped). These null deltas shall serve as anchor points so that branch deltas may later be created from them. The absence of this flag shall cause skipped releases to be nonexistent in the SCCS file, preventing branch deltas from being created from them in the future. During the initial creation of an SCCS file, the **n** flag may be ignored; that is, if the **-r** option is used to set the release number of the initial SID to a value greater than 1, null deltas need not be created for the "skipped" releases.
>
> **q***text*
>
> Substitute user-definable *text* for all occurrences of the %**Q**% keyword in the SCCS file text retrieved by [*get*](../utilities/get.html).
>
> **m***mod*
>
> Specify the module name of the SCCS file substituted for all occurrences of the %**M**% keyword in the SCCS file text retrieved by [*get*](../utilities/get.html). If the **m** flag is not specified, the value assigned shall be the name of the SCCS file with the leading `'.'` removed.
>
> **t***type*
>
> Specify the *type* of module in the SCCS file substituted for all occurrences of the %**Y**% keyword in the SCCS file text retrieved by [*get*](../utilities/get.html).
>
> **v***pgm*
>
> Cause [*delta*](../utilities/delta.html) to prompt for modification request (MR) numbers as the reason for creating a delta. The optional value specifies the name of an MR number validation program. (If this flag is set when creating an SCCS file, the application shall ensure that the **m** option is also used even if its value is null.)
>
> **-d ***flag*
>
> Remove (delete) the specified *flag* from an SCCS file. Several **-d** options may be supplied on a single *admin* command. See the **-f** option for allowable *flag* names. (The **l***list* flag gives a *list* of releases to be unlocked. See the **-f** option for further description of the **l** flag and the syntax of a *list*.)
>
> **-a ***login*
>
> Specify a *login* name, or numerical group ID, to be added to the list of users who may make deltas (changes) to the SCCS file. A group ID shall be equivalent to specifying all *login* names common to that group ID. Several **-a** options may be used on a single *admin* command line. As many *login*s, or numerical group IDs, as desired may be on the list simultaneously. If the list of users is empty, then anyone may add deltas. If *login* or group ID is preceded by a `'!'`, the users so specified shall be denied permission to make deltas.
>
> **-e ***login*
>
> Specify a *login* name, or numerical group ID, to be erased from the list of users allowed to make deltas (changes) to the SCCS file. Specifying a group ID is equivalent to specifying all *login* names common to that group ID. Several **-e** options may be used on a single *admin* command line.
>
> **-y\[***comment***\]**
>
> Insert the *comment* text into the SCCS file as a comment for the initial delta in a manner identical to that of [*delta*](../utilities/delta.html). In the POSIX locale, omission of the **-y** option shall result in a default comment line being inserted in the form:
>
>
>     "date and time created %s %s by %s", <date>, <time>, <login>
>
> where \<*date*\> is expressed in the format of the [*date*](../utilities/date.html) utility's `%y`/`%m`/`%d` conversion specification, \<*time*\> in the format of the [*date*](../utilities/date.html) utility's `%T` conversion specification format, and \<*login*\> is the login name of the user creating the file.
>
> **-m ***mrlist*
>
> Insert the list of modification request (MR) numbers into the SCCS file as the reason for creating the initial delta in a manner identical to [*delta*](../utilities/delta.html). The application shall ensure that the **v** flag is set and the MR numbers are validated if the **v** flag has a value (the name of an MR number validation program). A diagnostic message shall be written if the **v** flag is not set or MR validation fails.
>
> **-h**
>
> Check the structure of the SCCS file and compare the newly computed checksum with the checksum that is stored in the SCCS file. If the newly computed checksum does not match the checksum in the SCCS file, a diagnostic message shall be written.
>
> **-z**
>
> Recompute the SCCS file checksum and store it in the first line of the SCCS file (see the **-h** option above). Note that use of this option on a truly corrupted file may prevent future detection of the corruption.

#### <span id="tag_20_01_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file*
>
> A pathname of an existing SCCS file or a directory. If *file* is a directory, the *admin* utility shall behave as though each file in the directory were specified as a named file, except that non-SCCS files (last component of the pathname does not begin with **s.**) and unreadable files shall be silently ignored.
>
> *newfile*
>
> A pathname of an SCCS file to be created.
>
> If exactly one *file* or *newfile* operand appears, and it is `'-'`, the standard input shall be read; each line of the standard input shall be taken to be the name of an SCCS file to be processed. Non-SCCS files and unreadable files shall be silently ignored.

#### <span id="tag_20_01_06"></span>STDIN

> The standard input shall be a text file used only if **-i** is specified without an option-argument or if a *file* or *newfile* operand is specified as `'-'`. If the first character of any standard input line is \<SOH\> in the POSIX locale, the results are unspecified.

#### <span id="tag_20_01_07"></span>INPUT FILES

> The existing SCCS files shall be text files of an unspecified format.
>
> The application shall ensure that the file named by the **-i** option's *name* option-argument shall be a text file; if the first character of any line in this file is \<SOH\> in the POSIX locale, the results are unspecified. If this file contains more than 99999 lines, the number of lines recorded in the header for this file shall be 99999 for this delta.

#### <span id="tag_20_01_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *admin*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and the contents of the default **-y** comment.
>
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_01_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_01_10"></span>STDOUT

> Not used.

#### <span id="tag_20_01_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_01_12"></span>OUTPUT FILES

> Any SCCS files created shall be text files of an unspecified format. During processing of a *file*, a locking *z-file*, as described in [*get*](../utilities/get.html#), may be created and deleted.

#### <span id="tag_20_01_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_01_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_01_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_01_16"></span>APPLICATION USAGE

> It is recommended that directories containing SCCS files be writable by the owner only, and that SCCS files themselves be read-only. The mode of the directories should allow only the owner to modify SCCS files contained in the directories. The mode of the SCCS files prevents any modification at all except by SCCS commands.

#### <span id="tag_20_01_17"></span>EXAMPLES

> None.

#### <span id="tag_20_01_18"></span>RATIONALE

> None.

#### <span id="tag_20_01_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_01_20"></span>SEE ALSO

> [*delta*](../utilities/delta.html#), [*get*](../utilities/get.html#), [*prs*](../utilities/prs.html#), [*what*](../utilities/what.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_01_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_01_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements, and to emphasize the term "shall" for implementation requirements.
>
> The grammar is updated.
>
> The Open Group Base Resolution bwg2001-007 is applied, adding new text to the INPUT FILES section warning that the maximum lines recorded in the file is 99999.
>
> The Open Group Base Resolution bwg2001-009 is applied, amending the description of the **-h** option.

#### <span id="tag_20_01_23"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to behave as follows:
>
> 1.  Report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> 2.  Disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
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
