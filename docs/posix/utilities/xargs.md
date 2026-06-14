The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="xargs"></span> <span id="tag_20_152"></span>

#### <span id="tag_20_152_01"></span>NAME

> xargs — construct argument lists and invoke utility

#### <span id="tag_20_152_02"></span>SYNOPSIS

> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` xargs`` `**`[`**`-prtx`**`] [`**`-E`` `*`eofstr`*`|-0`**`] [`<img src="../images/opt-start.gif" data-border="0" />**`-I`` `*`replstr`*`|-L`` `*`number`*<img src="../images/opt-end.gif" data-border="0" />`|-n`` `*`number`***`]`**\
> `      `` `**`[`**`-s`` `*`size`***`] [`***`utility`*` `**`[`***`argument`*`...`**`]]`**

#### <span id="tag_20_152_03"></span>DESCRIPTION

> The *xargs* utility shall construct a command line consisting of the *utility* and *argument* operands specified followed by as many arguments read in sequence from standard input as fit in length and number constraints specified by the options. The *xargs* utility shall then invoke the constructed command line and wait for its completion. This sequence shall be repeated until one of the following occurs:
>
> - An end-of-file condition is detected on standard input.
>
> - An argument consisting of just the logical end-of-file string (see the **-E** *eofstr* option) is found on standard input after double-quote processing, \<apostrophe\> processing, and \<backslash\>-escape processing (see next paragraph). All arguments up to but not including the argument consisting of just the logical end-of-file string shall be used as arguments in constructed command lines.
>
> - An invocation of a constructed command line returns an exit status of 255.
>
> If the **-0** option is not specified, the application shall ensure that arguments in the standard input are delimited by unquoted \<blank\> characters, unescaped \<blank\> characters, or \<newline\> characters, and quoting characters shall be interpreted as follows:
>
> - A string of zero or more non-double-quote (`'"'` ) non-\<newline\> characters can be quoted by enclosing them in double-quotes.
>
> - A string of zero or more non-\<apostrophe\> (`'\''`) non-\<newline\> characters can be quoted by enclosing them in \<apostrophe\> characters.
>
> - Any unquoted character can be escaped by preceding it with a \<backslash\>.
>
> Multiple adjacent delimiter characters shall be treated as a single delimiter. If the standard input is not empty and does not end with a \<newline\>, the behavior is undefined (because the requirement in STDIN that the input is a text file is not met in that case).
>
> If the **-0** option is specified, the application shall ensure that arguments in the standard input are delimited by null bytes. If multiple adjacent null bytes occur in the input, each null byte shall be treated as a delimiter. If the standard input is not empty and does not end with a null byte, *xargs* should ignore the trailing non-null bytes (as this can signal incomplete data) but may use them as the last argument passed to utility.
>
> The utility named by *utility* shall be executed zero or more times until the end-of-file is reached or the logical end-of file string is found. If no arguments are supplied on standard input, the utility named by *utility* shall be executed zero times if the **-r** option is specified and shall be executed exactly once if the **-r** option is not specified. The results are unspecified if the utility named by *utility* attempts to read from its standard input.
>
> The generated command line length shall be the sum of the size in bytes of the utility name and each argument treated as strings, including a null byte terminator for each of these strings. The *xargs* utility shall limit the command line length such that when the command line is invoked, the combined argument and environment lists (see the *exec* family of functions in the System Interfaces volume of POSIX.1-2024) shall not exceed {ARG_MAX}-2048 bytes. Within this constraint, if neither the **-n** nor the **-s** option is specified, the default command line length shall be at least {LINE_MAX}.

#### <span id="tag_20_152_04"></span>OPTIONS

> The *xargs* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-E ***eofstr*
>
> Use *eofstr* as the logical end-of-file string. If neither **-E** nor **-0** is specified, it is unspecified whether the logical end-of-file string is the \<underscore\> character (`'_'`) or the end-of-file string capability is disabled. When *eofstr* is the null string, the logical end-of-file string capability shall be disabled and \<underscore\> characters shall be taken literally.
>
> **-I ***replstr*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Insert mode: invoke *utility* for each argument from standard input. If **-0** is not specified, arguments in the standard input shall be delimited only by unescaped \<newline\> characters, not by \<blank\> characters, and any unquoted unescaped \<blank\> characters at the beginning of each line shall be ignored. The resulting argument shall be inserted in *arguments* in place of each occurrence of *replstr*. At least five arguments in *arguments* can each contain one or more instances of *replstr*. Each of these constructed arguments cannot grow larger than an implementation-defined limit greater than or equal to 255 bytes. Option **-x** shall be forced on. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-L ***number*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Invoke *utility* for each set of *number* arguments from standard input. The last invocation of *utility* shall be with fewer arguments if fewer than *number* remain. If the **-0** option is not specified, each line in the standard input shall be treated as containing one argument except that empty lines shall be ignored and a line ending with a trailing unescaped \<blank\> shall signal continuation to the next non-empty line, inclusive; such continuation shall result in removal of all trailing unescaped \<blank\> characters and all \<newline\> characters that immediately follow them from the argument. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-n ***number*
>
> Invoke *utility* using as many standard input arguments as possible, up to *number* (a positive decimal integer) arguments maximum. Fewer arguments shall be used if:
>
> - The command line length accumulated exceeds the size specified by the **-s** option (or {LINE_MAX} if there is no **-s** option).
>
> - The last iteration has fewer than *number*, but not zero, operands remaining.
>
> **-p**
>
> Prompt mode: the user is asked whether to execute *utility* at each invocation. Trace mode (**-t**) is turned on to write the command instance to be executed, followed by a prompt to standard error. An affirmative response read from **/dev/tty** shall execute the command; otherwise, that particular invocation of *utility* shall be skipped.
>
> **-r**
>
> Do not execute the utility named by *utility* if no arguments are supplied on standard input.
>
> **-s ***size*
>
> Invoke *utility* using as many standard input arguments as possible yielding a command line length less than *size* (a positive decimal integer) bytes. Fewer arguments shall be used if:
>
> - The total number of arguments exceeds that specified by the **-n** option.
>
> - <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The total number of arguments exceeds that specified by the **-L** option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> - End-of-file is encountered on standard input before *size* bytes are accumulated.
>
> Values of *size* up to at least {LINE_MAX} bytes shall be supported, provided that the constraints specified in the DESCRIPTION are met. It shall not be considered an error if a value larger than that supported by the implementation or exceeding the constraints specified in the DESCRIPTION is given; *xargs* shall use the largest value it supports within the constraints.
>
> **-t**
>
> Enable trace mode. Each generated command line shall be written to standard error just prior to invocation.
>
> **-x**
>
> Terminate if a constructed command line will not fit in the implied or specified size (see the **-s** option above).
>
> **-0**
>
> Use a null byte as the input argument delimiter and do not treat any other input bytes as special.
>
> If the mutually exclusive **-0** and **-E** *eofstr* options are both specified, the behavior is unspecified, except that if *eofstr* is the null string the behavior shall be the same as if **-0** was specified without **-E** *eofstr*.

#### <span id="tag_20_152_05"></span>OPERANDS

> The following operands shall be supported:
>
> *utility*
>
> The name of the utility to be invoked, found by search path using the *PATH* environment variable, described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08). If *utility* is omitted, the default shall be the [*echo*](../utilities/echo.html) utility. If the *utility* operand names any of the special built-in utilities in [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15), the results are undefined.
>
> *argument*
>
> An initial option or operand for the invocation of *utility*.

#### <span id="tag_20_152_06"></span>STDIN

> If the **-0** option is not specified, the standard input shall be a text file and the results are unspecified if an end-of-file condition is detected immediately following an escaped \<newline\>.
>
> If the **-0** option is specified, the standard input need not be a text file, and *xargs* shall process the input as bytes, not characters.

#### <span id="tag_20_152_07"></span>INPUT FILES

> The file **/dev/tty** shall be used to read responses required by the **-p** option.

#### <span id="tag_20_152_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *xargs*:
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
> Determine the locale for the behavior of ranges, equivalence classes, and multi-character collating elements used in the extended regular expression defined for the **yesexpr** locale keyword in the *LC_MESSAGES* category.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and the behavior of character classes used in the extended regular expression defined for the **yesexpr** locale keyword in the *LC_MESSAGES* category.
>
> *LC_MESSAGES*
>
> \
> Determine the locale used to process affirmative responses, and the locale used to affect the format and contents of diagnostic messages and prompts written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *PATH*
>
> Determine the location of *utility*, as described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08).

#### <span id="tag_20_152_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_152_10"></span>STDOUT

> Not used.

#### <span id="tag_20_152_11"></span>STDERR

> The standard error shall be used for diagnostic messages and the **-t** and **-p** options. If the **-t** option is specified, the *utility* and its constructed argument list shall be written to standard error, as it will be invoked, prior to invocation. If **-p** is specified, a prompt of the following format shall be written (in the POSIX locale):
>
>
>     "?..."
>
> at the end of the line of the output from **-t**.

#### <span id="tag_20_152_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_152_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_152_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>     0
>
> Successful completion.
>
> 1-125
>
> A command line meeting the specified requirements could not be assembled, one or more of the invocations of *utility* returned a non-zero exit status, or some other error occurred.
>
>   126
>
> The utility specified by *utility* was found but could not be invoked.
>
>   127
>
> The utility specified by *utility* could not be found.

#### <span id="tag_20_152_15"></span>CONSEQUENCES OF ERRORS

> If a command line meeting the specified requirements cannot be assembled, the utility cannot be invoked, an invocation of the utility is terminated by a signal, or an invocation of the utility exits with exit status 255, the *xargs* utility shall write a diagnostic message and exit without processing any remaining input.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_152_16"></span>APPLICATION USAGE

> The 255 exit status allows a utility being used by *xargs* to tell *xargs* to terminate if it knows no further invocations using the current data stream will succeed. Thus, *utility* should explicitly [*exit*](../utilities/V3_chap02.html#exit) with an appropriate value to avoid accidentally returning with 255.
>
> Note that since input is parsed as lines (if **-0** is not specified), with \<blank\> characters separating arguments and \<backslash\>, \<apostrophe\>, and double-quote characters used for quoting, if *xargs* is used to bundle the output of commands like [*find*](../utilities/find.html) *dir* **-print** or [*ls*](../utilities/ls.html) into commands to be executed, unexpected results are likely if any filenames contain \<blank\>, \<newline\>, or quoting characters. This can be solved by using the **-print0** primary of [*find*](../utilities/find.html) together with the *xargs* **-0** option, or by using [*find*](../utilities/find.html) to call a script that converts each file found into a quoted string that is then piped to *xargs*, but in most cases it is preferable just to have [*find*](../utilities/find.html) do the argument aggregation itself by using **-exec** with a `'+'` terminator instead of `';'`. Note that the quoting rules used by *xargs* are not the same as in the shell. They were not made consistent here because existing applications depend on the current rules. An easy (but inefficient) method that can be used to transform input consisting of one argument per line into a quoted form that *xargs* interprets correctly is to precede each non-\<newline\> character with a \<backslash\>. More efficient alternatives are shown in Example 2 and Example 5 below.
>
> On implementations with a large value for {ARG_MAX}, *xargs* may produce command lines longer than {LINE_MAX}. For invocation of utilities, this is not a problem. If *xargs* is being used to create a text file, users should explicitly set the maximum command line length with the **-s** option.
>
> The [*command*](../utilities/command.html), [*env*](../utilities/env.html), [*nice*](../utilities/nice.html), [*nohup*](../utilities/nohup.html), [*time*](../utilities/time.html), [*timeout*](../utilities/timeout.html), and *xargs* utilities have been specified to use exit code 127 if a utility to be invoked cannot be found, so that applications can distinguish "failure to find a utility" from "invoked utility exited with an error indication". The value 127 was chosen because it is not commonly used for other meanings; most utilities use small values for "normal error conditions" and the values above 128 can be confused with termination due to receipt of a signal. The value 126 was chosen in a similar manner to indicate that the utility could be found, but not invoked. Some scripts produce meaningful error messages differentiating the 126 and 127 cases. The distinction between exit codes 126 and 127 is based on KornShell practice that uses 127 when all attempts to *exec* the utility fail with \[ENOENT\], and uses 126 when any attempt to *exec* the utility fails for any other reason.

#### <span id="tag_20_152_17"></span>EXAMPLES

> 1.  The following command combines the output of the parenthesized commands (minus the \<apostrophe\> characters) onto one line, which is then appended to the file log. It assumes that the expansion of `"$0 $*"` does not include any \<apostrophe\> or \<newline\> characters.
>
>
>         (logname; date; printf "'%s'\n" "$0 $*") | xargs -E "" >>log
>
> 2.  The following command invokes [*diff*](../utilities/diff.html) with successive pairs of arguments originally typed as command line arguments.
>
>
>         printf "%s\0" "$@" | xargs -0 -n 2 -x diff --
>
> 3.  In the following command, the user is asked which regular files below the current directory are to be archived.
>
>
>         find . -type f -print0 | xargs -0 -p -L 1 ar -r arch
>
> 4.  The following command invokes *command1* one or more times with multiple arguments, stopping if an invocation of *command1* has a non-zero exit status.
>
>
>         xargs -E "" sh -c 'command1 "$@" || exit 255' sh < xargs_input

#### <span id="tag_20_152_18"></span>RATIONALE

> The *xargs* utility was usually found only in System V-based systems; BSD systems included an *apply* utility that provided functionality similar to *xargs* **-n** *number*. The SVID lists *xargs* as a software development extension. This volume of POSIX.1-2024 does not share the view that it is used only for development, and therefore it is not optional.
>
> The classic application of the *xargs* utility is in conjunction with the [*find*](../utilities/find.html) utility to reduce the number of processes launched by a simplistic use of the [*find*](../utilities/find.html) **-exec** combination. The *xargs* utility is also used to enforce an upper limit on memory required to launch a process. With this basis in mind, this volume of POSIX.1-2024 selected only the minimal features required.
>
> Although the 255 exit status is mostly an accident of historical implementations, it allows a utility being used by *xargs* to tell *xargs* to terminate if it knows no further invocations using the current data stream shall succeed. Any non-zero exit status from a utility falls into the 1-125 range when *xargs* exits. There is no statement of how the various non-zero utility exit status codes are accumulated by *xargs*. The value could be the addition of all codes, their highest value, the last one received, or a single value such as 1. Since no algorithm is arguably better than the others, and since many of the standard utilities say little more (portably) than "pass/fail", no new algorithm was invented.
>
> Several other *xargs* options were removed because simple alternatives already exist within this volume of POSIX.1-2024. For example, the **-i** *replstr* option can be just as efficiently performed using a shell **for** loop. Since *xargs* calls an *exec* function with each input line, the **-i** option does not usually exploit the grouping capabilities of *xargs*.
>
> The requirement that *xargs* never produces command lines such that invocation of *utility* is within 2048 bytes of hitting the POSIX *exec* {ARG_MAX} limitations is intended to guarantee that the invoked utility has room to modify its environment variables and command line arguments and still be able to invoke another utility. Note that the minimum {ARG_MAX} allowed by the System Interfaces volume of POSIX.1-2024 is 4096 bytes and the minimum value allowed by this volume of POSIX.1-2024 is 2048 bytes; therefore, the 2048 bytes difference seems reasonable. Note, however, that *xargs* may never be able to invoke a utility if the environment passed in to *xargs* comes close to using {ARG_MAX} bytes.
>
> The version of *xargs* required by this volume of POSIX.1-2024 is required to wait for the completion of the invoked command before invoking another command. This was done because historical scripts using *xargs* assumed sequential execution. Implementations wanting to provide parallel operation of the invoked utilities are encouraged to add an option enabling parallel invocation, but should still wait for termination of all of the children before *xargs* terminates normally.
>
> The **-e** option was omitted from the ISO POSIX-2:1993 standard in the belief that the *eofstr* option-argument was recognized only when it was on a line by itself and before quote and escape processing were performed, and that the logical end-of-file processing was only enabled if a **-e** option was specified. In that case, a simple [*sed*](../utilities/sed.html) script could be used to duplicate the **-e** functionality. Further investigation revealed that:
>
> - The logical end-of-file string was checked for after quote and escape processing, making a [*sed*](../utilities/sed.html) script that provided equivalent functionality much more difficult to write.
>
> - The default was to perform logical end-of-file processing with an \<underscore\> as the logical end-of-file string.
>
> To correct this misunderstanding, the **-E** *eofstr* option was adopted from the X/Open Portability Guide. Users should note that the description of the **-E** option matches historical documentation of the **-e** option (which was not adopted because it did not support the Utility Syntax Guidelines), by saying that if *eofstr* is the null string, logical end-of-file processing is disabled. Historical implementations of *xargs* actually did not disable logical end-of-file processing; they treated a null argument found in the input as a logical end-of-file string. (A null *string* argument could be generated using single or double-quotes (`'"'` or `""`). Since this behavior was not documented historically, it is considered to be a bug.
>
> The **-I**, **-L**, and **-n** options are mutually-exclusive. Some implementations use the last one specified if more than one is given on a command line; other implementations treat combinations of the options in different ways.

#### <span id="tag_20_152_19"></span>FUTURE DIRECTIONS

> A future version of this standard may require that, when the **-0** option is specified, if the standard input is not empty and does not end with a null byte, *xargs* ignores the trailing non-null bytes.

#### <span id="tag_20_152_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*diff*](../utilities/diff.html#), [*echo*](../utilities/echo.html#), [*find*](../utilities/find.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*exec*](../functions/exec.html#tag_17_129)

#### <span id="tag_20_152_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_152_22"></span>Issue 5

> A second FUTURE DIRECTION is added.

#### <span id="tag_20_152_23"></span>Issue 6

> The obsolescent **-e**, **-i**, and **-l** options are removed.
>
> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - The **-p** option is added.
>
> - In the INPUT FILES section, the file **/dev/tty** is used to read responses required by the **-p** option.
>
> - The STDERR section is updated to describe the **-p** option.
>
> The description of the **-E** option is aligned with the ISO POSIX-2:1993 standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_152_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#123 is applied, changing the description of the *xargs* **-I** option.
>
> Austin Group Interpretation 1003.1-2001 \#126 is applied, changing the description of the *LC_MESSAGES* environment variable.
>
> SD5-XCU-ERN-68 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> SD5-XCU-ERN-128 is applied, clarifying the DESCRIPTION of the logical end-of-file string.
>
> SD5-XCU-ERN-132 is applied, updating the EXAMPLES section.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0149 \[342\] is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0203 \[499\] is applied.

#### <span id="tag_20_152_25"></span>Issue 8

> Austin Group Defect 243 is applied, adding the **-r** and **-0** options.
>
> Austin Group Defect 248 is applied, changing the EXAMPLES section.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
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
