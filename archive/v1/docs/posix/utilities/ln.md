The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="ln"></span> <span id="tag_20_67"></span>

#### <span id="tag_20_67_01"></span>NAME

> ln — link files

#### <span id="tag_20_67_02"></span>SYNOPSIS

> `ln`` `**`[`**`-fs`**`] [`**`-L|-P`**`]`**` `*`source_file target_file`*\
> \
> `ln`` `**`[`**`-fs`**`] [`**`-L|-P`**`]`**` `*`source_file`*`...`` `*`target_dir`*\

#### <span id="tag_20_67_03"></span>DESCRIPTION

> In the first synopsis form, the *ln* utility shall create a new directory entry at the destination path specified by the *target_file* operand. If the **-s** option is specified, a symbolic link shall be created with the contents specified by the *source_file* operand (which need not name an existing file); otherwise, a hard link shall be created to the file named by the *source_file* operand. This first synopsis form shall be assumed when the final operand does not name an existing directory; if more than two operands are specified and the final is not an existing directory, an error shall result.
>
> In the second synopsis form, the *ln* utility shall create a new directory entry for each *source_file* operand, at a destination path in the existing directory named by *target_dir*. If the **-s** option is specified, a symbolic link shall be created with the contents specified by each *source_file* operand (which need not name an existing file); otherwise, a hard link shall be created to each file named by a *source_file* operand.
>
> If the last operand specifies an existing file of a type not specified by the System Interfaces volume of POSIX.1-2024, the behavior is implementation-defined.
>
> The corresponding destination path for each *source_file* shall be the concatenation of the target directory pathname, a \<slash\> character if the target directory pathname did not end in a \<slash\>, and the last pathname component of the *source_file*. The second synopsis form shall be assumed when the final operand names an existing directory.
>
> For each *source_file*:
>
> 1.  If the destination path exists and was created by a previous step, it is unspecified whether *ln* writes a diagnostic message to standard error, does nothing more with the current *source_file*, and goes on to any remaining *source_file*s; or continues processing the current *source_file*. If the destination path exists:
>
>     1.  If the **-f** option is not specified, *ln* shall write a diagnostic message to standard error, do nothing more with the current *source_file*, and go on to any remaining *source_file*s.
>
>     2.  If the destination path names the same directory entry as the current *source_file* *ln* shall write a diagnostic message to standard error, do nothing more with the current *source_file*, and go on to any remaining *source_file*s*.*
>
>     3.  Actions shall be performed equivalent to the [*unlink*()](../functions/unlink.html) function defined in the System Interfaces volume of POSIX.1-2024, called using the destination path as the *path* argument. If this fails for any reason, *ln* shall write a diagnostic message to standard error, do nothing more with the current *source_file*, and go on to any remaining *source_file*s.
>
> 2.  If the **-s** option is specified, actions shall be performed equivalent to the [*symlink*()](../functions/symlink.html) function with *source_file* as the *path1* argument and the destination path as the *path2* argument. The *ln* utility shall do nothing more with *source_file* and shall go on to any remaining files.
>
> 3.  If *source_file* is a symbolic link:
>
>     1.  If the **-P** option is in effect, actions shall be performed equivalent to the [*linkat*()](../functions/linkat.html) function with *source_file* as the *path1* argument, the destination path as the *path2* argument, AT_FDCWD as the *fd1* and *fd2* arguments, and zero as the *flag* argument.
>
>     2.  If the **-L** option is in effect, actions shall be performed equivalent to the [*linkat*()](../functions/linkat.html) function with *source_file* as the *path1* argument, the destination path as the *path2* argument, AT_FDCWD as the *fd1* and *fd2* arguments, and AT_SYMLINK_FOLLOW as the *flag* argument.
>
>     The *ln* utility shall do nothing more with *source_file* and shall go on to any remaining files.
>
> 4.  Actions shall be performed equivalent to the [*link*()](../functions/link.html) function defined in the System Interfaces volume of POSIX.1-2024 using *source_file* as the *path1* argument, and the destination path as the *path2* argument.

#### <span id="tag_20_67_04"></span>OPTIONS

> The *ln* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-f**
>
> Force existing destination pathnames to be removed to allow the link.
>
> **-L**
>
> For each *source_file* operand that names a file of type symbolic link, create a hard link to the file referenced by the symbolic link.
>
> **-P**
>
> For each *source_file* operand that names a file of type symbolic link, create a hard link to the symbolic link itself.
>
> **-s**
>
> Create symbolic links instead of hard links. If the **-s** option is specified, the **-L** and **-P** options shall be silently ignored.
>
> Specifying more than one of the mutually-exclusive options **-L** and **-P** shall not be considered an error. The last option specified shall determine the behavior of the utility (unless the **-s** option causes it to be ignored).
>
> If the **-s** option is not specified and neither a **-L** nor a **-P** option is specified, it is implementation-defined which of the **-L** and **-P** options is used as the default.

#### <span id="tag_20_67_05"></span>OPERANDS

> The following operands shall be supported:
>
> *source_file*
>
> A pathname of a file to be linked. If the **-s** option is specified, no restrictions on the type of file or on its existence shall be made. If the **-s** option is not specified, whether a directory can be linked is implementation-defined.
>
> *target_file*
>
> The pathname of the new directory entry to be created.
>
> *target_dir*
>
> A pathname of an existing directory in which the new directory entries are created.

#### <span id="tag_20_67_06"></span>STDIN

> Not used.

#### <span id="tag_20_67_07"></span>INPUT FILES

> None.

#### <span id="tag_20_67_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *ln*:
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

#### <span id="tag_20_67_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_67_10"></span>STDOUT

> Not used.

#### <span id="tag_20_67_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_67_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_67_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_67_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_67_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_67_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_67_17"></span>EXAMPLES

> None.

#### <span id="tag_20_67_18"></span>RATIONALE

> The CONSEQUENCES OF ERRORS section does not require *ln* **-f** *a b* to remove *b* if a subsequent link operation would fail.
>
> Some historic versions of *ln* (including the one specified by the SVID) unlink the destination file, if it exists, by default. If the mode does not permit writing, these versions prompt for confirmation before attempting the unlink. In these versions the **-f** option causes *ln* not to attempt to prompt for confirmation.
>
> This allows *ln* to succeed in creating links when the target file already exists, even if the file itself is not writable (although the directory must be). Early proposals specified this functionality.
>
> This volume of POSIX.1-2024 does not allow the *ln* utility to unlink existing destination paths by default for the following reasons:
>
> - The *ln* utility has historically been used to provide locking for shell applications, a usage that is incompatible with *ln* unlinking the destination path by default. There was no corresponding technical advantage to adding this functionality.
>
> - This functionality gave *ln* the ability to destroy the link structure of files, which changes the historical behavior of *ln*.
>
> - This functionality is easily replicated with a combination of [*rm*](../utilities/rm.html) and *ln*.
>
> - It is not historical practice in many systems; BSD and BSD-derived systems do not support this behavior. Unfortunately, whichever behavior is selected can cause scripts written expecting the other behavior to fail.
>
> - It is preferable that *ln* perform in the same manner as the [*link*()](../functions/link.html) function, which does not permit the target to exist already.
>
> This volume of POSIX.1-2024 retains the **-f** option to provide support for shell scripts depending on the SVID semantics. It seems likely that shell scripts would not be written to handle prompting by *ln* and would therefore have specified the **-f** option.
>
> The **-f** option is an undocumented feature of many historical versions of the *ln* utility, allowing linking to directories. These versions require modification.
>
> Early proposals of this volume of POSIX.1-2024 also required a **-i** option, which behaved like the **-i** options in [*cp*](../utilities/cp.html) and [*mv*](../utilities/mv.html), prompting for confirmation before unlinking existing files. This was not historical practice for the *ln* utility and has been omitted.
>
> The **-L** and **-P** options allow for implementing both common behaviors of the *ln* utility. Earlier versions of this standard did not specify these options and required the behavior now described for the **-L** option. Many systems by default or as an alternative provided a non-conforming *ln* utility with the behavior now described for the **-P** option. Since applications could not rely on *ln* following links in practice, the **-L** and **-P** options were added to specify the desired behavior for the application.
>
> The **-L** and **-P** options are ignored when **-s** is specified in order to allow an alias to be created to alter the default behavior when creating hard links (for example, [*alias*](../utilities/alias.html) *ln*='[*ln*](../utilities/ln.html) **-L**'). They serve no purpose when **-s** is specified, since *source_file* is then just a string to be used as the contents of the created symbolic link and need not exist as a file.
>
> The specification ensures that *ln* **a** **a** with or without the **-f** option will not unlink the file **a**. Earlier versions of this standard were unclear in this case.

#### <span id="tag_20_67_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_67_20"></span>SEE ALSO

> [*chmod*](../utilities/chmod.html#tag_20_17), [*find*](../utilities/find.html#), [*pax*](../utilities/pax.html#), [*readlink*](../utilities/readlink.html#tag_20_101), [*realpath*](../utilities/realpath.html#tag_20_102), [*rm*](../utilities/rm.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*link*()](../functions/link.html#tag_17_304), [*unlink*()](../functions/unlink.html#tag_17_649)

#### <span id="tag_20_67_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_67_22"></span>Issue 6

> The *ln* utility is updated to include symbolic link processing as defined in the IEEE P1003.2b draft standard.

#### <span id="tag_20_67_23"></span>Issue 7

> Austin Group Interpretations 1003.1-2001 \#164, \#168, and \#169 are applied.
>
> SD5-XCU-ERN-27 is applied, adding a new paragraph to the RATIONALE.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The **-L** and **-P** options are added to make it implementation-defined whether the *ln* utility follows symbolic links.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0096 \[136\] is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0113 \[930\] is applied.

#### <span id="tag_20_67_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1380 is applied, changing text using the term "link" in line with its updated definition.
>
> Austin Group Defect 1457 is applied, adding [*readlink*](../utilities/readlink.html) and [*realpath*](../utilities/realpath.html) to the SEE ALSO section.
>
> Austin Group Defect 1506 is applied, changing the EXIT STATUS section.

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
