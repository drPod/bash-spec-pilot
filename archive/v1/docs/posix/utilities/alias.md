The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="alias"></span> <span id="tag_20_02"></span>

#### <span id="tag_20_02_01"></span>NAME

> alias — define or display aliases

#### <span id="tag_20_02_02"></span>SYNOPSIS

> `alias`` `**`[`***`alias-name`***`[`**`=`*`string`***`]`**`...`**`]`**

#### <span id="tag_20_02_03"></span>DESCRIPTION

> The *alias* utility shall create or redefine alias definitions or write the values of existing alias definitions to standard output. An alias definition provides a string value that shall replace a command name when it is encountered. For information on valid string values, and the processing involved, see [*2.3.1 Alias Substitution*](../utilities/V3_chap02.html#tag_19_03_01).
>
> An alias definition shall affect the current shell execution environment and the execution environments of the subshells of the current shell. When used as specified by this volume of POSIX.1-2024, the alias definition shall not affect the parent process of the current shell nor any utility environment invoked by the shell; see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13).

#### <span id="tag_20_02_04"></span>OPTIONS

> None.

#### <span id="tag_20_02_05"></span>OPERANDS

> The following operands shall be supported:
>
> *alias-name*
>
> Write the alias definition to standard output.
>
> *alias-name*=*string*
>
> \
> Assign the value of *string* to the alias *alias-name*.
>
> If no operands are given, all alias definitions shall be written to standard output.

#### <span id="tag_20_02_06"></span>STDIN

> Not used.

#### <span id="tag_20_02_07"></span>INPUT FILES

> None.

#### <span id="tag_20_02_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *alias*:
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

#### <span id="tag_20_02_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_02_10"></span>STDOUT

> The format for displaying aliases (when no operands or only *name* operands are specified) shall be:
>
>
>     "%s=%s\n", name, value
>
> The *value* string shall be written with appropriate quoting so that it is suitable for reinput to the shell. See the description of shell quoting in [*2.2 Quoting*](../utilities/V3_chap02.html#tag_19_02).

#### <span id="tag_20_02_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_02_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_02_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_02_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> One of the *name* operands specified did not have an alias definition, or an error occurred.

#### <span id="tag_20_02_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_02_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> Care should be taken to avoid alias values that end with a character that could be treated as part of an operator token, as it is unspecified whether the character that follows the alias name in the input can be used as part of the same token (see [*2.3.1 Alias Substitution*](../utilities/V3_chap02.html#tag_19_03_01)). For example, with:
>
>
>     $ alias foo='echo 0'
>     $ foo>&2
>
> the shell can either pass the argument `'0'` to [*echo*](../utilities/echo.html) and redirect fd 1 to fd 2, or pass no arguments to [*echo*](../utilities/echo.html) and redirect fd 0 to fd 2. Changing it to:
>
>
>     $ alias foo='echo "0"'
>
> avoids this problem. The alternative of adding a \<space\> after the `'0'` would also avoid the problem, but in addition it would alter the way the alias works, as described in [*2.3.1 Alias Substitution*](../utilities/V3_chap02.html#tag_19_03_01).
>
> Likewise, given:
>
>
>     $ alias foo='some_command &'
>     $ foo&
>
> the shell may combine the two `'&'` characters into an `&&` (and) operator. Since the alias cannot pass arguments to *some_command* and thus can be expected to be invoked without arguments, adding a \<space\> after the `'&'` would be an acceptable way to prevent this. Alternatively, the alias could be specified as a grouping command:
>
>
>     $ alias foo='{ some_command & }'
>
> Problems can occur for tokens other than operators as well, if the alias is used in unusual ways. For example, with:
>
>
>     $ alias foo='echo $'
>     $ foo((123))
>
> some shells combine the `'$'` and the `"((123))"` to form an arithmetic expansion, but others do not (resulting in a syntax error).

#### <span id="tag_20_02_17"></span>EXAMPLES

> 1.  Create a short alias for a commonly used [*ls*](../utilities/ls.html) command:
>
>
>         alias lf="ls -CF"
>
> 2.  Create a simple "redo" command to repeat previous entries in the command history file:
>
>
>         alias r='fc -s'
>
> 3.  Use 1K units for [*du*](../utilities/du.html):
>
>
>         alias du=du\ -k
>
> 4.  Set up [*nohup*](../utilities/nohup.html) so that it can deal with an argument that is itself an alias name:
>
>
>         alias nohup="nohup "
>
> 5.  Add the **-F** option to interactive uses of [*ls*](../utilities/ls.html), even when executed as `xargs ls` or `xargs -0 ls`:
>
>
>         alias ls='ls -F'
>         alias xargs='xargs '
>         alias -- -0='-0 '
>         find . [...] -print | xargs ls      # breaks on filenames with \n
>                                             # (two aliases expanded)
>         find . [...] -print0 | xargs -0 ls  # minimizes \n issues (three
>                                             # aliases expanded)

#### <span id="tag_20_02_18"></span>RATIONALE

> The *alias* description is based on historical KornShell implementations. Known differences exist between that and the C shell. The KornShell version was adopted to be consistent with all the other KornShell features in this volume of POSIX.1-2024, such as command line editing.
>
> Since *alias* affects the current shell execution environment, it is generally provided as a shell regular built-in.
>
> Historical versions of the KornShell have allowed aliases to be exported to scripts that are invoked by the same shell. This is triggered by the *alias* **-x** flag; it is allowed by this volume of POSIX.1-2024 only when an explicit extension such as **-x** is used. The standard developers considered that aliases were of use primarily to interactive users and that they should normally not affect shell scripts called by those users; functions are available to such scripts.
>
> Historical versions of the KornShell had not written aliases in a quoted manner suitable for reentry to the shell, but this volume of POSIX.1-2024 has made this a requirement for all similar output. Therefore, consistency was chosen over this detail of historical practice.

#### <span id="tag_20_02_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_02_20"></span>SEE ALSO

> [*2.9.5 Function Definition Command*](../utilities/V3_chap02.html#tag_19_09_05)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_02_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_02_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The APPLICATION USAGE section is added.

#### <span id="tag_20_02_23"></span>Issue 7

> The *alias* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The first example is changed to remove the creation of an alias for a standard utility that alters its behavior to be non-conforming.

#### <span id="tag_20_02_24"></span>Issue 8

> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
>
> Austin Group Defect 953 is applied, clarifying that the details of how alias replacement is performed are in the cross-referenced section ( [*2.3.1 Alias Substitution*](../utilities/V3_chap02.html#tag_19_03_01)) and updating the APPLICATION USAGE section.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1630 is applied, adding a new item in EXAMPLES.

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
