The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="test"></span> <span id="tag_20_121"></span>

#### <span id="tag_20_121_01"></span>NAME

> test — evaluate expression

#### <span id="tag_20_121_02"></span>SYNOPSIS

> `test`` `**`[`***`expression`***`]`**\
> \
> `[`` `**`[`***`expression`***`]`**` ``]`\

#### <span id="tag_20_121_03"></span>DESCRIPTION

> The *test* utility shall evaluate the *expression* and indicate the result of the evaluation by its exit status. An exit status of zero indicates that the expression evaluated as true and an exit status of 1 indicates that the expression evaluated as false.
>
> In the second form of the utility, where the utility name used is *\[* rather than *test*, the application shall ensure that the closing square bracket is a separate argument. The *test* and *\[* utilities may be implemented as a single linked utility which examines the basename of the zeroth command line argument to determine whether to behave as the *test* or *\[* variant. Applications using the *exec* family of functions to execute these utilities shall ensure that the argument passed in *arg0* or *argv*\[0\] is `'['` when executing the *\[* utility and has a basename of `"test"` when executing the *test* utility.

#### <span id="tag_20_121_04"></span>OPTIONS

> The *test* utility shall not recognize the `"--"` argument in the manner specified by Guideline 10 in XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02). In addition, when the utility name used is *\[* the utility does not conform to Guidelines 1 and 2.
>
> No options shall be supported.

#### <span id="tag_20_121_05"></span>OPERANDS

> The application shall ensure that all operators and elements of primaries are presented as separate arguments to the *test* utility.
>
> The following primaries can be used to construct *expression*:
>
> **-b ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a block special file. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that is not a block special file.
>
> **-c ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a character special file. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that is not a character special file.
>
> **-d ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a directory. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that is not a directory.
>
> **-e ***pathname*
>
> True if *pathname* resolves to an existing directory entry. False if *pathname* cannot be resolved.
>
> *pathname1*** -ef ***pathname2*
>
> \
> True if *pathname1* and *pathname2* resolve to existing directory entries for the same file; otherwise, false.
>
> **-f ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a regular file. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that is not a regular file.
>
> **-g ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a file that has its set-group-ID flag set. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that does not have its set-group-ID flag set.
>
> **-h ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a symbolic link. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that is not a symbolic link. If the final component of *pathname* is a symbolic link, that symbolic link is not followed.
>
> **-L ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a symbolic link. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that is not a symbolic link. If the final component of *pathname* is a symbolic link, that symbolic link is not followed.
>
> **-n ***string*
>
> True if the length of *string* is non-zero; otherwise, false.
>
> *pathname1*** -nt ***pathname2*
>
> \
> True if *pathname1* resolves to an existing file and *pathname2* cannot be resolved, or if both resolve to existing files and *pathname1* is newer than *pathname2* according to their last data modification timestamps; otherwise, false.
>
> *pathname1*** -ot ***pathname2*
>
> \
> True if *pathname2* resolves to an existing file and *pathname1* cannot be resolved, or if both resolve to existing files and *pathname1* is older than *pathname2* according to their last data modification timestamps; otherwise, false.
>
> **-p ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a FIFO. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that is not a FIFO.
>
> **-r ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a file for which permission to read from the file is granted, as defined in [*1.1.1.4 File Read, Write, and Creation*](../utilities/V3_chap01.html#tag_18_01_01_04). False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file for which permission to read from the file is not granted.
>
> **-S ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a socket. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that is not a socket.
>
> **-s ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a file that has a size greater than zero. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that does not have a size greater than zero.
>
> **-t ***file_descriptor*
>
> \
> True if file descriptor number *file_descriptor* is open and is associated with a terminal. False if *file_descriptor* is not a valid file descriptor number, or if file descriptor number *file_descriptor* is not open, or if it is open but is not associated with a terminal.
>
> **-u ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a file that has its set-user-ID flag set. False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file that does not have its set-user-ID flag set.
>
> **-w ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a file for which permission to write to the file is granted, as defined in [*1.1.1.4 File Read, Write, and Creation*](../utilities/V3_chap01.html#tag_18_01_01_04). False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file for which permission to write to the file is not granted.
>
> **-x ***pathname*
>
> True if *pathname* resolves to an existing directory entry for a file for which permission to execute the file (or search it, if it is a directory) is granted, as defined in [*1.1.1.4 File Read, Write, and Creation*](../utilities/V3_chap01.html#tag_18_01_01_04). False if *pathname* cannot be resolved, or if *pathname* resolves to an existing directory entry for a file for which permission to execute (or search) the file is not granted.
>
> **-z ***string*
>
> True if the length of string *string* is zero; otherwise, false.
>
> *string*
>
> True if the string *string* is not the null string; otherwise, false.
>
> *s1*** = ***s2*
>
> True if the strings *s1* and *s2* are identical; otherwise, false.
>
> *s1*** != ***s2*
>
> True if the strings *s1* and *s2* are not identical; otherwise, false.
>
> *s1*** \> ***s2*
>
> True if *s1* collates after *s2* in the current locale; otherwise, false.
>
> *s1*** \< ***s2*
>
> True if *s1* collates before *s2* in the current locale; otherwise, false.
>
> *n1*** -eq ***n2*
>
> True if the integers *n1* and *n2* are algebraically equal; otherwise, false.
>
> *n1*** -ne ***n2*
>
> True if the integers *n1* and *n2* are not algebraically equal; otherwise, false.
>
> *n1*** -gt ***n2*
>
> True if the integer *n1* is algebraically greater than the integer *n2*; otherwise, false.
>
> *n1*** -ge ***n2*
>
> True if the integer *n1* is algebraically greater than or equal to the integer *n2*; otherwise, false.
>
> *n1*** -lt ***n2*
>
> True if the integer *n1* is algebraically less than the integer *n2*; otherwise, false.
>
> *n1*** -le ***n2*
>
> True if the integer *n1* is algebraically less than or equal to the integer *n2*; otherwise, false.
>
> With the exception of the **-h** *pathname* and **-L** *pathname* primaries, if a *pathname*, *pathname1*, or *pathname2* argument is a symbolic link, *test* shall evaluate the expression by resolving the symbolic link and using the file referenced by the link.
>
> These primaries can be combined with the following operator:
>
> **! ***expression*
>
> True if *expression* is false. False if *expression* is true.
>
> The primaries with two elements of the form:
>
>
>     -primary_operator primary_operand
>
> are known as *unary primaries*. The primaries with three elements in either of the two forms:
>
>
>     primary_operand -primary_operator primary_operand
>
>
>     primary_operand primary_operator primary_operand
>
> are known as *binary primaries*. Additional implementation-defined operators and *primary_operator*s may be provided by implementations. They shall be of the form -*operator* where the first character of *operator* is not a digit.
>
> The algorithm for determining the precedence of the operators and the return value that shall be generated is based on the number of arguments presented to *test*. (However, when using the `"[...]"` form, the \<right-square-bracket\> final argument shall not be counted in this algorithm.)
>
> In the following list, \$1, \$2, \$3, and \$4 represent the arguments presented to *test*:
>
> 0 arguments:
>
> Exit false (1).
>
> 1 argument:
>
> Exit true (0) if \$1 is not null; otherwise, exit false.
>
> 2 arguments:
>
> - If \$1 is `'!'`, exit true if \$2 is null, false if \$2 is not null.
>
> - If \$1 is a unary primary, exit true if the unary test is true, false if the unary test is false.
>
> - Otherwise, produce unspecified results.
>
> 3 arguments:
>
> - If \$2 is a binary primary, perform the binary test of \$1 and \$3.
>
> - If \$1 is `'!'`, negate the two-argument test of \$2 and \$3.
>
> - Otherwise, produce unspecified results.
>
> 4 arguments:
>
> - If \$1 is `'!'`, negate the three-argument test of \$2, \$3, and \$4.
>
> - Otherwise, the results are unspecified.
>
> \>4 arguments:
>
> The results are unspecified.

#### <span id="tag_20_121_06"></span>STDIN

> Not used.

#### <span id="tag_20_121_07"></span>INPUT FILES

> None.

#### <span id="tag_20_121_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *test*:
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
> Determine the locale for the behavior of the **\>** and **\<** string comparison operators.
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

#### <span id="tag_20_121_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_121_10"></span>STDOUT

> Not used.

#### <span id="tag_20_121_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_121_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_121_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_121_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> *expression* evaluated to true.
>
>  1
>
> *expression* evaluated to false or *expression* was missing.
>
> \>1
>
> An error occurred.

#### <span id="tag_20_121_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_121_16"></span>APPLICATION USAGE

> Since `'>'` and `'<'` are operators in the shell language, applications need to quote them when passing them as arguments to *test* from a shell.
>
> The **-a** and **-o** binary primaries and the `'('` and `')'` operators have been removed. (Many expressions using them were ambiguously defined by the grammar depending on the specific expressions being evaluated.) Scripts using these expressions should be converted to the forms given below. Even though many implementations will continue to support these forms, scripts should be extremely careful when dealing with user-supplied input that could be confused with these and other primaries and operators. Unless the application developer knows all the cases that produce input to the script, invocations like:
>
>
>     test "$1" -a "$2"
>
> should be written as:
>
>
>     test "$1" && test "$2"
>
> to avoid problems if a user supplied values such as \$1 set to `'!'` and \$2 set to the null string. That is, replace:
>
>
>     test expr1 -a expr2
>
> with:
>
>
>     test expr1 && test expr2
>
> and replace:
>
>
>     test expr1 -o expr2
>
> with:
>
>
>     test expr1 || test expr2
>
> but note that, in *test*, **-a** was specified as having higher precedence than **-o** while `"&&"` and `"||"` have equal precedence in the shell.
>
> Parentheses or braces can be used in the shell command language to effect grouping.
>
> The two commands:
>
>
>     test "$1"
>     test ! "$1"
>
> could not be used reliably on some historical systems. Unexpected results would occur if such a *string* expression were used and \$1 expanded to `'!'`, `'('`, or a known unary primary. Better constructs are:
>
>
>     test -n "$1"
>     test -z "$1"
>
> respectively.
>
> Historical systems have also been unreliable given the common construct:
>
>
>     test "$response" = "expected string"
>
> One of the following is a more reliable form:
>
>
>     test "X$response" = "Xexpected string"
>     test "expected string" = "$response"
>
> Note that the second form assumes that *expected string* could not be confused with any unary primary. If *expected string* starts with `'-'`, `'('`, `'!'`, or even `'='`, the first form should be used instead. Using the preceding rules, any of the three comparison forms is reliable, given any input. (However, note that the strings are quoted in all cases.)
>
> Historically, the string comparison binary primaries, `'='` and `"!="`, had a higher precedence than any unary primary in the greater than 4 argument case, and consequently unexpected results could occur if arguments were not properly prepared. For example, in:
>
>
>     test -d "$1" -o -d "$2"
>
> If \$1 evaluates to a possible directory name of `'='`, the first three arguments are considered a string comparison, which causes a syntax error when the second **-d** is encountered. The following form prevents this:
>
>
>     test -d "$1" || test -d "$2"
>
> Also in the greater than 4 argument case:
>
>
>     test "$1" = "bat" -a "$2" = "ball"
>
> syntax errors would occur if \$1 evaluates to `'('` or `'!'`. One of the following forms prevents this; the second is preferred:
>
>
>     test "$1" = "bat" && test "$2" = "ball"
>     test "X$1" = "Xbat" && test "X$2" = "Xball"
>
> Note that none of the following examples are permitted by the syntax described:
>
>
>     [-f file]
>     [-f file ]
>     [ -f file]
>     [ -f file
>     test -f file ]
>
> In the first two cases, if a utility named *\[-f* exists, that utility would be invoked, and not *test*. In the remaining cases, the brackets are mismatched, and the behavior is unspecified. However:
>
>
>     test ! ]
>
> does have a defined meaning, and must exit with status 1. Similarly:
>
>
>     test ]
>
> must exit with status 0.

#### <span id="tag_20_121_17"></span>EXAMPLES

> 1.  Exit if there are not two or three arguments (two variations):
>
>
>         if [ $# -ne 2 ] && [ $# -ne 3 ]; then exit 1; fi
>         if [ $# -lt 2 ] || [ $# -gt 3 ]; then exit 1; fi
>
> 2.  Perform a [*mkdir*](../utilities/mkdir.html) if a directory does not exist:
>
>
>         test ! -d tempdir && mkdir tempdir
>
> 3.  Wait for a file to become non-readable:
>
>
>         while test -r thefile
>         do
>             sleep 30
>         done
>         echo '"thefile" is no longer readable'
>
> 4.  Perform a command if the argument is one of three strings (two variations):
>
>
>         if [ "$1" = "pear" ] || [ "$1" = "grape" ] || [ "$1" = "apple" ]
>         then
>             command
>         fi
>
>
>         case "$1" in
>             pear|grape|apple) command ;;
>         esac

#### <span id="tag_20_121_18"></span>RATIONALE

> The KornShell-derived conditional command (double bracket **\[\[\]\]**) was removed from the shell command language description in an early proposal. Objections were raised that the real problem is misuse of the *test* command (**\[**), and putting it into the shell is the wrong way to fix the problem. Instead, proper documentation and a new shell reserved word (**!**) are sufficient. A later proposal to add **\[\[\]\]** in Issue 8 was also rejected because existing implementations of it were found to be error-prone in a similar way to historical versions of *test*, and there was also too much variation in behavior between shells that support it.
>
> Tests that require multiple *test* operations can be done at the shell level using individual invocations of the *test* command and shell logicals, rather than using the error-prone historical **-a** and **-o** operators of *test*.
>
> The BSD and System V versions of **-f** were not the same. The BSD definition was:
>
> **-f ***file*
>
> True if *file* exists and is not a directory.
>
> The SVID version (true if the file exists and is a regular file) was chosen for this volume of POSIX.1-2024 because its use is consistent with the **-b**, **-c**, **-d**, and **-p** operands (*file* exists and is a specific file type).
>
> The **-e** primary, possessing similar functionality to that provided by the C shell, was added because it provides the only way for a shell script to find out if a file exists without trying to open the file. Since implementations are allowed to add additional file types, a portable script cannot use:
>
>
>     test -b foo || test -c foo || test -d foo || test -f foo || test -p foo
>
> to find out if **foo** is an existing file. On historical BSD systems, the existence of a file could be determined by:
>
>
>     test -f foo || test -d foo
>
> but there was no easy way to determine that an existing file was a regular file. An early proposal used the KornShell **-a** primary (with the same meaning), but this was changed to **-e** because there were concerns about the high probability of humans confusing the **-a** primary with the historical **-a** binary operator.
>
> The following options were not included in this volume of POSIX.1-2024, although they are provided by some implementations. These operands should not be used by new implementations for other purposes:
>
> **-k ***file*
>
> True if *file* exists and its sticky bit is set.
>
> **-C ***file*
>
> True if *file* is a contiguous file.
>
> **-V ***file*
>
> True if *file* is a version file.
>
> The following option was not included because it was undocumented in most implementations, has been removed from some implementations (including System V), and the functionality is provided by the shell (see [*2.6.2 Parameter Expansion*](../utilities/V3_chap02.html#tag_19_06_02).
>
> **-l ***string*
>
> The length of the string *string*.
>
> The **-b**, **-c**, **-g**, **-p**, **-u**, and **-x** operands are derived from the SVID; historical BSD does not provide them. The **-k** operand is derived from System V; historical BSD does not provide it.
>
> On historical BSD systems, *test* **-w** *directory* always returned false because *test* tried to open the directory for writing, which always fails.
>
> Some additional primaries newly invented or from the KornShell appeared in an early proposal as part of the conditional command (**\[\[\]\]**): *s1* **\>** *s2*, *s1* **\<** *s2*, *f1* **-nt** *f2*, *f1* **-ot** *f2*, and *f1* **-ef** *f2*. They were not carried forward into the *test* utility when the conditional command was removed from the shell because they had not been included in the *test* utility built into historical implementations of the [*sh*](../utilities/sh.html) utility. However, they were later added to this standard once support for them became widespread.
>
> The **-t** *file_descriptor* primary is shown with a mandatory argument because the grammar is ambiguous if it can be omitted. Historical implementations have allowed it to be omitted, providing a default of 1.
>
> It is noted that `'['` is not part of the portable filename character set; however, since it is required to be encoded by a single byte, and is part of the portable character set, the name of this utility forms a character string across all supported locales.

#### <span id="tag_20_121_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_121_20"></span>SEE ALSO

> [*1.1.1.4 File Read, Write, and Creation*](../utilities/V3_chap01.html#tag_18_01_01_04), [*find*](../utilities/find.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_121_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_121_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_121_23"></span>Issue 6

> The **-h** operand is added for symbolic links, and access permission requirements are clarified for the **-r**, **-w**, and **-x** operands to align with the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> The **-L** and **-S** operands are added for symbolic links and sockets.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/38 is applied, adding XSI margin marking and shading to a line in the OPERANDS section referring to the use of parentheses as arguments to the *test* utility.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/30 is applied, rewording the existence primaries for the *test* utility.

#### <span id="tag_20_121_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#107 is applied.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0143 \[291\] is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0191 \[898\], XCU/TC2-2008/0192 \[730\], and XCU/TC2-2008/0193 \[898\] are applied.

#### <span id="tag_20_121_25"></span>Issue 8

> Austin Group Defect 375 is applied, adding the *pathname1*** -ef ***pathname2*, *pathname1*** -nt ***pathname2*, *pathname1*** -ot ***pathname2*, *s1*** \> ***s2*, and *s1*** \< ***s2* primaries.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1330 is applied, removing the obsolescent (and optional) **-a** and **-o** binary primaries, and `'('` and `')'` operators.
>
> Austin Group Defect 1348 is applied, removing "()" from "the *exec*() family of functions".
>
> Austin Group Defect 1373 is applied, clarifying that when the utility name used is *\[* the utility does not conform to Guidelines 1 and 2.

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
