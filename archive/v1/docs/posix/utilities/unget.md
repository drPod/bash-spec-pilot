The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="unget"></span> <span id="tag_20_137"></span>

#### <span id="tag_20_137_01"></span>NAME

> unget — undo a previous get of an SCCS file (**DEVELOPMENT**)

#### <span id="tag_20_137_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` unget`` `**`[`**`-ns`**`] [`**`-r`` `*`SID`***`]`**` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_137_03"></span>DESCRIPTION

> The *unget* utility shall reverse the effect of a [*get*](../utilities/get.html) **-e** done prior to creating the intended new delta.

#### <span id="tag_20_137_04"></span>OPTIONS

> The *unget* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-r ***SID*
>
> Uniquely identify which delta is no longer intended. (This would have been specified by [*get*](../utilities/get.html) as the new delta.) The use of this option is necessary only if two or more outstanding [*get*](../utilities/get.html) commands for editing on the same SCCS file were done by the same person (login name).
>
> **-s**
>
> Suppress the writing to standard output of the intended delta's SID.
>
> **-n**
>
> Retain the file that was obtained by [*get*](../utilities/get.html), which would normally be removed from the current directory.

#### <span id="tag_20_137_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file*
>
> A pathname of an existing SCCS file or a directory. If *file* is a directory, the *unget* utility shall behave as though each file in the directory were specified as a named file, except that non-SCCS files (last component of the pathname does not begin with **s.**) and unreadable files shall be silently ignored.
>
> If exactly one *file* operand appears, and it is `'-'`, the standard input shall be read; each line of the standard input shall be taken to be the name of an SCCS file to be processed. Non-SCCS files and unreadable files shall be silently ignored.

#### <span id="tag_20_137_06"></span>STDIN

> The standard input shall be a text file used only when the *file* operand is specified as `'-'`. Each line of the text file shall be interpreted as an SCCS pathname.

#### <span id="tag_20_137_07"></span>INPUT FILES

> Any SCCS files processed shall be files of an unspecified format.

#### <span id="tag_20_137_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *unget*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_137_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_137_10"></span>STDOUT

> The standard output shall consist of a line for each file, in the following format:
>
>
>     "%s\n", <SID removed from file>
>
> If there is more than one named file or if a directory or standard input is named, each pathname shall be written before each of the preceding lines:
>
>
>     "\n%s:\n", <pathname>

#### <span id="tag_20_137_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_137_12"></span>OUTPUT FILES

> Any SCCS files updated shall be files of an unspecified format. During processing of a *file*, a locking *z-file*, as described in [*get*](../utilities/get.html), and a *q-file* (a working copy of the *p-file*), may be created and deleted. The *p-file* and *g-file*, as described in [*get*](../utilities/get.html), shall be deleted.

#### <span id="tag_20_137_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_137_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_137_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_137_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_137_17"></span>EXAMPLES

> None.

#### <span id="tag_20_137_18"></span>RATIONALE

> None.

#### <span id="tag_20_137_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_137_20"></span>SEE ALSO

> [*delta*](../utilities/delta.html#), [*get*](../utilities/get.html#), [*sact*](../utilities/sact.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_137_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_137_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_137_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_137_24"></span>Issue 8

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
