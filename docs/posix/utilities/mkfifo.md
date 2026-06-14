The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="mkfifo"></span> <span id="tag_20_80"></span>

#### <span id="tag_20_80_01"></span>NAME

> mkfifo — make FIFO special files

#### <span id="tag_20_80_02"></span>SYNOPSIS

> `mkfifo`` `**`[`**`-m`` `*`mode`***`]`**` `*`file`*`...`

#### <span id="tag_20_80_03"></span>DESCRIPTION

> The *mkfifo* utility shall create the FIFO special files specified by the operands, in the order specified.
>
> For each *file* operand, the *mkfifo* utility shall perform actions equivalent to the [*mkfifo*()](../functions/mkfifo.html) function defined in the System Interfaces volume of POSIX.1-2024, called with the following arguments:
>
> 1.  The *file* operand is used as the *path* argument.
>
> 2.  The value of the bitwise-inclusive OR of S_IRUSR, S_IWUSR, S_IRGRP, S_IWGRP, S_IROTH, and S_IWOTH is used as the *mode* argument. (If the **-m** option is specified, the value of the [*mkfifo*()](../functions/mkfifo.html) *mode* argument is unspecified, but the FIFO shall at no time have permissions less restrictive than the **-m** *mode* option-argument.)

#### <span id="tag_20_80_04"></span>OPTIONS

> The *mkfifo* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-m ***mode*
>
> Set the file permission bits of the newly-created FIFO to the specified *mode* value. The *mode* option-argument shall be the same as the *mode* operand defined for the [*chmod*](../utilities/chmod.html) utility. In the *symbolic_mode* strings, the *op* characters `'+'` and `'-'` shall be interpreted relative to an assumed initial mode of *a*=*rw*.

#### <span id="tag_20_80_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of the FIFO special file to be created.

#### <span id="tag_20_80_06"></span>STDIN

> Not used.

#### <span id="tag_20_80_07"></span>INPUT FILES

> None.

#### <span id="tag_20_80_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *mkfifo*:
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

#### <span id="tag_20_80_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_80_10"></span>STDOUT

> Not used.

#### <span id="tag_20_80_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_80_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_80_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_80_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> All the specified FIFO special files were created successfully.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_80_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_80_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_80_17"></span>EXAMPLES

> None.

#### <span id="tag_20_80_18"></span>RATIONALE

> This utility was added to permit shell applications to create FIFO special files.
>
> The **-m** option was added to control the file mode, for consistency with the similar functionality provided by the [*mkdir*](../utilities/mkdir.html) utility.
>
> Early proposals included a **-p** option similar to the [*mkdir*](../utilities/mkdir.html) **-p** option that created intermediate directories leading up to the FIFO specified by the final component. This was removed because it is not commonly needed and is not common practice with similar utilities.
>
> The functionality of *mkfifo* is described substantially through a reference to the [*mkfifo*()](../functions/mkfifo.html) function in the System Interfaces volume of POSIX.1-2024. For example, by default, the mode of the FIFO file is affected by the file mode creation mask in accordance with the specified behavior of the [*mkfifo*()](../functions/mkfifo.html) function. In this way, there is less duplication of effort required for describing details of the file creation.

#### <span id="tag_20_80_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_80_20"></span>SEE ALSO

> [*chmod*](../utilities/chmod.html#tag_20_17), [*umask*](../utilities/umask.html#tag_20_132)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*mkfifo*()](../functions/mkfifo.html#tag_17_340)

#### <span id="tag_20_80_21"></span>CHANGE HISTORY

> First released in Issue 3.

#### <span id="tag_20_80_22"></span>Issue 6

> The **-m** option is aligned with the IEEE P1003.2b draft standard to clarify an ambiguity.

#### <span id="tag_20_80_23"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
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
