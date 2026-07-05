The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="type"></span> <span id="tag_20_130"></span>

#### <span id="tag_20_130_01"></span>NAME

> type — write a description of command type

#### <span id="tag_20_130_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` type`` `*`name`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_130_03"></span>DESCRIPTION

> The *type* utility shall indicate how each argument would be interpreted if used as a command name.

#### <span id="tag_20_130_04"></span>OPTIONS

> None.

#### <span id="tag_20_130_05"></span>OPERANDS

> The following operand shall be supported:
>
> *name*
>
> A name to be interpreted.

#### <span id="tag_20_130_06"></span>STDIN

> Not used.

#### <span id="tag_20_130_07"></span>INPUT FILES

> None.

#### <span id="tag_20_130_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *type*:
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
> Determine the location of messages objects and message catalogs.
>
> *PATH*
>
> Determine the location of *name*, as described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08).

#### <span id="tag_20_130_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_130_10"></span>STDOUT

> The standard output of *type* contains information about each operand in an unspecified format. The information provided typically identifies the operand as a shell built-in, function, alias, or keyword, and where applicable, may display the operand's pathname.

#### <span id="tag_20_130_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_130_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_130_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_130_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_130_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_130_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> Since *type* must be aware of the contents of the current shell execution environment (such as the lists of commands, functions, and built-ins processed by [*hash*](../utilities/hash.html)), it is always provided as a shell regular built-in. If it is called in a separate utility execution environment, such as one of the following:
>
>
>     nohup type writer
>     find . -type f -exec type {} +
>
> it might not produce accurate results.

#### <span id="tag_20_130_17"></span>EXAMPLES

> None.

#### <span id="tag_20_130_18"></span>RATIONALE

> None.

#### <span id="tag_20_130_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_130_20"></span>SEE ALSO

> [*command*](../utilities/command.html#), [*hash*](../utilities/hash.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_130_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_130_22"></span>Issue 8

> Austin Group Defect 248 is applied, changing a command line in the APPLICATION USAGE section.
>
> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
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
