The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_19"></span>2. Shell Command Language

This chapter contains the definition of the Shell Command Language.

### <span id="tag_19_01"></span>2.1 Shell Introduction

The shell is a command language interpreter. This chapter describes the syntax of that command language as it is used by the [*sh*](../utilities/sh.html) utility and the [*system*()](../functions/system.html) and [*popen*()](../functions/popen.html) functions defined in the System Interfaces volume of POSIX.1-2024.

The shell operates according to the following general overview of operations. The specific details are included in the cited sections of this chapter.

1.  The shell reads its input from a file (see [*sh*](../utilities/sh.html)), from the **-c** option or from the [*system*()](../functions/system.html) and [*popen*()](../functions/popen.html) functions defined in the System Interfaces volume of POSIX.1-2024. If the first line of a file of shell commands starts with the characters `"#!"`, the results are unspecified.

2.  The shell breaks the input into tokens: words and operators; see [2.3 Token Recognition](#tag_19_03).

3.  The shell parses the input into simple commands (see [2.9.1 Simple Commands](#tag_19_09_01)) and compound commands (see [2.9.4 Compound Commands](#tag_19_09_04)).

4.  For each word within a command, the shell processes \<backslash\>-escape sequences inside dollar-single-quotes (see [2.2.4 Dollar-Single-Quotes](#tag_19_02_04)) and then performs various word expansions (see [2.6 Word Expansions](#tag_19_06)). In the case of a simple command, the results usually include a list of pathnames and fields to be treated as a command name and arguments; see [2.9 Shell Commands](#tag_19_09).

5.  The shell performs redirection (see [2.7 Redirection](#tag_19_07)) and removes redirection operators and their operands from the parameter list.

6.  The shell executes a function (see [2.9.5 Function Definition Command](#tag_19_09_05)), built-in (see [2.15 Special Built-In Utilities](#tag_19_15)), executable file, or script, giving the names of the arguments as positional parameters numbered 1 to *n*, and the name of the command (or in the case of a function within a script, the name of the script) as special parameter 0 (see [2.9.1.4 Command Search and Execution](#tag_19_09_01_04)).

7.  The shell optionally waits for the command to complete and collects the exit status (see [2.8.2 Exit Status for Commands](#tag_19_08_02)).

### <span id="tag_19_02"></span>2.2 Quoting

Quoting is used to remove the special meaning of certain characters or words to the shell. Quoting can be used to preserve the literal meaning of the special characters in the next paragraph, prevent reserved words from being recognized as such, and prevent parameter expansion and command substitution within here-document processing (see [2.7.4 Here-Document](#tag_19_07_04) ).

The application shall quote the following characters if they are to represent themselves:


    |  &  ;  <  >  (  )  $  `  \  "  '  <space>  <tab>  <newline>

and the following might need to be quoted under certain circumstances. That is, these characters are sometimes special depending on conditions described elsewhere in this volume of POSIX.1-2024:


    *  ?  [  ]  ^  -  !  #  ~  =  %  {  ,  }

**Note:**  
A future version of this standard may extend the conditions under which these characters are special. Therefore applications should quote them whenever they are intended to represent themselves. This does not apply to \<hyphen-minus\> (`'-'`) since it is in the portable filename character set.

The various quoting mechanisms are the escape character, single-quotes, double-quotes, and dollar-single-quotes. The here-document represents another form of quoting; see [2.7.4 Here-Document](#tag_19_07_04).

#### <span id="tag_19_02_01"></span>2.2.1 Escape Character (Backslash)

A \<backslash\> that is not quoted shall preserve the literal value of the following character, with the exception of a \<newline\>. If a \<newline\> immediately follows the \<backslash\>, the shell shall interpret this as line continuation. The \<backslash\> and \<newline\> shall be removed before splitting the input into tokens. Since the escaped \<newline\> is removed entirely from the input and is not replaced by any white space, it cannot serve as a token separator.

#### <span id="tag_19_02_02"></span>2.2.2 Single-Quotes

Enclosing characters in single-quotes (`''`) shall preserve the literal value of each character within the single-quotes. A single-quote cannot occur within single-quotes.

#### <span id="tag_19_02_03"></span>2.2.3 Double-Quotes

Enclosing characters in double-quotes (`""`) shall preserve the literal value of all characters within the double-quotes, with the exception of the characters backquote, \<dollar-sign\>, and \<backslash\>, as follows:

`$`

The \<dollar-sign\> shall retain its special meaning introducing parameter expansion (see [2.6.2 Parameter Expansion](#tag_19_06_02)), a form of command substitution (see [2.6.3 Command Substitution](#tag_19_06_03)), and arithmetic expansion (see [2.6.4 Arithmetic Expansion](#tag_19_06_04)), but shall not retain its special meaning introducing the dollar-single-quotes form of quoting (see [2.2.4 Dollar-Single-Quotes](#tag_19_02_04)).

The input characters within the quoted string that are also enclosed between `"$("` and the matching `')'` shall not be affected by the double-quotes, but rather shall define the command(s) whose output replaces the `"$(...)"` when the word is expanded. The tokenizing rules in [2.3 Token Recognition](#tag_19_03) shall be applied recursively to find the matching `')'`.

For the four varieties of parameter expansion that provide for substring processing (see [2.6.2 Parameter Expansion](#tag_19_06_02)), within the string of characters from an enclosed `"${"` to the matching `'}'`, the double-quotes within which the expansion occurs shall have no effect on the handling of any special characters.

For parameter expansions other than the four varieties that provide for substring processing, within the string of characters from an enclosed `"${"` to the matching `'}'`, the double-quotes within which the expansion occurs shall preserve the literal value of all characters, with the exception of the characters double-quote, backquote, \<dollar-sign\>, and \<backslash\>. If any unescaped double-quote characters occur within the string, other than in embedded command substitutions, the behavior is unspecified. The backquote and \<dollar-sign\> characters shall follow the same rules as for characters in double-quotes described in this section. The \<backslash\> character shall follow the same rules as for characters in double-quotes described in this section except that it shall additionally retain its special meaning as an escape character when followed by `'}'` and this shall prevent the escaped `'}'` from being considered when determining the matching `'}'` (using the rule in [2.6.2 Parameter Expansion](#tag_19_06_02)).

`` ` ``

The backquote shall retain its special meaning introducing the other form of command substitution (see [2.6.3 Command Substitution](#tag_19_06_03)). The portion of the quoted string from the initial backquote and the characters up to the next backquote that is not preceded by a \<backslash\>, having escape characters removed, defines that command whose output replaces `` "`...`" `` when the word is expanded. Either of the following cases produces undefined results:

- A quoted (single-quoted, double-quoted, or dollar-single-quoted) string that begins, but does not end, within the `` "`...`" `` sequence

- A `` "`...`" `` sequence that begins, but does not end, within the same double-quoted string

`\`

Outside of `"$(...)"` and `"${...}"` the \<backslash\> shall retain its special meaning as an escape character (see [2.2.1 Escape Character (Backslash)](#tag_19_02_01)) only when immediately followed by one of the following characters:


    $   `   \   <newline>

or by a double-quote character that would otherwise be considered special (see [2.6.4 Arithmetic Expansion](#tag_19_06_04) and [2.7.4 Here-Document](#tag_19_07_04)).

When double-quotes are used to quote a parameter expansion, command substitution, or arithmetic expansion, the literal value of all characters within the result of the expansion shall be preserved.

The application shall ensure that a double-quote that is not within `"$(...)"` nor within `"${...}"` is immediately preceded by a \<backslash\> in order to be included within double-quotes. The parameter `'@'` has special meaning inside double-quotes and is described in [2.5.2 Special Parameters](#tag_19_05_02).

#### <span id="tag_19_02_04"></span>2.2.4 Dollar-Single-Quotes

A sequence of characters starting with a \<dollar-sign\> immediately followed by a single-quote (`$'`) shall preserve the literal value of all characters up to an unescaped terminating single-quote (`'`), with the exception of certain \<backslash\>-escape sequences, as follows:

- `\"` yields a \<quotation-mark\> (double-quote) character, but note that \<quotation-mark\> can be included unescaped.

- `\'` yields an \<apostrophe\> (single-quote) character.

- `\\` yields a \<backslash\> character.

- `\a` yields an \<alert\> character.

- `\b` yields a \<backspace\> character.

- `\e` yields an \<ESC\> character.

- `\f` yields a \<form-feed\> character.

- `\n` yields a \<newline\> character.

- `\r` yields a \<carriage-return\> character.

- `\t` yields a \<tab\> character.

- `\v` yields a \<vertical-tab\> character.

- `\c`*X* yields the control character listed in the **Value** column of [*Values for cpio c_mode Field*](../utilities/stty.html#tagtcjh_23) in the OPERANDS section of the [*stty*](../utilities/stty.html) utility when *X* is one of the characters listed in the **^c** column of the same table, except that `\c\\` yields the \<FS\> control character since the \<backslash\> character has to be escaped.

- `\x`*XX* yields the byte whose value is the hexadecimal value *XX* (one or more hexadecimal digits). If more than two hexadecimal digits follow `\x`, the results are unspecified.

- `\`*ddd* yields the byte whose value is the octal value *ddd* (one to three octal digits).

- The behavior of an unescaped \<backslash\> immediately followed by any other character, including \<newline\>, is unspecified.

In cases where a variable number of characters can be used to specify an escape sequence (`\x`*XX* and `\`*ddd*), the escape sequence shall be terminated by the first character that is not of the expected type or, for `\`*ddd* sequences, when the maximum number of characters specified has been found, whichever occurs first.

These \<backslash\>-escape sequences shall be processed (replaced with the bytes or characters they yield) immediately prior to word expansion (see [2.6 Word Expansions](#tag_19_06)) of the word in which the dollar-single-quotes sequence occurs.

If a `\x`*XX* or `\`*ddd* escape sequence yields a byte whose value is 0, it is unspecified whether that null byte is included in the result or if that byte and any following regular characters and escape sequences up to the terminating unescaped single-quote are evaluated and discarded.

If the octal value specified by `\`*ddd* will not fit in a byte, the results are unspecified.

If a `\e` or `\c`*X* escape sequence specifies a character that does not have an encoding in the locale in effect when these \<backslash\>-escape sequences are processed, the result is implementation-defined. However, implementations shall not replace an unsupported character with bytes that do not form valid characters in that locale's character set.

If a \<backslash\>-escape sequence represents a single-quote character (for example `\'`), that sequence shall not terminate the dollar-single-quote sequence.

### <span id="tag_19_03"></span>2.3 Token Recognition

The shell shall read its input in terms of lines. (For details about how the shell reads its input, see the description of [*sh*](../utilities/sh.html#).) The input lines can be of unlimited length. These lines shall be parsed using two major modes: ordinary token recognition and processing of here-documents.

When an **io_here** token has been recognized by the grammar (see [2.10 Shell Grammar](#tag_19_10)), one or more of the subsequent lines immediately following the next **NEWLINE** token form the body of a here-document and shall be parsed according to the rules of [2.7.4 Here-Document](#tag_19_07_04). Any non-**NEWLINE** tokens (including more **io_here** tokens) that are recognized while searching for the next **NEWLINE** token shall be saved for processing after the here-document has been parsed. If a saved token is an **io_here** token, the corresponding here-document shall start on the line immediately following the line containing the trailing delimiter of the previous here-document. If any saved token includes a \<newline\> character, the behavior is unspecified.

When it is not processing an **io_here**, the shell shall break its input into tokens by applying the first applicable rule below to each character in turn in its input. At the start of input or after a previous token has just been delimited, the first or next token, respectively, shall start with the first character that has not already been included in a token and is not discarded according to the rules below. Once a token has started, zero or more characters from the input shall be appended to the token until the end of the token is delimited according to one of the rules below. When both the start and end of a token have been delimited, the characters forming the token shall be exactly those in the input between the two delimiters, including any quoting characters. If a rule below indicates that a token is delimited, and no characters have been included in the token, that empty token shall be discarded.

1.  If the end of input is recognized, the current token (if any) shall be delimited.

2.  If the previous character was used as part of an operator and the current character is not quoted and can be used with the previous characters to form an operator, it shall be used as part of that (operator) token.

3.  If the previous character was used as part of an operator and the current character cannot be used with the previous characters to form an operator, the operator containing the previous character shall be delimited.

4.  If the current character is an unquoted \<backslash\>, single-quote, or double-quote or is the first character of an unquoted \<dollar-sign\> single-quote sequence, it shall affect quoting for subsequent characters up to the end of the quoted text. The rules for quoting are as described in [2.2 Quoting](#tag_19_02). During token recognition no substitutions shall be actually performed, and the result token shall contain exactly the characters that appear in the input unmodified, including any embedded or enclosing quotes or substitution operators, between the start and the end of the quoted text. The token shall not be delimited by the end of the quoted field.

5.  If the current character is an unquoted `'$'` or `` '`' ``, the shell shall identify the start of any candidates for parameter expansion ( [2.6.2 Parameter Expansion](#tag_19_06_02)), command substitution ( [2.6.3 Command Substitution](#tag_19_06_03)), or arithmetic expansion ( [2.6.4 Arithmetic Expansion](#tag_19_06_04)) from their introductory unquoted character sequences: `'$'` or `"${"`, `"$("` or `` '`' ``, and `"$(("`, respectively. The shell shall read sufficient input to determine the end of the unit to be expanded (as explained in the cited sections). While processing the characters, if instances of expansions or quoting are found nested within the substitution, the shell shall recursively process them in the manner specified for the construct that is found. For `"$("` and `` '`' `` only, if instances of **io_here** tokens are found nested within the substitution, they shall be parsed according to the rules of [2.7.4 Here-Document](#tag_19_07_04); if the terminating `')'` or `` '`' `` of the substitution occurs before the **NEWLINE** token marking the start of the here-document, the behavior is unspecified. The characters found from the beginning of the substitution to its end, allowing for any recursion necessary to recognize embedded constructs, shall be included unmodified in the result token, including any embedded or enclosing substitution operators or quotes. The token shall not be delimited by the end of the substitution.

6.  If the current character is not quoted and can be used as the first character of a new operator, the current token (if any) shall be delimited. The current character shall be used as the beginning of the next (operator) token.

7.  If the current character is an unquoted \<blank\>, any token containing the previous character is delimited and the current character shall be discarded.

8.  If the previous character was part of a word, the current character shall be appended to that word.

9.  If the current character is a `'#'`, it and all subsequent characters up to, but excluding, the next \<newline\> shall be discarded as a comment. The \<newline\> that ends the line is not considered part of the comment.

10. The current character is used as the start of a new word.

Once a token is delimited, it is categorized as required by the grammar in [2.10 Shell Grammar](#tag_19_10).

In situations where the shell parses its input as a *program*, once a *complete_command* has been recognized by the grammar (see [2.10 Shell Grammar](#tag_19_10)), the *complete_command* shall be executed before the next *complete_command* is tokenized and parsed.

#### <span id="tag_19_03_01"></span>2.3.1 Alias Substitution

After a token has been categorized as type **TOKEN** (see [2.10.1 Shell Grammar Lexical Conventions](#tag_19_10_01)), including (recursively) any token resulting from an alias substitution, the **TOKEN** shall be subject to alias substitution if all of the following conditions are true:

- The **TOKEN** does not contain any quoting characters.

- The **TOKEN** is a valid alias name (see XBD [*3.10 Alias Name*](../basedefs/V1_chap03.html#tag_03_10)).

- An alias with that name is in effect.

- The **TOKEN** did not either fully or, optionally, partially result from an alias substitution of the same alias name at any earlier recursion level.

- Either the **TOKEN** is being considered for alias substitution because it follows an alias substitution whose replacement value ended with a \<blank\> (see below) or the **TOKEN** could be parsed as the command name word of a simple command (see [2.10 Shell Grammar](#tag_19_10)), based on this **TOKEN** and the tokens (if any) that preceded it, but ignoring whether any subsequent characters would allow that.

except that if the **TOKEN** meets the above conditions and would be recognized as a reserved word (see [2.4 Reserved Words](#tag_19_04)) if it occurred in an appropriate place in the input, it is unspecified whether the **TOKEN** is subject to alias substitution.

When a **TOKEN** is subject to alias substitution, the value of the alias shall be processed as if it had been read from the input instead of the **TOKEN**, with token recognition (see [2.3 Token Recognition](#tag_19_03)) resuming at the start of the alias value. When the end of the alias value is reached, the shell may behave as if an additional \<space\> character had been read from the input after the **TOKEN** that was replaced. If it does not add this \<space\>, it is unspecified whether the current token is delimited before token recognition is applied to the character (if any) that followed the **TOKEN** in the input.

**Note:**  
A future version of this standard may disallow adding this \<space\>.

If the value of the alias replacing the **TOKEN** ends in a \<blank\> that would be unquoted after substitution, and optionally if it ends in a \<blank\> that would be quoted after substitution, the shell shall check the next token in the input, if it is a **TOKEN**, for alias substitution; this process shall continue until a **TOKEN** is found that is not a valid alias or an alias value does not end in such a \<blank\>.

An implementation may defer the effect of a change to an alias but the change shall take effect no later than the completion of the currently executing *complete_command* (see [2.10 Shell Grammar](#tag_19_10)). Changes to aliases shall not take effect out of order. Implementations may provide predefined aliases that are in effect when the shell is invoked.

When used as specified by this volume of POSIX.1-2024, alias definitions shall not be inherited by separate invocations of the shell or by the utility execution environments invoked by the shell; see [2.13 Shell Execution Environment](#tag_19_13) .

### <span id="tag_19_04"></span>2.4 Reserved Words

Reserved words are words that have special meaning to the shell; see [2.9 Shell Commands](#tag_19_09). The following words shall be recognized as reserved words:

<table data-cellpadding="3">
<colgroup>
<col style="width: 25%" />
<col style="width: 25%" />
<col style="width: 25%" />
<col style="width: 25%" />
</colgroup>
<tbody>
<tr data-valign="top">
<td style="text-align: left;"><p><strong><br />
!<br />
{<br />
}<br />
case<br />
</strong></p></td>
<td style="text-align: left;"><p><strong><br />
do<br />
done<br />
elif<br />
else<br />
</strong></p></td>
<td style="text-align: left;"><p><strong><br />
esac<br />
fi<br />
for<br />
if<br />
</strong></p></td>
<td style="text-align: left;"><p><strong><br />
in<br />
then<br />
until<br />
while<br />
</strong></p></td>
</tr>
</tbody>
</table>

This recognition shall only occur when none of the characters is quoted and when the word is used as:

- The first word of a command
- The first word following one of the reserved words other than **case**, **for**, or **in**
- The third word in a **case** command (only **in** is valid in this case)
- The third word in a **for** command (only **in** and **do** are valid in this case)

See the grammar in [2.10 Shell Grammar](#tag_19_10).

When used in circumstances where reserved words are recognized (described above), the following words may be recognized as reserved words, in which case the results are unspecified except as described below for **time**:

|          |          |              |               |            |          |
|:---------|:---------|:-------------|:--------------|:-----------|:---------|
| **\[\[** | **\]\]** | **function** | **namespace** | **select** | **time** |

When the word **time** is recognized as a reserved word in circumstances where it would, if it were not a reserved word, be the command name (see [2.9.1.1 Order of Processing](#tag_19_09_01_01)) of a simple command that would execute the [*time*](../utilities/time.html) utility in a manner other than one for which [*time*](../utilities/time.html#tag_20_122) states that the results are unspecified, the behavior shall be as specified for the [*time*](../utilities/time.html) utility.

When used in circumstances where reserved words are recognized (described above), all words whose final character is a \<colon\> (`':'`) are reserved; their use in those circumstances produces unspecified results.

### <span id="tag_19_05"></span>2.5 Parameters and Variables

A parameter can be denoted by a name, a number, or one of the special characters listed in [2.5.2 Special Parameters](#tag_19_05_02). A variable is a parameter denoted by a name.

A parameter is set if it has an assigned value (null is a valid value). Once a variable is set, it can only be unset by using the [*unset*](#unset) special built-in command.

Parameters can contain arbitrary byte sequences, except for the null byte. The shell shall process their values as characters only when performing operations that are described in this standard in terms of characters.

#### <span id="tag_19_05_01"></span>2.5.1 Positional Parameters

A positional parameter is a parameter denoted by a decimal representation of a positive integer. The digits denoting the positional parameters shall always be interpreted as a decimal value, even if there is a leading zero. When a positional parameter with more than one digit is specified, the application shall enclose the digits in braces (see [2.6.2 Parameter Expansion](#tag_19_06_02)).

Examples:

- `"$8"`, `"${8}"`, `"${08}"`, `"${008}"`, etc. all expand to the value of the eighth positional parameter.
- `"${10}"` expands to the value of the tenth positional parameter.
- `"$10"` expands to the value of the first positional parameter followed by the character '0'.

**Note:**  
0 is a special parameter, not a positional parameter, and therefore the results of expanding `${00}` are unspecified.

Positional parameters are initially assigned when the shell is invoked (see [*sh*](../utilities/sh.html)), temporarily replaced when a shell function is invoked (see [2.9.5 Function Definition Command](#tag_19_09_05)), and can be reassigned with the [*set*](#set) special built-in command.

#### <span id="tag_19_05_02"></span>2.5.2 Special Parameters

Listed below are the special parameters and the values to which they shall expand. Only the values of the special parameters are listed; see [2.6 Word Expansions](#tag_19_06) for a detailed summary of all the stages involved in expanding words.

`@`

Expands to the positional parameters, starting from one, initially producing one field for each positional parameter that is set. When the expansion occurs in a context where field splitting will be performed, any empty fields may be discarded and each of the non-empty fields shall be further split as described in [2.6.5 Field Splitting](#tag_19_06_05). When the expansion occurs within double-quotes, the behavior is unspecified unless one of the following is true:

- Field splitting as described in [2.6.5 Field Splitting](#tag_19_06_05) would be performed if the expansion were not within double-quotes (regardless of whether field splitting would have any effect; for example, if *IFS* is null).
- The double-quotes are within the *word* of a \${*parameter*:-*word*} or a \${*parameter*:+*word*} expansion (with or without the \<colon\>; see [2.6.2 Parameter Expansion](#tag_19_06_02)) which would have been subject to field splitting if *parameter* had been expanded instead of *word*.

If one of these conditions is true, the initial fields shall be retained as separate fields, except that if the parameter being expanded was embedded within a word, the first field shall be joined with the beginning part of the original word and the last field shall be joined with the end part of the original word. In all other contexts the results of the expansion are unspecified. If there are no positional parameters, the expansion of `'@'` shall generate zero fields, even when `'@'` is within double-quotes; however, if the expansion is embedded within a word which contains one or more other parts that expand to a quoted null string, these null string(s) shall still produce an empty field, except that if the other parts are all within the same double-quotes as the `'@'`, it is unspecified whether the result is zero fields or one empty field.

`*`

Expands to the positional parameters, starting from one, initially producing one field for each positional parameter that is set. When the expansion occurs in a context where field splitting will be performed, any empty fields may be discarded and each of the non-empty fields shall be further split as described in [2.6.5 Field Splitting](#tag_19_06_05). When the expansion occurs in a context where field splitting will not be performed, the initial fields shall be joined to form a single field with the value of each parameter separated by the first character of the *IFS* variable if *IFS* contains at least one character, or separated by a \<space\> if *IFS* is unset, or with no separation if *IFS* is set to a null string.

`#`

Expands to the shortest representation of the decimal number of positional parameters. The command name (parameter 0) shall not be counted in the number given by `'#'` because it is a special parameter, not a positional parameter.

`?`

Expands to the shortest representation of the decimal exit status (see [2.8.2 Exit Status for Commands](#tag_19_08_02)) of the pipeline (see [2.9.2 Pipelines](#tag_19_09_02)) executed from the current shell execution environment (not a subshell environment) that most recently either terminated or, optionally but only if the shell is interactive and job control is enabled, was stopped by a signal. If this pipeline terminated, the status value shall be its exit status; otherwise, the status value shall be the same as the exit status that would have resulted if the pipeline had been terminated by a signal with the same number as the signal that stopped it. The value of the special parameter `'?'` shall be set to 0 during initialization of the shell. When a subshell environment is created, the value of the special parameter `'?'` from the invoking shell environment shall be preserved in the subshell.

**Note:**  
In `var=$(some_command); echo $?` the output is the exit status of `some_command`, which is executed in a subshell environment, but this is because its exit status becomes the exit status of the assignment command `var=$(some_command)` (see [2.9.1 Simple Commands](#tag_19_09_01)) and this assignment command is the most recently completed pipeline. Likewise for any pipeline consisting entirely of a simple command that has no command word, but contains one or more command substitutions. (See [2.9.1 Simple Commands](#tag_19_09_01).)

`-`

(Hyphen.) Expands to the current option flags (the single-letter option names concatenated into a string) as specified on invocation, by the [*set*](#set) special built-in command, or implicitly by the shell. It is unspecified whether the **-c** and **-s** options are included in the expansion of `"$-"`. The **-i** option shall be included in `"$-"` if the shell is interactive, regardless of whether it was specified on invocation.

`$`

Expands to the shortest representation of the decimal process ID of the invoked shell. In a subshell (see [2.13 Shell Execution Environment](#tag_19_13)), `'$'` shall expand to the same value as that of the current shell.

`!`

Expands to the shortest representation of the decimal process ID associated with the most recent asynchronous AND-OR list (see [2.9.3.1 Asynchronous AND-OR Lists](#tag_19_09_03_02)) executed from the current shell execution environment, or to the shortest representation of the decimal process ID of the last command specified in the currently executing pipeline in the job-control background job that most recently resumed execution through the use of [*bg*](../utilities/bg.html), whichever is the most recent.

0

(Zero.) Expands to the name of the shell or shell script. See [*sh*](../utilities/sh.html#) for a detailed description of how this name is derived.

See the description of the *IFS* variable in [2.5.3 Shell Variables](#tag_19_05_03).

#### <span id="tag_19_05_03"></span>2.5.3 Shell Variables

Variables shall be initialized from the environment (as defined by XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08) and the *exec* function in the System Interfaces volume of POSIX.1-2024) and can be given new values with variable assignment commands. Shell variables shall be initialized only from environment variables that have valid names. If a variable is initialized from the environment, it shall be marked for export immediately; see the [*export*](#export) special built-in. New variables can be defined and initialized with variable assignments, with the [*read*](../utilities/read.html) or [*getopts*](../utilities/getopts.html) utilities, with the *name* parameter in a **for** loop, with the \${*name*=*word*} expansion, or with other mechanisms provided as implementation extensions.\

The following variables shall affect the execution of the shell:

*ENV*

<sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The processing of the *ENV* shell variable shall be supported if the system supports the User Portability Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

This variable, when and only when an interactive shell is invoked, shall be subjected to parameter expansion (see [2.6.2 Parameter Expansion](#tag_19_06_02)) by the shell and the resulting value shall be used as a pathname of a file. Before any interactive commands are read, the shell shall tokenize (see [2.3 Token Recognition](#tag_19_03)) the contents of the file, parse the tokens as a *program* (see [2.10 Shell Grammar](#tag_19_10)), and execute the resulting commands in the current environment. (In other words, the contents of the *ENV* file are not parsed as a single *compound_list*. This distinction matters because it influences when aliases take effect.) The file need not be executable. If the expanded value of *ENV* is not an absolute pathname, the results are unspecified. *ENV* shall be ignored if the user's real and effective user IDs or real and effective group IDs are different.

*HOME*

The pathname of the user's home directory. The contents of *HOME* are used in tilde expansion (see [2.6.1 Tilde Expansion](#tag_19_06_01)).

*IFS*

A string treated as a list of characters that is used for field splitting, expansion of the `'*'` special parameter, and to split lines into fields with the [*read*](../utilities/read.html) utility. If the value of *IFS* includes any bytes that do not form part of a valid character, the results of field splitting, expansion of `'*'`, and use of the [*read*](../utilities/read.html) utility are unspecified.

If *IFS* is not set, it shall behave as normal for an unset variable, except that field splitting by the shell and line splitting by the [*read*](../utilities/read.html) utility shall be performed as if the value of *IFS* is \<space\>\<tab\>\<newline\>; see [2.6.5 Field Splitting](#tag_19_06_05).

The shell shall set *IFS* to \<space\>\<tab\>\<newline\> when it is invoked.

*LANG*

Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)

*LC_ALL*

The value of this variable overrides the *LC\_\** variables and *LANG ,* as described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08).

*LC_COLLATE*

Determine the behavior of range expressions, equivalence classes, and multi-character collating elements within pattern matching.

*LC_CTYPE*

Determine the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters), which characters are defined as letters (character class **alpha**) and \<blank\> characters (character class **blank**), and the behavior of character classes within pattern matching. Changing the value of *LC_CTYPE* after the shell has started shall not affect the lexical processing of shell commands in the current shell execution environment or its subshells. Invoking a shell script or performing [*exec*](#exec) [*sh*](../utilities/sh.html) subjects the new shell to the changes in *LC_CTYPE .*

*LC_MESSAGES*

Determine the language in which messages should be written.

*LINENO*

<sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The processing of the *LINENO* shell variable shall be supported if the system supports the User Portability Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

Set by the shell to a decimal number representing the current sequential line number (numbered starting with 1) within a script or function before it executes each command. If the user unsets or resets *LINENO ,* the variable may lose its special meaning for the life of the shell. If the shell is not currently executing a script or function, the value of *LINENO* is unspecified.

*NLSPATH*

<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of message catalogs for the processing of *LC_MESSAGES .* <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

*PATH*

A string formatted as described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), used to effect command interpretation; see [2.9.1.4 Command Search and Execution](#tag_19_09_01_04).

*PPID*

Set by the shell to the decimal value of its parent process ID during initialization of the shell. In a subshell (see [2.13 Shell Execution Environment](#tag_19_13)), *PPID* shall be set to the same value as that of the parent of the current shell. For example, [*echo*](../utilities/echo.html) \$*PPID* and ([*echo*](../utilities/echo.html) \$*PPID )* would produce the same value.

*PS1*

<sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The processing of the *PS1* shell variable shall be supported if the system supports the User Portability Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

Each time an interactive shell is ready to read a command, the value of this variable shall be subjected to parameter expansion (see [2.6.2 Parameter Expansion](#tag_19_06_02)) and exclamation-mark expansion (see below). Whether the value is also subjected to command substitution (see [2.6.3 Command Substitution](#tag_19_06_03)) or arithmetic expansion (see [2.6.4 Arithmetic Expansion](#tag_19_06_04)) or both is unspecified. After expansion, the value shall be written to standard error.

The expansions shall be performed in two passes, where the result of the first pass is input to the second pass. One of the passes shall perform only the exclamation-mark expansion described below. The other pass shall perform the other expansion(s) according to the rules in [2.6 Word Expansions](#tag_19_06). Which of the two passes is performed first is unspecified.

The default value shall be `"$ "`. For users who have specific additional implementation-defined privileges, the default may be another, implementation-defined value.

Exclamation-mark expansion: The shell shall replace each instance of the \<exclamation-mark\> character (`'!'`) with the history file number (see [*Command History List*](../utilities/sh.html#tag_20_110_13_01)) of the next command to be typed. An \<exclamation-mark\> character escaped by another \<exclamation-mark\> character (that is, `"!!"`) shall expand to a single \<exclamation-mark\> character.

*PS2*

<sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The processing of the *PS2* shell variable shall be supported if the system supports the User Portability Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

Each time the user enters a \<newline\> prior to completing a command line in an interactive shell, the value of this variable shall be subjected to parameter expansion (see [2.6.2 Parameter Expansion](#tag_19_06_02)). Whether the value is also subjected to command substitution (see [2.6.3 Command Substitution](#tag_19_06_03)) or arithmetic expansion (see [2.6.4 Arithmetic Expansion](#tag_19_06_04)) or both is unspecified. After expansion, the value shall be written to standard error. The default value shall be `"> "`.

*PS4*

<sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The processing of the *PS4* shell variable shall be supported if the system supports the User Portability Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

When an execution trace ([*set*](#set) **-x**) is being performed, before each line in the execution trace, the value of this variable shall be subjected to parameter expansion (see [2.6.2 Parameter Expansion](#tag_19_06_02)). Whether the value is also subjected to command substitution (see [2.6.3 Command Substitution](#tag_19_06_03)) or arithmetic expansion (see [2.6.4 Arithmetic Expansion](#tag_19_06_04)) or both is unspecified. After expansion, the value shall be written to standard error. The default value shall be `"+ "`.

*PWD*

Set by the shell and by the [*cd*](../utilities/cd.html) utility. In the shell the value shall be initialized from the environment as follows. If a value for *PWD* is passed to the shell in the environment when it is executed, the value is an absolute pathname of the current working directory that is no longer than {PATH_MAX} bytes including the terminating null byte, and the value does not contain any components that are dot or dot-dot, then the shell shall set *PWD* to the value from the environment. Otherwise, if a value for *PWD* is passed to the shell in the environment when it is executed, the value is an absolute pathname of the current working directory, and the value does not contain any components that are dot or dot-dot, then it is unspecified whether the shell sets *PWD* to the value from the environment or sets *PWD* to the pathname that would be output by [*pwd*](../utilities/pwd.html) **-P**. Otherwise, the [*sh*](../utilities/sh.html) utility sets *PWD* to the pathname that would be output by [*pwd*](../utilities/pwd.html) **-P**. In cases where *PWD* is set to the value from the environment, the value can contain components that refer to files of type symbolic link. In cases where *PWD* is set to the pathname that would be output by [*pwd*](../utilities/pwd.html) **-P**, if there is insufficient permission on the current working directory, or on any parent of that directory, to determine what that pathname would be, the value of *PWD* is unspecified. Assignments to this variable may be ignored. If an application sets or unsets the value of *PWD ,* the behaviors of the [*cd*](../utilities/cd.html) and [*pwd*](../utilities/pwd.html) utilities are unspecified.

### <span id="tag_19_06"></span>2.6 Word Expansions

This section describes the various expansions that are performed on words. Not all expansions are performed on every word, as explained in the following sections and elsewhere in this chapter. The expansions that are performed for a given word shall be performed in the following order:

1.  Tilde expansion (see [2.6.1 Tilde Expansion](#tag_19_06_01)), parameter expansion (see [2.6.2 Parameter Expansion](#tag_19_06_02)), command substitution (see [2.6.3 Command Substitution](#tag_19_06_03) ), and arithmetic expansion (see [2.6.4 Arithmetic Expansion](#tag_19_06_04)) shall be performed, beginning to end. See item 5 in [2.3 Token Recognition](#tag_19_03).
2.  Field splitting (see [2.6.5 Field Splitting](#tag_19_06_05)) shall be performed on the portions of the fields generated by step 1.
3.  Pathname expansion (see [2.6.6 Pathname Expansion](#tag_19_06_06)) shall be performed, unless [*set*](#set) **-f** is in effect.
4.  Quote removal (see [2.6.7 Quote Removal](#tag_19_06_07)), if performed, shall always be performed last.

Tilde expansions, parameter expansions, command substitutions, arithmetic expansions, and quote removals that occur within a single word shall expand to a single field, except as described below. The shell shall create multiple fields or no fields from a single word only as a result of field splitting, pathname expansion, or the following cases:

1.  Parameter expansion of the special parameters `'@'` and `'*'`, as described in [2.5.2 Special Parameters](#tag_19_05_02), can create multiple fields or no fields from a single word.

2.  When the expansion occurs in a context where field splitting will be performed, a word that contains all of the following somewhere within it, before any expansions are applied, in the order specified:

    - an unquoted \<left-curly-bracket\> (`'{'`) that is not immediately preceded by an unquoted \<dollar-sign\> (`'$'`)
    - one or more unquoted \<comma\> (`','`) characters or a sequence that consists of two adjacent \<period\> (`'.'`) characters surrounded by other characters (which can also be \<period\> characters)
    - an unquoted \<right-curly-bracket\> (`'}'`)

    may be subject to an additional implementation-defined form of expansion that can create multiple fields from a single word. This expansion, if supported, shall be applied before all the other word expansions are applied. The other expansions shall then be applied to each field that results from this expansion.

When the expansions in this section are performed other than in the context of preparing a command for execution, they shall be carried out in the current shell execution environment.

When expanding words for a command about to be executed, and the word will be the command name or an argument to the command, the expansions shall be carried out in the current shell execution environment. (The environment for the command to be executed is unknown until the command word is known.)

When expanding the words in a command about to be executed that are used with variable assignments or redirections, it is unspecified whether the expansions are carried out in the current execution environment or in the environment of the command about to be executed.

The `'$'` character is used to introduce parameter expansion, command substitution, or arithmetic evaluation. If a `'$'` that is neither within single-quotes nor escaped by a \<backslash\> is immediately followed by a character that is not a \<space\>, not a \<tab\>, not a \<newline\>, and is not one of the following:

- A numeric character
- The name of one of the special parameters (see [2.5.2 Special Parameters](#tag_19_05_02))
- A valid first character of a variable name
- A \<left-curly-bracket\> (`'{'`)
- A \<left-parenthesis\>
- A single-quote

the result is unspecified. If a `'$'` that is neither within single-quotes nor escaped by a \<backslash\> is immediately followed by a \<space\>, \<tab\>, or a \<newline\>, or is not followed by any character, the `'$'` shall be treated as a literal character.

#### <span id="tag_19_06_01"></span>2.6.1 Tilde Expansion

A "tilde-prefix" consists of an unquoted \<tilde\> character at the beginning of a word, followed by all of the characters preceding the first unquoted \<slash\> in the word, or all the characters in the word if there is no \<slash\>. In an assignment (see XBD [*4.26 Variable Assignment*](../basedefs/V1_chap04.html#tag_04_26)), multiple tilde-prefixes can be used: one at the beginning of the word (that is, following the \<equals-sign\> of the assignment), or one following any unquoted \<colon\>, or both. A tilde-prefix in an assignment is terminated by the first unquoted \<colon\> or \<slash\>, or the end of the assignment word.

If the tilde-prefix consists of only the \<tilde\> character, it shall be replaced by the value of the variable *HOME .* If *HOME* is unset, the results are unspecified.

Otherwise, the characters in the tilde-prefix following the \<tilde\> shall be treated as a possible login name from the user database. If these characters do not form a portable login name (see the description of the *LOGNAME* environment variable in XBD [*8.3 Other Environment Variables*](../basedefs/V1_chap08.html#tag_08_03)), the results are unspecified.

**Note:**  
Since the tilde-prefix is not subject to further word expansions after the \<tilde\> is removed to obtain the login name, none of the following has a portable login name following the \<tilde\>:


    ~"string"
    ~'string'
    ~$var
    ~\/bin

owing to the presence of `'"'`, `'\''`, `'$'`, `'\\'`, and `'/'` characters in the login name.

If the characters in the tilde-prefix following the \<tilde\> form a portable login name, the tilde-prefix shall be replaced by a pathname of the initial working directory associated with the login name. The pathname shall be obtained as if by using the [*getpwnam*()](../functions/getpwnam.html) function as defined in the System Interfaces volume of POSIX.1-2024. If the system does not recognize the login name, the results are unspecified.

The pathname that replaces the tilde-prefix shall be treated as if quoted to prevent it being altered by field splitting and pathname expansion; if a \<slash\> follows the tilde-prefix and the pathname ends with a \<slash\>, the trailing \<slash\> from the pathname should be omitted from the replacement. If the word being expanded consists of only the \<tilde\> character and *HOME* is set to the null string, this produces an empty field (as opposed to zero fields) as the expanded word.

**Note:**  
A future version of this standard may require that if a \<slash\> follows the tilde-prefix and the pathname ends with a \<slash\>, the trailing \<slash\> from the pathname is omitted from the replacement.

#### <span id="tag_19_06_02"></span>2.6.2 Parameter Expansion

The format for parameter expansion is as follows:


    ${expression}

where *expression* consists of all characters until the matching `'}'`. Any `'}'` escaped by a \<backslash\> or within a quoted string, and characters in embedded arithmetic expansions, command substitutions, and variable expansions, shall not be examined in determining the matching `'}'`.

The simplest form for parameter expansion is:


    ${parameter}

The value, if any, of *parameter* shall be substituted.

The parameter name or symbol can be enclosed in braces, which are optional except for positional parameters with more than one digit or when *parameter* is a name and is followed by a character that could be interpreted as part of the name.

For a parameter that is not enclosed in braces:

- If the parameter is a name, the expansion shall use the longest valid name (see XBD [*3.216 Name*](../basedefs/V1_chap03.html#tag_03_216)), whether or not the variable denoted by that name exists.
- Otherwise, the parameter is a single-character symbol, and behavior is unspecified if that character is neither a digit nor one of the special parameters (see [2.5.2 Special Parameters](#tag_19_05_02)).

In addition, a parameter expansion can be modified by using one of the following formats. In each case that a value of *word* is needed (based on the state of *parameter*, as described below), *word* shall be subjected to tilde expansion, parameter expansion, command substitution, arithmetic expansion, and quote removal. If *word* is not needed, it shall not be expanded. The `'}'` character that delimits the following parameter expansion modifications shall be determined as described previously in this section and in [2.2.3 Double-Quotes](#tag_19_02_03). If *parameter* is `'*'` or `'@'`, the result of the expansion is unspecified.

\${*parameter*:-**\[***word***\]**}

**Use Default Values**. If *parameter* is unset or null, the expansion of *word* (or an empty string if *word* is omitted) shall be substituted; otherwise, the value of *parameter* shall be substituted.

\${*parameter*:=**\[***word***\]**}

**Assign Default Values**. If *parameter* is unset or null, quote removal shall be performed on the expansion of *word* and the result (or an empty string if *word* is omitted) shall be assigned to *parameter*. In all cases, the final value of *parameter* shall be substituted. Only variables, not positional parameters or special parameters, can be assigned in this way.

\${*parameter*:?**\[***word***\]**}

**Indicate Error if Null or Unset**. If *parameter* is unset or null, the expansion of *word* (or a message indicating it is unset if *word* is omitted) shall be written to standard error and the shell exits with a non-zero exit status. Otherwise, the value of *parameter* shall be substituted. An interactive shell need not exit.

\${*parameter*:+**\[***word***\]**}

**Use Alternative Value**. If *parameter* is unset or null, null shall be substituted; otherwise, the expansion of *word* (or an empty string if *word* is omitted) shall be substituted.

In the parameter expansions shown previously, use of the \<colon\> in the format shall result in a test for a parameter that is unset or null; omission of the \<colon\> shall result in a test for a parameter that is only unset. If parameter is `'#'` and the colon is omitted, the application shall ensure that *word* is specified (this is necessary to avoid ambiguity with the string length expansion). The following table summarizes the effect of the \<colon\>:\

| ** ** | ***parameter* Set and Not Null** | ***parameter* Set But Null** | ***parameter* Unset** |
|:---|:---|:---|:---|
| **\${***parameter***:-***word***}** | substitute *parameter* | substitute *word* | substitute *word* |
| **\${***parameter***-***word***}** | substitute *parameter* | substitute null | substitute *word* |
| **\${***parameter***:=***word***}** | substitute *parameter* | assign *word* | assign *word* |
| **\${***parameter***=***word***}** | substitute *parameter* | substitute null | assign *word* |
| **\${***parameter***:?***word***}** | substitute *parameter* | error, exit | error, exit |
| **\${***parameter***?***word***}** | substitute *parameter* | substitute null | error, exit |
| **\${***parameter***:+***word***}** | substitute *word* | substitute null | substitute null |
| **\${***parameter***+***word***}** | substitute *word* | substitute *word* | substitute null |

In all cases shown with "substitute", the expression is replaced with the value shown. In all cases shown with "assign", *parameter* is assigned that value, which also replaces the expression.

\${#*parameter*}

**String Length**. The shortest decimal representation of the length in characters of the value of *parameter* shall be substituted. If *parameter* is `'*'` or `'@'`, the result of the expansion is unspecified. If *parameter* is unset and [*set*](#set) **-u** is in effect, the expansion shall fail.

The following four varieties of parameter expansion provide for character substring processing. In each case, pattern matching notation (see [2.14 Pattern Matching Notation](#tag_19_14)), rather than regular expression notation, shall be used to evaluate the patterns. If *parameter* is `'#'`, `'*'`, or `'@'`, the result of the expansion is unspecified. If *parameter* is unset and [*set*](#set) **-u** is in effect, the expansion shall fail. Enclosing the full parameter expansion string in double-quotes shall not cause the following four varieties of pattern characters to be quoted, whereas quoting characters within the braces shall have this effect. In each variety, if *word* is omitted, the empty pattern shall be used.

\${*parameter*%**\[***word***\]**}

**Remove Smallest Suffix Pattern**. The *word* shall be expanded to produce a pattern. The parameter expansion shall then result in *parameter*, with the smallest portion of the suffix matched by the *pattern* deleted. If present, *word* shall not begin with an unquoted `'%'`.

\${*parameter*%%**\[***word***\]**}

**Remove Largest Suffix Pattern**. The *word* shall be expanded to produce a pattern. The parameter expansion shall then result in *parameter*, with the largest portion of the suffix matched by the *pattern* deleted.

\${*parameter*\#**\[***word***\]**}

**Remove Smallest Prefix Pattern**. The *word* shall be expanded to produce a pattern. The parameter expansion shall then result in *parameter*, with the smallest portion of the prefix matched by the *pattern* deleted. If present, *word* shall not begin with an unquoted `'#'`.

\${*parameter*\##**\[***word***\]**}

**Remove Largest Prefix Pattern**. The *word* shall be expanded to produce a pattern. The parameter expansion shall then result in *parameter*, with the largest portion of the prefix matched by the *pattern* deleted.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

##### <span id="tag_19_06_02_01"></span>Examples

\${*parameter*}

\
In this example, the effects of omitting braces are demonstrated.


    a=1
    set 2
    echo ${a}b-$ab-${1}0-${10}-$10
    1b--20--20

\${*parameter*-*word*}

\
This example demonstrates the difference between unset and set to the empty string, as well as the rules for finding the delimiting close brace.

> 
>     foo=asdf
>     echo ${foo-bar}xyz}
>     asdfxyz}
>     foo=
>     echo ${foo-bar}xyz}
>     xyz}
>     unset foo
>     echo ${foo-bar}xyz}
>     barxyz}

\${*parameter*:-*word*}

\
In this example, [*ls*](../utilities/ls.html) is executed only if *x* is null or unset. (The \$([*ls*](../utilities/ls.html)) command substitution notation is explained in [2.6.3 Command Substitution](#tag_19_06_03).)


    ${x:-$(ls)}

\${*parameter*:=*word*}


    unset X
    echo ${X:=abc}
    abc

\${*parameter*:?*word*}


    unset posix
    echo ${posix:?}
    sh: posix: parameter null or not set

\${*parameter*:+*word*}


    set a b c
    echo ${3:+posix}
    posix

\${#*parameter*}


    HOME=/usr/posix
    echo ${#HOME}
    10

\${*parameter*%*word*}


    x=file.c
    echo ${x%.c}.o
    file.o

\${*parameter*%%*word*}


    x=posix/src/std
    echo ${x%%/*}
    posix

\${*parameter*\#*word*}


    x=$HOME/src/cmd
    echo ${x#$HOME}
    /src/cmd

\${*parameter*\##*word*}


    x=/one/two/three
    echo ${x##*/}
    three

The double-quoting of patterns is different depending on where the double-quotes are placed:

`"${x#*}"`

The \<asterisk\> is a pattern character.

`${x#"*"}`

The literal \<asterisk\> is quoted and not special.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

#### <span id="tag_19_06_03"></span>2.6.3 Command Substitution

Command substitution allows the output of one or more commands to be substituted in place of the commands themselves. Command substitution shall occur when command(s) are enclosed as follows:


    $(commands)

or (backquoted version):


    `commands`

The shell shall expand the command substitution by executing *commands* in a subshell environment (see [2.13 Shell Execution Environment](#tag_19_13)) and replacing the command substitution (the text of the *commands* string plus the enclosing `"$()"` or backquotes) with the standard output of the command(s); if the output ends with one or more bytes that have the encoded value of a \<newline\> character, they shall not be included in the replacement. Any such bytes that occur elsewhere shall be included in the replacement; however, they might be treated as field delimiters and eliminated during field splitting, depending on the value of *IFS* and quoting that is in effect. If the output contains any null bytes, the behavior is unspecified.

Within the backquoted style of command substitution, if the command substitution is not within double-quotes, \<backslash\> shall retain its literal meaning, except when followed by: `'$'`, `` '`' ``, or \<backslash\>. See [2.2.3 Double-Quotes](#tag_19_02_03) for the handling of \<backslash\> when the command substitution is within double-quotes. The search for the matching backquote shall be satisfied by the first unquoted non-escaped backquote; during this search, if a non-escaped backquote is encountered within a shell comment, a here-document, an embedded command substitution of the \$(*commands*) form, or a quoted string, undefined results occur. A quoted string that begins, but does not end, within the `` "`...`" `` sequence produces undefined results.

With the \$(*commands*) form, all characters following the open parenthesis to the matching closing parenthesis constitute the *commands* string.

With both the backquoted and \$(*commands*) forms, the *commands* string shall be tokenized (see [2.3 Token Recognition](#tag_19_03)) and parsed (see [2.10 Shell Grammar](#tag_19_10)). It is unspecified whether the *commands* string is parsed and executed incrementally as a *program* (as for a shell script), or is parsed as a single *compound_list* that is executed after the string has been completely parsed. In addition, it is unspecified whether the terminating `')'` of the \$(*commands*) form can result from alias substitution. With the \$(*commands*) form any syntactically correct *program* can be used for *commands*, except that:

- If the *commands* string consists solely of redirections, the results are unspecified.
- If the *commands* string is parsed as a single *compound_list*, before any commands are executed, [*alias*](../utilities/alias.html) and [*unalias*](../utilities/unalias.html) commands in *commands* have no effect during parsing (see [2.3.1 Alias Substitution](#tag_19_03_01)). Strictly conforming applications shall ensure that the *commands* string does not depend on alias changes taking effect incrementally as would be the case if parsed and executed as a *program*.
- The behavior is unspecified if the terminating `')'` is not present in the token containing the command substitution; that is, if the `')'` is expected to result from alias substitution.

The results of command substitution shall not be processed for further tilde expansion, parameter expansion, command substitution, or arithmetic expansion.

Command substitution can be nested. To specify nesting within the backquoted version, the application shall precede the inner backquotes with \<backslash\> characters; for example:


    \`commands\`

The syntax of the shell command language has an ambiguity for expansions beginning with `"$(("`, which can introduce an arithmetic expansion or a command substitution that starts with a subshell. Arithmetic expansion has precedence; that is, the shell shall first determine whether it can parse the expansion as an arithmetic expansion and shall only parse the expansion as a command substitution if it determines that it cannot parse the expansion as an arithmetic expansion. The shell need not evaluate nested expansions when performing this determination. If it encounters the end of input without already having determined that it cannot parse the expansion as an arithmetic expansion, the shell shall treat the expansion as an incomplete arithmetic expansion and report a syntax error. A conforming application shall ensure that it separates the `"$("` and `'('` into two tokens (that is, separate them with white space) in a command substitution that starts with a subshell. For example, a command substitution containing a single subshell could be written as:


    $( (commands) )

#### <span id="tag_19_06_04"></span>2.6.4 Arithmetic Expansion

Arithmetic expansion provides a mechanism for evaluating an arithmetic expression and substituting its value. The format for arithmetic expansion shall be as follows:


    $((expression))

The expression shall be treated as if it were in double-quotes, except that a double-quote inside the expression is not treated specially. The shell shall expand all tokens in the expression for parameter expansion, command substitution, and quote removal.

Next, the shell shall treat this as an arithmetic expression and substitute the value of the expression. The arithmetic expression shall be processed according to the rules given in [*1.1.2.1 Arithmetic Precision and Operations*](../utilities/V3_chap01.html#tag_18_01_02_01), with the following exceptions:

- Only signed long integer arithmetic is required.
- Only the decimal-constant, octal-constant, and hexadecimal-constant constants specified in the ISO C standard, Section 6.4.4.1 are required to be recognized as constants.
- The *sizeof*() operator and the prefix and postfix `"++"` and `"--"` operators are not required.
- Selection, iteration, and jump statements are not supported.

All changes to variables in an arithmetic expression shall be in effect after the arithmetic expansion, as in the parameter expansion `"${x=value}"`.

If the shell variable *x* contains a value that forms a valid integer constant, optionally including a leading \<plus-sign\> or \<hyphen-minus\>, then the arithmetic expansions `"$((x))"` and `"$(($x))"` shall return the same value.

As an extension, the shell may recognize arithmetic expressions beyond those listed. The shell may use a signed integer type with a rank larger than the rank of **signed long**. The shell may use a real-floating type instead of **signed long** as long as it does not affect the results in cases where there is no overflow. If the expression is invalid, or the contents of a shell variable used in the expression are not recognized by the shell, the expansion fails and the shell shall write a diagnostic message to standard error indicating the failure.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

##### <span id="tag_19_06_04_01"></span>Examples

A simple example using arithmetic expansion:


    # repeat a command 100 times
    x=100
    while [ $x -gt 0 ]
    do
        command
        x=$(($x-1))
    done

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

#### <span id="tag_19_06_05"></span>2.6.5 Field Splitting

After parameter expansion ( [2.6.2 Parameter Expansion](#tag_19_06_02)), command substitution ( [2.6.3 Command Substitution](#tag_19_06_03)), and arithmetic expansion ( [2.6.4 Arithmetic Expansion](#tag_19_06_04)), if the shell variable *IFS* (see [2.5.3 Shell Variables](#tag_19_05_03)) is set and its value is not empty, or if *IFS* is unset, the shell shall scan each field containing results of expansions and substitutions that did not occur in double-quotes for field splitting; zero, one or multiple fields can result.

For the remainder of this section, any reference to the results of an expansion, or results of expansions, shall be interpreted to mean the results from one or more unquoted variable or arithmetic expansions, or unquoted command substitutions.

If the *IFS* variable is set and has an empty string as its value, no field splitting shall occur. However, if an input field which contained the results of an expansion is entirely empty, it shall be removed. Note that this occurs before quote removal; any input field that contains any quoting characters can never be empty at this point. After the removal of any such fields from the input, the possibly modified input field list shall become the output.

Each input field shall be considered in sequence, first to last, with the results of the algorithm described in this section causing output fields to be generated, which shall remain in the same order as the input fields from which they originated.

Fields which contain no results from expansions shall not be affected by field splitting, and shall remain unaltered, simply moving from the list of input fields to be next in the list of output fields.

In the remainder of this description, it is assumed that there is present in the field at least one expansion result; this assumption will not be restated. Field splitting only ever alters those parts of the field.

For the purposes of this section, the term "*IFS* white space" is used to mean any of the white-space bytes (see XBD [*3.413 White Space*](../basedefs/V1_chap03.html#tag_03_413), [*3.414 White-Space Byte*](../basedefs/V1_chap03.html#tag_03_414), and [*3.415 White-Space Character*](../basedefs/V1_chap03.html#tag_03_415)) \<space\>, \<tab\>, or \<newline\> from the portable character set (see XBD [*6.1 Portable Character Set*](../basedefs/V1_chap06.html#tag_06_01)) which are present in the value of the *IFS* variable, and perhaps other white-space characters. It is implementation-defined whether other white-space characters which appear in the value of *IFS* are also considered as "*IFS* white space". The three characters above specified as *IFS* white-space bytes are always *IFS* white space, when they occur in the value of *IFS ,* regardless of whether they are white-space characters in any relevant locale. For other locale-specific white-space characters allowed by the implementation it is unspecified whether the character is considered as *IFS* white space if it is white space at the time it is assigned to the *IFS* variable, or if it is white space at the time field splitting occurs. (The locale might have changed between those events.)

If the *IFS* variable is unset, then for the purposes of this section, but without altering the value of the variable, its value shall be considered to contain the three single-byte characters \<space\>, \<tab\>, and \<newline\> from the portable character set, all of which are *IFS* white-space characters.

The shell shall use the byte sequences that form the characters in the value of the *IFS* variable as delimiters. Each of the characters \<space\>, \<tab\>, and \<newline\> which appears in the value of *IFS* shall be a single-byte delimiter. The shell shall use these delimiters as field terminators to split the results of expansions, along with other adjacent bytes, into separate fields, as described below. Note that these delimiters terminate a field; they do not, of themselves, cause a new field to start—subsequent bytes that are not from the results of an expansion, or that do not form *IFS* white-space characters are required for a new field to begin.

Note that the shell processes arbitrary bytes from the input fields; there is no requirement that those bytes form valid characters.

If the results of the algorithm are that no fields are delimited; that is, if the input field is wholly empty or consists entirely of *IFS* white space, the result shall be zero fields (rather than an empty field).

For the purposes of this section, when a field is said to be delimited, then the candidate field, as generated below shall become an output field. When the algorithm transforms a candidate into an output field it shall be appended to the current list of output fields.

Each field containing the results from an expansion shall be processed in order, intermixed with fields not containing the results of expansions, processed as described above, as if by using the following algorithm, examining bytes in the input field, from beginning to end:

- Begin with an empty candidate field and the input as specified above.
- When instructed to start the next iteration of the loop, this is the start of the loop. While the input (as modified by earlier iterations of this loop) is not empty:
  - Consider the leading remaining byte or byte sequence of the input. No such byte sequence shall contain data such that some bytes in the sequence resulted from an expansion, and others did not, nor which contains bytes resulting from the results of more than one expansion. If the byte or sequence of bytes is:

    1.  A byte (or sequence of bytes) in the input which did not result from an expansion:

        Append this byte (or sequence) to the candidate, and remove it from the input. Start the next iteration of the loop.

    2.  A byte sequence in the input which resulted from an expansion and which does not form a character in *IFS :*

        Append the first byte of the sequence to the candidate, and remove that byte from the input. Start the next iteration of the loop.

    3.  A byte sequence in the input which resulted from an expansion and which forms an *IFS* white space character:

        Remove that byte sequence from the input, consider the new leading input byte sequence, and repeat this step.

    4.  A byte sequence in the input which resulted from an expansion and which forms an *IFS* character that is not *IFS* white space:

        Remove that byte sequence from the input, but note it was observed.

    At this point, if the candidate is not empty, or if a sequence of bytes representing an *IFS* character that is not *IFS* white space was seen at step 4, then a field is said to have been delimited, and the candidate shall become an output field.

  - Empty (clear) the candidate, and start the next iteration of the loop.
- Once the input is empty, the candidate shall become an output field if and only if it is not empty.

The ordered list of output fields so produced, which might be empty, shall replace the list of input fields.

#### <span id="tag_19_06_06"></span>2.6.6 Pathname Expansion

After field splitting, if [*set*](#set) **-f** is not in effect, each field in the resulting command line shall be expanded using the algorithm described in [2.14 Pattern Matching Notation](#tag_19_14), qualified by the rules in [2.14.3 Patterns Used for Filename Expansion](#tag_19_14_03).

#### <span id="tag_19_06_07"></span>2.6.7 Quote Removal

The quote character sequence \<dollar-sign\> single-quote and the single-character quote characters (\<backslash\>, single-quote, and double-quote) that were present in the original word shall be removed unless they have themselves been quoted. Note that the single-quote character that terminates a \<dollar-sign\> single-quote sequence is itself a single-character quote character.

**Note:**  
After quote removal the shell still remembers which characters were quoted. This is necessary for purposes such as matching patterns in a **case** conditional construct (see [2.9.4.3 Case Conditional Construct](#tag_19_09_04_05) and [2.14 Pattern Matching Notation](#tag_19_14)).

### <span id="tag_19_07"></span>2.7 Redirection

Redirection is used to open and close files for the current shell execution environment (see [2.13 Shell Execution Environment](#tag_19_13)) or for any command. Redirection operators can be used with numbers representing file descriptors (see XBD [*3.141 File Descriptor*](../basedefs/V1_chap03.html#tag_03_141)) as described below.

The overall format used for redirection is:


    [n]redir-op word

The number *n* is an optional one or more digit decimal number designating the file descriptor number; the application shall ensure it is delimited from any preceding text and immediately precedes the redirection operator *redir-op* (with no intervening \<blank\> characters allowed). If *n* is quoted, the number shall not be recognized as part of the redirection expression. For example:


    echo \2>a

writes the character 2 into file **a**. If any part of *redir-op* is quoted, no redirection expression is recognized. For example:


    echo 2\>a

writes the characters 2\>*a* to standard output. The optional number, redirection operator, and *word* shall not appear in the arguments provided to the command to be executed (if any).

The shell may support an additional format used for redirection:


    {location}redir-op word

where *location* is non-empty and indicates a location where an integer value can be stored, such as the name of a shell variable. If this format is supported its behavior is implementation-defined.

The largest file descriptor number supported in shell redirections is implementation-defined; however, all implementations shall support at least 0 to 9, inclusive, for use by the application.

If the redirection operator is `"<<"` or `"<<-"`, the word that follows the redirection operator shall be subjected to quote removal; it is unspecified whether any of the other expansions occur. For the other redirection operators, the word that follows the redirection operator shall be subjected to tilde expansion, parameter expansion, command substitution, arithmetic expansion, and quote removal. Pathname expansion shall not be performed on the word by a non-interactive shell; an interactive shell may perform it, but if the expansion would result in more than one word it is unspecified whether the redirection proceeds without pathname expansion being performed or the redirection fails.

**Note:**  
A future version of this standard may require that the redirection fails in this case.

If more than one redirection operator is specified with a command, the order of evaluation is from beginning to end.

A failure to open or create a file shall cause a redirection to fail.

#### <span id="tag_19_07_01"></span>2.7.1 Redirecting Input

Input redirection shall cause the file whose name results from the expansion of *word* to be opened for reading on the designated file descriptor, or standard input if the file descriptor is not specified.

The general format for redirecting input is:


    [n]<word

where the optional *n* represents the file descriptor number. If the number is omitted, the redirection shall refer to standard input (file descriptor 0).

#### <span id="tag_19_07_02"></span>2.7.2 Redirecting Output

The two general formats for redirecting output are:


    [n]>word
    [n]>|word

where the optional *n* represents the file descriptor number. If the number is omitted, the redirection shall refer to standard output (file descriptor 1).

Output redirection using the `'>'` format shall fail if the *noclobber* option is set (see the description of [*set*](#set) **-C**) and the file named by the expansion of *word* exists and is either a regular file or a symbolic link that resolves to a regular file; it may also fail if the file is a symbolic link that does not resolve to an existing file. The check for existence, file creation, and open operations shall be performed atomically as is done by the [*open*()](../functions/open.html) function as defined in System Interfaces volume of POSIX.1-2024 when the O_CREAT and O_EXCL flags are set, except that if the file exists and is a symbolic link, the open operation need not fail with \[EEXIST\] unless the symbolic link resolves to an existing regular file. Performing these operations atomically ensures that the creation of lock files and unique (often temporary) files is reliable, with important caveats detailed in [*C.2.7.2 Redirecting Output*](../xrat/V4_xcu_chap01.html#tag_23_02_07_02). The check for the type of the file need not be performed atomically with the check for existence, file creation, and open operations. If not, there is a potential race condition that may result in a misleading shell diagnostic message when redirection fails. See XRAT [*C.2.7.2 Redirecting Output*](../xrat/V4_xcu_chap01.html#tag_23_02_07_02) for more details.

In all other cases (*noclobber* not set, redirection using `'>'` does not fail for the reasons stated above, or redirection using the `">|"` format), output redirection shall cause the file whose name results from the expansion of *word* to be opened for output on the designated file descriptor, or standard output if none is specified. If the file does not exist, it shall be created as an empty file; otherwise, it shall be opened as if the [*open*()](../functions/open.html) function was called with the O_TRUNC flag set.

#### <span id="tag_19_07_03"></span>2.7.3 Appending Redirected Output

Appended output redirection shall cause the file whose name results from the expansion of word to be opened for output on the designated file descriptor. The file shall be opened as if the [*open*()](../functions/open.html) function as defined in the System Interfaces volume of POSIX.1-2024 was called with the O_APPEND flag set. If the file does not exist, it shall be created.

The general format for appending redirected output is as follows:


    [n]>>word

where the optional *n* represents the file descriptor number. If the number is omitted, the redirection refers to standard output (file descriptor 1).

#### <span id="tag_19_07_04"></span>2.7.4 Here-Document

The redirection operators `"<<"` and `"<<-"` both allow redirection of subsequent lines read by the shell to the input of a command. The redirected lines are known as a "here-document".

The here-document shall be treated as a single word that begins after the next **NEWLINE** token and continues until there is a line containing only the delimiter and a \<newline\>, with no \<blank\> characters in between. Then the next here-document starts, if there is one. For the purposes of locating this terminating line, the end of a *command_string* operand (see [*sh*](../utilities/sh.html#)) shall be treated as a \<newline\> character, and the end of the *commands* string in `$(`*`commands`*`)` and `` ` ``*`commands`*`` ` `` may be treated as a \<newline\>. If the end of input is reached without finding the terminating line, the shell should, but need not, treat this as a redirection error. The format is as follows:


    [n]<<word
        here-document
    delimiter

where the optional *n* represents the file descriptor number. If the number is omitted, the here-document refers to standard input (file descriptor 0). It is unspecified whether the file descriptor is opened as a regular file or some other type of file. Portable applications cannot rely on the file descriptor being seekable (see XSH [*lseek*()](../functions/lseek.html#)).

If any part of *word* is quoted, not counting double-quotes outside a command substitution if the here-document is inside one, the delimiter shall be formed by performing quote removal on *word*, and the here-document lines shall not be expanded. Otherwise:

- The delimiter shall be the *word* itself.
- The removal of \<backslash\>\<newline\> for line continuation (see [2.2.1 Escape Character (Backslash)](#tag_19_02_01)) shall be performed during the search for the trailing delimiter. (As a consequence, the trailing delimiter is not recognized immediately after a \<newline\> that was removed by line continuation.) It is unspecified whether the line containing the trailing delimiter is itself subject to this line continuation.
- All lines of the here-document shall be expanded, when the redirection operator is evaluated but after the trailing delimiter for the here-document has been located, for parameter expansion, command substitution, and arithmetic expansion. If the redirection operator is never evaluated (because the command it is part of is not executed), the here-document shall be read without performing any expansions.
- Any \<backslash\> characters in the input shall behave as the \<backslash\> inside double-quotes (see [2.2.3 Double-Quotes](#tag_19_02_03)). However, the double-quote character (`'"'`) shall not be treated specially within a here-document, except when the double-quote appears within `"$()"`, ``` "``" ```, or `"${}"`.

If the redirection operator is `"<<-"`, all leading \<tab\> characters shall be stripped from input lines after \<backslash\>\<newline\> line continuation (when it applies) has been performed, and from the line containing the trailing delimiter. Stripping of leading \<tab\> characters shall occur as the here-document is read from the shell input (and consequently does not affect any \<tab\> characters that result from expansions).

If more than one `"<<"` or `"<<-"` operator is specified on a line, the here-document associated with the first operator shall be supplied first by the application and shall be read first by the shell.

When a here-document is read from a terminal device and the shell is interactive, it shall write the contents of the variable *PS2*, processed as described in [2.5.3 Shell Variables](#tag_19_05_03), to standard error before reading each line of input until the delimiter has been recognized.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

##### <span id="tag_19_07_04_01"></span>Examples

An example of a here-document follows:


    cat <<eof1; cat <<eof2
    Hi,
    eof1
    Helene.
    eof2

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

#### <span id="tag_19_07_05"></span>2.7.5 Duplicating an Input File Descriptor

The redirection operator:


    [n]<&word

shall duplicate one input file descriptor from another, or shall close one. If *word* evaluates to one or more digits, the file descriptor denoted by *n*, or standard input if *n* is not specified, shall be made to be a copy of the file descriptor denoted by *word*; if the digits in *word* do not represent an already open file descriptor, a redirection error shall result (see [2.8.1 Consequences of Shell Errors](#tag_19_08_01)); if the file descriptor denoted by *word* represents an open file descriptor that is not open for input, a redirection error may result. If *word* evaluates to `'-'`, file descriptor *n*, or standard input if *n* is not specified, shall be closed. Attempts to close a file descriptor that is not open shall not constitute an error. If *word* evaluates to something else, the behavior is unspecified.

#### <span id="tag_19_07_06"></span>2.7.6 Duplicating an Output File Descriptor

The redirection operator:


    [n]>&word

shall duplicate one output file descriptor from another, or shall close one. If *word* evaluates to one or more digits, the file descriptor denoted by *n*, or standard output if *n* is not specified, shall be made to be a copy of the file descriptor denoted by *word*; if the digits in *word* do not represent an already open file descriptor, a redirection error shall result (see [2.8.1 Consequences of Shell Errors](#tag_19_08_01)); if the file descriptor denoted by *word* represents an open file descriptor that is not open for output, a redirection error may result. If *word* evaluates to `'-'`, file descriptor *n*, or standard output if *n* is not specified, is closed. Attempts to close a file descriptor that is not open shall not constitute an error. If *word* evaluates to something else, the behavior is unspecified.

#### <span id="tag_19_07_07"></span>2.7.7 Open File Descriptors for Reading and Writing

The redirection operator:


    [n]<>word

shall cause the file whose name is the expansion of *word* to be opened for both reading and writing on the file descriptor denoted by *n*, or standard input if *n* is not specified. If the file does not exist, it shall be created.

### <span id="tag_19_08"></span>2.8 Exit Status and Errors

#### <span id="tag_19_08_01"></span>2.8.1 Consequences of Shell Errors

Certain errors shall cause the shell to write a diagnostic message to standard error and exit as shown in the following table:

<table data-border="1" data-cellpadding="3" data-align="center">
<colgroup>
<col style="width: 25%" />
<col style="width: 25%" />
<col style="width: 25%" />
<col style="width: 25%" />
</colgroup>
<thead>
<tr data-valign="top">
<th style="text-align: center;"><p><strong>Error</strong></p></th>
<th style="text-align: center;"><p><strong>Non-Interactive<br />
Shell</strong></p></th>
<th style="text-align: center;"><p><strong>Interactive Shell</strong></p></th>
<th style="text-align: center;"><p><strong>Shell Diagnostic<br />
Message Required</strong></p></th>
</tr>
</thead>
<tbody>
<tr data-valign="top">
<td style="text-align: left;"><p>Shell language syntax error</p></td>
<td style="text-align: left;"><p>shall exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Special built-in utility error</p></td>
<td style="text-align: left;"><p>shall exit<sup><span class="small">1</span></sup></p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>no<sup><span class="small">2</span></sup></p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Other utility (not a special<br />
built-in) error</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>no<sup><span class="small">3</span></sup></p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Redirection error with<br />
special built-in utilities</p></td>
<td style="text-align: left;"><p>shall exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Redirection error with<br />
compound commands</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Redirection error with<br />
function execution</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Redirection error with other<br />
utilities (not special built-ins)</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Variable assignment error</p></td>
<td style="text-align: left;"><p>shall exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Expansion error</p></td>
<td style="text-align: left;"><p>shall exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Command not found</p></td>
<td style="text-align: left;"><p>may exit</p></td>
<td style="text-align: left;"><p>shall not exit</p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Unrecoverable read error<br />
when reading commands</p></td>
<td style="text-align: left;"><p>shall exit<sup><span class="small">4</span></sup></p></td>
<td style="text-align: left;"><p>shall exit<sup><span class="small">4</span></sup></p></td>
<td style="text-align: left;"><p>yes</p></td>
</tr>
</tbody>
</table>

Notes:

1.  The shell shall exit only if the special built-in utility is executed directly. If it is executed via the [*command*](../utilities/command.html) utility, the shell shall not exit.
2.  Although special built-ins are part of the shell, a diagnostic message written by a special built-in is not considered to be a shell diagnostic message, and can be redirected like any other utility.
3.  The shell is not required to write a diagnostic message, but the utility itself shall write a diagnostic message if required to do so.
4.  If an unrecoverable read error occurs when reading commands, other than from the *file* operand of the [*dot*](#dot) special built-in, the shell shall execute no further commands (including any already successfully read but not yet executed) other than any specified in a previously defined EXIT [*trap*](#trap) action. An unrecoverable read error while reading from the *file* operand of the [*dot*](#dot) special built-in shall be treated as a special built-in utility error.

An expansion error is one that occurs when the shell expansions defined in [2.6 Word Expansions](#tag_19_06) are carried out (for example, `"${x!y}"`, because `'!'` is not a valid operator); an implementation may treat these as syntax errors if it is able to detect them during tokenization, rather than during expansion.

If any of the errors shown as "shall exit" or "may exit" occur in a subshell environment, the shell shall (respectively, may) exit from the subshell environment with a non-zero status and continue in the environment from which that subshell environment was invoked.

In all of the cases shown in the table where an interactive shell is required not to exit and a non-interactive shell is required to exit, an interactive shell shall not perform any further processing of the command in which the error occurred.

#### <span id="tag_19_08_02"></span>2.8.2 Exit Status for Commands

Each command has an exit status that can influence the behavior of other shell commands. The exit status of commands that are not utilities is documented in this section. The exit status of the standard utilities is documented in their respective sections.

The exit status of a command shall be determined as follows:

- If the command is not found, the exit status shall be 127.
- Otherwise, if the command name is found, but it is not an executable utility, the exit status shall be 126.
- Otherwise, if the command terminated due to the receipt of a signal, the shell shall assign it an exit status greater than 128. The exit status shall identify, in an implementation-defined manner, which signal terminated the command. Note that shell implementations are permitted to assign an exit status greater than 255 if a command terminates due to a signal.
- Otherwise, the exit status shall be the value obtained by the equivalent of the WEXITSTATUS macro applied to the status obtained by the [*wait*()](../functions/wait.html) function (as defined in the System Interfaces volume of POSIX.1-2024). Note that for C programs, this value is equal to the result of performing a modulo 256 operation on the value passed to [*\_Exit*()](../functions/_Exit.html), [*\_exit*()](../functions/_exit.html), or [*exit*()](../functions/exit.html) or returned from *main*().

### <span id="tag_19_09"></span>2.9 Shell Commands

This section describes the basic structure of shell commands. The following command descriptions each describe a format of the command that is only used to aid the reader in recognizing the command type, and does not formally represent the syntax. In particular, the representations include spacing between tokens in some places where \<blank\>s would not be necessary (when one of the tokens is an operator). Each description discusses the semantics of the command; for a formal definition of the command language, consult [2.10 Shell Grammar](#tag_19_10).

A *command* is one of the following:

- Simple command (see [2.9.1 Simple Commands](#tag_19_09_01))
- Pipeline (see [2.9.2 Pipelines](#tag_19_09_02))
- List compound-list (see [2.9.3 Lists](#tag_19_09_03))
- Compound command (see [2.9.4 Compound Commands](#tag_19_09_04))
- Function definition (see [2.9.5 Function Definition Command](#tag_19_09_05))

Unless otherwise stated, the exit status of a command shall be that of the last simple command executed by the command. There shall be no limit on the size of any shell command other than that imposed by the underlying system (memory constraints, {ARG_MAX}, and so on).

#### <span id="tag_19_09_01"></span>2.9.1 Simple Commands

A "simple command" is a sequence of optional variable assignments and redirections, in any sequence, optionally followed by words and redirections.

##### <span id="tag_19_09_01_01"></span>2.9.1.1 Order of Processing

When a given simple command is required to be executed (that is, when any conditional construct such as an AND-OR list or a **case** statement has not bypassed the simple command), the following expansions, assignments, and redirections shall all be performed from the beginning of the command text to the end:

1.  The words that are recognized as variable assignments or redirections according to [2.10.2 Shell Grammar Rules](#tag_19_10_02) are saved for processing in steps 3 and 4.
2.  The first word (if any) that is not a variable assignment or redirection shall be expanded. If any fields remain following its expansion, the first field shall be considered the command name. If no fields remain, the next word (if any) shall be expanded, and so on, until a command name is found or no words remain. If there is a command name and it is recognized as a declaration utility, then any remaining words after the word that expanded to produce the command name, that would be recognized as a variable assignment in isolation, shall be expanded as a variable assignment (tilde expansion after the first \<equals-sign\> and after any unquoted \<colon\>, parameter expansion, command substitution, arithmetic expansion, and quote removal, but no field splitting or pathname expansion); while remaining words that would not be a variable assignment in isolation shall be subject to regular expansion (tilde expansion for only a leading \<tilde\>, parameter expansion, command substitution, arithmetic expansion, field splitting, pathname expansion, and quote removal). For all other command names, words after the word that produced the command name shall be subject only to regular expansion. All fields resulting from the expansion of the word that produced the command name and the subsequent words, except for the field containing the command name, shall be the arguments for the command.
3.  Redirections shall be performed as described in [2.7 Redirection](#tag_19_07).
4.  Each variable assignment shall be expanded for tilde expansion, parameter expansion, command substitution, arithmetic expansion, and quote removal prior to assigning the value.

In the preceding list, the order of steps 3 and 4 may be reversed if no command name results from step 2 or if the command name matches the name of a special built-in utility; see [2.15 Special Built-In Utilities](#tag_19_15).

When determining whether a command name is a declaration utility, an implementation may use only lexical analysis. It is unspecified whether assignment context will be used if the command name would only become recognized as a declaration utility after word expansions.

##### <span id="tag_19_09_01_02"></span>2.9.1.2 Variable Assignments

Variable assignments shall be performed as follows:

- If no command name results, variable assignments shall affect the current execution environment.
- If the command name is not a special built-in utility or function, the variable assignments shall be exported for the execution environment of the command and shall not affect the current execution environment except as a side-effect of the expansions performed in step 4. In this case it is unspecified:
  - Whether or not the assignments are visible for subsequent expansions in step 4
  - Whether variable assignments made as side-effects of these expansions are visible for subsequent expansions in step 4, or in the current shell execution environment, or both
- If the command name is a standard utility implemented as a function (see XBD [*4.25 Utility*](../basedefs/V1_chap04.html#tag_04_25)), the effect of variable assignments shall be as if the utility was not implemented as a function.
- If the command name is a special built-in utility, variable assignments shall affect the current execution environment before the utility is executed and remain in effect when the command completes; if an assigned variable is further modified by the utility, the modifications made by the utility shall persist. Unless the [*set*](#set) **-a** option is on (see [set](#tag_19_26)), it is unspecified:
  - Whether or not the variables gain the *export* attribute during the execution of the special built-in utility
  - Whether or not *export* attributes gained as a result of the variable assignments persist after the completion of the special built-in utility
- If the command name is a function that is not a standard utility implemented as a function, variable assignments shall affect the current execution environment during the execution of the function. It is unspecified:
  - Whether or not the variable assignments persist after the completion of the function
  - Whether or not the variables gain the *export* attribute during the execution of the function
  - Whether or not *export* attributes gained as a result of the variable assignments persist after the completion of the function (if variable assignments persist after the completion of the function)

If any of the variable assignments attempt to assign a value to a variable for which the *readonly* attribute is set in the current shell environment (regardless of whether the assignment is made in that environment), a variable assignment error shall occur. See [2.8.1 Consequences of Shell Errors](#tag_19_08_01) for the consequences of these errors.

##### <span id="tag_19_09_01_03"></span>2.9.1.3 Commands with no Command Name

If a simple command has no command name after word expansion (see [2.9.1.1 Order of Processing](#tag_19_09_01_01)), any redirections shall be performed in a subshell environment; it is unspecified whether this subshell environment is the same one as that used for a command substitution within the command. (To affect the current execution environment, see the [exec](#tag_19_21) special built-in.) If any of the redirections performed in the current shell execution environment fail, the command shall immediately fail with an exit status greater than zero, and the shell shall write an error message indicating the failure. See [2.8.1 Consequences of Shell Errors](#tag_19_08_01) for the consequences of these failures on interactive and non-interactive shells.

Additionally, if there is no command name but the command contains a command substitution, the command shall complete with the exit status of the command substitution whose exit status was the last to be obtained. Otherwise, the command shall complete with a zero exit status.

##### <span id="tag_19_09_01_04"></span>2.9.1.4 Command Search and Execution

If a simple command has a command name and an optional list of arguments after word expansion (see [2.9.1.1 Order of Processing](#tag_19_09_01_01)), the following actions shall be performed:

1.  If the command name does not contain any \<slash\> characters, the first successful step in the following sequence shall occur:
    1.  If the command name matches the name of a special built-in utility, that special built-in utility shall be invoked.
    2.  If the command name matches the name of a utility listed in the following table, the results are unspecified.
        <table data-cellpadding="3" data-align="center">
        <colgroup>
        <col style="width: 20%" />
        <col style="width: 20%" />
        <col style="width: 20%" />
        <col style="width: 20%" />
        <col style="width: 20%" />
        </colgroup>
        <tbody>
        <tr data-valign="top">
        <td style="text-align: left;"><p><br />
        <em>alloc</em><br />
        <em>autoload</em><br />
        <em>bind</em><br />
        <em>bindkey</em><br />
        <em>builtin</em><br />
        <em>bye</em><br />
        <em>caller</em><br />
        <em>cap</em><br />
        <em>chdir</em><br />
        <em>clone</em><br />
        <em>comparguments</em><br />
         </p></td>
        <td style="text-align: left;"><p><br />
        <em>compcall</em><br />
        <em>compctl</em><br />
        <em>compdescribe</em><br />
        <em>compfiles</em><br />
        <em>compgen</em><br />
        <em>compgroups</em><br />
        <em>complete</em><br />
        <em>compound</em><br />
        <em>compquote</em><br />
        <em>comptags</em><br />
        <em>comptry</em><br />
         </p></td>
        <td style="text-align: left;"><p><br />
        <em>compvalues</em><br />
        <em>declare</em><br />
        <em>dirs</em><br />
        <em>disable</em><br />
        <em>disown</em><br />
        <em>dosh</em><br />
        <em>echotc</em><br />
        <em>echoti</em><br />
        <em>enum</em><br />
        <em>float</em><br />
        <em>help</em><br />
         </p></td>
        <td style="text-align: left;"><p><br />
        <em>history</em><br />
        <em>hist</em><br />
        <em>integer</em><br />
        <em>let</em><br />
        <em>local</em><br />
        <em>login</em><br />
        <em>logout</em><br />
        <em>map</em><br />
        <em>mapfile</em><br />
        <em>nameref</em><br />
        <em>popd</em><br />
         </p></td>
        <td style="text-align: left;"><p><br />
        <em>print</em><br />
        <em>pushd</em><br />
        <em>readarray</em><br />
        <em>repeat</em><br />
        <em>savehistory</em><br />
        <em>source</em><br />
        <em>shopt</em><br />
        <em>stop</em><br />
        <em>suspend</em><br />
        <em>typeset</em><br />
        <em>whence</em><br />
         </p></td>
        </tr>
        </tbody>
        </table>
    3.  If the command name matches the name of a function known to this shell, the function shall be invoked as described in [2.9.5 Function Definition Command](#tag_19_09_05). If the implementation has provided a standard utility in the form of a function, and that function definition still exists (i.e. has not been removed using [*unset*](#unset) **-f** or replaced via another function definition with the same name), it shall not be recognized at this point. It shall be invoked in conjunction with the path search in step 1e.
    4.  If the command name matches the name of an intrinsic utility (see [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07)), that utility shall be invoked.
    5.  Otherwise, the command shall be searched for using the *PATH* environment variable as described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08):
        1.  If the search is successful:

            1.  If the system has implemented the utility as a built-in or as a shell function, and the built-in or function is associated with the directory that was most recently tested during the successful *PATH* search, that built-in or function shall be invoked.
            2.  Otherwise, the shell shall execute a non-built-in utility as described in [2.9.1.6 Non-built-in Utility Execution](#tag_19_09_01_06).

            Once a utility has been searched for and found (either as a result of this specific search or as part of an unspecified shell start-up activity), an implementation may remember its location and need not search for the utility again unless the *PATH* variable has been the subject of an assignment. If the remembered location fails for a subsequent invocation, the shell shall repeat the search to find the new location for the utility, if any.

        2.  If the search is unsuccessful, the command shall fail with an exit status of 127 and the shell shall write an error message.
2.  If the command name contains at least one \<slash\>, the shell shall execute a non-built-in utility as described in [2.9.1.6 Non-built-in Utility Execution](#tag_19_09_01_06).

##### <span id="tag_19_09_01_05"></span>2.9.1.5 Standard File Descriptors

If the utility would be executed with file descriptor 0, 1, or 2 closed, implementations may execute the utility with the file descriptor open to an unspecified file. If a standard utility or a conforming application is executed with file descriptor 0 not open for reading or with file descriptor 1 or 2 not open for writing, the environment in which the utility or application is executed shall be deemed non-conforming, and consequently the utility or application might not behave as described in this standard.

##### <span id="tag_19_09_01_06"></span>2.9.1.6 Non-built-in Utility Execution

When the shell executes a non-built-in utility, if the execution is not being made via the [*exec*](#exec) special built-in utility, the shell shall execute the utility in a separate utility environment (see [2.13 Shell Execution Environment](#tag_19_13)).

If the execution is being made via the [*exec*](#exec) special built-in utility, the shell shall not create a separate utility environment for this execution; the new process image shall replace the current shell execution environment. If the current shell environment is a subshell environment, the new process image shall replace the subshell environment and the shell shall continue in the environment from which that subshell environment was invoked.

In either case, execution of the utility in the specified environment shall be performed as follows:

1.  If the command name does not contain any \<slash\> characters, the command name shall be searched for using the *PATH* environment variable as described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08):
    1.  If the search is successful, the shell shall execute the utility with actions equivalent to calling the [*execl*()](../functions/execl.html) function as defined in the System Interfaces volume of POSIX.1-2024 with the *path* argument set to the pathname resulting from the search, *arg0* set to the command name, and the remaining [*execl*()](../functions/execl.html) arguments set to the command arguments (if any) and the null terminator.

        If the [*execl*()](../functions/execl.html) function fails due to an error equivalent to the \[ENOEXEC\] error defined in the System Interfaces volume of POSIX.1-2024, the shell shall execute a command equivalent to having a shell invoked with the pathname resulting from the search as its first operand, with any remaining arguments passed to the new shell, except that the value of `"$0"` in the new shell may be set to the command name. The shell may apply a heuristic check to determine if the file to be executed could be a script and may bypass this command execution if it determines that the file cannot be a script. In this case, it shall write an error message, and the command shall fail with an exit status of 126.

        **Note:**  
        A common heuristic for rejecting files that cannot be a script is locating a NUL byte prior to a \<newline\> byte within a fixed-length prefix of the file. Since [*sh*](../utilities/sh.html) is required to accept input files with unlimited line lengths, the heuristic check cannot be based on line length.

        It is unspecified whether environment variables that were passed to the shell when it was invoked, but were not used to initialize shell variables (see [2.5.3 Shell Variables](#tag_19_05_03)) because they had invalid names, are included in the environment passed to [*execl*()](../functions/execl.html) and (if [*execl*()](../functions/execl.html) fails as described above) to the new shell.

    2.  If the search is unsuccessful, the command shall fail with an exit status of 127 and the shell shall write an error message.
2.  If the command name contains at least one \<slash\>:
    1.  If the named utility exists, the shell shall execute the utility with actions equivalent to calling the [*execl*()](../functions/execl.html) function defined in the System Interfaces volume of POSIX.1-2024 with the *path* and *arg0* arguments set to the command name, and the remaining [*execl*()](../functions/execl.html) arguments set to the command arguments (if any) and the null terminator.

        If the [*execl*()](../functions/execl.html) function fails due to an error equivalent to the \[ENOEXEC\] error, the shell shall execute a command equivalent to having a shell invoked with the command name as its first operand, with any remaining arguments passed to the new shell. The shell may apply a heuristic check to determine if the file to be executed could be a script and may bypass this command execution if it determines that the file cannot be a script. In this case, it shall write an error message, and the command shall fail with an exit status of 126.

        **Note:**  
        A common heuristic for rejecting files that cannot be a script is locating a NUL byte prior to a \<newline\> byte within a fixed-length prefix of the file. Since [*sh*](../utilities/sh.html) is required to accept input files with unlimited line lengths, the heuristic check cannot be based on line length.

        It is unspecified whether environment variables that were passed to the shell when it was invoked, but were not used to initialize shell variables (see [2.5.3 Shell Variables](#tag_19_05_03)) because they had invalid names, are included in the environment passed to [*execl*()](../functions/execl.html) and (if [*execl*()](../functions/execl.html) fails as described above) to the new shell.

    2.  If the named utility does not exist, the command shall fail with an exit status of 127 and the shell shall write an error message.

#### <span id="tag_19_09_02"></span>2.9.2 Pipelines

A *pipeline* is a sequence of one or more commands separated by the control operator `'|'`. For each command but the last, the shell shall connect the standard output of the command to the standard input of the next command as if by creating a pipe and passing the write end of the pipe as the standard output of the command and the read end of the pipe as the standard input of the next command.

The format for a pipeline is:


    [!] command1 [ | command2 ...]

If the pipeline begins with the reserved word **!** and *command1* is a subshell command, the application shall ensure that the **(** operator at the beginning of *command1* is separated from the **!** by one or more \<blank\> characters. The behavior of the reserved word **!** immediately followed by the **(** operator is unspecified.

The standard output of *command1* shall be connected to the standard input of *command2*. The standard input, standard output, or both of a command shall be considered to be assigned by the pipeline before any redirection specified by redirection operators that are part of the command (see [2.7 Redirection](#tag_19_07)).

If the pipeline is not in the background (see [2.9.3.1 Asynchronous AND-OR Lists](#tag_19_09_03_02) and [2.11 Job Control](#tag_19_11)), the shell shall wait for the last command specified in the pipeline to complete, and may also wait for all commands to complete.

##### <span id="tag_19_09_02_01"></span>Exit Status

The exit status of a pipeline shall depend on whether or not the *pipefail* option (see [set](#tag_19_26)) is enabled and whether or not the pipeline begins with the **!** reserved word, as described in the following table. The *pipefail* option determines which command in the pipeline the exit status is derived from; the **!** reserved word causes the exit status to be the logical NOT of the exit status of that command. The shell shall use the *pipefail* setting at the time it begins execution of the pipeline, not the setting at the time it sets the exit status of the pipeline. (For example, in `command1 | set -o pipefail` the exit status of `command1` has no effect on the exit status of the pipeline, even if the shell executes `set -o pipefail` in the current shell environment.)

| **pipefail Enabled** | **Begins with !** | **Exit Status** |
|:---|:---|:---|
| no | no | The exit status of the last (rightmost) command specified in the pipeline. |
| no | yes | Zero, if the last (rightmost) command in the pipeline returned a non-zero exit status; otherwise, 1. |
| yes | no | Zero, if all commands in the pipeline returned an exit status of 0; otherwise, the exit status of the last (rightmost) command specified in the pipeline that returned a non-zero exit status. |
| yes | yes | Zero, if any command in the pipeline returned a non-zero exit status; otherwise, 1. |

#### <span id="tag_19_09_03"></span>2.9.3 Lists

An *AND-OR list* is a sequence of one or more pipelines separated by the operators `"&&"` and `"||"`.

A *list* is a sequence of one or more AND-OR lists separated by the operators `';'` and `'&'`.

The operators `"&&"` and `"||"` shall have equal precedence and shall be evaluated with left associativity. For example, both of the following commands write solely **bar** to standard output:


    false && echo foo || echo bar
    true || echo foo && echo bar

A `';'` separator or a `';'` or \<newline\> terminator shall cause the preceding AND-OR list to be executed sequentially; an `'&'` separator or terminator shall cause asynchronous execution of the preceding AND-OR list.

The term "compound-list" is derived from the grammar in [2.10 Shell Grammar](#tag_19_10); it is equivalent to a sequence of *lists*, separated by \<newline\> characters, that can be preceded or followed by an arbitrary number of \<newline\> characters.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

##### <span id="tag_19_09_03_01"></span>Examples

The following is an example that illustrates \<newline\> characters in compound-lists:


    while
        # a couple of <newline>s


        # a list
        date && who || ls; cat file
        # a couple of <newline>s


        # another list
        wc file > output & true


    do
        # 2 lists
        ls
        cat file
    done

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

##### <span id="tag_19_09_03_02"></span>2.9.3.1 Asynchronous AND-OR Lists

If an AND-OR list is terminated by the control operator \<ampersand\> (`'&'`), the shell shall execute the AND-OR list asynchronously in a subshell environment. This subshell shall execute in the background; that is, the shell shall not wait for the subshell to terminate before executing the next command (if any); if there are no further commands to execute, the shell shall not wait for the subshell to terminate before exiting.

If job control is enabled (see [set](#tag_19_26), **-m**), the AND-OR list shall become a job-control background job and a job number shall be assigned to it. If job control is disabled, the AND-OR list may become a non-job-control background job, in which case a job number shall be assigned to it; if no job number is assigned it shall become a background command but not a background job.

A job-control background job can be controlled as described in [2.11 Job Control](#tag_19_11).

The process ID associated with the asynchronous AND-OR list shall become known in the current shell execution environment; see [2.13 Shell Execution Environment](#tag_19_13). This process ID shall remain known until any one of the following occurs (and, unless otherwise specified, may continue to remain known after it occurs).

- The process terminates and the application waits for the process ID or the corresponding job ID (see [*wait*](../utilities/wait.html#tag_20_147)).
- If the asynchronous AND-OR list did not become a background job: another asynchronous AND-OR list is invoked before `"$!"` (corresponding to the previous asynchronous AND-OR list) is expanded in the current shell execution environment.
- If the asynchronous AND-OR list became a background job: the [*jobs*](../utilities/jobs.html) utility reports the termination status of that job.
- If the shell is interactive and the asynchronous AND-OR list became a background job: a message indicating completion of the corresponding job is written to standard error. If [*set*](#set) **-b** is enabled, it is unspecified whether the process ID is removed from the list of known process IDs when the message is written or immediately prior to when the shell writes the next prompt for input.

The implementation need not retain more than the {CHILD_MAX} most recent entries in its list of known process IDs in the current shell execution environment.

If, and only if, job control is disabled, the standard input for the subshell in which an asynchronous AND-OR list is executed shall initially be assigned to an open file description that behaves as if **/dev/null** had been opened for reading only. This initial assignment shall be overridden by any explicit redirection of standard input within the AND-OR list.

If the shell is interactive and the asynchronous AND-OR list became a background job, the job number and the process ID associated with the job shall be written to standard error using the format:


    "[%d] %d\n", <job-number>, <process-id>

If the shell is interactive and the asynchronous AND-OR list did not become a background job, the process ID associated with the asynchronous AND-OR list shall be written to standard error in an unspecified format.

##### <span id="tag_19_09_03_03"></span>Exit Status

The exit status of an asynchronous AND-OR list shall be zero.

The exit status of the subshell in which the AND-OR list is asynchronously executed can be obtained using the [*wait*](../utilities/wait.html) utility.

##### <span id="tag_19_09_03_04"></span>2.9.3.2 Sequential AND-OR Lists

AND-OR lists that are separated by a \<semicolon\> (`';'`) shall be executed sequentially. The format for executing AND-OR lists sequentially shall be:


    aolist1 [; aolist2] ...

Each AND-OR list shall be expanded and executed in the order specified.

If job control is enabled, the AND-OR lists shall form all or part of a foreground job that can be controlled as described in [2.11 Job Control](#tag_19_11).

##### <span id="tag_19_09_03_05"></span>Exit Status

The exit status of a sequential AND-OR list shall be the exit status of the last pipeline in the AND-OR list that is executed.

##### <span id="tag_19_09_03_06"></span>2.9.3.3 AND Lists

The control operator `"&&"` denotes an AND list. The format shall be:


    command1 [ && command2] ...

First *command1* shall be executed. If its exit status is zero, *command2* shall be executed, and so on, until a command has a non-zero exit status or there are no more commands left to execute. The commands are expanded only if they are executed.

##### <span id="tag_19_09_03_07"></span>Exit Status

The exit status of an AND list shall be the exit status of the last command that is executed in the list.

##### <span id="tag_19_09_03_08"></span>2.9.3.4 OR Lists

The control operator `"||"` denotes an OR List. The format shall be:


    command1 [ || command2] ...

First, *command1* shall be executed. If its exit status is non-zero, *command2* shall be executed, and so on, until a command has a zero exit status or there are no more commands left to execute.

##### <span id="tag_19_09_03_09"></span>Exit Status

The exit status of an OR list shall be the exit status of the last command that is executed in the list.

#### <span id="tag_19_09_04"></span>2.9.4 Compound Commands

The shell has several programming constructs that are "compound commands", which provide control flow for commands. Each of these compound commands has a reserved word or control operator at the beginning, and a corresponding terminator reserved word or operator at the end. In addition, each can be followed by redirections on the same line as the terminator. Each redirection shall apply to all the commands within the compound command that do not explicitly override that redirection.

In the descriptions below, the exit status of some compound commands is stated in terms of the exit status of a *compound-list*. The exit status of a *compound-list* shall be the value that the special parameter `'?'` (see [2.5.2 Special Parameters](#tag_19_05_02)) would have immediately after execution of the *compound-list*.

##### <span id="tag_19_09_04_01"></span>2.9.4.1 Grouping Commands

The format for grouping commands is as follows:

( *compound-list* )

Execute *compound-list* in a subshell environment; see [2.13 Shell Execution Environment](#tag_19_13). Variable assignments and built-in commands that affect the environment shall not remain in effect after the list finishes.

If a character sequence beginning with `"(("` would be parsed by the shell as an arithmetic expansion if preceded by a `'$'`, shells which implement an extension whereby `"((`*`expression`*`))"` is evaluated as an arithmetic expression may treat the `"(("` as introducing as an arithmetic evaluation instead of a grouping command. A conforming application shall ensure that it separates the two leading `'('` characters with white space to prevent the shell from performing an arithmetic evaluation.

{ *compound-list* ; }

Execute *compound-list* in the current process environment. The semicolon shown here is an example of a control operator delimiting the **}** reserved word. Other delimiters are possible, as shown in [2.10 Shell Grammar](#tag_19_10); a \<newline\> is frequently used.

##### <span id="tag_19_09_04_02"></span>Exit Status

The exit status of a grouping command shall be the exit status of *compound-list*.

##### <span id="tag_19_09_04_03"></span>2.9.4.2 The for Loop

The **for** loop shall execute a sequence of commands for each member in a list of *items*. The **for** loop requires that the reserved words **do** and **done** be used to delimit the sequence of commands.

The format for the **for** loop is as follows:


    for name [ in [word ... ]]
    do
        compound-list
    done

First, the list of words following **in** shall be expanded to generate a list of items. Then, the variable *name* shall be set to each item, in turn, and the *compound-list* executed each time. If no items result from the expansion, the *compound-list* shall not be executed. Omitting:


    in word ...

shall be equivalent to:


    in "$@"

##### <span id="tag_19_09_04_04"></span>Exit Status

If there is at least one item in the list of items, the exit status of a **for** command shall be the exit status of the last *compound-list* executed. If there are no items, the exit status shall be zero.

##### <span id="tag_19_09_04_05"></span>2.9.4.3 Case Conditional Construct

The conditional construct **case** shall execute the *compound-list* corresponding to the first *pattern* (see [2.14 Pattern Matching Notation](#tag_19_14)), if any are present, that is matched by the string resulting from the tilde expansion, parameter expansion, command substitution, arithmetic expansion, and quote removal of the given word. The reserved word **in** shall denote the beginning of the patterns to be matched. Multiple patterns with the same *compound-list* shall be delimited by the `'|'` symbol. The control operator `')'` terminates a list of patterns corresponding to a given action. The terminated pattern list and the following *compound-list* is called a **case** statement *clause*. Each **case** statement clause, with the possible exception of the last, shall be terminated with either `";;"` or `";&"`. The **case** construct terminates with the reserved word **esac** (**case** reversed).\

The format for the **case** construct is as follows:


    case word in
        [[(] pattern[ | pattern] ... ) compound-list terminator] ...
        [[(] pattern[ | pattern] ... ) compound-list]
    esac

Where *terminator* is either `";;"` or `";&"` and is optional for the last *compound-list*.

In order from the beginning to the end of the **case** statement, each *pattern* that labels a *compound-list* shall be subjected to tilde expansion, parameter expansion, command substitution, and arithmetic expansion, and the result of these expansions shall be compared against the expansion of *word*, according to the rules described in [2.14 Pattern Matching Notation](#tag_19_14) (which also describes the effect of quoting parts of the pattern). After the first match, no more patterns in the **case** statement shall be expanded, and the *compound-list* of the matching clause shall be executed. If the **case** statement clause is terminated by `";;"`, no further clauses shall be examined. If the **case** statement clause is terminated by `";&"`, then the *compound-list* (if any) of each subsequent clause shall be executed, in order, until either a clause terminated by `";;"` is reached and its *compound-list* (if any) executed or there are no further clauses in the **case** statement. The order of expansion and comparison of multiple *pattern*s that label a *compound-list* statement is unspecified.

##### <span id="tag_19_09_04_06"></span>Exit Status

The exit status of **case** shall be zero if no patterns are matched. Otherwise, the exit status shall be the exit status of the *compound-list* of the last clause to be executed.

##### <span id="tag_19_09_04_07"></span>2.9.4.4 The if Conditional Construct

The **if** command shall execute a *compound-list* and use its exit status to determine whether to execute another *compound-list*.

The format for the **if** construct is as follows:


    if compound-list
    then
        compound-list
    [elif compound-list
    then
        compound-list] ...
    [else
        compound-list]
    fi

The **if** *compound-list* shall be executed; if its exit status is zero, the **then** *compound-list* shall be executed and the command shall complete. Otherwise, each **elif** *compound-list* shall be executed, in turn, and if its exit status is zero, the **then** *compound-list* shall be executed and the command shall complete. Otherwise, the **else** *compound-list* shall be executed.

##### <span id="tag_19_09_04_08"></span>Exit Status

The exit status of the **if** command shall be the exit status of the **then** or **else** *compound-list* that was executed, or zero, if none was executed.

**Note:**  
Although the exit status of the **if** or **elif** *compound-list* is ignored when determining the exit status of the **if** command, it is available through the special parameter `'?'` (see [2.5.2 Special Parameters](#tag_19_05_02)) during execution of the next **then**, **elif**, or **else** *compound-list* (if any is executed) in the normal way.

##### <span id="tag_19_09_04_09"></span>2.9.4.5 The while Loop

The **while** loop shall continuously execute one *compound-list* as long as another *compound-list* has a zero exit status.

The format of the **while** loop is as follows:


    while compound-list-1
    do
        compound-list-2
    done

The *compound-list-1* shall be executed, and if it has a non-zero exit status, the **while** command shall complete. Otherwise, the *compound-list-2* shall be executed, and the process shall repeat.

##### <span id="tag_19_09_04_10"></span>Exit Status

The exit status of the **while** loop shall be the exit status of the last *compound-list-2* executed, or zero if none was executed.

**Note:**  
Since the exit status of *compound-list-1* is ignored when determining the exit status of the **while** command, it is not possible to obtain the status of the command that caused the loop to exit, other than via the special parameter `'?'` (see [2.5.2 Special Parameters](#tag_19_05_02)) during execution of *compound-list-1*, for example:


    while some_command; st=$?; false; do ...

The exit status of *compound-list-1* is available through the special parameter `'?'` during execution of *compound-list-2*, but is known to be zero at that point anyway.

##### <span id="tag_19_09_04_11"></span>2.9.4.6 The until Loop

The **until** loop shall continuously execute one *compound-list* as long as another *compound-list* has a non-zero exit status.

The format of the **until** loop is as follows:


    until compound-list-1
    do
        compound-list-2
    done

The *compound-list-1* shall be executed, and if it has a zero exit status, the **until** command completes. Otherwise, the *compound-list-2* shall be executed, and the process repeats.

##### <span id="tag_19_09_04_12"></span>Exit Status

The exit status of the **until** loop shall be the exit status of the last *compound-list-2* executed, or zero if none was executed.

**Note:**  
Although the exit status of *compound-list-1* is ignored when determining the exit status of the **until** command, it is available through the special parameter `'?'` (see [2.5.2 Special Parameters](#tag_19_05_02)) during execution of *compound-list-2* in the normal way.

#### <span id="tag_19_09_05"></span>2.9.5 Function Definition Command

A function is a user-defined name that is used as a simple command to call a compound command with new positional parameters. A function is defined with a "function definition command".

The format of a function definition command is as follows:


    fname ( ) compound-command [io-redirect ...]

The function is named *fname*; the application shall ensure that it is a name (see XBD [*3.216 Name*](../basedefs/V1_chap03.html#tag_03_216)) and that it is not the name of a special built-in utility. An implementation may allow other characters in a function name as an extension. The implementation shall maintain separate name spaces for functions and variables.

The argument *compound-command* represents a compound command, as described in [2.9.4 Compound Commands](#tag_19_09_04).

When the function is declared, none of the expansions in [2.6 Word Expansions](#tag_19_06) shall be performed on the text in *compound-command* or *io-redirect*; all expansions shall be performed as normal each time the function is called. Similarly, the optional *io-redirect* redirections and any variable assignments within *compound-command* shall be performed during the execution of the function itself, not the function definition. See [2.8.1 Consequences of Shell Errors](#tag_19_08_01) for the consequences of failures of these operations on interactive and non-interactive shells.

When a function is executed, it shall have the syntax-error properties described for special built-in utilities in the first item in the enumerated list at the beginning of [2.15 Special Built-In Utilities](#tag_19_15).

The *compound-command* shall be executed whenever the function name is specified as the name of a simple command (see [2.9.1.4 Command Search and Execution](#tag_19_09_01_04)). The operands to the command temporarily shall become the positional parameters during the execution of the *compound-command*; the special parameter `'#'` also shall be changed to reflect the number of operands. The special parameter 0 shall be unchanged. When the function completes, the values of the positional parameters and the special parameter `'#'` shall be restored to the values they had before the function was executed. If the special built-in [*return*](#return) (see [return](#tag_19_25)) is executed in the *compound-command*, the function completes and execution shall resume with the next command after the function call.

##### <span id="tag_19_09_05_01"></span>Exit Status

The exit status of a function definition shall be zero if the function was declared successfully; otherwise, it shall be greater than zero. The exit status of a function invocation shall be the exit status of the last command executed by the function.

### <span id="tag_19_10"></span>2.10 Shell Grammar

The following grammar defines the Shell Command Language. This formal syntax shall take precedence over the preceding text syntax description.

#### <span id="tag_19_10_01"></span>2.10.1 Shell Grammar Lexical Conventions

The input language to the shell shall be first recognized at the character level. The resulting tokens shall be classified by their immediate context according to the following rules (applied in order). These rules shall be used to determine what a "token" is that is subject to parsing at the token level. The rules for token recognition in [2.3 Token Recognition](#tag_19_03) shall apply.

1.  If the token is an operator, the token identifier for that operator shall result.
2.  If the string consists solely of digits and the delimiter character is one of `'<'` or `'>'`, the token identifier **IO_NUMBER** shall result.
3.  If the string contains at least three characters, begins with a \<left-curly-bracket\> (`'{'`) and ends with a \<right-curly-bracket\> (`'}'`), and the delimiter character is one of `'<'` or `'>'`, the token identifier **IO_LOCATION** may result; if the result is not **IO_LOCATION**, the token identifier **TOKEN** shall result.
4.  Otherwise, the token identifier **TOKEN** shall result.

Further distinction on **TOKEN** is context-dependent. It may be that the same **TOKEN** yields **WORD**, a **NAME**, an **ASSIGNMENT_WORD**, or one of the reserved words below, dependent upon the context. Some of the productions in the grammar below are annotated with a rule number from the following list. When a **TOKEN** is seen where one of those annotated productions could be used to reduce the symbol, the applicable rule shall be applied to convert the token identifier type of the **TOKEN** to:

- The token identifier of the recognized reserved word, for rule 1
- A token identifier acceptable at that point in the grammar, for all other rules

The reduction shall then proceed based upon the token identifier type yielded by the rule applied. When more than one rule applies, the highest numbered rule shall apply (which in turn may refer to another rule). (Note that except in rule 7, the presence of an `'='` in the token has no effect.)

The **WORD** tokens shall have the word expansion rules applied to them immediately before the associated command is executed, not at the time the command is parsed.

#### <span id="tag_19_10_02"></span>2.10.2 Shell Grammar Rules

1.  \[Command Name\]

    When the **TOKEN** is exactly a reserved word, the token identifier for that reserved word shall result. Otherwise, the token **WORD** shall be returned. Also, if the parser is in any state where only a reserved word could be the next correct token, proceed as above.

    **Note:**  
    Because at this point quoting characters (\<backslash\>, single-quote, \<quotation-mark\>, and the \<dollar-sign\> single-quote sequence) are retained in the token, quoted strings cannot be recognized as reserved words. This rule also implies that reserved words are not recognized except in certain positions in the input, such as after a \<newline\> or \<semicolon\>; the grammar presumes that if the reserved word is intended, it is properly delimited by the user, and does not attempt to reflect that requirement directly. Also note that line joining is done before tokenization, as described in [2.2.1 Escape Character (Backslash)](#tag_19_02_01), so escaped \<newline\> characters are already removed at this point.

    Rule 1 is not directly referenced in the grammar, but is referred to by other rules, or applies globally.

2.  \[Redirection to or from filename\]

    The expansions specified in [2.7 Redirection](#tag_19_07) shall occur. As specified there, exactly one field can result (or the result is unspecified), and there are additional requirements on pathname expansion.

3.  \[Redirection from here-document\]

    Quote removal shall be applied to the word to determine the delimiter that is used to find the end of the here-document that begins after the next \<newline\>.

4.  \[Case statement termination\]

    When the **TOKEN** is exactly the reserved word **esac**, the token identifier for **esac** shall result. Otherwise, the token **WORD** shall be returned.

5.  \[**NAME** in **for**\]

    When the **TOKEN** meets the requirements for a name (see XBD [*3.216 Name*](../basedefs/V1_chap03.html#tag_03_216)), the token identifier **NAME** shall result. Otherwise, the token **WORD** shall be returned.

6.  \[Third word of **for** and **case**\]

    1.  \[**case** only\]

        When the **TOKEN** is exactly the reserved word **in**, the token identifier for **in** shall result. Otherwise, the token **WORD** shall be returned.

    2.  \[**for** only\]

        When the **TOKEN** is exactly the reserved word **in** or **do**, the token identifier for **in** or **do** shall result, respectively. Otherwise, the token **WORD** shall be returned.

    (For a. and b.: As indicated in the grammar, a *linebreak* precedes the tokens **in** and **do**. If \<newline\> characters are present at the indicated location, it is the token after them that is treated in this fashion.)

7.  \[Assignment preceding command name\]

    1.  \[When the first word\]

        If the **TOKEN** is exactly a reserved word, the token identifier for that reserved word shall result. Otherwise, 7b shall be applied.

    2.  \[Not the first word\]

        If the **TOKEN** contains an unquoted (as determined while applying rule 4 from [2.3 Token Recognition](#tag_19_03)) \<equals-sign\> character that is not part of an embedded parameter expansion, command substitution, or arithmetic expansion construct (as determined while applying rule 5 from [2.3 Token Recognition](#tag_19_03)):

        - If the **TOKEN** begins with `'='`, then the token **WORD** shall be returned.
        - If all the characters in the **TOKEN** preceding the first such \<equals-sign\> form a valid name (see XBD [*3.216 Name*](../basedefs/V1_chap03.html#tag_03_216)), the token **ASSIGNMENT_WORD** shall be returned.
        - Otherwise, it is implementation-defined whether the token **WORD** or **ASSIGNMENT_WORD** is returned, or the **TOKEN** is processed in some other way.

        Otherwise, the token **WORD** shall be returned.

    If a returned **ASSIGNMENT_WORD** token begins with a valid name, assignment of the value after the first \<equals-sign\> to the name shall occur as specified in [2.9.1 Simple Commands](#tag_19_09_01). If a returned **ASSIGNMENT_WORD** token does not begin with a valid name, the way in which the token is processed is unspecified.

8.  \[**NAME** in function\]

    When the **TOKEN** is exactly a reserved word, the token identifier for that reserved word shall result. Otherwise, when the **TOKEN** meets the requirements for a name, the token identifier **NAME** shall result. Otherwise, rule 7 applies.

9.  \[Body of function\]

    Word expansion and assignment shall never occur, even when required by the rules above, when this rule is being parsed. Each **TOKEN** that might either be expanded or have assignment applied to it shall instead be returned as a single **WORD** consisting only of characters that are exactly the token described in [2.3 Token Recognition](#tag_19_03) .

\


    /* -------------------------------------------------------
       The grammar symbols
       ------------------------------------------------------- */
    %token  WORD
    %token  ASSIGNMENT_WORD
    %token  NAME
    %token  NEWLINE
    %token  IO_NUMBER
    %token  IO_LOCATION

`/* The following are the operators (see XBD `[*`3.243 Operator`*](../basedefs/V1_chap03.html#tag_03_243)`) containing more than one character. */`\




    %token  AND_IF    OR_IF    DSEMI    SEMI_AND
    /*      '&&'      '||'     ';;'     ';&'   */


    %token  DLESS  DGREAT  LESSAND  GREATAND  LESSGREAT  DLESSDASH
    /*      '<<'   '>>'    '<&'     '>&'      '<>'       '<<-'   */


    %token  CLOBBER
    /*      '>|'   */


    /* The following are the reserved words. */


    %token  If    Then    Else    Elif    Fi    Do    Done
    /*      'if'  'then'  'else'  'elif'  'fi'  'do'  'done'   */


    %token  Case    Esac    While    Until    For
    /*      'case'  'esac'  'while'  'until'  'for'   */


    /* These are reserved words, not operator tokens, and are
       recognized when reserved words are recognized. */


    %token  Lbrace    Rbrace    Bang
    /*      '{'       '}'       '!'   */


    %token  In
    /*      'in'   */




    /* -------------------------------------------------------
       The Grammar
       ------------------------------------------------------- */
    %start program
    %%
    program          : linebreak complete_commands linebreak
                     | linebreak
                     ;
    complete_commands: complete_commands newline_list complete_command
                     |                                complete_command
                     ;
    complete_command : list separator_op
                     | list
                     ;
    list             : list separator_op and_or
                     |                   and_or
                     ;
    and_or           :                         pipeline
                     | and_or AND_IF linebreak pipeline
                     | and_or OR_IF  linebreak pipeline
                     ;
    pipeline         :      pipe_sequence
                     | Bang pipe_sequence
                     ;
    pipe_sequence    :                             command
                     | pipe_sequence '|' linebreak command
                     ;
    command          : simple_command
                     | compound_command
                     | compound_command redirect_list
                     | function_definition
                     ;
    compound_command : brace_group
                     | subshell
                     | for_clause
                     | case_clause
                     | if_clause
                     | while_clause
                     | until_clause
                     ;
    subshell         : '(' compound_list ')'
                     ;
    compound_list    : linebreak term
                     | linebreak term separator
                     ;
    term             : term separator and_or
                     |                and_or
                     ;
    for_clause       : For name                                      do_group
                     | For name                       sequential_sep do_group
                     | For name linebreak in          sequential_sep do_group
                     | For name linebreak in wordlist sequential_sep do_group
                     ;
    name             : NAME                     /* Apply rule 5 */
                     ;
    in               : In                       /* Apply rule 6 */
                     ;
    wordlist         : wordlist WORD
                     |          WORD
                     ;
    case_clause      : Case WORD linebreak in linebreak case_list    Esac
                     | Case WORD linebreak in linebreak case_list_ns Esac
                     | Case WORD linebreak in linebreak              Esac
                     ;
    case_list_ns     : case_list case_item_ns
                     |           case_item_ns
                     ;
    case_list        : case_list case_item
                     |           case_item
                     ;
    case_item_ns     : pattern_list ')' linebreak
                     | pattern_list ')' compound_list
                     ;
    case_item        : pattern_list ')' linebreak     DSEMI linebreak
                     | pattern_list ')' compound_list DSEMI linebreak
                     | pattern_list ')' linebreak     SEMI_AND linebreak
                     | pattern_list ')' compound_list SEMI_AND linebreak
                     ;
    pattern_list     :                  WORD    /* Apply rule 4 */
                     |              '(' WORD    /* Do not apply rule 4 */
                     | pattern_list '|' WORD    /* Do not apply rule 4 */
                     ;
    if_clause        : If compound_list Then compound_list else_part Fi
                     | If compound_list Then compound_list           Fi
                     ;
    else_part        : Elif compound_list Then compound_list
                     | Elif compound_list Then compound_list else_part
                     | Else compound_list
                     ;
    while_clause     : While compound_list do_group
                     ;
    until_clause     : Until compound_list do_group
                     ;
    function_definition : fname '(' ')' linebreak function_body
                     ;
    function_body    : compound_command                /* Apply rule 9 */
                     | compound_command redirect_list  /* Apply rule 9 */
                     ;
    fname            : NAME                            /* Apply rule 8 */
                     ;
    brace_group      : Lbrace compound_list Rbrace
                     ;
    do_group         : Do compound_list Done           /* Apply rule 6 */
                     ;
    simple_command   : cmd_prefix cmd_word cmd_suffix
                     | cmd_prefix cmd_word
                     | cmd_prefix
                     | cmd_name cmd_suffix
                     | cmd_name
                     ;
    cmd_name         : WORD                   /* Apply rule 7a */
                     ;
    cmd_word         : WORD                   /* Apply rule 7b */
                     ;
    cmd_prefix       :            io_redirect
                     | cmd_prefix io_redirect
                     |            ASSIGNMENT_WORD
                     | cmd_prefix ASSIGNMENT_WORD
                     ;
    cmd_suffix       :            io_redirect
                     | cmd_suffix io_redirect
                     |            WORD
                     | cmd_suffix WORD
                     ;
    redirect_list    :               io_redirect
                     | redirect_list io_redirect
                     ;
    io_redirect      :             io_file
                     | IO_NUMBER   io_file
                     | IO_LOCATION io_file /* Optionally supported */
                     |             io_here
                     | IO_NUMBER   io_here
                     | IO_LOCATION io_here /* Optionally supported */
                     ;
    io_file          : '<'       filename
                     | LESSAND   filename
                     | '>'       filename
                     | GREATAND  filename
                     | DGREAT    filename
                     | LESSGREAT filename
                     | CLOBBER   filename
                     ;
    filename         : WORD                      /* Apply rule 2 */
                     ;
    io_here          : DLESS     here_end
                     | DLESSDASH here_end
                     ;
    here_end         : WORD                      /* Apply rule 3 */
                     ;
    newline_list     :              NEWLINE
                     | newline_list NEWLINE
                     ;
    linebreak        : newline_list
                     | /* empty */
                     ;
    separator_op     : '&'
                     | ';'
                     ;
    separator        : separator_op linebreak
                     | newline_list
                     ;
    sequential_sep   : ';' linebreak
                     | newline_list
                     ;

### <span id="tag_19_11"></span>2.11 Job Control

Job control is defined (see XBD [*3.181 Job Control*](../basedefs/V1_chap03.html#tag_03_181)) as a facility that allows users selectively to stop (suspend) the execution of processes and continue (resume) their execution at a later point. It is jointly supplied by the terminal I/O driver and a command interpreter. The shell is one such command interpreter and job control in the shell is enabled by [set](#tag_19_26) **-m** (which is enabled by default in interactive shells). The remainder of this section describes the job control facility provided by the shell. Requirements relating to background jobs stated in this section only apply to job-control background jobs.

If the shell has a controlling terminal and it is the controlling process for the terminal session, it shall initially set the foreground process group ID associated with the terminal to its own process group ID. Otherwise, if it has a controlling terminal, it shall initially perform the following steps if interactive and may perform them if non-interactive:

1.  If its process group is the foreground process group associated with the terminal, the shell shall set its process group ID to its process ID (if they are not already equal) and set the foreground process group ID associated with the terminal to its process group ID.
2.  If its process group is not the foreground process group associated with the terminal (which would result from it being started by a job-control shell as a background job), the shell shall either stop itself by sending itself a SIGTTIN signal or, if interactive, attempt to read from standard input (which generates a SIGTTIN signal if standard input is the controlling terminal). If it is stopped, then when it continues execution (after receiving a SIGCONT signal) it shall repeat these steps.

Subsequently, the shell shall change the foreground process group associated with its controlling terminal when a foreground job is running as noted in the description below.

When job control is enabled, the shell shall create one or more jobs when it executes a list (see [2.9.3 Lists](#tag_19_09_03)) that has one of the following forms:

- A single asynchronous AND-OR list
- One or more sequentially executed AND-OR lists followed by at most one asynchronous AND-OR list

For the purposes of job control, a list that includes more than one asynchronous AND-OR list shall be treated as if it were split into multiple separate lists, each ending with an asynchronous AND-OR list.

When a job consisting of a single asynchronous AND-OR list is created, it shall form a *background job* and the associated process ID shall be that of a child process that is made a process group leader, with all other processes (if any) that the shell creates to execute the AND-OR list initially having this process ID as their process group ID.

For a list consisting of one or more sequentially executed AND-OR lists followed by at most one asynchronous AND-OR list, the whole list shall form a single *foreground job* up until the sequentially executed AND-OR lists have all completed execution, at which point the asynchronous AND-OR list (if any) shall form a background job as described above.

For each pipeline in a foreground job, if the pipeline is executed while the list is still a foreground job, the set of processes comprising the pipeline, and any processes descended from it, shall all be in the same process group, unless the shell executes some of the commands in the pipeline in the current shell execution environment and others in a subshell environment; in this case the process group ID of the current shell need not change (or cannot change if it is the session leader), and consequently the process group ID that the other processes all share may differ from the process group ID of the current shell (which means that a SIGSTOP, SIGTSTP, SIGTTIN, or SIGTTOU signal sent to one of those process groups does not cause the whole pipeline to stop).

A background job that was created on execution of an asynchronous AND-OR list can be brought into the foreground by means of the [*fg*](../utilities/fg.html) utility (if supported); in this case the entire job shall become a single foreground job. If a process that the shell subsequently waits for is part of this foreground job and is stopped by a signal, the entire job shall become a suspended job and the behavior shall be as if the process had been stopped while the job was running in the background.

When a foreground job is created, or a background job is brought into the foreground by the [*fg*](../utilities/fg.html) utility, if the shell has a controlling terminal it shall set the foreground process group ID associated with the terminal as follows:

- If the job was originally created as a background job, the foreground process group ID shall be set to the process ID of the process that the shell made a process group leader when it executed the asynchronous AND-OR list.
- If the job was originally created as a foreground job, the foreground process group ID shall be set as follows when each pipeline in the job is executed:
  - If the shell is not itself executing, in the current shell execution environment, all of the commands in the pipeline, the foreground process group ID shall be set to the process group ID that is shared by the other processes executing the pipeline (see above).
  - If all of the commands in the pipeline are being executed by the shell itself in the current shell execution environment, the foreground process group ID shall be set to the process group ID of the shell.

When a foreground job terminates, or becomes a suspended job (see below), if the shell has a controlling terminal it shall set the foreground process group ID associated with the terminal to the process group ID of the shell.

Each background job (whether suspended or not) shall have associated with it a job number and a process ID that is known in the current shell execution environment. When a background job is brought into the foreground by means of the [*fg*](../utilities/fg.html) utility, the associated job number shall be removed from the shell's background jobs list and the associated process ID shall be removed from the list of process IDs known in the current shell execution environment.

If a process that the shell is waiting for is part of a foreground job that was started as a foreground job and is stopped by a catchable signal (SIGTSTP, SIGTTIN, or SIGTTOU):

- If the currently executing AND-OR list within the list comprising the foreground job consists of a single pipeline in which all of the commands are simple commands, the shell shall either create a suspended job consisting of at least that AND-OR list and the remaining (if any) AND-OR lists in the same list, or create a suspended job consisting of just that AND-OR list and discard the remaining (if any) AND-OR lists in the same list.
- Otherwise, the shell shall create a suspended job consisting of a set of commands, from within the list comprising the foreground job, that is unspecified except that the set shall include at least the pipeline to which the stopped process belongs. Commands in the foreground job that have not already completed and are not included in the suspended job shall be discarded.

**Note:**  
Although only a pipeline of simple commands is guaranteed to remain intact if started in the foreground and subsequently suspended, it is possible to ensure that a complex AND-OR list will remain intact when suspended by starting it in the background and immediately bringing it into the foreground. For example:


    command1 && command2 | { command3 || command4; } & fg

If a process that the shell is waiting for is part of a foreground job that was started as a foreground job and is stopped by a SIGSTOP signal, the behavior shall be as described above for a catchable signal unless the shell was executing a built-in utility in the current shell execution environment when the SIGSTOP was delivered, resulting in the shell itself being stopped by the signal, in which case if the shell subsequently receives a SIGCONT signal and has one or more child processes that remain stopped, the shell shall create a suspended job as if only those child processes had been stopped.

When a suspended job is created as a result of a foreground job being stopped, it shall be assigned a job number, and an interactive shell shall write, and a non-interactive shell may write, a message to standard error, formatted as described by the [*jobs*](../utilities/jobs.html) utility (without the **-l** option) for a suspended job. The message may indicate that the commands comprising the job include commands that have already completed; in this case the completed commands shall not be repeated if execution of the job is subsequently continued. If the shell is interactive, it shall save the terminal settings before changing them to the settings it needs to read further commands.

When a process associated with a background job is stopped by a SIGSTOP, SIGTSTP, SIGTTIN, or SIGTTOU signal, the shell shall convert the (non-suspended) background job into a suspended job and an interactive shell shall write a message to standard error, formatted as described by the [*jobs*](../utilities/jobs.html) utility (without the **-l** option) for a suspended job, at the following time:

- If [*set*](#set) **-b** is enabled, the message shall be written either immediately after the job became suspended or immediately prior to writing the next prompt for input.
- If [*set*](#set) **-b** is disabled, the message shall be written immediately prior to writing the next prompt for input.

Execution of a suspended job can be continued as a foreground job by means of the [*fg*](../utilities/fg.html) utility (if supported), or as a (non-suspended) background job either by means of the [*bg*](../utilities/bg.html) utility (if supported) or by sending the stopped processes a SIGCONT signal. The [*fg*](../utilities/fg.html) and [*bg*](../utilities/bg.html) utilities shall send a SIGCONT signal to the process group of the process(es) whose stopped wait status caused the shell to suspend the job. If the shell has a controlling terminal, the [*fg*](../utilities/fg.html) utility shall send the SIGCONT signal after it has set the foreground process group ID associated with the terminal (see above). If the [*fg*](../utilities/fg.html) utility is used from an interactive shell to bring into the foreground a suspended job that was created from a foreground job, before it sends the SIGCONT signal the [*fg*](../utilities/fg.html) utility shall restore the terminal settings to the ones that the shell saved when the job was suspended.

When a background job completes or is terminated by a signal, an interactive shell shall write a message to standard error, formatted as described by the [*jobs*](../utilities/jobs.html) utility (without the **-l** option) for a job that completed or was terminated by a signal, respectively, at the following time:

- If [*set*](#set) **-b** is enabled, the message shall be written immediately after the job completes or is terminated.
- If [*set*](#set) **-b** is disabled, the message shall be written immediately prior to writing the next prompt for input.

In each case above where an interactive shell writes a message immediately prior to writing the next prompt for input, the same message may also be written by a non-interactive shell, at any of the following times:

- After the next time a foreground job terminates or is suspended
- Before the shell parses further input
- Before the shell exits

### <span id="tag_19_12"></span>2.12 Signals and Error Handling

If job control is disabled (see the description of [*set*](#set) **-m**) when the shell executes an asynchronous AND-OR list, the commands in the list shall inherit from the shell a signal action of ignored (SIG_IGN) for the SIGINT and SIGQUIT signals. In all other cases, commands executed by the shell shall inherit the same signal actions as those inherited by the shell from its parent unless a signal action is modified by the [*trap*](#trap) special built-in (see [trap](#tag_19_29))

When a signal for which a trap has been set is received while the shell is waiting for the completion of a utility executing a foreground command, the trap associated with that signal shall not be executed until after the foreground command has completed. When the shell is waiting, by means of the [*wait*](../utilities/wait.html) utility, for asynchronous commands to complete, the reception of a signal for which a trap has been set shall cause the [*wait*](../utilities/wait.html) utility to return immediately with an exit status \>128, immediately after which the trap associated with that signal shall be taken.

If multiple signals are pending for the shell for which there are associated trap actions, the order of execution of trap actions is unspecified.

### <span id="tag_19_13"></span>2.13 Shell Execution Environment

A shell execution environment consists of the following:

- Open files inherited upon invocation of the shell, plus open files controlled by [*exec*](#exec)
- Working directory as set by [*cd*](../utilities/cd.html)
- File creation mask set by [*umask*](../utilities/umask.html)
- File size limit as set by [*ulimit*](../utilities/ulimit.html)
- Current traps set by [*trap*](#trap)
- Shell parameters that are set by variable assignment (see the [set](#tag_19_26) special built-in) or from the System Interfaces volume of POSIX.1-2024 environment inherited by the shell when it begins (see the [export](#tag_19_23) special built-in)
- Shell functions; see [2.9.5 Function Definition Command](#tag_19_09_05)
- Options turned on at invocation or by [*set*](#set)
- Background jobs and their associated process IDs, and process IDs of child processes created to execute asynchronous AND-OR lists while job control is disabled; together these process IDs constitute the process IDs "known to this shell environment". If the implementation supports non-job-control background jobs, the list of known process IDs and the list of background jobs may form a single list even though this standard describes them as being updated separately. See [2.9.3.1 Asynchronous AND-OR Lists](#tag_19_09_03_02)
- Shell aliases; see [2.3.1 Alias Substitution](#tag_19_03_01)

Utilities other than the special built-ins (see [2.15 Special Built-In Utilities](#tag_19_15)) shall be invoked in a separate environment that consists of the following. The initial value of these objects shall be the same as that for the parent shell, except as noted below.

- Open files inherited on invocation of the shell, open files controlled by the [*exec*](#exec) special built-in plus any modifications, and additions specified by any redirections to the utility
- Current working directory
- File creation mask
- If the utility is a shell script, traps caught by the shell shall be set to the default values and traps ignored by the shell shall be set to be ignored by the utility; if the utility is not a shell script, the trap actions (default or ignore) shall be mapped into the appropriate signal handling actions for the utility
- Variables with the [*export*](#export) attribute, along with those explicitly exported for the duration of the command, shall be passed to the utility environment variables
- It is unspecified whether environment variables that were passed to the invoking shell when it was invoked itself, but were not used to initialize shell variables (see [2.5.3 Shell Variables](#tag_19_05_03)) because they had invalid names, are included in the invoked utility's environment.

The environment of the shell process shall not be changed by the utility unless explicitly specified by the utility description (for example, [*cd*](../utilities/cd.html) and [*umask*](../utilities/umask.html)).

A subshell environment shall be created as a duplicate of the shell environment, except that:

- Unless specified otherwise (see [trap](#tag_19_29)), traps that are not being ignored shall be set to the default action.
- If the shell is interactive, the subshell shall behave as a non-interactive shell in all respects except:
  - The expansion of the special parameter `'-'` may continue to indicate that it is interactive.
  - The [*set*](#set) **-n** option may be ignored.

Changes made to the subshell environment shall not affect the shell environment. Command substitution, commands that are grouped with parentheses, and asynchronous AND-OR lists shall be executed in a subshell environment. Additionally, each command of a multi-command pipeline is in a subshell environment; as an extension, however, any or all commands in a pipeline may be executed in the current environment. Except where otherwise stated, all other commands shall be executed in the current shell environment.

### <span id="tag_19_14"></span>2.14 Pattern Matching Notation

The pattern matching notation described in this section is used to specify patterns for matching character strings in the shell. This notation is also used by some other utilities ([*find*](../utilities/find.html), [*pax*](../utilities/pax.html), and optionally [*make*](../utilities/make.html)) and by some system interfaces ([*fnmatch*()](../functions/fnmatch.html), [*glob*()](../functions/glob.html), and [*wordexp*()](../functions/wordexp.html)). Historically, pattern matching notation is related to, but slightly different from, the regular expression notation described in XBD [*9. Regular Expressions*](../basedefs/V1_chap09.html#tag_09). For this reason, the description of the rules for this pattern matching notation are based on the description of regular expression notation, modified to account for the differences.

If an attempt is made to use pattern matching notation to match a string that contains one or more bytes that do not form part of a valid character, the behavior is unspecified. Since pathnames can contain such bytes, portable applications need to ensure that the current locale is the C or POSIX locale when performing pattern matching (or expansion) on arbitrary pathnames.

#### <span id="tag_19_14_01"></span>2.14.1 Patterns Matching a Single Character

The following patterns shall match a single character: ordinary characters, special pattern characters, and pattern bracket expressions. The pattern bracket expression also shall match a single collating element.

In a pattern, or part of one, where a shell-quoting \<backslash\> can be used, a \<backslash\> character shall escape the following character as described in [2.2.1 Escape Character (Backslash)](#tag_19_02_01), regardless of whether or not the \<backslash\> is inside a bracket expression. (The sequence `"\\"` represents one literal \<backslash\>.)

In a pattern, or part of one, where a shell-quoting \<backslash\> cannot be used to preserve the literal value of a character that would otherwise be treated as special:

- A \<backslash\> character that is not inside a bracket expression shall preserve the literal value of the following character, unless the following character is in a part of the pattern where shell quoting can be used and is a shell quoting character, in which case the behavior is unspecified.
- For the shell only, it is unspecified whether or not a \<backslash\> character inside a bracket expression preserves the literal value of the following character.

All of the requirements and effects of quoting on ordinary, shell special, and special pattern characters shall apply to escaping in this context, except where specified otherwise. (Situations where this applies include word expansions when a pattern used in pathname expansion is not present in the original word but results from an earlier expansion, or the argument to the [*find*](../utilities/find.html) -*name* or -*path* primary as passed to [*find*](../utilities/find.html), or the *pattern* argument to the [*fnmatch*()](../functions/fnmatch.html) and [*glob*()](../functions/glob.html) functions when FNM_NOESCAPE or GLOB_NOESCAPE is not set in *flags*, respectively.)

If a pattern ends with an unescaped \<backslash\>, the behavior is unspecified.

An ordinary character is a pattern that shall match itself. In a pattern, or part of one, where a shell-quoting \<backslash\> can be used, an ordinary character can be any character in the supported character set except for NUL, those special shell characters in [2.2 Quoting](#tag_19_02) that require quoting, and the three special pattern characters described below. In a pattern, or part of one, where a shell-quoting \<backslash\> cannot be used to preserve the literal value of a character that would otherwise be treated as special, an ordinary character can be any character in the supported character set except for NUL and the three special pattern characters described below. Matching shall be based on the bit pattern used for encoding the character, not on the graphic representation of the character. If any character (ordinary, shell special, or pattern special) is quoted, or escaped with a \<backslash\>, that pattern shall match the character itself. The application shall ensure that it quotes or escapes any character that would otherwise be treated as special, in order for it to be matched as an ordinary character.

When unquoted, unescaped, and not inside a bracket expression, the following three characters shall have special meaning in the specification of patterns:

`?`

A \<question-mark\> is a pattern that shall match any character.

`*`

An \<asterisk\> is a pattern that shall match multiple characters, as described in [2.14.2 Patterns Matching Multiple Characters](#tag_19_14_02).

`[`

A \<left-square-bracket\> shall introduce a bracket expression if the characters following it meet the requirements for bracket expressions stated in XBD [*9.3.5 RE Bracket Expression*](../basedefs/V1_chap09.html#tag_09_03_05), except that the \<exclamation-mark\> character (`'!'`) shall replace the \<circumflex\> character (`'^'`) in its role in a non-matching list in the regular expression notation. A bracket expression starting with an unquoted \<circumflex\> character produces unspecified results. A \<left-square-bracket\> that does not introduce a valid bracket expression shall match the character itself.

#### <span id="tag_19_14_02"></span>2.14.2 Patterns Matching Multiple Characters

The following rules are used to construct patterns matching multiple characters from patterns matching a single character:

1.  The \<asterisk\> (`'*'`) is a pattern that shall match any string, including the null string.
2.  The concatenation of patterns matching a single character is a valid pattern that shall match the concatenation of the single characters or collating elements matched by each of the concatenated patterns.
3.  The concatenation of one or more patterns matching a single character with one or more \<asterisk\> characters is a valid pattern. In such patterns, each \<asterisk\> shall match a string of zero or more characters, matching the greatest possible number of characters that still allows the remainder of the pattern to match the string.

#### <span id="tag_19_14_03"></span>2.14.3 Patterns Used for Filename Expansion

The rules described so far in [2.14.1 Patterns Matching a Single Character](#tag_19_14_01) and [2.14.2 Patterns Matching Multiple Characters](#tag_19_14_02) are qualified by the following rules that apply when pattern matching notation is used for filename expansion:

1.  The \<slash\> character in a pathname shall be explicitly matched by using one or more \<slash\> characters in the pattern; it shall neither be matched by the \<asterisk\> or \<question-mark\> special characters nor by a bracket expression. \<slash\> characters in the pattern shall be identified before bracket expressions; thus, a \<slash\> cannot be included in a pattern bracket expression used for filename expansion. If a \<slash\> character is found following an unescaped \<left-square-bracket\> character before a corresponding \<right-square-bracket\> is found, the open bracket shall be treated as an ordinary character. For example, the pattern `"a[b/c]d"` does not match such pathnames as **abd** or **a/d**. It only matches a pathname of literally **a\[b/c\]d**.

2.  If a filename begins with a \<period\> (`'.'`), the \<period\> shall be explicitly matched by using a \<period\> as the first character of the pattern or immediately following a \<slash\> character. The leading \<period\> shall not be matched by:

    - The \<asterisk\> or \<question-mark\> special characters
    - A bracket expression containing a non-matching list, such as `"[!a]"`, a range expression, such as `"[%-0]"`, or a character class expression, such as `"[[:punct:]]"`

    It is unspecified whether an explicit \<period\> in a bracket expression matching list, such as `"[.abc]"`, can match a leading \<period\> in a filename.

3.  If a specified pattern contains any `'*'`, `'?'` or `'['` characters that will be treated as special (see [2.14.1 Patterns Matching a Single Character](#tag_19_14_01)), it shall be matched against existing filenames and pathnames, as appropriate; if directory entries for dot and dot-dot exist, they may be ignored. Each component that contains any such characters shall require read permission in the directory containing that component. Each component that contains a \<backslash\> that will be treated as special may require read permission in the directory containing that component. Any component, except the last, that does not contain any `'*'`, `'?'` or `'['` characters that will be treated as special shall require search permission. If these permissions are denied, or if an attempt to open or search a pathname as a directory, or an attempt to read an opened directory, fails because of an error condition that is related to file system contents, this shall not be considered an error and pathname expansion shall continue as if the pathname had named an existing directory which had been successfully opened and read, or searched, and no matching directory entries had been found in it. For other error conditions it is unspecified whether pathname expansion fails or they are treated the same as when permission is denied.

    For example, given the pattern:


        /foo/bar/x*/bam

    search permission is needed for directories **/** and **foo**, search and read permissions are needed for directory **bar**, and search permission is needed for each **x\*** directory.

    If the pattern matches any existing filenames or pathnames, the pattern shall be replaced with those filenames and pathnames, sorted according to the collating sequence in effect in the current locale. If this collating sequence does not have a total ordering of all characters (see XBD [*7.3.2 LC_COLLATE*](../basedefs/V1_chap07.html#tag_07_03_02)), any filenames or pathnames that collate equally shall be further compared byte-by-byte using the collating sequence for the POSIX locale.

    If the pattern contains an open bracket (`'['`) that does not introduce a bracket expression as in XBD [*9.3.5 RE Bracket Expression*](../basedefs/V1_chap09.html#tag_09_03_05), it is unspecified whether other unquoted `'*'`, `'?'`, `'['` or \<backslash\> characters within the same slash-delimited component of the pattern retain their special meanings or are treated as ordinary characters. For example, the pattern `"a*[/b*"` may match all filenames beginning with `'b'` in the directory `"a*["` or it may match all filenames beginning with `'b'` in all directories with names beginning with `'a'` and ending with `'['`.

    If the pattern does not match any existing filenames or pathnames, the pattern string shall be left unchanged.

    **Note:**  
    A future version of this standard may require that directory entries for dot and dot-dot are ignored (if they exist) when matching patterns against existing filenames. For example, when expanding the pattern `".*"` the result would not include dot and dot-dot.

4.  If a specified pattern does not contain any `'*'`, `'?'` or `'['` characters that will be treated as special, the pattern string shall be left unchanged.

### <span id="tag_19_15"></span>2.15 Special Built-In Utilities

The following "special built-in" utilities shall be supported in the shell command language. The output of each command, if any, shall be written to standard output, subject to the normal redirection and piping possible with all commands.

The term "built-in" implies that there is no need to execute a separate executable file because the utility is implemented in the shell itself. An implementation may choose to make any utility a built-in; however, the special built-in utilities described here differ from regular built-in utilities in two respects:

1.  An error in a special built-in utility may cause a shell executing that utility to abort, while an error in a regular built-in utility shall not cause a shell executing that utility to abort. (See [2.8.1 Consequences of Shell Errors](#tag_19_08_01) for the consequences of errors on interactive and non-interactive shells.) If a special built-in utility encountering an error does not abort the shell, its exit value shall be non-zero.
2.  As described in [2.9.1 Simple Commands](#tag_19_09_01), variable assignments preceding the invocation of a special built-in utility affect the current execution environment; this shall not be the case with a regular built-in or other utility.

The special built-in utilities in this section need not be provided in a manner accessible via the *exec* family of functions defined in the System Interfaces volume of POSIX.1-2024.

Some of the special built-ins are described as conforming to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02). For those that are not, the requirement in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04) that `"--"` be recognized as a first argument to be discarded does not apply and a conforming application shall not use that argument.

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------

<span id="break"></span> <span id="tag_19_16"></span>

#### <span id="tag_19_16_01"></span>NAME

> break — exit from for, while, or until loop

#### <span id="tag_19_16_02"></span>SYNOPSIS

> `break`` `**`[`***`n`***`]`**

#### <span id="tag_19_16_03"></span>DESCRIPTION

> If *n* is specified, the [*break*](#break) utility shall exit from the *n*th enclosing **for**, **while**, or **until** loop. If *n* is not specified, [*break*](#break) shall behave as if *n* was specified as 1. Execution shall continue with the command immediately following the exited loop. The application shall ensure that the value of *n* is a positive decimal integer. If *n* is greater than the number of enclosing loops, the outermost enclosing loop shall be exited. If there is no enclosing loop, the behavior is unspecified.
>
> A loop shall enclose a *break* or *continue* command if the loop lexically encloses the command. A loop lexically encloses a *break* or *continue* command if the command is:
>
> - Executing in the same execution environment (see [2.13 Shell Execution Environment](#tag_19_13)) as the compound-list of the loop's do-group (see [2.10.2 Shell Grammar Rules](#tag_19_10_02)), and
> - Contained in a compound-list associated with the loop (either in the compound-list of the loop's do-group or, if the loop is a **while** or **until** loop, in the compound-list following the **while** or **until** reserved word), and
> - Not in the body of a function whose function definition command (see [2.9.5 Function Definition Command](#tag_19_09_05)) is contained in a compound-list associated with the loop.
>
> If *n* is greater than the number of lexically enclosing loops and there is a non-lexically enclosing loop in progress in the same execution environment as the *break* or *continue* command, it is unspecified whether that loop encloses the command.

#### <span id="tag_19_16_04"></span>OPTIONS

> None.

#### <span id="tag_19_16_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_16_06"></span>STDIN

> Not used.

#### <span id="tag_19_16_07"></span>INPUT FILES

> None.

#### <span id="tag_19_16_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_16_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_16_10"></span>STDOUT

> Not used.

#### <span id="tag_19_16_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_16_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_16_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_16_14"></span>EXIT STATUS

>  0
>
> Successful completion.
>
> \>0
>
> The *n* value was not an unsigned decimal integer greater than or equal to 1.

#### <span id="tag_19_16_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_16_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_19_16_17"></span>EXAMPLES

> 
>     for i in *
>     do
>         if test -d "$i"
>         then break
>         fi
>     done
>
> The results of running the following example are unspecified: there are two loops in progress when the [*break*](#break) command is executed, and they are in the same execution environment, but neither loop is lexically enclosing the [*break*](#break) command. (There are no loops lexically enclosing the [*continue*](#continue) commands, either.)
>
>
>     foo() {
>         for j in 1 2; do
>             echo 'break 2' >/tmp/do_break
>             echo "  sourcing /tmp/do_break ($j)..."
>             # the behavior of the break from running the following command
>             # results in unspecified behavior:
>             . /tmp/do_break
>
>
>             do_continue() { continue 2; }
>             echo "  running do_continue ($j)..."
>             # the behavior of the continue in the following function call
>             # results in unspecified behavior (if execution reaches this
>             # point):
>             do_continue
>
>
>             trap 'continue 2' USR1
>             echo "  sending SIGUSR1 to self ($j)..."
>             # the behavior of the continue in the trap invoked from the
>             # following signal results in unspecified behavior (if
>             # execution reaches this point):
>             kill -s USR1 $$
>             sleep 1
>         done
>     }
>     for i in 1 2; do
>         echo "running foo ($i)..."
>         foo
>     done

#### <span id="tag_19_16_18"></span>RATIONALE

> In early proposals, consideration was given to expanding the syntax of [*break*](#break) and [*continue*](#continue) to refer to a label associated with the appropriate loop as a preferable alternative to the *n* method. However, this volume of POSIX.1-2024 does reserve the name space of command names ending with a \<colon\>. It is anticipated that a future implementation could take advantage of this and provide something like:
>
>
>     outofloop: for i in a b c d e
>     do
>         for j in 0 1 2 3 4 5 6 7 8 9
>         do
>             if test -r "${i}${j}"
>             then break outofloop
>             fi
>         done
>     done
>
> and that this might be standardized after implementation experience is achieved.

#### <span id="tag_19_16_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_16_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)

#### <span id="tag_19_16_21"></span>CHANGE HISTORY

#### <span id="tag_19_16_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_16_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0046 \[842\] is applied.

#### <span id="tag_19_16_24"></span>Issue 8

> Austin Group Defect 1058 is applied, clarifying that the requirement for *n* to be a positive decimal integer is a requirement on the application.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="colon"></span> <span id="tag_19_17"></span>

#### <span id="tag_19_17_01"></span>NAME

> colon — null utility

#### <span id="tag_19_17_02"></span>SYNOPSIS

> `:`` `**`[`***`argument`*`...`**`]`**

#### <span id="tag_19_17_03"></span>DESCRIPTION

> This utility shall do nothing except return a 0 exit status. It is used when a command is needed, as in the **then** condition of an **if** command, but nothing is to be done by the command.

#### <span id="tag_19_17_04"></span>OPTIONS

> This utility shall not recognize the `"--"` argument in the manner specified by Guideline 10 of XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> Implementations shall not support any options.

#### <span id="tag_19_17_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_17_06"></span>STDIN

> Not used.

#### <span id="tag_19_17_07"></span>INPUT FILES

> None.

#### <span id="tag_19_17_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_17_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_17_10"></span>STDOUT

> Not used.

#### <span id="tag_19_17_11"></span>STDERR

> Not used.

#### <span id="tag_19_17_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_17_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_17_14"></span>EXIT STATUS

> Zero.

#### <span id="tag_19_17_15"></span>CONSEQUENCES OF ERRORS

> None.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_17_16"></span>APPLICATION USAGE

> See the APPLICATION USAGE for [*true*](../utilities/true.html).

#### <span id="tag_19_17_17"></span>EXAMPLES

> 
>     : "${X=abc}"
>     if     false
>     then   :
>     else   printf '%s\n' "$X"
>     fi
>
>     abc
>
> As with any of the special built-ins, the null utility can also have variable assignments and redirections associated with it, such as:
>
>
>     x=y : > z
>
> which sets variable *x* to the value *y* (so that it persists after the null utility completes) and creates or truncates file **z**; if the file cannot be created or truncated, a non-interactive shell exits (see [2.8.1 Consequences of Shell Errors](#tag_19_08_01)).

#### <span id="tag_19_17_18"></span>RATIONALE

> None.

#### <span id="tag_19_17_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_17_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15), [*true*](../utilities/true.html#)

#### <span id="tag_19_17_21"></span>CHANGE HISTORY

#### <span id="tag_19_17_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_17_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_19_17_24"></span>Issue 8

> Austin Group Defect 1272 is applied, clarifying that the null utility does not process its arguments, does not recognize the `"--"` end-of-options delimiter, does not support any options, and does not write to standard error.
>
> Austin Group Defect 1640 is applied, changing the APPLICATION USAGE section.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="continue"></span> <span id="tag_19_18"></span>

#### <span id="tag_19_18_01"></span>NAME

> continue — continue for, while, or until loop

#### <span id="tag_19_18_02"></span>SYNOPSIS

> `continue`` `**`[`***`n`***`]`**

#### <span id="tag_19_18_03"></span>DESCRIPTION

> If *n* is specified, the [*continue*](#continue) utility shall return to the top of the *n*th enclosing **for**, **while**, or **until** loop. If *n* is not specified, [*continue*](#continue) shall behave as if *n* was specified as 1. Returning to the top of the loop involves repeating the condition list of a **while** or **until** loop or performing the next assignment of a **for** loop, and re-executing the loop if appropriate.
>
> The application shall ensure that the value of *n* is a positive decimal integer. If *n* is greater than the number of enclosing loops, the outermost enclosing loop shall be used. If there is no enclosing loop, the behavior is unspecified.
>
> The meaning of "enclosing" shall be as specified in the description of the [*break*](#break) utility.

#### <span id="tag_19_18_04"></span>OPTIONS

> None.

#### <span id="tag_19_18_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_18_06"></span>STDIN

> Not used.

#### <span id="tag_19_18_07"></span>INPUT FILES

> None.

#### <span id="tag_19_18_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_18_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_18_10"></span>STDOUT

> Not used.

#### <span id="tag_19_18_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_18_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_18_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_18_14"></span>EXIT STATUS

>  0
>
> Successful completion.
>
> \>0
>
> The *n* value was not an unsigned decimal integer greater than or equal to 1.

#### <span id="tag_19_18_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_18_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_19_18_17"></span>EXAMPLES

> 
>     for i in *
>     do
>         if test -d "$i"
>         then continue
>         fi
>         printf '"%s" is not a directory.\n' "$i"
>     done

#### <span id="tag_19_18_18"></span>RATIONALE

> None.

#### <span id="tag_19_18_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_18_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)

#### <span id="tag_19_18_21"></span>CHANGE HISTORY

#### <span id="tag_19_18_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_18_23"></span>Issue 7

> The example is changed to use the [*printf*](../utilities/printf.html) utility rather than [*echo*](../utilities/echo.html).
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0046 \[842\] is applied.

#### <span id="tag_19_18_24"></span>Issue 8

> Austin Group Defect 1058 is applied, clarifying that the requirement for *n* to be a positive decimal integer is a requirement on the application.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="dot"></span> <span id="tag_19_19"></span>

#### <span id="tag_19_19_01"></span>NAME

> dot — execute commands in the current environment

#### <span id="tag_19_19_02"></span>SYNOPSIS

> `.`` `*`file`*

#### <span id="tag_19_19_03"></span>DESCRIPTION

> The shell shall tokenize (see [2.3 Token Recognition](#tag_19_03)) the contents of the *file*, parse the tokens (see [2.10 Shell Grammar](#tag_19_10)), and execute the resulting commands in the current environment. It is unspecified whether the commands are parsed and executed as a *program* (as for a shell script) or are parsed as a single *compound_list* that is executed after the entire file has been parsed.
>
> If *file* does not contain a \<slash\>, the shell shall use the search path specified by *PATH* to find the directory containing *file*. Unlike normal command search, however, the file searched for by the [*dot*](#dot) utility need not be executable. If no readable file is found, a non-interactive shell shall abort; an interactive shell shall write a diagnostic message to standard error.
>
> The [*dot*](#dot) special built-in shall support XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except for Guidelines 1 and 2.

#### <span id="tag_19_19_04"></span>OPTIONS

> None.

#### <span id="tag_19_19_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_19_06"></span>STDIN

> Not used.

#### <span id="tag_19_19_07"></span>INPUT FILES

> See the DESCRIPTION.

#### <span id="tag_19_19_08"></span>ENVIRONMENT VARIABLES

> See the DESCRIPTION.

#### <span id="tag_19_19_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_19_10"></span>STDOUT

> Not used.

#### <span id="tag_19_19_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_19_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_19_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_19_14"></span>EXIT STATUS

> If no readable file was found or if the commands in the file could not be parsed, and the shell is interactive (and therefore does not abort; see [2.8.1 Consequences of Shell Errors](#tag_19_08_01)), the exit status shall be non-zero. Otherwise, return the value of the last command executed, or a zero exit status if no command is executed.

#### <span id="tag_19_19_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_19_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_19_19_17"></span>EXAMPLES

> 
>     cat foobar
>
>     foo=hello bar=world
>
>     . ./foobar
>     echo $foo $bar
>
>     hello world

#### <span id="tag_19_19_18"></span>RATIONALE

> Some older implementations searched the current directory for the *file*, even if the value of *PATH* disallowed it. This behavior was omitted from this volume of POSIX.1-2024 due to concerns about introducing the susceptibility to trojan horses that the user might be trying to avoid by leaving **dot** out of *PATH .*
>
> The KornShell version of [*dot*](#dot) takes optional arguments that are set to the positional parameters. This is a valid extension that allows a [*dot*](#dot) script to behave identically to a function.

#### <span id="tag_19_19_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_19_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15), [return](#tag_19_25)

#### <span id="tag_19_19_21"></span>CHANGE HISTORY

#### <span id="tag_19_19_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_19_23"></span>Issue 7

> SD5-XCU-ERN-164 is applied.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0038 \[114\] and XCU/TC1-2008/0039 \[214\] are applied.

#### <span id="tag_19_19_24"></span>Issue 8

> Austin Group Defect 252 is applied, adding a requirement for [*dot*](#dot) to support XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02) (except for Guidelines 1 and 2, since the utility's name is `'.'`).
>
> Austin Group Defect 953 is applied, clarifying how the commands in the *file* are parsed.
>
> Austin Group Defect 1265 is applied, updating the DESCRIPTION to align with the changes made to [2.8.1 Consequences of Shell Errors](#tag_19_08_01) between Issue 6 and Issue 7.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="eval"></span> <span id="tag_19_20"></span>

#### <span id="tag_19_20_01"></span>NAME

> eval — construct command by concatenating arguments

#### <span id="tag_19_20_02"></span>SYNOPSIS

> `eval`` `**`[`***`argument`*`...`**`]`**

#### <span id="tag_19_20_03"></span>DESCRIPTION

> The [*eval*](#eval) utility shall construct a command string by concatenating *argument*s together, separating each with a \<space\> character. The constructed command string shall be tokenized (see [2.3 Token Recognition](#tag_19_03)), parsed (see [2.10 Shell Grammar](#tag_19_10)), and executed by the shell in the current environment. It is unspecified whether the commands are parsed and executed as a *program* (as for a shell script) or are parsed as a single *compound_list* that is executed after the entire constructed command string has been parsed.

#### <span id="tag_19_20_04"></span>OPTIONS

> None.

#### <span id="tag_19_20_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_20_06"></span>STDIN

> Not used.

#### <span id="tag_19_20_07"></span>INPUT FILES

> None.

#### <span id="tag_19_20_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_20_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_20_10"></span>STDOUT

> Not used.

#### <span id="tag_19_20_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_20_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_20_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_20_14"></span>EXIT STATUS

> If there are no *argument*s, or only null *argument*s, [*eval*](#eval) shall return a zero exit status; otherwise, it shall return the exit status of the command defined by the string of concatenated *argument*s separated by \<space\> characters, or a non-zero exit status if the concatenation could not be parsed as a command and the shell is interactive (and therefore did not abort).

#### <span id="tag_19_20_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_20_16"></span>APPLICATION USAGE

> Since [*eval*](#eval) is not required to recognize the `"--"` end of options delimiter, in cases where the argument(s) to [*eval*](#eval) might begin with `'-'` it is recommended that the first argument is prefixed by a string that will not alter the commands to be executed, such as a \<space\> character:
>
>
>     eval " $commands"
>
> or:
>
>
>     eval " $(some_command)"

#### <span id="tag_19_20_17"></span>EXAMPLES

> 
>     foo=10 x=foo
>     y='$'$x
>     echo $y
>
>     $foo
>
>     eval y='$'$x
>     echo $y
>
>     10

#### <span id="tag_19_20_18"></span>RATIONALE

> This standard allows, but does not require, [*eval*](#eval) to recognize `"--"`. Although this means applications cannot use `"--"` to protect against options supported as an extension (or errors reported for unsupported options), the nature of the [*eval*](#eval) utility is such that other means can be used to provide this protection (see APPLICATION USAGE above).

#### <span id="tag_19_20_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_20_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)

#### <span id="tag_19_20_21"></span>CHANGE HISTORY

#### <span id="tag_19_20_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_20_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0040 \[114\], XCU/TC1-2008/0041 \[163\], and XCU/TC1-2008/0042 \[163\] are applied.

#### <span id="tag_19_20_24"></span>Issue 8

> Austin Group Defect 953 is applied, clarifying how the commands in the constructed command string are parsed.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="exec"></span> <span id="tag_19_21"></span>

#### <span id="tag_19_21_01"></span>NAME

> exec — perform redirections in the current shell or execute a utility

#### <span id="tag_19_21_02"></span>SYNOPSIS

> `exec`` `**`[`***`utility`*` `**`[`***`argument`*`...`**`]]`**

#### <span id="tag_19_21_03"></span>DESCRIPTION

> If [*exec*](#exec) is specified with no operands, any redirections associated with the [*exec*](#exec) command shall be made in the current shell execution environment. If any file descriptors with numbers greater than 2 are opened by those redirections, it is unspecified whether those file descriptors remain open when the shell invokes another utility. Scripts concerned that child shells could misuse open file descriptors can always close them explicitly, as shown in one of the following examples. If the result of the redirections would be that file descriptor 0, 1, or 2 is closed, implementations may open the file descriptor to an unspecified file.
>
> If [*exec*](#exec) is specified with a *utility* operand, the shell shall execute a non-built-in utility as described in [2.9.1.6 Non-built-in Utility Execution](#tag_19_09_01_06) with *utility* as the command name and the *argument* operands (if any) as the command arguments.
>
> If the [*exec*](#exec) command fails, a non-interactive shell shall exit from the current shell execution environment; <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  an interactive shell may exit from a subshell environment but shall not exit if the current shell environment is not a subshell environment.
>
> If the [*exec*](#exec) command fails and the shell does not exit, any redirections associated with the [*exec*](#exec) command that were successfully made shall take effect in the current shell execution environment. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The [*exec*](#exec) special built-in shall support XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).

#### <span id="tag_19_21_04"></span>OPTIONS

> None.

#### <span id="tag_19_21_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_21_06"></span>STDIN

> Not used.

#### <span id="tag_19_21_07"></span>INPUT FILES

> None.

#### <span id="tag_19_21_08"></span>ENVIRONMENT VARIABLES

> The following environment variable shall affect the execution of [*exec*](#exec):
>
> *PATH*
>
> Determine the search path when looking for the utility given as the *utility* operand; see XBD [*8.3 Other Environment Variables*](../basedefs/V1_chap08.html#tag_08_03).

#### <span id="tag_19_21_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_21_10"></span>STDOUT

> Not used.

#### <span id="tag_19_21_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_21_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_21_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_21_14"></span>EXIT STATUS

> If *utility* is specified and is executed, [*exec*](#exec) shall not return to the shell; rather, the exit status of the current shell execution environment shall be the exit status of *utility*. If *utility* is specified and an attempt to execute it as a non-built-in utility fails, the exit status shall be as described in [2.9.1.6 Non-built-in Utility Execution](#tag_19_09_01_06). If a redirection error occurs (see [2.8.1 Consequences of Shell Errors](#tag_19_08_01)), the exit status shall be a value in the range 1-125. Otherwise, [*exec*](#exec) shall return a zero exit status.

#### <span id="tag_19_21_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_21_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_19_21_17"></span>EXAMPLES

> Open *readfile* as file descriptor 3 for reading:
>
>
>     exec 3< readfile
>
> Open *writefile* as file descriptor 4 for writing:
>
>
>     exec 4> writefile
>
> Make file descriptor 5 a copy of file descriptor 0:
>
>
>     exec 5<&0
>
> Close file descriptor 3:
>
>
>     exec 3<&-
>
> Cat the file **maggie** by replacing the current shell with the [*cat*](../utilities/cat.html) utility:
>
>
>     exec cat maggie
>
> An application that is not concerned with strict conformance can make use of optional `%g` support known to be present in the implementation's [*printf*](../utilities/printf.html) utility by ensuring that any shell built-in version is not executed instead, and using a subshell so that the shell continues afterwards:
>
>
>     (exec printf '%g\n' "$float_value")

#### <span id="tag_19_21_18"></span>RATIONALE

> Most historical implementations were not conformant in that:
>
>
>     foo=bar exec cmd
>
> did not pass **foo** to **cmd**.

#### <span id="tag_19_21_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_21_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)

#### <span id="tag_19_21_21"></span>CHANGE HISTORY

#### <span id="tag_19_21_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_21_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_19_21_24"></span>Issue 8

> Austin Group Defect 252 is applied, adding a requirement for [*exec*](#exec) to support XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> Austin Group Defect 1157 is applied, clarifying the execution of non-built-in utilities.
>
> Austin Group Defect 1587 is applied, changing the ENVIRONMENT VARIABLES section.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="exit"></span> <span id="tag_19_22"></span>

#### <span id="tag_19_22_01"></span>NAME

> exit — cause the shell to exit

#### <span id="tag_19_22_02"></span>SYNOPSIS

> `exit`` `**`[`***`n`***`]`**

#### <span id="tag_19_22_03"></span>DESCRIPTION

> The [*exit*](#exit) utility shall cause the shell to exit from its current execution environment. If the current execution environment is a subshell environment, the shell shall exit from the subshell environment and continue in the environment from which that subshell environment was invoked; otherwise, the shell utility shall terminate. The wait status of the shell or subshell shall be determined by the unsigned decimal integer *n*, if specified.
>
> If *n* is specified and has a value between 0 and 255 inclusive, the wait status of the shell or subshell shall indicate that it exited with exit status *n*. If *n* is specified and has a value greater than 256 that corresponds to an exit status the shell assigns to commands terminated by a valid signal (see [2.8.2 Exit Status for Commands](#tag_19_08_02)), the wait status of the shell or subshell shall indicate that it was terminated by that signal. No other actions associated with the signal, such as execution of [*trap*](#trap) actions or creation of a core image, shall be performed by the shell.
>
> If *n* is specified and is not an unsigned decimal integer, or has a value of 256, or has a value greater than 256 but not corresponding to an exit status the shell assigns to commands terminated by a valid signal, the wait status of the shell or subshell is unspecified.
>
> If *n* is not specified, the result shall be as if *n* were specified with the current value of the special parameter `'?'` (see [2.5.2 Special Parameters](#tag_19_05_02)), except that if the [*exit*](#exit) command would cause the end of execution of a [*trap*](#trap) action, the value for the special parameter `'?'` that is considered "current" shall be the value it had immediately preceding the [*trap*](#trap) action.
>
> A [*trap*](#trap) action on **EXIT** shall be executed before the shell terminates, except when the [*exit*](#exit) utility is invoked in that [*trap*](#trap) action itself, in which case the shell shall exit immediately. It is unspecified whether setting a new [*trap*](#trap) action on **EXIT** during execution of a [*trap*](#trap) action on **EXIT** will cause the new [*trap*](#trap) action to be executed before the shell terminates.

#### <span id="tag_19_22_04"></span>OPTIONS

> None.

#### <span id="tag_19_22_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_22_06"></span>STDIN

> Not used.

#### <span id="tag_19_22_07"></span>INPUT FILES

> None.

#### <span id="tag_19_22_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_22_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_22_10"></span>STDOUT

> Not used.

#### <span id="tag_19_22_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_22_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_22_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_22_14"></span>EXIT STATUS

> The [*exit*](#exit) utility causes the shell to exit from its current execution environment, and therefore does not itself return an exit status.

#### <span id="tag_19_22_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_22_16"></span>APPLICATION USAGE

> As explained in other sections, certain exit status values have been reserved for special uses and should be used by applications only for those purposes:
>
>  126
>
> A file to be executed was found, but it was not an executable utility.
>
>  127
>
> A utility to be executed was not found.
>
>  128
>
> An unrecoverable read error was detected by the shell while reading commands, except from the *file* operand of the [*dot*](#dot) special built-in.
>
> \>128
>
> A command was interrupted by a signal.

#### <span id="tag_19_22_17"></span>EXAMPLES

> Exit with a *true* value:
>
>
>     exit 0
>
> Exit with a *false* value:
>
>
>     exit 1
>
> Propagate error handling from within a subshell:
>
>
>     (
>         command1 || exit 1
>         command2 || exit 1
>         exec command3
>     ) > outputfile || exit 1
>     echo "outputfile created successfully"

#### <span id="tag_19_22_18"></span>RATIONALE

> The behavior of [*exit*](#exit) when given an invalid argument or unknown option is unspecified, because of differing practices in the various historical implementations. A value larger than 255 might be truncated by the shell, and be unavailable even to a parent process that uses [*waitid*()](../functions/waitid.html) to get the full exit value. It is recommended that implementations that detect any usage error should cause a non-zero exit status (or, if the shell is interactive and the error does not cause the shell to abort, store a non-zero value in `"$?"`), but even this was not done historically in all shells.
>
> See also [*C.2.8.2 Exit Status for Commands*](../xrat/V4_xcu_chap01.html#tag_23_02_08_02).

#### <span id="tag_19_22_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_22_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)

#### <span id="tag_19_22_21"></span>CHANGE HISTORY

#### <span id="tag_19_22_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_22_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0047 \[717\], XCU/TC2-2008/0048 \[960\], XCU/TC2-2008/0049 \[717\], and XCU/TC2-2008/0050 \[960\] are applied.

#### <span id="tag_19_22_24"></span>Issue 8

> Austin Group Defect 51 is applied, specifying the behavior when *n* has a value greater than 256 that corresponds to an exit status the shell assigns to commands terminated by a valid signal.
>
> Austin Group Defect 1029 is applied, changing "[*trap*](#trap)" to "[*trap*](#trap) action" in the DESCRIPTION section.
>
> Austin Group Defect 1309 is applied, changing the EXIT STATUS section.
>
> Austin Group Defect 1425 is applied, clarifying the requirements for a [*trap*](#trap) action on **EXIT**.
>
> Austin Group Defect 1602 is applied, clarifying the behavior of [*exit*](#exit) in a [*trap*](#trap) action.
>
> Austin Group Defect 1629 is applied, adding exit status 128 to the APPLICATION USAGE section.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="export"></span> <span id="tag_19_23"></span>

#### <span id="tag_19_23_01"></span>NAME

> export — set the export attribute for variables

#### <span id="tag_19_23_02"></span>SYNOPSIS

> `export name`**`[`**`=`*`word`***`]`**`...`\
> ` `\
> `export -p`

#### <span id="tag_19_23_03"></span>DESCRIPTION

> The shell shall give the [*export*](#export) attribute to the variables corresponding to the specified *name*s, which shall cause them to be in the environment of subsequently executed commands. If the name of a variable is followed by =*word*, then the value of that variable shall be set to *word*.
>
> The [*export*](#export) special built-in shall be a declaration utility. Therefore, if *export* is recognized as the command name of a simple command, then subsequent words of the form *name*=*word* shall be expanded in an assignment context. See [2.9.1.1 Order of Processing](#tag_19_09_01_01).
>
> The [*export*](#export) special built-in shall support XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> When **-p** is specified, [*export*](#export) shall write to the standard output the names and values of all exported variables, in the following format:
>
>
>     "export %s=%s\n", <name>, <value>
>
> if *name* is set, and:
>
>
>     "export %s\n", <name>
>
> if *name* is unset.
>
> The shell shall format the output, including the proper use of quoting, so that it is suitable for reinput to the shell as commands that achieve the same exporting results, except:
>
> 1.  Read-only variables with values cannot be reset.
> 2.  Variables that were unset at the time they were output need not be reset to the unset state if a value is assigned to the variable between the time the state was saved and the time at which the saved output is reinput to the shell.
>
> When no arguments are given, the results are unspecified.

#### <span id="tag_19_23_04"></span>OPTIONS

> See the DESCRIPTION.

#### <span id="tag_19_23_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_23_06"></span>STDIN

> Not used.

#### <span id="tag_19_23_07"></span>INPUT FILES

> None.

#### <span id="tag_19_23_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_23_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_23_10"></span>STDOUT

> See the DESCRIPTION.

#### <span id="tag_19_23_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_23_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_23_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_23_14"></span>EXIT STATUS

>  0
>
> Successful completion.
>
> \>0
>
> At least one operand could not be processed as requested, such as a *name* operand that could not be exported or an attempt to modify a *readonly* variable using a *name*=*word* operand, or the **-p** option was specified and a write error occurred.

#### <span id="tag_19_23_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_23_16"></span>APPLICATION USAGE

> Note that, unless *X* was previously marked readonly, the value of `"$?"` after:
>
>
>     export X=$(false)
>
> will be 0 (because [*export*](#export) successfully set *X* to the empty string) and that execution continues, even if [*set*](#set) **-e** is in effect. In order to detect command substitution failures, a user must separate the assignment from the export, as in:
>
>
>     X=$(false)
>     export X
>
> In shells that support extended assignment syntax, for example to allow an array to be populated with a single assignment, such extensions can typically only be used in assignments specified as arguments to [*export*](#export) if the command word is literally *export*, and not if it is some other word that expands to *export*. For example:
>
>
>     # Shells that support array assignment as an extension generally
>     # support this:
>     export x=(1 2 3); echo ${x[0]}  # outputs 1
>     # But generally do not support this:
>     e=export; $e x=(1 2 3); echo ${x[0]}  # syntax error

#### <span id="tag_19_23_17"></span>EXAMPLES

> Export *PWD* and *HOME* variables:
>
>
>     export PWD HOME
>
> Set and export the *PATH* variable:
>
>
>     export PATH="/local/bin:$PATH"
>
> Save and restore all exported variables:
>
>
>     export -p > temp-file
>     unset a lot of variables
>
>     ... processing
>
>     . ./temp-file
>
> **Note:**  
> If LANG, LC_CTYPE or LC_ALL are left altered or unset in the above example prior to sourcing `temp-file`, the results may be undefined.

#### <span id="tag_19_23_18"></span>RATIONALE

> Some historical shells use the no-argument case as the functional equivalent of what is required here with **-p**. This feature was left unspecified because it is not historical practice in all shells, and some scripts may rely on the now-unspecified results on their implementations. Attempts to specify the **-p** output as the default case were unsuccessful in achieving consensus. The **-p** option was added to allow portable access to the values that can be saved and then later restored using; for example, a [*dot*](#dot) script.
>
> Some implementations extend the shell's assignment syntax, for example to allow an array to be populated with a single assignment, and in order for such an extension to be usable in assignments specified as arguments to [*export*](#export) these shells have *export* as a separate token in their grammar. This standard only permits an extension of this nature when the input to the shell would contain a syntax error according to the standard grammar. Note that although *export* can be a separate token in the shell's grammar, it cannot be a reserved word since *export* is a candidate for alias substitution whereas reserved words are not (see [2.3.1 Alias Substitution](#tag_19_03_01)).

#### <span id="tag_19_23_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_23_20"></span>SEE ALSO

> [2.9.1.1 Order of Processing](#tag_19_09_01_01), [2.15 Special Built-In Utilities](#tag_19_15)
>
> XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_19_23_21"></span>CHANGE HISTORY

#### <span id="tag_19_23_22"></span>Issue 6

> IEEE PASC Interpretation 1003.2 \#203 is applied, clarifying the format when a variable is unset.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/6 is applied, adding the following text to the end of the first paragraph of the DESCRIPTION: "If the name of a variable is followed by =*word*, then the value of that variable shall be set to *word*.". The reason for this change is that the SYNOPSIS for [*export*](#export) includes:
>
>
>     export name[=word]...
>
> but the meaning of the optional "=*word*" is never explained in the text.

#### <span id="tag_19_23_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0043 \[352\] is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0051 \[654\] and XCU/TC2-2008/0052 \[960\] are applied.

#### <span id="tag_19_23_24"></span>Issue 8

> Austin Group Defect 351 is applied, requiring [*export*](#export) to be a declaration utility.
>
> Austin Group Defect 367 is applied, changing the EXIT STATUS section.
>
> Austin Group Defect 1258 is applied, changing the EXAMPLES section.
>
> Austin Group Defect 1393 is applied, changing the APPLICATION USAGE and RATIONALE sections.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="readonly"></span> <span id="tag_19_24"></span>

#### <span id="tag_19_24_01"></span>NAME

> readonly — set the readonly attribute for variables

#### <span id="tag_19_24_02"></span>SYNOPSIS

> `readonly name`**`[`**`=`*`word`***`]`**`...`\
> ` `\
> `readonly -p`

#### <span id="tag_19_24_03"></span>DESCRIPTION

> The variables whose *name*s are specified shall be given the [*readonly*](#readonly) attribute. The values of variables with the [*readonly*](#readonly) attribute cannot be changed by subsequent assignment or use of the [*export*](#export), [*getopts*](../utilities/getopts.html), [*readonly*](#readonly), or [*read*](../utilities/read.html) utilities, nor can those variables be unset by the [*unset*](#unset) utility. As described in XBD [*8.1 Environment Variable Definition*](../basedefs/V1_chap08.html#tag_08_01), conforming applications shall not request to mark a variable as *readonly* if it is documented as being manipulated by a shell built-in utility, as it may render those utilities unable to complete successfully. If the name of a variable is followed by =*word*, then the value of that variable shall be set to *word*.
>
> The [*readonly*](#readonly) special built-in shall be a declaration utility. Therefore, if *readonly* is recognized as the command name of a simple command, then subsequent words of the form *name*=*word* shall be expanded in an assignment context. See [2.9.1.1 Order of Processing](#tag_19_09_01_01).
>
> The [*readonly*](#readonly) special built-in shall support XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> When **-p** is specified, [*readonly*](#readonly) writes to the standard output the names and values of all read-only variables, in the following format:
>
>
>     "readonly %s=%s\n", <name>, <value>
>
> if *name* is set, and
>
>
>     "readonly %s\n", <name>
>
> if *name* is unset.
>
> The shell shall format the output, including the proper use of quoting, so that it is suitable for reinput to the shell as commands that achieve the same value and *readonly* attribute-setting results in a shell execution environment in which:
>
> 1.  Variables with values at the time they were output do not have the *readonly* attribute set.
> 2.  Variables that were unset at the time they were output do not have a value at the time at which the saved output is reinput to the shell.
>
> When no arguments are given, the results are unspecified.

#### <span id="tag_19_24_04"></span>OPTIONS

> See the DESCRIPTION.

#### <span id="tag_19_24_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_24_06"></span>STDIN

> Not used.

#### <span id="tag_19_24_07"></span>INPUT FILES

> None.

#### <span id="tag_19_24_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_24_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_24_10"></span>STDOUT

> See the DESCRIPTION.

#### <span id="tag_19_24_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_24_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_24_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_24_14"></span>EXIT STATUS

>  0
>
> Successful completion.
>
> \>0
>
> At least one operand could not be processed as requested, such as a *name* operand that could not be marked *readonly* or an attempt to modify an already *readonly* variable using a *name*=*word* operand, or the **-p** option was specified and a write error occurred.

#### <span id="tag_19_24_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_24_16"></span>APPLICATION USAGE

> In shells that support extended assignment syntax, for example to allow an array to be populated with a single assignment, such extensions can typically only be used in assignments specified as arguments to [*readonly*](#readonly) if the command word is literally *readonly*, and not if it is some other word that expands to *readonly*. For example:
>
>
>     # Shells that support array assignment as an extension generally
>     # support this:
>     readonly x=(1 2 3); echo ${x[0]}  # outputs 1
>     # But generally do not support this:
>     r=readonly; $r x=(1 2 3); echo ${x[0]}  # syntax error

#### <span id="tag_19_24_17"></span>EXAMPLES

> 
>     readonly HOME

#### <span id="tag_19_24_18"></span>RATIONALE

> Some historical shells preserve the *readonly* attribute across separate invocations. This volume of POSIX.1-2024 allows this behavior, but does not require it.
>
> The **-p** option allows portable access to the values that can be saved and then later restored using, for example, a [*dot*](#dot) script. Also see the RATIONALE for [export](#tag_19_23) for a description of the no-argument and **-p** output cases and a related example.
>
> Read-only functions were considered, but they were omitted as not being historical practice or particularly useful. Furthermore, functions must not be read-only across invocations to preclude "spoofing" (spoofing is the term for the practice of creating a program that acts like a well-known utility with the intent of subverting the real intent of the user) of administrative or security-relevant (or security-conscious) shell scripts.
>
> Attempts to set the *readonly* attribute on certain variables, such as *PWD ,* may have surprising results. Either [*readonly*](#readonly) will reject the attempt, or the attempt will succeed but the shell will continue to alter the contents of *PWD* during the [*cd*](../utilities/cd.html) utility, or the attempt will succeed and render the [*cd*](../utilities/cd.html) utility inoperative (since it must not change directories if it cannot also update *PWD ).*
>
> Some implementations extend the shell's assignment syntax, for example to allow an array to be populated with a single assignment, and in order for such an extension to be usable in assignments specified as arguments to [*readonly*](#readonly) these shells have *readonly* as a separate token in their grammar. This standard only permits an extension of this nature when the input to the shell would contain a syntax error according to the standard grammar. Note that although *readonly* can be a separate token in the shell's grammar, it cannot be a reserved word since *readonly* is a candidate for alias substitution whereas reserved words are not (see [2.3.1 Alias Substitution](#tag_19_03_01)).

#### <span id="tag_19_24_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_24_20"></span>SEE ALSO

> [2.9.1.1 Order of Processing](#tag_19_09_01_01), [2.15 Special Built-In Utilities](#tag_19_15)
>
> XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_19_24_21"></span>CHANGE HISTORY

#### <span id="tag_19_24_22"></span>Issue 6

> IEEE PASC Interpretation 1003.2 \#203 is applied, clarifying the format when a variable is unset.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/7 is applied, adding the following text to the end of the first paragraph of the DESCRIPTION: "If the name of a variable is followed by =*word*, then the value of that variable shall be set to *word*.". The reason for this change is that the SYNOPSIS for [*readonly*](#readonly) includes:\
>
>
>     readonly name[=word]...
>
> but the meaning of the optional "=*word*" is never explained in the text.

#### <span id="tag_19_24_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0052 \[960\] is applied.

#### <span id="tag_19_24_24"></span>Issue 8

> Austin Group Defect 351 is applied, requiring [*readonly*](#readonly) to be a declaration utility.
>
> Austin Group Defect 367 is applied, clarifying that the values of *readonly* variables cannot be changed by subsequent use of the [*export*](#export), [*getopts*](../utilities/getopts.html), [*readonly*](#readonly), or [*read*](../utilities/read.html) utilities, and changing the EXIT STATUS, EXAMPLES and RATIONALE sections.
>
> Austin Group Defect 1393 is applied, changing the APPLICATION USAGE and RATIONALE sections.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="return"></span> <span id="tag_19_25"></span>

#### <span id="tag_19_25_01"></span>NAME

> return — return from a function or dot script

#### <span id="tag_19_25_02"></span>SYNOPSIS

> `return`` `**`[`***`n`***`]`**

#### <span id="tag_19_25_03"></span>DESCRIPTION

> The [*return*](#return) utility shall cause the shell to stop executing the current function or [*dot*](#dot) script. If the shell is not currently executing a function or [*dot*](#dot) script, the results are unspecified.

#### <span id="tag_19_25_04"></span>OPTIONS

> None.

#### <span id="tag_19_25_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_25_06"></span>STDIN

> Not used.

#### <span id="tag_19_25_07"></span>INPUT FILES

> None.

#### <span id="tag_19_25_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_25_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_25_10"></span>STDOUT

> Not used.

#### <span id="tag_19_25_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_25_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_25_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_25_14"></span>EXIT STATUS

> The exit status shall be *n*, if specified, except that the behavior is unspecified if *n* is not an unsigned decimal integer or is greater than 255. If *n* is not specified, the result shall be as if *n* were specified with the current value of the special parameter `'?'` (see [2.5.2 Special Parameters](#tag_19_05_02)), except that if the [*return*](#return) command would cause the end of execution of a [*trap*](#trap) action, the value for the special parameter `'?'` that is considered "current" shall be the value it had immediately preceding the [*trap*](#trap) action.

#### <span id="tag_19_25_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_25_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_19_25_17"></span>EXAMPLES

> None.

#### <span id="tag_19_25_18"></span>RATIONALE

> The behavior of [*return*](#return) when not in a function or [*dot*](#dot) script differs between the System V shell and the KornShell. In the System V shell this is an error, whereas in the KornShell, the effect is the same as [*exit*](#exit).
>
> The results of returning a number greater than 255 are undefined because of differing practices in the various historical implementations. Some shells AND out all but the low-order 8 bits; others allow larger values, but not of unlimited size.
>
> See the discussion of appropriate exit status values under [exit](#tag_19_22).

#### <span id="tag_19_25_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_25_20"></span>SEE ALSO

> [2.9.5 Function Definition Command](#tag_19_09_05), [2.15 Special Built-In Utilities](#tag_19_15), [dot](#tag_19_19)

#### <span id="tag_19_25_21"></span>CHANGE HISTORY

#### <span id="tag_19_25_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_25_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0044 \[214\] and XCU/TC1-2008/0045 \[214\] are applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0052 \[960\] is applied.

#### <span id="tag_19_25_24"></span>Issue 8

> Austin Group Defect 1309 is applied, changing the EXIT STATUS section.
>
> Austin Group Defect 1602 is applied, clarifying the behavior of [*return*](#return) in a [*trap*](#trap) action.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="set"></span> <span id="tag_19_26"></span>

#### <span id="tag_19_26_01"></span>NAME

> set — set or unset options and positional parameters

#### <span id="tag_19_26_02"></span>SYNOPSIS

> `set`` `**`[`**`-abCefhmnuvx`**`] [`**`-o`` `*`option`***`] [`***`argument`*`...`**`]`**\
> ` `\
> `set`` `**`[`**`+abCefhmnuvx`**`] [`**`+o`` `*`option`***`] [`***`argument`*`...`**`]`**\
> ` `\
> `set --`` `**`[`***`argument`*`...`**`]`**\
> ` `\
> `set -o`\
> ` `\
> `set +o`

#### <span id="tag_19_26_03"></span>DESCRIPTION

> If no *option*s or *argument*s are specified, [*set*](#set) shall write the names and values of all shell variables in the collation sequence of the current locale. Each *name* shall start on a separate line, using the format:
>
>
>     "%s=%s\n", <name>, <value>
>
> The *value* string shall be written with appropriate quoting; see the description of shell quoting in [2.2 Quoting](#tag_19_02). The output shall be suitable for reinput to the shell, setting or resetting, as far as possible, the variables that are currently set; read-only variables cannot be reset.
>
> When options are specified, they shall set or unset attributes of the shell, as described below. When *argument*s are specified, they cause positional parameters to be set or unset, as described below. Setting or unsetting attributes and positional parameters are not necessarily related actions, but they can be combined in a single invocation of [*set*](#set).
>
> The [*set*](#set) special built-in shall support XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02) except that options can be specified with either a leading \<hyphen-minus\> (meaning enable the option) or \<plus-sign\> (meaning disable it) unless otherwise specified.
>
> Implementations shall support the options in the following list in both their \<hyphen-minus\> and \<plus-sign\> forms. These options can also be specified as options to [*sh*](../utilities/sh.html).
>
> **-a**
>
> Set the *export* attribute for all variable assignments. When this option is on, whenever a value is assigned to a variable in the current shell execution environment, the *export* attribute shall be set for the variable. This applies to all forms of assignment, including those made as a side-effect of variable expansions or arithmetic expansions, and those made as a result of the operation of the [*cd*](../utilities/cd.html), [*getopts*](../utilities/getopts.html), or [*read*](../utilities/read.html) utilities.
>
> **Note:**  
> As discussed in [2.9.1 Simple Commands](#tag_19_09_01), not all variable assignments happen in the current execution environment. When an assignment happens in a separate execution environment the *export* attribute is still set for the variable, but that does not affect the current execution environment.
>
> **-b**
>
> This option shall be supported if the implementation supports the User Portability Utilities option. When job control and **-b** are both enabled, the shell shall write asynchronous notifications of background job completions (including termination by a signal), and may write asynchronous notifications of background job suspensions. See [2.11 Job Control](#tag_19_11) for details. When job control is disabled, the **-b** option shall have no effect. Asynchronous notification shall not be enabled by default.
>
> **-C**
>
> (Uppercase C.) Prevent existing regular files from being overwritten by the shell's `'>'` redirection operator (see [2.7.2 Redirecting Output](#tag_19_07_02)); the `">|"` redirection operator shall override this *noclobber* option for an individual file.
>
> **-e**
>
> When this option is on, when any command fails (for any of the reasons listed in [2.8.1 Consequences of Shell Errors](#tag_19_08_01) or by returning an exit status greater than zero), the shell immediately shall exit, as if by executing the [*exit*](#exit) special built-in utility with no arguments, with the following exceptions:
>
> 1.  The failure of any individual command in a multi-command pipeline, or of any subshell environments in which command substitution was performed during word expansion, shall not cause the shell to exit. Only the failure of the pipeline itself shall be considered.
> 2.  The **-e** setting shall be ignored when executing the compound list following the **while**, **until**, **if**, or **elif** reserved word, a pipeline beginning with the **!** reserved word, or any command of an AND-OR list other than the last.
> 3.  If the exit status of a compound command other than a subshell command was the result of a failure while **-e** was being ignored, then **-e** shall not apply to this command.
>
> This requirement applies to the shell environment and each subshell environment separately. For example, in:
>
>
>     set -e; (false; echo one) | cat; echo two
>
> the [*false*](../utilities/false.html) command causes the subshell to exit without executing `echo one`; however, `echo two` is executed because the exit status of the pipeline `(false; echo one) | cat` is zero.
>
> In
>
>
>     set -e; echo $(false; echo one) two
>
> the [*false*](../utilities/false.html) command causes the subshell in which the command substitution is performed to exit without executing `echo one`; the exit status of the subshell is ignored and the shell then executes the word-expanded command `echo two`.
>
> **-f**
>
> The shell shall disable pathname expansion.
>
> **-h**
>
> <sup>\[[OB](javascript:open_code('OB'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Setting this option may speed up *PATH* searches (see XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)). This option may be enabled by default. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-m**
>
> This option shall be supported if the implementation supports the User Portability Utilities option. When this option is enabled, the shell shall perform job control actions as described in [2.11 Job Control](#tag_19_11). This option shall be enabled by default for interactive shells.
>
> **-n**
>
> The shell shall read commands but does not execute them; this can be used to check for shell script syntax errors. Interactive shells and subshells of interactive shells, recursively, may ignore this option.
>
> **-o**
>
> Write the current settings of the options to standard output in an unspecified format.
>
> **+o**
>
> Write the current option settings to standard output in a format that is suitable for reinput to the shell as commands that achieve the same options settings.
>
> **-o ***option*
>
> \
> Set various options, many of which shall be equivalent to the single option letters. The following values of *option* shall be supported:
>
> *allexport*
>
> Equivalent to **-a**.
>
> *errexit*
>
> Equivalent to **-e**.
>
> *ignoreeof*
>
> Prevent an interactive shell from exiting on end-of-file. This setting prevents accidental logouts when \<control\>-D is entered. A user shall explicitly [*exit*](#exit) to leave the interactive shell. This option shall be supported if the system supports the User Portability Utilities option.
>
> *monitor*
>
> Equivalent to **-m**. This option shall be supported if the system supports the User Portability Utilities option.
>
> *noclobber*
>
> Equivalent to **-C** (uppercase C).
>
> *noglob*
>
> Equivalent to **-f**.
>
> *noexec*
>
> Equivalent to **-n**.
>
> *nolog*
>
> <sup>\[[OB](javascript:open_code('OB'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Prevent the entry of function definitions into the command history; see [*Command History List*](../utilities/sh.html#tag_20_110_13_01). This option may have no effect; it is kept for compatibility with previous versions of the standard. This option shall be supported if the system supports the User Portability Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *notify*
>
> Equivalent to **-b**.
>
> *nounset*
>
> Equivalent to **-u**.
>
> *pipefail*
>
> Derive the exit status of a pipeline from the exit statuses of all of the commands in the pipeline, not just the last (rightmost) command, as described in [2.9.2 Pipelines](#tag_19_09_02).
>
> *verbose*
>
> Equivalent to **-v**.
>
> *vi*
>
> Allow shell command line editing using the built-in [*vi*](../utilities/vi.html) editor. Enabling [*vi*](../utilities/vi.html) mode shall disable any other command line editing mode provided as an implementation extension. This option shall be supported if the system supports the User Portability Utilities option.
>
> It need not be possible to set [*vi*](../utilities/vi.html) mode on for certain block-mode terminals.
>
> *xtrace*
>
> Equivalent to **-x**.
>
> **-u**
>
> When the shell tries to expand, in a parameter expansion or an arithmetic expansion, an unset parameter other than the `'@'` and `'*'` special parameters, it shall write a message to standard error and the expansion shall fail with the consequences specified in [2.8.1 Consequences of Shell Errors](#tag_19_08_01).
>
> **-v**
>
> The shell shall write its input to standard error as it is read.
>
> **-x**
>
> The shell shall write to standard error a trace for each command after it expands the command and before it executes it. It is unspecified whether the command that turns tracing off is traced.
>
> The default for all these options shall be off (unset) unless stated otherwise in the description of the option or unless the shell was invoked with them on; see [*sh*](../utilities/sh.html).
>
> The remaining arguments shall be assigned in order to the positional parameters. The special parameter `'#'` shall be set to reflect the number of positional parameters. All positional parameters shall be unset before any new values are assigned.
>
> If the first argument is `'-'`, the results are unspecified.
>
> The special argument `"--"` immediately following the [*set*](#set) command name can be used to delimit the arguments if the first argument begins with `'+'` or `'-'`, or to prevent inadvertent listing of all shell variables when there are no arguments. The command [*set*](#set) **--** without *argument* shall unset all positional parameters and set the special parameter `'#'` to zero.

#### <span id="tag_19_26_04"></span>OPTIONS

> See the DESCRIPTION.

#### <span id="tag_19_26_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_26_06"></span>STDIN

> Not used.

#### <span id="tag_19_26_07"></span>INPUT FILES

> None.

#### <span id="tag_19_26_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_26_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_26_10"></span>STDOUT

> See the DESCRIPTION.

#### <span id="tag_19_26_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_26_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_26_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_26_14"></span>EXIT STATUS

>  0
>
> Successful completion.
>
> \>0
>
> An invalid option was specified, or an error occurred.

#### <span id="tag_19_26_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_26_16"></span>APPLICATION USAGE

> Application writers should avoid relying on [*set*](#set) **-e** within functions. For example, in the following script:
>
>
>     set -e
>     start() {
>         some_server
>         echo some_server started successfully
>     }
>     start || echo >&2 some_server failed
>
> the **-e** setting is ignored within the function body (because the function is a command in an AND-OR list other than the last). Therefore, if `some_server` fails, the function carries on to echo `"some_server started successfully"`, and the exit status of the function is zero (which means `"some_server failed"` is not output).
>
> Use of [*set*](#set) **-n** causes the shell to parse the rest of the script without executing any commands, meaning that [*set*](#set) **+n** cannot be used to undo the effect. Syntax checking is more commonly done via `sh` `-n` *script_name*.

#### <span id="tag_19_26_17"></span>EXAMPLES

> Write out all variables and their values:
>
>
>     set
>
> Set \$1, \$2, and \$3 and set `"$#"` to 3:
>
>
>     set c a b
>
> Turn on the **-x** and **-v** options:
>
>
>     set -xv
>
> Unset all positional parameters:
>
>
>     set --
>
> Set \$1 to the value of *x*, even if it begins with `'-'` or `'+'`:
>
>
>     set -- "$x"
>
> Set the positional parameters to the expansion of *x*, even if *x* expands with a leading `'-'` or `'+'`:
>
>
>     set -- $x

#### <span id="tag_19_26_18"></span>RATIONALE

> The [*set*](#set) -- form is listed specifically in the SYNOPSIS even though this usage is implied by the Utility Syntax Guidelines. The explanation of this feature removes any ambiguity about whether the [*set*](#set) -- form might be misinterpreted as being equivalent to [*set*](#set) without any options or arguments. The functionality of this form has been adopted from the KornShell. In System V, [*set*](#set) -- only unsets parameters if there is at least one argument; the only way to unset all parameters is to use [*shift*](#shift). Using the KornShell version should not affect System V scripts because there should be no reason to issue it without arguments deliberately; if it were issued as, for example:
>
>
>     set -- "$@"
>
> and there were in fact no arguments resulting from `"$@"`, unsetting the parameters would have no result.
>
> The [*set*](#set) + form in early proposals was omitted as being an unnecessary duplication of [*set*](#set) alone and not widespread historical practice.
>
> The *noclobber* option was changed to allow [*set*](#set) **-C** as well as the [*set*](#set) **-o** *noclobber* option. The single-letter version was added so that the historical `"$-"` paradigm would not be broken; see [2.5.2 Special Parameters](#tag_19_05_02).
>
> The description of the **-e** option is intended to match the behavior of the 1988 version of the KornShell.
>
> The **-h** option is related to command name hashing. See [*hash*](../utilities/hash.html#). The normative description is deliberately vague because the way this option works varies between shell implementations.
>
> Earlier versions of this standard specified **-h** as a way to locate and remember utilities to be invoked by functions as those functions are defined (the utilities are normally located when the function is executed). However, this did not match existing practice in most shells.
>
> The following [*set*](#set) options were omitted intentionally with the following rationale:
>
> **-k**
>
> The **-k** option was originally added by the author of the Bourne shell to make it easier for users of pre-release versions of the shell. In early versions of the Bourne shell the construct [*set*](#set) *name*=*value* had to be used to assign values to shell variables. The problem with **-k** is that the behavior affects parsing, virtually precluding writing any compilers. To explain the behavior of **-k**, it is necessary to describe the parsing algorithm, which is implementation-defined. For example:
>
>
>     set -k; echo name=value
>
> and:
>
>
>     set -k
>     echo name=value
>
> behave differently. The interaction with functions is even more complex. What is more, the **-k** option is never needed, since the command line could have been reordered.
>
> **-t**
>
> The **-t** option is hard to specify and almost never used. The only known use could be done with here-documents. Moreover, the behavior with *ksh* and [*sh*](../utilities/sh.html) differs. The reference page says that it exits after reading and executing one command. What is one command? If the input is *date*;*date*, [*sh*](../utilities/sh.html) executes both [*date*](../utilities/date.html) commands while *ksh* does only the first.
>
> Consideration was given to rewriting [*set*](#set) to simplify its confusing syntax. A specific suggestion was that the [*unset*](#unset) utility should be used to unset options instead of using the non-[*getopt*()](../functions/getopt.html)-able +*option* syntax. However, the conclusion was reached that the historical practice of using +*option* was satisfactory and that there was no compelling reason to modify such widespread historical practice.
>
> The **-o** option was adopted from the KornShell to address user needs. In addition to its generally friendly interface, **-o** is needed to provide the [*vi*](../utilities/vi.html) command line editing mode, for which historical practice yields no single-letter option name. (Although it might have been possible to invent such a letter, it was recognized that other editing modes would be developed and **-o** provides ample name space for describing such extensions.)
>
> Historical implementations are inconsistent in the format used for **-o** option status reporting. The **+o** format without an option-argument was added to allow portable access to the options that can be saved and then later restored using, for instance, a dot script.
>
> Historically, [*sh*](../utilities/sh.html) did trace the command [*set*](#set) **+x**, but *ksh* did not.
>
> The *ignoreeof* setting prevents accidental logouts when the end-of-file character (typically \<control\>-D) is entered. A user shall explicitly [*exit*](#exit) to leave the interactive shell.
>
> The [*set*](#set) **-m** option was added to apply only to the UPE because it applies primarily to interactive use, not shell script applications.
>
> The ability to do asynchronous notification became available in the 1988 version of the KornShell. To have it occur, the user had to issue the command:
>
>
>     trap "jobs -n" CLD
>
> The C shell provides two different levels of an asynchronous notification capability. The environment variable *notify* is analogous to what is done in [*set*](#set) **-b** or [*set*](#set) **-o** *notify*. When set, it notifies the user immediately of background job completions. When unset, this capability is turned off.
>
> The other notification ability comes through the built-in utility *notify*. The syntax is:
>
>
>     notify [%job ... ]
>
> By issuing *notify* with no operands, it causes the C shell to notify the user asynchronously when the state of the current job changes. If given operands, *notify* asynchronously informs the user of changes in the states of the specified jobs.
>
> To add asynchronous notification to the POSIX shell, neither the KornShell extensions to [*trap*](#trap), nor the C shell *notify* environment variable seemed appropriate (*notify* is not a proper POSIX environment variable name).
>
> The [*set*](#set) **-b** option was selected as a compromise.
>
> The *notify* built-in was considered to have more functionality than was required for simple asynchronous notification.
>
> Historically, some shells applied the **-u** option to all parameters including `$@` and `$*`. The standard developers felt that this was a misfeature since it is normal and common for `$@` and `$*` to be used in shell scripts regardless of whether they were passed any arguments. Treating these uses as an error when no arguments are passed reduces the value of **-u** for its intended purpose of finding spelling mistakes in variable names and uses of unset positional parameters.

#### <span id="tag_19_26_19"></span>FUTURE DIRECTIONS

> A future version of this standard may remove the **-o** *nolog* option.

#### <span id="tag_19_26_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15), [*hash*](../utilities/hash.html#)
>
> XBD [*4.26 Variable Assignment*](../basedefs/V1_chap04.html#tag_04_26), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_19_26_21"></span>CHANGE HISTORY

#### <span id="tag_19_26_22"></span>Issue 6

> The obsolescent [*set*](#set) command name followed by `'-'` has been removed.
>
> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - The *nolog* option is added to [*set*](#set) **-o**.
>
> IEEE PASC Interpretation 1003.2 \#167 is applied, clarifying that the options default also takes into account the description of the option.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/8 is applied, changing the square brackets in the example in RATIONALE to be in bold, which is the typeface used for optional items.

#### <span id="tag_19_26_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied, clarifying the behavior if the first argument is `'-'`.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> XSI shading is removed from the **-h** functionality.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0046 \[52\], XCU/TC1-2008/0047 \[155,280\], XCU/TC1-2008/0048 \[52\], XCU/TC1-2008/0049 \[52\], and XCU/TC1-2008/0050 \[155,430\] are applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0053 \[584\], XCU/TC2-2008/0054 \[717\], XCU/TC2-2008/0055 \[717\], and XCU/TC2-2008/0056 \[960\] are applied.

#### <span id="tag_19_26_24"></span>Issue 8

> Austin Group Defect 559 is applied, changing the description of the **-u** option.
>
> Austin Group Defect 789 is applied, adding **-o** *pipefail*.
>
> Austin Group Defect 981 is applied, changing the description of the **-o** *nolog* option and the FUTURE DIRECTIONS section.
>
> Austin Group Defects 1009 and 1555 are applied, changing the description of the **-a** option.
>
> Austin Group Defect 1016 is applied, changing the description of the **-C** option.
>
> Austin Group Defect 1055 is applied, adding a paragraph about the **-n** option to the APPLICATION USAGE section.
>
> Austin Group Defect 1063 is applied, changing the description of the **-h** option.
>
> Austin Group Defect 1150 is applied, changing the description of the **-e** option.
>
> Austin Group Defect 1207 is applied, clarifying which option-arguments of the **-o** option are related to the User Portability Utilities option.
>
> Austin Group Defect 1254 is applied, changing the descriptions of the **-b** and **-m** options.
>
> Austin Group Defect 1384 is applied, allowing subshells of interactive shells to ignore the **-n** option.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="shift"></span> <span id="tag_19_27"></span>

#### <span id="tag_19_27_01"></span>NAME

> shift — shift positional parameters

#### <span id="tag_19_27_02"></span>SYNOPSIS

> `shift`` `**`[`***`n`***`]`**

#### <span id="tag_19_27_03"></span>DESCRIPTION

> The positional parameters shall be shifted. Positional parameter 1 shall be assigned the value of parameter (1+*n*), parameter 2 shall be assigned the value of parameter (2+*n*), and so on. The parameters represented by the numbers `"$#"` down to `"$#-n+1"` shall be unset, and the parameter `'#'` is updated to reflect the new number of positional parameters.
>
> The value *n* shall be an unsigned decimal integer less than or equal to the value of the special parameter `'#'`. If *n* is not given, it shall be assumed to be 1. If *n* is 0, the positional and special parameters are not changed.

#### <span id="tag_19_27_04"></span>OPTIONS

> None.

#### <span id="tag_19_27_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_27_06"></span>STDIN

> Not used.

#### <span id="tag_19_27_07"></span>INPUT FILES

> None.

#### <span id="tag_19_27_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_27_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_27_10"></span>STDOUT

> Not used.

#### <span id="tag_19_27_11"></span>STDERR

> The standard error shall be used only for diagnostic messages and the warning message specified in EXIT STATUS.

#### <span id="tag_19_27_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_27_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_27_14"></span>EXIT STATUS

> If the *n* operand is invalid or is greater than `"$#"`, this may be treated as an error and a non-interactive shell may exit; if the shell does not exit in this case, a non-zero exit status shall be returned and a warning message shall be written to standard error. Otherwise, zero shall be returned.

#### <span id="tag_19_27_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_27_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_19_27_17"></span>EXAMPLES

> 
>
>     $
>      set a b c d e
>
>     $
>      shift 2
>
>     $
>      echo $*
>
>     c d e

#### <span id="tag_19_27_18"></span>RATIONALE

> None.

#### <span id="tag_19_27_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_27_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)

#### <span id="tag_19_27_21"></span>CHANGE HISTORY

#### <span id="tag_19_27_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_27_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0051 \[459\] is applied.

#### <span id="tag_19_27_24"></span>Issue 8

> Austin Group Defect 1265 is applied, updating the EXIT STATUS and STDERR sections to align with the changes made to [2.8.1 Consequences of Shell Errors](#tag_19_08_01) between Issue 6 and Issue 7.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="times"></span> <span id="tag_19_28"></span>

#### <span id="tag_19_28_01"></span>NAME

> times — write process times

#### <span id="tag_19_28_02"></span>SYNOPSIS

> `times`

#### <span id="tag_19_28_03"></span>DESCRIPTION

> The [*times*](#times) utility shall write the accumulated user and system times for the shell and for all of its child processes, in the following POSIX locale format:
>
>
>     "%dm%fs %dm%fs\n%dm%fs %dm%fs\n", <shell user minutes>,
>         <shell user seconds>, <shell system minutes>,
>         <shell system seconds>, <children user minutes>,
>         <children user seconds>, <children system minutes>,
>         <children system seconds>
>
> The four pairs of times shall correspond to the members of the [*\<sys/times.h\>*](../basedefs/sys_times.h.html) **tms** structure (defined in XBD [*14. Headers*](../basedefs/V1_chap14.html#tag_14)) as returned by [*times*()](../functions/times.html): *tms_utime*, *tms_stime*, *tms_cutime*, and *tms_cstime*, respectively.

#### <span id="tag_19_28_04"></span>OPTIONS

> None.

#### <span id="tag_19_28_05"></span>OPERANDS

> None.

#### <span id="tag_19_28_06"></span>STDIN

> Not used.

#### <span id="tag_19_28_07"></span>INPUT FILES

> None.

#### <span id="tag_19_28_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_28_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_28_10"></span>STDOUT

> See the DESCRIPTION.

#### <span id="tag_19_28_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_28_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_28_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_28_14"></span>EXIT STATUS

>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_19_28_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_28_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_19_28_17"></span>EXAMPLES

> 
>
>     $
>      times
>
>     0m0.43s 0m1.11s
>     8m44.18s 1m43.23s

#### <span id="tag_19_28_18"></span>RATIONALE

> The [*times*](#times) special built-in from the Single UNIX Specification is now required for all conforming shells.

#### <span id="tag_19_28_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_28_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)
>
> XBD [*\<sys/times.h\>*](../basedefs/sys_times.h.html)

#### <span id="tag_19_28_21"></span>CHANGE HISTORY

#### <span id="tag_19_28_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/9 is applied, changing text in the DESCRIPTION from: "Write the accumulated user and system times for the shell and for all of its child processes ..." to: "The [*times*](#times) utility shall write the accumulated user and system times for the shell and for all of its child processes ...".

#### <span id="tag_19_28_23"></span>Issue 7

> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0056 \[960\] is applied.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="trap"></span> <span id="tag_19_29"></span>

#### <span id="tag_19_29_01"></span>NAME

> trap — trap signals

#### <span id="tag_19_29_02"></span>SYNOPSIS

> `trap`` `*`n`*` `**`[`***`condition`*`...`**`]`**\
> ` `\
> `trap -p`` `**`[`***`condition`*`...`**`]`**\
> ` `\
> `trap`` `**`[`***`action condition`*`...`**`]`**

#### <span id="tag_19_29_03"></span>DESCRIPTION

> If the **-p** option is not specified and the first operand is an unsigned decimal integer, the shell shall treat all operands as conditions, and shall reset each condition to the default value. Otherwise, if the **-p** option is not specified and there are operands, the first operand shall be treated as an action and the remaining as conditions.
>
> If *action* is `'-'`, the shell shall reset each *condition* to the default value. If *action* is null (`""`), the shell shall ignore each specified *condition* if it arises. Otherwise, the argument *action* shall be read and executed by the shell when one of the corresponding conditions arises. The action of [*trap*](#trap) shall override a previous action (either default action or one explicitly set). The value of `"$?"` after the [*trap*](#trap) action completes shall be the value it had before the [*trap*](#trap) action was executed.
>
> The condition can be EXIT, 0 (equivalent to EXIT), or a signal specified using a symbolic name, without the SIG prefix, as listed in the tables of signal names in the [*\<signal.h\>*](../basedefs/signal.h.html) header defined in XBD [*14. Headers*](../basedefs/V1_chap14.html#tag_14); for example, HUP, INT, QUIT, TERM. Implementations may permit names with the SIG prefix or ignore case in signal names as an extension. Setting a trap for SIGKILL or SIGSTOP produces undefined results.
>
> The EXIT condition shall occur when the shell terminates normally (exits), and may occur when the shell terminates abnormally as a result of delivery of a signal (other than SIGKILL) whose [*trap*](#trap) action is the default.
>
> The environment in which the shell executes a [*trap*](#trap) action on EXIT shall be identical to the environment immediately after the last command executed before the [*trap*](#trap) action on EXIT was executed.
>
> If *action* is neither `'-'` nor the empty string, then each time a matching *condition* arises, the *action* shall be executed in a manner equivalent to:
>
>
>     eval action
>
> Signals that were ignored on entry to a non-interactive shell cannot be trapped or reset, although no error need be reported when attempting to do so. An interactive shell may reset or catch signals ignored on entry. Traps shall remain in place for a given shell until explicitly changed with another [*trap*](#trap) command.
>
> When a subshell is entered, traps that are not being ignored shall be set to the default actions, except in the case of a command substitution containing only a single [*trap*](#trap) command, when the traps need not be altered. Implementations may check for this case using only lexical analysis; for example, if `` `trap` `` and `$( trap -- )` do not alter the traps in the subshell, cases such as assigning `var=trap` and then using `$($var)` may still alter them. This does not imply that the [*trap*](#trap) command cannot be used within the subshell to set new traps.
>
> The [*trap*](#trap) command with no operands shall write to standard output a list of commands associated with each of a set of conditions; if the **-p** option is not specified, this set shall contain only the conditions that are not in the default state (including signals that were ignored on entry to a non-interactive shell); if the **-p** option is specified, the set shall contain all conditions, except that it is unspecified whether conditions corresponding to the SIGKILL and SIGSTOP signals are included in the set. If the command is executed in a subshell, the implementation does not perform the optional check described above for a command substitution containing only a single [*trap*](#trap) command, and no [*trap*](#trap) commands with operands have been executed since entry to the subshell, the list shall contain the commands that were associated with each condition immediately before the subshell environment was entered. Otherwise, the list shall contain the commands currently associated with each condition. The format shall be:
>
>
>     "trap -- %s %s ...\n", <action>, <condition> ...
>
> The shell shall format the output, including the proper use of quoting, so that it is suitable for reinput to the shell as commands that achieve the same trapping results for the set of conditions included in the output, except for signals that were ignored on entry to the shell as described above. If this set includes conditions corresponding to the SIGKILL and SIGSTOP signals, the shell shall accept them when the output is reinput to the shell (where accepting them means they do not cause a non-zero exit status, a diagnostic message, or undefined behavior). For example:
>
>
>     save_traps=$(trap -p)
>
>
>     ...
>     eval "$save_traps"
>
> or:
>
>
>     save_traps=$(trap -p INT QUIT)
>     trap "some command" INT QUIT
>
>
>     ...
>
>
>     eval "$save_traps"
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> XSI-conformant systems also allow numeric signal numbers for the conditions corresponding to the following signal names:
>
> 1
>
> SIGHUP
>
> 2
>
> SIGINT
>
> 3
>
> SIGQUIT
>
> 6
>
> SIGABRT
>
> 9
>
> SIGKILL
>
> 14
>
> SIGALRM
>
> 15
>
> SIGTERM
>
> <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> If an invalid signal name <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  or number <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> is specified, the [*trap*](#trap) utility shall write a warning message to standard error.
>
> The [*trap*](#trap) special built-in shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).

#### <span id="tag_19_29_04"></span>OPTIONS

> The following option shall be supported:
>
> **-p**
>
> Write to standard output a list of commands associated with each *condition* operand. The behavior when there are no operands is specified in the DESCRIPTION section.
>
> The shell shall format the output, including the proper use of quoting, so that it is suitable for reinput to the shell as commands that achieve the same trapping results for the specified set of conditions. If a *condition* operand is a condition corresponding to the SIGKILL or SIGSTOP signal, and [*trap*](#trap) **-p** without any operands would not include it in the set of conditions for which it writes output, the behavior is undefined if the output is reinput to the shell.

#### <span id="tag_19_29_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_29_06"></span>STDIN

> Not used.

#### <span id="tag_19_29_07"></span>INPUT FILES

> None.

#### <span id="tag_19_29_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_29_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_29_10"></span>STDOUT

> See the DESCRIPTION.

#### <span id="tag_19_29_11"></span>STDERR

> The standard error shall be used only for diagnostic messages and warning messages about invalid signal names <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  or numbers. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_19_29_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_29_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_29_14"></span>EXIT STATUS

> If the trap name <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  or number <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> is invalid, a non-zero exit status shall be returned; otherwise, zero shall be returned. For both interactive and non-interactive shells, invalid signal names <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  or numbers <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> shall not be considered an error and shall not cause the shell to abort.

#### <span id="tag_19_29_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_29_16"></span>APPLICATION USAGE

> When the **-p** option is not used, since [*trap*](#trap) with no operands does not output commands to restore traps that are currently set to default, these need to be restored separately. The RATIONALE section shows examples and describes their drawbacks.

#### <span id="tag_19_29_17"></span>EXAMPLES

> Write out a list of all traps and actions:
>
>
>     trap
>
> Set a trap so the *logout* utility in the directory referred to by the *HOME* environment variable executes when the shell terminates:
>
>
>     trap '"$HOME"/logout' EXIT
>
> or:
>
>
>     trap '"$HOME"/logout' 0
>
> Unset traps on INT, QUIT, TERM, and EXIT:
>
>
>     trap - INT QUIT TERM EXIT

#### <span id="tag_19_29_18"></span>RATIONALE

> Implementations may permit lowercase signal names as an extension. Implementations may also accept the names with the SIG prefix; no known historical shell does so. The [*trap*](#trap) and [*kill*](../utilities/kill.html) utilities in this volume of POSIX.1-2024 are now consistent in their omission of the SIG prefix for signal names. Some [*kill*](../utilities/kill.html) implementations do not allow the prefix, and [*kill*](../utilities/kill.html) **-l** lists the signals without prefixes.
>
> Trapping SIGKILL or SIGSTOP is syntactically accepted by some historical implementations, but it has no effect. Portable POSIX applications cannot attempt to trap these signals.
>
> The output format is not historical practice. Since the output of historical [*trap*](#trap) commands is not portable (because numeric signal values are not portable) and had to change to become so, an opportunity was taken to format the output in a way that a shell script could use to save and then later reuse a trap if it wanted.
>
> The KornShell uses an **ERR** trap that is triggered whenever [*set*](#set) **-e** would cause an exit. This is allowable as an extension, but was not mandated, as other shells have not used it.
>
> The text about the environment for the EXIT trap invalidates the behavior of some historical versions of interactive shells which, for example, close the standard input before executing a trap on 0. For example, in some historical interactive shell sessions the following trap on 0 would always print `"--"`:
>
>
>     trap 'read foo; echo "-$foo-"' 0
>
> The command:
>
>
>     trap 'eval " $cmd"' 0
>
> causes the contents of the shell variable *cmd* to be executed as a command when the shell exits. Using:
>
>
>     trap '$cmd' 0
>
> does not work correctly if *cmd* contains any special characters such as quoting or redirections. Using:
>
>
>     trap " $cmd" 0
>
> also works (the leading \<space\> character protects against unlikely cases where *cmd* is a decimal integer or begins with `'-'`), but it expands the *cmd* variable when the [*trap*](#trap) command is executed, not when the exit action is executed.
>
> The **-p** option was added because without it the method used to restore traps needs to include special handling of traps that are set to default when [*trap*](#trap) with no operands is used to save the current traps. One example is:
>
>
>     save_traps=$(trap)
>     trap "some command" INT QUIT
>     save_traps="trap - INT QUIT; $save_traps"
>
>
>     ...
>
>
>     eval "$save_traps"
>
> but this method relies on hard-coding the commands to reset the traps that are being set. It also has a race condition if INT or QUIT was not set to default when saved, since it first sets them to default and then restores the saved traps. A more general approach would be:
>
>
>     save_traps=$(trap)
>     ...
>     for sig in EXIT $( kill -l )
>     do
>         case "$sig" in
>         SIGKILL | KILL | sigkill | kill | SIGSTOP | STOP | sigstop | stop)
>         ;;
>         *) trap - $sig
>         ;;
>         esac
>     done
>     eval "$save_traps"
>
> This has the same race condition since it first sets all traps (that can be set) to default and then restores those that were not previously set to default.
>
> Historically, some shells behaved the same with and without **-p** when there are no operands. This standard requires that the set of conditions differs between the two cases: with **-p** it is all conditions (except possibly SIGKILL and SIGSTOP); without **-p** it is only the conditions that are not in the default state.

#### <span id="tag_19_29_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_29_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)
>
> XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), [*\<signal.h\>*](../basedefs/signal.h.html)

#### <span id="tag_19_29_21"></span>CHANGE HISTORY

#### <span id="tag_19_29_22"></span>Issue 6

> XSI-conforming implementations provide the mapping of signal names to numbers given above (previously this had been marked obsolescent). Other implementations need not provide this optional mapping.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_29_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> Austin Group Interpretation 1003.1-2001 \#116 is applied.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0052 \[53,268,440\], XCU/TC1-2008/0053 \[53,268,440\], XCU/TC1-2008/0054 \[163\], XCU/TC1-2008/0055 \[163\], and XCU/TC1-2008/0056 \[163\] are applied.

#### <span id="tag_19_29_24"></span>Issue 8

> Austin Group Defect 621 is applied, clarifying when the EXIT condition occurs.
>
> Austin Group Defect 1029 is applied, clarifying the execution of [*trap*](#trap) actions.
>
> Austin Group Defects 1211 and 1212 are applied, adding the **-p** option and clarifying that, when **-p** is not specified, the output of [*trap*](#trap) with no operands does not list conditions that are in the default state.
>
> Austin Group Defect 1265 is applied, updating the DESCRIPTION, STDERR and EXIT STATUS sections to align with the changes made to [2.8.1 Consequences of Shell Errors](#tag_19_08_01) between Issue 6 and Issue 7.
>
> Austin Group Defect 1285 is applied, inserting a blank line between the two SYNOPSIS lines.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

<span id="unset"></span> <span id="tag_19_30"></span>

#### <span id="tag_19_30_01"></span>NAME

> unset — unset values and attributes of variables and functions

#### <span id="tag_19_30_02"></span>SYNOPSIS

> `unset`` `**`[`**`-fv`**`]`**` `*`name`*`...`

#### <span id="tag_19_30_03"></span>DESCRIPTION

> The [*unset*](#unset) utility shall unset each variable or function definition specified by *name* that does not have the *readonly* attribute and remove any attributes other than *readonly* that have been given to *name* (see [2.15 Special Built-In Utilities](#tag_19_15) *export* and *readonly*).
>
> If **-v** is specified, *name* refers to a variable name and the shell shall unset it and remove it from the environment. Read-only variables cannot be unset.
>
> If **-f** is specified, *name* refers to a function and the shell shall unset the function definition.
>
> If neither **-f** nor **-v** is specified, *name* refers to a variable; if a variable by that name does not exist, it is unspecified whether a function by that name, if any, shall be unset.
>
> Unsetting a variable or function that was not previously set shall not be considered an error and does not cause the shell to abort.
>
> The [*unset*](#unset) special built-in shall support XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> Note that:
>
>
>     VARIABLE=
>
> is not equivalent to an [*unset*](#unset) of **VARIABLE**; in the example, **VARIABLE** is set to `""`. Also, the variables that can be [*unset*](#unset) should not be misinterpreted to include the special parameters (see [2.5.2 Special Parameters](#tag_19_05_02)).

#### <span id="tag_19_30_04"></span>OPTIONS

> See the DESCRIPTION.

#### <span id="tag_19_30_05"></span>OPERANDS

> See the DESCRIPTION.

#### <span id="tag_19_30_06"></span>STDIN

> Not used.

#### <span id="tag_19_30_07"></span>INPUT FILES

> None.

#### <span id="tag_19_30_08"></span>ENVIRONMENT VARIABLES

> None.

#### <span id="tag_19_30_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_19_30_10"></span>STDOUT

> Not used.

#### <span id="tag_19_30_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_19_30_12"></span>OUTPUT FILES

> None.

#### <span id="tag_19_30_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_19_30_14"></span>EXIT STATUS

>  0
>
> All *name* operands were successfully unset.
>
> \>0
>
> At least one *name* could not be unset.

#### <span id="tag_19_30_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_19_30_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_19_30_17"></span>EXAMPLES

> Unset *VISUAL* variable:
>
>
>     unset -v VISUAL
>
> Unset the functions **foo** and **bar**:
>
>
>     unset -f foo bar

#### <span id="tag_19_30_18"></span>RATIONALE

> Consideration was given to omitting the **-f** option in favor of an *unfunction* utility, but the standard developers decided to retain historical practice.
>
> The **-v** option was introduced because System V historically used one name space for both variables and functions. When [*unset*](#unset) is used without options, System V historically unset either a function or a variable, and there was no confusion about which one was intended. A portable POSIX application can use [*unset*](#unset) without an option to unset a variable, but not a function; the **-f** option must be used.

#### <span id="tag_19_30_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_19_30_20"></span>SEE ALSO

> [2.15 Special Built-In Utilities](#tag_19_15)
>
> XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_19_30_21"></span>CHANGE HISTORY

#### <span id="tag_19_30_22"></span>Issue 6

> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/5 is applied so that the reference page sections use terms as described in the Utility Description Defaults ( [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)). No change in behavior is intended.

#### <span id="tag_19_30_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_19_30_24"></span>Issue 8

> Austin Group Defect 1075 is applied, clarifying that [*unset*](#unset) removes attributes, other than *readonly*, from the variables it unsets.

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------
