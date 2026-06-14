The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="gettext"></span> <span id="tag_20_54"></span>

#### <span id="tag_20_54_01"></span>NAME

> gettext, ngettext — retrieve text string from messages object

#### <span id="tag_20_54_02"></span>SYNOPSIS

> `gettext`` `**`[`**`-e|-E`**`] [`**`-d textdomain`**`] [`***`textdomain`***`]`**` `*`msgid`*\
> \
> `gettext`` `**`[`**`-e|-E`**`] [`**`-n`**`]`**` ``-s`` `**`[`**`-d`` `*`textdomain`***`]`**` `*`msgid`*`...`\
> \
> `ngettext`` `**`[`**`-e|-E`**`] [`**`-d`` `*`textdomain`***`] [`***`textdomain`***`]`**` `*`msgid msgid_plural n`*\

#### <span id="tag_20_54_03"></span>DESCRIPTION

> The *gettext* and *ngettext* utilities shall write to standard output the message string(s) that would result from the following calls to functions defined in the System Interfaces volume of POSIX.1-2024:
>
>
>     if (textdomainname == NULL || textdomainname[0] == '\0')
>         message_string = msgid;
>     else {
>         setlocale(LC_ALL, "");
>         if (textdomaindir != NULL)
>             bindtextdomain(textdomainname, textdomaindir);
>         if (msgid_plural == NULL)
>             message_string = dgettext(textdomainname, msgid);
>         else
>             message_string = dngettext(textdomainname, msgid, msgid_plural, n);
>     }
>
> where:
>
> - The *textdomaindir* variable is a string containing the value of the *TEXTDOMAINDIR* environment variable, if set and not empty, or is NULL otherwise.
>
> - The *textdomainname* variable is a string containing the text domain name obtained from, in decreasing order of precedence:
>
>   - The optional operand *textdomain,* if present
>
>   - The **-d** *textdomain* option, if specified
>
>   - The *TEXTDOMAIN* environment variable, if set and not empty
>
>   If the text domain name cannot be obtained from these sources, the *textdomainname* variable is NULL.
>
> - If the **-s** option of *gettext* is not specified and for the *ngettext* utility, the *msgid* variable is a string containing:
>
>   - The value of the *msgid* operand, if the **-E** option is specified
>
>   - The value of the *msgid* operand with C-language escape sequences processed (see below), if the **-e** option is specified
>
>   - The value of the *msgid* operand with C-language escape sequences optionally processed (see below), otherwise
>
> - If the **-s** option of *gettext* is specified, the *msgid* variable is a string containing:
>
>   - The value of each *msgid* operand in turn, if the **-E** option is specified or neither the **-e** nor the **-E** option is specified
>
>   - The value of each *msgid* operand in turn with C-language escape sequences processed (see below), if the **-e** option is specified
>
> - For the *gettext* utility, the *msgid_plural* variable is NULL. For the *ngettext* utility, the *msgid_plural* variable is a string containing:
>
>   - The value of the *msgid_plural* operand, if the **-E** option is specified
>
>   - The value of the *msgid_plural* operand with C-language escape sequences processed (see below), if the **-e** option is specified
>
>   - The value of the *msgid_plural* operand with C-language escape sequences optionally processed (see below), otherwise
>
> - For the *gettext* utility, the *n* variable is 1 (one). For the *ngettext* utility the *n* variable is the *n* operand, parsed as an integer as if by using the [*strtoul*()](../functions/strtoul.html) function with a *base* argument of 10.
>
> When C-language escape sequences are processed, they shall be processed as specified for character string literals in the ISO C standard, except that *universal-character-name* escape sequences need not be supported. Implementations may also support a \<backslash\> `'c'` escape sequence; if supported, the `'\c'` and all characters following it shall be removed and, if the **-s** option is specified, the behavior shall be as if the **-n** option is also specified.
>
> For the *ngettext* utility, and for the *gettext* utility if the **-s** option is not specified, the resulting message string shall be written to standard output. If the **-s** option of *gettext* is specified, the resulting message string for each *msgid* shall be written to standard output with consecutive message strings separated by a single \<space\> character and, if the **-n** option is not specified, a \<newline\> shall be written after the last message string. If the **-s** and **-n** options are specified, the trailing \<newline\> shall be omitted.
>
> Under conditions where the *textdomainname* variable in the above code would be NULL, these utilities may write a diagnostic message to standard error and exit with non-zero status.

#### <span id="tag_20_54_04"></span>OPTIONS

> These utilities shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02) .
>
> The following options shall be supported:
>
> **-d ***textdomain*
>
> \
> Retrieve the translated message from the domain *textdomain*, if *textdomain* is not specified as an operand.
>
> **-e**
>
> Process C-language escape sequences in *msgid* and *msgid_plural* operands.
>
> **-E**
>
> Do not process C-language escape sequences in *msgid* and *msgid_plural* operands.
>
> The *gettext* utility shall also support the following options:
>
> **-n**
>
> Modify the behavior of the **-s** option such that a \<newline\> is not appended to the output.
>
> **-s**
>
> Separate the message strings obtained from each *msgid* operand with \<space\> characters in the output, and (if **-n** is not also specified) append a \<newline\> to the output.
>
> If neither of the mutually exclusive **-e** and **-E** options is specified, it is unspecified which is the default, except that if the **-s** option of *gettext* is specified then **-E** shall be the default.

#### <span id="tag_20_54_05"></span>OPERANDS

> The following operands shall be supported:
>
> *textdomain*
>
> A text domain name used to retrieve the translated message. This shall override the specification by the **-d** option, if present.
>
> *msgid*
>
> A key to retrieve the translated message.
>
> *msgid_plural*
>
> A default plural if no corresponding plural message can be found.
>
> *n*
>
> A non-negative decimal integer to be used as the *n* argument to [*dngettext*()](../functions/dngettext.html) (see the DESCRIPTION).

#### <span id="tag_20_54_06"></span>STDIN

> Not used.

#### <span id="tag_20_54_07"></span>INPUT FILES

> The input files are messages object files (see [*msgfmt*](../utilities/msgfmt.html#)).

#### <span id="tag_20_54_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *gettext* and *ngettext*:
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
> *LC_MESSAGES*
>
> \
> Determine the locale name used to locate messages objects, and the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *TEXTDOMAIN*
>
> \
> Specify the text domain name. (See XBD [*3.386 Text Domain*](../basedefs/V1_chap03.html#tag_03_386).)
>
> *TEXTDOMAINDIR*
>
> \
> Specify the pathname to the messages object hierarchy. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> *NLSPATH* shall have precedence over *TEXTDOMAINDIR .* <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_54_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_54_10"></span>STDOUT

> See DESCRIPTION.

#### <span id="tag_20_54_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_54_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_54_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_54_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_54_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_54_16"></span>APPLICATION USAGE

> Since it is unspecified which of the **-e** or **-E** options is the default, except when the **-s** option of *gettext* is specified, portable applications need to ensure that **-e**, **-E**, or (for *gettext*) **-s** is specified whenever a *msgid* or *msgid_plural* operand contains, or might contain, a \<backslash\> character.
>
> Note that, unless the **-s** option of *gettext* is specified without **-n**, the message(s) written to standard output are not followed by a \<newline\>. (Therefore the output only ends with a \<newline\> if the last message ends with one.)
>
> Both *msgid* and *msgid_plural* should be properly quoted for the shell.

#### <span id="tag_20_54_17"></span>EXAMPLES

> The following examples assume that the following portable messages object source file (dot-po file) has been compiled to a valid file **mail.mo** by the [*msgfmt*](../utilities/msgfmt.html) utility. See the EXTENDED DESCRIPTION section of the [*msgfmt*](../utilities/msgfmt.html) utility for a description of the dot-po file format.
>
>
>     msgid ""
>     msgstr ""
>     "Content-Type: text/plain; charset=utf-8\n"
>     "Plural-Forms: nplurals=4; plural=n==1?0: (n>1&&n<=10)?1: (n==0)?2:3;\n"
>
>
>     msgid "recipient"
>     msgid_plural "recipients"
>     msgstr[0] "1 recipient"
>     msgstr[1] "2 to 10 recipients"
>     msgstr[2] "no recipients"
>     msgstr[3] "more than 10 recipients"
>
>
>     msgid "%d attachment\n"
>     msgid_plural "%d attachments\n"
>     msgstr[0] "1 (%d) attachment\n"
>     msgstr[1] "2 to 10 (%d) attachments\n"
>     msgstr[2] "no (%d) attachments\n"
>     msgstr[3] "more than 10 (%d) attachments\n"
>
> They also assume that **mail.mo** is installed in the directory that *gettext* and *ngettext* search for the current locale. See the OPTIONS and ENVIRONMENT VARIABLES sections above and the description of [*gettext*()](../functions/gettext.html) for details on how this search is performed.
>
> The command
>
>
>     ngettext -d mail recipient recipients 0
>
> will write `"no recipients"`.
>
> The command
>
>
>     ngettext -d mail recipient recipients 1
>
> will write `"1 recipient"`.
>
> The command
>
>
>     ngettext -d mail recipient recipients 5
>
> will write `"2 to 10 recipients"`.
>
> The command
>
>
>     ngettext -d mail recipient recipients 11
>
> will write `"more than 10 recipients"`.
>
> The command
>
>
>     ngettext -d mail Call Calls 1
>
> will write `"Call"`. Note that `"Call"` is not in the messages object.
>
> The command
>
>
>     ngettext -d mail Call Calls 0
>
> will write `"Calls"`.
>
> The command
>
>
>     ngettext -d mail Call Calls 10
>
> will write `"Calls"`.
>
> The command
>
>
>     ngettext -ed mail "%d attachment\n" "%d attachments\n" 1
>
> will write the same as
>
>
>     printf "1 (%%d) attachment\n"
>
> (i.e. `"1 (%d) attachment"` followed by a \<newline\> character). The output of *ngettext* can be used as a format string for [*printf*](../utilities/printf.html).
>
> The command
>
>
>     printf "$(ngettext -ed mail "%d attachment\n" "%d attachments\n" 1)" 10
>
> will write the same as
>
>
>     printf "1 (%d) attachment\n" 10
>
> (i.e. `"1 (10) attachment"` followed by a \<newline\> character).
>
> The command
>
>
>     ngettext -e -d mail "\tsubject\n" "\tsubjects\n" 0
>
> will write the same as
>
>
>     printf "\tsubjects\n"
>
> (i.e. a \<tab\> character, followed by `"subjects"` followed by a \<newline\> character). Note that `"\tsubject\n"` is not in the messages object.
>
> The command
>
>
>     printf "%s\n" "$(ngettext -E -d mail "subject" "subjects" 0)"
>
> will write the same as
>
>
>     printf "subjects\n"
>
> (i.e. `"subjects"` followed by a \<newline\> character). Note that `"subject"` is not in the messages object.
>
> The command
>
>
>     gettext -s -d mail "recipient"
>
> will write `"1 recipient"` followed by a \<newline\> character.
>
> The command
>
>
>     gettext -s -n -d mail "recipient"
>
> will write `"1 recipient"` without a \<newline\> character.

#### <span id="tag_20_54_18"></span>RATIONALE

> Historical implementations did not support the `'\a'` C-language escape sequence. This standard requires it to be supported for consistency with other utilities that support the table in XBD [*5. File Format Notation*](../basedefs/V1_chap05.html#tag_05).
>
> Unlike other standard utilities, the behavior of *gettext* and *ngettext* is not undefined when *NLSPATH* overrides the system default path; see XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02). This is so that applications can use these utilities to obtain message strings from messages objects in other locations. However, it also means that they need to be implemented in such a way that they do not do anything that would result in undefined behavior when they need to write a diagnostic message. In particular, they should not use a string obtained from a message catalog or a messages object as a format string (or should only do so after checking that the string contains the correct conversions).

#### <span id="tag_20_54_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_54_20"></span>SEE ALSO

> [*msgfmt*](../utilities/msgfmt.html#), [*printf*](../utilities/printf.html#tag_20_96)
>
> XBD [*7. Locale*](../basedefs/V1_chap07.html#tag_07), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*gettext*()](../functions/gettext.html#tag_17_238), [*iconv*()](../functions/iconv.html#tag_17_248), [*setlocale*()](../functions/setlocale.html#)

#### <span id="tag_20_54_21"></span>CHANGE HISTORY

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
