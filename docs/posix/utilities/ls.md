The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="ls"></span> <span id="tag_20_73"></span>

#### <span id="tag_20_73_01"></span>NAME

> ls — list directory contents

#### <span id="tag_20_73_02"></span>SYNOPSIS

> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` ls`` `**`[`**`-ikqrs`**`] [`**`-`<img src="../images/opt-start.gif" data-border="0" />`g`<img src="../images/opt-end.gif" data-border="0" />`ln`<img src="../images/opt-start.gif" data-border="0" />`o`<img src="../images/opt-end.gif" data-border="0" />**`] [`**`-A|-a`**`] [`**`-C|-m|-x|-1`**`]`**` ``\`\
> `      `` `**`[`**`-F|-p`**`] [`**`-H|-L`**`] [`**`-R|-d`**`] [`**`-S|-f|-t`**`] [`**`-c|-u`**`] [`***`file`*`...`**`]`**

#### <span id="tag_20_73_03"></span>DESCRIPTION

> For each operand that names a file of a type other than directory or symbolic link to a directory, *ls* shall write the name of the file as well as any requested, associated information. For each operand that names a file of type directory, *ls* shall write the names of files contained within the directory as well as any requested, associated information. Filenames beginning with a \<period\> (`'.'`) and any associated information shall not be written out unless explicitly referenced, the **-A** or **-a** option is supplied, or an implementation-defined condition causes them to be written. If one or more of the **-d**, **-F**, or **-l** options are specified, and neither the **-H** nor the **-L** option is specified, for each operand that names a file of type symbolic link to a directory, *ls* shall write the name of the file as well as any requested, associated information. If none of the **-d**, **-F**, or **-l** options are specified, or the **-H** or **-L** options are specified, for each operand that names a file of type symbolic link to a directory, *ls* shall write the names of files contained within the directory as well as any requested, associated information. In each case where the names of files contained within a directory are written, if the directory contains any symbolic links then *ls* shall evaluate the file information and file type to be those of the symbolic link itself, unless the **-L** option is specified.
>
> If no operands are specified, *ls* shall behave as if a single operand of dot (`'.'`) had been specified. If more than one operand is specified, *ls* shall write non-directory operands first; it shall sort directory and non-directory operands separately according to the collating sequence in the current locale.
>
> Whenever *ls* sorts filenames or pathnames according to the collating sequence in the current locale, if this collating sequence does not have a total ordering of all characters (see XBD [*7.3.2 LC_COLLATE*](../basedefs/V1_chap07.html#tag_07_03_02)), then any filenames or pathnames that collate equally shall be further compared byte-by-byte using the collating sequence for the POSIX locale.
>
> The *ls* utility shall detect infinite loops; that is, entering a previously visited directory that is an ancestor of the last file encountered. When it detects an infinite loop, *ls* shall write a diagnostic message to standard error and shall either recover its position in the hierarchy or terminate.

#### <span id="tag_20_73_04"></span>OPTIONS

> The *ls* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-A**
>
> Write out all directory entries, including those whose names begin with a \<period\> (`'.'`) but excluding the entries dot and dot-dot (if they exist).
>
> **-C**
>
> Write multi-text-column output with entries sorted down the columns, according to the collating sequence. The number of text columns and the column separator characters are unspecified, but should be adapted to the nature of the output device. This option disables long format output.
>
> **Note:**  
> Since the output from this option may use separator characters that include characters that might appear in filenames (in addition to the problems related to \<newline\>s in filenames), **-C** should not be used when filenames might be extracted from the output by a script.
>
> **-F**
>
> Do not follow symbolic links named as operands unless the **-H** or **-L** options are specified. Write a \<slash\> (`'/'`) immediately after each pathname that is a directory, an \<asterisk\> (`'*'`) after each that is executable, a \<vertical-line\> (`'|'`) after each that is a FIFO, an \<equals-sign\> (`'='`) after each that is a socket, and a \<commercial-at\> (`'@'`) after each that is a symbolic link. For other file types, other symbols may be written.
>
> **-H**
>
> Evaluate the file information and file type for symbolic links specified on the command line to be those of the file referenced by the link, and not the link itself; however, *ls* shall write the name of the link itself and not the file referenced by the link.
>
> **-L**
>
> Evaluate the file information and file type for all symbolic links (whether named on the command line or encountered in a file hierarchy) to be those of the file referenced by the link, and not the link itself; however, *ls* shall write the name of the link itself and not the file referenced by the link. When **-L** is used with **-l**, write the contents of symbolic links in the long format (see the STDOUT section).
>
> **-R**
>
> Recursively list subdirectories encountered. Subdirectories with filenames beginning with a \<period\> (`'.'`) shall be recursively listed if and only if the subdirectory name was included in the filenames listed for the containing directory. When a symbolic link to a directory is encountered, the directory shall not be recursively listed unless the **-L** option is specified. The use of **-R** with **-d** or **-f** produces unspecified results.
>
> **-S**
>
> Sort with the primary key being file size (in decreasing order) and the secondary key being filename in the collating sequence (in increasing order). For a symbolic link, the size used as the sort key is that of the symbolic link itself, unless *ls* is evaluating its file information to be that of the file referenced by the link (see the **-H** and **-L** options).
>
> **-a**
>
> Write out all directory entries, including those whose names begin with a \<period\> (`'.'`).
>
> **-c**
>
> Use time of last modification of the file status information (see XBD [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html)) instead of last modification of the file itself for sorting (**-t**) or writing (**-l**).
>
> **-d**
>
> Do not follow symbolic links named as operands unless the **-H** or **-L** options are specified. Do not treat directories differently than other types of files. The use of **-d** with **-R** or **-f** produces unspecified results.
>
> **-f**
>
> List the entries in directory operands in the order they appear in the directory. The behavior for non-directory operands is unspecified. This option shall turn on **-a**. When **-f** is specified, any occurrences of the **-r**, **-S**, and **-t** options shall be ignored and any occurrences of the **-A**, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-g**, <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> **-l**, **-n**, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-o**, <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> and **-s** options may be ignored. The use of **-f** with **-R** or **-d** produces unspecified results.
>
> **-g**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Turn on the **-l** (ell) option, but disable writing the file's owner name or number. Disable the **-C**, **-m**, and **-x** options. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-i**
>
> For each file, write the file's file serial number (see [*stat*()](../functions/stat.html) in the System Interfaces volume of POSIX.1-2024).
>
> **-k**
>
> Set the block size for the **-s** option and the per-directory block count written for the **-l**, **-n**, **-s**, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-g**, and **-o** <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> options (see the STDOUT section) to 1024 bytes.
>
> **-l**
>
> (The letter ell.) Do not follow symbolic links named as operands unless the **-H** or **-L** options are specified. Write out in long format (see the STDOUT section). Disable the **-C**, **-m**, and **-x** options.
>
> **-m**
>
> Stream output format; list pathnames across the page, separated by a \<comma\> character followed by a \<space\> character. Use a \<newline\> character as the list terminator and after the separator sequence when there is not room on a line for the next list entry. This option disables long format output.
>
> **-n**
>
> Turn on the **-l** (ell) option, but when writing the file's owner or group, write the file's numeric UID or GID rather than the user or group name, respectively. Disable the **-C**, **-m**, and **-x** options.
>
> **-o**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Turn on the **-l** (ell) option, but disable writing the file's group name or number. Disable the **-C**, **-m**, and **-x** options. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-p**
>
> Write a \<slash\> (`'/'`) after each pathname if that file is a directory.
>
> **-q**
>
> Force each instance of non-printable filename characters (including \<newline\>, \<tab\>, and other control characters) to be written as the \<question-mark\> (`'?'`) character. Implementations may provide this option by default if the output is to a terminal device.
>
> **-r**
>
> Reverse the order of the sort to get reverse collating sequence, oldest first, or smallest file size first depending on the other options given.
>
> **-s**
>
> Indicate the total number of file system blocks consumed by each file displayed. If the **-k** option is also specified, the block size shall be 1024 bytes; otherwise, the block size is implementation-defined.
>
> **-t**
>
> Sort with the primary key being time modified (most recently modified first) and the secondary key being filename in the collating sequence. For a symbolic link, the time used as the sort key is that of the symbolic link itself, unless *ls* is evaluating its file information to be that of the file referenced by the link (see the **-H** and **-L** options).
>
> **-u**
>
> Use time of last access (see XBD [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html)) instead of last modification of the file for sorting (**-t**) or writing (**-l**).
>
> **-x**
>
> The same as **-C**, except that the multi-text-column output is produced with entries sorted across, rather than down, the columns. This option disables long format output.
>
> **-1**
>
> (The numeric digit one.) Force output to be one entry per line. This option does not disable long format output. (Long format output is enabled by <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-g**, <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> **-l** (ell), **-n**, and <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-o**; <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> and disabled by **-C**, **-m**, and **-x**.)
>
> If an option that enables long format output (<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-g**, <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> **-l** (ell), **-n**, and <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-o**<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> ) is given with an option that disables long format output (**-C**, **-m**, and **-x**), this shall not be considered an error. The last of these options specified shall determine whether long format output is written.
>
> If **-R**, **-d**, or **-f** are specified, the results of specifying these mutually-exclusive options are specified by the descriptions of these options above. If more than one of any of the other options shown in the SYNOPSIS section in mutually-exclusive sets are given, this shall not be considered an error; the last option specified in each set shall determine the output.
>
> Note that if **-t** is specified, **-c** and **-u** are not only mutually-exclusive with each other, they are also mutually-exclusive with **-S** when determining sort order. But even if **-S** is specified after all occurrences of **-c**, **-t**, and **-u**, the last use of **-c** or **-u** determines the timestamp printed when producing long format output.

#### <span id="tag_20_73_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a file to be written. If the file specified is not found, a diagnostic message shall be output on standard error.

#### <span id="tag_20_73_06"></span>STDIN

> Not used.

#### <span id="tag_20_73_07"></span>INPUT FILES

> None.\

#### <span id="tag_20_73_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *ls*:
>
> *COLUMNS*
>
> Override the system-selected horizontal display line size, used to determine the column position width for writing multiple text-column output. See XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08) for valid values and results when it is unset or null. The *ls* utility shall use this value to calculate how many pathname text columns to write (see **-C**). The column width chosen to write the names of files in any given directory shall be constant. Filenames shall not be truncated to fit into the multiple text-column output.
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
> Determine the locale for character collation information in determining the pathname collation sequence.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments) and which characters are defined as printable (character class **print**).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *LC_TIME*
>
> Determine the format and contents for date and time strings written by *ls*.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *TZ*
>
> Determine the timezone for date and time strings written by *ls*. If *TZ* is unset or null, an unspecified default timezone shall be used.

#### <span id="tag_20_73_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_73_10"></span>STDOUT

> The default format shall be to list one entry per line to standard output; the exceptions are to terminals or when one of the **-C**, **-m**, or **-x** options is specified. If the output is to a terminal, the format is implementation-defined.
>
> In the formats specified below, except where specified otherwise the \<*pathname*\> field shall consist of the file's pathname and, if the **-F** or **-p** option is specified, any indicator character written after the pathname as described for those options.
>
> When **-m** is specified, the format used for the last element of the list shall be:
>
>
>     "%s\n", <pathname>
>
> The format used for each other element of the list shall be:
>
>
>     "%s,%s", <pathname>, <separator>
>
> where, if there is not room for the next element of the list to fit within the current line length, \<*separator*\> is a string containing an optional \<space\> character and a mandatory \<newline\> character; otherwise it is a single \<space\> character.
>
> If the **-i** option is specified, the file's file serial number (see XBD [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html)) shall be written in the following format before any other output for the corresponding entry:
>
>
>     %u ", <file serial number>
>
> If the **-l** option is specified, the following information shall be written for files other than character special and block special files:
>
>
>     "%s %u %s %s %u %s %s\n", <file mode>, <number of links>,
>         <owner name>, <group name>, <size>, <date and time>,
>         <pathname>
>
> If the **-l** option is specified, the following information shall be written for character special and block special files:
>
>
>     "%s %u %s %s %s %s %s\n", <file mode>, <number of links>,
>         <owner name>, <group name>, <device info>, <date and time>,
>         <pathname>
>
> In both cases if the file is a symbolic link and the **-L** option is also specified, this information shall be for the file resolved from the symbolic link, except that the \<*pathname*\> field shall contain the pathname of the symbolic link itself. If the file is a symbolic link and the **-L** option is not specified, this information shall be about the link itself and the \<*pathname*\> field shall be one of the following forms:
>
> - `"%s%sΔ->Δ%s", <`*pathname of link*`>, <`*link type indicator*`>, <`*contents of link*`>`
>
> - `"%sΔ->Δ%s%s", <`*pathname of link*`>, <`*contents of link*`>, <`*file type indicator*`>`
>
> - `"%s%sΔ->Δ%s%s", <`*pathname of link*`>, <`*link type indicator*`>, <`*contents of link*`>, <`*file type indicator*`>`
>
> where \<*link type indicator*\> is a \<commercial-at\> (`'@'`) if the **-F** option is specified, or an empty string otherwise and \<*file type indicator*\> is the required indicator character, if any, for the file resolved from the symbolic link if the **-F** or **-p** option is specified, or an empty string otherwise. If pathname resolution fails when following the symbolic link, this shall not be treated as an error and the \<*file type indicator*\> field shall be an empty string.
>
> The **-n**, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-g**, and **-o** <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> options use the same format as **-l**, but with omitted items and their associated \<blank\> characters. See the OPTIONS section.
>
> In both the preceding **-l** forms, if \<*owner name*\> or \<*group name*\> cannot be determined, or if **-n** is given, they shall be replaced with their associated numeric values using the format `%u`.
>
> The \<*size*\> field shall contain the value that would be returned for the file in the *st_size* field of **struct stat** (see XBD [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html)). Note that for some file types this value is unspecified.
>
> The \<*device info*\> field shall contain implementation-defined information associated with the device in question.
>
> The \<*date and time*\> field shall contain the appropriate date and timestamp of when the file was last modified. In the POSIX locale, the field shall be the equivalent of the output of the following [*date*](../utilities/date.html) command:
>
>
>     date "+%b %e %H:%M"
>
> if the file has been modified in the last six months, or:
>
>
>     date "+%b %e %Y"
>
> (where two \<space\> characters are used between `%e` and `%Y`) if the file has not been modified in the last six months or if the modification date is in the future, except that, in both cases, the final \<newline\> produced by [*date*](../utilities/date.html) shall not be included and the output shall be as if the [*date*](../utilities/date.html) command were executed at the time of the last modification date of the file rather than the current time. When the *LC_TIME* locale category is not set to the POSIX locale, a different format and order of presentation of this field may be used.
>
> If the pathname was specified as a *file* operand, it shall be written as specified.
>
> The file mode written under the **-l**, **-n**, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-g**, and **-o** <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> options shall consist of the following format:
>
>
>     "%c%s%s%s%s", <entry type>, <owner permissions>,
>         <group permissions>, <other permissions>,
>         <optional alternate access method flag>
>
> The \<*optional alternate access method flag*\> shall be the empty string if there is no alternate or additional access control method associated with the file; otherwise, it shall be a string containing a single printable character that is not a \<blank\>.
>
> The \<*entry type*\> character shall describe the type of file, as follows:
>
> `d`
>
> Directory.
>
> `b`
>
> Block special file.
>
> `c`
>
> Character special file.
>
> `l` (ell)
>
> Symbolic link.
>
> `p`
>
> FIFO.
>
> `s`
>
> Socket.
>
> `-`
>
> Regular file.
>
> Implementations may add other characters to this list to represent other implementation-defined file types.
>
> The next three fields shall be three characters each:
>
> \<*owner permissions*\>
>
> \
> Permissions for the file owner class (see XBD [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07) ).
>
> \<*group permissions*\>
>
> \
> Permissions for the file group class.
>
> \<*other permissions*\>
>
> \
> Permissions for the file other class.
>
> Each field shall have three character positions:
>
> 1.  If `'r'`, the file is readable; if `'-'`, the file is not readable.
>
> 2.  If `'w'`, the file is writable; if `'-'`, the file is not writable.
>
> 3.  The first of the following that applies:
>
>     `S`
>
>     If in \<*owner permissions*\>, the file is not executable and set-user-ID mode is set. If in \<*group permissions*\>, the file is not executable and set-group-ID mode is set.
>
>     `s`
>
>     If in \<*owner permissions*\>, the file is executable and set-user-ID mode is set. If in \<*group permissions*\>, the file is executable and set-group-ID mode is set.
>
>     `T`
>
>     <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If in \<*other permissions*\> and the file is a directory, search permission is not granted to others, and the restricted deletion flag is set. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
>     `t`
>
>     <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If in \<*other permissions*\> and the file is a directory, search permission is granted to others, and the restricted deletion flag is set. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
>     `x`
>
>     The file is executable or the directory is searchable.
>
>     `-`
>
>     None of the attributes of `'S'`, `'s'`, `'T'`, `'t'`, or `'x'` applies.
>
>     Implementations may add other characters to this list for the third character position. Such additions shall, however, be written in lowercase if the file is executable or searchable, and in uppercase if it is not.
>
> If any of the **-l**, **-n**, **-s**, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-g**, or **-o** <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> options is specified, each list of files within a directory shall be preceded by a status line indicating the number of file system blocks occupied by the listed files for that directory in 512-byte units if the **-k** option is not specified, or 1024-byte units if the **-k** option is specified, rounded up to the next integral number of units, if necessary. In the POSIX locale, the format shall be:
>
>
>     "total %u\n", <number of units in the directory>
>
> If more than one directory, or a combination of non-directory files and directories are written, either as a result of specifying multiple operands, or the **-R** option, each list of files within a directory shall be preceded by:
>
>
>     "\n%s:\n", <directory name>
>
> The above string may be omitted for the directory named by the operand if only one operand is present. It may also be omitted for dot (`'.'`) if no operands are present. If this string is the first thing to be written, the first \<newline\> shall not be written. This output shall precede the number of units in the directory.
>
> If the **-s** option is given, each file shall be written with the number of blocks used by the file. Along with **-C**, **-1**, **-m**, or **-x**, the number and a \<space\> shall precede the filename; with **-l**, **-n**, <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-g**, or **-o**, <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> they shall precede each line describing a file.

#### <span id="tag_20_73_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_73_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_73_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_73_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_73_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_73_16"></span>APPLICATION USAGE

> It is difficult for an application to use every part of the file modes field of *ls* **-l** in a portable manner. Certain file types and executable bits are not guaranteed to be exactly as shown, as implementations may have extensions. Applications can use this field to pass directly to a user printout or prompt, but actions based on its contents should generally be deferred, instead, to the [*test*](../utilities/test.html) utility.
>
> The output of *ls* (with the **-l** and related options) contains information that logically could be used by utilities such as [*chmod*](../utilities/chmod.html) and [*touch*](../utilities/touch.html) to restore files to a known state. However, this information is presented in a format that cannot be used directly by those utilities or be easily translated into a format that can be used. A character has been added to the end of the permissions string so that applications at least have an indication that they may be working in an area they do not understand instead of assuming that they can translate the permissions string into something that can be used. Future versions or related documents may define one or more specific characters to be used based on different standard additional or alternative access control mechanisms.
>
> As with many of the utilities that deal with filenames, the output of *ls* for multiple files or in one of the long listing formats must be used carefully on systems where filenames can contain embedded white space. Systems and system administrators should institute policies and user training to limit the use of such filenames.
>
> The number of disk blocks occupied by the file that it reports varies depending on underlying file system type, block size units reported, and the method of calculating the number of blocks. On some file system types, the number is the actual number of blocks occupied by the file (counting indirect blocks and ignoring holes in the file); on others it is calculated based on the file size (usually making an allowance for indirect blocks, but ignoring holes).
>
> The `total` number provided when using *ls* **-l** does not necessarily correspond to the space that would be reclaimed if all the listed files were removed, because of hard links (and symbolic links if **-L** is present). The space for each listed file is counted in the total regardless of any relationship between the files.

#### <span id="tag_20_73_17"></span>EXAMPLES

> An example of a small directory tree being fully listed with *ls* **-laRF a** in the POSIX locale:
>
>
>     a:
>     total 11
>     drwxr-xr-x   3 fox      prog          64 Jul  4 12:07 ./
>     drwxrwxrwx   4 fox      prog        3264 Jul  4 12:09 ../
>     drwxr-xr-x   2 fox      prog          48 Jul  4 12:07 b/
>     -rwxr--r--   1 fox      prog         572 Jul  4 12:07 foo*
>
>
>     a/b:
>     total 4
>     drwxr-xr-x   2 fox      prog          48 Jul  4 12:07 ./
>     drwxr-xr-x   3 fox      prog          64 Jul  4 12:07 ../
>     -rw-r--r--   1 fox      prog         700 Jul  4 12:07 bar
>
> where the `"a:"` line may be omitted by some implementations.

#### <span id="tag_20_73_18"></span>RATIONALE

> Some historical implementations of the *ls* utility show all entries in a directory except dot and dot-dot when a superuser invokes *ls* without specifying the **-a** option. When "normal" users invoke *ls* without specifying **-a**, they should not see information about any files with names beginning with a \<period\> unless they were named as *file* operands.
>
> Implementations are expected to traverse arbitrary depths when processing the **-R** option. The only limitation on depth should be based on running out of physical storage for keeping track of untraversed directories.
>
> The **-1** (one) option was historically found in BSD and BSD-derived implementations only. It is required in this volume of POSIX.1-2024 so that conforming applications might ensure that output is one entry per line, even if the output is to a terminal.
>
> The **-S** option was added in Issue 7, but had been provided by several implementations for many years. The description given in the standard documents historic practice, but does not match much of the documentation that described its behavior. Historical documentation typically described it as something like:
>
> **-S**
>
> Sort by size (largest size first) instead of by name. Special character devices (listed last) are sorted by name.
>
> even though the file type was never considered when sorting the output. Character special files do typically sort close to the end of the list because their file size on most implementations is zero. But they are sorted alphabetically with any other files that happen to have the same file size (zero), not sorted separately and added to the end.
>
> This volume of POSIX.1-2024 is frequently silent about what happens when mutually-exclusive options are specified. Except for **-R**, **-d**, and **-f**, the *ls* utility is required to accept multiple options from each mutually-exclusive option set without treating them as errors and to use the behavior specified by the last option given in each mutually-exclusive set. Since *ls* is one of the most aliased commands, it is important that the implementation perform intuitively. For example, if the alias were:
>
>
>     alias ls="ls -C"
>
> and the user typed *ls* **-1** (one), single-text-column output should result, not an error.
>
> The **-g**, **-l** (ell), **-n**, and **-o** options are not mutually-exclusive options. They all enable long format output. They work together to determine whether the file's owner is written (no if **-g** is present), file's group is written (no if **-o** is present), and if the file's group or owner is written whether it is written as the name (default) or a string representation of the UID or GID number (if **-n** is present). The **-C**, **-m**, **-x**, and **-1** (one) are mutually-exclusive options and the first three of these disable long format output. The **-1** (one) option does not directly change whether or not long format output is enabled, but by overriding **-C**, **-m**, and **-x**, it can re-enable long format output that had been disabled by one of these options.
>
> Earlier versions of this standard did not describe the BSD **-A** option (like **-a**, but dot and dot-dot are not written out). It has been added due to widespread implementation.
>
> Implementations may make **-q** the default for terminals to prevent trojan horse attacks on terminals with special escape sequences. This is not required because:
>
> - Some control characters may be useful on some terminals; for example, a system might write them as `"\001"` or `"^A"`.
>
> - Special behavior for terminals is not relevant to applications portability.
>
> An early proposal specified that the \<*optional alternate access method flag*\> had to be `'+'` if there was an alternate access method used on the file or \<space\> if there was not. This was changed to be \<space\> if there is not and a single printable character if there is. This was done for three reasons:
>
> 1.  There are historical implementations using characters other than `'+'`.
>
> 2.  There are implementations that vary this character used in that position to distinguish between various alternate access methods in use.
>
> 3.  The standard developers did not want to preclude future specifications that might need a way to specify more than one alternate access method.
>
> Nonetheless, implementations providing a single alternate access method are encouraged to use `'+'`.
>
> Earlier versions of this standard did not have the **-k** option, which meant that the **-s** option could not be used portably as its block size was implementation-defined, and the units used to specify the number of blocks occupied by files in a directory in an *ls* **-l** listing were fixed as 512-byte units. The **-k** option has been added to provide a way for the **-s** option to be used portably, and for consistency it also changes the aforementioned units from 512-byte to 1024-byte.
>
> The \<*date and time*\> field in the **-l** format is specified only for the POSIX locale. As noted, the format can be different in other locales. No mechanism for defining this is present in this volume of POSIX.1-2024, as the appropriate vehicle is a messaging system; that is, the format should be specified as a "message".

#### <span id="tag_20_73_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> Allowing **-f** to ignore the **-A**, **-g**, **-l**, **-n**, **-o**, and **-s** options may be removed in a future version.

#### <span id="tag_20_73_20"></span>SEE ALSO

> [*chmod*](../utilities/chmod.html#tag_20_17), [*find*](../utilities/find.html#), [*readlink*](../utilities/readlink.html#tag_20_101)
>
> XBD [*7.3.2 LC_COLLATE*](../basedefs/V1_chap07.html#tag_07_03_02), [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html)
>
> XSH [*fstatat*()](../functions/fstatat.html#)

#### <span id="tag_20_73_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_73_22"></span>Issue 5

> A second FUTURE DIRECTION is added.

#### <span id="tag_20_73_23"></span>Issue 6

> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - In the **-F** option, other symbols are allowed for other file types.
>
> Treatment of symbolic links is added, as defined in the IEEE P1003.2b draft standard.
>
> The Open Group Base Resolution bwg2001-010 is applied, adding the `T` and `t` fields as part of the XSI option.

#### <span id="tag_20_73_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#101 is applied, clarifying the optional alternate access method flag in the STDOUT section.
>
> Austin Group Interpretation 1003.1-2001 \#128 is applied, clarifying the DESCRIPTION and the definition of the **-R** option.
>
> Austin Group Interpretation 1003.1-2001 \#129 is applied, clarifying the behavior of *ls* when no operands are specified.
>
> Austin Group Interpretation 1003.1-2001 \#198 is applied, clarifying the requirements for the **-H** option.
>
> SD5-XCU-ERN-50 is applied, adding the **-A** option.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The **-S** option is added from The Open Group Technical Standard, 2006, Extended API Set Part 1.
>
> The **-f**, **-m**, **-n**, **-p**, **-s**, and **-x** options are moved from the XSI option to the Base.
>
> The description of the **-f**, **-s**, and **-t** options are revised and the **-k** option is added.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0098 \[424\], XCU/TC1-2008/0099 \[424\], XCU/TC1-2008/0100 \[424\], XCU/TC1-2008/0101 \[424\], XCU/TC1-2008/0102 \[424\], XCU/TC1-2008/0103 \[424\], XCU/TC1-2008/0104 \[424\], XCU/TC1-2008/0105 \[423,424\], XCU/TC1-2008/0106 \[424\], XCU/TC1-2008/0107 \[424\], XCU/TC1-2008/0108 \[424\], XCU/TC1-2008/0109 \[424\], XCU/TC1-2008/0110 \[424\], XCU/TC1-2008/0111 \[423\], XCU/TC1-2008/0112 \[117\], XCU/TC1-2008/0113 \[117\], XCU/TC1-2008/0114 \[117\], XCU/TC1-2008/0115 \[424\], and XCU/TC1-2008/0116 \[424\] are applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0115 \[963\] and XCU/TC2-2008/0116 \[963\] are applied.

#### <span id="tag_20_73_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 1023 is applied, clarifying the **-R** option with respect to subdirectory filenames beginning with a \<period\>.
>
> Austin Group Defect 1070 is applied, requiring that any filenames or pathnames that collate equally are further compared byte-by-byte using the collating sequence for the POSIX locale.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1146 is applied, clarifying the requirements for the status line written by *ls* **-l**.
>
> Austin Group Defect 1147 is applied, clarifying the requirements for trailing file type indicators (such as `'/'` for a directory).
>
> Austin Group Defect 1148 is applied, clarifying the behavior of the **-S** option for symbolic links.
>
> Austin Group Defect 1149 is applied, inserting a comma in the description of the **-r** option.
>
> Austin Group Defect 1185 is applied, changing the *COLUMNS* entry in ENVIRONMENT VARIABLES.
>
> Austin Group Defect 1217 is applied, adding file type indicators for sockets.
>
> Austin Group Defect 1261 is applied, changing the STDOUT and EXAMPLES sections in relation to the `<`*directory name*`>` output.
>
> Austin Group Defect 1457 is applied, adding [*readlink*](../utilities/readlink.html) to the SEE ALSO section.
>
> Austin Group Defect 1703 is applied, changing "at-sign" to "\<commercial-at\>".

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
