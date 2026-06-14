The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="rm"></span> <span id="tag_20_104"></span>

#### <span id="tag_20_104_01"></span>NAME

> rm — remove directory entries

#### <span id="tag_20_104_02"></span>SYNOPSIS

> `rm`` `**`[`**`-diRrv`**`]`**` `*`file`*`...`\
> \
> `rm -f`` `**`[`**`-diRrv`**`]`**` `**`[`***`file`*`...`**`]`**\

#### <span id="tag_20_104_03"></span>DESCRIPTION

> The *rm* utility shall remove the directory entry specified by each *file* argument.
>
> If either of the files dot or dot-dot are specified as the basename portion of an operand (that is, the final pathname component) or if an operand resolves to the root directory, *rm* shall write a diagnostic message to standard error and do nothing more with such operands.
>
> For each *file* the following steps shall be taken:
>
> 1.  If the *file* does not exist:
>
>     1.  If the **-f** option is not specified, *rm* shall write a diagnostic message to standard error.
>
>     2.  Go on to any remaining *files*.
>
> 2.  If *file* is of type directory, the following steps shall be taken:
>
>     1.  If neither the **-R** option nor the **-r** option is specified, but **-d** is specified, *rm* shall proceed with step 3 for the current file. If none of **-r**, **-R**, or **-d** is specified, *rm* shall write a diagnostic message to standard error, do nothing more with *file*, and go on to any remaining files.
>
>     2.  If *file* is an empty directory, *rm* may skip to step 2d. If the **-f** option is not specified, and either the permissions of *file* do not permit writing and the standard input is a terminal or the **-i** option is specified, *rm* shall write a prompt to standard error and read a line from the standard input. If the response is not affirmative, *rm* shall do nothing more with the current file and go on to any remaining files.
>
>     3.  For each entry contained in *file*, other than dot or dot-dot, the four steps listed here (1 to 4) shall be taken with the entry as if it were a *file* operand. The *rm* utility shall not traverse directories by following symbolic links into other parts of the hierarchy, but shall remove the links themselves.
>
>     4.  If the **-i** option is specified, *rm* shall write a prompt to standard error and read a line from the standard input. If the response is not affirmative, *rm* shall do nothing more with the current file, and go on to any remaining files.
>
>     5.  *rm* shall proceed with step 4 for the current file.
>
> 3.  If the **-f** option is not specified, and either the permissions of *file* do not permit writing and the standard input is a terminal or the **-i** option is specified, *rm* shall write a prompt to the standard error and read a line from the standard input. If the response is not affirmative, *rm* shall do nothing more with the current file and go on to any remaining files.
>
> 4.  *rm* shall perform actions equivalent to the [*remove*()](../functions/remove.html) function defined in the System Interfaces volume of POSIX.1-2024 called with a pathname of the current file used as the *path* argument.
>
>     If *rm* successfully performed the above actions on the current file, and the **-v** option is specified, *rm* shall write a message containing the pathname of the current file to the standard output. If the actions fail for any reason, *rm* shall write a diagnostic message to standard error, do nothing more with the current file, and go on to any remaining files.
>
> The *rm* utility shall be able to descend to arbitrary depths in a file hierarchy, and shall not fail due to path length limitations (unless an operand specified by the user exceeds system limitations).

#### <span id="tag_20_104_04"></span>OPTIONS

> The *rm* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-d**
>
> Remove empty directories. See the DESCRIPTION.
>
> **-f**
>
> Do not prompt for confirmation. Do not write diagnostic messages or modify the exit status in the case of no file operands, or in the case of operands that do not exist. Any previous occurrences of the **-i** option shall be ignored.
>
> **-i**
>
> Prompt for confirmation as described previously. Any previous occurrences of the **-f** option shall be ignored.
>
> **-R**
>
> Remove file hierarchies. See the DESCRIPTION.
>
> **-r**
>
> Equivalent to **-R**.
>
> **-v**
>
> After each file has been removed, write a message to standard output indicating that it has been removed.

#### <span id="tag_20_104_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a directory entry to be removed.

#### <span id="tag_20_104_06"></span>STDIN

> The standard input shall be used to read an input line in response to each prompt specified in the STDOUT section. Otherwise, the standard input shall not be used.

#### <span id="tag_20_104_07"></span>INPUT FILES

> None.

#### <span id="tag_20_104_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *rm*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
>
> *LC_COLLATE*
>
> \
> Determine the locale for the behavior of ranges, equivalence classes, and multi-character collating elements used in the extended regular expression defined for the **yesexpr** locale keyword in the *LC_MESSAGES* category.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments) and the behavior of character classes within regular expressions used in the extended regular expression defined for the **yesexpr** locale keyword in the *LC_MESSAGES* category.
>
> *LC_MESSAGES*
>
> \
> Determine the locale used to process affirmative responses, and the locale used to affect the format and contents of diagnostic messages and prompts written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_104_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_104_10"></span>STDOUT

> If the **-v** option is specified, information about each removed file shall be written to standard output in an unspecified format.

#### <span id="tag_20_104_11"></span>STDERR

> Prompts shall be written to standard error under the conditions specified in the DESCRIPTION and OPTIONS sections. The prompts shall contain the *file* pathname, but their format is otherwise unspecified. The standard error also shall be used for diagnostic messages.

#### <span id="tag_20_104_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_104_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_104_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> All requested directory entries (excluding directory entries where a non-affirmative response was given to a request for confirmation) were successfully deleted. In addition, if the **-v** option is specified, information about each removed directory entry was successfully written to standard output.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_104_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_104_16"></span>APPLICATION USAGE

> The *rm* utility is forbidden to remove the names dot and dot-dot in order to avoid the consequences of inadvertently doing something like:
>
>
>     rm -r .*
>
> Some implementations do not permit the removal of the last hard link to an executable binary file that is being executed; see the \[EBUSY\] error in the [*unlink*()](../functions/unlink.html) function defined in the System Interfaces volume of POSIX.1-2024. Thus, the *rm* utility can fail to remove such files.
>
> The **-i** option causes *rm* to prompt and read the standard input even if the standard input is not a terminal, but in the absence of **-i** the mode prompting is not done when the standard input is not a terminal.

#### <span id="tag_20_104_17"></span>EXAMPLES

> 1.  The following command:
>
>
>         rm a.out core
>
>     removes the directory entries: **a.out** and **core**, or issues an error if either directory entry is itself a directory or does not exist.
>
> 2.  The following command:
>
>
>         rm -Rf junk
>
>     removes the directory **junk** and all its contents, without prompting.
>
> 3.  The following command:
>
>
>         rm -d name
>
>     behaves like
>
>
>         rmdir name
>
>     if **name** is a directory (including failing if **name** is not empty), as if by the [*rmdir*()](../functions/rmdir.html) function; and behaves like
>
>
>         rm name
>
>     if **name** is not a directory, as if by the [*unlink*()](../functions/unlink.html) function.

#### <span id="tag_20_104_18"></span>RATIONALE

> For absolute clarity, paragraphs (2b) and (3) in the DESCRIPTION of *rm* describing the behavior when prompting for confirmation, should be interpreted in the following manner:
>
>
>     if ((NOT f_option) AND
>         ((not_writable AND input_is_terminal) OR i_option))
>
> The exact format of the interactive prompts is unspecified. Only the general nature of the contents of prompts are specified because implementations may desire more descriptive prompts than those used on historical implementations. Therefore, an application not using the **-f** option, or using the **-i** option, relies on the system to provide the most suitable dialog directly with the user, based on the behavior specified.
>
> The **-r** option is historical practice on all known systems. The synonym **-R** option is provided for consistency with the other utilities in this volume of POSIX.1-2024 that provide options requesting recursive descent through the file hierarchy.
>
> The behavior of the **-f** option in historical versions of *rm* is inconsistent. In general, along with "forcing" the unlink without prompting for permission, it always causes diagnostic messages to be suppressed and the exit status to be unmodified for nonexistent operands and files that cannot be unlinked. In some versions, however, the **-f** option suppresses usage messages and system errors as well. Suppressing such messages is not a service to either shell scripts or users.
>
> It is less clear that error messages regarding files that cannot be unlinked (removed) should be suppressed. Although this is historical practice, this volume of POSIX.1-2024 does not permit the **-f** option to suppress such messages.
>
> When given the **-r** and **-i** options, historical versions of *rm* prompt the user twice for each directory, once before removing its contents and once before actually attempting to delete the directory entry that names it. This allows the user to "prune" the file hierarchy walk. Historical versions of *rm* were inconsistent in that some did not do the former prompt for directories named on the command line and others had obscure prompting behavior when the **-i** option was specified and the permissions of the file did not permit writing. The POSIX Shell and Utilities *rm* differs little from historic practice, but does require that prompts be consistent. Historical versions of *rm* were also inconsistent in that prompts were done to both standard output and standard error. This volume of POSIX.1-2024 requires that prompts be done to standard error, for consistency with [*cp*](../utilities/cp.html) and [*mv*](../utilities/mv.html), and to allow historical extensions to *rm* that provide an option to list deleted files on standard output.
>
> The *rm* utility is required to descend to arbitrary depths so that any file hierarchy may be deleted. This means, for example, that the *rm* utility cannot run out of file descriptors during its descent (that is, if the number of file descriptors is limited, *rm* cannot be implemented in the historical fashion where one file descriptor is used per directory level). Also, *rm* is not permitted to fail because of path length restrictions, unless an operand specified by the user is longer than {PATH_MAX}.
>
> The *rm* utility removes symbolic links themselves, not the files they refer to, as a consequence of the dependence on the [*unlink*()](../functions/unlink.html) functionality, per the DESCRIPTION. When removing hierarchies with **-r** or **-R**, the prohibition on following symbolic links has to be made explicit.
>
> The addition of the **-d** option allows the use of *rm* to delete either a file or an empty directory without the risk of recursion into a non-empty directory, and without the inherent race between determining a file's type and deciding what action to attempt on that file. If either the **-r** or **-R** option is specified, the use of recursion takes precedence.
>
> The addition of the **-v** option allows a user of *rm* to see which files have been deleted.

#### <span id="tag_20_104_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_104_20"></span>SEE ALSO

> [*rmdir*](../utilities/rmdir.html#tag_20_106)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*remove*()](../functions/remove.html#), [*rmdir*()](../functions/rmdir.html#tag_17_493), [*unlink*()](../functions/unlink.html#tag_17_649)

#### <span id="tag_20_104_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_104_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_104_23"></span>Issue 6

> Text is added to clarify actions relating to symbolic links as specified in the IEEE P1003.2b draft standard.

#### <span id="tag_20_104_24"></span>Issue 7

> Austin Group Interpretations 1003.1-2001 \#019 and \#091 are applied.
>
> Austin Group Interpretation 1003.1-2001 \#126 is applied, changing the description of the *LC_MESSAGES* environment variable.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0163 \[542\], XCU/TC2-2008/0164 \[819\], and XCU/TC2-2008/0165 \[542\] are applied.

#### <span id="tag_20_104_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 802 is applied, adding the **-d** option.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defects 1154, 1365, and 1487 are applied, adding the **-v** option.
>
> Austin Group Defect 1380 is applied, changing "last link" to "last hard link".
>
> Austin Group Defect 1732 is applied, changing the EXIT STATUS section.

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
