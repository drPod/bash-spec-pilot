The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="msgfmt"></span> <span id="tag_20_82"></span>

#### <span id="tag_20_82_01"></span>NAME

> msgfmt — create messages objects from portable messages object source files

#### <span id="tag_20_82_02"></span>SYNOPSIS

> `msgfmt`` `**`[`**`-cfSv`**`] [`**`-D`` `*`dir`***`] [`**`-o`` `*`outputfile`***`]`**` `*`pathname`*`...`

#### <span id="tag_20_82_03"></span>DESCRIPTION

> The *msgfmt* utility shall create messages object files from portable messages object source files (dot-po files).
>
> A dot-po file contains messages to be output by system commands or by applications. The messages in these files should be able to be translated to any language supported by the system.
>
> The *msgfmt* utility shall interpret message strings for output as characters according to the codeset specified in the dot-po file or, if not present, the current setting of the *LC_CTYPE* locale category.

#### <span id="tag_20_82_04"></span>OPTIONS

> The *msgfmt* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-c**
>
> If this option and **-v** are both specified, *msgfmt* shall detect and diagnose input file abnormalities which might represent translation errors. The **msgid** and **msgstr** strings shall be compared. It shall be considered abnormal if one string starts or ends with a \<newline\> while the other does not. Also, if the flag **c-format** appears in a `"#,"` comment for a **msgid** directive (see EXTENDED DESCRIPTION), it shall be considered abnormal if the strings do not have the same number of `'%'` conversion specifiers, or if corresponding conversion specifiers take different argument types (see XSH [*fprintf*()](../functions/fprintf.html#)). If an abnormality is detected, the exit status shall be non-zero and a diagnostic message shall be output. Additional checks beyond those described here may also be performed. These checks may produce diagnostics or informational messages and need not affect the exit status. If **-c** is specified without **-v** or **-v** is specified without **-c**, the behavior is unspecified.
>
> **-D ***dir*
>
> Add *dir* to the list of directories to search for input files.
>
> **-f**
>
> Use fuzzy entries in output. If this option is not specified, fuzzy entries shall not be included in the output.
>
> **-o ***outputfile*
>
> \
> Specify the name of an output file to be used instead of the default filename(s) specified in EXTENDED DESCRIPTION. All **domain** *domainname* directives in the dot-po file(s) shall be ignored.
>
> **-S**
>
> Append the suffix **.mo** to each generated messages object filename if it does not have this suffix.
>
> **-v**
>
> See **-c**.

#### <span id="tag_20_82_05"></span>OPERANDS

> The following operand shall be supported:
>
> *pathname*
>
> A pathname of a dot-po file.

#### <span id="tag_20_82_06"></span>STDIN

> Not used.

#### <span id="tag_20_82_07"></span>INPUT FILES

> The input files shall be text files in the format described in EXTENDED DESCRIPTION.

#### <span id="tag_20_82_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *msgfmt*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LANGUAGE*
>
> Determine the location of messages objects <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  if *NLSPATH* is not set or the evaluation of *NLSPATH* did not lead to a suitable messages object being found. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
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
> Determine the locale name used to locate messages objects, and the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_82_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_82_10"></span>STDOUT

> Not Used.

#### <span id="tag_20_82_11"></span>STDERR

> The standard error shall be used for diagnostic messages and may also be used for warning messages. If the **-c** and **-v** options are specified, additional unspecified informational messages may be written to standard error.

#### <span id="tag_20_82_12"></span>OUTPUT FILES

> The format of the created messages object files is unspecified.

#### <span id="tag_20_82_13"></span>EXTENDED DESCRIPTION

> The *msgfmt* utility shall accept portable messages object source files (dot-po files) in the following format.
>
> A dot-po file contains zero or more lines, with each non-blank line containing a comment, a statement, or a statement continuation. A comment has an unquoted \<number-sign\> (`'#'`) as the first non-\<blank\> character and ends with the next \<newline\> character. A statement continuation is a double-quoted string on a line by itself, optionally preceded and/or followed by \<blank\> characters, and the string shall be concatenated with the string on the previous statement line. If a comment occurs between a statement and a statement continuation, the behavior is unspecified. All other comments, except for comments beginning with \<number-sign\>\<comma\> (`"#,"`), and blank lines shall be ignored.
>
> The format of a statement is:
>
>
>     directive value
>
> The *directive* starts at the first non-\<blank\> character of the line and is separated from the *value* by one or more \<blank\> characters. The *value* consists of a double-quoted string optionally followed by \<blank\> characters. Zero or more statement continuation lines (see above) can follow the statement. The following directives shall be supported:\
>
>
>     domain domainname
>     msgid message_identifier
>     msgid_plural untranslated_string_plural
>     msgstr message_string
>     msgstr[index] message_string
>
> A dot-po file consists of zero or more sections. Each section specifies the messages to be processed in a domain. The first directive in each section shall be a **domain** directive (except for the first section which shall behave as if
>
>
>     domain "messages"
>
> had been specified if the first directive is not a **domain** directive).
>
> The behavior of the **domain** directive is affected by the options used. See OPTIONS for the behavior when the **-o** option is specified. If the **-o** option is not specified, all data obtained from the non-**domain** directives in a dot-po section shall be output to the messages object file named *domainname***.mo** when the **-S** option is specified. When the **-S** option is not specified, it is implementation-defined whether *domainname* or *domainname***.mo** is used.
>
> If multiple **domain** directives specify the same *domainname*, the sections shall be processed as if there was only one section that starts with a **domain** *domainname* statement which contained the statements of the sections, in the same order, excluding all but the first **domain** *domainname* statement.
>
> Within each section, there can be a header. A header is identified by having a **msgid** directive with the empty string (`""`) as the *message_identifier* immediately followed by a statement containing a **msgstr** directive. The *message_string* in this **msgstr** statement in a header shall be treated specially. If *message_string* contains a specification of the form:
>
>
>     "nplurals=count; plural=expression"
>
> then *count* indicates the number of plural forms for messages in that domain, and *expression* is a C-language expression that evaluates to an unsigned integer value which determines the **msgstr\[***index***\]** directive to be used. The value of *expression* is used as the index value. The variable *n* in *expression* is assigned the value of the *n* argument to the [*ngettext*()](../functions/ngettext.html), [*ngettext_l*()](../functions/ngettext_l.html), [*dngettext*()](../functions/dngettext.html), [*dngettext_l*()](../functions/dngettext_l.html), [*dcngettext*()](../functions/dcngettext.html), and [*dcngettext_l*()](../functions/dcngettext_l.html) functions or of the *n* operand of the [*ngettext*](../utilities/ngettext.html) utility before *expression* is evaluated. The application shall ensure that *expression* evaluates to a non-negative value less than *count* for all *n* that can be supplied by the aforementioned functions and utility.
>
> If *message_string* in the header contains a specification of the form:
>
>
>     "charset=codeset"
>
> then *codeset* indicates the codeset to be used to encode the message strings in this section's domain (overriding *LC_CTYPE ).* If the output string's codeset is different from the message string's codeset, codeset conversion from the message string's codeset to the output string's codeset shall be performed by the *gettext* family of functions and by the [*gettext*](../utilities/gettext.html) and [*ngettext*](../utilities/ngettext.html) utilities. See XSH [*gettext*()](../functions/gettext.html#tag_17_238) and [*gettext*](../utilities/gettext.html#tag_20_54). The output string's codeset shall be determined by the current or specified locale's codeset.
>
> **Note:**  
> It is the responsibility of translators to ensure that the characters they enter into message strings in a dot-po file are encoded in the codeset specified in the header.
>
> If a header is present in a section, the application shall ensure that the header is provided by the first **msgid** directive in that section.
>
> After the header, if present, zero or more messages are identified by a **msgid** directive with a *message_identifier* that is not an empty string. Each of these directives start a subsection that is used to get a translated message from the *gettext* family of functions and from the [*gettext*](../utilities/gettext.html) and [*ngettext*](../utilities/ngettext.html) utilities. If the *message_identifier* string is the string identified by the *gettext* family of functions *msgid* argument or by the [*gettext*](../utilities/gettext.html) and [*ngettext*](../utilities/ngettext.html) utility *msgid* operand, this subsection specifies how that translation is to be processed.
>
> If there is only a singular form for the given *message_identifier*, the application shall ensure that the statement containing the **msgid** directive is immediately followed by a **msgstr** directive.
>
> If there are plural forms for the given *message_identifier* and the header for this section exists and contains an
>
>
>     "nplurals=count; plural=expression"
>
> specification, the application shall ensure that the statement containing the **msgid** directive is immediately followed by a **msgid_plural** directive and that each statement containing a **msgid_plural** directive is followed by *count* statements containing **msgstr\[***index***\]** directives, starting with **msgstr\[0\]** and ending with **msgstr\[***count***-1\]** in increasing order, with no duplicate index values. If a header for this section does not exist or does not contain an
>
>
>     "nplurals=count; plural=expression"
>
> specification, the application shall ensure that no **msgid_plural** or **msgstr\[***index***\]** directives are used in this section.
>
> For example, if the header's *message_string* contains the specification:
>
>
>     "nplurals=2; plural= n == 1 ? 0 : 1"
>
> there are two forms in the domain; **msgstr\[0\]** is used if *n* is equal to 1, otherwise **msgstr\[1\]** is used. For another example, if the header's *message_string* contains:
>
>
>     "nplurals=3; plural= n == 1 ? 0 : n == 2 ? 1 : 2"
>
> there are three forms in the domain; **msgstr\[0\]** is used if *n* is equal to 1, **msgstr\[1\]** is used if *n* is equal to 2, otherwise **msgstr\[2\]** is used.
>
> C-language escape sequences in strings shall be processed as specified for character string literals in the ISO C standard, except that *universal-character-name* escape sequences need not be supported.
>
> Comments in a dot-po file can be in one of the following formats:
>
>
>     #: reference
>     #. utility-added-comments
>     #, flag
>     #translator-comments (where translator-comments does not begin with '.', ':' or ',')
>
> A `#: `*`reference`* comment indicates the location(s) of the **msgid** string in the source files, in
>
>
>     pathname1:linenumber1 [pathname2:linenumber2 ... ]
>
> format. They can be added, as might `"#."` prefixed additional comments of unspecified format, by the [*xgettext*](../utilities/xgettext.html) utility. All comments that do not begin with `"#,"` are informative only and shall be silently ignored by the *msgfmt* utility. In `"#,"` comments the following values for *flag* can be specified:
>
> **fuzzy**
>
> This flag indicates that the **msgstr** string might not be a correct translation at this point in time. Only the translator can judge if the translation requires further modification or is acceptable as is. Once satisfied with the translation, the translator should remove this **fuzzy** flag. If this flag is specified, the *msgfmt* utility shall not generate the entry for the next following **msgid** in the output message catalog, unless the **-f** option is specified. If other flag comments are specified between **fuzzy** and the **msgid**, the behavior is unspecified.
>
> **c-format**
>
> **no-c-format**
>
> The **c-format** flag indicates that the next following **msgid** string contains a [*printf*()](../functions/printf.html) format string. When the **c-format** flag is given and the **-c** and **-v** options are specified, the *msgfmt* utility shall perform additional tests to check the validity of the translation (see OPTIONS); these additional tests may also be performed if neither **c-format** nor **no-c-format** is given. When the **no-c-format** flag is given for a string, no additional checks shall be performed for the string. When both the **c-format** and the **no-c-format** flags are given, the last flag specified takes precedence.

#### <span id="tag_20_82_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_82_15"></span>CONSEQUENCES OF ERRORS

> The *msgfmt* utility need not continue processing later *pathname* operands when an error condition that affects the exit status is detected. It is unspecified whether a messages object file is written when checks performed for the **-c** and **-v** options fail.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_82_16"></span>APPLICATION USAGE

> The [*xgettext*](../utilities/xgettext.html) utility can be used to create template dot-po files from C-language source files.
>
> Installing messages object files for the POSIX or C locale is not recommended, since they may be ignored for the sake of efficiency.
>
> The first section for each domain in a dot-po file should include a header containing a
>
>
>     "charset=codeset"
>
> specification. If this specification is omitted, message conversions in the *gettext* family of functions and in the [*gettext*](../utilities/gettext.html) and [*ngettext*](../utilities/ngettext.html) utilities may fail.
>
> The **msgid_plural** directive's *untranslated_string_plural* string comes from the *msgid_plural* arguments in calls to the [*ngettext*()](../functions/ngettext.html), [*ngettext_l*()](../functions/ngettext_l.html), [*dngettext*()](../functions/dngettext.html), [*dngettext_l*()](../functions/dngettext_l.html), [*dcngettext*()](../functions/dcngettext.html), and [*dcngettext_l*()](../functions/dcngettext_l.html) functions when a prototype dot-po file is created by the [*xgettext*](../utilities/xgettext.html) utility. These strings (and the *msgid_plural* operands in calls to the [*ngettext*](../utilities/ngettext.html) utility) can provide context when a translator is modifying a template dot-po file into a dot-po file for a specific language. These functions and the [*ngettext*](../utilities/ngettext.html) utility do not try to match the *msgid_plural* arguments or operands with anything in a messages object file; they only match the *msgid* arguments and operands.
>
> Unlike shell command language strings, double-quoted strings in dot-po files cannot contain a literal \<newline\> character.

#### <span id="tag_20_82_17"></span>EXAMPLES

> In this example, **module1.po** and **module2.po** are portable messages object source files.
>
>
>     $ cat module1.po
>     # default domain "messages"
>     msgid ""
>     msgstr "charset=utf-8"
>     msgid "msg 1"
>     msgstr "msg 1 translation"
>     #
>     domain "help_domain"
>     msgid ""
>     msgstr "charset=utf-8"
>     msgid "help 2"
>     msgstr "help 2 translation"
>     #
>     domain "error_domain"
>     msgid ""
>     msgstr "charset=utf-8"
>     msgid "error 3"
>     msgstr "error 3 translation"
>
>
>     $ cat module2.po
>     # default domain "messages"
>     msgid ""
>     msgstr "charset=utf-8"
>     msgid "mesg 4"
>     msgstr "mesg 4 translation"
>     #
>     domain "error_domain"
>     msgid ""
>     msgstr "charset=utf-8"
>     #, c-format
>     msgid "error 5 %s"
>     msgstr "error 5 translation %s"
>     #
>     domain "window_domain"
>     msgid ""
>     msgstr "charset=utf-8"
>     msgid "window 6"
>     msgstr "window 6 translation"
>
>
>     $ cat module3.po
>     # default domain "messages"
>     # header will be used for the whole output file in the third example
>     msgid ""
>     msgstr "charset=utf-8"
>     msgid "info 0"
>     msgstr "info 0 translation"
>
>
>     $ cat opt_debug.po
>     #
>     domain "debug_domain"
>     msgid "debug 8"
>     msgstr "debug 8 translation"
>
> The following command will produce the output files **messages.mo**, **help_domain.mo**, and **error_domain.mo**:
>
>
>     $ msgfmt -S module1.po
>
> The following command will produce the output files **messages.mo**, **help_domain.mo**, **error_domain.mo**, and **window_domain.mo**:
>
>
>     $ msgfmt -S module1.po module2.po
>
> The following command will produce the output file **hello.mo**:
>
>
>     $ msgfmt -o hello.mo module3.po opt_debug.po

#### <span id="tag_20_82_18"></span>RATIONALE

> Some implementations are less strict about the format of dot-po files and simply treat all occurrences of one or more white space characters as a separator. The format described in this standard is accepted by all known implementations.
>
> In some implementations, duplicate **msgid** directives within a domain are ignored, and only an entry for the first **msgid** directive and the following **msgid**, **msgid_plural**, **msgstr**, or **msgstr\[***index***\]** directives is created. However, some implementations consider duplicate **msgid** directives within a domain to be an error and do not produce output at all. Consequently this standard does not specify the behavior of *msgfmt* if duplicate **msgid** directives are encountered within one domain.

#### <span id="tag_20_82_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_82_20"></span>SEE ALSO

> [*gettext*](../utilities/gettext.html#tag_20_54), [*xgettext*](../utilities/xgettext.html#)
>
> XSH [*fprintf*()](../functions/fprintf.html#), [*gettext*()](../functions/gettext.html#tag_17_238)

#### <span id="tag_20_82_21"></span>CHANGE HISTORY

> First released in Issue 8.

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
