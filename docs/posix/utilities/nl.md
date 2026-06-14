The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="nl"></span> <span id="tag_20_87"></span>

#### <span id="tag_20_87_01"></span>NAME

> nl — line numbering filter

#### <span id="tag_20_87_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` nl`` `**`[`**`-p`**`] [`**`-b`` `*`type`***`] [`**`-d`` `*`delim`***`] [`**`-f`` `*`type`***`] [`**`-h`` `*`type`***`] [`**`-i`` `*`incr`***`] [`**`-l`` `*`num`***`]`\**
> ` ``      `` `**`[`**`-n`` `*`format`***`] [`**`-s`` `*`sep`***`] [`**`-v`` `*`startnum`***`] [`**`-w`` `*`width`***`] [`***`file`***`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_87_03"></span>DESCRIPTION

> The *nl* utility shall read lines from the named *file* or the standard input if no *file* is named and shall reproduce the lines to standard output. Lines shall be numbered on the left. Additional functionality may be provided in accordance with the command options in effect.
>
> The *nl* utility views the text it reads in terms of logical pages. Line numbering shall be reset at the start of each logical page. A logical page consists of a header, a body, and a footer section. Empty sections are valid. Different line numbering options are independently available for header, body, and footer (for example, no numbering of header and footer lines while numbering blank lines only in the body).
>
> The starts of logical page sections shall be signaled by input lines containing nothing but the following delimiter characters:
>
> | **Line** | **Start of** |
> |:---------|:-------------|
> | \\\\\\   | Header       |
> | \\\\     | Body         |
> | \\       | Footer       |
>
> Unless otherwise specified, *nl* shall assume the text being read is in a single logical page body.

#### <span id="tag_20_87_04"></span>OPTIONS

> The *nl* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02). Only one file can be named.
>
> The following options shall be supported:
>
> **-b ***type*
>
> Specify which logical page body lines shall be numbered. Recognized *types* and their meaning are:
>
> **a**
>
> Number all lines.
>
> **t**
>
> Number only non-empty lines.
>
> **n**
>
> No line numbering.
>
> **p***string*
>
> Number only lines that contain the basic regular expression specified in *string*.
>
> The default *type* for logical page body shall be **t** (text lines numbered).
>
> **-d ***delim*
>
> Specify the delimiter characters that indicate the start of a logical page section. These can be changed from the default characters `"\:"` to two user-specified characters. If only one character is entered, the second character shall remain the default character `':'`.
>
> **-f ***type*
>
> Specify the same as **b** *type* except for footer. The default for logical page footer shall be **n** (no lines numbered).
>
> **-h ***type*
>
> Specify the same as **b** *type* except for header. The default *type* for logical page header shall be **n** (no lines numbered).
>
> **-i ***incr*
>
> Specify the increment value used to number logical page lines. The default shall be 1.
>
> **-l ***num*
>
> Specify the number of blank lines to be considered as one. For example, **-l 2** results in only the second adjacent blank line being numbered (if the appropriate **-h a**, **-b a**, or **-f a** option is set). The default shall be 1.
>
> **-n ***format*
>
> Specify the line numbering format. Recognized values are: **ln**, left justified, leading zeros suppressed; **rn**, right justified, leading zeros suppressed; **rz**, right justified, leading zeros kept. The default *format* shall be **rn** (right justified).
>
> **-p**
>
> Specify that numbering should not be restarted at logical page delimiters.
>
> **-s ***sep*
>
> Specify the characters used in separating the line number and the corresponding text line. The default *sep* shall be a \<tab\>.
>
> **-v ***startnum*
>
> Specify the initial value used to number logical page lines. The default shall be 1.
>
> **-w ***width*
>
> Specify the number of characters to be used for the line number. The default *width* shall be 6.

#### <span id="tag_20_87_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a text file to be line-numbered.

#### <span id="tag_20_87_06"></span>STDIN

> The standard input shall be used if no *file* operand is specified, and shall be used if the *file* operand is `'-'` and the implementation treats the `'-'` as meaning standard input. Otherwise, the standard input shall not be used. See the INPUT FILES section.

#### <span id="tag_20_87_07"></span>INPUT FILES

> The input file shall be a text file.

#### <span id="tag_20_87_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *nl*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
>
> *LC_COLLATE*
>
> \
> Determine the locale for the behavior of ranges, equivalence classes, and multi-character collating elements within regular expressions.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files), the behavior of character classes within regular expressions, and for deciding which characters are in character class **graph** (for the **-b t**, **-f t**, and **-h t** options).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_87_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_87_10"></span>STDOUT

> The standard output shall be a text file in the following format:
>
>
>     "%s%s%s", <line number>, <separator>, <input line>
>
> where \<*line number*\> is one of the following numeric formats:
>
> `%6d`
>
> When the **rn** format is used (the default; see **-n**).
>
> `%06d`
>
> When the **rz** format is used.
>
> `%-6d`
>
> When the **ln** format is used.
>
> \<empty\>
>
> When line numbers are suppressed for a portion of the page; the \<*separator*\> is also suppressed.
>
> In the preceding list, the number 6 is the default width; the **-w** option can change this value.

#### <span id="tag_20_87_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_87_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_87_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_87_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_87_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_87_16"></span>APPLICATION USAGE

> In using the **-d** *delim* option, care should be taken to escape characters that have special meaning to the command interpreter.

#### <span id="tag_20_87_17"></span>EXAMPLES

> The command:
>
>
>     nl -v 10 -i 10 -d \!+ file1
>
> numbers *file1* starting at line number 10 with an increment of 10. The logical page delimiter is `"!+"`. Note that the `'!'` has to be escaped when using *csh* as a command interpreter because of its history substitution syntax. For *ksh* and [*sh*](../utilities/sh.html) the escape is not necessary, but does not do any harm.

#### <span id="tag_20_87_18"></span>RATIONALE

> None.

#### <span id="tag_20_87_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_87_20"></span>SEE ALSO

> [*pr*](../utilities/pr.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_87_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_87_22"></span>Issue 5

> The option \[**-f** *type*\] is added to the SYNOPSIS. The option descriptions are presented in alphabetic order. The description of **-bt** is changed to "Number only non-empty lines".

#### <span id="tag_20_87_23"></span>Issue 6

> The obsolescent behavior allowing the options to be intermingled with the optional *file* operand is removed.

#### <span id="tag_20_87_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#092 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_87_25"></span>Issue 8

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
