The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_07"></span>7. Locale

### <span id="tag_07_01"></span>7.1 General

A locale is the definition of the subset of a user's environment that depends on language and cultural conventions. It is made up from one or more categories. Each category is identified by its name and controls specific aspects of the behavior of components of the system. Category names correspond to the following environment variable names:

*LC_CTYPE*

Character classification and case conversion.

*LC_COLLATE*

Collation order.

*LC_MONETARY*

Monetary formatting.

*LC_NUMERIC*

Numeric, non-monetary formatting.

*LC_TIME*

Date and time formats.

*LC_MESSAGES*

Formats of informative and diagnostic messages and interactive responses.

The standard utilities in the Shell and Utilities volume of POSIX.1-2024 shall base their behavior on the current locale, as defined in the ENVIRONMENT VARIABLES section for each utility. The behavior of some of the C-language functions defined in the System Interfaces volume of POSIX.1-2024 shall also be modified based on a locale selection. The locale to be used by these functions can be selected in the following ways:

1.  For functions such as [*isalnum_l*()](../functions/isalnum_l.html) that take a locale object as an argument, a locale object can be obtained from [*newlocale*()](../functions/newlocale.html) or [*duplocale*()](../functions/duplocale.html) and passed to the function.

2.  For functions that do not take a locale object as an argument, the current locale for the thread can be set by calling [*uselocale*()](../functions/uselocale.html) or the global locale for the process can be set by calling [*setlocale*()](../functions/setlocale.html). Such functions shall use the current locale of the calling thread if one has been set for that thread; otherwise, they shall use the global locale.

3.  Some functions, such as [*catopen*()](../functions/catopen.html) and those related to text domains, may reference various environment variables and a locale category of a specific locale to access files they need to use.

Locales other than those supplied by the implementation can be created via the [*localedef*](../utilities/localedef.html) utility, provided that the \_POSIX2_LOCALEDEF symbol is defined on the system. Even if [*localedef*](../utilities/localedef.html) is not provided, all implementations conforming to the System Interfaces volume of POSIX.1-2024 shall provide one or more locales that behave as described in this chapter. The input to the utility is described in [7.3 Locale Definition](#tag_07_03). The value that is used to specify a locale when using environment variables shall be the string specified as the *name* operand to the [*localedef*](../utilities/localedef.html) utility when the locale was created. The strings `"C"` and `"POSIX"` are reserved as identifiers for the POSIX locale (see [7.2 POSIX Locale](#tag_07_02)). When the value of a locale environment variable begins with a \<slash\> (`'/'`), it shall be interpreted as the pathname of the locale definition; the type of file (regular, directory, and so on) used to store the locale definition is implementation-defined. If the value does not begin with a \<slash\>, the mechanism used to locate the locale is implementation-defined.

If incompatible character sets are used by the locale categories, the results achieved by an application utilizing these categories are undefined. Two locale categories have incompatible character sets if one of the categories is *LC_CTYPE* and the locale data associated with the other category includes at least one character that either is not in the character set used by *LC_CTYPE* or has a different encoding than the same character in the character set used by *LC_CTYPE .*

Likewise, unless specified otherwise, if different codesets are used by a particular category of the selected locale and by the data being processed by an interface whose behavior is dependent on that category of the selected locale, the results are undefined.

Applications can select the desired locale by calling the [*newlocale*()](../functions/newlocale.html) or [*setlocale*()](../functions/setlocale.html) function with the appropriate value. If the function is invoked with an empty string, such as:


    newlocale(LC_ALL_MASK, "", (locale_t)0);

or:


    setlocale(LC_ALL, "");

the value of the corresponding environment variable is used. If the environment variable is unset or is set to the empty string, the implementation shall set the appropriate environment as defined in [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08).

### <span id="tag_07_02"></span>7.2 POSIX Locale

Conforming systems shall provide a POSIX locale, also known as the C locale. In POSIX.1 the requirements for the POSIX locale are more extensive than the requirements for the C locale as specified in the ISO C standard. However, in a conforming POSIX implementation, the POSIX locale and the C locale are identical. The behavior of standard utilities and functions in the POSIX locale shall be as if the locale was defined via the [*localedef*](../utilities/localedef.html) utility with input data from the POSIX locale tables in [7.3 Locale Definition](#tag_07_03).

For C-language programs, the POSIX locale shall be the default locale when the [*setlocale*()](../functions/setlocale.html) function is not called.

The POSIX locale can be specified by assigning to the appropriate environment variables the values `"C"` or `"POSIX"`.

All implementations shall define a locale as the default locale, to be invoked when no environment variables are set, or set to the empty string. This default locale can be the POSIX locale or any other implementation-defined locale. Some implementations may provide facilities for local installation administrators to set the default locale, customizing it for each location. POSIX.1-2024 does not require such a facility.

### <span id="tag_07_03"></span>7.3 Locale Definition

The capability to specify additional locales to those provided by an implementation is optional, denoted by the \_POSIX2_LOCALEDEF symbol. If the option is not supported, only implementation-supplied locales are available. Such locales shall be documented using the format specified in this section.

Locales can be described with the file format presented in this section. The file format is that accepted by the [*localedef*](../utilities/localedef.html) utility. For the purposes of this section, the file is referred to as the "locale definition file", but no locales shall be affected by this file unless it is processed by [*localedef*](../utilities/localedef.html) or some similar mechanism. Any requirements in this section imposed upon the utility shall apply to [*localedef*](../utilities/localedef.html) or to any other similar utility used to install locale information using the locale definition file format described here.

The locale definition file shall contain one or more locale category source definitions, and shall not contain more than one definition for the same locale category. If the file contains source definitions for more than one category, implementation-defined categories, if present, shall appear after the categories defined by [7.1 General](#tag_07_01). A category source definition contains either the definition of a category or a **copy** directive. For a description of the **copy** directive, see [*localedef*](../utilities/localedef.html). In the event that some of the information for a locale category, as specified in this volume of POSIX.1-2024, is missing from the locale source definition, the behavior of that category, if it is referenced, is unspecified.

A category source definition shall consist of a category header, a category body, and a category trailer. A category header shall consist of the character string naming of the category, beginning with the characters *LC\_ .* The category trailer shall consist of the string `"END"`, followed by one or more \<blank\> characters and the string used in the corresponding category header.

The category body shall consist of one or more lines of text. Each line shall contain an identifier, optionally followed by one or more operands. Identifiers shall be either keywords, identifying a particular locale element, or collating elements. In addition to the keywords defined in this volume of POSIX.1-2024, the source can contain implementation-defined keywords. Each keyword within a locale shall have a unique name (that is, two categories cannot have a commonly-named keyword); no keyword shall start with the characters *LC\_ .* Identifiers shall be separated from the operands by one or more \<blank\> characters.

Operands shall be characters, collating elements, or strings of characters. Strings shall be enclosed in double-quotes. Literal double-quotes within strings shall be preceded by the \<*escape character*\>, described below. When a keyword is followed by more than one operand, the operands shall be separated by \<semicolon\> characters; \<blank\> characters shall be allowed both before and after a \<semicolon\>.

The first category header in the file can be preceded by a line modifying the comment character. It shall have the following format, starting in column 1:


    "comment_char %c\n", <comment character>

The comment character shall default to the \<number-sign\> (`'#'`). Blank lines and lines containing the \<*comment character*\> in the first position shall be ignored.

The first category header in the file can be preceded by a line modifying the escape character to be used in the file. It shall have the following format, starting in column 1:


    "escape_char %c\n", <escape character>

The escape character shall default to \<backslash\>, which is the character used in all examples shown in this volume of POSIX.1-2024.

A line can be continued by placing an escape character as the last character on the line; this continuation character shall be discarded from the input. Although the implementation need not accept any one portion of a continued line with a length exceeding {LINE_MAX} bytes, it shall place no limits on the accumulated length of the continued line. Comment lines shall not be continued on a subsequent line using an escaped \<newline\>.

Individual characters, characters in strings, and collating elements shall be represented using symbolic names, as defined below. In addition, characters can be represented using the characters themselves or as octal, hexadecimal, or decimal constants. When non-symbolic notation is used, the resultant locale definitions are in many cases not portable between systems. The left angle bracket (`'<'`) is a reserved symbol, denoting the start of a symbolic name; when used to represent itself it shall be preceded by the escape character. The following rules apply to character representation:

1.  A character can be represented via a symbolic name, enclosed within angle brackets `'<'` and `'>'`. The symbolic name, including the angle brackets, shall exactly match a symbolic name defined in the charmap file specified via the [*localedef*](../utilities/localedef.html) **-f** option, and it shall be replaced by a character value determined from the value associated with the symbolic name in the charmap file. The use of a symbolic name not found in the charmap file shall constitute an error, unless the category is *LC_CTYPE* or *LC_COLLATE ,* in which case it shall constitute a warning condition (see [*localedef*](../utilities/localedef.html) for a description of actions resulting from errors and warnings). The specification of a symbolic name in a **collating-element** or **collating-symbol** section that duplicates a symbolic name in the charmap file (if present) shall be an error. Use of the escape character or a right angle bracket within a symbolic name is invalid unless the character is preceded by the escape character.

    For example:


        <c>;<c-cedilla>  "<M><a><y>"

2.  A character in the portable character set can be represented by the character itself, in which case the value of the character is implementation-defined. (Implementations may allow other characters to be represented as themselves, but such locale definitions are not portable.) Within a string, the double-quote character, the escape character, and the right angle bracket character shall be escaped (preceded by the escape character) to be interpreted as the character itself. Outside strings, the characters:


        ,    ;    <    >    escape_char

    shall be escaped to be interpreted as the character itself.

    For example:


        c    "May"

3.  A character can be represented as an octal constant. An octal constant shall be specified as the escape character followed by two or three octal digits. Each constant shall represent a byte value. Multi-byte values can be represented by concatenated constants specified in byte order with the last constant specifying the least significant byte of the character.

    For example:


        \143;\347;\143\150   "\115\141\171"

4.  A character can be represented as a hexadecimal constant. A hexadecimal constant shall be specified as the escape character followed by an `'x'` followed by two hexadecimal digits. Each constant shall represent a byte value. Multi-byte values can be represented by concatenated constants specified in byte order with the last constant specifying the least significant byte of the character.

    For example:


        \x63;\xe7;\x63\x68   "\x4d\x61\x79"

5.  A character can be represented as a decimal constant. A decimal constant shall be specified as the escape character followed by a `'d'` followed by two or three decimal digits. Each constant represents a byte value. Multi-byte values can be represented by concatenated constants specified in byte order with the last constant specifying the least significant byte of the character.

    For example:


        \d99;\d231;\d99\d104  "\d77\d97\d121"

Implementations may accept single-digit octal, decimal, or hexadecimal constants following the escape character. Only characters existing in the character set for which the locale definition is created shall be specified, whether using symbolic names, the characters themselves, or octal, decimal, or hexadecimal constants. If a charmap file is present, only characters defined in the charmap can be specified using octal, decimal, or hexadecimal constants. Symbolic names not present in the charmap file can be specified and shall be ignored, as specified under item 1 above.

#### <span id="tag_07_03_01"></span>7.3.1 LC_CTYPE

The *LC_CTYPE* category shall define character classification, case conversion, and other character attributes. In addition, a series of characters can be represented by three adjacent \<period\> characters representing an ellipsis symbol (`"..."`). The ellipsis specification shall be interpreted as meaning that all values between the values preceding and following it represent valid characters. The ellipsis specification shall be valid only within a single encoded character set; that is, within a group of characters of the same size. An ellipsis shall be interpreted as including in the list all characters with an encoded value higher than the encoded value of the character preceding the ellipsis and lower than the encoded value of the character following the ellipsis.\

For example:


    \x30;...;\x39;

includes in the character class all characters with encoded values between the endpoints.

The following keywords shall be recognized. In the descriptions, the term "automatically included" means that it shall not be an error either to include or omit any of the referenced characters; the implementation provides them if missing (even if the entire keyword is missing) and accepts them silently if present. When the implementation automatically includes a missing character, it shall have an encoded value dependent on the charmap file in effect (see the description of the [*localedef*](../utilities/localedef.html) **-f** option); otherwise, it shall have a value derived from an implementation-defined character mapping.

The character classes **digit**, **xdigit**, **lower**, **upper**, and **space** have a set of automatically included characters. It is not possible to define a locale without these automatically included characters unless some implementation extension is used to prevent their inclusion. Such a definition would not be a proper superset of the C or POSIX locale and, thus, it might not be possible for conforming applications to work properly.

**copy**

Specify the name of an existing locale which shall be used as the definition of this category. If this keyword is specified, no other keyword shall be specified.

**upper**

Define characters to be classified as uppercase letters.

In the POSIX locale, only:


    A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

shall be included:

In a locale definition file, no character specified for the keywords **cntrl**, **digit**, **punct**, or **space** shall be specified. The uppercase letters \<A\> to \<Z\>, as defined in [*6.4 Character Set Description File*](../basedefs/V1_chap06.html#tag_06_04) (the portable character set), are automatically included in this class.

**lower**

Define characters to be classified as lowercase letters.

In the POSIX locale, only:


    a b c d e f g h i j k l m n o p q r s t u v w x y z

shall be included.

In a locale definition file, no character specified for the keywords **cntrl**, **digit**, **punct**, or **space** shall be specified. The lowercase letters \<a\> to \<z\> of the portable character set are automatically included in this class.

**alpha**

Define characters to be classified as letters.

In the POSIX locale, only characters in the classes **upper** and **lower** shall be included.

In a locale definition file, no character specified for the keywords **cntrl**, **digit**, **punct**, or **space** shall be specified. Characters classified as either **upper** or **lower** are automatically included in this class.

**digit**

Define the characters to be classified as numeric digits.

In all locales, only:


    0 1 2 3 4 5 6 7 8 9

shall be included.

In a locale definition file, only the digits \<zero\>, \<one\>, \<two\>, \<three\>, \<four\>, \<five\>, \<six\>, \<seven\>, \<eight\>, and \<nine\> shall be specified, and in contiguous ascending sequence by numerical value. The digits \<zero\> to \<nine\> of the portable character set are automatically included in this class.

**alnum**

Define characters to be classified as letters and numeric digits. Only the characters specified for the **alpha** and **digit** keywords shall be specified. Characters specified for the keywords **alpha** and **digit** are automatically included in this class.

**space**

Define characters to be classified as white-space characters.

In the POSIX locale, exactly \<space\>, \<form-feed\>, \<newline\>, \<carriage-return\>, \<tab\>, and \<vertical-tab\> shall be included.

In a locale definition file, no character specified for the keywords **upper**, **lower**, **alpha**, **digit**, **graph**, or **xdigit** shall be specified. The \<space\>, \<form-feed\>, \<newline\>, \<carriage-return\>, \<tab\>, and \<vertical-tab\> of the portable character set, and any characters included in the class **blank** are automatically included in this class.

**cntrl**

Define characters to be classified as control characters.

In the POSIX locale, no characters in classes **alpha** or **print** shall be included.

In a locale definition file, no character specified for the keywords **upper**, **lower**, **alpha**, **digit**, **punct**, **graph**, **print**, or **xdigit** shall be specified.

**punct**

Define characters to be classified as punctuation characters.

In the POSIX locale, neither the \<space\> nor any characters in classes **alpha**, **digit**, or **cntrl** shall be included.

In a locale definition file, no character specified for the keywords **upper**, **lower**, **alpha**, **digit**, **cntrl**, **xdigit**, or as the \<space\> shall be specified.

**graph**

Define characters to be classified as printable characters, not including the \<space\>.

In the POSIX locale, all characters in classes **alpha**, **digit**, and **punct** shall be included; no characters in class **cntrl** shall be included.

In a locale definition file, characters specified for the keywords **upper**, **lower**, **alpha**, **digit**, **xdigit**, and **punct** are automatically included in this class. No character specified for the keyword **cntrl** shall be specified.

**print**

Define characters to be classified as printable characters, including the \<space\>.

In the POSIX locale, all characters in class **graph** shall be included; no characters in class **cntrl** shall be included.

In a locale definition file, characters specified for the keywords **upper**, **lower**, **alpha**, **digit**, **xdigit**, **punct,** **graph**, and the \<space\> are automatically included in this class. No character specified for the keyword **cntrl** shall be specified.

**xdigit**

Define the characters to be classified as hexadecimal digits.

In all locales, only:


    0 1 2 3 4 5 6 7 8 9 A B C D E F a b c d e f

shall be included.

In a locale definition file, only the characters defined for the class **digit** shall be specified, in contiguous ascending sequence by numerical value, followed by two sets, in either order, of six characters representing the hexadecimal digits corresponding to the decimal numbers 10 to 15 inclusive, with each set in ascending order: \<A\>, \<B\>, \<C\>, \<D\>, \<E\>, \<F\> and \<a\>, \<b\>, \<c\>, \<d\>, \<e\>, \<f\>. The digits \<zero\> to \<nine\>, the uppercase letters \<A\> to \<F\>, and the lowercase letters \<a\> to \<f\> of the portable character set are automatically included in this class.

**blank**

Define characters to be classified as \<blank\> characters.

In the POSIX locale, only the \<space\> and \<tab\> shall be included.

In a locale definition file, no character specified for the keywords **upper**, **lower**, **alpha**, **digit**, **graph**, or **xdigit** shall be specified, and none of the characters \<form-feed\>, \<newline\>, \<carriage-return\>, and \<vertical-tab\> of the portable character set shall be specified. The \<space\> and \<tab\> are automatically included in this class.

**charclass**

Define one or more locale-specific character class names as strings separated by \<semicolon\> characters. Each named character class can then be defined subsequently in the *LC_CTYPE* definition. A character class name shall consist of at least one and at most {CHARCLASS_NAME_MAX} bytes of alphanumeric characters from the portable filename character set. The first character of a character class name shall not be a digit. The name shall not match any of the *LC_CTYPE* keywords defined in this volume of POSIX.1-2024. Future versions of this standard will not specify any *LC_CTYPE* keywords containing uppercase letters.

*charclass-name*

Define characters to be classified as belonging to the named locale-specific character class. In the POSIX locale, locale-specific named character classes need not exist.

If a class name is defined by a **charclass** keyword, but no characters are subsequently assigned to it, this is not an error; it represents a class without any characters belonging to it.

The *charclass-name* can be used as the *property* argument to the [*wctype*()](../functions/wctype.html) function, in regular expression and shell pattern-matching bracket expressions, and by the [*tr*](../utilities/tr.html) command.

**toupper**

Define the mapping of lowercase letters to uppercase letters.

In the POSIX locale, the 26 lowercase characters:


    a b c d e f g h i j k l m n o p q r s t u v w x y z

shall be mapped to the corresponding 26 uppercase characters:


    A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

In a locale definition file, the operand shall consist of character pairs, separated by \<semicolon\> characters. The characters in each character pair shall be separated by a \<comma\> and the pair enclosed by parentheses. The first character in each pair is the lowercase letter, the second the corresponding uppercase letter. Only characters specified for the keywords **lower** and **upper** shall be specified. The lowercase letters \<a\> to \<z\>, and their corresponding uppercase letters \<A\> to \<Z\>, of the portable character set are automatically included in this mapping, but only when the **toupper** keyword is omitted from the locale definition.

**tolower**

Define the mapping of uppercase letters to lowercase letters.

In the POSIX locale, the 26 uppercase characters:


    A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

shall be mapped to the corresponding 26 lowercase characters:


    a b c d e f g h i j k l m n o p q r s t u v w x y z

In a locale definition file, the operand shall consist of character pairs, separated by \<semicolon\> characters. The characters in each character pair shall be separated by a \<comma\> and the pair enclosed by parentheses. The first character in each pair is the uppercase letter, the second the corresponding lowercase letter. Only characters specified for the keywords **lower** and **upper** shall be specified. If the **tolower** keyword is omitted from the locale definition, the mapping is the reverse mapping of the one specified for **toupper**.

The following table shows the character class combinations allowed:\

<span id="tagtcjh_5"></span> Table: Valid Character Class Combinations

<table data-border="1" data-cellpadding="3" data-align="center">
<thead>
<tr data-valign="top">
<th style="text-align: center;"><p><strong> </strong></p></th>
<th colspan="11" style="text-align: center;"><p><strong>Can Also Belong To</strong></p></th>
</tr>
</thead>
<tbody>
<tr data-valign="top">
<th style="text-align: center;"><p><strong>In Class</strong></p></th>
<th style="text-align: center;"><p><strong>upper</strong></p></th>
<th style="text-align: center;"><p><strong>lower</strong></p></th>
<th style="text-align: center;"><p><strong>alpha</strong></p></th>
<th style="text-align: center;"><p><strong>digit</strong></p></th>
<th style="text-align: center;"><p><strong>space</strong></p></th>
<th style="text-align: center;"><p><strong>cntrl</strong></p></th>
<th style="text-align: center;"><p><strong>punct</strong></p></th>
<th style="text-align: center;"><p><strong>graph</strong></p></th>
<th style="text-align: center;"><p><strong>print</strong></p></th>
<th style="text-align: center;"><p><strong>xdigit</strong></p></th>
<th style="text-align: center;"><p><strong>blank</strong></p></th>
</tr>
&#10;<tr data-valign="top">
<td style="text-align: left;"><p><strong>upper</strong></p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>x</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>lower</strong></p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>x</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>alpha</strong></p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>x</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>digit</strong></p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>x</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>space</strong></p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>*</p></td>
<td style="text-align: center;"><p>*</p></td>
<td style="text-align: center;"><p>*</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>—</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>cntrl</strong></p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>—</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>punct</strong></p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>—</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>graph</strong></p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>print</strong></p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>xdigit</strong></p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"></td>
<td style="text-align: center;"><p>x</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>blank</strong></p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p>A</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>*</p></td>
<td style="text-align: center;"><p>*</p></td>
<td style="text-align: center;"><p>*</p></td>
<td style="text-align: center;"><p>x</p></td>
<td style="text-align: center;"><p> </p></td>
</tr>
</tbody>
</table>

\

**Notes:**  
1.  Explanation of codes:
    A
    Automatically included; see text.
    —
    Permitted.
    x
    Mutually-exclusive.
    \*
    See note 2.
2.  The \<space\>, which is part of the **space** and **blank** classes, cannot belong to **punct** or **graph**, but shall automatically belong to the **print** class. Other **space** or **blank** characters can be classified as any of **punct**, **graph**, or **print**.

##### <span id="tag_07_03_01_01"></span>7.3.1.1 LC_CTYPE Category in the POSIX Locale

The minimum character classifications for the POSIX locale follow; the code listing depicts the [*localedef*](../utilities/localedef.html) input, and the table represents the same information, sorted by character. Implementations may add additional characters to the **cntrl** and **punct** classifications but shall not make any other additions.


    LC_CTYPE
    # The following is the minimum POSIX locale LC_CTYPE.
    # "alpha" is by definition "upper" and "lower"
    # "alnum" is by definition "alpha" and "digit"
    # "print" is by definition "alnum", "punct", and the <space>
    # "graph" is by definition "alnum" and "punct"
    #
    upper    <A>;<B>;<C>;<D>;<E>;<F>;<G>;<H>;<I>;<J>;<K>;<L>;<M>;\
             <N>;<O>;<P>;<Q>;<R>;<S>;<T>;<U>;<V>;<W>;<X>;<Y>;<Z>
    #
    lower    <a>;<b>;<c>;<d>;<e>;<f>;<g>;<h>;<i>;<j>;<k>;<l>;<m>;\
             <n>;<o>;<p>;<q>;<r>;<s>;<t>;<u>;<v>;<w>;<x>;<y>;<z>
    #
    digit    <zero>;<one>;<two>;<three>;<four>;<five>;<six>;\
             <seven>;<eight>;<nine>
    #
    space    <tab>;<newline>;<vertical-tab>;<form-feed>;\
             <carriage-return>;<space>
    #
    cntrl    <alert>;<backspace>;<tab>;<newline>;<vertical-tab>;\
             <form-feed>;<carriage-return>;\
             <NUL>;<SOH>;<STX>;<ETX>;<EOT>;<ENQ>;<ACK>;<SO>;\
             <SI>;<DLE>;<DC1>;<DC2>;<DC3>;<DC4>;<NAK>;<SYN>;\
             <ETB>;<CAN>;<EM>;<SUB>;<ESC>;<IS4>;<IS3>;<IS2>;\
             <IS1>;<DEL>
    #
    punct    <exclamation-mark>;<quotation-mark>;<number-sign>;\
             <dollar-sign>;<percent-sign>;<ampersand>;<apostrophe>;\
             <left-parenthesis>;<right-parenthesis>;<asterisk>;\
             <plus-sign>;<comma>;<hyphen-minus>;<period>;<slash>;\
             <colon>;<semicolon>;<less-than-sign>;<equals-sign>;\
             <greater-than-sign>;<question-mark>;<commercial-at>;\
             <left-square-bracket>;<backslash>;<right-square-bracket>;\
             <circumflex>;<underscore>;<grave-accent>;<left-curly-bracket>;\
             <vertical-line>;<right-curly-bracket>;<tilde>
    #
    xdigit   <zero>;<one>;<two>;<three>;<four>;<five>;<six>;<seven>;\
             <eight>;<nine>;<A>;<B>;<C>;<D>;<E>;<F>;<a>;<b>;<c>;<d>;<e>;<f>
    #
    blank    <space>;<tab>
    #
    toupper (<a>,<A>);(<b>,<B>);(<c>,<C>);(<d>,<D>);(<e>,<E>);\
            (<f>,<F>);(<g>,<G>);(<h>,<H>);(<i>,<I>);(<j>,<J>);\
            (<k>,<K>);(<l>,<L>);(<m>,<M>);(<n>,<N>);(<o>,<O>);\
            (<p>,<P>);(<q>,<Q>);(<r>,<R>);(<s>,<S>);(<t>,<T>);\
            (<u>,<U>);(<v>,<V>);(<w>,<W>);(<x>,<X>);(<y>,<Y>);(<z>,<Z>)
    #
    tolower (<A>,<a>);(<B>,<b>);(<C>,<c>);(<D>,<d>);(<E>,<e>);\
            (<F>,<f>);(<G>,<g>);(<H>,<h>);(<I>,<i>);(<J>,<j>);\
            (<K>,<k>);(<L>,<l>);(<M>,<m>);(<N>,<n>);(<O>,<o>);\
            (<P>,<p>);(<Q>,<q>);(<R>,<r>);(<S>,<s>);(<T>,<t>);\
            (<U>,<u>);(<V>,<v>);(<W>,<w>);(<X>,<x>);(<Y>,<y>);(<Z>,<z>)
    END LC_CTYPE

| **Symbolic Name** | **Other Case** | **Character Classes** |
|:---|:--:|:---|
| \<NUL\> |   | **cntrl** |
| \<SOH\> |   | **cntrl** |
| \<STX\> |   | **cntrl** |
| \<ETX\> |   | **cntrl** |
| \<EOT\> |   | **cntrl** |
| \<ENQ\> |   | **cntrl** |
| \<ACK\> |   | **cntrl** |
| \<alert\> |   | **cntrl** |
| \<backspace\> |   | **cntrl** |
| \<tab\> |   | **cntrl, space, blank** |
| \<newline\> |   | **cntrl, space** |
| \<vertical-tab\> |   | **cntrl, space** |
| \<form-feed\> |   | **cntrl, space** |
| \<carriage-return\> |   | **cntrl, space** |
| \<SO\> |   | **cntrl** |
| \<SI\> |   | **cntrl** |
| \<DLE\> |   | **cntrl** |
| \<DC1\> |   | **cntrl** |
| \<DC2\> |   | **cntrl** |
| \<DC3\> |   | **cntrl** |
| \<DC4\> |   | **cntrl** |
| \<NAK\> |   | **cntrl** |
| \<SYN\> |   | **cntrl** |
| \<ETB\> |   | **cntrl** |
| \<CAN\> |   | **cntrl** |
| \<EM\> |   | **cntrl** |
| \<SUB\> |   | **cntrl** |
| \<ESC\> |   | **cntrl** |
| \<IS4\> |   | **cntrl** |
| \<IS3\> |   | **cntrl** |
| \<IS2\> |   | **cntrl** |
| \<IS1\> |   | **cntrl** |
| \<space\> |   | **space, print, blank** |
| \<exclamation-mark\> |   | **punct, print, graph** |
| \<quotation-mark\> |   | **punct, print, graph** |
| \<number-sign\> |   | **punct, print, graph** |
| \<dollar-sign\> |   | **punct, print, graph** |
| \<percent-sign\> |   | **punct, print, graph** |
| \<ampersand\> |   | **punct, print, graph** |
| \<apostrophe\> |   | **punct, print, graph** |
| \<left-parenthesis\> |   | **punct, print, graph** |
| \<right-parenthesis\> |   | **punct, print, graph** |
| \<asterisk\> |   | **punct, print, graph** |
| \<plus-sign\> |   | **punct, print, graph** |
| \<comma\> |   | **punct, print, graph** |
| \<hyphen-minus\> |   | **punct, print, graph** |
| \<period\> |   | **punct, print, graph** |
| \<slash\> |   | **punct, print, graph** |
| \<zero\> |   | **digit, xdigit, print, graph** |
| \<one\> |   | **digit, xdigit, print, graph** |
| \<two\> |   | **digit, xdigit, print, graph** |
| \<three\> |   | **digit, xdigit, print, graph** |
| \<four\> |   | **digit, xdigit, print, graph** |
| \<five\> |   | **digit, xdigit, print, graph** |
| \<six\> |   | **digit, xdigit, print, graph** |
| \<seven\> |   | **digit, xdigit, print, graph** |
| \<eight\> |   | **digit, xdigit, print, graph** |
| \<nine\> |   | **digit, xdigit, print, graph** |
| \<colon\> |   | **punct, print, graph** |
| \<semicolon\> |   | **punct, print, graph** |
| \<less-than-sign\> |   | **punct, print, graph** |
| \<equals-sign\> |   | **punct, print, graph** |
| \<greater-than-sign\> |   | **punct, print, graph** |
| \<question-mark\> |   | **punct, print, graph** |
| \<commercial-at\> |   | **punct, print, graph** |
| \<A\> | \<a\> | **upper, xdigit, alpha, print, graph** |
| \<B\> | \<b\> | **upper, xdigit, alpha, print, graph** |
| \<C\> | \<c\> | **upper, xdigit, alpha, print, graph** |
| \<D\> | \<d\> | **upper, xdigit, alpha, print, graph** |
| \<E\> | \<e\> | **upper, xdigit, alpha, print, graph** |
| \<F\> | \<f\> | **upper, xdigit, alpha, print, graph** |
| \<G\> | \<g\> | **upper, alpha, print, graph** |
| \<H\> | \<h\> | **upper, alpha, print, graph** |
| \<I\> | \<i\> | **upper, alpha, print, graph** |
| \<J\> | \<j\> | **upper, alpha, print, graph** |
| \<K\> | \<k\> | **upper, alpha, print, graph** |
| \<L\> | \<l\> | **upper, alpha, print, graph** |
| \<M\> | \<m\> | **upper, alpha, print, graph** |
| \<N\> | \<n\> | **upper, alpha, print, graph** |
| \<O\> | \<o\> | **upper, alpha, print, graph** |
| \<P\> | \<p\> | **upper, alpha, print, graph** |
| \<Q\> | \<q\> | **upper, alpha, print, graph** |
| \<R\> | \<r\> | **upper, alpha, print, graph** |
| \<S\> | \<s\> | **upper, alpha, print, graph** |
| \<T\> | \<t\> | **upper, alpha, print, graph** |
| \<U\> | \<u\> | **upper, alpha, print, graph** |
| \<V\> | \<v\> | **upper, alpha, print, graph** |
| \<W\> | \<w\> | **upper, alpha, print, graph** |
| \<X\> | \<x\> | **upper, alpha, print, graph** |
| \<Y\> | \<y\> | **upper, alpha, print, graph** |
| \<Z\> | \<z\> | **upper, alpha, print, graph** |
| \<left-square-bracket\> |   | **punct, print, graph** |
| \<backslash\> |   | **punct, print, graph** |
| \<right-square-bracket\> |   | **punct, print, graph** |
| \<circumflex\> |   | **punct, print, graph** |
| \<underscore\> |   | **punct, print, graph** |
| \<grave-accent\> |   | **punct, print, graph** |
| \<a\> | \<A\> | **lower, xdigit, alpha, print, graph** |
| \<b\> | \<B\> | **lower, xdigit, alpha, print, graph** |
| \<c\> | \<C\> | **lower, xdigit, alpha, print, graph** |
| \<d\> | \<D\> | **lower, xdigit, alpha, print, graph** |
| \<e\> | \<E\> | **lower, xdigit, alpha, print, graph** |
| \<f\> | \<F\> | **lower, xdigit, alpha, print, graph** |
| \<g\> | \<G\> | **lower, alpha, print, graph** |
| \<h\> | \<H\> | **lower, alpha, print, graph** |
| \<i\> | \<I\> | **lower, alpha, print, graph** |
| \<j\> | \<J\> | **lower, alpha, print, graph** |
| \<k\> | \<K\> | **lower, alpha, print, graph** |
| \<l\> | \<L\> | **lower, alpha, print, graph** |
| \<m\> | \<M\> | **lower, alpha, print, graph** |
| \<n\> | \<N\> | **lower, alpha, print, graph** |
| \<o\> | \<O\> | **lower, alpha, print, graph** |
| \<p\> | \<P\> | **lower, alpha, print, graph** |
| \<q\> | \<Q\> | **lower, alpha, print, graph** |
| \<r\> | \<R\> | **lower, alpha, print, graph** |
| \<s\> | \<S\> | **lower, alpha, print, graph** |
| \<t\> | \<T\> | **lower, alpha, print, graph** |
| \<u\> | \<U\> | **lower, alpha, print, graph** |
| \<v\> | \<V\> | **lower, alpha, print, graph** |
| \<w\> | \<W\> | **lower, alpha, print, graph** |
| \<x\> | \<X\> | **lower, alpha, print, graph** |
| \<y\> | \<Y\> | **lower, alpha, print, graph** |
| \<z\> | \<Z\> | **lower, alpha, print, graph** |
| \<left-curly-bracket\> |   | **punct, print, graph** |
| \<vertical-line\> |   | **punct, print, graph** |
| \<right-curly-bracket\> |   | **punct, print, graph** |
| \<tilde\> |   | **punct, print, graph** |
| \<DEL\> |   | **cntrl** |

#### <span id="tag_07_03_02"></span>7.3.2 LC_COLLATE

The *LC_COLLATE* category provides a collation sequence definition for numerous utilities in the Shell and Utilities volume of POSIX.1-2024 ([*ls*](../utilities/ls.html), [*sort*](../utilities/sort.html), and so on), regular expression matching (see [*9. Regular Expressions*](../basedefs/V1_chap09.html#tag_09)), and the [*strcoll*()](../functions/strcoll.html), [*strxfrm*()](../functions/strxfrm.html), [*wcscoll*()](../functions/wcscoll.html), and [*wcsxfrm*()](../functions/wcsxfrm.html) functions in the System Interfaces volume of POSIX.1-2024.

A collation sequence definition shall define the relative order between collating elements (characters and multi-character collating elements) in the locale. This order is expressed in terms of collation values; that is, by assigning each element one or more collation values (also known as collation weights). This does not imply that implementations shall assign such values, but that ordering of strings using the resultant collation definition in the locale behaves as if such assignment is done and used in the collation process. At least the following capabilities are provided:

1.  **Multi-character collating elements**. Specification of multi-character collating elements (that is, sequences of two or more characters to be collated as an entity).
2.  **User-defined ordering of collating elements**. Each collating element shall be assigned a collation value defining its order in the character (or basic) collation sequence. This ordering is used by regular expressions and pattern matching and, unless collation weights are explicitly specified, also as the collation weight to be used in sorting.
3.  **Multiple weights and equivalence classes**. Collating elements can be assigned one or more (up to the limit {COLL_WEIGHTS_MAX}, as defined in [*\<limits.h\>*](../basedefs/limits.h.html)) collating weights for use in sorting. The first weight is hereafter referred to as the primary weight.
4.  **One-to-many mapping**. A single character is mapped into a string of collating elements.
5.  **Equivalence class definition**. Two or more collating elements have the same collation value (primary weight).
6.  **Ordering by weights**. When two strings are compared to determine their relative order, the two strings are first broken up into a series of collating elements; the elements in each successive pair of elements are then compared according to the relative primary weights for the elements. If equal, and more than one weight has been assigned, then the pairs of collating elements are re-compared according to the relative subsequent weights, until either a pair of collating elements compare unequal or the weights are exhausted.

All implementation-provided locales (either preinstalled or provided as locale definitions which can be installed later) shall define a collation sequence that has a total ordering of all characters unless the locale name has an `'@'` modifier indicating that it has a special collation sequence (for example, `@icase` could indicate that each upper and lowercase character pair collates equally).

**Note:**  
Users installing their own locales should ensure that they define a collation sequence with a total ordering of all characters unless an `'@'` modifier in the locale name (such as `@icase`) indicates that it has a special collation sequence. As \<NUL\> is reserved as the string terminator for most usages of *LC_COLLATE ,* it is the responsibility of the locale writer to ensure \<NUL\> has the lowest primary weight in a collation ordering for the interfaces to behave in the way users typically expect. Unusual behavior may result if it has any other collation order weighting, or is subject to **IGNORE**.

The following keywords shall be recognized in a collation sequence definition. They are described in detail in the following sections.

**copy**

Specify the name of an existing locale which shall be used as the definition of this category. If this keyword is specified, no other keyword shall be specified.

**collating-element**

Define a collating-element symbol representing a multi-character collating element. This keyword is optional.

**collating-symbol**

Define a collating symbol for use in collation order statements. This keyword is optional.

**order_start**

Define collation rules. This statement shall be followed by one or more collation order statements, assigning character collation values and collation weights to collating elements.

**order_end**

Specify the end of the collation-order statements.

##### <span id="tag_07_03_02_01"></span>7.3.2.1 The collating-element Keyword

In addition to the collating elements in the character set, the **collating-element** keyword can be used to define multi-character collating elements. The syntax is as follows:


    "collating-element %s from \"%s\"\n", <collating-symbol>, <string>

The \<*collating-symbol*\> operand shall be a symbolic name, enclosed between angle brackets (`'<'` and `'>'`), and shall not duplicate any symbolic name in the current charmap file (if any), or any other symbolic name defined in this collation definition. The string operand is a string of two or more characters that collates as an entity. A \<*collating-element*\> defined via this keyword is only recognized with the *LC_COLLATE* category.

For example:


    collating-element <ch> from "<c><h>"
    collating-element <e-acute> from "<acute><e>"
    collating-element <ll> from "ll"

##### <span id="tag_07_03_02_02"></span>7.3.2.2 The collating-symbol Keyword

This keyword shall be used to define symbols for use in collation sequence statements; that is, between the **order_start** and the **order_end** keywords. The syntax is as follows:


    "collating-symbol %s\n", <collating-symbol>

The \<*collating-symbol*\> shall be a symbolic name, enclosed between angle brackets (`'<'` and `'>'`), and shall not duplicate any symbolic name in the current charmap file (if any), or any other symbolic name defined in this collation definition. A \<*collating-symbol*\> defined via this keyword is only recognized within the *LC_COLLATE* category.

For example:


    collating-symbol <UPPER_CASE>
    collating-symbol <HIGH>

The **collating-symbol** keyword defines a symbolic name that can be associated with a relative position in the character order sequence. While such a symbolic name does not represent any collating element, it can be used as a weight.

##### <span id="tag_07_03_02_03"></span>7.3.2.3 The order_start Keyword

The **order_start** keyword shall precede collation order entries and also define the number of weights for this collation sequence definition and other collation rules. The syntax is as follows:


    "order_start %s;%s;...;%s\n", <sort-rules>, <sort-rules> ...

The operands to the **order_start** keyword are optional. If present, the operands define rules to be applied when strings are compared. The number of operands define how many weights each element is assigned; if no operands are present, one **forward** operand is assumed. If present, the first operand defines rules to be applied when comparing strings using the first (primary) weight; the second when comparing strings using the second weight, and so on. Operands shall be separated by \<semicolon\> characters (`';'`). Each operand shall consist of one or more collation directives, separated by \<comma\> characters (`','`). If the number of operands exceeds the {COLL_WEIGHTS_MAX} limit, the utility shall issue a warning message. The following directives shall be supported:

**forward**

Specifies that comparison operations for the weight level shall proceed from start of string towards the end of string.

**backward**

Specifies that comparison operations for the weight level shall proceed from end of string towards the beginning of string.

**position**

Specifies that comparison operations for the weight level shall consider the relative position of elements in the strings not subject to **IGNORE**. The string containing an element not subject to **IGNORE** after the fewest collating elements subject to **IGNORE** from the start of the compare shall collate first. If both strings contain a character not subject to **IGNORE** in the same relative position, the collating values assigned to the elements shall determine the ordering. In case of equality, subsequent characters not subject to **IGNORE** shall be considered in the same manner.

The directives **forward** and **backward** are mutually-exclusive.

If no operands are specified, a single **forward** operand shall be assumed.\

For example:


    order_start    forward;backward

##### <span id="tag_07_03_02_04"></span>7.3.2.4 Collation Order

The **order_start** keyword shall be followed by collating identifier entries. The syntax for the collating element entries is as follows:


    "%s %s;%s;...;%s\n", <collating-identifier>, <weight>, <weight>, ...

Each *collating-identifier* shall consist of either a character (in any of the forms defined in [7.3 Locale Definition](#tag_07_03)), a \<*collating-element*\>, a \<*collating-symbol*\>, an ellipsis, or the special symbol **UNDEFINED**. The order in which collating elements are specified determines the character order sequence, such that each collating element shall compare less than the elements following it.

A \<*collating-element*\> shall be used to specify multi-character collating elements, and indicates that the character sequence specified via the \<*collating-element*\> is to be collated as a unit and in the relative order specified by its place.

A \<*collating-symbol*\> can be used to define a position in the relative order for use in weights. No weights shall be specified with a \<*collating-symbol*\>.

The ellipsis symbol specifies that a sequence of characters shall collate according to their encoded character values. It shall be interpreted as indicating that all characters with a coded character set value higher than the value of the character in the preceding line, and lower than the coded character set value for the character in the following line, in the current coded character set, shall be placed in the character collation order between the previous and the following character in ascending order according to their coded character set values. An initial ellipsis shall be interpreted as if the preceding line specified the NUL character, and a trailing ellipsis as if the following line specified the highest coded character set value in the current coded character set. An ellipsis shall be treated as invalid if the preceding or following lines do not specify characters in the current coded character set. The use of the ellipsis symbol ties the definition to a specific coded character set and may preclude the definition from being portable between implementations.

The symbol **UNDEFINED** shall be interpreted as including all coded character set values not specified explicitly or via the ellipsis symbol. Such characters shall be inserted in the character collation order at the point indicated by the symbol, and in ascending order according to their coded character set values. If no **UNDEFINED** symbol is specified, and the current coded character set contains characters not specified in this section, the utility shall issue a warning message and place such characters at the end of the character collation order.

The optional operands for each collation-element shall be used to define the primary, secondary, or subsequent weights for the collating element. The first operand specifies the relative primary weight, the second the relative secondary weight, and so on. Two or more collation-elements can be assigned the same weight; they belong to the same "equivalence class" if they have the same primary weight. Collation shall behave as if, for each weight level, elements subject to **IGNORE** are removed, unless the **position** collation directive is specified for the corresponding level with the **order_start** keyword. Then each successive pair of elements shall be compared according to the relative weights for the elements. If the two strings compare equal, the process shall be repeated for the next weight level, up to the limit {COLL_WEIGHTS_MAX}.

Weights shall be assigned such that the collation sequence has a total ordering of all characters unless an `'@'` modifier in the locale name indicates that it has a special collation sequence.

Weights shall be expressed as characters (in any of the forms specified in [7.3 Locale Definition](#tag_07_03)), \<*collating-symbol*\>s, \<*collating-element*\>s, an ellipsis, or the special symbol **IGNORE**. A single character, a \<*collating-symbol*\>, or a \<*collating-element*\> shall represent the relative position in the character collating sequence of the character or symbol, rather than the character or characters themselves. Thus, rather than assigning absolute values to weights, a particular weight is expressed using the relative order value assigned to a collating element based on its order in the character collation sequence.

One-to-many mapping is indicated by specifying two or more concatenated characters or symbolic names. For example, if the \<eszet\> is given the string `"<s><s>"` as a weight, comparisons are performed as if all occurrences of the \<eszet\> are replaced by `"<s><s>"` (assuming that `"<s>"` has the collating weight `"<s>"`). If it is necessary to define \<eszet\> and `"<s><s>"` as an equivalence class, then a collating element needs to be defined for the string `"ss"`.

All characters specified via an ellipsis shall by default be assigned unique weights, equal to the relative order of characters. Characters specified via an explicit or implicit **UNDEFINED** special symbol shall by default be assigned the same primary weight (that is, they belong to the same equivalence class) if the collation order has more than one weight level. If the collation order has only one weight level, these characters shall be assigned unique primary weights, equal to the relative order of their character in the character collation sequence.

An ellipsis symbol as a weight shall be interpreted to mean that each character in the sequence shall have unique weights, equal to the relative order of their character in the character collation sequence. The use of the ellipsis as a weight shall be treated as an error if the collating element is neither an ellipsis nor the special symbol **UNDEFINED**.

The special keyword **IGNORE** as a weight shall indicate that when strings are compared using the weights at the level where **IGNORE** is specified, the collating element shall be ignored; that is, as if the string did not contain the collating element. In regular expressions and pattern matching, all characters that are subject to **IGNORE** in their primary weight form an equivalence class.

An empty operand shall be interpreted as the collating element itself.

For example, the order statement:


    <a>    <a>;<a>

is equal to:


    <a>

An ellipsis can be used as an operand if the collating element was an ellipsis, and shall be interpreted as the value of each character defined by the ellipsis.

The collation order as defined in this section affects the interpretation of bracket expressions in regular expressions (see [*9.3.5 RE Bracket Expression*](../basedefs/V1_chap09.html#tag_09_03_05)).\

For example:


    order_start  forward;backward
    <NUL>        <NUL>;<NUL>
    <LOW>
    <space>      <LOW>;<space>
    ...          <LOW>;...
    <a>          <a>;<a>
    <a-acute>    <a>;<a-acute>
    <a-grave>    <a>;<a-grave>
    <A>          <a>;<A>
    <A-acute>    <a>;<A-acute>
    <A-grave>    <a>;<A-grave>
    <ch>         <ch>;<ch>
    <Ch>         <ch>;<Ch>
    <s>          <s>;<s>
    <eszet>      "<s><s>";"<eszet><eszet>"
    UNDEFINED    IGNORE;...
    order_end

This example is interpreted as follows:

1.  All characters between \<space\> and `'a'` shall have the same primary equivalence class and individual secondary weights based on their ordinal encoded values.
2.  All characters based on the uppercase or lowercase character `'a'` belong to the same primary equivalence class.
3.  The multi-character collating element \<ch\> is represented by the collating symbol \<ch\> and belongs to the same primary equivalence class as the multi-character collating element \<Ch\>.
4.  The **UNDEFINED** means that all characters not specified in this definition (explicitly or via the ellipsis) shall be ignored when comparing primary weights, and have individual secondary weights based on their ordinal encoded values.

##### <span id="tag_07_03_02_05"></span>7.3.2.5 The order_end Keyword

The collating order entries shall be terminated with an **order_end** keyword.

##### <span id="tag_07_03_02_06"></span>7.3.2.6 LC_COLLATE Category in the POSIX Locale

The minimum collation sequence definition of the POSIX locale follows; the code listing depicts the [*localedef*](../utilities/localedef.html) input. All characters not explicitly listed here shall be inserted in the character collation order after the listed characters and shall be assigned unique primary weights. If the listed characters have ASCII encoding, the other characters shall be in ascending order according to their coded character set values; otherwise, the order of the other characters is unspecified. The collation sequence shall not include any multi-character collating elements.


    LC_COLLATE
    # This is the minimum input for the POSIX locale definition for the
    # LC_COLLATE category. Characters in this list are in the same order
    # as in the ASCII codeset.
    order_start forward
    <NUL>
    <SOH>
    <STX>
    <ETX>
    <EOT>
    <ENQ>
    <ACK>
    <alert>
    <backspace>
    <tab>
    <newline>
    <vertical-tab>
    <form-feed>
    <carriage-return>
    <SO>
    <SI>
    <DLE>
    <DC1>
    <DC2>
    <DC3>
    <DC4>
    <NAK>
    <SYN>
    <ETB>
    <CAN>
    <EM>
    <SUB>
    <ESC>
    <IS4>
    <IS3>
    <IS2>
    <IS1>
    <space>
    <exclamation-mark>
    <quotation-mark>
    <number-sign>
    <dollar-sign>
    <percent-sign>
    <ampersand>
    <apostrophe>
    <left-parenthesis>
    <right-parenthesis>
    <asterisk>
    <plus-sign>
    <comma>
    <hyphen-minus>
    <period>
    <slash>
    <zero>
    <one>
    <two>
    <three>
    <four>
    <five>
    <six>
    <seven>
    <eight>
    <nine>
    <colon>
    <semicolon>
    <less-than-sign>
    <equals-sign>
    <greater-than-sign>
    <question-mark>
    <commercial-at>
    <A>
    <B>
    <C>
    <D>
    <E>
    <F>
    <G>
    <H>
    <I>
    <J>
    <K>
    <L>
    <M>
    <N>
    <O>
    <P>
    <Q>
    <R>
    <S>
    <T>
    <U>
    <V>
    <W>
    <X>
    <Y>
    <Z>
    <left-square-bracket>
    <backslash>
    <right-square-bracket>
    <circumflex>
    <underscore>
    <grave-accent>
    <a>
    <b>
    <c>
    <d>
    <e>
    <f>
    <g>
    <h>
    <i>
    <j>
    <k>
    <l>
    <m>
    <n>
    <o>
    <p>
    <q>
    <r>
    <s>
    <t>
    <u>
    <v>
    <w>
    <x>
    <y>
    <z>
    <left-curly-bracket>
    <vertical-line>
    <right-curly-bracket>
    <tilde>
    <DEL>
    order_end
    #
    END LC_COLLATE

#### <span id="tag_07_03_03"></span>7.3.3 LC_MONETARY

The *LC_MONETARY* category shall define the rules and symbols that are used to format monetary numeric information.

This information is available through the [*localeconv*()](../functions/localeconv.html) function and is used by the [*strfmon*()](../functions/strfmon.html) function.

Some of the information is also available in an alternative form via the [*nl_langinfo*()](../functions/nl_langinfo.html) function (see CRNCYSTR in [*\<langinfo.h\>*](../basedefs/langinfo.h.html)).

The following items are defined in this category of the locale. The item names are the keywords recognized by the [*localedef*](../utilities/localedef.html) utility when defining a locale. They are also similar to the member names of the **lconv** structure defined in [*\<locale.h\>*](../basedefs/locale.h.html); see [*\<locale.h\>*](../basedefs/locale.h.html) for the exact symbols in the header. The [*localeconv*()](../functions/localeconv.html) function returns {CHAR_MAX} for unavailable integer items and the empty string (`""`) for unavailable or size zero string items.

In a locale definition file, the operands are strings, formatted as indicated by the grammar in [7.4 Locale Definition Grammar](#tag_07_04). For some keywords, the strings can contain only integers. Keywords that are not provided, or integer keywords set to -1, can be used to indicate that the value is not available in the locale. String values set to the empty string (`""`) can be used to indicate that the value is available and is an empty string, or that the value is not available. The following keywords shall be recognized:

**copy**

Specify the name of an existing locale which shall be used as the definition of this category. If this keyword is specified, no other keyword shall be specified.

**Note:**  
This is a [*localedef*](../utilities/localedef.html) utility keyword, unavailable through [*localeconv*()](../functions/localeconv.html).

**int_curr_symbol**

The international currency symbol. The operand shall be a four-character string, with the first three characters containing the alphabetic international currency symbol. The international currency symbol should be chosen in accordance with those specified in the ISO 4217 standard. The fourth character shall be the character used to separate the international currency symbol from the monetary quantity.

**currency_symbol**

The string that shall be used as the local currency symbol.

**mon_decimal_point**

The operand is a string containing the symbol that shall be used as the decimal delimiter (radix character) in monetary formatted quantities.

**mon_thousands_sep**

The operand is a string containing the symbol that shall be used as a separator for groups of digits to the left of the decimal delimiter in formatted monetary quantities.

**mon_grouping**

Define the size of each group of digits in formatted monetary quantities. The operand is a sequence of integers separated by \<semicolon\> characters. Each integer specifies the number of digits in each group, with the initial integer defining the size of the group immediately preceding the decimal delimiter, and the following integers defining the preceding groups. If the last integer is not -1, then the size of the previous group (if any) shall be repeatedly used for the remainder of the digits. If the last integer is -1, then no further grouping shall be performed.

**positive_sign**

A string that shall be used to indicate a non-negative-valued formatted monetary quantity.

**negative_sign**

A string that shall be used to indicate a negative-valued formatted monetary quantity.

**int_frac_digits**

An integer representing the number of fractional digits (those to the right of the decimal delimiter) to be written in a formatted monetary quantity using **int_curr_symbol**.

**frac_digits**

An integer representing the number of fractional digits (those to the right of the decimal delimiter) to be written in a formatted monetary quantity using **currency_symbol**.

**p_cs_precedes**

An integer set to 1 if the **currency_symbol** precedes the value for a monetary quantity with a non-negative value, and set to 0 if the symbol succeeds the value.

**p_sep_by_space**

Set to a value indicating the separation of the **currency_symbol**, the sign string, and the value for a non-negative formatted monetary quantity.

The values of **p_sep_by_space**, **n_sep_by_space**, **int_p_sep_by_space**, and **int_n_sep_by_space** are interpreted according to the following:

0

No \<space\> separates the currency symbol and value.

1

If the currency symbol and sign string are adjacent, a \<space\> separates them from the value; otherwise, a \<space\> separates the currency symbol from the value.

2

If the currency symbol and sign string are adjacent, a \<space\> separates them; otherwise, a \<space\> separates the sign string from the value.

**n_cs_precedes**

An integer set to 1 if the **currency_symbol** precedes the value for a monetary quantity with a negative value, and set to 0 if the symbol succeeds the value.

**n_sep_by_space**

Set to a value indicating the separation of the **currency_symbol**, the sign string, and the value for a negative formatted monetary quantity.

**p_sign_posn**

An integer set to a value indicating the positioning of the **positive_sign** for a monetary quantity with a non-negative value. The following integer values shall be recognized for **int_n_sign_posn**, **int_p_sign_posn**, **n_sign_posn**, and **p_sign_posn**:

0

Parentheses enclose the quantity and the **currency_symbol**.

1

The sign string precedes the quantity and the **currency_symbol**.

2

The sign string succeeds the quantity and the **currency_symbol**.

3

The sign string precedes the **currency_symbol**.

4

The sign string succeeds the **currency_symbol**.

**n_sign_posn**

An integer set to a value indicating the positioning of the **negative_sign** for a negative formatted monetary quantity.

**int_p_cs_precedes**

An integer set to 1 if the **int_curr_symbol** precedes the value for a monetary quantity with a non-negative value, and set to 0 if the symbol succeeds the value.

**int_n_cs_precedes**

An integer set to 1 if the **int_curr_symbol** precedes the value for a monetary quantity with a negative value, and set to 0 if the symbol succeeds the value.

**int_p_sep_by_space**

Set to a value indicating the separation of the **int_curr_symbol**, the sign string, and the value for a non-negative internationally formatted monetary quantity.

**int_n_sep_by_space**

Set to a value indicating the separation of the **int_curr_symbol**, the sign string, and the value for a negative internationally formatted monetary quantity.

**int_p_sign_posn**

An integer set to a value indicating the positioning of the **positive_sign** for a positive monetary quantity formatted with the international format.

**int_n_sign_posn**

An integer set to a value indicating the positioning of the **negative_sign** for a negative monetary quantity formatted with the international format.

Certain combinations of the **\*\_sign_posn**, **positive_sign**, and **negative_sign** values are invalid and shall not be accepted by [*localedef*](../utilities/localedef.html):

- If **p_sign_posn** and **n_sign_posn** are both greater than 0, and **positive_sign** and **negative_sign** have the same value or are both either empty strings or omitted, this combination is invalid because it requires signs to be used but does not provide the means to distinguish negative from positive values using signs.
- Likewise, if **int_p_sign_posn** and **int_n_sign_posn** are both greater than 0, and **positive_sign** and **negative_sign** have the same value or are both either empty strings or omitted, this combination is invalid.
- If **p_sign_posn** and **n_sign_posn** are both 0, this combination is invalid because it requires parentheses to be used but does not provide the means to distinguish negative from positive values using parentheses.
- Likewise, if **int_p_sign_posn** and **int_n_sign_posn** are both 0, this combination is invalid.

##### <span id="tag_07_03_03_01"></span>7.3.3.1 LC_MONETARY Category in the POSIX Locale

The monetary formatting definitions for the POSIX locale follow; the code listing depicting the [*localedef*](../utilities/localedef.html) input, the table representing the same information with the addition of [*localeconv*()](../functions/localeconv.html) and [*nl_langinfo*()](../functions/nl_langinfo.html) formats. All values shall be unavailable in the POSIX locale.


    LC_MONETARY
    # This is the POSIX locale definition for
    # the LC_MONETARY category.
    #
    int_curr_symbol      ""
    currency_symbol      ""
    mon_decimal_point    ""
    mon_thousands_sep    ""
    mon_grouping         -1
    positive_sign        ""
    negative_sign        ""
    int_frac_digits      -1
    frac_digits          -1
    p_cs_precedes        -1
    p_sep_by_space       -1
    n_cs_precedes        -1
    n_sep_by_space       -1
    p_sign_posn          -1
    n_sign_posn          -1
    int_p_cs_precedes    -1
    int_p_sep_by_space   -1
    int_n_cs_precedes    -1
    int_n_sep_by_space   -1
    int_p_sign_posn      -1
    int_n_sign_posn      -1
    #
    END LC_MONETARY

| **Item** | **langinfo Constant** | **POSIX Locale Value** | **localeconv() Value** | **localedef Value** |
|:---|:--:|:--:|:--:|:--:|
| **int_curr_symbol** | — | N/A | "" | "" |
| **currency_symbol** | CRNCYSTR | N/A | "" | "" |
| **mon_decimal_point** | — | N/A | "" | "" |
| **mon_thousands_sep** | — | N/A | "" | "" |
| **mon_grouping** | — | N/A | "" | -1 |
| **positive_sign** | — | N/A | "" | "" |
| **negative_sign** | — | N/A | "" | "" |
| **int_frac_digits** | — | N/A | {CHAR_MAX} | -1 |
| **frac_digits** | — | N/A | {CHAR_MAX} | -1 |
| **p_cs_precedes** | CRNCYSTR | N/A | {CHAR_MAX} | -1 |
| **p_sep_by_space** | — | N/A | {CHAR_MAX} | -1 |
| **n_cs_precedes** | CRNCYSTR | N/A | {CHAR_MAX} | -1 |
| **n_sep_by_space** | — | N/A | {CHAR_MAX} | -1 |
| **p_sign_posn** | — | N/A | {CHAR_MAX} | -1 |
| **n_sign_posn** | — | N/A | {CHAR_MAX} | -1 |
| **int_p_cs_precedes** | — | N/A | {CHAR_MAX} | -1 |
| **int_p_sep_by_space** | — | N/A | {CHAR_MAX} | -1 |
| **int_n_cs_precedes** | — | N/A | {CHAR_MAX} | -1 |
| **int_n_sep_by_space** | — | N/A | {CHAR_MAX} | -1 |
| **int_p_sign_posn** | — | N/A | {CHAR_MAX} | -1 |
| **int_n_sign_posn** | — | N/A | {CHAR_MAX} | -1 |

The entry N/A indicates that the value is not available in the POSIX locale.

#### <span id="tag_07_03_04"></span>7.3.4 LC_NUMERIC

The *LC_NUMERIC* category shall define the rules and symbols that are used to format non-monetary numeric information. This information is available through the [*localeconv*()](../functions/localeconv.html) function.

Some of the information is also available in an alternative form via the [*nl_langinfo*()](../functions/nl_langinfo.html) function.

The following items are defined in this category of the locale. The item names are the keywords recognized by the [*localedef*](../utilities/localedef.html) utility when defining a locale. They are also similar to the member names of the **lconv** structure defined in [*\<locale.h\>*](../basedefs/locale.h.html); see [*\<locale.h\>*](../basedefs/locale.h.html) for the exact symbols in the header. The [*localeconv*()](../functions/localeconv.html) function returns {CHAR_MAX} for unavailable integer items and the empty string (`""`) for unavailable or size zero string items.

In a locale definition file, the operands are strings, formatted as indicated by the grammar in [7.4 Locale Definition Grammar](#tag_07_04). For some keywords, the strings can only contain integers. Keywords that are not provided, or integer keywords set to -1, can be used to indicate that the value is not available in the locale. String values set to the empty string (`""`) can be used to indicate that the value is available and is an empty string, or that the value is not available. The following keywords shall be recognized:

**copy**

Specify the name of an existing locale which shall be used as the definition of this category. If this keyword is specified, no other keyword shall be specified.

**Note:**  
This is a [*localedef*](../utilities/localedef.html) utility keyword, unavailable through [*localeconv*()](../functions/localeconv.html).

**decimal_point**

The operand is a string containing the symbol that shall be used as the decimal delimiter (radix character) in numeric, non-monetary formatted quantities. This keyword cannot be omitted and cannot be set to the empty string. In contexts where standards limit the **decimal_point** to a single byte, the result of specifying a multi-byte operand shall be unspecified.

**thousands_sep**

The operand is a string containing the symbol that shall be used as a separator for groups of digits to the left of the decimal delimiter in numeric, non-monetary formatted monetary quantities. In contexts where standards limit the **thousands_sep** to a single byte, the result of specifying a multi-byte operand shall be unspecified.

**grouping**

Define the size of each group of digits in formatted non-monetary quantities. The operand is a sequence of integers separated by \<semicolon\> characters. Each integer specifies the number of digits in each group, with the initial integer defining the size of the group immediately preceding the decimal delimiter, and the following integers defining the preceding groups. If the last integer is not -1, then the size of the previous group (if any) shall be repeatedly used for the remainder of the digits. If the last integer is -1, then no further grouping shall be performed.

##### <span id="tag_07_03_04_01"></span>7.3.4.1 LC_NUMERIC Category in the POSIX Locale

The non-monetary numeric formatting definitions for the POSIX locale follow; the code listing depicting the [*localedef*](../utilities/localedef.html) input, the table representing the same information with the addition of [*localeconv*()](../functions/localeconv.html) values, and [*nl_langinfo*()](../functions/nl_langinfo.html) constants.


    LC_NUMERIC
    # This is the POSIX locale definition for
    # the LC_NUMERIC category.
    #
    decimal_point    "<period>"
    thousands_sep    ""
    grouping         -1
    #
    END LC_NUMERIC

| **Item** | **langinfo Constant** | **POSIX Locale Value** | **localeconv() Value** | **localedef Value** |
|:---|:--:|:--:|:--:|:--:|
| **decimal_point** | RADIXCHAR | "." | "." | . |
| **thousands_sep** | THOUSEP | N/A | "" | "" |
| **grouping** | — | N/A | "" | -1 |

The entry N/A indicates that the value is not available in the POSIX locale.

#### <span id="tag_07_03_05"></span>7.3.5 LC_TIME

The *LC_TIME* category shall define the interpretation of the conversion specifications supported by the [*date*](../utilities/date.html) utility and shall affect the behavior of the [*strftime*()](../functions/strftime.html), [*wcsftime*()](../functions/wcsftime.html), [*strptime*()](../functions/strptime.html), and [*nl_langinfo*()](../functions/nl_langinfo.html) functions. Since the interfaces for C-language access and locale definition differ significantly, they are described separately.

##### <span id="tag_07_03_05_01"></span>7.3.5.1 LC_TIME Locale Definition

In a locale definition, the following mandatory keywords shall be recognized:

**copy**

Specify the name of an existing locale which shall be used as the definition of this category. If this keyword is specified, no other keyword shall be specified.

**abday**

Define the abbreviated weekday names, corresponding to the `%a` conversion specification (conversion specification in the [*strftime*()](../functions/strftime.html), [*wcsftime*()](../functions/wcsftime.html), and [*strptime*()](../functions/strptime.html) functions). The operand shall consist of seven \<semicolon\>-separated strings, each surrounded by double-quotes. The first string shall be the abbreviated name of the day corresponding to Sunday, the second the abbreviated name of the day corresponding to Monday, and so on.

**day**

Define the full weekday names, corresponding to the `%A` conversion specification. The operand shall consist of seven \<semicolon\>-separated strings, each surrounded by double-quotes. The first string is the full name of the day corresponding to Sunday, the second the full name of the day corresponding to Monday, and so on.

**abmon**

Define the abbreviated month names, corresponding to the `%b` conversion specification. The operand shall consist of twelve \<semicolon\>-separated strings, each surrounded by double-quotes. The first string shall be the abbreviated name of the first month of the year (January), the second the abbreviated name of the second month, and so on. For languages having both a genitive (when used with a day number) and a nominative (no day number) case, this operand shall be used to denote the genitive case.

**ab_alt_mon**

Define the abbreviated month names, corresponding to the `%Ob` conversion specification. The operand shall consist of twelve \<semicolon\>-separated strings, each surrounded by double-quotes. The first string shall be the abbreviated name of the first month of the year (January), the second the abbreviated name of the second month, and so on. For languages having both a genitive (when used with a day number) and a nominative (no day number) case, this operand shall be used to denote the nominative case.

**mon**

Define the full month names, corresponding to the `%B` conversion specification. The operand shall consist of twelve \<semicolon\>-separated strings, each surrounded by double-quotes. The first string shall be the full name of the first month of the year (January), the second the full name of the second month, and so on. For languages having both a genitive (when used with a day number) and a nominative (no day number) case, this operand shall be used to denote the genitive case.

**alt_mon**

Define the full month names, corresponding to the `%OB` conversion specification. The operand shall consist of twelve \<semicolon\>-separated strings, each surrounded by double-quotes. The first string shall be the full name of the first month of the year (January), the second the full name of the second month, and so on. For languages having both a genitive (when used with a day number) and a nominative (no day number) case, this operand shall be used to denote the nominative case.

**d_t_fmt**

Define the appropriate date and time representation, corresponding to the `%c` conversion specification. The operand shall consist of a string containing any combination of characters and conversion specifications. In addition, the string can contain escape sequences defined in the table in [*Escape Sequences and Associated Actions*](../basedefs/V1_chap05.html#tagtcjh_2) (`'\\'`, `'\a'`, `'\b'`, `'\f'`, `'\n'`, `'\r'`, `'\t'`, `'\v'`).

**d_fmt**

Define the appropriate date representation, corresponding to the `%x` conversion specification. The operand shall consist of a string containing any combination of characters and conversion specifications. In addition, the string can contain escape sequences defined in [*Escape Sequences and Associated Actions*](../basedefs/V1_chap05.html#tagtcjh_2) .

**t_fmt**

Define the appropriate time representation, corresponding to the `%X` conversion specification. The operand shall consist of a string containing any combination of characters and conversion specifications. In addition, the string can contain escape sequences defined in [*Escape Sequences and Associated Actions*](../basedefs/V1_chap05.html#tagtcjh_2) .

**am_pm**

Define the appropriate representation of the *ante-meridiem* and *post-meridiem* strings, corresponding to the `%p` conversion specification. The operand shall consist of two strings, separated by a \<semicolon\>, each surrounded by double-quotes; the first string shall represent the *ante-meridiem* designation, the last string the *post-meridiem* designation. If and only if the 12-hour format is not supported in the locale, both strings shall be empty.

**t_fmt_ampm**

Define the appropriate time representation in the 12-hour clock format with **am_pm**, corresponding to the `%r` conversion specification. The operand shall consist of a string and can contain any combination of characters and conversion specifications. If and only if the 12-hour format is not supported in the locale, the string shall be empty.

**era**

Define how years are counted and displayed for each era in a locale. The operand shall consist of \<semicolon\>-separated strings. Each string shall be an era description segment with the format:


    direction:offset:start_date:end_date:era_name:era_format

according to the definitions below. There can be as many era description segments as are necessary to describe the different eras.

**Note:**  
The start of an era might not be the earliest point in the era—it may be the latest. For example, the Christian era BC starts on the day before January 1, AD 1, and increases with earlier time.

*direction*

Either a `'+'` or a `'-'` character. The `'+'` character shall indicate that years closer to the *start_date* have lower numbers than those closer to the *end_date*. The `'-'` character shall indicate that years closer to the *start_date* have higher numbers than those closer to the *end_date*.

*offset*

The number of the year closest to the *start_date* in the era, corresponding to the `%Ey` conversion specification.

*start_date*

A date in the form *yyyy*/*mm*/*dd*, where *yyyy*, *mm*, and *dd* are the year, month, and day numbers respectively of the start of the era. Years prior to AD 1 shall be represented as negative numbers.

*end_date*

The ending date of the era, in the same format as the *start_date*, or one of the two special values `"-*"` or `"+*"`. The value `"-*"` shall indicate that the ending date is the beginning of time. The value `"+*"` shall indicate that the ending date is the end of time.

*era_name*

A string representing the name of the era, corresponding to the `%EC` conversion specification.

*era_format*

A string for formatting the year in the era, corresponding to the `%EY` conversion specification.

**era_d_fmt**

Define the format of the date in alternative era notation, corresponding to the `%Ex` conversion specification.

**era_t_fmt**

Define the locale's appropriate alternative time format, corresponding to the `%EX` conversion specification.

**era_d_t_fmt**

Define the locale's appropriate alternative date and time format, corresponding to the `%Ec` conversion specification.

**alt_digits**

Define alternative symbols for digits, corresponding to the `%O` modified conversion specification. The operand shall consist of \<semicolon\>-separated strings, each surrounded by double-quotes. The first string shall be the alternative symbol corresponding with zero, the second string the symbol corresponding with one, and so on. Up to 100 alternative symbol strings can be specified. The `%O` modifier shall indicate that the string corresponding to the value specified via the conversion specification shall be used instead of the value.

##### <span id="tag_07_03_05_02"></span>7.3.5.2 LC_TIME C-Language Access

The following constants used to identify items of *langinfo* data can be used as arguments to the [*nl_langinfo*()](../functions/nl_langinfo.html) function to access information in the *LC_TIME* category. These constants are defined in the [*\<langinfo.h\>*](../basedefs/langinfo.h.html) header.

ABDAY\_*x*

The abbreviated weekday names (for example, Sun), where *x* is a number from 1 to 7.

DAY\_*x*

The full weekday names (for example, Sunday), where *x* is a number from 1 to 7.

ABMON\_*x*

The abbreviated month names (for example, Jan), where *x* is a number from 1 to 12.

ABALTMON\_*x*

The alternative abbreviated month names (for example, Jan), where *x* is a number from 1 to 12.

MON\_*x*

The full month names (for example, January), where *x* is a number from 1 to 12.

ALTMON\_*x*

The alternative full month names (for example, January), where *x* is a number from 1 to 12.

D_T_FMT

The appropriate date and time representation.

D_FMT

The appropriate date representation.

T_FMT

The appropriate time representation.

AM_STR

The appropriate ante-meridiem affix; if AM_STR and PM_STR are both empty strings, the 12-hour format is not supported in the locale.

PM_STR

The appropriate post-meridiem affix; if AM_STR and PM_STR are both empty strings, the 12-hour format is not supported in the locale.

T_FMT_AMPM

The appropriate time representation in the 12-hour clock format; if the 12-hour format is not supported in the locale, this shall be either an empty string or a string specifying a 24-hour clock format.

ERA

The era description segments, which describe how years are counted and displayed for each era in a locale. Each era description segment shall have the format:


    direction:offset:start_date:end_date:era_name:era_format

according to the definitions below. There can be as many era description segments as are necessary to describe the different eras. Era description segments are separated by \<semicolon\> characters.

*direction*

Either a `'+'` or a `'-'` character. The `'+'` character shall indicate that years closer to the *start_date* have lower numbers than those closer to the *end_date*. The `'-'` character shall indicate that years closer to the *start_date* have higher numbers than those closer to the *end_date*.

*offset*

The number of the year closest to the *start_date* in the era.

*start_date*

A date in the form *yyyy*/*mm*/*dd*, where *yyyy*, *mm*, and *dd* are the year, month, and day numbers respectively of the start of the era. Years prior to AD 1 shall be represented as negative numbers.

*end_date*

The ending date of the era, in the same format as the *start_date*, or one of the two special values `"-*"` or `"+*"`. The value `"-*"` shall indicate that the ending date is the beginning of time. The value `"+*"` shall indicate that the ending date is the end of time.

*era_name*

The era, corresponding to the `%EC` conversion specification.

*era_format*

The format of the year in the era, corresponding to the `%EY` conversion specification.

ERA_D_FMT

The era date format.

ERA_T_FMT

The locale's appropriate alternative time format, corresponding to the `%EX` conversion specification.

ERA_D_T_FMT

The locale's appropriate alternative date and time format, corresponding to the `%Ec` conversion specification.

ALT_DIGITS

The alternative symbols for digits, corresponding to the `%O` conversion specification modifier. The value consists of \<semicolon\>-separated symbols. The first is the alternative symbol corresponding to zero, the second is the symbol corresponding to one, and so on. Up to 100 alternative symbols may be specified.

##### <span id="tag_07_03_05_03"></span>7.3.5.3 LC_TIME Category in the POSIX Locale

The *LC_TIME* category definition of the POSIX locale follows; the code listing depicts the [*localedef*](../utilities/localedef.html) input; the table represents the same information with the addition of [*localedef*](../utilities/localedef.html) keywords, conversion specifiers used by the [*date*](../utilities/date.html) utility and the [*strftime*()](../functions/strftime.html), [*wcsftime*()](../functions/wcsftime.html), and [*strptime*()](../functions/strptime.html) functions, and [*nl_langinfo*()](../functions/nl_langinfo.html) constants.


    LC_TIME
    # This is the POSIX locale definition for
    # the LC_TIME category.
    #
    # Abbreviated weekday names (%a)
    abday      "<S><u><n>";"<M><o><n>";"<T><u><e>";"<W><e><d>";\
               "<T><h><u>";"<F><r><i>";"<S><a><t>"
    #
    # Full weekday names (%A)
    day        "<S><u><n><d><a><y>";"<M><o><n><d><a><y>";\
               "<T><u><e><s><d><a><y>";"<W><e><d><n><e><s><d><a><y>";\
               "<T><h><u><r><s><d><a><y>";"<F><r><i><d><a><y>";\
               "<S><a><t><u><r><d><a><y>"
    #
    # Abbreviated month names (%b)
    abmon      "<J><a><n>";"<F><e><b>";"<M><a><r>";\
               "<A><p><r>";"<M><a><y>";"<J><u><n>";\
               "<J><u><l>";"<A><u><g>";"<S><e><p>";\
               "<O><c><t>";"<N><o><v>";"<D><e><c>"
    #
    # Full month names (%B)
    mon        "<J><a><n><u><a><r><y>";"<F><e><b><r><u><a><r><y>";\
               "<M><a><r><c><h>";"<A><p><r><i><l>";\
               "<M><a><y>";"<J><u><n><e>";\
               "<J><u><l><y>";"<A><u><g><u><s><t>";\
               "<S><e><p><t><e><m><b><e><r>";"<O><c><t><o><b><e><r>";\
               "<N><o><v><e><m><b><e><r>";"<D><e><c><e><m><b><e><r>"
    #
    # Equivalent of AM/PM (%p)      "AM";"PM"
    am_pm      "<A><M>";"<P><M>"
    #
    # Appropriate date and time representation (%c)
    #    "%a %b %e %H:%M:%S %Y"
    d_t_fmt    "<percent-sign><a><space><percent-sign><b>\
    <space><percent-sign><e><space><percent-sign><H>\
    <colon><percent-sign><M><colon><percent-sign><S>\
    <space><percent-sign><Y>"
    #
    # Appropriate date representation (%x)   "%m/%d/%y"
    d_fmt      "<percent-sign><m><slash><percent-sign><d>\
    <slash><percent-sign><y>"
    #
    # Appropriate time representation (%X)   "%H:%M:%S"
    t_fmt      "<percent-sign><H><colon><percent-sign><M>\
    <colon><percent-sign><S>"
    #
    # Appropriate 12-hour time representation (%r) "%I:%M:%S %p"
    t_fmt_ampm "<percent-sign><I><colon><percent-sign><M><colon>\
    <percent-sign><S><space><percent-sign><p>"
    #
    END LC_TIME

| **localedef Keyword** | **langinfo Constant** | **Conversion Specification** | **POSIX Locale Value** |
|:---|:---|:---|:---|
| **d_t_fmt** | D_T_FMT | %c | "%a %b %e %H:%M:%S %Y" |
| **d_fmt** | D_FMT | %x | "%m/%d/%y" |
| **t_fmt** | T_FMT | %X | "%H:%M:%S" |
| **am_pm** | AM_STR | %p | "AM" |
| **am_pm** | PM_STR | %p | "PM" |
| **t_fmt_ampm** | T_FMT_AMPM | %r | "%I:%M:%S %p" |
| **day** | DAY_1 | %A | "Sunday" |
| **day** | DAY_2 | %A | "Monday" |
| **day** | DAY_3 | %A | "Tuesday" |
| **day** | DAY_4 | %A | "Wednesday" |
| **day** | DAY_5 | %A | "Thursday" |
| **day** | DAY_6 | %A | "Friday" |
| **day** | DAY_7 | %A | "Saturday" |
| **abday** | ABDAY_1 | %a | "Sun" |
| **abday** | ABDAY_2 | %a | "Mon" |
| **abday** | ABDAY_3 | %a | "Tue" |
| **abday** | ABDAY_4 | %a | "Wed" |
| **abday** | ABDAY_5 | %a | "Thu" |
| **abday** | ABDAY_6 | %a | "Fri" |
| **abday** | ABDAY_7 | %a | "Sat" |
| **mon** | MON_1 | %B | "January" |
| **mon** | MON_2 | %B | "February" |
| **mon** | MON_3 | %B | "March" |
| **mon** | MON_4 | %B | "April" |
| **mon** | MON_5 | %B | "May" |
| **mon** | MON_6 | %B | "June" |
| **mon** | MON_7 | %B | "July" |
| **mon** | MON_8 | %B | "August" |
| **mon** | MON_9 | %B | "September" |
| **mon** | MON_10 | %B | "October" |
| **mon** | MON_11 | %B | "November" |
| **mon** | MON_12 | %B | "December" |
| **alt_mon** | ALTMON_1 | %OB | N/A |
| **alt_mon** | ALTMON_2 | %OB | N/A |
| **alt_mon** | ALTMON_3 | %OB | N/A |
| **alt_mon** | ALTMON_4 | %OB | N/A |
| **alt_mon** | ALTMON_5 | %OB | N/A |
| **alt_mon** | ALTMON_6 | %OB | N/A |
| **alt_mon** | ALTMON_7 | %OB | N/A |
| **alt_mon** | ALTMON_8 | %OB | N/A |
| **alt_mon** | ALTMON_9 | %OB | N/A |
| **alt_mon** | ALTMON_10 | %OB | N/A |
| **alt_mon** | ALTMON_11 | %OB | N/A |
| **alt_mon** | ALTMON_12 | %OB | N/A |
| **abmon** | ABMON_1 | %b | "Jan" |
| **abmon** | ABMON_2 | %b | "Feb" |
| **abmon** | ABMON_3 | %b | "Mar" |
| **abmon** | ABMON_4 | %b | "Apr" |
| **abmon** | ABMON_5 | %b | "May" |
| **abmon** | ABMON_6 | %b | "Jun" |
| **abmon** | ABMON_7 | %b | "Jul" |
| **abmon** | ABMON_8 | %b | "Aug" |
| **abmon** | ABMON_9 | %b | "Sep" |
| **abmon** | ABMON_10 | %b | "Oct" |
| **abmon** | ABMON_11 | %b | "Nov" |
| **abmon** | ABMON_12 | %b | "Dec" |
| **ab_alt_mon** | ABALTMON_1 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_2 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_3 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_4 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_5 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_6 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_7 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_8 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_9 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_10 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_11 | %Ob | N/A |
| **ab_alt_mon** | ABALTMON_12 | %Ob | N/A |
| **era** | ERA | %EC, %Ey, %EY | N/A |
| **era_d_fmt** | ERA_D_FMT | %Ex | N/A |
| **era_t_fmt** | ERA_T_FMT | %EX | N/A |
| **era_d_t_fmt** | ERA_D_T_FMT | %Ec | N/A |
| **alt_digits** | ALT_DIGITS | %O | N/A |

The entry N/A indicates the value is not available in the POSIX locale.

#### <span id="tag_07_03_06"></span>7.3.6 LC_MESSAGES

The *LC_MESSAGES* category shall define the format and values used by various utilities for affirmative and negative responses. This information is available through the [*nl_langinfo*()](../functions/nl_langinfo.html) function.

The message catalog used by the standard utilities and selected by the [*catopen*()](../functions/catopen.html) function shall be determined by the setting of *NLSPATH ;* see [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08). The *LC_MESSAGES* category can be specified as part of an *NLSPATH* substitution field.

The following keywords shall be recognized as part of the locale definition file.

**copy**

Specify the name of an existing locale which shall be used as the definition of this category. If this keyword is specified, no other keyword shall be specified.

**Note:**  
This is a [*localedef*](../utilities/localedef.html) keyword, unavailable through [*nl_langinfo*()](../functions/nl_langinfo.html).

**yesexpr**

The operand consists of an extended regular expression (see [*9.4 Extended Regular Expressions*](../basedefs/V1_chap09.html#tag_09_04)) that describes acceptable affirmative responses to a question expecting an affirmative or negative response.

**noexpr**

The operand consists of an extended regular expression that describes acceptable negative responses to a question expecting an affirmative or negative response.

##### <span id="tag_07_03_06_01"></span>7.3.6.1 LC_MESSAGES Category in the POSIX Locale

The format and values for affirmative and negative responses of the POSIX locale follow; the code listing depicting the [*localedef*](../utilities/localedef.html) input, the table representing the same information with the addition of [*nl_langinfo*()](../functions/nl_langinfo.html) constants.


    LC_MESSAGES
    # This is the POSIX locale definition for
    # the LC_MESSAGES category.
    #
    yesexpr "<circumflex><left-square-bracket><y><Y><right-square-bracket>"
    #
    noexpr  "<circumflex><left-square-bracket><n><N><right-square-bracket>"
    #
    END LC_MESSAGES

| **localedef Keyword** | **langinfo Constant** | **POSIX Locale Value** |
|:----------------------|:----------------------|:-----------------------|
| **yesexpr**           | YESEXPR               | "^\[yY\]"              |
| **noexpr**            | NOEXPR                | "^\[nN\]"              |

### <span id="tag_07_04"></span>7.4 Locale Definition Grammar

The grammar and lexical conventions in this section shall together describe the syntax for the locale definition source. The general conventions for this style of grammar are described in XCU [*1.3 Grammar Conventions*](../utilities/V3_chap01.html#tag_18_03). The grammar shall take precedence over the text in this chapter.

#### <span id="tag_07_04_01"></span>7.4.1 Locale Lexical Conventions

The lexical conventions for the locale definition grammar are described in this section.

The following tokens shall be processed (in addition to those string constants shown in the grammar):

**LOC_NAME**

A string of characters representing the name of a locale.

**CHAR**

Any single character.

**NUMBER**

A decimal number, represented by one or more decimal digits.

**COLLSYMBOL**

A symbolic name, enclosed between angle brackets. The string cannot duplicate any charmap symbol defined in the current charmap (if any), or a **COLLELEMENT** symbol.

**COLLELEMENT**

A symbolic name, enclosed between angle brackets, which cannot duplicate either any charmap symbol or a **COLLSYMBOL** symbol.

**CHARCLASS**

A string of alphanumeric characters from the portable character set, the first of which is not a digit, consisting of at least one and at most {CHARCLASS_NAME_MAX} bytes, and optionally surrounded by double-quotes.

**CHARSYMBOL**

A symbolic name, enclosed between angle brackets, from the current charmap (if any).

**OCTAL_CHAR**

One or more octal representations of the encoding of each byte in a single character. The octal representation consists of an escape character (normally a \<backslash\>) followed by two or more octal digits.

**HEX_CHAR**

One or more hexadecimal representations of the encoding of each byte in a single character. The hexadecimal representation consists of an escape character followed by the constant *x* and two or more hexadecimal digits.

**DECIMAL_CHAR**

One or more decimal representations of the encoding of each byte in a single character. The decimal representation consists of an escape character followed by a character `'d'` and two or more decimal digits.

**ELLIPSIS**

The string `"..."`.

**EXTENDED_REG_EXP**

An extended regular expression as defined in the grammar in [*9.5 Regular Expression Grammar*](../basedefs/V1_chap09.html#tag_09_05).

**EOL**

The line termination character \<newline\>.

#### <span id="tag_07_04_02"></span>7.4.2 Locale Grammar

This section presents the grammar for the locale definition.


    %token              LOC_NAME
    %token              CHAR
    %token              NUMBER
    %token              COLLSYMBOL COLLELEMENT
    %token              CHARSYMBOL OCTAL_CHAR HEX_CHAR DECIMAL_CHAR
    %token              ELLIPSIS
    %token              EXTENDED_REG_EXP
    %token              EOL


    %start              locale_definition


    %%


    locale_definition   : global_statements locale_categories
                        |                   locale_categories
                        ;


    global_statements   : global_statements symbol_redefine
                        | symbol_redefine
                        ;


    symbol_redefine     : 'escape_char'  CHAR EOL
                        | 'comment_char' CHAR EOL
                        ;


    locale_categories   : locale_categories locale_category
                        | locale_category
                        ;


    locale_category     : lc_ctype | lc_collate | lc_messages
                        | lc_monetary | lc_numeric | lc_time
                        ;


    /* The following grammar rules are common to all categories */


    char_list           : char_list char_symbol
                        | char_symbol
                        ;


    char_symbol         : CHAR | CHARSYMBOL
                        | OCTAL_CHAR | HEX_CHAR | DECIMAL_CHAR
                        ;


    elem_list           : elem_list char_symbol
                        | elem_list COLLSYMBOL
                        | elem_list COLLELEMENT
                        | char_symbol
                        | COLLSYMBOL
                        | COLLELEMENT
                        ;


    symb_list           : symb_list COLLSYMBOL
                        | COLLSYMBOL
                        ;


    locale_name         : LOC_NAME
                        | '"' LOC_NAME '"'
                        ;


    /* The following is the LC_CTYPE category grammar */


    lc_ctype            : ctype_hdr ctype_keywords         ctype_tlr
                        | ctype_hdr 'copy' locale_name EOL ctype_tlr
                        ;


    ctype_hdr           : 'LC_CTYPE' EOL
                        ;


    ctype_keywords      : ctype_keywords ctype_keyword
                        | ctype_keyword
                        ;


    ctype_keyword       : charclass_keyword charclass_list EOL
                        | charconv_keyword charconv_list EOL
                        | 'charclass' charclass_namelist EOL
                        ;


    charclass_namelist  : charclass_namelist ';' CHARCLASS
                        | CHARCLASS
                        ;


    charclass_keyword   : 'upper' | 'lower' | 'alpha' | 'digit'
                        | 'punct' | 'xdigit' | 'space' | 'print'
                        | 'graph' | 'blank' | 'cntrl' | 'alnum'
                        | CHARCLASS
                        ;


    charclass_list      : charclass_list ';' char_symbol
                        | charclass_list ';' ELLIPSIS ';' char_symbol
                        | char_symbol
                        ;


    charconv_keyword    : 'toupper'
                        | 'tolower'
                        ;


    charconv_list       : charconv_list ';' charconv_entry
                        | charconv_entry
                        ;


    charconv_entry      : '(' char_symbol ',' char_symbol ')'
                        ;


    ctype_tlr           : 'END' 'LC_CTYPE' EOL
                        ;


    /* The following is the LC_COLLATE category grammar */


    lc_collate          : collate_hdr collate_keywords       collate_tlr
                        | collate_hdr 'copy' locale_name EOL collate_tlr
                        ;


    collate_hdr         : 'LC_COLLATE' EOL
                        ;


    collate_keywords    :                order_statements
                        | opt_statements order_statements
                        ;


    opt_statements      : opt_statements collating_symbols
                        | opt_statements collating_elements
                        | collating_symbols
                        | collating_elements
                        ;


    collating_symbols   : 'collating-symbol' COLLSYMBOL EOL
                        ;


    collating_elements  : 'collating-element' COLLELEMENT
                        | 'from' '"' elem_list '"' EOL
                        ;


    order_statements    : order_start collation_order order_end
                        ;


    order_start         : 'order_start' EOL
                        | 'order_start' order_opts EOL
                        ;


    order_opts          : order_opts ';' order_opt
                        | order_opt
                        ;


    order_opt           : order_opt ',' opt_word
                        | opt_word
                        ;


    opt_word            : 'forward' | 'backward' | 'position'
                        ;


    collation_order     : collation_order collation_entry
                        | collation_entry
                        ;


    collation_entry     : COLLSYMBOL EOL
                        | collation_element weight_list EOL
                        | collation_element             EOL
                        ;


    collation_element   : char_symbol
                        | COLLELEMENT
                        | ELLIPSIS
                        | 'UNDEFINED'
                        ;


    weight_list         : weight_list ';' weight_symbol
                        | weight_list ';'
                        | weight_symbol
                        ;


    weight_symbol       : /* empty */
                        | char_symbol
                        | COLLSYMBOL
                        | '"' elem_list '"'
                        | '"' symb_list '"'
                        | ELLIPSIS
                        | 'IGNORE'
                        ;


    order_end           : 'order_end' EOL
                        ;


    collate_tlr         : 'END' 'LC_COLLATE' EOL
                        ;


    /* The following is the LC_MESSAGES category grammar */


    lc_messages         : messages_hdr messages_keywords      messages_tlr
                        | messages_hdr 'copy' locale_name EOL messages_tlr
                        ;


    messages_hdr        : 'LC_MESSAGES' EOL
                        ;


    messages_keywords   : messages_keywords messages_keyword
                        | messages_keyword
                        ;


    messages_keyword    : 'yesexpr' '"' EXTENDED_REG_EXP '"' EOL
                        | 'noexpr'  '"' EXTENDED_REG_EXP '"' EOL
                        ;


    messages_tlr        : 'END' 'LC_MESSAGES' EOL
                        ;


    /* The following is the LC_MONETARY category grammar */


    lc_monetary         : monetary_hdr monetary_keywords       monetary_tlr
                        | monetary_hdr 'copy' locale_name EOL  monetary_tlr
                        ;


    monetary_hdr        : 'LC_MONETARY' EOL
                        ;


    monetary_keywords   : monetary_keywords monetary_keyword
                        | monetary_keyword
                        ;


    monetary_keyword    : mon_keyword_string mon_string EOL
                        | mon_keyword_char NUMBER EOL
                        | mon_keyword_char '-1'   EOL
                        | mon_keyword_grouping mon_group_list EOL
                        ;


    mon_keyword_string  : 'int_curr_symbol' | 'currency_symbol'
                        | 'mon_decimal_point' | 'mon_thousands_sep'
                        | 'positive_sign' | 'negative_sign'
                        ;


    mon_string          : '"' char_list '"'
                        | '""'
                        ;


    mon_keyword_char    : 'int_frac_digits' | 'frac_digits'
                        | 'p_cs_precedes' | 'p_sep_by_space'
                        | 'n_cs_precedes' | 'n_sep_by_space'
                        | 'p_sign_posn' | 'n_sign_posn'
                        | 'int_p_cs_precedes' | 'int_p_sep_by_space'
                        | 'int_n_cs_precedes' | 'int_n_sep_by_space'
                        | 'int_p_sign_posn' | 'int_n_sign_posn'
                        ;


    mon_keyword_grouping : 'mon_grouping'
                        ;


    mon_group_list      : NUMBER
                        | mon_group_list ';' NUMBER
                        ;


    monetary_tlr        : 'END' 'LC_MONETARY' EOL
                        ;


    /* The following is the LC_NUMERIC category grammar */


    lc_numeric          : numeric_hdr numeric_keywords       numeric_tlr
                        | numeric_hdr 'copy' locale_name EOL numeric_tlr
                        ;


    numeric_hdr         : 'LC_NUMERIC' EOL
                        ;


    numeric_keywords    : numeric_keywords numeric_keyword
                        | numeric_keyword
                        ;


    numeric_keyword     : num_keyword_string num_string EOL
                        | num_keyword_grouping num_group_list EOL
                        ;


    num_keyword_string  : 'decimal_point'
                        | 'thousands_sep'
                        ;


    num_string          : '"' char_list '"'
                        | '""'
                        ;


    num_keyword_grouping: 'grouping'
                        ;


    num_group_list      : NUMBER
                        | num_group_list ';' NUMBER
                        ;


    numeric_tlr         : 'END' 'LC_NUMERIC' EOL
                        ;


    /* The following is the LC_TIME category grammar */


    lc_time             : time_hdr time_keywords          time_tlr
                        | time_hdr 'copy' locale_name EOL time_tlr
                        ;


    time_hdr            : 'LC_TIME' EOL
                        ;


    time_keywords       : time_keywords time_keyword
                        | time_keyword
                        ;


    time_keyword        : time_keyword_name time_list EOL
                        | time_keyword_fmt time_string EOL
                        | time_keyword_opt time_list EOL
                        ;


    time_keyword_name   : 'abday' | 'day' | 'abmon' | 'mon'
                        ;


    time_keyword_fmt    : 'd_t_fmt' | 'd_fmt' | 't_fmt'
                        | 'am_pm' | 't_fmt_ampm'
                        ;


    time_keyword_opt    : 'era' | 'era_d_fmt' | 'era_t_fmt'
                        | 'era_d_t_fmt' | 'alt_digits'
                        | 'ab_alt_mon' | 'alt_mon'
                        ;


    time_list           : time_list ';' time_string
                        | time_string
                        ;


    time_string         : '"' char_list '"'
                        ;


    time_tlr            : 'END' 'LC_TIME' EOL
                        ;

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
