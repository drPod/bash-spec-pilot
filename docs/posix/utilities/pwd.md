The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="pwd"></span> <span id="tag_20_99"></span>

#### <span id="tag_20_99_01"></span>NAME

> pwd — return working directory name

#### <span id="tag_20_99_02"></span>SYNOPSIS

> `pwd`` `**`[`**`-L|-P`**`]`**

#### <span id="tag_20_99_03"></span>DESCRIPTION

> The *pwd* utility shall write to standard output an absolute pathname of the current working directory, which does not contain the filenames dot or dot-dot.

#### <span id="tag_20_99_04"></span>OPTIONS

> The *pwd* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported by the implementation:
>
> **-L**
>
> If the *PWD* environment variable contains an absolute pathname of the current directory and the pathname does not contain any components that are dot or dot-dot, *pwd* shall write this pathname to standard output, except that if the *PWD* environment variable is longer than {PATH_MAX} bytes including the terminating null, it is unspecified whether *pwd* writes this pathname to standard output or behaves as if the **-P** option had been specified. Otherwise, the **-L** option shall behave as the **-P** option.
>
> **-P**
>
> The pathname written to standard output shall not contain any components that refer to files of type symbolic link. If there are multiple pathnames that the *pwd* utility could write to standard output, one beginning with a single \<slash\> character and one or more beginning with two \<slash\> characters, then it shall write the pathname beginning with a single \<slash\> character. The pathname shall not contain any unnecessary \<slash\> characters after the leading one or two \<slash\> characters.
>
> If both **-L** and **-P** are specified, the last one shall apply. If neither **-L** nor **-P** is specified, the *pwd* utility shall behave as if **-L** had been specified.

#### <span id="tag_20_99_05"></span>OPERANDS

> None.

#### <span id="tag_20_99_06"></span>STDIN

> Not used.

#### <span id="tag_20_99_07"></span>INPUT FILES

> None.

#### <span id="tag_20_99_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *pwd*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *PWD*
>
> An absolute pathname of the current working directory. If an application sets or unsets the value of *PWD ,* the behavior of *pwd* is unspecified.

#### <span id="tag_20_99_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_99_10"></span>STDOUT

> The *pwd* utility output is an absolute pathname of the current working directory:
>
>
>     "%s\n", <directory pathname>

#### <span id="tag_20_99_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_99_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_99_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_99_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_99_15"></span>CONSEQUENCES OF ERRORS

> If an error is detected other than a write error when writing to standard output, no output shall be written to standard output, a diagnostic message shall be written to standard error, and the exit status shall be non-zero.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_99_16"></span>APPLICATION USAGE

> If the pathname obtained from *pwd* is longer than {PATH_MAX} bytes, it could produce an error if passed to [*cd*](../utilities/cd.html). Therefore, in order to return to that directory it may be necessary to break the pathname into sections shorter than {PATH_MAX} and call [*cd*](../utilities/cd.html) on each section in turn (the first section being an absolute pathname and subsequent sections being relative pathnames).

#### <span id="tag_20_99_17"></span>EXAMPLES

> None.

#### <span id="tag_20_99_18"></span>RATIONALE

> Some implementations have historically provided *pwd* as a shell special built-in command.
>
> In most utilities, if an error occurs, partial output may be written to standard output. This does not happen in historical implementations of *pwd* (unless an error condition causes a partial write). Because *pwd* is frequently used in historical shell scripts without checking the exit status, it is important that the historical behavior is required here; therefore, the CONSEQUENCES OF ERRORS section specifically disallows any partial output being written to standard output, except when a write error occurs when writing to standard output.
>
> An earlier version of this standard stated that the *PWD* environment variable was affected when the **-P** option was in effect. This was incorrect; conforming implementations do not do this.

#### <span id="tag_20_99_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_99_20"></span>SEE ALSO

> [*cd*](../utilities/cd.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*getcwd*()](../functions/getcwd.html#)

#### <span id="tag_20_99_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_99_22"></span>Issue 6

> The **-P** and **-L** options are added to describe actions relating to symbolic links as specified in the IEEE P1003.2b draft standard.

#### <span id="tag_20_99_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#097 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> Changes to the *pwd* utility and *PWD* environment variable have been made to match the changes to the [*getcwd*()](../functions/getcwd.html) function made for Austin Group Interpretation 1003.1-2001 \#140.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0161 \[471\] is applied.

#### <span id="tag_20_99_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1488 is applied, clarifying the behavior when a write error occurs when writing to standard output.

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
