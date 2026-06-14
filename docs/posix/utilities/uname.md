The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="uname"></span> <span id="tag_20_134"></span>

#### <span id="tag_20_134_01"></span>NAME

> uname — return system name

#### <span id="tag_20_134_02"></span>SYNOPSIS

> `uname`` `**`[`**`-amnrsv`**`]`**

#### <span id="tag_20_134_03"></span>DESCRIPTION

> By default, the *uname* utility shall write the operating system name to standard output. When options are specified, symbols representing one or more system characteristics shall be written to the standard output. The format and contents of the symbols are implementation-defined. On systems conforming to the System Interfaces volume of POSIX.1-2024, the symbols written shall be those supported by the [*uname*()](../functions/uname.html) function as defined in the System Interfaces volume of POSIX.1-2024.

#### <span id="tag_20_134_04"></span>OPTIONS

> The *uname* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a**
>
> Behave as though all of the options **-mnrsv** were specified.
>
> **-m**
>
> Write the name of the hardware type on which the system is running to standard output.
>
> **-n**
>
> Write the name of this node within an implementation-defined communications network.
>
> **-r**
>
> Write the current release level of the operating system implementation.
>
> **-s**
>
> Write the name of the implementation of the operating system.
>
> **-v**
>
> Write the current version level of this release of the operating system implementation.
>
> If no options are specified, the *uname* utility shall write the operating system name, as if the **-s** option had been specified.

#### <span id="tag_20_134_05"></span>OPERANDS

> None.

#### <span id="tag_20_134_06"></span>STDIN

> Not used.

#### <span id="tag_20_134_07"></span>INPUT FILES

> None.

#### <span id="tag_20_134_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *uname*:
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

#### <span id="tag_20_134_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_134_10"></span>STDOUT

> By default, the output shall be a single line of the following form:
>
>
>     "%s\n", <sysname>
>
> If the **-a** option is specified, the output shall be a single line of the following form:
>
>
>     "%s %s %s %s %s\n", <sysname>, <nodename>, <release>,
>         <version>, <machine>
>
> Additional implementation-defined symbols may be written; all such symbols shall be written at the end of the line of output before the \<newline\>.
>
> If options are specified to select different combinations of the symbols, only those symbols shall be written, in the order shown above for the **-a** option. If a symbol is not selected for writing, its corresponding trailing \<blank\> characters also shall not be written.

#### <span id="tag_20_134_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_134_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_134_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_134_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The requested information was successfully written.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_134_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_134_16"></span>APPLICATION USAGE

> Note that any of the symbols could include embedded \<space\> characters, which may affect parsing algorithms if multiple options are selected for output.
>
> The node name is typically a name that the system uses to identify itself for inter-system communication addressing.

#### <span id="tag_20_134_17"></span>EXAMPLES

> The following command:
>
>
>     uname -sr
>
> writes the operating system name and release level, separated by one or more \<blank\> characters.

#### <span id="tag_20_134_18"></span>RATIONALE

> It was suggested that this utility cannot be used portably since the format of the symbols is implementation-defined. The POSIX.1 working group could not achieve consensus on defining these formats in the underlying [*uname*()](../functions/uname.html) function, and there was no expectation that this volume of POSIX.1-2024 would be any more successful. Some applications may still find this historical utility of value. For example, the symbols could be used for system log entries or for comparison with operator or user input.

#### <span id="tag_20_134_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_134_20"></span>SEE ALSO

> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*uname*()](../functions/uname.html#tag_17_646)

#### <span id="tag_20_134_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_134_22"></span>Issue 8

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
