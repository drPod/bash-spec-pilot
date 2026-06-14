The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="printf"></span> <span id="tag_20_96"></span>

#### <span id="tag_20_96_01"></span>NAME

> printf — write formatted output

#### <span id="tag_20_96_02"></span>SYNOPSIS

> `printf`` `*`format`*` `**`[`***`argument`*`...`**`]`**

#### <span id="tag_20_96_03"></span>DESCRIPTION

> The *printf* utility shall write formatted operands to the standard output. The *argument* operands shall be formatted under control of the *format* operand.

#### <span id="tag_20_96_04"></span>OPTIONS

> None.

#### <span id="tag_20_96_05"></span>OPERANDS

> The following operands shall be supported:
>
> *format*
>
> A character string describing the format to use to write the remaining operands. See the EXTENDED DESCRIPTION section.
>
> *argument*
>
> The values to be written to standard output, under the control of *format*. See the EXTENDED DESCRIPTION section.

#### <span id="tag_20_96_06"></span>STDIN

> Not used.

#### <span id="tag_20_96_07"></span>INPUT FILES

> None.

#### <span id="tag_20_96_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *printf*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
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
> *LC_NUMERIC*
>
> \
> Determine the locale for numeric formatting. It shall affect the format of numbers written using the `e`, `E`, `f`, `g`, and `G` conversion specifier characters (if supported).
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_96_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_96_10"></span>STDOUT

> See the EXTENDED DESCRIPTION section.

#### <span id="tag_20_96_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_96_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_96_13"></span>EXTENDED DESCRIPTION

> The application shall ensure that the *format* operand is a character string, beginning and ending in its initial shift state, if any. The *format* operand shall be used as the format string described in XBD [*5. File Format Notation*](../basedefs/V1_chap05.html#tag_05) with the following exceptions:
>
> 1.  A \<space\> in the format string, in any context other than a flag of a conversion specification, shall be treated as an ordinary character that is copied to the output.
>
> 2.  A `'Δ'` character in the format string shall be treated as a `'Δ'` character, not as a \<space\>.
>
> 3.  In addition to the escape sequences shown in XBD [*5. File Format Notation*](../basedefs/V1_chap05.html#tag_05) (`'\\'`, `'\a'`, `'\b'`, `'\f'`, `'\n'`, `'\r'`, `'\t'`, `'\v'`), `"\ddd"`, where *ddd* is a one, two, or three-digit octal number, shall be written as a byte with the numeric value specified by the octal number.
>
> 4.  The implementation shall not precede or follow output from the `d` or `u` conversion specifiers with \<blank\> characters not specified by the *format* operand.
>
> 5.  The implementation shall not precede output from the `o` conversion specifier with zeros not specified by the *format* operand.
>
> 6.  The `a`, `A`, `e`, `E`, `f`, `F`, `g`, and `G` conversion specifiers need not be supported.
>
> 7.  An additional conversion specifier character, `b`, shall be supported as follows. The argument shall be taken to be a string that can contain \<backslash\>-escape sequences. The following \<backslash\>-escape sequences shall be supported:
>
>     - The escape sequences listed in XBD [*5. File Format Notation*](../basedefs/V1_chap05.html#tag_05) (`'\\'`, `'\a'`, `'\b'`, `'\f'`, `'\n'`, `'\r'`, `'\t'`, `'\v'`), which shall be converted to the characters they represent.
>
>     - `"\0ddd"`, where *ddd* is a zero, one, two, or three-digit octal number that shall be converted to a byte with the numeric value specified by the octal number.
>
>     - `'\c'`, which shall not be written and shall cause *printf* to ignore any remaining characters in the string operand containing it, any remaining string operands, and any additional characters in the *format* operand. If a precision is specified and the argument contains a `'\c'` after the point at which the number of bytes indicated by the precision specification have been written, it is unspecified whether the `'\c'` takes effect.
>
>     The interpretation of a \<backslash\> followed by any other sequence of characters is unspecified.
>
>     Bytes from the converted string shall be written until the end of the string or the number of bytes indicated by the precision specification is reached. If the precision is omitted, it shall be taken to be infinite, so all bytes up to the end of the converted string shall be written.
>
> 8.  Conversions can be applied to the *n*th *argument* operand rather than to the next *argument* operand. In this case, the conversion specifier character `'%'` is replaced by the sequence `"%`*`n`*`$"`, where *n* is a decimal integer in the range \[1,{NL_ARGMAX}\], giving the *argument* operand number. This feature provides for the definition of format strings that select arguments in an order appropriate to specific languages.
>
>     The format can contain either numbered argument conversion specifications (that is, ones beginning with `"%`*`n`*`$"`), or unnumbered argument conversion specifications, but not both. The only exception to this is that `"%%"` can be mixed with the `"%`*`n`*`$"` form. The results of mixing numbered and unnumbered argument specifications that consume an argument are unspecified.
>
> 9.  For each conversion specification that consumes an argument, an *argument* operand shall be evaluated and converted to the appropriate type for the conversion as specified below. The operand to be evaluated shall be determined as follows:
>
>     - If the conversion specification begins with a `"%`*`n`*`$"` sequence, the *n*th *argument* operand shall be evaluated.
>
>     - Otherwise, the evaluated operand shall be the next *argument* operand after the one evaluated by the previous conversion specification that consumed an argument; if there is no such previous conversion specification the first *argument* operand shall be evaluated.
>
>     If the *format* operand contains no conversion specifications that consume an argument and there are *argument* operands present, the results are unspecified.
>
> 10. The *format* operand shall be reused as often as necessary to satisfy the *argument* operands. If conversion specifications beginning with a `"%`*`n`*`$"` sequence are used, on format reuse the value of *n* shall refer to the *n*th *argument* operand following the highest numbered *argument* operand consumed by the previous use of the *format* operand.
>
> 11. If an *argument* operand to be consumed by a conversion specification does not exist:
>
>     - If it is a numbered argument conversion specification, *printf* should write a diagnostic message to standard error and exit with non-zero status, but may behave as for an unnumbered argument conversion specification.
>
>     - If it is an unnumbered argument conversion specification, any extra `b`, `c`, or `s` conversion specifiers shall be evaluated as if a null string argument were supplied and any other extra conversion specifiers shall be evaluated as if a zero argument were supplied.
>
> 12. If a character sequence in the *format* operand begins with a `'%'` character, but does not form a valid conversion specification, the behavior is unspecified.
>
> 13. The argument to the `c` conversion specifier can be a string containing zero or more bytes. If it contains one or more bytes, the first byte shall be written and any additional bytes shall be ignored. If the argument is an empty string, it is unspecified whether nothing is written or a null byte is written.
>
> The *argument* operands shall be treated as strings if the corresponding conversion specifier is `b`, `c`, or `s`, and shall be evaluated as if by the [*strtod*()](../functions/strtod.html) function if the corresponding conversion specifier is `a`, `A`, `e`, `E`, `f`, `F`, `g`, or `G`. Otherwise, they shall be evaluated as unsuffixed C integer constants, as described by the ISO C standard, with the following extensions:
>
> - A leading \<plus-sign\> or \<hyphen-minus\> shall be allowed.
>
> - If the leading character is a single-quote or double-quote, the value shall be the numeric value in the underlying codeset of the character following the single-quote or double-quote.
>
> - Suffixed integer constants may be allowed.
>
> If an *argument* operand cannot be completely converted into an internal value appropriate to the corresponding conversion specification, a diagnostic message shall be written to standard error and the utility shall not exit with a zero exit status, but shall continue processing any remaining operands and shall write the value accumulated at the time the error was detected to standard output.
>
> It shall not be considered an error if an *argument* operand is not completely used for a `b`, `c`, or `s` conversion.

#### <span id="tag_20_96_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_96_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_96_16"></span>APPLICATION USAGE

> The floating-point formatting conversion specifications of [*printf*()](../functions/printf.html) are not required because all arithmetic in the shell is integer arithmetic. The [*awk*](../utilities/awk.html) utility performs floating-point calculations and provides its own **printf** function. The [*bc*](../utilities/bc.html) utility can perform arbitrary-precision floating-point arithmetic, but does not provide extensive formatting capabilities. (This *printf* utility cannot really be used to format [*bc*](../utilities/bc.html) output; it does not support arbitrary precision.) Implementations are encouraged to support the floating-point conversions as an extension.
>
> Note that this *printf* utility, like the [*printf*()](../functions/printf.html) function defined in the System Interfaces volume of POSIX.1-2024 on which it is based, makes no special provision for dealing with multi-byte characters when using the `%c` conversion specification or when a precision is specified in a `%b` or `%s` conversion specification. Applications should be extremely cautious using either of these features when there are multi-byte characters in the character set.
>
> No provision is made in this volume of POSIX.1-2024 which allows field widths and precisions to be specified as `'*'` since the `'*'` can be replaced directly in the *format* operand using shell variable substitution. Implementations can also provide this feature as an extension if they so choose.
>
> Hexadecimal character constants as defined in the ISO C standard are not recognized in the *format* operand because there is no consistent way to detect the end of the constant. Octal character constants are limited to, at most, three octal digits, but hexadecimal character constants are only terminated by a non-hex-digit character. In the ISO C standard, string literal concatenation can be used to terminate a constant and follow it with a hexadecimal character to be written. In the shell, similar concatenation can be done using `$'...'` so that the shell converts the hexadecimal sequence before it executes *printf*.
>
> The `%b` conversion specification is not part of the ISO C standard; it has been added here as a portable way to process \<backslash\>-escapes expanded in string operands as provided by the [*echo*](../utilities/echo.html) utility. See also the APPLICATION USAGE section of [*echo*](../utilities/echo.html#) for ways to use *printf* as a replacement for all of the traditional versions of the [*echo*](../utilities/echo.html) utility.
>
> If an argument cannot be parsed correctly for the corresponding conversion specification, the *printf* utility is required to report an error. Thus, overflow and extraneous characters at the end of an argument being used for a numeric conversion shall be reported as errors.
>
> Unlike the [*printf*()](../functions/printf.html) function, when numbered conversion specifications are used, specifying the *N*th argument does not require that all the leading arguments, from the first to the (*N-1*)th, are specified in the format string. For example, `"%3$s %1$d\n"` is an acceptable *format* operand which evaluates the first and third *argument* operands but not the second.

#### <span id="tag_20_96_17"></span>EXAMPLES

> To alert the user and then print and read a series of prompts:
>
>
>     printf "\aPlease fill in the following: \nName: "
>     read name
>     printf "Phone number: "
>     read phone
>
> To read out a list of right and wrong answers from a file, calculate the percentage correctly, and print them out. The numbers are right-justified and separated by a single \<tab\>. The percentage is written to one decimal place of accuracy:
>
>
>     while read right wrong ; do
>         percent=$(echo "scale=1;($right*100)/($right+$wrong)" | bc)
>         printf "%2d right\t%2d wrong\t(%s%%)\n" \
>             $right $wrong $percent
>     done < database_file
>
> The command:
>
>
>     printf "%5d%4d\n" 1 21 321 4321 54321
>
> produces:
>
>
>         1  21
>       3214321
>     54321   0
>
> Note that the *format* operand is used three times to print all of the given strings and that a `'0'` was supplied by *printf* to satisfy the last `%4d` conversion specification.
>
> The command:
>
>
>     printf '%d\n' 10 010 0x10
>
> produces:\
>
> | **Output Line** | **Explanation** |
> |:---|:---|
> | 10 | Decimal representation of the numeric value of decimal integer constant 10 |
> | 8 | Decimal representation of the numeric value of octal integer constant 010 |
> | 16 | Decimal representation of the numeric value of hexadecimal integer constant 0x10 |
>
> If the implementation supports floating-point conversions, the command:
>
>
>     LC_ALL=C printf '%.2f\n' 10 010 0x10 10.1e2 010.1e2 0x10.1p2
>
> produces:\
>
> | **Output Line** | **Explanation** |
> |:---|:---|
> | 10.00 | The string `"10"` interpreted as a decimal value, with 2 digits of precision |
> | 10.00 | The string `"010"` interpreted as a decimal (not octal) value, with 2 digits of precision |
> | 16.00 | The string `"0x10"` interpreted as a hexadecimal value, with 2 digits of precision |
> | 1010.00 | The string `"10.1e2"` interpreted as a decimal floating-point value, with 2 digits of precision |
> | 1010.00 | The string `"010.1e2"` interpreted as a decimal (not octal) floating-point value, with 2 digits of precision |
> | 64.25 | The string `"0x10.1p2"` interpreted as a hexadecimal floating-point value, with 2 digits of precision |
>
> The *printf* utility is required to notify the user when conversion errors are detected while producing numeric output; thus, the following results would be expected on an implementation with 32-bit two's-complement integers when `%d` is specified as the *format* operand:\
>
> | **Argument** | **Standard Output** | **Diagnostic Output**                     |
> |:-------------|:--------------------|:------------------------------------------|
> | 5a           | 5                   | printf: "5a" not completely converted     |
> | 9999999999   | 2147483647          | printf: "9999999999" arithmetic overflow  |
> | -9999999999  | -2147483648         | printf: "-9999999999" arithmetic overflow |
> | ABC          | 0                   | printf: "ABC" expected numeric value      |
>
> The diagnostic message format is not specified, but these examples convey the type of information that should be reported. Note that the value shown on standard output is what would be expected as the return value from the [*strtol*()](../functions/strtol.html) function as defined in the System Interfaces volume of POSIX.1-2024. A similar correspondence exists between `%u` and [*strtoul*()](../functions/strtoul.html) and `%e`, `%f`, and `%g` (if the implementation supports floating-point conversions) and [*strtod*()](../functions/strtod.html).
>
> In a locale that uses a codeset based on the ISO/IEC 646:1991 standard, the command:
>
>
>     printf "%d\n" 3 +3 -3 \'3 \"+3 "'-3"
>
> produces:\
>
> | **Output Line** | **Explanation** |
> |:---|:---|
> | 3 | Decimal representation of the numeric value 3 |
> | 3 | Decimal representation of the numeric value +3 |
> | -3 | Decimal representation of the numeric value -3 |
> | 51 | Decimal representation of the numeric value of the character `'3'` in the ISO/IEC 646:1991 standard codeset |
> | 43 | Decimal representation of the numeric value of the character `'+'` in the ISO/IEC 646:1991 standard codeset |
> | 45 | Decimal representation of the numeric value of the character `'-'` in the ISO/IEC 646:1991 standard codeset |
>
> Since the last two arguments contain more characters than used for the conversion, a diagnostic message is generated and the exit status is non-zero. Note that in a locale with multi-byte characters, the value of a character is intended to be the value of the equivalent of the **wchar_t** representation of the character as described in the System Interfaces volume of POSIX.1-2024.

#### <span id="tag_20_96_18"></span>RATIONALE

> The *printf* utility was added to provide functionality that has historically been provided by [*echo*](../utilities/echo.html). However, due to irreconcilable differences in the various versions of [*echo*](../utilities/echo.html) extant, the version has few special features, leaving those to this new *printf* utility, which is based on one in the Ninth Edition system.
>
> The format strings for the *printf* utility are handled differently than for the [*printf*()](../functions/printf.html) function in several respects. Notable differences include:
>
> - Reuse of the format until all arguments have been consumed.
> - No provision for obtaining field width and precision from argument values.
> - No requirement to support floating-point conversion specifiers.
> - An additional `b` conversion specifier.
> - Special handling of leading single-quote or double-quote for integer conversion specifiers.
> - Hexadecimal character constants are not recognized in the format.
> - Formats that use numbered argument conversion specifications can have gaps in the argument numbers.
>
> Although *printf* implementations have no difficulty handling formats with mixed numbered and unnumbered conversion specifications (unlike the [*printf*()](../functions/printf.html) function where it is undefined behavior), existing implementations differ in behavior. Given the format operand `"%2$d %d\n"`, with some implementations the `"%d"` evaluates the first argument and with others it evaluates the third. Consequently this standard leaves the behavior unspecified (as opposed to undefined).
>
> Earlier versions of this standard specified that arguments for all conversions other than `b`, `c`, and `s` were evaluated in the same way (as C constants, but with stated exceptions). For implementations supporting the floating-point conversions it was not clear whether integer conversions need only accept integer constants and floating-point conversions need only accept floating-point constants, or whether both types of conversions should accept both types of constants. Also by not distinguishing between them, the requirement relating to a leading single-quote or double-quote applied to floating-point conversions even though this provided no useful functionality to applications that was not already available through the integer conversions. The current standard clarifies the situation by specifying that the arguments for floating-point conversions are evaluated as if by [*strtod*()](../functions/strtod.html), and the arguments for integer conversions are evaluated as C integer constants, with the special treatment of leading single-quote and double-quote applying only to integer conversions.

#### <span id="tag_20_96_19"></span>FUTURE DIRECTIONS

> A future version of this standard may require that a missing *argument* operand to be consumed by a numbered argument conversion specification is treated as an error.
>
> A future version of this standard is expected to add a `%b` conversion to the [*printf*()](../functions/printf.html) function for binary conversion of integers, in alignment with the next version of the ISO C standard. This will result in an inconsistency between the *printf* utility and [*printf*()](../functions/printf.html) function for format strings containing `%b`. Implementors are encouraged to collaborate on a way to address this which could then be adopted in a future version of this standard. For example, the *printf* utility could add a **-C** option to make the format string behave in the same way, as far as possible, as the [*printf*()](../functions/printf.html) function.
>
> A future version of this standard may add a `%q` conversion to convert a string argument to a quoted output format that can be reused as shell input.

#### <span id="tag_20_96_20"></span>SEE ALSO

> [*awk*](../utilities/awk.html#), [*bc*](../utilities/bc.html#), [*echo*](../utilities/echo.html#)
>
> XBD [*5. File Format Notation*](../basedefs/V1_chap05.html#tag_05), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)
>
> XSH [*fprintf*()](../functions/fprintf.html#), [*strtod*()](../functions/strtod.html#)

#### <span id="tag_20_96_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_96_22"></span>Issue 7

> Austin Group Interpretations 1003.1-2001 \#175 and \#177 are applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0156 \[727\], XCU/TC2-2008/0157 \[727,932\], XCU/TC2-2008/0158 \[584\], and XCU/TC2-2008/0159 \[727\] are applied.

#### <span id="tag_20_96_23"></span>Issue 8

> Austin Group Defect 1108 is applied, changing "twos" to "two's".
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1202 is applied, changing the description of how `'\c'` is handled by the `b` conversion specifier.
>
> Austin Group Defects 1209 and 1476 are applied, changing the EXAMPLES section.
>
> Austin Group Defect 1413 is applied, changing the APPLICATION USAGE section.
>
> Austin Group Defect 1562 is applied, clarifying that it is the application's responsibility to ensure that the format is a character string, beginning and ending in its initial shift state, if any.
>
> Austin Group Defect 1592 is applied, adding support for numbered conversion specifications.
>
> Austin Group Defect 1771 is applied, changing the FUTURE DIRECTIONS section.

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
