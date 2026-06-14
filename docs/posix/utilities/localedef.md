The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="localedef"></span> <span id="tag_20_69"></span>

#### <span id="tag_20_69_01"></span>NAME

> localedef — define locale environment

#### <span id="tag_20_69_02"></span>SYNOPSIS

> `localedef`` `**`[`**`-c`**`] [`**`-f`` `*`charmap`***`] [`**`-i`` `*`sourcefile`***`] [`**`-u`` `*`code_set_name`***`]`**` `*`name`*

#### <span id="tag_20_69_03"></span>DESCRIPTION

> The *localedef* utility shall convert source definitions for locale categories into a format usable by the functions and utilities whose operational behavior is determined by the setting of the locale environment variables defined in XBD [*7. Locale*](../basedefs/V1_chap07.html#tag_07). It is implementation-defined whether users have the capability to create new locales, in addition to those supplied by the implementation. If the symbolic constant POSIX2_LOCALEDEF is defined, the system supports the creation of new locales. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  On XSI-conformant systems, the symbolic constant POSIX2_LOCALEDEF shall be defined. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The utility shall read source definitions for one or more locale categories belonging to the same locale from the file named in the **-i** option (if specified) or from standard input.
>
> The *name* operand identifies the target locale. The utility shall support the creation of *public*, or generally accessible locales, as well as *private*, or restricted-access locales. Implementations may restrict the capability to create or modify public locales to users with appropriate privileges.
>
> Each category source definition shall be identified by the corresponding environment variable name and terminated by an **END** *category-name* statement. The following categories shall be supported. In addition, the input may contain source for implementation-defined categories.
>
> *LC_CTYPE*
>
> Defines character classification and case conversion.
>
> *LC_COLLATE*
>
> \
> Defines collation rules.
>
> *LC_MONETARY*
>
> \
> Defines the format and symbols used in formatting of monetary information.
>
> *LC_NUMERIC*
>
> \
> Defines the decimal delimiter, grouping, and grouping symbol for non-monetary numeric editing.
>
> *LC_TIME*
>
> Defines the format and content of date and time information.
>
> *LC_MESSAGES*
>
> \
> Defines the format and values of affirmative and negative responses.
>
> If the *LC_COLLATE* category defines a collation sequence that does not have a total ordering of all characters, *localedef* shall write a warning message to standard error and, if the exit status would otherwise have been zero, shall exit with status 1.

#### <span id="tag_20_69_04"></span>OPTIONS

> The *localedef* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-c**
>
> Create permanent output even if warning messages have been issued.
>
> **-f ***charmap*
>
> Specify the pathname of a file containing a mapping of character symbols and collating element symbols to actual character encodings. The format of the *charmap* is described in XBD [*6.4 Character Set Description File*](../basedefs/V1_chap06.html#tag_06_04). The application shall ensure that this option is specified if symbolic names (other than collating symbols defined in a **collating-symbol** keyword) are used. If the **-f** option is not present, an implementation-defined character mapping shall be used.
>
> **-i ***inputfile*
>
> The pathname of a file containing the source definitions. If this option is not present, source definitions shall be read from standard input. The format of the *inputfile* is described in XBD [*7.3 Locale Definition*](../basedefs/V1_chap07.html#tag_07_03).
>
> **-u ***code_set_name*
>
> \
> Specify the name of a codeset used as the target mapping of character symbols and collating element symbols whose encoding values are defined in terms of the ISO/IEC 10646-1:2020 standard position constant values.

#### <span id="tag_20_69_05"></span>OPERANDS

> The following operand shall be supported:
>
> *name*
>
> Identifies the locale; see XBD [*7. Locale*](../basedefs/V1_chap07.html#tag_07) for a description of the use of this name. If the name contains one or more \<slash\> characters, *name* shall be interpreted as a pathname where the created locale definitions shall be stored. If *name* does not contain any \<slash\> characters, the interpretation of the name is implementation-defined and the locale shall be public. The ability to create public locales in this way may be restricted to users with appropriate privileges. (As a consequence of specifying one *name*, although several categories can be processed in one execution, only categories belonging to the same locale can be processed.)

#### <span id="tag_20_69_06"></span>STDIN

> Unless the **-i** option is specified, the standard input shall be a text file containing one or more locale category source definitions, as described in XBD [*7.3 Locale Definition*](../basedefs/V1_chap07.html#tag_07_03). When lines are continued using the escape character mechanism, there is no limit to the length of the accumulated continued line.

#### <span id="tag_20_69_07"></span>INPUT FILES

> The character set mapping file specified as the *charmap* option-argument is described in XBD [*6.4 Character Set Description File*](../basedefs/V1_chap06.html#tag_06_04). If a locale category source definition contains a **copy** statement, as defined in XBD [*7. Locale*](../basedefs/V1_chap07.html#tag_07), and the **copy** statement names a valid, existing locale, then *localedef* shall behave as if the source definition had contained a valid category source definition for the named locale.

#### <span id="tag_20_69_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *localedef*:
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
> (This variable has no affect on *localedef*; the POSIX locale is used for this category.)
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files). This variable has no affect on the processing of *localedef* input data; the POSIX locale is used for this purpose, regardless of the value of this variable.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_69_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_69_10"></span>STDOUT

> The utility shall report all categories successfully processed, in an unspecified format.

#### <span id="tag_20_69_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_69_12"></span>OUTPUT FILES

> The format of the created output is unspecified. If the *name* operand does not contain a \<slash\>, the existence of an output file for the locale is unspecified.

#### <span id="tag_20_69_13"></span>EXTENDED DESCRIPTION

> When the **-u** option is used, the *code_set_name* option-argument shall be interpreted as an implementation-defined name of a codeset to which the ISO/IEC 10646-1:2020 standard position constant values shall be converted via an implementation-defined method. Both the ISO/IEC 10646-1:2020 standard position constant values and other formats (decimal, hexadecimal, or octal) shall be valid as encoding values within the *charmap* file. The codeset represented by the implementation-defined name can be any codeset that is supported by the implementation.
>
> When conflicts occur between the *charmap* specification of \<*code_set_name*\>, \<*mb_cur_max*\>, or \<*mb_cur_min*\> and the implementation-defined interpretation of these respective items for the codeset represented by the **-u** option-argument *code_set_name*, the result is unspecified.
>
> When conflicts (including omissions) occur between the *charmap* encoding values specified for symbolic names of characters of the portable character set and the implementation-defined assignment of character encoding values, the result is unspecified. If the result is that *localedef* creates the specified locale, any attempted use of that locale by an application or utility results in undefined behavior.
>
> If a non-printable character in the *charmap* has a width specified that is not **-1**, the result is undefined.

#### <span id="tag_20_69_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> No errors occurred and the locales were successfully created.
>
>  1
>
> Warnings occurred and the locales were successfully created.
>
>  2
>
> The locale specification exceeded implementation limits or the coded character set or sets used were not supported by the implementation, and no locale was created.
>
>  3
>
> The capability to create new locales is not supported by the implementation.
>
> \>3
>
> Warnings or errors occurred and no output was created.

#### <span id="tag_20_69_15"></span>CONSEQUENCES OF ERRORS

> If an error is detected, no permanent output shall be created.
>
> If warnings occur, permanent output shall be created if the **-c** option was specified. The following conditions shall cause warning messages to be issued:
>
> - If a symbolic name not found in the *charmap* file is used for the descriptions of the *LC_CTYPE* or *LC_COLLATE* categories (for other categories, this shall be an error condition).
>
> - If the number of operands to the **order** keyword exceeds the {COLL_WEIGHTS_MAX} limit.
>
> - If optional keywords not supported by the implementation are present in the source.
>
> Other implementation-defined conditions may also cause warnings.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_69_16"></span>APPLICATION USAGE

> The *charmap* definition is optional, and is contained outside the locale definition. This allows both completely self-defined source files, and generic sources (applicable to more than one codeset). To aid portability, all *charmap* definitions must use the same symbolic names for the portable character set. As explained in XBD [*6.4 Character Set Description File*](../basedefs/V1_chap06.html#tag_06_04), it is implementation-defined whether or not users or applications can provide additional character set description files. Therefore, the **-f** option might be operable only when an implementation-defined *charmap* is named.

#### <span id="tag_20_69_17"></span>EXAMPLES

> None.

#### <span id="tag_20_69_18"></span>RATIONALE

> The output produced by the *localedef* utility is implementation-defined. The *name* operand is used to identify the specific locale. (As a consequence, although several categories can be processed in one execution, only categories belonging to the same locale can be processed.)
>
> When conflicts (including omissions) occur between the *charmap* encoding values specified for symbolic names of characters of the portable character set and the implementation-defined assignment of character encoding values, it is recommended that *localedef* treats this as an error in order to prevent the undefined behavior that results if *localedef* creates the specified locale and an application or utility attempts to use it.

#### <span id="tag_20_69_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_69_20"></span>SEE ALSO

> [*locale*](../utilities/locale.html#)
>
> XBD [*6.4 Character Set Description File*](../basedefs/V1_chap06.html#tag_06_04), [*7. Locale*](../basedefs/V1_chap07.html#tag_07), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_69_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_69_22"></span>Issue 6

> The **-u** option is added, as specified in the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/15 is applied, rewording text in the OPERANDS section describing the ability to create public locales.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/16 is applied, making the text consistent with the descriptions of **WIDTH** and **WIDTH_DEFAULT** in the Base Definitions volume of POSIX.1-2024.

#### <span id="tag_20_69_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_69_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1070 is applied, requiring that *localedef* issues a warning if the *LC_COLLATE* category defines a collation sequence that does not have a total ordering of all characters.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1609 is applied, clarifying the behavior when conflicts (including omissions) occur between the *charmap* encoding values specified for symbolic names of characters of the portable character set and the implementation-defined assignment of character encoding values.

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
