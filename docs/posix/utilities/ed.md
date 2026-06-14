The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="ed"></span> <span id="tag_20_38"></span>

#### <span id="tag_20_38_01"></span>NAME

> ed — edit text

#### <span id="tag_20_38_02"></span>SYNOPSIS

> `ed`` `**`[`**`-p`` `*`string`***`] [`**`-s`**`] [`***`file`***`]`**

#### <span id="tag_20_38_03"></span>DESCRIPTION

> The *ed* utility is a line-oriented text editor that uses two modes: *command mode* and *input mode*. In command mode the input characters shall be interpreted as commands, and in input mode they shall be interpreted as text. See the EXTENDED DESCRIPTION section.
>
> If an operand is `'-'`, the results are unspecified.

#### <span id="tag_20_38_04"></span>OPTIONS

> The *ed* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except for the unspecified usage of `'-'`.
>
> The following options shall be supported:
>
> **-p ***string*
>
> Use *string* as the prompt string when in command mode. By default, there shall be no prompt string.
>
> **-s**
>
> Suppress the writing of byte counts by **e**, **E**, **r**, and **w** commands and of the `'!'` prompt after a !*command*.

#### <span id="tag_20_38_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> If the *file* argument is given, *ed* shall perform the effect of an **e** command on the pathname *file* before accepting commands from the standard input, except that *file* can contain a \<newline\>, even though this is not possible for the argument to the **e** command.

#### <span id="tag_20_38_06"></span>STDIN

> The standard input shall be a text file consisting of commands, as described in the EXTENDED DESCRIPTION section.

#### <span id="tag_20_38_07"></span>INPUT FILES

> The input files shall be text files.

#### <span id="tag_20_38_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *ed*:
>
> *HOME*
>
> Determine the pathname of the user's home directory.
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and the behavior of character classes within regular expressions.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_38_09"></span>ASYNCHRONOUS EVENTS

> The *ed* utility shall take the standard action for all signals (see the ASYNCHRONOUS EVENTS section in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)) with the following exceptions:
>
> SIGINT
>
> The *ed* utility shall interrupt its current activity, write the string `"?\n"` to standard output, and return to command mode (see the EXTENDED DESCRIPTION section).
>
> SIGHUP
>
> If the buffer is not empty and the buffer change flag is currently set to either **changed** or **changed-and-warned** (see the EXTENDED DESCRIPTION section), the *ed* utility shall attempt to write a copy of the buffer in a file. First, the file named **ed.hup** in the current directory shall be used; if that fails, the file named **ed.hup** in the directory named by the *HOME* environment variable shall be used. In any case, the *ed* utility shall exit without writing the file to the currently remembered pathname and without returning to command mode.
>
> SIGQUIT
>
> The *ed* utility shall ignore this event.

#### <span id="tag_20_38_10"></span>STDOUT

> Various editing commands and the prompting feature (see **-p**) write to standard output, as described in the EXTENDED DESCRIPTION section.

#### <span id="tag_20_38_11"></span>STDERR

> The standard error shall be used for diagnostic messages and may be used for warning messages.

#### <span id="tag_20_38_12"></span>OUTPUT FILES

> The output files shall be text files whose formats are dependent on the editing commands given.

#### <span id="tag_20_38_13"></span>EXTENDED DESCRIPTION

> The *ed* utility shall operate on a copy of the file it is editing; changes made to the copy shall have no effect on the file until a **w** (write) command is given. The copy of the text is called the *buffer*. The *ed* utility shall keep track of whether the buffer has been modified. This shall be maintained as if via a tri-state internal flag with the state values **unchanged**, **changed**, and **changed-and-warned**, which is:
>
> - Initially set to **unchanged**
>
> - Set to **changed** by any command that modifies the buffer
>
> - Set to **unchanged** by an **e** or **E** command that reloads (or empties) the buffer, or a **w** command that writes the entire buffer
>
> - Set to either **changed-and-warned** or **unchanged** by an **e** or **q** command that warns an attempt was made to destroy the editor buffer
>
> A command that makes changes to the buffer in such a way that its contents are the same after the command (for example **s/a/a/**) shall be considered to have modified the buffer, unless explicitly stated otherwise. In the remainder of the description, this flag is referred to as the *buffer change flag*.
>
> Commands to *ed* have a simple and regular structure: zero, one, or two *addresses* followed by a single-character *command*, possibly followed by parameters to that command. These addresses specify one or more lines in the buffer. Every command that requires addresses has default addresses, so that the addresses very often can be omitted. If the **-p** option is specified, the prompt string shall be written to standard output before each command is read.
>
> In general, only one command can appear on a line. Certain commands allow text to be input. This text is placed in the appropriate place in the buffer. While *ed* is accepting text, it is said to be in *input mode*. In this mode, no commands shall be recognized; all input is merely collected. Input mode is terminated by entering a line consisting of two characters: a \<period\> (`'.'`) followed by a \<newline\>. This line is not considered part of the input text.
>
> ##### <span id="tag_20_38_13_01"></span>Regular Expressions in ed
>
> The *ed* utility shall support basic regular expressions, as described in XBD [*9.3 Basic Regular Expressions*](../basedefs/V1_chap09.html#tag_09_03). Since regular expressions in *ed* are always matched against single lines (excluding the terminating \<newline\> characters), never against any larger section of text, there is no way for a regular expression to match a \<newline\>.
>
> A null RE shall be equivalent to the last RE encountered.
>
> Regular expressions are used in addresses to specify lines, and in some commands (for example, the **s** substitute command) to specify portions of a line to be substituted.
>
> The start and end of a regular expression (RE) are marked by a delimiter character (although in some circumstances the end delimiter can be omitted). In addresses, the delimiter is either \<slash\> or \<question-mark\>. In commands, other characters can be used as the delimiter, as specified in the description of the command. Within the RE (as an *ed* extension to the BRE syntax), the delimiter shall not terminate the RE if it is the second character of an escape sequence (see XBD [*9.1 Regular Expression Definitions*](../basedefs/V1_chap09.html#tag_09_01)) and the escaped delimiter shall be treated as that literal character in the RE (losing any special meaning it would have had if it was not used as the delimiter and was not escaped). In addition, the delimiter character shall not terminate the RE when it appears within a bracket expression, and shall have its normal meaning in the bracket expression. For example, the command `"g%[%]%p"` is equivalent to `"g/[%]/p"`, and the command `"s-[0-9]--g"` is equivalent to `"s/[0-9]//g"`.
>
> ##### <span id="tag_20_38_13_02"></span>Addresses in ed
>
> Addressing in *ed* relates to the current line. Generally, the current line is the last line affected by a command. The current line number is the address of the current line. If the edit buffer is not empty, the initial value for the current line shall be the last line in the edit buffer; otherwise, zero.
>
> Addresses shall be constructed as follows:
>
> 1.  The \<period\> character (`'.'`) shall address the current line.
>
> 2.  The \<dollar-sign\> character (`'$'`) shall address the last line of the edit buffer.
>
> 3.  The positive decimal number *n* shall address the *n*th line of the edit buffer.
>
> 4.  The \<apostrophe\>-x character pair (`"'x"`) shall address the line marked with the mark name character *x*, which shall be a lowercase letter from the portable character set. It shall be an error if the character has not been set to mark a line or if the line that was marked is not currently present in the edit buffer.
>
> 5.  A BRE enclosed by \<slash\> characters (`'/'`) shall address the first line found by searching forwards from the line following the current line toward the end of the edit buffer and stopping at the first line for which the line excluding the terminating \<newline\> matches the BRE. The BRE consisting of a null BRE delimited by a pair of \<slash\> characters shall address the next line for which the line excluding the terminating \<newline\> matches the last BRE encountered. In addition, the second \<slash\> can be omitted at the end of a command line. Within the BRE, a \<backslash\>-\<slash\> pair (`"\/"`) shall represent a literal \<slash\> instead of the BRE delimiter. If necessary, the search shall wrap around to the beginning of the buffer and continue up to and including the current line, so that the entire buffer is searched.
>
> 6.  A BRE enclosed by \<question-mark\> characters (`'?'`) shall address the first line found by searching backwards from the line preceding the current line toward the beginning of the edit buffer and stopping at the first line for which the line excluding the terminating \<newline\> matches the BRE. The BRE consisting of a null BRE delimited by a pair of \<question-mark\> characters (`"??"`) shall address the previous line for which the line excluding the terminating \<newline\> matches the last BRE encountered. In addition, the second \<question-mark\> can be omitted at the end of a command line. Within the BRE, a \<backslash\>-\<question-mark\> pair (`"\?"`) shall represent a literal \<question-mark\> instead of the BRE delimiter. If necessary, the search shall wrap around to the end of the buffer and continue up to and including the current line, so that the entire buffer is searched.
>
> 7.  A \<plus-sign\> (`'+'`) or \<hyphen-minus\> character (`'-'`) followed by a decimal number shall address the current line plus or minus the number. A \<plus-sign\> or \<hyphen-minus\> character not followed by a decimal number shall address the current line plus or minus 1.
>
> Addresses can be followed by zero or more address offsets, optionally \<blank\>-separated. Address offsets are constructed as follows:
>
> - A \<plus-sign\> or \<hyphen-minus\> character followed by a decimal number shall add or subtract, respectively, the indicated number of lines to or from the address. A \<plus-sign\> or \<hyphen-minus\> character not followed by a decimal number shall add or subtract 1 to or from the address.
>
> - A decimal number shall add the indicated number of lines to the address.
>
> It shall not be an error for an intermediate address value to be less than zero or greater than the last line in the edit buffer. It shall be an error for the final address value to be less than zero or greater than the last line in the edit buffer. It shall be an error if a search for a BRE fails to find a matching line.
>
> Commands accept zero, one, or two addresses. If one or more addresses are provided to a command that requires zero addresses, it shall be an error. Otherwise, if more than the maximum number of accepted addresses are provided to a command, the addresses shall be evaluated from first to last and then discarded, until the maximum number of accepted addresses for that command remain.
>
> Addresses shall be separated from each other by a \<comma\> (`','`) or \<semicolon\> character (`';'`). In the case of a \<semicolon\> separator, the current line (`'.'`) shall be set to the first address, and only then shall the second address be calculated. This feature can be used to determine the starting line for forwards and backwards searches; see rules 5. and 6.
>
> Addresses can be omitted on either side of the \<comma\> or \<semicolon\> separator, in which case the resulting address pairs shall be as follows:
>
> | **Specified** | **Resulting** |
> |:--------------|:--------------|
> | ,             | 1 , \$        |
> | , addr        | 1 , addr      |
> | addr ,        | addr , addr   |
> | ;             | . ; \$        |
> | ; addr        | . ; addr      |
> | addr ;        | addr ; addr   |
>
> If an address is omitted between two separators, the rule shall be applied to the first separator and the resulting second address shall be used as the first address for the second separator. For example, with the address list `",,"` the first `','` becomes `"1,$"` and the `'$'` is treated as the first address for the second `','`, resulting in `"1,$,$"`.
>
> Any \<blank\> characters included between addresses, address separators, or address offsets shall be ignored.
>
> ##### <span id="tag_20_38_13_03"></span>Commands in ed
>
> In the following list of *ed* commands, the default addresses are shown in parentheses. The number of addresses shown in the default shall be the number expected by the command. The parentheses are not part of the address; they show that the given addresses are the default.
>
> It is generally invalid for more than one command to appear on a line. However, any command (except **e**, **E**, **f**, **q**, **Q**, **r**, **w**, and **!**) can be suffixed by the letter **l**, **n**, or **p**; in which case, except for the **l**, **n**, and **p** commands, the command shall be executed and then the new current line shall be written as described below under the **l**, **n**, and **p** commands. When an **l**, **n**, or **p** suffix is used with an **l**, **n**, or **p** command, the command shall write to standard output as described below, but it is unspecified whether the suffix writes the current line again in the requested format or whether the suffix has no effect. For example, the **pl** command (base **p** command with an **l** suffix) shall either write just the current line or write it twice—once as specified for **p** and once as specified for **l**. Also, the **g**, **G**, **v**, and **V** commands shall take a command as a parameter.
>
> Each address component can be preceded by zero or more \<blank\> characters. The command letter can be preceded by zero or more \<blank\> characters. If a suffix letter (**l**, **n**, or **p**) is given, the application shall ensure that it immediately follows the command.
>
> The **e**, **E**, **f**, **r**, and **w** commands shall take an optional *file* parameter, separated from the command letter by one or more \<blank\> characters.
>
> If the buffer change flag is currently set to **changed**, *ed* shall warn the user if an attempt is made to destroy the editor buffer via the **e** or **q** commands. The *ed* utility shall write the string:
>
>
>     "?\n"
>
> (followed by an explanatory message if *help mode* has been enabled via the **H** command) to standard output and shall continue in command mode with the buffer change flag set to either **changed-and-warned** or **unchanged** and the current line number unchanged. If another **e** or **q** command is then attempted with no intervening command that sets the buffer change flag to **changed**, it shall take effect.
>
> If a terminal disconnect (see XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11), Modem Disconnect and Closing a Device Terminal), is detected:
>
> - If accompanied by a SIGHUP signal, the *ed* utility shall operate as described in the ASYNCHRONOUS EVENTS section for a SIGHUP signal.
> - If not accompanied by a SIGHUP signal, the *ed* utility shall act as if an end-of-file had been detected on standard input.
>
> If an end-of-file is detected on standard input:
>
> - If the *ed* utility is in input mode, *ed* shall terminate input mode and return to command mode. It is unspecified if any partially entered lines (that is, input text without a terminating \<newline\>) are discarded from the input text.
> - If the *ed* utility is in command mode, it shall act as if a **q** command had been entered.
>
> In the following commands, if a closing delimiter would be the last character before a \<newline\> then that character can be omitted with the behavior shown:
>
> - For the **g** and **v** commands the addressed line(s) shall be written as if a closing delimiter followed by a **p** were appended to the command.
> - For the **G** and **V** commands no additional action shall be taken.
> - For the **s** command, only the closing delimiter of the replacement can be omitted, in which case the result of the substitution shall be written as if the **p** flag were appended.
> - For the null command, the addressed line(s) shall be written as if the closing delimiter were appended.
>
> For example, the following pairs of commands are equivalent:
>
>
>     s/s1/s2   s/s1/s2/p
>     g/s1      g/s1/p
>     ?s1       ?s1?
>
> If an invalid command is entered, *ed* shall write the string:
>
>
>     "?\n"
>
> (followed by an explanatory message if *help mode* has been enabled via the **H** command) to standard output and shall continue in command mode with the current line number unchanged.
>
> ##### <span id="tag_20_38_13_04"></span>Append Command
>
> *Synopsis*:
>
>
>     (.)a
>     <text>
>     .
>
> The **a** command shall read the given text and append it after the addressed line; the current line number shall become the address of the last inserted line or, if there were none, the addressed line. Address 0 shall be valid for this command; it shall cause the appended text to be placed at the beginning of the buffer. If \<*text*\> is empty (that is, the terminating `'.'` immediately follows the `'a'`), the buffer change flag shall not be altered.
>
> ##### <span id="tag_20_38_13_05"></span>Change Command
>
> *Synopsis*:
>
>
>     (.,.)c
>     <text>
>     .
>
> The **c** command shall delete the addressed lines, then accept input text that replaces these lines; the current line shall be set to the address of the last line input; or, if there were none, at the line after the last line deleted; if the lines deleted were originally at the end of the buffer, the current line number shall be set to the address of the new last line; if no lines remain in the buffer, the current line number shall be set to zero.
>
> ##### <span id="tag_20_38_13_06"></span>Delete Command
>
> *Synopsis*:
>
>
>     (.,.)d
>
> The **d** command shall delete the addressed lines from the buffer. The address of the line after the last line deleted shall become the current line number; if the lines deleted were originally at the end of the buffer, the current line number shall be set to the address of the new last line; if no lines remain in the buffer, the current line number shall be set to zero.
>
> ##### <span id="tag_20_38_13_07"></span>Edit Command
>
> *Synopsis*:
>
>
>     e [file]
>
> The **e** command shall delete the entire contents of the buffer and then read in the file named by the pathname *file*. The current line number shall be set to the address of the last line of the buffer. If no pathname is given, the currently remembered pathname, if any, shall be used (see the **f** command). If the pathname names a file that does not exist and the buffer change flag is currently set to **unchanged**, it is unspecified whether this is treated as an error, or whether the resulting buffer is emptied and a warning is written to standard error instead of writing the byte count to standard out. The number of bytes read shall be written to standard output, unless the **-s** option was specified, in the following format:
>
>
>     "%d\n", <number of bytes read>
>
> The name *file* shall be remembered for possible use as a default pathname in subsequent **e**, **E**, **r**, and **w** commands. If *file* is replaced by `'!'`, the rest of the line shall be taken to be a shell command line whose output is to be read. Such a shell command line shall not be remembered as the current *file*. All marks shall be discarded upon the completion of a successful **e** command. If the buffer change flag is currently set to **changed**, the user shall be warned, as described previously.
>
> ##### <span id="tag_20_38_13_08"></span>Edit Without Checking Command
>
> *Synopsis*:
>
>
>     E [file]
>
> The **E** command shall possess all properties and restrictions of the **e** command except that the editor shall not check the current state of the buffer change flag.
>
> ##### <span id="tag_20_38_13_09"></span>Filename Command
>
> *Synopsis*:
>
>
>     f [file]
>
> If *file* is given, the **f** command shall change the currently remembered pathname to *file*, whether or not *file* names an existing file; whether the name is changed or not, it shall then write the (possibly new) currently remembered pathname to the standard output in the following format:
>
>
>     "%s\n", <pathname>
>
> The current line number shall be unchanged.
>
> ##### <span id="tag_20_38_13_10"></span>Global Command
>
> *Synopsis*:
>
>
>     (1,$)g/RE/command list
>
> In the **g** command, the first step shall be to mark every line for which the line excluding the terminating \<newline\> matches the given RE. Then, going sequentially from the beginning of the file to the end of the file, the given *command list* shall be executed for each marked line, with the current line number set to the address of that line. Any line modified by the *command list* shall be unmarked. When the **g** command completes, the current line number shall have the value assigned by the last command in the *command list*. If there were no matching lines, the current line number shall not be changed. A single command or the first of a list of commands shall appear on the same line as the global command. All lines of a multi-line list except the last line shall be ended with a \<backslash\> preceding the terminating \<newline\>; the **a**, **i**, and **c** commands and associated input are permitted. The `'.'` terminating input mode can be omitted if it would be the last line of the *command list*. An empty *command list* shall be equivalent to the **p** command. The use of the **g**, **G**, **v**, **V**, and **!** commands in the *command list* produces undefined results. Any character other than \<backslash\>, \<space\>, or \<newline\> can be used instead of a \<slash\> to delimit the RE. Within the RE, in certain circumstances the RE delimiter can be used as a literal character; see [Regular Expressions in ed](#tag_20_38_13_01).
>
> ##### <span id="tag_20_38_13_11"></span>Interactive Global Command
>
> *Synopsis*:
>
>
>     (1,$)G/RE/
>
> In the **G** command, the first step shall be to mark every line for which the line excluding the terminating \<newline\> matches the given RE. Then, for every such line, that line shall be written, the current line number shall be set to the address of that line, and any one command (other than one of the **a**, **c**, **i**, **g**, **G**, **v**, and **V** commands) shall be read and executed. A \<newline\> shall act as a null command (causing no action to be taken on the current line); an `'&'` shall cause the re-execution of the most recent non-null command executed within the current invocation of **G**. Note that the commands input as part of the execution of the **G** command can address and affect any lines in the buffer. Any line modified by the command shall be unmarked. The final value of the current line number shall be the value set by the last command successfully executed. (Note that the last command successfully executed shall be the **G** command itself if a command fails or the null command is specified.) If there were no matching lines, the current line number shall not be changed. The **G** command can be terminated by a SIGINT signal. Any character other than \<backslash\>, \<space\>, or \<newline\> can be used instead of a \<slash\> to delimit the RE. Within the RE, in certain circumstances the RE delimiter can be used as a literal character; see [Regular Expressions in ed](#tag_20_38_13_01).
>
> ##### <span id="tag_20_38_13_12"></span>Help Command
>
> *Synopsis*:
>
>
>     h
>
> The **h** command shall write a short message to standard output that explains the reason for the most recent `'?'` notification. The current line number shall be unchanged.
>
> ##### <span id="tag_20_38_13_13"></span>Help-Mode Command
>
> *Synopsis*:
>
>
>     H
>
> The **H** command shall cause *ed* to enter a mode in which help messages (see the **h** command) shall be written to standard output for all subsequent `'?'` notifications. The **H** command alternately shall turn this mode on and off; it is initially off. If the help-mode is being turned on, the **H** command also explains the previous `'?'` notification, if there was one. The current line number shall be unchanged.
>
> ##### <span id="tag_20_38_13_14"></span>Insert Command
>
> *Synopsis*:
>
>
>     (.)i
>     <text>
>     .
>
> The **i** command shall insert the given text before the addressed line; the current line is set to the last inserted line or, if there was none, to the addressed line. This command differs from the **a** command only in the placement of the input text. Address 0 shall be valid for this command; it is unspecified whether it causes the inserted text to be placed at the beginning of the buffer or it is interpreted as if address 1 were specified. (These two allowed behaviors differ in the case that the buffer is empty.) If \<*text*\> is empty (that is, the terminating `'.'` immediately follows the `'i'`), the buffer change flag shall not be altered.
>
> ##### <span id="tag_20_38_13_15"></span>Join Command
>
> *Synopsis*:
>
>
>     (.,.+1)j
>
> The **j** command shall join contiguous lines by removing the appropriate \<newline\> characters. If exactly one address is given, this command shall do nothing. If lines are joined, the current line number shall be set to the address of the joined line; otherwise, the current line number shall be unchanged.
>
> ##### <span id="tag_20_38_13_16"></span>Mark Command
>
> *Synopsis*:
>
>
>     (.)kx
>
> The **k** command shall mark the addressed line with name *x*, which the application shall ensure is a lowercase letter from the portable character set. The address `"'x"` shall then refer to this line; the current line number shall be unchanged.
>
> ##### <span id="tag_20_38_13_17"></span>List Command
>
> *Synopsis*:
>
>
>     (.,.)l
>
> The **l** command shall write to standard output the addressed lines in a visually unambiguous form. The characters listed in XBD [*Escape Sequences and Associated Actions*](../basedefs/V1_chap05.html#tagtcjh_2) (`'\\'`, `'\a'`, `'\b'`, `'\f'`, `'\r'`, `'\t'`, `'\v'`) shall be written as the corresponding escape sequence; the `'\n'` in that table is not applicable. Non-printable characters not in the table shall be written as one three-digit octal number (with a preceding \<backslash\> character) for each byte in the character (most significant byte first).
>
> Long lines shall be folded, with the point of folding indicated by \<newline\> preceded by a \<backslash\>; the length at which folding occurs is unspecified, but should be appropriate for the output device. The end of each line shall be marked with a `'$'`, and `'$'` characters within the text shall be written with a preceding \<backslash\>. An **l** command can be appended to any other command other than **e**, **E**, **f**, **q**, **Q**, **r**, **w**, or **!**. The current line number shall be set to the address of the last line written.
>
> ##### <span id="tag_20_38_13_18"></span>Move Command
>
> *Synopsis*:
>
>
>     (.,.)maddress
>
> The **m** command shall reposition the addressed lines after the line addressed by *address*. Address 0 shall be valid for *address* and cause the addressed lines to be moved to the beginning of the buffer. It shall be an error if address *address* falls within the range of moved lines. The current line number shall be set to the address of the last line moved.
>
> ##### <span id="tag_20_38_13_19"></span>Number Command
>
> *Synopsis*:
>
>
>     (.,.)n
>
> The **n** command shall write to standard output the addressed lines, preceding each line by its line number and a \<tab\>; the current line number shall be set to the address of the last line written. The **n** command can be appended to any command other than **e**, **E**, **f**, **q**, **Q**, **r**, **w**, or **!**.
>
> ##### <span id="tag_20_38_13_20"></span>Print Command
>
> *Synopsis*:
>
>
>     (.,.)p
>
> The **p** command shall write to standard output the addressed lines; the current line number shall be set to the address of the last line written. The **p** command can be appended to any command other than **e**, **E**, **f**, **q**, **Q**, **r**, **w**, or **!**.
>
> ##### <span id="tag_20_38_13_21"></span>Prompt Command
>
> *Synopsis*:
>
>
>     P
>
> The **P** command shall cause *ed* to prompt with an \<asterisk\> (`'*'`) (or *string*, if **-p** is specified) for all subsequent commands. The **P** command alternatively shall turn this mode on and off; it shall be initially on if the **-p** option is specified; otherwise, off. The current line number shall be unchanged.
>
> ##### <span id="tag_20_38_13_22"></span>Quit Command
>
> *Synopsis*:
>
>
>     q
>
> The **q** command shall cause *ed* to exit. If the buffer change flag is currently set to **changed**, the user shall be warned, as described previously.
>
> ##### <span id="tag_20_38_13_23"></span>Quit Without Checking Command
>
> *Synopsis*:
>
>
>     Q
>
> The **Q** command shall cause *ed* to exit without checking the current state of the buffer change flag.
>
> ##### <span id="tag_20_38_13_24"></span>Read Command
>
> *Synopsis*:
>
>
>     ($)r [file]
>
> The **r** command shall read in the file named by the pathname *file* and append it after the addressed line. If no *file* argument is given, the currently remembered pathname, if any, shall be used (see the **e** and **f** commands). The currently remembered pathname shall not be changed unless there is no remembered pathname. Address 0 shall be valid for **r** and shall cause the file to be read at the beginning of the buffer. If the read is successful, and **-s** was not specified, the number of bytes read shall be written to standard output in the following format:
>
>
>     "%d\n", <number of bytes read>
>
> The current line number shall be set to the address of the last line read in. If *file* is replaced by `'!'`, the rest of the line shall be taken to be a shell command line whose output is to be read. Such a shell command line shall not be remembered as the current pathname.
>
> If the number of bytes read is 0 it is unspecified whether the buffer change flag is set to **changed** or left unaltered.
>
> ##### <span id="tag_20_38_13_25"></span>Substitute Command
>
> *Synopsis*:
>
>
>     (.,.)s/RE/replacement/flags
>
> The **s** command shall search each addressed line for an occurrence of the specified RE and replace either the first or all (non-overlapped) matched strings with the *replacement*; see the following description of the **g** suffix. Any character other than \<backslash\>, \<space\>, or \<newline\> can be used instead of a \<slash\> to delimit the RE and the replacement. Within the RE, in certain circumstances the RE delimiter can be used as a literal character; see [Regular Expressions in ed](#tag_20_38_13_01). Within the replacement, the delimiter shall not terminate the replacement if it is the second character of an escape sequence (see XBD [*9.1 Regular Expression Definitions*](../basedefs/V1_chap09.html#tag_09_01)) and the escaped delimiter shall be treated as that literal character in the replacement (losing any special meaning it would have had if it was not used as the delimiter and was not escaped). It shall be an error if the substitution fails on every addressed line. The current line shall be set to the address of the last line on which a substitution occurred.
>
> An unescaped \<ampersand\> (`'&'`) appearing in the replacement shall be replaced by the string matching the RE on the current line. As a more general feature, the characters `'\n'`, where the \<backslash\> is unescaped and *n* is a digit, shall be replaced by the text matched by the corresponding back-reference expression. If the corresponding back-reference expression does not match, then the characters `'\n'` shall be replaced by the empty string. When the character `'%'` is the only character in *replacement*, the *replacement* used in the most recent substitute command shall be used as *replacement* in the current substitute command; if there was no previous substitute command, the use of `'%'` in this manner shall be an error. The `'%'` shall lose its special meaning when it is in a replacement string of more than one character or is escaped. It is unspecified what special meaning is given to any character other than \<backslash\>, `'&'`, `'%'`, or digits.
>
> A line can be split by substituting a \<newline\> into it. The application shall ensure it escapes the \<newline\> in the *replacement* by preceding it by \<backslash\>. Such substitution cannot be done as part of a **g** or **v** *command list*. The current line number shall be set to the address of the last line on which a substitution is performed. If no substitution is performed, the current line number shall be unchanged. If a line is split, a substitution shall be considered to have been performed on each of the new lines for the purpose of determining the new current line number. A substitution shall be considered to have been performed even if the replacement string is identical to the string that it replaces.
>
> The application shall ensure that the value of *flags* is zero or more of:
>
> *count*
>
> Substitute for the *count*th occurrence only of the RE found on each addressed line.
>
> **g**
>
> Globally substitute for all non-overlapping instances of the RE rather than just the first one. If both **g** and *count* are specified, the results are unspecified.
>
> **l**
>
> Write to standard output the final line in which a substitution was made. The line shall be written in the format specified for the **l** command.
>
> **n**
>
> Write to standard output the final line in which a substitution was made. The line shall be written in the format specified for the **n** command.
>
> **p**
>
> Write to standard output the final line in which a substitution was made. The line shall be written in the format specified for the **p** command.
>
> ##### <span id="tag_20_38_13_26"></span>Copy Command
>
> *Synopsis*:
>
>
>     (.,.)taddress
>
> The **t** command shall be equivalent to the **m** command, except that a copy of the addressed lines shall be placed after address *address* (which can be 0); the current line number shall be set to the address of the last line added.
>
> ##### <span id="tag_20_38_13_27"></span>Undo Command
>
> *Synopsis*:
>
>
>     u
>
> The **u** command shall nullify the effect of the most recent command that modified anything in the buffer, namely the most recent **a**, **c**, **d**, **g**, **i**, **j**, **m**, **r**, **s**, **t**, **u**, **v**, **G**, or **V** command. All changes made to the buffer by a **g**, **G**, **v**, or **V** global command shall be undone as a single change; if no changes were made by the global command (such as with **g**/RE/**p**), the **u** command shall have no effect. The current line number shall be set to the value it had immediately before the command being undone started.
>
> ##### <span id="tag_20_38_13_28"></span>Global Non-Matched Command
>
> *Synopsis*:
>
>
>     (1,$)v/RE/command list
>
> This command shall be equivalent to the global command **g** except that the lines that are marked during the first step shall be those for which the line excluding the terminating \<newline\> does not match the RE.
>
> ##### <span id="tag_20_38_13_29"></span>Interactive Global Not-Matched Command
>
> *Synopsis*:
>
>
>     (1,$)V/RE/
>
> This command shall be equivalent to the interactive global command **G** except that the lines that are marked during the first step shall be those for which the line excluding the terminating \<newline\> does not match the RE.
>
> ##### <span id="tag_20_38_13_30"></span>Write Command
>
> *Synopsis*:
>
>
>     (1,$)w [file]
>
> The **w** command shall write the addressed lines into the file named by the pathname *file*. The command shall create the file, if it does not exist, or shall replace the contents of the existing file. The currently remembered pathname shall not be changed unless there is no remembered pathname. If no pathname is given, the currently remembered pathname, if any, shall be used (see the **e** and **f** commands); the current line number shall be unchanged. If the command is successful, the number of bytes written shall be written to standard output, unless the **-s** option was specified, in the following format:
>
>
>     "%d\n", <number of bytes written>
>
> If *file* begins with `'!'`, the rest of the line shall be taken to be a shell command line whose standard input shall be the addressed lines. Such a shell command line shall not be remembered as the current pathname. This usage of the **w** command with `'!'` shall not alter the buffer change flag; thus, this alone shall not prevent the warning to the user if an attempt is made to destroy the editor buffer via the **e** or **q** commands.
>
> ##### <span id="tag_20_38_13_31"></span>Line Number Command
>
> *Synopsis*:
>
>
>     ($)=
>
> The line number of the addressed line shall be written to standard output in the following format:
>
>
>     "%d\n", <line number>
>
> The current line number shall be unchanged by this command.
>
> ##### <span id="tag_20_38_13_32"></span>Shell Escape Command
>
> *Synopsis*:
>
>
>     !command
>
> The remainder of the line after the `'!'` shall be sent to the command interpreter to be interpreted as a shell command line. Within the text of that shell command line, the unescaped character `'%'` shall be replaced with the remembered pathname; if a `'!'` appears as the first character of the command, it shall be replaced with the text of the previous shell command executed via `'!'`. Thus, `"!!"` shall repeat the previous !*command*. If any replacements of `'%'` or `'!'` are performed, the modified line shall be written to the standard output before *command* is executed. The **!** command shall write:
>
>
>     "!\n"
>
> to standard output upon completion, unless the **-s** option is specified. The current line number shall be unchanged.
>
> ##### <span id="tag_20_38_13_33"></span>Null Command
>
> *Synopsis*:
>
>
>     (.+1)
>
> An address alone on a line shall cause the addressed line to be written. A \<newline\> alone shall be equivalent to `"+1p"`. The current line number shall be set to the address of the written line.

#### <span id="tag_20_38_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion without any file or command errors.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_38_15"></span>CONSEQUENCES OF ERRORS

> When an error in the input script is encountered, or when an error is detected that is a consequence of the data (not) present in the file or due to an external condition such as a read or write error:
>
> - If the standard input is a terminal device file, all input shall be flushed, and a new command read.
> - If the standard input is not a terminal device file, *ed* shall behave as described under CONSEQUENCES OF ERRORS in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04).

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_38_16"></span>APPLICATION USAGE

> Because of the extremely terse nature of the default error messages, the prudent script writer begins the *ed* input commands with an **H** command, so that if any errors do occur at least some clue as to the cause is made available.
>
> In earlier versions of this standard, an obsolescent **-** option was described. This is no longer specified. Applications should use the **-s** option. Using **-** as a *file* operand now produces unspecified results. This allows implementations to continue to support the former required behavior.

#### <span id="tag_20_38_17"></span>EXAMPLES

> None.

#### <span id="tag_20_38_18"></span>RATIONALE

> The initial description of this utility was adapted from the SVID. It contains some features not found in Version 7 or BSD-derived systems. Some of the differences between the POSIX and BSD *ed* utilities include, but need not be limited to:
>
> - The BSD **-** option does not suppress the `'!'` prompt after a **!** command.
> - BSD does not support the special meanings of the `'%'` and `'!'` characters within a **!** command.
> - BSD does not support the *addresses* `';'` and `','`.
> - BSD allows the command/suffix pairs **pp**, **ll**, and so on, which are unspecified in this volume of POSIX.1-2024.
> - BSD does not support the `'!'` character part of the **e**, **r**, or **w** commands.
> - A failed **g** command in BSD sets the line number to the last line searched if there are no matches.
> - BSD does not default the *command list* to the **p** command.
> - BSD does not support the **G**, **h**, **H**, **n**, or **V** commands.
> - On BSD, if there is no inserted text, the insert command changes the current line to the referenced line -1; that is, the line before the specified line.
> - On BSD, the **j** command with only a single address changes the current line to that address.
> - BSD does not support the **P** command; moreover, in BSD it is synonymous with the **p** command.
> - BSD does not support the *undo* of the commands **j**, **m**, **r**, **s**, or **t**.
> - The Version 7 *ed* command **W**, and the BSD *ed* commands **W**, **wq**, and **z** are not present in this volume of POSIX.1-2024.
>
> The **-s** option was added to allow the functionality of the removed **-** option in a manner compatible with the Utility Syntax Guidelines.
>
> In early proposals there was a limit, {ED_FILE_MAX}, that described the historical limitations of some *ed* utilities in their handling of large files; some of these have had problems with files larger than 100000 bytes. It was this limitation that prompted much of the desire to include a [*split*](../utilities/split.html) command in this volume of POSIX.1-2024. Since this limit was removed, this volume of POSIX.1-2024 requires that implementations document the file size limits imposed by *ed* in the conformance document. The limit {ED_LINE_MAX} was also removed; therefore, the global limit {LINE_MAX} is used for input and output lines.
>
> The manner in which the **l** command writes non-printable characters was changed to avoid the historical backspace-overstrike method. On video display terminals, the overstrike is ambiguous because most terminals simply replace overstruck characters, making the **l** format not useful for its intended purpose of unambiguously understanding the content of the line. The historical \<backslash\>-escapes were also ambiguous. (The string `"a\0011"` could represent a line containing those six characters or a line containing the three characters `'a'`, a byte with a binary value of 1, and a 1.) In the format required here, a \<backslash\> appearing in the line is written as `"\\"` so that the output is truly unambiguous. The method of marking the ends of lines was adopted from the [*ex*](../utilities/ex.html) editor and is required for any line ending in \<space\> characters; the `'$'` is placed on all lines so that a real `'$'` at the end of a line cannot be misinterpreted.
>
> Earlier versions of this standard allowed for implementations with bytes other than eight bits, but this has been modified in this version.
>
> The description of how a NUL is written was removed. The NUL character cannot be in text files, and this volume of POSIX.1-2024 should not dictate behavior in the case of undefined, erroneous input.
>
> Unlike some of the other editing utilities, the filenames accepted by the **E**, **e**, **R**, and **r** commands are not patterns.
>
> Early proposals stated that the **-p** option worked only when standard input was associated with a terminal device. This has been changed to conform to historical implementations, thereby allowing applications to interpose themselves between a user and the *ed* utility.
>
> The form of the substitute command that uses the **n** suffix was limited in some historical documentation (where this was described incorrectly as "backreferencing"). This limit has been omitted because there is no reason why an editor processing lines of {LINE_MAX} length should have this restriction. The command **s/x/X/2047** should be able to substitute the 2047th occurrence of `'x'` on a line.
>
> The use of printing commands with printing suffixes (such as **pn**, **lp**, and so on) was made unspecified because BSD-based systems allow this, whereas System V does not.
>
> Some BSD-based systems exit immediately upon receipt of end-of-file if all of the lines in the file have been deleted. Since this volume of POSIX.1-2024 refers to the **q** command in this instance, such behavior is not allowed.
>
> Some historical implementations returned exit status zero even if command errors had occurred; this is not allowed by this volume of POSIX.1-2024.
>
> Some historical implementations contained a bug that allowed a single \<period\> to be entered in input mode as \<backslash\> \<period\> \<newline\>. This is not allowed by *ed* because there is no description of escaping any of the characters in input mode; \<backslash\> characters are entered into the buffer exactly as typed. The typical method of entering a single \<period\> has been to precede it with another character and then use the substitute command to delete that character.
>
> It is difficult under some modes of some versions of historical operating system terminal drivers to distinguish between an end-of-file condition and terminal disconnect. POSIX.1-2024 does not require implementations to distinguish between the two situations, which permits historical implementations of the *ed* utility on historical platforms to conform. Implementations are encouraged to distinguish between the two, if possible, and take appropriate action on terminal disconnect.
>
> Historically, *ed* accepted a zero address for the **a** and **r** commands in order to insert text at the start of the edit buffer. When the buffer was empty the command **.=** returned zero. POSIX.1-2024 requires conformance to historical practice.
>
> For consistency with the **a** and **r** commands and better user functionality, the **i** command also accepts an address of 0. However, it is unspecified if `0i` is treated as `1i` (which will fail if the buffer is empty), or means insert at the beginning of the buffer (which will succeed even if the buffer is empty). Earlier versions of this standard required address 0 for the **c** command to be treated as 1 also, but this requirement has been removed, though implementations are permitted to do this as an extension.
>
> All of the following are valid addresses:
>
> `+++`
>
> Three lines after the current line.
>
> `/`*pattern*`/-`
>
> One line before the next occurrence of pattern.
>
> `-2`
>
> Two lines before the current line.
>
> `3 ---- 2`
>
> Line one (note the intermediate negative address).
>
> `1 2 3`
>
> Line six.
>
> More than the maximum number of accepted addresses can be provided to commands taking addresses; for example, `"1,2,3,4,5p"` prints lines 4 and 5, because two is the maximum number of addresses accepted by the **print** command. This, in combination with the \<semicolon\> delimiter, permits users to create commands based on ordered patterns in the file. For example, the command `"3;/foo/;+2p"` will display the first line after line 3 that contains the pattern *foo*, plus the next two lines. Note that the address `"3;"` must still be evaluated before being discarded, because the search origin for the `"/foo/"` address depends on this.
>
> Historically, *ed* disallowed address chains, as discussed above, consisting solely of \<comma\> or \<semicolon\> separators; for example, `",,,"` or `";;;"` were considered an error. For consistency of address specification, this restriction is removed. The following table lists some of the address forms now possible:
>
> | **Address** | **Addr1** | **Addr2** | **Status** | **Comment**           |
> |:------------|:----------|:----------|:-----------|:----------------------|
> | 7,          | 7         | 7         | Historical |                       |
> | 7,5,        | 5         | 5         | Historical |                       |
> | 7,5,9       | 5         | 9         | Historical |                       |
> | 7,9         | 7         | 9         | Historical |                       |
> | 7,+         | 7         | .+        | Historical |                       |
> | ,           | 1         | \$        | Historical |                       |
> | ,7          | 1         | 7         | Extension  |                       |
> | ,,          | \$        | \$        | Extension  |                       |
> | ,;          | \$        | \$        | Extension  |                       |
> | 7;          | 7         | 7         | Historical |                       |
> | 7;5;        | 5         | 5         | Historical |                       |
> | 7;5;9       | 5         | 9         | Historical |                       |
> | 7;5,9       | 5         | 9         | Historical |                       |
> | 7;\$;4      | \$        | 4         | Historical | Valid, but erroneous. |
> | 7;9         | 7         | 9         | Historical |                       |
> | 7;+         | 7         | 8         | Historical |                       |
> | ;           | .         | \$        | Historical |                       |
> | ;7          | .         | 7         | Extension  |                       |
> | ;;          | \$        | \$        | Extension  |                       |
> | ;,          | \$        | \$        | Extension  |                       |
>
> Historically, *ed* accepted the `'^'` character as an address, in which case it was identical to the \<hyphen-minus\> character. POSIX.1-2024 does not require or prohibit this behavior.
>
> Implementations are encouraged to set the buffer change flag to **changed-and-warned** when an **e** or **q** command warns that an attempt was made to destroy the editor buffer. Some existing implementations set it to **unchanged**, but this has the undesirable side-effect that a SIGHUP received after the warning is given does not write the buffer to **ed.hup**.

#### <span id="tag_20_38_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> A future version of this standard may require that the buffer change flag is set to **changed-and-warned** when an **e** or **q** command warns that an attempt was made to destroy the editor buffer.

#### <span id="tag_20_38_20"></span>SEE ALSO

> [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04), [*ex*](../utilities/ex.html#), [*sed*](../utilities/sed.html#), [*sh*](../utilities/sh.html#), [*vi*](../utilities/vi.html#)
>
> XBD [*Escape Sequences and Associated Actions*](../basedefs/V1_chap05.html#tagtcjh_2), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*9.3 Basic Regular Expressions*](../basedefs/V1_chap09.html#tag_09_03), [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_38_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_38_22"></span>Issue 5

> In the OPTIONS section, the meaning of **-s** and **-** is clarified.
>
> A second FUTURE DIRECTION is added.

#### <span id="tag_20_38_23"></span>Issue 6

> The obsolescent single-minus form is removed.
>
> A second APPLICATION USAGE note is added.
>
> The Open Group Corrigendum U025/2 is applied, correcting the description of the Edit section.
>
> The *ed* utility is updated to align with the IEEE P1003.2b draft standard. This includes addition of the treatment of the SIGQUIT signal, changes to *ed* addressing, and changes to processing when end-of-file is detected and when terminal disconnect is detected.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/22 is applied, adding the text: "Any line modified by the *command list* shall be unmarked." to the **G** command. This change corresponds to a similar change made to the **g** command in the first version of this standard.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/7 is applied, removing text describing behavior on systems with bytes consisting of more than eight bits.

#### <span id="tag_20_38_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied, clarifying the behavior if an operand is `'-'`.
>
> Austin Group Interpretation 1003.1-2001 \#036 is applied, clarifying the behavior for BREs.
>
> SD5-XCU-ERN-94 is applied, updating text in the EXTENDED DESCRIPTION where a terminal disconnect is detected (in Commands in *ed*).
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> SD5-XCU-ERN-135 is applied, removing some RATIONALE text that is no longer applicable.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0090 \[584\], XCU/TC2-2008/0091 \[584\], and XCU/TC2-2008/0092 \[584\] are applied.

#### <span id="tag_20_38_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1130 is applied, removing the requirement for the **c** command to accept an address of 0 and updating the information about address 0 in the RATIONALE section.
>
> Austin Group Defect 1131 is applied, changing the address 0 requirements for the **i** command.
>
> Austin Group Defect 1204 is applied, clarifying the behavior when a closing delimiter that would be the last character before a \<newline\> is omitted.
>
> Austin Group Defect 1281 is applied, moving some text in the description of the **s** command and changing it to use "shall".
>
> Austin Group Defect 1298 is applied, changing the CONSEQUENCES OF ERRORS section.
>
> Austin Group Defect 1308 is applied, changing the **Addr2** value for address `7,+` in the table of address forms in the RATIONALE section.
>
> Austin Group Defect 1311 is applied, changing "*join* command" to "**j** command" in the RATIONALE section.
>
> Austin Group Defect 1582 is applied, clarifying the behavior when an address is omitted between two address separators.
>
> Austin Group Defect 1607 is applied, clarifying the behavior when more than the maximum number of accepted addresses are provided to a command.
>
> Austin Group Defect 1662 is applied, clarifying requirements relating to delimiters in addresses and in **s** commands.
>
> Austin Group Defect 1786 is applied, clarifying the behavior when an **e** command names a file that does not exist, and clarifying how the *ed* utility keeps track of whether the buffer has been modified.

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
