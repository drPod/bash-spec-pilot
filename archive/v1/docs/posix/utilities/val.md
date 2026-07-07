The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="val"></span> <span id="tag_20_145"></span>

#### <span id="tag_20_145_01"></span>NAME

> val — validate SCCS files (**DEVELOPMENT**)

#### <span id="tag_20_145_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` val -`\
> \
> `val`` `**`[`**`-s`**`] [`**`-m`` `*`name`***`] [`**`-r`` `*`SID`***`] [`**`-y`` `*`type`***`]`**` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_145_03"></span>DESCRIPTION

> The *val* utility shall determine whether the specified *file* is an SCCS file meeting the characteristics specified by the options.

#### <span id="tag_20_145_04"></span>OPTIONS

> The *val* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that the usage of the `'-'` operand is not strictly as intended by the guidelines (that is, reading options and operands from standard input).
>
> The following options shall be supported:
>
> **-m ***name*
>
> Specify a *name*, which is compared with the SCCS %**M**% keyword in *file*; see [*get*](../utilities/get.html#).
>
> **-r ***SID*
>
> Specify a *SID* (SCCS Identification String), an SCCS delta number. A check shall be made to determine whether the *SID* is ambiguous (for example, **-r 1** is ambiguous because it physically does not exist but implies 1.1, 1.2, and so on, which may exist) or invalid (for example, **-r 1.0** or **-r 1.1.0** are invalid because neither case can exist as a valid delta number). If the *SID* is valid and not ambiguous, a check shall be made to determine whether it actually exists.
>
> **-s**
>
> Silence the diagnostic message normally written to standard output for any error that is detected while processing each named file on a given command line.
>
> **-y ***type*
>
> Specify a *type*, which shall be compared with the SCCS %**Y**% keyword in *file*; see [*get*](../utilities/get.html#).

#### <span id="tag_20_145_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file*
>
> A pathname of an existing SCCS file. If exactly one *file* operand appears, and it is `'-'`, the standard input shall be read: each line shall be independently processed as if it were a command line argument list. (However, the line is not subjected to any of the shell word expansions, such as parameter expansion or quote removal.)

#### <span id="tag_20_145_06"></span>STDIN

> The standard input shall be a text file used only when the *file* operand is specified as `'-'`.

#### <span id="tag_20_145_07"></span>INPUT FILES

> Any SCCS files processed shall be files of an unspecified format.

#### <span id="tag_20_145_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *val*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error, and informative messages written to standard output.
>
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_145_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_145_10"></span>STDOUT

> The standard output shall consist of informative messages about either:
>
> 1.  Each file processed
>
> 2.  Each command line read from standard input
>
> If the standard input is not used, for each *file* operand yielding a discrepancy, the output line shall have the following format:
>
>
>     "%s: %s\n", <pathname>, <unspecified string>
>
> If the standard input is used, for each input line yielding a discrepancy, the output shall have the following format:
>
>
>     "%s\n\n %s: %s\n", <input>, <pathname>, <unspecified string>
>
> where \<*input*\> is the input line minus its terminating \<newline\>.

#### <span id="tag_20_145_11"></span>STDERR

> Not used.

#### <span id="tag_20_145_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_145_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_145_14"></span>EXIT STATUS

> The 8-bit code returned by *val* shall be a disjunction of the possible errors; that is, it can be interpreted as a bit string where set bits are interpreted as follows:
>
> |      |     |                                    |
> |:-----|:---:|:-----------------------------------|
> | 0x80 |  =  | Missing file argument.             |
> | 0x40 |  =  | Unknown or duplicate option.       |
> | 0x20 |  =  | Corrupted SCCS file.               |
> | 0x10 |  =  | Cannot open file or file not SCCS. |
> | 0x08 |  =  | *SID* is invalid or ambiguous.     |
> | 0x04 |  =  | *SID* does not exist.              |
> | 0x02 |  =  | %**Y**%, **-y** mismatch.          |
> | 0x01 |  =  | %**M**%, **-m** mismatch.          |
>
> Note that *val* can process two or more files on a given command line and can process multiple command lines (when reading the standard input). In these cases an aggregate code shall be returned: a logical OR of the codes generated for each command line and file processed.

#### <span id="tag_20_145_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_145_16"></span>APPLICATION USAGE

> Since the *val* exit status sets the 0x80 bit, shell applications checking `"$?"` cannot tell if it terminated due to a missing file argument or receipt of a signal.

#### <span id="tag_20_145_17"></span>EXAMPLES

> In a directory with three SCCS files—**s.x** (of **t** type "text"), **s.y**, and **s.z** (a corrupted file)—the following command could produce the output shown:
>
>
>     val - <<EOF
>     -y source s.x
>     -m y s.y
>     s.z
>     EOF
>     -y source s.x
>
>
>         s.x: %Y%, -y mismatch
>     s.z
>
>
>         s.z: corrupted SCCS file

#### <span id="tag_20_145_18"></span>RATIONALE

> None.

#### <span id="tag_20_145_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_145_20"></span>SEE ALSO

> [*admin*](../utilities/admin.html#), [*delta*](../utilities/delta.html#), [*get*](../utilities/get.html#), [*prs*](../utilities/prs.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_145_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_145_22"></span>Issue 6

> The Open Group Corrigendum U025/4 is applied, correcting a typographical error in the EXIT STATUS.

#### <span id="tag_20_145_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0147 \[416\] and XCU/TC1-2008/0148 \[416\] are applied.

#### <span id="tag_20_145_24"></span>Issue 8

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
