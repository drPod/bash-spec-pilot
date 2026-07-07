The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="expand"></span> <span id="tag_20_41"></span>

#### <span id="tag_20_41_01"></span>NAME

> expand — convert tabs to spaces

#### <span id="tag_20_41_02"></span>SYNOPSIS

> `expand`` `**`[`**`-t`` `*`tablist`***`] [`***`file`*`...`**`]`**

#### <span id="tag_20_41_03"></span>DESCRIPTION

> The *expand* utility shall write files or the standard input to the standard output with \<tab\> characters replaced with one or more \<space\> characters needed to pad to the next tab stop. Any \<backspace\> characters shall be copied to the output and cause the column position count for tab stop calculations to be decremented; the column position count shall not be decremented below zero.

#### <span id="tag_20_41_04"></span>OPTIONS

> The *expand* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-t ***tablist*
>
> Specify the tab stops. The application shall ensure that the argument *tablist* consists of either a single positive decimal integer or a list of tabstops. If a single number is given, tabs shall be set that number of column positions apart instead of the default 8.
>
> If a list of tabstops is given, the application shall ensure that it consists of a list of two or more positive decimal integers, separated by \<blank\> or \<comma\> characters, in ascending order. The \<tab\> characters shall be set at those specific column positions. Each tab stop *N* shall be an integer value greater than zero, and the list is in strictly ascending order. This is taken to mean that, from the start of a line of output, tabbing to position *N* shall cause the next character output to be in the (*N*+1)th column position on that line.
>
> In the event of *expand* having to process a \<tab\> at a position beyond the last of those specified in a multiple tab-stop list, the \<tab\> shall be replaced by a single \<space\> in the output.

#### <span id="tag_20_41_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> The pathname of a text file to be used as input.

#### <span id="tag_20_41_06"></span>STDIN

> See the INPUT FILES section.

#### <span id="tag_20_41_07"></span>INPUT FILES

> Input files shall be text files.

#### <span id="tag_20_41_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *expand*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files), the processing of \<tab\> and \<space\> characters, and for the determination of the width in column positions each character would occupy on an output device.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_41_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_41_10"></span>STDOUT

> The standard output shall be equivalent to the input files with \<tab\> characters converted into the appropriate number of \<space\> characters.

#### <span id="tag_20_41_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_41_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_41_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_41_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion
>
> \>0
>
> An error occurred.

#### <span id="tag_20_41_15"></span>CONSEQUENCES OF ERRORS

> The *expand* utility shall terminate with an error message and non-zero exit status upon encountering difficulties accessing one of the *file* operands.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_41_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_41_17"></span>EXAMPLES

> None.

#### <span id="tag_20_41_18"></span>RATIONALE

> The *expand* utility is useful for preprocessing text files (before sorting, looking at specific columns, and so on) that contain \<tab\> characters.
>
> See XBD [*3.75 Column Position*](../basedefs/V1_chap03.html#tag_03_75).
>
> The *tablist* option-argument consists of integers in ascending order. Utility Syntax Guideline 8 mandates that *expand* shall accept the integers (within the single argument) separated using either \<comma\> or \<blank\> characters.
>
> Earlier versions of this standard allowed the following form in the SYNOPSIS:
>
>
>     expand [-tabstop][-tab1,tab2,...,tabn][file ...]
>
> This form is no longer specified by POSIX.1-2024 but may be present in some implementations.

#### <span id="tag_20_41_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_41_20"></span>SEE ALSO

> [*tabs*](../utilities/tabs.html#), [*unexpand*](../utilities/unexpand.html#)
>
> XBD [*3.75 Column Position*](../basedefs/V1_chap03.html#tag_03_75), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_41_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_41_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The APPLICATION USAGE section is added.
>
> The obsolescent SYNOPSIS is removed.
>
> The *LC_CTYPE* environment variable description is updated to align with the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_41_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The *expand* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.

#### <span id="tag_20_41_24"></span>Issue 8

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
