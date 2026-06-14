The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="tsort"></span> <span id="tag_20_128"></span>

#### <span id="tag_20_128_01"></span>NAME

> tsort — topological sort

#### <span id="tag_20_128_02"></span>SYNOPSIS

> `tsort`` `**`[`**`-w`**`] [`***`file`***`]`**

#### <span id="tag_20_128_03"></span>DESCRIPTION

> The *tsort* utility shall write to standard output a totally ordered list of items consistent with a partial ordering of items contained in the input.
>
> The application shall ensure that the input consists of pairs of items (non-empty strings) separated by one or more \<blank\> or \<newline\> characters. It is unspecified whether other white-space characters can also be used as separators. Pairs of different items shall indicate ordering. Pairs of identical items shall indicate presence, but not ordering.
>
> If a cycle is found in the input, diagnostic or warning messages shall be written to standard error reporting that there is a cycle and indicating which nodes are in the cycle(s). If the **-w** option is specified, these messages shall be diagnostic messages. If a diagnostic message is written, the final exit status shall be non-zero.

#### <span id="tag_20_128_04"></span>OPTIONS

> The *tsort* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-w**
>
> Set the exit status to the number of cycles found in the input, or to an implementation-defined maximum if there are more cycles than that maximum. If no cycles are found, the exit status shall be zero unless another error occurs.

#### <span id="tag_20_128_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a text file to order. If no *file* operand is given, the standard input shall be used.

#### <span id="tag_20_128_06"></span>STDIN

> The standard input shall be used if no *file* operand is specified, and shall be used if the *file* operand is `'-'` and the implementation treats the `'-'` as meaning standard input. Otherwise, the standard input shall not be used. See the INPUT FILES section.

#### <span id="tag_20_128_07"></span>INPUT FILES

> The input file shall be a text file.

#### <span id="tag_20_128_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *tsort*:
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
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_128_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_128_10"></span>STDOUT

> The standard output shall be a text file consisting of the ordered list of items, with one item per line, produced from the partially ordered input.

#### <span id="tag_20_128_11"></span>STDERR

> The standard error shall be used only for diagnostic and warning messages.

#### <span id="tag_20_128_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_128_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_128_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred. If the **-w** option is specified and one or more cycles were found in the input, the exit status shall be the number of cycles found, or an implementation-defined maximum if more cycles than that maximum were found.

#### <span id="tag_20_128_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_128_16"></span>APPLICATION USAGE

> The *LC_COLLATE* variable need not affect the actions of *tsort*. The output ordering is not lexicographic, but depends on the pairs of items given as input.

#### <span id="tag_20_128_17"></span>EXAMPLES

> The command:
>
>
>     tsort <<EOF
>     a b c c d e
>     g g
>     f g e f
>     h h
>     EOF
>
> produces the output:
>
>
>     a
>     b
>     c
>     d
>     e
>     f
>     g
>     h

#### <span id="tag_20_128_18"></span>RATIONALE

> At the time that the **-w** option was added to this standard, the only known implementation reported a maximum of 255 cycles via the exit status. This has the drawback that applications cannot distinguish, from the exit status, errors caused by cycles from other errors or (when *tsort* is executed from a shell) termination by a signal. Implementations are urged to set the implementation-defined maximum number of cycles reported via the exit status to at most 124, leaving values above that maximum through 125 for other errors, and leaving values 126 and greater to have the special meanings that the shell assigns to them.

#### <span id="tag_20_128_19"></span>FUTURE DIRECTIONS

> A future version of this standard may require that when the **-w** option is specified, the maximum number of cycles reported through the exit status of *tsort* is at most 124 and that exit status values greater than 126 are not used by *tsort*.

#### <span id="tag_20_128_20"></span>SEE ALSO

> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_128_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_128_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_128_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#092 is applied.
>
> The *tsort* utility is moved from the XSI option to the Base.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0146 \[241\] is applied.

#### <span id="tag_20_128_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defects 1617 and 1629 are applied, clarifying how *tsort* handles cycles found in the input.
>
> Austin Group Defect 1745 is applied, clarifying the input separator characters and the output format.

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
