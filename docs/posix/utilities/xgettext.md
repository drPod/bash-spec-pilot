The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="xgettext"></span> <span id="tag_20_153"></span>

#### <span id="tag_20_153_01"></span>NAME

> xgettext — extract *gettext* call strings from C-language source files (DEVELOPMENT)

#### <span id="tag_20_153_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`CD`](javascript:open_code('CD'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` xgettext`` `**`[`**`-j`**`] [`**`-n`**`] [`**`-d`` `*`default-domain`***`] [`**`-K`` `*`keyword-spec`***`]`**`...`\
> `      `` `**`[`**`-p`` `*`pathname`***`]`**` `*`file`*`...`\
> \
> `xgettext -a`` `**`[`**`-n`**`] [`**`-d`` `*`default-domain`***`] [`**`-p`` `*`pathname`***`]`\**
> ` ``      `` `**`[`**`-x`` `*`exclude-file`***`]`**` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_153_03"></span>DESCRIPTION

> The *xgettext* utility shall automate the creation of portable messages object source files (dot-po files). A dot-po file shall contain copies of string literals that are found in C-language source code in files specified by *file* operands. The dot-po file can be used as input to the [*msgfmt*](../utilities/msgfmt.html) utility, to produce a messages object file that can be used by applications.
>
> The *xgettext* utility shall write *msgid* argument strings that are passed as string literals in [*gettext*()](../functions/gettext.html), [*gettext_l*()](../functions/gettext_l.html), [*ngettext*()](../functions/ngettext.html), and [*ngettext_l*()](../functions/ngettext_l.html) calls in C-language source code to the default output file; this file shall be named **messages.po** unless it is changed by the **-d** option. The *xgettext* utility shall also write *msgid* argument strings that are passed as string literals in [*dcgettext*()](../functions/dcgettext.html), [*dcgettext_l*()](../functions/dcgettext_l.html), [*dcngettext*()](../functions/dcngettext.html), [*dcngettext_l*()](../functions/dcngettext_l.html), [*dgettext*()](../functions/dgettext.html), [*dgettext_l*()](../functions/dgettext_l.html), [*dngettext*()](../functions/dngettext.html), and [*dngettext_l*()](../functions/dngettext_l.html) calls either to the default output file or to the output file *domainname***.po** where *domainname* is the first parameter to the call; it is implementation-defined which of those output files is used. A **msgid** directive shall precede each *msgid* argument string. For the functions that have a *msgid_plural* argument, a **msgid_plural** directive followed by that argument string shall also be written directly after the corresponding **msgid** directive. A **msgstr** directive or **msgstr\[***index***\]** directives with an empty string shall be written after the corresponding **msgid** or **msgid_plural** directive, respectively. The function names that *xgettext* searches for can be changed using the **-K** option.
>
> The first directive in each created dot-po file shall be a **domain** directive giving the associated domain name, except that this directive is optional in the default output file.
>
> If the **-p** *pathname* option is specified, *xgettext* shall create the dot-po files in the *pathname* directory. Otherwise, the dot-po files shall be created in the current working directory.
>
> The **msgid** values shall be in the same order that the strings are extracted from each *file* and subsections with duplicate **msgid** values shall be written to the dot-po files as comment lines.

#### <span id="tag_20_153_04"></span>OPTIONS

> The *xgettext* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a**
>
> Extract all strings, not just those found in calls to *gettext* family functions. Only one dot-po file shall be created.
>
> **-d ***default-domain*
>
> \
> Name the default output file *default-domain***.po** instead of **messages.po**.
>
> **-j**
>
> Join messages from C-language source files with existing dot-po files. For each dot-po file that *xgettext* writes messages to, if the file does not exist, it shall be created. New messages shall be appended but any subsections with duplicate **msgid** values except the first (including **msgid** values found in an existing dot-po file) shall either be commented out or omitted in the resulting dot-po file; if omitted, a warning message may be written to standard error. Domain directives in the existing dot-po files shall be ignored; the assumption is that all previous **msgid** values belong to the same domain. The behavior is unspecified if an existing dot-po file was not created by *xgettext* or has been modified by another application.
>
> **-K ***keyword-spec*
>
> \
> Specify an additional keyword to be looked for:
>
> - If *keyword-spec* is an empty string, this shall disable the use of default keywords for the *gettext* family of functions.
>
> - If *keyword-spec* is a C identifier, *xgettext* shall look for strings in the first argument of each call to the function or macro *keyword-spec*.
>
> - If *keyword-spec* is of the form *id*:*argnum* then *xgettext* shall treat the *argnum*-th argument of a call to the function or macro *id* as the *msgid* argument, where *argnum* 1 is the first argument.
>
> - If *keyword-spec* is of the form *id*:*argnum1*,*argnum2* then *xgettext* shall treat strings in the *argnum1*-th argument and in the *argnum2*-th argument of a call to the function or macro *id* as the *msgid* and *msgid_plural* arguments, respectively.
>
> For all mentioned forms, the application shall ensure that if *argnum2* is given, it is not equal to *argnum1*. All numeric values shall be converted as specified in item 6 in XBD [*12.1 Utility Argument Syntax*](../basedefs/V1_chap12.html#tag_12_01).
>
> **-n**
>
> Add comment lines to the output file indicating pathnames and line numbers in the source files where each extracted string is encountered. These lines shall appear before each **msgid** directive. Such comments should have the format:
>
>
>     #: pathname1:linenumber1 [pathname2:linenumber2...]
>
> **-p ***pathname*
>
> \
> Create output files in the directory specified by *pathname* instead of in the current working directory.
>
> **-x ***exclude-file*
>
> \
> Specify a file containing strings that shall not be extracted from the input files. The format of *exclude-file* is identical to that of a dot-po file. However, only statements containing **msgid** directives in *exclude-file* shall be used. All other statements shall be ignored.

#### <span id="tag_20_153_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an input file containing C-language source code. If `'-'` is specified for an instance of *file*, the standard input shall be used.

#### <span id="tag_20_153_06"></span>STDIN

> The standard input shall not be used unless a *file* operand is specified as `'-'`.

#### <span id="tag_20_153_07"></span>INPUT FILES

> The input files specified as *file* operands shall be C-language source files. The input file specified as the option-argument for the **-x** option shall be a dot-po file in the format specified as input for the [*msgfmt*](../utilities/msgfmt.html) utility.

#### <span id="tag_20_153_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *xgettext*:
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

#### <span id="tag_20_153_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_153_10"></span>STDOUT

> The standard output shall not be used.

#### <span id="tag_20_153_11"></span>STDERR

> The standard error shall be used for diagnostic messages and may be used for warning messages.

#### <span id="tag_20_153_12"></span>OUTPUT FILES

> The output files shall be dot-po files in the format specified as input for the [*msgfmt*](../utilities/msgfmt.html) utility. It is unspecified whether each output file includes a header (**msgid** `""`) before the content derived from the input C-language source files.

#### <span id="tag_20_153_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_153_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_153_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_153_16"></span>APPLICATION USAGE

> Implementations differ as to whether they write all output to the default output file or split the output into separate per-domain files. Portable applications can either ensure that each C-language source file contains calls to *gettext* family functions for only a single domain, or force all output to be to the default output file by using the **-K** option to override the default keywords.
>
> Some implementations of *xgettext* are not able to extract cast strings (unless **-a** is used), for example casts of literal strings to **(const char \*)**. Use of a cast is unnecessary anyway, since the prototypes in [*\<libintl.h\>*](../basedefs/libintl.h.html) already specify this type.
>
> The *xgettext* utility is not required to handle C preprocessor directives. Therefore if, for example, calls to *gettext* family functions are wrapped by macros, they might not be found unless the **-K** option is used to tell *xgettext* to look for the macro calls.

#### <span id="tag_20_153_17"></span>EXAMPLES

> **Example 1**
>
> The following example shows how **-K** can be used to force all output to be to the default output file:
>
>
>     xgettext -K "" -K gettext:1 -K dgettext:2 -K dcgettext:2 \
>         -K ngettext:1,2 -K dngettext:2,3 -K dcngettext:2,3 source.c
>
> By overriding the default keywords using the **-K** option as above, the *xgettext* utility is directed to ignore the *domainname* arguments to the [*dgettext*()](../functions/dgettext.html), [*dcgettext*()](../functions/dcgettext.html), [*dngettext*()](../functions/dngettext.html), and [*dcngettext*()](../functions/dcngettext.html) functions. Thus, the utility treats the functions as their respective equivalent without the *d* prefix, ignoring the *domainname* argument and writing generated output to the default output file, **messages.po**. Additional **-K** options would be needed for the variants of the functions with an *\_l* suffix if they are used.
>
> **Example 2**
>
> If the source uses a macro definition such as:
>
>
>     #define i18n gettext
>
> the use of:
>
>
>     xgettext -K i18n:1 source.c
>
> will pick up **msgid** values from a line such as:
>
>
>     fprintf(stdout, i18n("The value is %s"), value1);

#### <span id="tag_20_153_18"></span>RATIONALE

> The **-K** option is based on the **-k** option of GNU *xgettext*; the only difference is that GNU's **-k** takes an optional option-argument whereas **-K** in this standard has a mandatory option-argument in order to comply with the syntax guidelines.
>
> The standard developers considered including functionality equivalent to the **-c**, **-m**, and **-M** options in existing implementations. However, those letters could not be used as the syntax differed between implementations. The usual solution of adding an uppercase equivalent of lowercase options with the standard syntax instead was not possible, for obvious reasons for **-m** and **-M**, and as **-C** was already in use for another purpose in one implementation.
>
> The **-s** option is not included as it has been deprecated in at least one implementation because it has been found to deprive translators of valuable context.

#### <span id="tag_20_153_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> A future version of this standard may change the description of the **-n** option to mandate the given comment format (by using "shall" instead of "should").

#### <span id="tag_20_153_20"></span>SEE ALSO

> [*gettext*](../utilities/gettext.html#tag_20_54), [*msgfmt*](../utilities/msgfmt.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*gettext*()](../functions/gettext.html#tag_17_238)

#### <span id="tag_20_153_21"></span>CHANGE HISTORY

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
