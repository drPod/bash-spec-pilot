The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="sed"></span> <span id="tag_20_109"></span>

#### <span id="tag_20_109_01"></span>NAME

> sed — stream editor

#### <span id="tag_20_109_02"></span>SYNOPSIS

> `sed`` `**`[`**`-En`**`]`**` `*`script`*` `**`[`***`file`*`...`**`]`**\
> \
> `sed`` `**`[`**`-En`**`]`**` ``-e`` `*`script`*` `**`[`**`-e`` `*`script`***`]`**`...`` `**`[`**`-f`` `*`script_file`***`]`**`...`` `**`[`***`file`*`...`**`]`**\
> \
> `sed`` `**`[`**`-En`**`] [`**`-e`` `*`script`***`]`**`... -f`` `*`script_file`*` `**`[`**`-f`` `*`script_file`***`]`**`...`` `**`[`***`file`*`...`**`]`**\

#### <span id="tag_20_109_03"></span>DESCRIPTION

> The *sed* utility is a stream editor that shall read one or more text files, make editing changes according to a script of editing commands, and write the results to standard output. The script shall be obtained from either the *script* operand string or a combination of the option-arguments from the **-e** *script* and **-f** *script_file* options.

#### <span id="tag_20_109_04"></span>OPTIONS

> The *sed* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that the order of presentation of the **-e** and **-f** options is significant.
>
> The following options shall be supported:
>
> **-E**
>
> Match using extended regular expressions. Treat each pattern specified as an ERE, as described in XBD [*9.4 Extended Regular Expressions*](../basedefs/V1_chap09.html#tag_09_04).
>
> **-e ***script*
>
> Add the editing commands specified by the *script* option-argument to the end of the script of editing commands.
>
> **-f ***script_file*
>
> Add the editing commands in the file *script_file* to the end of the script of editing commands.
>
> **-n**
>
> Suppress the default output (in which each line, after it is examined for editing, is written to standard output). Only lines explicitly selected for output are written.
>
> If any **-e** or **-f** options are specified, the script of editing commands shall initially be empty. The commands specified by each **-e** or **-f** option shall be added to the script in the order specified. When each addition is made, if the previous addition (if any) was from a **-e** option, a \<newline\> shall be inserted before the new addition. The resulting script shall have the same properties as the *script* operand, described in the OPERANDS section.

#### <span id="tag_20_109_05"></span>OPERANDS

> The following operands shall be supported:
>
> *file*
>
> A pathname of a file whose contents are read and edited. If multiple *file* operands are specified, the named files shall be read in the order specified and the concatenation shall be edited. If no *file* operands are specified, the standard input shall be used.
>
> *script*
>
> A string to be used as the script of editing commands. The application shall not present a *script* that violates the restrictions of a text file except that the final character need not be a \<newline\>.

#### <span id="tag_20_109_06"></span>STDIN

> The standard input shall be used if no *file* operands are specified, and shall be used if a *file* operand is `'-'` and the implementation treats the `'-'` as meaning standard input. Otherwise, the standard input shall not be used. See the INPUT FILES section.

#### <span id="tag_20_109_07"></span>INPUT FILES

> The input files shall be text files. The *script_file*s named by the **-f** option shall consist of editing commands.

#### <span id="tag_20_109_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *sed*:
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
> Determine the locale for the behavior of ranges, equivalence classes, and multi-character collating elements within regular expressions.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files), and the behavior of character classes within regular expressions.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_109_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_109_10"></span>STDOUT

> The input files shall be written to standard output, with the editing commands specified in the script applied. If the **-n** option is specified, only those input lines selected by the script shall be written to standard output.

#### <span id="tag_20_109_11"></span>STDERR

> The standard error shall be used only for diagnostic and warning messages.

#### <span id="tag_20_109_12"></span>OUTPUT FILES

> The output files shall be text files whose formats are dependent on the editing commands given.

#### <span id="tag_20_109_13"></span>EXTENDED DESCRIPTION

> The *script* shall consist of editing commands of the following form:
>
>
>     [address[,address]]function
>
> where *function* represents a single-character command verb from the list in [Editing Commands in sed](#tag_20_109_13_03), followed by any applicable arguments.
>
> The command can be preceded by \<blank\> characters and/or \<semicolon\> characters. The function can be preceded by \<blank\> characters. These optional characters shall have no effect.
>
> In default operation, *sed* cyclically shall append a line of input, less its terminating \<newline\> character, into the pattern space. Reading from input shall be skipped if a \<newline\> was in the pattern space prior to a **D** command ending the previous cycle. The *sed* utility shall then apply in sequence all commands whose addresses select that pattern space, until a command starts the next cycle or quits. If no commands explicitly started a new cycle, then at the end of the script the pattern space shall be copied to standard output (except when **-n** is specified) and the pattern space shall be deleted. Whenever the pattern space is written to standard output or a named file, *sed* shall immediately follow it with a \<newline\>.
>
> Some of the editing commands use a hold space to save all or part of the pattern space for subsequent retrieval. The pattern and hold spaces shall each be able to hold at least 8192 bytes.
>
> ##### <span id="tag_20_109_13_01"></span>Addresses in sed
>
> An address is either a decimal number that counts input lines cumulatively across files, a `'$'` character that addresses the last line of input, or a context address. A context address has either the form `"/RE/"` or `"\`*`c`*`RE`*`c`*`"`, where RE is a regular expression as described in [Regular Expressions in sed](#tag_20_109_13_02), and *c* is any character other than \<backslash\> or \<newline\>. In a *sed* context address, the BRE and ERE syntax shall be extended to support escaping occurrences of the \<slash\> or *c* delimiter within the RE by means of an escape sequence (see XBD [*9.1 Regular Expression Definitions*](../basedefs/V1_chap09.html#tag_09_01)). For the `"\`*`c`*`RE`*`c`*`"` form, if the character designated by *c* is not listed as a special BRE character (if the **-E** option is not specified) or a special ERE character (if **-E** is specified) in XBD [*9.3.3 BRE Special Characters*](../basedefs/V1_chap09.html#tag_09_03_03) or XBD [*9.4.3 ERE Special Characters*](../basedefs/V1_chap09.html#tag_09_04_03), respectively, the escape sequence \<backslash\>*c* shall be treated as that literal character; otherwise, it is unspecified whether the escape sequence \<backslash\>*c* is treated as the literal character or the special character. In either case, the escape sequence \<backslash\>*c* shall not terminate the RE. For example, in the context address `"/abc\/def/"`, the second \<slash\> stands for itself, so that the RE is `"abc/def"`, and in `"\xabc\xdefx"`, the second `'x'` stands for itself, so that the RE is `"abcxdef"`.
>
> An editing command with no addresses shall select every pattern space.
>
> An editing command with one address shall select each pattern space that matches the address.
>
> An editing command with two addresses shall select the inclusive range from the first pattern space that matches the first address through the next pattern space that matches the second. (If the second address is a number less than or equal to the line number first selected, only one line shall be selected.) Starting at the first line following the selected range, *sed* shall look again for the first address. Thereafter, the process shall be repeated. Omitting either or both of the address components in the following form produces undefined results:
>
>
>     [address[,address]]
>
> ##### <span id="tag_20_109_13_02"></span>Regular Expressions in sed
>
> The *sed* utility shall support the REs described in XBD [*9. Regular Expressions*](../basedefs/V1_chap09.html#tag_09); by default it shall use BREs as described in XBD [*9.3 Basic Regular Expressions*](../basedefs/V1_chap09.html#tag_09_03), but if the **-E** option is used, it shall use EREs as described in XBD [*9.4 Extended Regular Expressions*](../basedefs/V1_chap09.html#tag_09_04). In *sed*, the BRE and ERE syntax shall be extended as follows:
>
> - The delimiter character that precedes and follows the RE shall not terminate the RE when it appears within a bracket expression, and shall have its normal meaning in the bracket expression. For example, the context address `"\%[%]%"` is equivalent to `"/[%]/"`, and the command `"s-[0-9]--g"` is equivalent to `"s/[0-9]//g"`.
>
> - The escape sequence `'\n'` shall match a \<newline\> embedded in the pattern space. A literal \<newline\> shall not be used in the RE of a context address or in the substitute function.
>
> - If an RE is empty (that is, no pattern is specified) *sed* shall behave as if the last RE used in the last command applied (either as an address or as part of a substitute command) was specified.
>
> ##### <span id="tag_20_109_13_03"></span>Editing Commands in sed
>
> In the following list of editing commands, the maximum number of permissible addresses for each function is indicated by \[*0addr*\], \[*1addr*\], or \[*2addr*\], representing zero, one, or two addresses.
>
> The argument *text* shall consist of one or more lines. A \<backslash\> in the text can be escaped with another \<backslash\>. The application shall ensure that each embedded \<newline\> (that is, those other than the terminating \<newline\> of the last line) in the text is preceded by an unescaped \<backslash\>. The behavior is unspecified if an unescaped \<backslash\> is immediately followed by any character other than \<backslash\> or \<newline\>, or by the end of a *script*.
>
> The **r** and **w** command verbs, and the *w* flag to the **s** command, take an *rfile* (or *wfile*) parameter, separated from the command verb letter or flag by one or more \<blank\> characters; implementations may allow zero separation as an extension.
>
> The argument *rfile* or the argument *wfile* shall terminate the editing command. Each *wfile* shall be created before processing begins. Implementations shall support at least ten *wfile* arguments in the script; the actual number (greater than or equal to 10) that is supported by the implementation is unspecified. The use of the *wfile* parameter shall cause that file to be initially created, if it does not exist, or shall replace the contents of an existing file.
>
> The **b**, **r**, **s**, **t**, **w**, **y**, and **:** command verbs shall accept additional arguments. The following synopses indicate which arguments shall be separated from the command verbs by a single \<space\>.
>
> The **a** and **r** commands schedule text for later output. The text specified for the **a** command, and the contents of the file specified for the **r** command, shall be written to standard output just before the next attempt to fetch a line of input when executing the **c**, **D**, **d**, **N**, or **n** commands, just before executing the **q** command, or when reaching the end of the script. If written when reaching the end of the script, and the **-n** option was not specified, the text shall be written after copying the pattern space to standard output. The contents of the file specified for the **r** command shall be as of the time the output is written, not the time the **r** command is applied. The text shall be output in the order in which the **a** and **r** commands were applied to the input.
>
> Editing commands other than **a**, **b**, **c**, **i**, **r**, **t**, **w**, **:**, and **\#** can be followed by a \<semicolon\>, optional \<blank\> characters, and another editing command. However, when an **s** editing command is used with the *w* flag, following it with another command in this manner produces undefined results.
>
> A function can be preceded by a `'!'` character, in which case the function shall be applied if the addresses do not select the pattern space. Zero or more \<blank\> characters shall be accepted before the `'!'` character. It is unspecified whether \<blank\> characters can follow the `'!'` character, and conforming applications shall not follow the `'!'` character with \<blank\> characters.
>
> If a *label* argument (to a **b**, **t**, or **:** command) contains characters outside of the portable filename character set, or if a *label* is longer than 8 bytes, the behavior is unspecified. The implementation shall support *label* arguments recognized as unique up to at least 8 bytes; the actual length (greater than or equal to 8) supported by the implementation is unspecified. It is unspecified whether exceeding the maximum supported label length causes an error or a silent truncation.
>
> **\[***2addr***\] {***editing command*
>
> *editing command*
>
> ...
>
> **}**
>
> Execute a list of *sed* editing commands only when the pattern space is selected. The list of *sed* editing commands shall be surrounded by braces. The braces can be preceded or followed by \<blank\> characters. The \<right-brace\> shall be preceded by a \<newline\> or \<semicolon\> (before any optional \<blank\> characters preceding the \<right-brace\>).
>
> Each command in the list of commands shall be terminated by a \<newline\> character, or by a \<semicolon\> character if permitted when the command is used outside the braces. The editing commands can be preceded by \<blank\> characters, but shall not be followed by \<blank\> characters.
>
> **\[***1addr***\]a\\**
>
> *text*
>
> Write text to standard output as described previously.
>
> **\[***2addr***\]b \[***label***\]**
>
> \
> Branch to the **:** command verb bearing the *label* argument. If *label* is not specified, branch to the end of the script.
>
> **\[***2addr***\]c\\**
>
> *text*
>
> Delete the pattern space. With a 0 or 1 address or at the end of a 2-address range, place *text* on the output. Start the next cycle.
>
> **\[***2addr***\]d**
>
> Delete the pattern space and start the next cycle.
>
> **\[***2addr***\]D**
>
> If the pattern space contains no \<newline\>, delete the pattern space and start a normal new cycle as if the **d** command was issued. Otherwise, delete the initial segment of the pattern space through the first \<newline\>, and start the next cycle with the resultant pattern space and without reading any new input.
>
> **\[***2addr***\]g**
>
> Replace the contents of the pattern space by the contents of the hold space.
>
> **\[***2addr***\]G**
>
> Append to the pattern space a \<newline\> followed by the contents of the hold space.
>
> **\[***2addr***\]h**
>
> Replace the contents of the hold space with the contents of the pattern space.
>
> **\[***2addr***\]H**
>
> Append to the hold space a \<newline\> followed by the contents of the pattern space.
>
> **\[***1addr***\]i\\**
>
> *text*
>
> Write *text* to standard output.
>
> **\[***2addr***\]l**
>
> (The letter ell.) Write the pattern space to standard output in a visually unambiguous form. The characters listed in XBD [*Escape Sequences and Associated Actions*](../basedefs/V1_chap05.html#tagtcjh_2) (`'\\'`, `'\a'`, `'\b'`, `'\f'`, `'\r'`, `'\t'`, `'\v'`) shall be written as the corresponding escape sequence; the `'\n'` in that table is not applicable. Non-printable characters not in that table shall be written as one three-digit octal number (with a preceding \<backslash\>) for each byte in the character (most significant byte first).
>
> Long lines shall be folded, with the point of folding indicated by writing a \<backslash\> followed by a \<newline\>; the length at which folding occurs is unspecified, but should be appropriate for the output device. The end of each line shall be marked with a `'$'`.
>
> **\[***2addr***\]n**
>
> Write the pattern space to standard output if the default output has not been suppressed, and replace the pattern space with the next line of input, less its terminating \<newline\>.
>
> If no next line of input is available, the **n** command verb shall branch to the end of the script and quit without starting a new cycle.
>
> **\[***2addr***\]N**
>
> Append the next line of input, less its terminating \<newline\>, to the pattern space, using an embedded \<newline\> to separate the appended material from the original material. Note that the current line number changes.
>
> If no next line of input is available, the **N** command verb shall branch to the end of the script and quit without starting a new cycle or copying the pattern space to standard output.
>
> **\[***2addr***\]p**
>
> Write the pattern space to standard output.
>
> **\[***2addr***\]P**
>
> Write the pattern space, up to the first \<newline\>, to standard output.
>
> **\[***1addr***\]q**
>
> Branch to the end of the script and quit without starting a new cycle.
>
> **\[***1addr***\]r ***rfile*
>
> Copy the contents of *rfile* to standard output as described previously. If *rfile* does not exist or cannot be read, it shall be treated as if it were an empty file, causing no error condition.
>
> **\[***2addr***\]s/***RE***/***replacement***/***flags*
>
> \
> Substitute the replacement string for instances of the RE in the pattern space. Any character other than \<backslash\> or \<newline\> can be used instead of a \<slash\> to delimit the RE and the replacement. Within the RE (as a *sed* extension to the BRE and ERE syntax) and the replacement, the delimiter shall not terminate the RE or replacement if it is the second character of an escape sequence (see XBD [*9.1 Regular Expression Definitions*](../basedefs/V1_chap09.html#tag_09_01)). If the delimiter character is not listed as a special BRE character (if the **-E** option is not specified) or a special ERE character (if **-E** is specified) in XBD [*9.3.3 BRE Special Characters*](../basedefs/V1_chap09.html#tag_09_03_03) or XBD [*9.4.3 ERE Special Characters*](../basedefs/V1_chap09.html#tag_09_04_03), respectively, the escaped delimiter shall be treated as that literal character in the RE; otherwise, it is unspecified whether the escaped delimiter is treated as the literal character or the special character. Likewise, if the delimiter character is not \<ampersand\> (`'&'`), the escaped delimiter shall be treated as that literal character in the replacement; if it is \<ampersand\>, it is unspecified whether the escaped delimiter is treated as the literal character or the special character (see below).
>
> The replacement string shall be scanned from beginning to end. An \<ampersand\> (`'&'`) appearing in the replacement shall be replaced by the string matching the RE. The special meaning of `'&'` in this context can be suppressed by preceding it by a \<backslash\>. The characters `"\`*n"*, where *n* is a digit, shall be replaced by the text matched by the corresponding back-reference expression. If the corresponding back-reference expression does not match, then the characters `"\`*n"* shall be replaced by the empty string. The special meaning of `"\`*n"* where *n* is a digit in this context, can be suppressed by preceding it by a \<backslash\>. For each other \<backslash\> encountered, the following character shall lose its special meaning (if any).
>
> A line can be split by substituting a \<newline\> into it. The application shall escape the \<newline\> in the replacement by preceding it by a \<backslash\>.
>
> The meaning of an unescaped \<backslash\> immediately followed by any character other than `'&'`, \<backslash\>, a digit, \<newline\>, or the delimiter character used for this command, is unspecified.
>
> Any \<backslash\> used to alter the default meaning of a subsequent character shall be discarded from the resulting replacement string. A substitution shall be considered to have been performed even if the resulting replacement string is identical to the string that it replaces.
>
> The value of *flags* shall be zero or more of:
>
> *n*
>
> Substitute for the *n*th occurrence only of the RE found within the pattern space.
>
> **g**
>
> Globally substitute for all non-overlapping instances of the RE rather than just the first one. If both **g** and *n* are specified, the results are unspecified.
>
> **i**
>
> Match the regular expression in a case-insensitive way.
>
> **p**
>
> Write the pattern space to standard output if a replacement was made.
>
> **w ***wfile*
>
> Write. Append the pattern space to *wfile* if a replacement was made. A conforming application shall precede the *wfile* argument with one or more \<blank\> characters. If the **w** flag is not the last flag value given in a concatenation of multiple flag values, the results are undefined.
>
> **\[***2addr***\]t \[***label***\]**
>
> \
> Test. Branch to the **:** command verb bearing the *label* if any substitutions have been made since the most recent reading of an input line or execution of a **t**. If *label* is not specified, branch to the end of the script.
>
> **\[***2addr***\]w ***wfile*
>
> \
> Append (write) the pattern space to *wfile*.
>
> **\[***2addr***\]x**
>
> Exchange the contents of the pattern and hold spaces.
>
> **\[***2addr***\]y/***string1***/***string2***/**
>
> \
> Replace all occurrences of characters in *string1* with the corresponding characters in *string2*. If a \<backslash\> followed by an `'n'` appear in *string1* or *string2*, the two characters shall be handled as a single \<newline\>. If (after resolving any escape sequences) the numbers of characters in *string1* and *string2* are not equal, or if any of the characters in *string1* appear more than once, the results are undefined. Any character other than \<backslash\> or \<newline\> can be used instead of \<slash\> to delimit the strings. If the delimiter is not `'n'`, within *string1* and *string2*, the delimiter itself can be used as a literal character if it is preceded by an unescaped \<backslash\>. If a \<backslash\> character is escaped by an immediately preceding unescaped \<backslash\> character in *string1* or *string2*, the two \<backslash\> characters shall be treated as a single literal \<backslash\> character. The meaning of an unescaped \<backslash\> followed by any character that is not `'n'`, a \<backslash\>, or the delimiter character is undefined.
>
> **\[***0addr***\]:***label*
>
> Do nothing. This command bears a *label* to which the **b** and **t** commands branch.
>
> **\[***1addr***\]=**
>
> Write the following to standard output:
>
>
>     "%d\n", <current line number>
>
> **\[***0addr***\]**
>
> Ignore this empty command.
>
> **\[***0addr***\]#**
>
> Ignore the `'#'` and the remainder of the line (treat them as a comment), with the single exception that if the first two characters in the script are `"#n"`, the default output shall be suppressed; this shall be the equivalent of specifying **-n** on the command line.

#### <span id="tag_20_109_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_109_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_109_16"></span>APPLICATION USAGE

> Regular expressions match entire strings, not just individual lines, but a \<newline\> is matched by `'\n'` in a *sed* RE; a \<newline\> is not allowed by the general definition of regular expression in POSIX.1-2024. Also note that `'\n'` cannot be used to match a \<newline\> at the end of an arbitrary input line; \<newline\> characters appear in the pattern space as a result of the **N** editing command.
>
> Applications that use a special RE character as a delimiter (for example, `'.'` or `'*'`) and need to use the delimiter as a literal character in the RE should put it inside a bracket expression, as implementations differ regarding whether escaping it with a \<backslash\> removes its special meaning. For example, for the context address `"/\.[0-9]/"` to be written with `'.'` as delimiter, the form `"\.[.][0-9]."` needs to be used; `"\.\.[0-9]."` cannot be used portably for this purpose, as it is unspecified whether this would be equivalent to `"/\.[0-9]/"` or `"/.[0-9]/"`. Portable applications cannot use a special RE character as a delimiter if that character needs to have its special meaning in the RE, as escaping it may remove its special meaning.
>
> When using *sed* to process pathnames, it is recommended that LC_ALL, or at least LC_CTYPE and LC_COLLATE, are set to POSIX or C in the environment, since pathnames can contain byte sequences that do not form valid characters in some locales, in which case the utility's behavior would be undefined. In the POSIX locale each byte is a valid single-byte character, and therefore this problem is avoided.
>
> Note that some implementations of *sed* also support an **I** flag for the **s** command as an alias for the lower case **i** flag.
>
> Some implementations of *sed*, when executed in a non-conforming environment, handle \<backslash\> escapes in regular expressions in a similar way to how [*awk*](../utilities/awk.html) handles them in the lexical token **ERE** (processing `"\t"` as a tab character, etc.). This is a compatible extension except that it conflicts with the requirements of this standard when \<backslash\> appears inside a bracket expression. A future version of this standard may allow this behavior, and therefore applications should use two \<backslash\> characters in bracket expressions instead of one in order to ensure future portability. On implementations conforming to the current standard, the second \<backslash\> is redundant. In the future (and in current non-conforming environments) the first \<backslash\> may escape the second.

#### <span id="tag_20_109_17"></span>EXAMPLES

> This *sed* script simulates the BSD [*cat*](../utilities/cat.html) **-s** command, squeezing excess empty lines from standard input.
>
>
>     sed -n '
>     # Write non-empty lines.
>     /./ {
>         p
>         d
>         }
>     # Write a single empty line, then look for more empty lines.
>     /^$/    p
>     # Get next line, discard the held <newline> (empty line),
>     # and look for more empty lines.
>     :Empty
>     /^$/    {
>         N
>         s/.//
>         b Empty
>         }
>     # Write the non-empty line before going back to search
>     # for the first in a set of empty lines.
>         p
>     '
>
> The following *sed* command is a much simpler method of squeezing empty lines, although it is not quite the same as [*cat*](../utilities/cat.html) **-s** since it removes any initial empty lines:
>
>
>     sed -n '/./,/^$/p'

#### <span id="tag_20_109_18"></span>RATIONALE

> This volume of POSIX.1-2024 requires implementations to support at least ten distinct *wfile*s, matching historical practice on many implementations. Implementations are encouraged to support more, but conforming applications should not exceed this limit.
>
> The exit status codes specified here are different from those in System V. System V returns 2 for garbled *sed* commands, but returns zero with its usage message or if the input file could not be opened. The standard developers considered this to be a bug.
>
> The manner in which the **l** command writes non-printable characters was changed to avoid the historical backspace-overstrike method, and other requirements to achieve unambiguous output were added. See the RATIONALE for [*ed*](../utilities/ed.html#) for details of the format chosen, which is the same as that chosen for *sed*.
>
> This volume of POSIX.1-2024 requires implementations to provide pattern and hold spaces of at least 8192 bytes, larger than the 4000 bytes spaces used by some historical implementations, but less than the 20480 bytes limit used in an early proposal. Implementations are encouraged to allocate dynamically larger pattern and hold spaces as needed.
>
> The requirements for acceptance of \<blank\> and \<space\> characters in command lines has been made more explicit than in early proposals to describe clearly the historical practice and to remove confusion about the phrase "protect initial blanks \[*sic*\] and tabs from the stripping that is done on every script line" that appears in much of the historical documentation of the *sed* utility description of text. (Not all implementations are known to have stripped \<blank\> characters from text lines, although they all have allowed leading \<blank\> characters preceding the address on a command line.)
>
> The treatment of `'#'` comments differs from the SVID which only allows a comment as the first line of the script, but matches BSD-derived implementations. The comment character is treated as a command, and it has the same properties in terms of being accepted with leading \<blank\> characters; the BSD implementation has historically supported this.
>
> Early proposals required that a *script_file* have at least one non-comment line. Some historical implementations have behaved in unexpected ways if this were not the case. The standard developers considered that this was incorrect behavior and that application developers should not have to avoid this feature. A correct implementation of this volume of POSIX.1-2024 shall permit *script_file*s that consist only of comment lines.
>
> Early proposals indicated that if **-e** and **-f** options were intermixed, all **-e** options were processed before any **-f** options. This has been changed to process them in the order presented because it matches historical practice and is more intuitive.
>
> The characters \<backslash\> and \<newline\> cannot be used as RE delimiter characters, as they can never be recognized as the ending delimiter:
>
> - \<backslash\> does not work, because if it appears unescaped later in the RE, it either escapes the following character, which can then never be the ending delimiter, or it is part of a bracket expression, inside which the ending delimiter for the RE cannot be located.
>
> - \<newline\> does not work, because if not escaped, it terminates the command, meaning it cannot be the ending delimiter.
>
> Some historical *sed* implementations did not support escaping `'('`, `')'`, `'{'`, and `'}'` when used as a BRE delimiter, as the sequences `"\("` and so on were still treated as special, usually resulting in an error. This standard requires that these sequences are treated as the literal character. This is for consistency with extensions. For example, some implementations treat `"\s"` in a BRE as matching white-space characters, as an extension. This cannot have its special meaning when `'s'` is used as a BRE delimiter in order to ensure portability of *sed* commands that have `'s'` as a delimiter and escape it. If `"\s"` were allowed to keep its special meaning, then the potential for further extensions would mean portable applications would not be able to escape any delimiter character other than \<slash\>.
>
> The treatment of the **p** flag to the **s** command differs between System V and BSD-based systems when the default output is suppressed. In the two examples:
>
>
>     echo a | sed    's/a/A/p'
>     echo a | sed -n 's/a/A/p'
>
> this volume of POSIX.1-2024, BSD, System V documentation, and the SVID indicate that the first example should write two lines with **A**, whereas the second should write one. Some System V systems write the **A** only once in both examples because the **p** flag is ignored if the **-n** option is not specified.
>
> This is a case of a diametrical difference between systems that could not be reconciled through the compromise of declaring the behavior to be unspecified. The SVID/BSD/System V documentation behavior was adopted for this volume of POSIX.1-2024 because:
>
> - No known documentation for any historic system describes the interaction between the **p** flag and the **-n** option.
>
> - The selected behavior is more correct as there is no technical justification for any interaction between the **p** flag and the **-n** option. A relationship between **-n** and the **p** flag might imply that they are only used together, but this ignores valid scripts that interrupt the cyclical nature of the processing through the use of the **D**, **d**, **q**, or branching commands. Such scripts rely on the **p** suffix to write the pattern space because they do not make use of the default output at the "bottom" of the script.
>
> - Because the **-n** option makes the **p** flag unnecessary, any interaction would only be useful if *sed* scripts were written to run both with and without the **-n** option. This is believed to be unlikely. It is even more unlikely that programmers have coded the **p** flag expecting it to be unnecessary. Because the interaction was not documented, the likelihood of a programmer discovering the interaction and depending on it is further decreased.
>
> - Finally, scripts that break under the specified behavior produce too much output instead of too little, which is easier to diagnose and correct.
>
> The form of the substitute command that uses the **n** suffix was limited to the first 512 matches in an early proposal. This limit has been removed because there is no reason an editor processing lines of {LINE_MAX} length should have this restriction. The command **s/a/A/2047** should be able to substitute the 2047th occurrence of **a** on a line.
>
> The **b**, **t**, and **:** commands are documented to ignore leading white space, but no mention is made of trailing white space. Historical implementations of *sed* assigned different locations to the labels `'x'` and `"x "`. This is not useful, and leads to subtle programming errors, but it is historical practice, and changing it could theoretically break working scripts. Implementors are encouraged to provide warning messages about labels that are never referenced by a **b** or **t** command, jumps to labels that do not exist, and label arguments that are subject to truncation.
>
> Earlier versions of this standard allowed for implementations with bytes other than eight bits, but this has been modified in this version.

#### <span id="tag_20_109_19"></span>FUTURE DIRECTIONS

> A future version of this standard may allow *sed* to handle \<backslash\> escapes in regular expressions in a similar way to how [*awk*](../utilities/awk.html) handles them in the lexical token **ERE**. ("Similar" rather than "the same" because *sed* can use BREs or EREs whereas [*awk*](../utilities/awk.html) uses only EREs.)

#### <span id="tag_20_109_20"></span>SEE ALSO

> [*awk*](../utilities/awk.html#), [*ed*](../utilities/ed.html#), [*grep*](../utilities/grep.html#)
>
> XBD [*Escape Sequences and Associated Actions*](../basedefs/V1_chap05.html#tagtcjh_2), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*9.3 Basic Regular Expressions*](../basedefs/V1_chap09.html#tag_09_03), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_109_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_109_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_109_23"></span>Issue 6

> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - Implementations are required to support at least ten *wfile* arguments in an editing command.
>
> The EXTENDED DESCRIPTION is changed to align with the IEEE P1003.2b draft standard.
>
> IEEE PASC Interpretation 1003.2 \#190 is applied.
>
> IEEE PASC Interpretation 1003.2 \#203 is applied, clarifying the meaning of the \<backslash\>-escape sequences in a replacement string for a BRE.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/28 is applied, removing text describing behavior on systems with bytes consisting of more than eight bits.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/29 is applied, making an editorial correction within the Editing Commands in *sed* section.

#### <span id="tag_20_109_24"></span>Issue 7

> Austin Group Interpretations 1003.1-2001 \#006, \#036, and \#092 are applied.
>
> SD5-XCU-ERN-97 and SD5-XCU-ERN-123 are applied, updating the SYNOPSIS.
>
> A second example is added.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0133 \[262\], XCU/TC1-2008/0134 \[282,431\], XCU/TC1-2008/0135 \[269\], and XCU/TC1-2008/0136 \[282,431\] are applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0166 \[945\], XCU/TC2-2008/0167 \[944\], XCU/TC2-2008/0168 \[945\], XCU/TC2-2008/0169 \[944\], XCU/TC2-2008/0170 \[945\], XCU/TC2-2008/0171 \[533\], XCU/TC2-2008/0172 \[663\], XCU/TC2-2008/0173 \[945\], and XCU/TC2-2008/0174 \[944\] are applied.

#### <span id="tag_20_109_25"></span>Issue 8

> Austin Group Defect 528 is applied, adding support for selecting the use of EREs instead of BREs, by specifying the **-E** option.
>
> Austin Group Defect 779 is applied, adding the **i** flag to the **s** command.
>
> Austin Group Defect 961 is applied, requiring that **{...}** can be followed by a \<semicolon\>, optional \<blank\> characters, and another editing command.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1231 is applied, clarifying the handling of \<backslash\> in *text* arguments.
>
> Austin Group Defect 1233 is applied, changing the APPLICATION USAGE and FUTURE DIRECTIONS sections.
>
> Austin Group Defect 1319 is applied, changing when the text specified for the **a** command and the contents of the file specified for the **r** command are written.
>
> Austin Group Defect 1550 is applied, clarifying requirements relating to delimiters in context addresses and in **s** and **y** commands.
>
> Austin Group Defect 1578 is applied, clarifying the description of the **y** command.
>
> Austin Group Defect 1767 is applied, clarifying that a **c** command starts the next cycle on every line that its address range matches.

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
