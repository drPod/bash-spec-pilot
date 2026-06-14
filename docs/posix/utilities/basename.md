The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="basename"></span> <span id="tag_20_07"></span>

#### <span id="tag_20_07_01"></span>NAME

> basename — return non-directory portion of a pathname

#### <span id="tag_20_07_02"></span>SYNOPSIS

> `basename`` `*`string`*` `**`[`***`suffix`***`]`**

#### <span id="tag_20_07_03"></span>DESCRIPTION

> The *string* operand shall be treated as a pathname, as defined in XBD [*3.254 Pathname*](../basedefs/V1_chap03.html#tag_03_254). The string *string* shall be converted to the filename corresponding to the last pathname component in *string* and then the suffix string *suffix*, if present, shall be removed. This shall be done by performing actions equivalent to the following steps in order:
>
> 1.  If *string* is a null string, it is unspecified whether the resulting string is `'.'` or a null string. In either case, skip steps 2 through 6.
>
> 2.  If *string* is `"//"`, it is implementation-defined whether steps 3 to 6 are skipped or processed.
>
> 3.  If *string* consists entirely of \<slash\> characters, *string* shall be set to a single \<slash\> character. In this case, skip steps 4 to 6.
>
> 4.  If there are any trailing \<slash\> characters in *string*, they shall be removed.
>
> 5.  If there are any \<slash\> characters remaining in *string*, the prefix of *string* up to and including the last \<slash\> character in *string* shall be removed.
>
> 6.  If the *suffix* operand is present, is not identical to the characters remaining in *string*, and is identical to a suffix of the characters remaining in *string*, the suffix *suffix* shall be removed from *string*. Otherwise, *string* is not modified by this step. It shall not be considered an error if *suffix* is not found in *string*.
>
> The resulting string shall be written to standard output.

#### <span id="tag_20_07_04"></span>OPTIONS

> None.

#### <span id="tag_20_07_05"></span>OPERANDS

> The following operands shall be supported:
>
> *string*
>
> A string.
>
> *suffix*
>
> A string.

#### <span id="tag_20_07_06"></span>STDIN

> Not used.

#### <span id="tag_20_07_07"></span>INPUT FILES

> None.

#### <span id="tag_20_07_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *basename*:
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

#### <span id="tag_20_07_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_07_10"></span>STDOUT

> The *basename* utility shall write a line to the standard output in the following format:
>
>
>     "%s\n", <resulting string>

#### <span id="tag_20_07_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_07_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_07_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_07_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_07_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_07_16"></span>APPLICATION USAGE

> The definition of *pathname* specifies implementation-defined behavior for pathnames starting with two \<slash\> characters. Therefore, applications shall not arbitrarily add \<slash\> characters to the beginning of a pathname unless they can ensure that there are more or less than two or are prepared to deal with the implementation-defined consequences.

#### <span id="tag_20_07_17"></span>EXAMPLES

> If the string *string* is a valid pathname:
>
>
>     $(basename -- "string")
>
> produces a filename that could be used to open the file named by *string* in the directory returned by:
>
>
>     $(dirname -- "string")
>
> If the string *string* is not a valid pathname, the same algorithm is used, but the result need not be a valid filename. The *basename* utility is not expected to make any judgements about the validity of *string* as a pathname; it just follows the specified algorithm to produce a result string.
>
> The following shell script compiles **/usr/src/cmd/cat.c** and moves the output to a file named **cat** in the current directory when invoked with the argument **/usr/src/cmd/cat** or with the argument **/usr/src/cmd/cat.c**:
>
>
>     c17 -- "$(dirname -- "$1")/$(basename -- "$1" .c).c" &&
>     mv a.out "$(basename -- "$1" .c)"
>
> The EXAMPLES section of the [*basename*()](../functions/basename.html) function (see XSH [*basename*()](../functions/basename.html#tag_17_42)) includes a table showing examples of the results of processing several sample pathnames by the [*basename*()](../functions/basename.html) and [*dirname*()](../functions/dirname.html) functions and by the *basename* and [*dirname*](../utilities/dirname.html) utilities.

#### <span id="tag_20_07_18"></span>RATIONALE

> The behaviors of *basename* and [*dirname*](../utilities/dirname.html) have been coordinated so that when *string* is a valid pathname:
>
>
>     $(basename -- "string")
>
> would be a valid filename for the file in the directory:
>
>
>     $(dirname -- "string")
>
> This would not work for the early proposal versions of these utilities due to the way it specified handling of trailing \<slash\> characters.
>
> Since the definition of *pathname* specifies implementation-defined behavior for pathnames starting with two \<slash\> characters, this volume of POSIX.1-2024 specifies similar implementation-defined behavior for the *basename* and [*dirname*](../utilities/dirname.html) utilities.

#### <span id="tag_20_07_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_07_20"></span>SEE ALSO

> [*2.5 Parameters and Variables*](../utilities/V3_chap02.html#tag_19_05), [*dirname*](../utilities/dirname.html#tag_20_35)
>
> XBD [*3.254 Pathname*](../basedefs/V1_chap03.html#tag_03_254), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)
>
> XSH [*basename*()](../functions/basename.html#tag_17_42), [*dirname*()](../functions/dirname.html#tag_17_108)

#### <span id="tag_20_07_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_07_22"></span>Issue 6

> IEEE PASC Interpretation 1003.2 \#164 is applied.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_07_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0065 \[192,538\], XCU/TC1-2008/0066 \[192,538\], and XCU/TC1-2008/0067 \[192,430,538\] are applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0065 \[612\] is applied.

#### <span id="tag_20_07_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
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
