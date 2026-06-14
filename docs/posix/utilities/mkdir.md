The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="mkdir"></span> <span id="tag_20_79"></span>

#### <span id="tag_20_79_01"></span>NAME

> mkdir — make directories

#### <span id="tag_20_79_02"></span>SYNOPSIS

> `mkdir`` `**`[`**`-p`**`] [`**`-m`` `*`mode`***`]`**` `*`dir`*`...`

#### <span id="tag_20_79_03"></span>DESCRIPTION

> The *mkdir* utility shall create the directories specified by the operands, in the order specified.
>
> For each *dir* operand, the *mkdir* utility shall perform actions equivalent to the [*mkdir*()](../functions/mkdir.html) function defined in the System Interfaces volume of POSIX.1-2024, called with the following arguments:
>
> 1.  The *dir* operand is used as the *path* argument.
>
> 2.  The value of the bitwise-inclusive OR of S_IRWXU, S_IRWXG, and S_IRWXO is used as the *mode* argument. (If the **-m** option is specified, the value of the [*mkdir*()](../functions/mkdir.html) *mode* argument is unspecified, but the directory shall at no time have permissions less restrictive than the **-m** *mode* option-argument.)

#### <span id="tag_20_79_04"></span>OPTIONS

> The *mkdir* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-m ***mode*
>
> Set the file permission bits of the newly-created directory to the specified *mode* value. The *mode* option-argument shall be the same as the *mode* operand defined for the [*chmod*](../utilities/chmod.html) utility. In the *symbolic_mode* strings, the *op* characters `'+'` and `'-'` shall be interpreted relative to an assumed initial mode of *a*=*rwx*; `'+'` shall add permissions to the default mode, `'-'` shall delete permissions from the default mode.
>
> **-p**
>
> Create any missing intermediate pathname components.
>
> For each *dir* operand that does not name an existing directory, before performing the actions described in the DESCRIPTION above, the *mkdir* utility shall create any pathname components of the path prefix of *dir* that do not name an existing directory by performing actions equivalent to first calling the [*mkdir*()](../functions/mkdir.html) function with the following arguments:
>
> 1.  A pathname naming the missing pathname component, ending with a trailing \<slash\> character, as the *path* argument
>
> 2.  The value zero as the *mode* argument
>
> and then calling the [*chmod*()](../functions/chmod.html) function with the following arguments:
>
> 1.  The same *path* argument as in the [*mkdir*()](../functions/mkdir.html) call
>
> 2.  The value `(S_IWUSR|S_IXUSR|~`*`filemask`*`)&0777` as the *mode* argument, where *filemask* is the file mode creation mask of the process (see XSH [*umask*()](../functions/umask.html#tag_17_645))
>
> Each *dir* operand that names an existing directory shall be ignored without error.

#### <span id="tag_20_79_05"></span>OPERANDS

> The following operand shall be supported:
>
> *dir*
>
> A pathname of a directory to be created.

#### <span id="tag_20_79_06"></span>STDIN

> Not used.

#### <span id="tag_20_79_07"></span>INPUT FILES

> None.

#### <span id="tag_20_79_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *mkdir*:
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

#### <span id="tag_20_79_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_79_10"></span>STDOUT

> Not used.

#### <span id="tag_20_79_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_79_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_79_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_79_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> All the specified directories were created successfully, or the **-p** option was specified and all the specified directories either already existed or were created successfully.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_79_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_79_16"></span>APPLICATION USAGE

> The default file mode for directories is *a*=*rwx* (777 on most systems) with selected permissions removed in accordance with the file mode creation mask. For intermediate pathname components created by *mkdir*, the mode is the default modified by *u*+*wx* so that the subdirectories can always be created regardless of the file mode creation mask; if different ultimate permissions are desired for the intermediate directories, they can be changed afterwards with [*chmod*](../utilities/chmod.html).
>
> Note that some of the requested directories may have been created even if an error occurs.

#### <span id="tag_20_79_17"></span>EXAMPLES

> None.

#### <span id="tag_20_79_18"></span>RATIONALE

> The System V **-m** option was included to control the file mode.
>
> The System V **-p** option was included to create any needed intermediate directories and to complement the functionality provided by [*rmdir*](../utilities/rmdir.html) for removing directories in the path prefix as they become empty. Because no error is produced if any path component already exists, the **-p** option is also useful to ensure that a particular directory exists.
>
> The functionality of *mkdir* is described substantially through a reference to the [*mkdir*()](../functions/mkdir.html) function in the System Interfaces volume of POSIX.1-2024. For example, by default, the mode of the directory is affected by the file mode creation mask in accordance with the specified behavior of the [*mkdir*()](../functions/mkdir.html) function. In this way, there is less duplication of effort required for describing details of the directory creation.

#### <span id="tag_20_79_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_79_20"></span>SEE ALSO

> [*chmod*](../utilities/chmod.html#tag_20_17), [*rm*](../utilities/rm.html#), [*rmdir*](../utilities/rmdir.html#tag_20_106), [*umask*](../utilities/umask.html#tag_20_132)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*mkdir*()](../functions/mkdir.html#tag_17_338), [*umask*()](../functions/umask.html#tag_17_645)

#### <span id="tag_20_79_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_79_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_79_23"></span>Issue 7

> SD5-XCU-ERN-56 is applied, aligning the **-m** option with the IEEE P1003.2b draft standard to clarify an ambiguity.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0122 \[161\] is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0145 \[843\] is applied.

#### <span id="tag_20_79_24"></span>Issue 8

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
