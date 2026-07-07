The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="cd"></span> <span id="tag_20_14"></span>

#### <span id="tag_20_14_01"></span>NAME

> cd — change the working directory

#### <span id="tag_20_14_02"></span>SYNOPSIS

> `cd`` `**`[`**`-L`**`] [`***`directory`***`]`**\
> \
> `cd -P`` `**`[`**`-e`**`] [`***`directory`***`]`**\

#### <span id="tag_20_14_03"></span>DESCRIPTION

> The *cd* utility shall change the working directory of the current shell execution environment (see [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13)) by executing the following steps in sequence. (In the following steps, the symbol **curpath** represents an intermediate value used to simplify the description of the algorithm used by *cd*. There is no requirement that **curpath** be made visible to the application.)
>
> 1.  If no *directory* operand is given and the *HOME* environment variable is empty or undefined, the default behavior is implementation-defined and no further steps shall be taken.
>
> 2.  If no *directory* operand is given and the *HOME* environment variable is set to a non-empty value, the *cd* utility shall behave as if the directory named in the *HOME* environment variable was specified as the *directory* operand.
>
> 3.  If the *directory* operand begins with a \<slash\> character, set **curpath** to the operand and proceed to step 7.
>
> 4.  If the first component of the *directory* operand is dot or dot-dot, proceed to step 6.
>
> 5.  Starting with the first pathname in the \<colon\>-separated pathnames of *CDPATH* (see the ENVIRONMENT VARIABLES section) if the pathname is non-null, test if the concatenation of that pathname, a \<slash\> character if that pathname did not end with a \<slash\> character, and the *directory* operand names a directory. If the pathname is null, test if the concatenation of dot, a \<slash\> character, and the operand names a directory. In either case, if the resulting string names an existing directory, set **curpath** to that string and proceed to step 7. Otherwise, repeat this step with the next pathname in *CDPATH* until all pathnames have been tested.
>
> 6.  Set **curpath** to the *directory* operand.
>
> 7.  If the **-P** option is in effect, proceed to step 10. If **curpath** does not begin with a \<slash\> character, set **curpath** to the string formed by the concatenation of the value of *PWD ,* a \<slash\> character if the value of *PWD* did not end with a \<slash\> character, and **curpath**.
>
> 8.  The **curpath** value shall then be converted to canonical form as follows, considering each component from beginning to end, in sequence:
>
>     1.  Dot components and any \<slash\> characters that separate them from the next component shall be deleted.
>
>     2.  For each dot-dot component, if there is a preceding component and it is neither root nor dot-dot, then:
>
>         1.  If the preceding component does not refer (in the context of pathname resolution with symbolic links followed) to a directory, then the *cd* utility shall display an appropriate error message and no further steps shall be taken.
>
>         2.  The preceding component, all \<slash\> characters separating the preceding component from dot-dot, dot-dot, and all \<slash\> characters separating dot-dot from the following component (if any) shall be deleted.
>
>     3.  An implementation may further simplify **curpath** by removing any trailing \<slash\> characters that are not also leading \<slash\> characters, replacing multiple non-leading consecutive \<slash\> characters with a single \<slash\>, and replacing three or more leading \<slash\> characters with a single \<slash\>. If, as a result of this canonicalization, the **curpath** variable is null, no further steps shall be taken.
>
> 9.  If **curpath** is longer than {PATH_MAX} bytes (including the terminating null) and the *directory* operand was not longer than {PATH_MAX} bytes (including the terminating null), then **curpath** shall be converted from an absolute pathname to an equivalent relative pathname if possible. This conversion shall always be considered possible if the value of *PWD ,* with a trailing \<slash\> added if it does not already have one, is an initial substring of **curpath**. Whether or not it is considered possible under other circumstances is unspecified. Implementations may also apply this conversion if **curpath** is not longer than {PATH_MAX} bytes or the *directory* operand was longer than {PATH_MAX} bytes.
>
> 10. The *cd* utility shall then perform actions equivalent to the [*chdir*()](../functions/chdir.html) function called with **curpath** as the *path* argument. If these actions fail for any reason, the *cd* utility shall display an appropriate error message and the remainder of this step shall not be executed. If the **-P** option is not in effect, the *PWD* environment variable shall be set to the value that **curpath** had on entry to step 9 (i.e., before conversion to a relative pathname).
>
>     If the **-P** option is in effect, the *PWD* environment variable shall be set to the string that would be output by [*pwd*](../utilities/pwd.html) **-P**. If there is insufficient permission on the new directory, or on any parent of that directory, to determine the current working directory, the value of the *PWD* environment variable is unspecified. If both the **-e** and the **-P** options are in effect and *cd* is unable to determine the pathname of the current working directory, *cd* shall complete successfully but return a non-zero exit status.
>
> If, during the execution of the above steps, the *PWD* environment variable is set, the *OLDPWD* shell variable shall also be set to the value of the old working directory (that is the current working directory immediately prior to the call to *cd*). It is unspecified whether, when setting *OLDPWD ,* the shell also causes it to be exported if it was not already.

#### <span id="tag_20_14_04"></span>OPTIONS

> The *cd* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported by the implementation:
>
> **-e**
>
> If the **-P** option is in effect, the current working directory is successfully changed, and the correct value of the *PWD* environment variable cannot be determined, exit with exit status 1.
>
> **-L**
>
> Handle the operand dot-dot logically; symbolic link components shall not be resolved before dot-dot components are processed (see steps 8. and 9. in the DESCRIPTION).
>
> **-P**
>
> Handle the operand dot-dot physically; symbolic link components shall be resolved before dot-dot components are processed (see step 7. in the DESCRIPTION).
>
> If both **-L** and **-P** options are specified, the last of these options shall be used and all others ignored. If neither **-L** nor **-P** is specified, the operand shall be handled dot-dot logically; see the DESCRIPTION.

#### <span id="tag_20_14_05"></span>OPERANDS

> The following operands shall be supported:
>
> *directory*
>
> An absolute or relative pathname of the directory that shall become the new working directory. The interpretation of a relative pathname by *cd* depends on the **-L** option and the *CDPATH* and *PWD* environment variables. If *directory* is an empty string, *cd* shall write a diagnostic message to standard error and exit with non-zero status. If *directory* consists of a single `'-'` (\<hyphen-minus\>) character, the *cd* utility shall behave as if *directory* contained the value of the *OLDPWD* environment variable, except that after it sets the value of *PWD* it shall write the new value to standard output. The behavior is unspecified if *OLDPWD* does not start with a \<slash\> character.

#### <span id="tag_20_14_06"></span>STDIN

> Not used.

#### <span id="tag_20_14_07"></span>INPUT FILES

> None.

#### <span id="tag_20_14_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *cd*:
>
> *CDPATH*
>
> A \<colon\>-separated list of pathnames that refer to directories. The *cd* utility shall use this list in its attempt to change the directory, as described in the DESCRIPTION. An empty string in place of a directory pathname represents the current directory. If *CDPATH* is not set, it shall be treated as if it were an empty string.
>
> *HOME*
>
> The name of the directory, used when no *directory* operand is specified.
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
> *OLDPWD*
>
> A pathname of the previous working directory, used when the operand is `'-'`. If an application sets or unsets the value of *OLDPWD ,* the behavior of *cd* with a `'-'` operand is unspecified.
>
> *PWD*
>
> This variable shall be set as specified in the DESCRIPTION. If an application sets or unsets the value of *PWD ,* the behavior of *cd* is unspecified.

#### <span id="tag_20_14_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_14_10"></span>STDOUT

> If a non-empty directory name from *CDPATH* is used, or if the operand `'-'` is used, and the absolute pathname of the new working directory can be determined, that pathname shall be written to the standard output as follows:
>
>
>     "%s\n", <new directory>
>
> If an absolute pathname of the new current working directory cannot be determined, it is unspecified whether nothing is written to the standard output or the value of **curpath** used in step 10, followed by a \<newline\>, is written to the standard output.
>
> If a non-empty directory name from *CDPATH* is not used, and the directory argument is not `'-'`, there shall be no output.

#### <span id="tag_20_14_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_14_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_14_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_14_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The current working directory was successfully changed and the value of the *PWD* environment variable was set correctly.
>
>  0
>
> The current working directory was successfully changed, the **-e** option is not in effect, the **-P** option is in effect, and the correct value of the *PWD* environment variable could not be determined.
>
> \>0
>
> Either the **-e** option or the **-P** option is not in effect, and an error occurred.
>
>  1
>
> The current working directory was successfully changed, both the **-e** and the **-P** options are in effect, and the correct value of the *PWD* environment variable could not be determined.
>
> \>1
>
> Both the **-e** and the **-P** options are in effect, and an error occurred.

#### <span id="tag_20_14_15"></span>CONSEQUENCES OF ERRORS

> The working directory shall remain unchanged.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_14_16"></span>APPLICATION USAGE

> This utility is required to be intrinsic. See [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07) for details.
>
> Since *cd* affects the current shell execution environment, it is always provided as a shell regular built-in. If it is called in a subshell or separate utility execution environment, such as one of the following:
>
>
>     (cd /tmp)
>     nohup cd
>     find . -exec cd {} \;
>
> it does not affect the working directory of the caller's environment.
>
> The user must have execute (search) permission in *directory* in order to change to it.
>
> Since *cd* treats the operand `'-'` as a special case, applications should not pass arbitrary values as the operand. For example, instead of:
>
>
>     CDPATH= cd -P -- "$dir"
>
> applications should use the following:
>
>
>     case $dir in
>     (/*) cd -P "$dir";;
>     ("") echo >&2 directory is an empty string; exit 1;;
>     (*) CDPATH= cd -P "./$dir";;
>     esac
>
> If an absolute pathname of the new current working directory cannot be determined, and a non-empty directory name from *CDPATH* is used, *cd* may write a pathname to standard output that is not an absolute pathname.

#### <span id="tag_20_14_17"></span>EXAMPLES

> The following template can be used to perform processing in the directory specified by *location* and end up in the current working directory in use before the first *cd* command was issued:
>
>
>     cd location
>     if [ $? -ne 0 ]
>     then
>         print error message
>         exit 1
>     fi
>     ... do whatever is desired as long as the OLDPWD environment variable
>         is not modified
>     cd -

#### <span id="tag_20_14_18"></span>RATIONALE

> The use of the *CDPATH* was introduced in the System V shell. Its use is analogous to the use of the *PATH* variable in the shell. The BSD C shell used a shell parameter *cdpath* for this purpose.
>
> A common extension when *HOME* is undefined is to get the login directory from the user database for the invoking user. This does not occur on System V implementations.
>
> Some historical shells, such as the KornShell, took special actions when the directory name contained a dot-dot component, selecting the logical parent of the directory, rather than the actual parent directory; that is, it moved up one level toward the `'/'` in the pathname, remembering what the user typed, rather than performing the equivalent of:
>
>
>     chdir("..");
>
> In such a shell, the following commands would not necessarily produce equivalent output for all directories:
>
>
>     cd .. && ls      ls ..
>
> This behavior is now the default. It is not consistent with the definition of dot-dot in most historical practice; that is, while this behavior has been optionally available in the KornShell, other shells have historically not supported this functionality. The logical pathname is stored in the *PWD* environment variable when the *cd* utility completes and this value is used to construct the next directory name if *cd* is invoked with the **-L** option.
>
> When the **-P** option is in effect, the correct value of the *PWD* environment variable cannot be determined on some systems, but still results in a zero exit status. The value of *PWD* doesn't matter to some shell scripts and in those cases this is not a problem. In other cases, especially with multiple calls to *cd*, the values of *PWD* and *OLDPWD* are important but the standard provided no easy way to know that this was the case. The **-e** option has been added, even though this was not historic practice, to give script writers a reliable way to know when the value of *PWD* is not reliable.

#### <span id="tag_20_14_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_14_20"></span>SEE ALSO

> [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13), [*pwd*](../utilities/pwd.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*chdir*()](../functions/chdir.html#)

#### <span id="tag_20_14_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_14_22"></span>Issue 6

> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - The *cd* **-** operand, *PWD ,* and *OLDPWD* are added.
>
> The **-L** and **-P** options are added to align with the IEEE P1003.2b draft standard. This also includes the introduction of a new description to include the effect of these options.\
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/14 is applied, changing the SYNOPSIS to make it clear that the **-L** and **-P** options are mutually-exclusive.

#### <span id="tag_20_14_23"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#037 is applied.
>
> Austin Group Interpretation 1003.1-2001 \#199 is applied, clarifying how the *cd* utility handles concatenation of two pathnames when the first pathname ends in a \<slash\> character.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> Step 7 of the processing performed by *cd* is revised to refer to **curpath** instead of "the operand".
>
> Changes to the [*pwd*](../utilities/pwd.html) utility and *PWD* environment variable have been made to match the changes to the [*getcwd*()](../functions/getcwd.html) function made for Austin Group Interpretation 1003.1-2001 \#140.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0076 \[230\], XCU/TC1-2008/0077 \[240\], XCU/TC1-2008/0078 \[240\], and XCU/TC1-2008/0079 \[123\] are applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0074 \[584\] is applied.

#### <span id="tag_20_14_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 253 is applied, adding the **-e** option.
>
> Austin Group Defect 854 is applied, adding a note to the APPLICATION USAGE section that this utility is required to be intrinsic.
>
> Austin Group Defect 1045 is applied, clarifying the behavior when the *directory* operand is `'-'`.
>
> Austin Group Defect 1047 is applied, requiring *cd* to treat an empty *directory* operand as an error
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1527 is applied, clarifying the behavior when an absolute pathname of the new current working directory cannot be determined.
>
> Austin Group Defect 1601 is applied, clarifying that when setting *OLDPWD ,* the shell need not cause it to be exported if it was not already.

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
