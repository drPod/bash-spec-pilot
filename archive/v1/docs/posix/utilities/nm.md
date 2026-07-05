The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="nm"></span> <span id="tag_20_88"></span>

#### <span id="tag_20_88_01"></span>NAME

> nm — write the name list of an object file (**DEVELOPMENT**)

#### <span id="tag_20_88_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`SD`](javascript:open_code('SD'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` nm`` `**`[`**`-APv`**`] [`**`-g|-u`**`] [`**`-t`` `*`format`***`]`**` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \
> \
>
> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` nm`` `**`[`**`-APv`**`] [`**`-efox`**`] [`**`-g|-u`**`] [`**`-t`` `*`format`***`]`**` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_88_03"></span>DESCRIPTION

> The *nm* utility shall display symbolic information appearing in the object file, executable file, or object-file library named by *file*. If no symbolic information is available for a valid input file, the *nm* utility shall report that fact, but not consider it an error condition.
>
> The default base used when numeric values are written is unspecified. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  On XSI-conformant systems, it shall be decimal if the **-P** option is not specified. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_88_04"></span>OPTIONS

> The *nm* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-A**
>
> Write the full pathname or library name of an object on each line.
>
> **-e**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write only external (global) and static symbol information. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-f**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Produce full output. Write redundant symbols (**.text**, **.data**, and **.bss**), normally suppressed. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-g**
>
> Write only external (global) symbol information.
>
> **-o**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write numeric values in octal (equivalent to **-t o**). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-P**
>
> Write information in a portable output format, as specified in the STDOUT section.
>
> **-t ***format*
>
> Write each numeric value in the specified format. The format shall be dependent on the single character used as the *format* option-argument:
>
> `d`
>
> decimal <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  (default if **-P** is not specified). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> `o`
>
> octal.
>
> `x`
>
> hexadecimal (default if **-P** is specified).
>
> **-u**
>
> Write only undefined symbols.
>
> **-v**
>
> Sort output by value instead of by symbol name.
>
> **-x**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write numeric values in hexadecimal (equivalent to **-t x**). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_88_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an object file, executable file, or object-file library.

#### <span id="tag_20_88_06"></span>STDIN

> See the INPUT FILES section.

#### <span id="tag_20_88_07"></span>INPUT FILES

> The input file shall be an object file, an object-file library whose format is the same as those produced by the [*ar*](../utilities/ar.html) utility for link editing, or an executable file. The *nm* utility may accept additional implementation-defined object library formats for the input file.

#### <span id="tag_20_88_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *nm*:
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
> Determine the locale for character collation information for the symbol-name and symbol-value collation sequences.
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

#### <span id="tag_20_88_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_88_10"></span>STDOUT

> If symbolic information is present in the input files, then for each file or for each member of an archive, the *nm* utility shall write the following information to standard output. By default, the format is unspecified, but the output shall be sorted by symbol name according to the collation sequence in the current locale.
>
> - Library or object name, if **-A** is specified
>
> - Symbol name
>
> - Symbol type, which shall either be one of the following single characters or an implementation-defined type represented by a single character:
>
>   `A`
>
>   Global absolute symbol.
>
>   `a`
>
>   Local absolute symbol.
>
>   `B`
>
>   Global "bss" (that is, uninitialized data space) symbol.
>
>   `b`
>
>   Local bss symbol.
>
>   `D`
>
>   Global data symbol.
>
>   `d`
>
>   Local data symbol.
>
>   `T`
>
>   Global text symbol.
>
>   `t`
>
>   Local text symbol.
>
>   `U`
>
>   Undefined symbol.
>
> - Value of the symbol
>
> - The size associated with the symbol, if applicable
>
> This information may be supplemented by additional information specific to the implementation.
>
> If the **-P** option is specified, the previous information shall be displayed using the following portable format. The three versions differ depending on whether **-t d**, **-t o**, or **-t x** was specified, respectively:
>
>
>     "%s%s %s %d %d\n", <library/object name>, <name>, <type>,
>         <value>, <size>
>
>
>     "%s%s %s %o %o\n", <library/object name>, <name>, <type>,
>         <value>, <size>
>
>
>     "%s%s %s %x %x\n", <library/object name>, <name>, <type>,
>         <value>, <size>
>
> where \<*library/object name*\> shall be formatted as follows:
>
> - If **-A** is not specified, \<*library/object name*\> shall be an empty string.
>
> - If **-A** is specified and the corresponding *file* operand does not name a library:
>
>
>       "%s: ", <file>
>
> - If **-A** is specified and the corresponding *file* operand names a library. In this case, \<*object file*\> shall name the object file in the library containing the symbol being described:
>
>
>       "%s[%s]: ", <file>, <object file>
>
> If **-A** is not specified, then if more than one *file* operand is specified or if only one *file* operand is specified and it names a library, *nm* shall write a line identifying the object containing the following symbols before the lines containing those symbols, in the form:
>
> - If the corresponding *file* operand does not name a library:
>
>
>       "%s:\n", <file>
>
> - If the corresponding *file* operand names a library; in this case, \<*object file*\> shall be the name of the file in the library containing the following symbols:
>
>
>       "%s[%s]:\n", <file>, <object file>
>
> If **-P** is specified, but **-t** is not, the format shall be as if **-t x** had been specified.

#### <span id="tag_20_88_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_88_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_88_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_88_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_88_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_88_16"></span>APPLICATION USAGE

> Mechanisms for dynamic linking make this utility less meaningful when applied to an executable file because a dynamically linked executable may omit numerous library routines that would be found in a statically linked executable.

#### <span id="tag_20_88_17"></span>EXAMPLES

> None.

#### <span id="tag_20_88_18"></span>RATIONALE

> Historical implementations of *nm* have used different bases for numeric output and supplied different default types of symbols that were reported. The **-t** *format* option, similar to that used in [*od*](../utilities/od.html) and [*strings*](../utilities/strings.html), can be used to specify the numeric base; **-g** and **-u** can be used to restrict the amount of output or the types of symbols included in the output.
>
> The compromise of using **-t** *format* *versus* using **-d**, **-o**, and other similar options was necessary because of differences in the meaning of **-o** between implementations. The **-o** option from BSD has been provided here as **-A** to avoid confusion with the **-o** from System V (which has been provided here as **-t** and as **-o** on XSI-conformant systems).
>
> The option list was significantly reduced from that provided by historical implementations.
>
> The *nm* description is a subset of both the System V and BSD *nm* utilities with no specified default output.
>
> It was recognized that mechanisms for dynamic linking make this utility less meaningful when applied to an executable file (because a dynamically linked executable file may omit numerous library routines that would be found in a statically linked executable file), but the value of *nm* during software development was judged to outweigh other limitations.
>
> The default output format of *nm* is not specified because of differences in historical implementations. The **-P** option was added to allow some type of portable output format. After a comparison of the different formats used in SunOS, BSD, SVR3, and SVR4, it was decided to create one that did not match the current format of any of these four systems. The format devised is easy to parse by humans, easy to parse in shell scripts, and does not need to vary depending on locale (because no English descriptions are included). All of the systems currently have the information available to use this format.
>
> The format given in *nm* STDOUT uses \<space\> characters between the fields, which may be any number of \<blank\> characters required to align the columns. The single-character types were selected to match historical practice, and the requirement that implementation additions also be single characters made parsing the information easier for shell scripts.

#### <span id="tag_20_88_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_88_20"></span>SEE ALSO

> [*ar*](../utilities/ar.html#), [*c17*](../utilities/c17.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_88_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_88_22"></span>Issue 6

> This utility is marked as supported when both the User Portability Utilities option and the Software Development Utilities option are supported.

#### <span id="tag_20_88_23"></span>Issue 7

> The *nm* utility is removed from the User Portability Utilities option. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0125 \[263\] and XCU/TC1-2008/0126 \[263\] are applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0148 \[744\] is applied.

#### <span id="tag_20_88_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 1062 is applied, inserting an empty line between the two SYNOPSIS forms.
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
