The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="umask"></span> <span id="tag_20_132"></span>

#### <span id="tag_20_132_01"></span>NAME

> umask — get or set the file mode creation mask

#### <span id="tag_20_132_02"></span>SYNOPSIS

> `umask`` `**`[`**`-S`**`] [`***`mask`***`]`**

#### <span id="tag_20_132_03"></span>DESCRIPTION

> The *umask* utility shall set the file mode creation mask of the current shell execution environment (see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13)) to the value specified by the *mask* operand. This mask shall affect the initial value of the file permission bits of subsequently created files. If *umask* is called in a subshell or separate utility execution environment, such as one of the following:
>
>
>     (umask 002)
>     nohup umask ...
>     find . -exec umask ... \;
>
> it shall not affect the file mode creation mask of the caller's environment.
>
> If the *mask* operand is not specified, the *umask* utility shall write to standard output the value of the file mode creation mask of the invoking process.

#### <span id="tag_20_132_04"></span>OPTIONS

> The *umask* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-S**
>
> Produce symbolic output.
>
> The default output style is unspecified, but shall be recognized on a subsequent invocation of *umask* on the same system as a *mask* operand to restore the previous file mode creation mask.

#### <span id="tag_20_132_05"></span>OPERANDS

> The following operand shall be supported:
>
> *mask*
>
> A string specifying the new file mode creation mask. The string is treated in the same way as the *mode* operand described in the EXTENDED DESCRIPTION section for [*chmod*](../utilities/chmod.html).
>
> For a *symbolic_mode* value, the new value of the file mode creation mask shall be the logical complement of the file permission bits portion of the file mode specified by the *symbolic_mode* string.
>
> In a *symbolic_mode* value, the permissions *op* characters `'+'` and `'-'` shall be interpreted relative to the current file mode creation mask; `'+'` shall cause the bits for the indicated permissions to be cleared in the mask; `'-'` shall cause the bits for the indicated permissions to be set in the mask.
>
> The interpretation of *mode* values that specify file mode bits other than the file permission bits is unspecified.
>
> In the octal integer form of *mode*, the specified bits are set in the file mode creation mask.
>
> The file mode creation mask shall be set to the resulting numeric value.
>
> The default output of a prior invocation of *umask* on the same system with no operand also shall be recognized as a *mask* operand.

#### <span id="tag_20_132_06"></span>STDIN

> Not used.

#### <span id="tag_20_132_07"></span>INPUT FILES

> None.

#### <span id="tag_20_132_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *umask*:
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

#### <span id="tag_20_132_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_132_10"></span>STDOUT

> When the *mask* operand is not specified, the *umask* utility shall write a message to standard output that can later be used as a *umask* *mask* operand.
>
> If **-S** is specified, the message shall be in the following format:
>
>
>     "u=%s,g=%s,o=%s\n", <owner permissions>, <group permissions>,
>         <other permissions>
>
> where the three values shall be combinations of letters from the set {*r*, *w*, *x*}; the presence of a letter shall indicate that the corresponding bit is clear in the file mode creation mask.
>
> If a *mask* operand is specified, there shall be no output written to standard output.

#### <span id="tag_20_132_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_132_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_132_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_132_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The file mode creation mask was successfully changed, or no *mask* operand was supplied.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_132_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_132_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> Since *umask* affects the current shell execution environment, it is generally provided as a shell regular built-in.
>
> In contrast to the negative permission logic provided by the file mode creation mask and the octal number form of the *mask* argument, the symbolic form of the *mask* argument specifies those permissions that are left alone.

#### <span id="tag_20_132_17"></span>EXAMPLES

> Either of the commands:
>
>
>     umask a=rx,ug+w
>
>
>     umask 002
>
> sets the mode mask so that subsequently created files have their S_IWOTH bit cleared.
>
> After setting the mode mask with either of the above commands, the *umask* command can be used to write out the current value of the mode mask:
>
>
>     $ umask
>     0002
>
> (The output format is unspecified, but historical implementations use the octal integer mode format.)
>
>
>     $ umask -S
>     u=rwx,g=rwx,o=rx
>
> Either of these outputs can be used as the mask operand to a subsequent invocation of the *umask* utility.
>
> Assuming the mode mask is set as above, the command:
>
>
>     umask g-w
>
> sets the mode mask so that subsequently created files have their S_IWGRP and S_IWOTH bits cleared.
>
> The command:
>
>
>     umask -- -w
>
> sets the mode mask so that subsequently created files have all their write bits cleared. Note that *mask* operands **-r**, **-w**, **-x** or anything beginning with a \<hyphen-minus\>, must be preceded by `"--"` to keep it from being interpreted as an option.

#### <span id="tag_20_132_18"></span>RATIONALE

> Since *umask* affects the current shell execution environment, it is generally provided as a shell regular built-in. If it is called in a subshell or separate utility execution environment, such as one of the following:
>
>
>     (umask 002)
>     nohup umask ...
>     find . -exec umask ... \;
>
> it does not affect the file mode creation mask of the environment of the caller.
>
> The description of the historical utility was modified to allow it to use the symbolic modes of [*chmod*](../utilities/chmod.html). The **-s** option used in early proposals was changed to **-S** because **-s** could be confused with a *symbolic_mode* form of mask referring to the S_ISUID and S_ISGID bits.
>
> The default output style is unspecified to permit implementors to provide migration to the new symbolic style at the time most appropriate to their users. A **-o** flag to force octal mode output was omitted because the octal mode may not be sufficient to specify all of the information that may be present in the file mode creation mask when more secure file access permission checks are implemented.
>
> It has been suggested that trusted systems developers might appreciate ameliorating the requirement that the mode mask "affects" the file access permissions, since it seems access control lists might replace the mode mask to some degree. The wording has been changed to say that it affects the file permission bits, and it leaves the details of the behavior of how they affect the file access permissions to the description in the System Interfaces volume of POSIX.1-2024.

#### <span id="tag_20_132_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_132_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*chmod*](../utilities/chmod.html#tag_20_17)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*umask*()](../functions/umask.html#tag_17_645)

#### <span id="tag_20_132_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_132_22"></span>Issue 6

> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - The octal mode is supported.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/34 is applied, making a correction to the RATIONALE.

#### <span id="tag_20_132_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0197 \[584\] is applied.

#### <span id="tag_20_132_24"></span>Issue 8

> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
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
