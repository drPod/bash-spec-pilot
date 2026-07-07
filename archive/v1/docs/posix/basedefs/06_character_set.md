The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_06"></span>6. Character Set

### <span id="tag_06_01"></span>6.1 Portable Character Set

Conforming implementations shall support one or more coded character sets. Each supported locale shall include the *portable character set*, which is the set of symbolic names for characters in [Portable Character Set](#tagtcjh_3). This is used to describe characters within the text of POSIX.1-2024. The first eight entries in [Portable Character Set](#tagtcjh_3) and all characters in [Non-Portable Control Characters](#tagtcjh_4) are defined in the ISO/IEC 6429:1992 standard. The rest of the characters in [Portable Character Set](#tagtcjh_3) are defined in the ISO/IEC 10646-1:2020 standard.

<span id="tagtcjh_3"></span> Table: Portable Character Set

| **Symbolic Name(s)** | **Glyph** | **UCS** | **Description** |
|:---|:--:|:---|:---|
| \<NUL\> |   | \<U0000\> | NULL (NUL) |
| \<alert\>, \<BEL\> |   | \<U0007\> | BELL |
| \<backspace\>, \<BS\> |   | \<U0008\> | BACKSPACE |
| \<tab\>, \<HT\> |   | \<U0009\> | CHARACTER TABULATION |
| \<newline\>, \<LF\> |   | \<U000A\> | LINE FEED (LF) |
| \<vertical-tab\>, \<VT\> |   | \<U000B\> | LINE TABULATION |
| \<form-feed\>, \<FF\> |   | \<U000C\> | FORM FEED (FF) |
| \<carriage-return\>, \<CR\> |   | \<U000D\> | CARRIAGE RETURN (CR) |
| \<space\> |   | \<U0020\> | SPACE |
| \<exclamation-mark\> | ! | \<U0021\> | EXCLAMATION MARK |
| \<quotation-mark\> | " | \<U0022\> | QUOTATION MARK |
| \<number-sign\> | \# | \<U0023\> | NUMBER SIGN |
| \<dollar-sign\> | \$ | \<U0024\> | DOLLAR SIGN |
| \<percent-sign\> | % | \<U0025\> | PERCENT SIGN |
| \<ampersand\> | & | \<U0026\> | AMPERSAND |
| \<apostrophe\> | ' | \<U0027\> | APOSTROPHE |
| \<left-parenthesis\> | ( | \<U0028\> | LEFT PARENTHESIS |
| \<right-parenthesis\> | ) | \<U0029\> | RIGHT PARENTHESIS |
| \<asterisk\> | \* | \<U002A\> | ASTERISK |
| \<plus-sign\> | \+ | \<U002B\> | PLUS SIGN |
| \<comma\> | , | \<U002C\> | COMMA |
| \<hyphen-minus\>, \<hyphen\> | \- | \<U002D\> | HYPHEN-MINUS |
| \<full-stop\>, \<period\> | . | \<U002E\> | FULL STOP |
| \<slash\>, \<solidus\> | / | \<U002F\> | SOLIDUS |
| \<zero\> | 0 | \<U0030\> | DIGIT ZERO |
| \<one\> | 1 | \<U0031\> | DIGIT ONE |
| \<two\> | 2 | \<U0032\> | DIGIT TWO |
| \<three\> | 3 | \<U0033\> | DIGIT THREE |
| \<four\> | 4 | \<U0034\> | DIGIT FOUR |
| \<five\> | 5 | \<U0035\> | DIGIT FIVE |
| \<six\> | 6 | \<U0036\> | DIGIT SIX |
| \<seven\> | 7 | \<U0037\> | DIGIT SEVEN |
| \<eight\> | 8 | \<U0038\> | DIGIT EIGHT |
| \<nine\> | 9 | \<U0039\> | DIGIT NINE |
| \<colon\> | : | \<U003A\> | COLON |
| \<semicolon\> | ; | \<U003B\> | SEMICOLON |
| \<less-than-sign\> | \< | \<U003C\> | LESS-THAN SIGN |
| \<equals-sign\> | = | \<U003D\> | EQUALS SIGN |
| \<greater-than-sign\> | \> | \<U003E\> | GREATER-THAN SIGN |
| \<question-mark\> | ? | \<U003F\> | QUESTION MARK |
| \<commercial-at\> | @ | \<U0040\> | COMMERCIAL AT |
| \<A\> | A | \<U0041\> | LATIN CAPITAL LETTER A |
| \<B\> | B | \<U0042\> | LATIN CAPITAL LETTER B |
| \<C\> | C | \<U0043\> | LATIN CAPITAL LETTER C |
| \<D\> | D | \<U0044\> | LATIN CAPITAL LETTER D |
| \<E\> | E | \<U0045\> | LATIN CAPITAL LETTER E |
| \<F\> | F | \<U0046\> | LATIN CAPITAL LETTER F |
| \<G\> | G | \<U0047\> | LATIN CAPITAL LETTER G |
| \<H\> | H | \<U0048\> | LATIN CAPITAL LETTER H |
| \<I\> | I | \<U0049\> | LATIN CAPITAL LETTER I |
| \<J\> | J | \<U004A\> | LATIN CAPITAL LETTER J |
| \<K\> | K | \<U004B\> | LATIN CAPITAL LETTER K |
| \<L\> | L | \<U004C\> | LATIN CAPITAL LETTER L |
| \<M\> | M | \<U004D\> | LATIN CAPITAL LETTER M |
| \<N\> | N | \<U004E\> | LATIN CAPITAL LETTER N |
| \<O\> | O | \<U004F\> | LATIN CAPITAL LETTER O |
| \<P\> | P | \<U0050\> | LATIN CAPITAL LETTER P |
| \<Q\> | Q | \<U0051\> | LATIN CAPITAL LETTER Q |
| \<R\> | R | \<U0052\> | LATIN CAPITAL LETTER R |
| \<S\> | S | \<U0053\> | LATIN CAPITAL LETTER S |
| \<T\> | T | \<U0054\> | LATIN CAPITAL LETTER T |
| \<U\> | U | \<U0055\> | LATIN CAPITAL LETTER U |
| \<V\> | V | \<U0056\> | LATIN CAPITAL LETTER V |
| \<W\> | W | \<U0057\> | LATIN CAPITAL LETTER W |
| \<X\> | X | \<U0058\> | LATIN CAPITAL LETTER X |
| \<Y\> | Y | \<U0059\> | LATIN CAPITAL LETTER Y |
| \<Z\> | Z | \<U005A\> | LATIN CAPITAL LETTER Z |
| \<left-square-bracket\> | \[ | \<U005B\> | LEFT SQUARE BRACKET |
| \<backslash\>, \<reverse-solidus\> | \\ | \<U005C\> | REVERSE SOLIDUS |
| \<right-square-bracket\> | \] | \<U005D\> | RIGHT SQUARE BRACKET |
| \<circumflex-accent\>, \<circumflex\> | ^ | \<U005E\> | CIRCUMFLEX ACCENT |
| \<low-line\>, \<underscore\> | \_ | \<U005F\> | LOW LINE |
| \<grave-accent\> | \` | \<U0060\> | GRAVE ACCENT |
| \<a\> | a | \<U0061\> | LATIN SMALL LETTER A |
| \<b\> | b | \<U0062\> | LATIN SMALL LETTER B |
| \<c\> | c | \<U0063\> | LATIN SMALL LETTER C |
| \<d\> | d | \<U0064\> | LATIN SMALL LETTER D |
| \<e\> | e | \<U0065\> | LATIN SMALL LETTER E |
| \<f\> | f | \<U0066\> | LATIN SMALL LETTER F |
| \<g\> | g | \<U0067\> | LATIN SMALL LETTER G |
| \<h\> | h | \<U0068\> | LATIN SMALL LETTER H |
| \<i\> | i | \<U0069\> | LATIN SMALL LETTER I |
| \<j\> | j | \<U006A\> | LATIN SMALL LETTER J |
| \<k\> | k | \<U006B\> | LATIN SMALL LETTER K |
| \<l\> | l | \<U006C\> | LATIN SMALL LETTER L |
| \<m\> | m | \<U006D\> | LATIN SMALL LETTER M |
| \<n\> | n | \<U006E\> | LATIN SMALL LETTER N |
| \<o\> | o | \<U006F\> | LATIN SMALL LETTER O |
| \<p\> | p | \<U0070\> | LATIN SMALL LETTER P |
| \<q\> | q | \<U0071\> | LATIN SMALL LETTER Q |
| \<r\> | r | \<U0072\> | LATIN SMALL LETTER R |
| \<s\> | s | \<U0073\> | LATIN SMALL LETTER S |
| \<t\> | t | \<U0074\> | LATIN SMALL LETTER T |
| \<u\> | u | \<U0075\> | LATIN SMALL LETTER U |
| \<v\> | v | \<U0076\> | LATIN SMALL LETTER V |
| \<w\> | w | \<U0077\> | LATIN SMALL LETTER W |
| \<x\> | x | \<U0078\> | LATIN SMALL LETTER X |
| \<y\> | y | \<U0079\> | LATIN SMALL LETTER Y |
| \<z\> | z | \<U007A\> | LATIN SMALL LETTER Z |
| \<left-brace\>, \<left-curly-bracket\> | { | \<U007B\> | LEFT CURLY BRACKET |
| \<vertical-line\> | \| | \<U007C\> | VERTICAL LINE |
| \<right-brace\>, \<right-curly-bracket\> | } | \<U007D\> | RIGHT CURLY BRACKET |
| \<tilde\> | ~ | \<U007E\> | TILDE |

POSIX.1-2024 uses character names other than the above, but only in an informative way; for example, in examples to illustrate the use of characters beyond the portable character set with the facilities of POSIX.1-2024.

[Portable Character Set](#tagtcjh_3) defines the characters in the portable character set and the corresponding symbolic character names used to identify each character in a character set description file. Characters defined in [Non-Portable Control Characters](#tagtcjh_4) may also be used in character set description files.

POSIX.1-2024 places only the following requirements on the encoded values of the characters in the portable character set:

- If the encoded values associated with each member of the portable character set are not invariant across all locales supported by the implementation, if an application uses any pair of locales where the character encodings differ, or accesses data from an application using a locale which has different encodings from the locales used by the application, the results are unspecified.
- The encoded values associated with the digits 0 to 9 shall be such that the value of each character after 0 shall be one greater than the value of the previous character.
- A null character, NUL, which has all bits set to zero, shall be in the set of characters.
- The encoded values associated with \<period\>, \<slash\>, \<newline\>, and \<carriage-return\> shall be invariant across all locales supported by the implementation.
- The encoded values associated with the members of the portable character set are each represented in a single byte. Moreover, if the value is stored in an object of C-language type **char**, it is guaranteed to be positive (except the NUL, which is always zero).

Conforming implementations shall support certain character and character set attributes, as defined in [*7.2 POSIX Locale*](../basedefs/V1_chap07.html#tag_07_02).

### <span id="tag_06_02"></span>6.2 Character Encoding

The POSIX locale shall contain 256 single-byte characters including the characters in [Portable Character Set](#tagtcjh_3) and [Non-Portable Control Characters](#tagtcjh_4), which have the properties listed in [*7.3.1 LC_CTYPE*](../basedefs/V1_chap07.html#tag_07_03_01). It is unspecified whether characters not listed in those two tables are classified as **punct** or **cntrl**, or neither. Other locales shall contain the characters in [Portable Character Set](#tagtcjh_3) and may contain any or all of the control characters identified in [Non-Portable Control Characters](#tagtcjh_4); the presence, meaning, and representation of any additional characters are locale-specific.

In locales other than the POSIX locale, a character may have a state-dependent encoding. There are two types of these encodings:

- A single-shift encoding (where each character not in the initial shift state is preceded by a shift code) can be defined if each shift-code and character sequence is considered a multi-byte character. This is done using the concatenated-constant format in a character set description file, as described in [6.4 Character Set Description File](#tag_06_04). If the implementation supports a character encoding of this type, all of the standard utilities in the Shell and Utilities volume of POSIX.1-2024 shall support it. Use of a single-shift encoding with any of the functions in the System Interfaces volume of POSIX.1-2024 that do not specifically mention the effects of state-dependent encoding is implementation-defined.
- A locking-shift encoding (where the state of the character is determined by a shift code that may affect more than the single character following it) cannot be defined with the current character set description file format. Use of a locking-shift encoding with any of the standard utilities in the Shell and Utilities volume of POSIX.1-2024 or with any of the functions in the System Interfaces volume of POSIX.1-2024 that do not specifically mention the effects of state-dependent encoding is implementation-defined.

While in the initial shift state, all characters in the portable character set shall retain their usual interpretation and shall not alter the shift state. The interpretation for subsequent bytes in the sequence shall be a function of the current shift state. A byte with all bits zero shall be interpreted as the null character independent of shift state. Such a byte shall not occur as part of any other character. Likewise, the byte values used to encode \<period\>, \<slash\>, \<newline\>, and \<carriage-return\> shall not occur as part of any other character in any locale.

The maximum allowable number of bytes in a character in the current locale shall be indicated by {MB_CUR_MAX}, defined in the [*\<stdlib.h\>*](../basedefs/stdlib.h.html) header and by the **\<mb_cur_max\>** value in a character set description file; see [6.4 Character Set Description File](#tag_06_04). The implementation's maximum number of bytes in a character shall be defined by the C-language macro {MB_LEN_MAX}.

### <span id="tag_06_03"></span>6.3 C Language Wide-Character Codes

In the shell, the standard utilities are written so that the encodings of characters are described by the locale's *LC_CTYPE* definition (see [*7.3.1 LC_CTYPE*](../basedefs/V1_chap07.html#tag_07_03_01)) and there is no differentiation between characters consisting of single octets (8-bit bytes) or multiple bytes. However, in the C language, a differentiation is made. To ease the handling of variable length characters, the C language has introduced the concept of wide-character codes.

All wide-character codes in a given process consist of an equal number of bits. This is in contrast to characters, which can consist of a variable number of bytes. The byte or byte sequence that represents a character can also be represented as a wide-character code. Wide-character codes thus provide a uniform size for manipulating text data. A wide-character code having all bits zero is the null wide-character code (see [*3.233 Null Wide-Character Code*](../basedefs/V1_chap03.html#tag_03_233)), and terminates wide-character strings (see [*3.417 Wide-Character Code (C Language)*](../basedefs/V1_chap03.html#tag_03_417)). The wide-character value for each member of the portable character set shall equal its value when used as the lone character in an integer character constant. Wide-character codes for other characters are locale and implementation-defined. State shift bytes shall not have a wide-character code representation. POSIX.1-2024 provides no means of defining a wide-character codeset.

Arguments to the functions declared in the [*\<wchar.h\>*](../basedefs/wchar.h.html) header can point to arrays containing **wchar_t** values that do not correspond to valid wide character codes according to the *LC_CTYPE* category of the locale being used. Such values shall be processed according to the specified semantics for the function in the System Interfaces volume of POSIX.1-2024, except that it is unspecified whether an encoding error occurs if such a value appears in the format string of a function that has a format string as a parameter and the specified semantics do not require that value to be processed as if by [*wcrtomb*()](../functions/wcrtomb.html).

### <span id="tag_06_04"></span>6.4 Character Set Description File

Implementations shall provide a character set description file for at least one coded character set supported by the implementation. These files are referred to elsewhere in POSIX.1-2024 as *charmap* files. It is implementation-defined whether or not users or applications can provide additional character set description files.

POSIX.1-2024 does not require that multiple character sets or codesets be supported. Although multiple charmap files are supported, it is the responsibility of the implementation to provide the file or files; if only one is provided, only that one is accessible using the [*localedef*](../utilities/localedef.html) utility's **-f** option.

Each character set description file, except those that use the ISO/IEC 10646-1:2020 standard position values as the encoding values, shall define characteristics for the coded character set and the encoding for the characters specified in [Portable Character Set](#tagtcjh_3), and may define encoding for additional characters supported by the implementation. Other information about the coded character set may also be in the file. Coded character set character values shall be defined using symbolic character names followed by character encoding values.

Each symbolic name specified in [Portable Character Set](#tagtcjh_3) shall be included in the file. Each character in [Portable Character Set](#tagtcjh_3) (each row in the table) shall be mapped to a unique coding value. For each character in [Non-Portable Control Characters](#tagtcjh_4) that exists in the character set described by the file, the character's symbolic name(s) from [Non-Portable Control Characters](#tagtcjh_4) and the character's single-byte encoding value shall be included in the file.\

<span id="tagtcjh_4"></span> Table: Non-Portable Control Characters

| **Symbolic Name(s)** | **UCS**   | **Description**             |
|:---------------------|:----------|:----------------------------|
| \<SOH\>              | \<U0001\> | START OF HEADING            |
| \<STX\>              | \<U0002\> | START OF TEXT               |
| \<ETX\>              | \<U0003\> | END OF TEXT                 |
| \<EOT\>              | \<U0004\> | END OF TRANSMISSION         |
| \<ENQ\>              | \<U0005\> | ENQUIRY                     |
| \<ACK\>              | \<U0006\> | ACKNOWLEDGE                 |
| \<SO\>               | \<U000E\> | SHIFT OUT                   |
| \<SI\>               | \<U000F\> | SHIFT IN                    |
| \<DLE\>              | \<U0010\> | DATA LINK ESCAPE            |
| \<DC1\>              | \<U0011\> | DEVICE CONTROL ONE          |
| \<DC2\>              | \<U0012\> | DEVICE CONTROL TWO          |
| \<DC3\>              | \<U0013\> | DEVICE CONTROL THREE        |
| \<DC4\>              | \<U0014\> | DEVICE CONTROL FOUR         |
| \<NAK\>              | \<U0015\> | NEGATIVE ACKNOWLEDGE        |
| \<SYN\>              | \<U0016\> | SYNCHRONOUS IDLE            |
| \<ETB\>              | \<U0017\> | END OF TRANSMISSION BLOCK   |
| \<CAN\>              | \<U0018\> | CANCEL                      |
| \<EM\>               | \<U0019\> | END OF MEDIUM               |
| \<SUB\>              | \<U001A\> | SUBSTITUTE                  |
| \<ESC\>              | \<U001B\> | ESCAPE                      |
| \<IS4\>, \<FS\>      | \<U001C\> | INFORMATION SEPARATOR FOUR  |
| \<IS3\>, \<GS\>      | \<U001D\> | INFORMATION SEPARATOR THREE |
| \<IS2\>, \<RS\>      | \<U001E\> | INFORMATION SEPARATOR TWO   |
| \<IS1\>, \<US\>      | \<U001F\> | INFORMATION SEPARATOR ONE   |
| \<DEL\>              | \<U007F\> | DELETE                      |

The following declarations can precede the character definitions. Each shall consist of the symbol shown in the following list, starting in column 1, including the surrounding brackets, followed by one or more \<blank\> characters, followed by the value to be assigned to the symbol.

**\<code_set_name\>**

The name of the coded character set for which the character set description file is defined. The characters of the name shall be taken from the set of characters with visible glyphs defined in [Portable Character Set](#tagtcjh_3).

**\<mb_cur_max\>**

The maximum number of bytes in a multi-byte character. This shall default to 1.

**\<mb_cur_min\>**

An unsigned positive integer value that defines the minimum number of bytes in a character for the encoded character set. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  On XSI-conformant systems, **\<mb_cur_min\>** shall always be 1. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

**\<escape_char\>**

The character used to indicate that the characters following shall be interpreted in a special way, as defined later in this section. This shall default to \<backslash\> (`'\\'`), which is the character used in all the following text and examples, unless otherwise noted.

**\<comment_char\>**

The character that, when placed in column 1 of a charmap line, is used to indicate that the line shall be ignored. The default character shall be the \<number-sign\> (`'#'`).

The character set mapping definitions shall be all the lines immediately following an identifier line containing the string `"CHARMAP"` starting in column 1, and preceding a trailer line containing the string `"END CHARMAP"` starting in column 1. Empty lines and lines containing a **\<comment_char\>** in the first column shall be ignored. Each non-comment line of the character set mapping definition (that is, between the `"CHARMAP"` and `"END CHARMAP"` lines of the file) shall be in either of two forms:


    "%s %s %s\n", <symbolic-name>, <encoding>, <comments>

or:


    "%s...%s %s %s\n", <symbolic-name>, <symbolic-name>,
        <encoding>, <comments>

In the first format, the line in the character set mapping definition shall define a single symbolic name and a corresponding encoding. A symbolic name is one or more characters from the set shown with visible glyphs in [Portable Character Set](#tagtcjh_3), enclosed between angle brackets. A character following an escape character is interpreted as itself; for example, the sequence `"<\\\>>"` represents the symbolic name `"\>"` enclosed between angle brackets.

In the second format, the line in the character set mapping definition shall define a range of one or more symbolic names. In this form, the symbolic names shall consist of zero or more non-numeric characters from the set shown with visible glyphs in [Portable Character Set](#tagtcjh_3), followed by an integer formed by one or more decimal digits. Both integers shall contain the same number of digits. The characters preceding the integer shall be identical in the two symbolic names, and the integer formed by the digits in the second symbolic name shall be equal to or greater than the integer formed by the digits in the first name. This shall be interpreted as a series of symbolic names formed from the common part and each of the integers between the first and the second integer, inclusive. As an example, \<j0101\>...\<j0104\> is interpreted as the symbolic names \<j0101\>, \<j0102\>, \<j0103\>, and \<j0104\>, in that order.

A character set mapping definition line shall exist for all symbolic names specified in [Portable Character Set](#tagtcjh_3), and shall define the coded character value that corresponds to the character indicated in the table, or the coded character value that corresponds to the control character symbolic name. If the control characters commonly associated with the symbolic names in [Non-Portable Control Characters](#tagtcjh_4) are supported by the implementation, the symbolic name and the corresponding encoding value shall be included in the file. Additional unique symbolic names may be included. A coded character value can be represented by more than one symbolic name.

The encoding part is expressed as one (for single-byte character values) or more concatenated decimal, octal, or hexadecimal constants in the following formats:


    "%cd%u", <escape_char>, <decimal byte value>
    "%cx%x", <escape_char>, <hexadecimal byte value>
    "%c%o", <escape_char>, <octal byte value>

Decimal constants shall be represented by two or three decimal digits, preceded by the escape character and the lowercase letter `'d'`; for example, `"\d05"`, `"\d97"`, or `"\d143"`. Hexadecimal constants shall be represented by two hexadecimal digits, preceded by the escape character and the lowercase letter `'x'`; for example, `"\x05"`, `"\x61"`, or `"\x8f"`. Octal constants shall be represented by two or three octal digits, preceded by the escape character; for example, `"\05"`, `"\141"`, or `"\217"`. In a portable charmap file, each constant represents an 8-bit byte. When constants are concatenated for multi-byte character values, they shall be of the same type, and interpreted in sequence from from first to last with the first byte of the multi-byte character specified by the first byte in the sequence. The manner in which these constants are represented in the character stored in the system is implementation-defined. (This notation was chosen for reasons of portability. There is no requirement that the internal representation in the computer memory be in this same order.) Omitting bytes from a multi-byte character definition produces undefined results.

In lines defining ranges of symbolic names, the encoded value shall be the value for the first symbolic name in the range (the symbolic name preceding the ellipsis). Subsequent symbolic names defined by the range shall have encoding values in increasing order. Bytes shall be treated as unsigned octets, and carry shall be propagated between the bytes as necessary to represent the range. However, because this causes a null byte in the second or subsequent bytes of a character, such a declaration should not be specified. For example, the line:


    <j0101>...<j0104>  \d129\d254

is interpreted as:


    <j0101>            \d129\d254
    <j0102>            \d129\d255
    <j0103>            \d130\d00
    <j0104>            \d130\d01

The expanded declaration of the symbol \<j0103\> in the above example is an invalid specification, because it contains a null byte in the second byte of a character.

The comment is optional.

POSIX.1-2024 provides no means of defining a wide-character codeset.

The following declarations can follow the character set mapping definitions (after the `"END CHARMAP"` statement). Each shall consist of the keyword shown in the following list, starting in column 1, followed by the value(s) to be associated to the keyword, as defined below.

**WIDTH**

A non-negative integer value defining the column width (see [*3.75 Column Position*](../basedefs/V1_chap03.html#tag_03_75)) for the printable characters in the coded character set specified in [Portable Character Set](#tagtcjh_3) and [Non-Portable Control Characters](#tagtcjh_4). Coded character set character values shall be defined using symbolic character names followed by column width values. Defining a character with more than one **WIDTH** produces undefined results. The **END WIDTH** keyword shall be used to terminate the **WIDTH** definitions. Specifying the width of a non-printable character in a **WIDTH** declaration produces undefined results.

**WIDTH_DEFAULT**

\
A non-negative integer value defining the default column width for any printable character not listed by one of the **WIDTH** keywords. If no **WIDTH_DEFAULT** keyword is included in the charmap, the default character width shall be 1.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

##### <span id="tag_06_04_00_01"></span>Example

After the `"END CHARMAP"` statement, a syntax for a width definition would be:


    WIDTH
    <A> 1
    <B> 1
    <C>...<Z> 1
    ...
    <foo1>...<foon> 2
    ...
    END WIDTH

In this example, the numerical code point values represented by the symbols **\<A\>** and **\<B\>** are assigned a width of 1. The code point values **\<C\>** to **\<Z\>** inclusive (**\<C\>**, **\<D\>**, **\<E\>**, and so on) are also assigned a width of 1. Using **\<A\>**...**\<Z\>** would have required fewer lines, but the alternative was shown to demonstrate flexibility. The keyword **WIDTH_DEFAULT** could have been added as appropriate.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

#### <span id="tag_06_04_01"></span>6.4.1 State-Dependent Character Encodings

This section addresses the use of state-dependent character encodings (that is, those in which the encoding of a character is dependent on one or more shift codes that may precede it).

A single-shift encoding (where each character not in the initial shift state is preceded by a shift code) can be defined in the charmap format if each shift-code/character sequence is considered a multi-byte character, defined using the concatenated-constant format described in [6.4 Character Set Description File](#tag_06_04). If the implementation supports a character encoding of this type, all of the standard utilities shall support it. A locking-shift encoding (where the state of the character is determined by a shift code that may affect more than the single character following it) could be defined with an extension to the charmap format described in [6.4 Character Set Description File](#tag_06_04).\

If the implementation supports a character encoding of this type, any of the standard utilities that describe character (*versus* byte) or text-file manipulation shall have the following characteristics:

1.  The utility shall process the statefully encoded data as a concatenation of state-independent characters. The presence of redundant locking shifts shall not affect the comparison of two statefully encoded strings.
2.  A utility that divides, truncates, or extracts substrings from statefully encoded data shall produce output that contains locking shifts at the beginning or end of the resulting data, if appropriate, to retain correct state information.

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
