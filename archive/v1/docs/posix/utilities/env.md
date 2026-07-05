The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="env"></span> <span id="tag_20_39"></span>

#### <span id="tag_20_39_01"></span>NAME

> env — set the environment for command invocation

#### <span id="tag_20_39_02"></span>SYNOPSIS

> `env`` `**`[`**`-i`**`] [`***`name`*`=`*`value`***`]`**`...`` `**`[`***`utility`*` `**`[`***`argument`*`...`**`]]`**

#### <span id="tag_20_39_03"></span>DESCRIPTION

> The *env* utility shall obtain the current environment, modify it according to its arguments, then invoke the utility named by the *utility* operand with the modified environment.
>
> Optional arguments shall be passed to *utility*.
>
> If no *utility* operand is specified, the resulting environment shall be written to the standard output, with one *name*=*value* pair per line.
>
> If the first argument is `'-'`, the results are unspecified.

#### <span id="tag_20_39_04"></span>OPTIONS

> The *env* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except for the unspecified usage of `'-'`.
>
> The following options shall be supported:
>
> **-i**
>
> Invoke *utility* with exactly the environment specified by the arguments; the inherited environment shall be ignored completely.

#### <span id="tag_20_39_05"></span>OPERANDS

> The following operands shall be supported:
>
> *name*=*value*
>
> Arguments of the form *name*=*value* shall modify the execution environment, and shall be placed into the inherited environment before the *utility* is invoked.
>
> *utility*
>
> The name of the utility to be invoked. If the *utility* operand names any of the special built-in utilities in [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15), the results are undefined.
>
> *argument*
>
> A string to pass as an argument for the invoked utility.

#### <span id="tag_20_39_06"></span>STDIN

> Not used.

#### <span id="tag_20_39_07"></span>INPUT FILES

> None.

#### <span id="tag_20_39_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *env*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *PATH*
>
> Determine the location of the *utility*, as described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08). If *PATH* is specified as a *name*=*value* operand to *env*, the *value* given shall be used in the search for *utility*.

#### <span id="tag_20_39_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_39_10"></span>STDOUT

> If no *utility* operand is specified, each *name*=*value* pair in the resulting environment shall be written in the form:
>
>
>     "%s=%s\n", <name>, <value>
>
> If the *utility* operand is specified, the *env* utility shall not write to standard output.

#### <span id="tag_20_39_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_39_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_39_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_39_14"></span>EXIT STATUS

> If *utility* is invoked, the exit status of *env* shall be the exit status of *utility*; otherwise, the *env* utility shall exit with one of the following values:
>
>     0
>
> The *env* utility completed successfully.
>
> 1-125
>
> An error occurred in the *env* utility.
>
>   126
>
> The utility specified by *utility* was found but could not be invoked.
>
>   127
>
> The utility specified by *utility* could not be found.

#### <span id="tag_20_39_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_39_16"></span>APPLICATION USAGE

> The [*command*](../utilities/command.html), *env*, [*nice*](../utilities/nice.html), [*nohup*](../utilities/nohup.html), [*time*](../utilities/time.html), [*timeout*](../utilities/timeout.html), and [*xargs*](../utilities/xargs.html) utilities have been specified to use exit code 127 if a utility to be invoked cannot be found, so that applications can distinguish "failure to find a utility" from "invoked utility exited with an error indication". The value 127 was chosen because it is not commonly used for other meanings; most utilities use small values for "normal error conditions" and the values above 128 can be confused with termination due to receipt of a signal. The value 126 was chosen in a similar manner to indicate that the utility could be found, but not invoked. Some scripts produce meaningful error messages differentiating the 126 and 127 cases. The distinction between exit codes 126 and 127 is based on KornShell practice that uses 127 when all attempts to *exec* the utility fail with \[ENOENT\], and uses 126 when any attempt to *exec* the utility fails for any other reason.
>
> Historical implementations of the *env* utility use the [*execvp*()](../functions/execvp.html) or [*execlp*()](../functions/execlp.html) functions defined in the System Interfaces volume of POSIX.1-2024 to invoke the specified utility; this provides better performance and keeps users from having to escape characters with special meaning to the shell. Therefore, shell functions, special built-ins, and built-ins that are only provided by the shell are not found by this type of *env* implementation. However, *env* can be implemented as a shell built-in, in which case it may be able to execute shell functions and built-ins. An application wishing to ensure execution of a non-built-in utility can use [*exec*](../utilities/exec.html) in a subshell for this purpose.

#### <span id="tag_20_39_17"></span>EXAMPLES

> The following command:
>
>
>     env -i PATH=/mybin:"$PATH" $(getconf V7_ENV) mygrep xyz myfile
>
> invokes the command *mygrep* with a new *PATH* value as the only entry in its environment other than any variables required by the implementation for conformance. In this case, *PATH* is used to locate *mygrep*, which is expected to reside in **/mybin**.

#### <span id="tag_20_39_18"></span>RATIONALE

> As with all other utilities that invoke other utilities, this volume of POSIX.1-2024 only specifies what *env* does with standard input, standard output, standard error, input files, and output files. If a utility is executed, it is not constrained by the specification of input and output by *env*.
>
> The **-i** option was added to allow the functionality of the removed **-** option in a manner compatible with the Utility Syntax Guidelines. It is possible to create a non-conforming environment using the **-i** option, as it may remove environment variables required by the implementation for conformance. The following will preserve these environment variables as well as preserve the *PATH* for conforming utilities:
>
>
>     IFS='
>     '
>     # The preceding value should be <space><tab><newline>.
>     # Set IFS to its default value.
>
>
>     set -f
>     # disable pathname expansion
>
>
>     \unalias -a
>     # Unset all possible aliases.
>     # Note that unalias is escaped to prevent an alias
>     # being used for unalias.
>     # This step is not strictly necessary, since aliases are not inherited,
>     # and the ENV environment variable is only used by interactive shells,
>     # the only way any aliases can exist in a script is if it defines them
>     # itself.
>
>
>     unset -f env getconf
>     # Ensure env and getconf are not user functions.
>
>
>     env -i $(getconf V7_ENV) PATH="$(getconf PATH)" command
>
> Some have suggested that *env* is redundant since the same effect is achieved by:
>
>
>     name=value ... utility [ argument ... ]
>
> The example is equivalent to *env* when an environment variable is being added to the environment of the command, but not when the environment is being set to the given value. The *env* utility also writes out the current environment if invoked without arguments. There is sufficient functionality beyond what the example provides to justify inclusion of *env*.

#### <span id="tag_20_39_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_39_20"></span>SEE ALSO

> [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15), [*2.5 Parameters and Variables*](../utilities/V3_chap02.html#tag_19_05)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_39_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_39_22"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#027 is applied, clarifying the behavior if the first argument is `'-'`.
>
> Austin Group Interpretation 1003.1-2001 \#047 is applied, providing RATIONALE on how to use the *env* utility to preserve a conforming environment.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The EXAMPLES section is revised to change the use of *env* **-i**.

#### <span id="tag_20_39_23"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1157 is applied, adding a note about shell built-in implementations of *env* to the APPLICATION USAGE section.
>
> Austin Group Defect 1586 is applied, adding the [*timeout*](../utilities/timeout.html) utility.
>
> Austin Group Defect 1594 is applied, changing the APPLICATION USAGE section.

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
