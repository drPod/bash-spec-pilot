The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="ctags"></span> <span id="tag_20_27"></span>

#### <span id="tag_20_27_01"></span>NAME

> ctags — create a tags file (**DEVELOPMENT**)

#### <span id="tag_20_27_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`CD SD`](javascript:open_code('CD%20SD'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` ctags`` `**`[`**`-a`**`] [`**`-f`` `*`tagsfile`***`]`**` `*`pathname`*`...`\
> \
> `ctags -x`` `*`pathname`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_27_03"></span>DESCRIPTION

> The *ctags* utility shall write a *tagsfile* or an index of objects from C-language source files specified by the *pathname* operands. The *tagsfile* shall list the locators of C-language objects within the source files. A locator consists of a name, pathname, and either a search pattern or a line number that can be used in searching for the object definition. The objects that shall be recognized are specified in the EXTENDED DESCRIPTION section.

#### <span id="tag_20_27_04"></span>OPTIONS

> The *ctags* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a**
>
> Append to *tagsfile*.
>
> **-f ***tagsfile*
>
> Write the object locator lists into *tagsfile* instead of the default file named **tags** in the current directory.
>
> **-x**
>
> Produce a list of object names, the line number, and filename in which each is defined, as well as the text of that line, and write this to the standard output. A *tagsfile* shall not be created when **-x** is specified.

#### <span id="tag_20_27_05"></span>OPERANDS

> The following *pathname* operands are supported:
>
> *file***.c**
>
> Files with basenames ending with the **.c** suffix shall be treated as C-language source code. Such files that are not valid input to [*c17*](../utilities/c17.html) produce unspecified results.
>
> *file***.h**
>
> Files with basenames ending with the **.h** suffix shall be treated as C-language source code. Such files that are not valid input to [*c17*](../utilities/c17.html) produce unspecified results.
>
> The handling of other files is implementation-defined.

#### <span id="tag_20_27_06"></span>STDIN

> See the INPUT FILES section.

#### <span id="tag_20_27_07"></span>INPUT FILES

> The input files shall be text files containing C-language source code.

#### <span id="tag_20_27_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *ctags*:
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
> Determine the order in which output is sorted for the **-x** option. The POSIX locale determines the order in which the *tagsfile* is written.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files). If the locale is not compatible with the C locale described by the ISO C standard, the results are unspecified.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_27_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_27_10"></span>STDOUT

> The list of object name information produced by the **-x** option shall be written to standard output in the following format:
>
>
>     "%s %d %s %s", <object-name>, <line-number>, <filename>, <text>
>
> where \<*text*\> is the text of line \<*line-number*\> of file \<*filename*\>.

#### <span id="tag_20_27_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_27_12"></span>OUTPUT FILES

> When the **-x** option is not specified, the format of the output file shall be:
>
>
>     "%s\t%s\t/%s/\n", <identifier>, <filename>, <pattern>
>
> where \<*pattern*\> is a search pattern that could be used by an editor to find the defining instance of \<*identifier*\> in \<*filename*\> (where *defining instance* is indicated by the declarations listed in the EXTENDED DESCRIPTION).
>
> An optional \<circumflex\> (`'^'`) can be added as a prefix to \<*pattern*\>, and an optional \<dollar-sign\> can be appended to \<*pattern*\> to indicate that the pattern is anchored to the beginning (end) of a line of text. Any \<slash\> or \<backslash\> characters in \<*pattern*\> shall be preceded by a \<backslash\> character. The anchoring \<circumflex\>, \<dollar-sign\>, and escaping \<backslash\> characters shall not be considered part of the search pattern. All other characters in the search pattern shall be considered literal characters.\
>
> An alternative format is:
>
>
>     "%s\t%s\t?%s?\n", <identifier>, <filename>, <pattern>
>
> which is identical to the first format except that \<slash\> characters in \<*pattern*\> shall not be preceded by escaping \<backslash\> characters, and \<question-mark\> characters in \<*pattern*\> shall be preceded by \<backslash\> characters.
>
> A second alternative format is:
>
>
>     "%s\t%s\t%d\n", <identifier>, <filename>, <lineno>
>
> where \<*lineno*\> is a decimal line number that could be used by an editor to find \<*identifier*\> in \<*filename*\>.
>
> Neither alternative format shall be produced by *ctags* when it is used as described by POSIX.1-2024, but the standard utilities that process tags files shall be able to process those formats as well as the first format.
>
> In any of these formats, the file shall be sorted by identifier, based on the collation sequence in the POSIX locale.

#### <span id="tag_20_27_13"></span>EXTENDED DESCRIPTION

> The *ctags* utility shall attempt to produce an output line for each of the following objects:
>
> - Function definitions
>
> - Type definitions
>
> - Macros with arguments
>
> It may also produce output for any of the following objects:
>
> - Function prototypes
>
> - Structures
>
> - Unions
>
> - Global variable definitions
>
> - Enumeration types
>
> - Macros without arguments
>
> - **\#define** statements
>
> - **\#line** statements
>
> Any **\#if** and **\#ifdef** statements shall produce no output. The tag **main** is treated specially in C programs. The tag formed shall be created by prefixing **M** to the name of the file, with the trailing **.c**, and leading pathname components (if any) removed.
>
> It is implementation-defined what other objects (including duplicate identifiers) produce output.
>
> On systems that do not support the C-Language Development Utilities option, if *ctags* is supported it produces unspecified results for C-language source code files. It should write to standard error a message identifying this condition and cause a non-zero exit status to be produced.

#### <span id="tag_20_27_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_27_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_27_16"></span>APPLICATION USAGE

> The output with **-x** is meant to be a simple index that can be written out as an off-line readable function index. If the input files to *ctags* (such as **.c** files) were not created using the same locale as that in effect when *ctags* **-x** is run, results might not be as expected.
>
> The description of C-language processing says "attempts to" because the C language can be greatly confused, especially through the use of **\#define**s, and this utility would be of no use if the real C preprocessor were run to identify them. The output from *ctags* may be fooled and incorrect for various constructs.

#### <span id="tag_20_27_17"></span>EXAMPLES

> None.

#### <span id="tag_20_27_18"></span>RATIONALE

> The option list was significantly reduced from that provided by historical implementations. The **-F** option was omitted as redundant, since it is the default. The **-B** option was omitted as being of very limited usefulness. The **-t** option was omitted since the recognition of **typedef**s is now required for C source files. The **-u** option was omitted because the update function was judged to be not only inefficient, but also rarely needed.
>
> An early proposal included a **-w** option to suppress warning diagnostics. Since the types of such diagnostics could not be described, the option was omitted as being not useful.
>
> The text for *LC_CTYPE* about compatibility with the C locale acknowledges that the ISO C standard imposes requirements on the locale used to process C source. This could easily be a superset of that known as "the C locale" by way of implementation extensions, or one of a few alternative locales for systems supporting different codesets.
>
> The collation sequence of the tags file is not affected by *LC_COLLATE* because it is typically not used by human readers, but only by programs such as [*vi*](../utilities/vi.html) to locate the tag within the source files. Using the POSIX locale eliminates some of the problems of coordinating locales between the *ctags* file creator and the [*vi*](../utilities/vi.html) file reader.
>
> Historically, the tags file has been used only by [*ex*](../utilities/ex.html) and [*vi*](../utilities/vi.html). However, the format of the tags file has been published to encourage other programs to use the tags in new ways. The format allows either patterns or line numbers to find the identifiers because the historical [*vi*](../utilities/vi.html) recognizes either. The *ctags* utility does not produce the format using line numbers because it is not useful following any source file changes that add or delete lines. The documented search patterns match historical practice. It should be noted that literal leading \<circumflex\> or trailing \<dollar-sign\> characters in the search pattern will only behave correctly if anchored to the beginning of the line or end of the line by an additional \<circumflex\> or \<dollar-sign\> character.
>
> Historical implementations also understand the objects used by the languages FORTRAN, Pascal, and sometimes LISP, and they understand the C source output by [*lex*](../utilities/lex.html) and [*yacc*](../utilities/yacc.html). The *ctags* utility is not required to accommodate these languages, although implementors are encouraged to do so.
>
> The following historical option was not specified, as *vgrind* is not included in this volume of POSIX.1-2024:
>
> **-v**
>
> If the **-v** flag is given, an index of the form expected by *vgrind* is produced on the standard output. This listing contains the function name, filename, and page number (assuming 64-line pages). Since the output is sorted into lexicographic order, it may be desired to run the output through [*sort*](../utilities/sort.html) **-f**. Sample use:
>
>
>     ctags -v files | sort -f > index
>     vgrind -x index
>
> The special treatment of the tag **main** makes the use of *ctags* practical in directories with more than one program.

#### <span id="tag_20_27_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_27_20"></span>SEE ALSO

> [*c17*](../utilities/c17.html#), [*vi*](../utilities/vi.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_27_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_27_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_27_23"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The OUTPUT FILES section is changed to align with the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> IEEE PASC Interpretation 1003.2 \#168 is applied, changing "create" to "write" in the DESCRIPTION.

#### <span id="tag_20_27_24"></span>Issue 7

> The *ctags* utility is no longer dependent on support for the User Portability Utilities option.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_27_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to behave as follows:
>
> 1.  Report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> 2.  Disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1312 is applied, inserting a missing line break in the example commands in the RATIONALE section.
>
> Austin Group Defect 1330 is applied, removing obsolescent interfaces.

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
