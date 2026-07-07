The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="command"></span> <span id="tag_20_22"></span>

#### <span id="tag_20_22_01"></span>NAME

> command — execute a simple command

#### <span id="tag_20_22_02"></span>SYNOPSIS

> `command`` `**`[`**`-p`**`]`**` `*`command_name`*` `**`[`***`argument`*`...`**`]`**\
> \
> `command`` `**`[`**`-p`**`][`**`-v|-V`**`]`**` `*`command_name`*\

#### <span id="tag_20_22_03"></span>DESCRIPTION

> The *command* utility shall cause the shell to treat the arguments as a simple command, suppressing the shell function lookup that is described in [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04), item 1c.
>
> If the *command_name* is the same as the name of one of the special built-in utilities, the special properties in the enumerated list at the beginning of [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15) shall not occur. In every other respect, if *command_name* is not the name of a function, the effect of *command* (with no options) shall be the same as omitting *command*, except that *command_name* does not appear in the command word position in the *command* command, and consequently is not subject to alias substitution (see [*2.3.1 Alias Substitution*](../utilities/V3_chap02.html#tag_19_03_01)) nor recognized as a reserved word (see [*2.4 Reserved Words*](../utilities/V3_chap02.html#tag_19_04)).
>
> When the **-v** or **-V** option is used, the *command* utility shall provide information concerning how a command name is interpreted by the shell.
>
> The *command* utility shall be treated as a declaration utility if the first argument passed to the utility is recognized as a declaration utility. In this case, subsequent words of the form *name*=*word* shall be expanded in an assignment context. See [*2.9.1.1 Order of Processing*](../utilities/V3_chap02.html#tag_19_09_01_01).

#### <span id="tag_20_22_04"></span>OPTIONS

> The *command* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-p**
>
> Perform the command search using a default value for *PATH* that is guaranteed to find all of the standard utilities.
>
> **-v**
>
> Write a string to standard output that indicates the pathname or command that will be used by the shell, in the current shell execution environment (see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13)), to invoke *command_name*, but do not invoke *command_name*.
>
> - Executable utilities, regular built-in utilities, *command_name*s including a \<slash\> character, and any implementation-provided functions that are found using the *PATH* variable (as described in [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04)), shall be written as absolute pathnames.
>
> - Shell functions, special built-in utilities, regular built-in utilities not associated with a *PATH* search, and shell reserved words shall be written as just their names.
>
> - An alias shall be written as a command line that represents its alias definition.
>
> - Otherwise, no output shall be written and the exit status shall reflect that the name was not found.
>
> **-V**
>
> Write a string to standard output that indicates how the name given in the *command_name* operand will be interpreted by the shell, in the current shell execution environment (see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13)), but do not invoke *command_name*. Although the format of this string is unspecified, it shall indicate in which of the following categories *command_name* falls and shall include the information stated:
>
> - Executable utilities, regular built-in utilities, and any implementation-provided functions that are found using the *PATH* variable (as described in [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04)), shall be identified as such and include the absolute pathname in the string.
>
> - Other shell functions shall be identified as functions.
>
> - Aliases shall be identified as aliases and their definitions included in the string.
>
> - Special built-in utilities shall be identified as special built-in utilities.
>
> - Regular built-in utilities not associated with a *PATH* search shall be identified as regular built-in utilities. (The term "regular" need not be used.)
>
> - Shell reserved words shall be identified as reserved words.

#### <span id="tag_20_22_05"></span>OPERANDS

> The following operands shall be supported:
>
> *argument*
>
> One of the strings treated as an argument to *command_name*.
>
> *command_name*
>
> \
> The name of a utility or a special built-in utility.

#### <span id="tag_20_22_06"></span>STDIN

> Not used.

#### <span id="tag_20_22_07"></span>INPUT FILES

> None.

#### <span id="tag_20_22_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *command*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *PATH*
>
> Determine the search path used during the command search described in [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04), except as described under the **-p** option.

#### <span id="tag_20_22_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_22_10"></span>STDOUT

> When the **-v** option is specified, standard output shall be formatted as:
>
>
>     "%s\n", <pathname or command>
>
> When the **-V** option is specified, standard output shall be formatted as:
>
>
>     "%s\n", <unspecified>

#### <span id="tag_20_22_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_22_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_22_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_22_14"></span>EXIT STATUS

> When the **-v** or **-V** options are specified, the following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> The *command_name* could not be found or an error occurred.
>
> Otherwise, the following exit values shall be returned:
>
> 126
>
> The utility specified by *command_name* was found but could not be invoked.
>
> 127
>
> An error occurred in the *command* utility or the utility specified by *command_name* could not be found.
>
> Otherwise, the exit status of *command* shall be that of the simple command specified by the arguments to *command*.

#### <span id="tag_20_22_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_22_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> The order for command search allows functions to override regular built-ins and path searches. This utility is necessary to allow functions that have the same name as a utility to call the utility (instead of a recursive call to the function).
>
> The system default path is available using [*getconf*](../utilities/getconf.html); however, since [*getconf*](../utilities/getconf.html) may need to have the *PATH* set up before it can be called itself, the following can be used:
>
>
>     command -p getconf PATH
>
> There are some advantages to suppressing the special characteristics of special built-ins on occasion. For example:
>
>
>     command exec > unwritable-file
>
> does not cause a non-interactive script to abort, so that the output status can be checked by the script.
>
> The *command*, [*env*](../utilities/env.html), [*nohup*](../utilities/nohup.html), [*time*](../utilities/time.html), [*timeout*](../utilities/timeout.html), and [*xargs*](../utilities/xargs.html) utilities have been specified to use exit code 127 if a utility to be invoked cannot be found, so that applications can distinguish "failure to find a utility" from "invoked utility exited with an error indication". However, the *command* and [*nohup*](../utilities/nohup.html) utilities also use exit code 127 when an error occurs in those utilities, which means exit code 127 is not universally a "not found" indicator. The value 127 was chosen because it is not commonly used for other meanings; most utilities use small values for "normal error conditions" and the values above 128 can be confused with termination due to receipt of a signal. The value 126 was chosen in a similar manner to indicate that the utility could be found, but not invoked. Some scripts produce meaningful error messages differentiating the 126 and 127 cases. The distinction between exit codes 126 and 127 is based on KornShell practice that uses 127 when all attempts to *exec* the utility fail with \[ENOENT\], and uses 126 when any attempt to *exec* the utility fails for any other reason.
>
> Since the **-v** and **-V** options of *command* produce output in relation to the current shell execution environment, *command* is generally provided as a shell regular built-in. If it is called in a subshell or separate utility execution environment, such as one of the following:
>
>
>     (PATH=foo command -v)
>      nohup command -v
>
> it does not necessarily produce correct results. For example, when called with [*nohup*](../utilities/nohup.html) or an *exec* function, in a separate utility execution environment, most implementations are not able to identify aliases, functions, or special built-ins.
>
> Two types of regular built-ins could be encountered on a system and these are described separately by *command*. The description of command search in [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04) allows for a standard utility to be implemented as a regular built-in as long as it is found in the appropriate place in a *PATH* search. So, for example, *command* **-v** *true* might yield **/bin/true** or some similar pathname. Other implementation-defined utilities that are not defined by this volume of POSIX.1-2024 might exist only as built-ins and have no pathname associated with them. These produce output identified as (regular) built-ins. Applications encountering these are not able to count on *exec*ing them, using them with [*nohup*](../utilities/nohup.html), overriding them with a different *PATH ,* and so on.
>
> The *command* utility takes on the expansion behavior of the command that it is wrapping. Therefore, in
>
>
>     command command export a=~
>
> *command* is recognized as a declaration utility, and the command sets the variable *a* to the value of `$HOME` because it performs tilde-expansion of an assignment context; while
>
>
>     command echo a=~
>
> outputs the literal string `"a=~"` because regular expansion can only perform tilde-expansion at the beginning of the word. However, the shell need only perform lexical analysis of the next argument when deciding if command should be treated as a declaration utility; therefore, with:
>
>
>     var=export; command $var a=~
>
> and
>
>
>     command -- export a=~
>
> it is unspecified whether the word `a=~` is handled in an assignment context or as a regular expansion.

#### <span id="tag_20_22_17"></span>EXAMPLES

> 1.  Make a version of [*cd*](../utilities/cd.html) that always prints out the new working directory exactly once:
>
>
>         cd() {
>             command cd "$@" >/dev/null
>             pwd
>         }
>
> 2.  Start off a "secure shell script" in which the script avoids being spoofed by its parent:
>
>
>         IFS='
>         '
>         #    The preceding value should be <space><tab><newline>.
>         #    Set IFS to its default value.
>
>
>         \unalias -a
>         #    Unset all possible aliases.
>         #    Note that unalias is escaped to prevent an alias
>         #    being used for unalias.
>
>
>         unset -f command
>         #    Ensure command is not a user function.
>
>
>         PATH="$(command -p getconf PATH):$PATH"
>         #    Put on a reliable PATH prefix.
>
>
>         #    ...
>
>     At this point, given correct permissions on the directories called by *PATH ,* the script has the ability to ensure that any utility it calls is the intended one. It is being very cautious because it assumes that implementation extensions may be present that would allow user functions to exist when it is invoked; this capability is not specified by this volume of POSIX.1-2024, but it is not prohibited as an extension. For example, the *ENV* variable precedes the invocation of the script with a user start-up script. Such a script could define functions to spoof the application.

#### <span id="tag_20_22_18"></span>RATIONALE

> Since *command* is a regular built-in utility it is always found prior to the *PATH* search.
>
> There is nothing in the description of *command* that implies the command line is parsed any differently from that of any other simple command. For example:
>
>
>     command a | b ; c
>
> is not parsed in any special way that causes `'|'` or `';'` to be treated other than a pipe operator or \<semicolon\> or that prevents function lookup on **b** or **c**. However, some implementations extend the shell's assignment syntax, for example to allow an array to be populated with a single assignment, and in order for such an extension to be usable in assignments specified as arguments to [*export*](../utilities/export.html) and [*readonly*](../utilities/readonly.html) these shells have those utility names as separate tokens in their grammar. When *command* is used to execute these utilities it also needs to be a separate token in the grammar so that the same extended assignment syntax can still be recognized in this case. This standard only permits an extension of this nature when the input to the shell would contain a syntax error according to the standard grammar, and therefore it cannot affect how `'|'` and `';'` are parsed in the example above. Note that although *command* can be a separate token in the shell's grammar, it cannot be a reserved word since *command* is a candidate for alias substitution whereas reserved words are not (see [*2.3.1 Alias Substitution*](../utilities/V3_chap02.html#tag_19_03_01)).
>
> The *command* utility is somewhat similar to the Eighth Edition shell *builtin* command, but since *command* also goes to the file system to search for utilities, the name *builtin* would not be intuitive.
>
> The *command* utility is most likely to be provided as a regular built-in. It is not listed as a special built-in for the following reasons:
>
> - The removal of exportable functions made the special precedence of a special built-in unnecessary.
>
> - A special built-in has special properties (see [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15)) that were inappropriate for invoking other utilities. For example, two commands such as:
>
>
>       date > unwritable-file
>
>
>       command date > unwritable-file
>
>   would have entirely different results; in a non-interactive script, the former would continue to execute the next command, the latter would abort. Introducing this semantic difference along with suppressing functions was seen to be non-intuitive.
>
> The **-p** option is present because it is useful to be able to ensure a safe path search that finds all the standard utilities. This search might not be identical to the one that occurs through one of the *exec* functions (as defined in the System Interfaces volume of POSIX.1-2024) when *PATH* is unset. At the very least, this feature is required to allow the script to access the correct version of [*getconf*](../utilities/getconf.html) so that the value of the default path can be accurately retrieved.
>
> The *command* **-v** and **-V** options were added to satisfy requirements from users that are currently accomplished by three different historical utilities: [*type*](../utilities/type.html) in the System V shell, *whence* in the KornShell, and *which* in the C shell. Since there is no historical agreement on how and what to accomplish here, the POSIX *command* utility was enhanced and the historical utilities were left unmodified. The C shell *which* merely conducts a path search. The KornShell *whence* is more elaborate—in addition to the categories required by POSIX, it also reports on tracked aliases, exported aliases, and undefined functions.
>
> The output format of **-V** was left mostly unspecified because human users are its only audience. Applications should not be written to care about this information; they can use the output of **-v** to differentiate between various types of commands, but the additional information that may be emitted by the more verbose **-V** is not needed and should not be arbitrarily constrained in its verbosity or localization for application parsing reasons.

#### <span id="tag_20_22_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_22_20"></span>SEE ALSO

> [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04), [*2.9.1.1 Order of Processing*](../utilities/V3_chap02.html#tag_19_09_01_01), [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13), [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15), [*sh*](../utilities/sh.html#) , [*type*](../utilities/type.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*exec*](../functions/exec.html#tag_17_129)

#### <span id="tag_20_22_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_22_22"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#196 is applied, changing the SYNOPSIS to allow **-p** to be used with **-v** (or **-V**).
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The *command* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> The APPLICATION USAGE and EXAMPLES are revised to replace the non-standard [*getconf*](../utilities/getconf.html)\_CS_PATH with [*getconf*](../utilities/getconf.html) *PATH .*

#### <span id="tag_20_22_23"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defects 351 and 1393 are applied, requiring *command* to be a declaration utility if the first argument passed to the utility is recognized as a declaration utility.
>
> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
>
> Austin Group Defect 1117 is applied, changing "implementation-defined" to "implementation-provided".
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1161 is applied, changing "Utilities" to "Executable utilities" in the descriptions of the **-v** and **-V** options.
>
> Austin Group Defect 1431 is applied, changing "item 1b" to "item 1c".
>
> Austin Group Defect 1586 is applied, adding the [*timeout*](../utilities/timeout.html) utility.
>
> Austin Group Defect 1594 is applied, changing the APPLICATION USAGE section.
>
> Austin Group Defect 1637 is applied, clarifying that (when no options are specified) *command_name* is not subject to alias substitution nor recognized as a reserved word.

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
