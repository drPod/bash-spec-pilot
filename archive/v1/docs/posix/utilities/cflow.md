The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="cflow"></span> <span id="tag_20_15"></span>

#### <span id="tag_20_15_01"></span>NAME

> cflow — generate a C-language flowgraph (**DEVELOPMENT**)

#### <span id="tag_20_15_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` cflow`` `**`[`**`-r`**`] [`**`-d`` `*`num`***`] [`**`-D`` `*`name`***`[`**`=`*`def`***`]]`**`...`` `**`[`**`-i`` `*`incl`***`] [`**`-I`` `*`dir`***`]`**`...`\
> `      `` `**`[`**`-U`` `*`dir`***`]`**`...`` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_15_03"></span>DESCRIPTION

> The *cflow* utility shall analyze a collection of object files or assembler, C-language, [*lex*](../utilities/lex.html), or [*yacc*](../utilities/yacc.html) source files, and attempt to build a graph, written to standard output, charting the external references.

#### <span id="tag_20_15_04"></span>OPTIONS

> The *cflow* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that the order of the **-D**, **-I**, and **-U** options (which are identical to their interpretation by [*c17*](../utilities/c17.html)) is significant.
>
> The following options shall be supported:
>
> **-d ***num*
>
> Indicate the depth at which the flowgraph is cut off. The application shall ensure that the argument *num* is a decimal integer. By default this is a very large number (typically greater than 32000). Attempts to set the cut-off depth to a non-positive integer shall be ignored.
>
> **-i ***incl*
>
> Increase the number of included symbols. The *incl* option-argument is one of the following characters:
>
> *x*
>
> Include external and static data symbols. The default shall be to include only functions in the flowgraph.
>
> `_`
>
> (Underscore) Include names that begin with an \<underscore\>. The default shall be to exclude these functions (and data if **-i x** is used).
>
> **-r**
>
> Reverse the caller:callee relationship, producing an inverted listing showing the callers of each function. The listing shall also be sorted in lexicographical order by callee.

#### <span id="tag_20_15_05"></span>OPERANDS

> The following operand is supported:
>
> *file*
>
> The pathname of a file for which a graph is to be generated. Filenames suffixed by **.l** shall shall be taken to be [*lex*](../utilities/lex.html) input, **.y** as [*yacc*](../utilities/yacc.html) input, **.c** as [*c17*](../utilities/c17.html) input, and **.i** as the output of [*c17*](../utilities/c17.html) **-E**. Such files shall be processed as appropriate, determined by their suffix.
>
> Files suffixed by **.s** (conventionally assembler source) may have more limited information extracted from them.

#### <span id="tag_20_15_06"></span>STDIN

> Not used.

#### <span id="tag_20_15_07"></span>INPUT FILES

> The input files shall be object files or assembler, C-language, [*lex*](../utilities/lex.html), or [*yacc*](../utilities/yacc.html) source files.

#### <span id="tag_20_15_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *cflow*:
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
> Determine the locale for the ordering of the output when the **-r** option is used.
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

#### <span id="tag_20_15_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_15_10"></span>STDOUT

> The flowgraph written to standard output shall be formatted as follows:
>
>
>     "%d %s:%s\n", <reference number>, <global>, <definition>
>
> Each line of output begins with a reference (that is, line) number, followed by indentation of at least one column position per level. This is followed by the name of the global, a \<colon\>, and its definition. Normally globals are only functions not defined as an external or beginning with an \<underscore\>; see the OPTIONS section for the **-i** inclusion option. For information extracted from C-language source, the definition consists of an abstract type declaration (for example, **char \***) and, delimited by angle brackets, the name of the source file and the line number where the definition was found. Definitions extracted from object files indicate the filename and location counter under which the symbol appeared (for example, *text*).
>
> Once a definition of a name has been written, subsequent references to that name contain only the reference number of the line where the definition can be found. For undefined references, only `"<>"` shall be written.

#### <span id="tag_20_15_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_15_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_15_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_15_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_15_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_15_16"></span>APPLICATION USAGE

> Files produced by [*lex*](../utilities/lex.html) and [*yacc*](../utilities/yacc.html) cause the reordering of line number declarations, and this can confuse *cflow*. To obtain proper results, the input of [*yacc*](../utilities/yacc.html) or [*lex*](../utilities/lex.html) must be directed to *cflow*.

#### <span id="tag_20_15_17"></span>EXAMPLES

> Given the following in **file.c**:
>
>
>     int i;
>     int f();
>     int g();
>     int h();
>     int
>     main(void)
>     {
>         f();
>         g();
>         f();
>     }
>     int
>     f()
>     {
>         i = h();
>     }
>
> The command:
>
>
>     cflow -i x file.c
>
> produces the output:
>
>
>     1 main: int(), <file.c 6>
>     2    f: int(), <file.c 13>
>     3        h: <>
>     4        i: int, <file.c 1>
>     5    g: <>

#### <span id="tag_20_15_18"></span>RATIONALE

> None.

#### <span id="tag_20_15_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_15_20"></span>SEE ALSO

> [*c17*](../utilities/c17.html#), [*lex*](../utilities/lex.html#), [*yacc*](../utilities/yacc.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_15_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_15_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_15_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_15_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1195 is applied, changing "`main()`" to "`main(void)`".

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
