The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="link"></span> <span id="tag_20_66"></span>

#### <span id="tag_20_66_01"></span>NAME

> link — call link function

#### <span id="tag_20_66_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` link`` `*`file1 file2`*` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_66_03"></span>DESCRIPTION

> The *link* utility shall perform the function call:
>
>
>     link(file1, file2);
>
> A user may need appropriate privileges to invoke the *link* utility.

#### <span id="tag_20_66_04"></span>OPTIONS

> None.

#### <span id="tag_20_66_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file1*
>
> The pathname of an existing file.
>
> *file2*
>
> The pathname of the new directory entry to be created.

#### <span id="tag_20_66_06"></span>STDIN

> Not used.

#### <span id="tag_20_66_07"></span>INPUT FILES

> Not used.

#### <span id="tag_20_66_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *link*:
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

#### <span id="tag_20_66_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_66_10"></span>STDOUT

> None.

#### <span id="tag_20_66_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_66_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_66_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_66_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_66_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_66_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_66_17"></span>EXAMPLES

> None.

#### <span id="tag_20_66_18"></span>RATIONALE

> None.

#### <span id="tag_20_66_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_66_20"></span>SEE ALSO

> [*ln*](../utilities/ln.html#), [*unlink*](../utilities/unlink.html#tag_20_139)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)
>
> XSH [*link*()](../functions/link.html#tag_17_304)

#### <span id="tag_20_66_21"></span>CHANGE HISTORY

> First released in Issue 5.

#### <span id="tag_20_66_22"></span>Issue 8

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
