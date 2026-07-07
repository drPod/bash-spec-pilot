The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="rmdir"></span> <span id="tag_20_106"></span>

#### <span id="tag_20_106_01"></span>NAME

> rmdir — remove directories

#### <span id="tag_20_106_02"></span>SYNOPSIS

> `rmdir`` `**`[`**`-p`**`]`**` `*`dir`*`...`

#### <span id="tag_20_106_03"></span>DESCRIPTION

> The *rmdir* utility shall remove the directory entry specified by each *dir* operand.
>
> For each *dir* operand, the *rmdir* utility shall perform actions equivalent to the [*rmdir*()](../functions/rmdir.html) function called with the *dir* operand as its only argument.
>
> Directories shall be processed in the order specified. If a directory and a subdirectory of that directory are specified in a single invocation of the *rmdir* utility, the application shall specify the subdirectory before the parent directory so that the parent directory is empty when the *rmdir* utility tries to remove it.

#### <span id="tag_20_106_04"></span>OPTIONS

> The *rmdir* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-p**
>
> Remove all directories in a pathname. For each *dir* operand:
>
> 1.  The directory entry it names shall be removed.
>
> 2.  If the *dir* operand includes more than one pathname component, effects equivalent to the following command shall occur:
>
>
>         rmdir -p $(dirname dir)

#### <span id="tag_20_106_05"></span>OPERANDS

> The following operand shall be supported:
>
> *dir*
>
> A pathname of an empty directory to be removed.

#### <span id="tag_20_106_06"></span>STDIN

> Not used.

#### <span id="tag_20_106_07"></span>INPUT FILES

> None.

#### <span id="tag_20_106_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *rmdir*:
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

#### <span id="tag_20_106_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_106_10"></span>STDOUT

> Not used.

#### <span id="tag_20_106_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_106_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_106_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_106_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Each directory entry specified by a *dir* operand was removed successfully.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_106_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_106_16"></span>APPLICATION USAGE

> The definition of an empty directory is one that contains, at most, directory entries for dot and dot-dot.

#### <span id="tag_20_106_17"></span>EXAMPLES

> If a directory **a** in the current directory is empty except it contains a directory **b** and **a/b** is empty except it contains a directory **c**:
>
>
>     rmdir -p a/b/c
>
> removes all three directories.

#### <span id="tag_20_106_18"></span>RATIONALE

> On historical System V systems, the **-p** option also caused a message to be written to the standard output. The message indicated whether the whole path was removed or whether part of the path remained for some reason. The STDERR section requires this diagnostic when the entire path specified by a *dir* operand is not removed, but does not allow the status message reporting success to be written as a diagnostic.
>
> The *rmdir* utility on System V also included a **-s** option that suppressed the informational message output by the **-p** option. This option has been omitted because the informational message is not specified by this volume of POSIX.1-2024.

#### <span id="tag_20_106_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_106_20"></span>SEE ALSO

> [*rm*](../utilities/rm.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*remove*()](../functions/remove.html#), [*rmdir*()](../functions/rmdir.html#tag_17_493), [*unlink*()](../functions/unlink.html#tag_17_649)

#### <span id="tag_20_106_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_106_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_106_23"></span>Issue 8

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
