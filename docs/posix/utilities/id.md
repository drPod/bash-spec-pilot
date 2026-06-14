The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="id"></span> <span id="tag_20_59"></span>

#### <span id="tag_20_59_01"></span>NAME

> id — return user identity

#### <span id="tag_20_59_02"></span>SYNOPSIS

> `id`` `**`[`***`user`***`]`**\
> \
> `id -G`` `**`[`**`-n`**`] [`***`user`***`]`**\
> \
> `id -g`` `**`[`**`-nr`**`] [`***`user`***`]`**\
> \
> `id -u`` `**`[`**`-nr`**`] [`***`user`***`]`**\

#### <span id="tag_20_59_03"></span>DESCRIPTION

> If no *user* operand is provided, the *id* utility shall write the user and group IDs and the corresponding user and group names of the invoking process to standard output. If the effective and real IDs do not match, both shall be written. If multiple groups are supported by the underlying system (see the description of {NGROUPS_MAX} in the System Interfaces volume of POSIX.1-2024), the supplementary group affiliations of the invoking process shall also be written.
>
> If a *user* operand is provided and the process has appropriate privileges, the user and group IDs of the selected user shall be written. In this case, effective IDs shall be assumed to be identical to real IDs. If the selected user has more than one allowable group membership listed in the group database, these shall be written in the same manner as the supplementary groups described in the preceding paragraph.

#### <span id="tag_20_59_04"></span>OPTIONS

> The *id* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-G**
>
> Output all different group IDs (effective, real, and supplementary) only, using the format `"%u\n"`. If there is more than one distinct group affiliation, output each such affiliation, using the format `" %u"`, before the \<newline\> is output.
>
> **-g**
>
> Output only the effective group ID, using the format `"%u\n"`.
>
> **-n**
>
> Output the name in the format `"%s"` instead of the numeric ID using the format `"%u"`.
>
> **-r**
>
> Output the real ID instead of the effective ID.
>
> **-u**
>
> Output only the effective user ID, using the format `"%u\n"`.

#### <span id="tag_20_59_05"></span>OPERANDS

> The following operand shall be supported:
>
> *user*
>
> The login name for which information is to be written.

#### <span id="tag_20_59_06"></span>STDIN

> Not used.

#### <span id="tag_20_59_07"></span>INPUT FILES

> None.

#### <span id="tag_20_59_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *id*:
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

#### <span id="tag_20_59_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_59_10"></span>STDOUT

> The following formats shall be used when the *LC_MESSAGES* locale category specifies the POSIX locale. In other locales, the strings *uid*, *gid*, *euid*, *egid*, and *groups* may be replaced with more appropriate strings corresponding to the locale.
>
>
>     "uid=%u(%s) gid=%u(%s)\n", <real user ID>, <user-name>,
>         <real group ID>, <group-name>
>
> If the effective and real user IDs do not match, the following shall be inserted immediately before the `'\n'` character in the previous format:
>
>
>     " euid=%u(%s)"
>
> with the following arguments added at the end of the argument list:
>
>
>     <effective user ID>, <effective user-name>
>
> If the effective and real group IDs do not match, the following shall be inserted directly before the `'\n'` character in the format string (and after any addition resulting from the effective and real user IDs not matching):
>
>
>     " egid=%u(%s)"
>
> with the following arguments added at the end of the argument list:
>
>
>     <effective group-ID>, <effective group name>
>
> If the process has supplementary group affiliations or the selected user is allowed to belong to multiple groups, the first shall be added directly before the \<newline\> in the format string:
>
>
>     " groups=%u(%s)"
>
> with the following arguments added at the end of the argument list:
>
>
>     <supplementary group ID>, <supplementary group name>
>
> and the necessary number of the following added after that for any remaining supplementary group IDs:
>
>
>     ",%u(%s)"
>
> and the necessary number of the following arguments added at the end of the argument list:
>
>
>     <supplementary group ID>, <supplementary group name>
>
> If any of the user ID, group ID, effective user ID, effective group ID, or supplementary/multiple group IDs cannot be mapped by the system into printable user or group names, the corresponding `"(%s)"` and *name* argument shall be omitted from the corresponding format string.
>
> When any of the options are specified, the output format shall be as described in the OPTIONS section.

#### <span id="tag_20_59_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_59_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_59_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_59_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_59_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_59_16"></span>APPLICATION USAGE

> Output produced by the **-G** option and by the default case could potentially produce very long lines on systems that support large numbers of supplementary groups. (On systems with user and group IDs that are 32-bit integers and with group names with a maximum of 8 bytes per name, 93 supplementary groups plus distinct effective and real group and user IDs could theoretically overflow the 2048-byte {LINE_MAX} text file line limit on the default output case. It would take about 186 supplementary groups to overflow the 2048-byte barrier using *id* **-G**). This is not expected to be a problem in practice, but in cases where it is a concern, applications should consider using [*fold*](../utilities/fold.html) **-s** before post-processing the output of *id*.

#### <span id="tag_20_59_17"></span>EXAMPLES

> None.

#### <span id="tag_20_59_18"></span>RATIONALE

> The functionality provided by the 4 BSD *groups* utility can be simulated using:
>
>
>     id -Gn [ user ]
>
> The 4 BSD command *groups* was considered, but it was not included because it did not provide the functionality of the *id* utility of the SVID. Also, it was thought that it would be easier to modify *id* to provide the additional functionality necessary to systems with multiple groups than to invent another command.
>
> The options **-u**, **-g**, **-n**, and **-r** were added to ease the use of *id* with shell commands substitution. Without these options it is necessary to use some preprocessor such as [*sed*](../utilities/sed.html) to select the desired piece of information. Since output such as that produced by:
>
>
>     id -u -n
>
> is frequently wanted, it seemed desirable to add the options.

#### <span id="tag_20_59_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_59_20"></span>SEE ALSO

> [*fold*](../utilities/fold.html#), [*logname*](../utilities/logname.html#), [*who*](../utilities/who.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*getgid*()](../functions/getgid.html#), [*getgroups*()](../functions/getgroups.html#), [*getuid*()](../functions/getuid.html#)

#### <span id="tag_20_59_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_59_22"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_59_23"></span>Issue 8

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
