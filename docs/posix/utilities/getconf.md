The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="getconf"></span> <span id="tag_20_52"></span>

#### <span id="tag_20_52_01"></span>NAME

> getconf — get configuration values

#### <span id="tag_20_52_02"></span>SYNOPSIS

> `getconf`` `**`[`**`-v specification`**`]`**` `*`system_var`*\
> \
> `getconf`` `**`[`**`-v specification`**`]`**` `*`path_var pathname`*\

#### <span id="tag_20_52_03"></span>DESCRIPTION

> In the first synopsis form, the *getconf* utility shall write to the standard output the value of the variable specified by the *system_var* operand.
>
> In the second synopsis form, the *getconf* utility shall write to the standard output the value of the variable specified by the *path_var* operand for the path specified by the *pathname* operand.
>
> The value of each configuration variable shall be determined as if it were obtained by calling the function from which it is defined to be available by this volume of POSIX.1-2024 or by the System Interfaces volume of POSIX.1-2024 (see the OPERANDS section). The value shall reflect conditions in the current operating environment.

#### <span id="tag_20_52_04"></span>OPTIONS

> The *getconf* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-v ***specification*
>
> \
> Indicate a specific specification and version for which configuration variables shall be determined. If this option is not specified, the values returned correspond to an implementation default conforming compilation environment.
>
> If the command:
>
>
>     getconf _POSIX_V8_ILP32_OFF32
>
> does not write `"-1\n"` or `"undefined\n"` to standard output, then commands of the form:
>
>
>     getconf -v POSIX_V8_ILP32_OFF32 ...
>
> determine values for configuration variables corresponding to the POSIX_V8_ILP32_OFF32 compilation environment specified in [*c17*](../utilities/c17.html#), the EXTENDED DESCRIPTION.
>
> If the command:
>
>
>     getconf _POSIX_V8_ILP32_OFFBIG
>
> does not write `"-1\n"` or `"undefined\n"` to standard output, then commands of the form:
>
>
>     getconf -v POSIX_V8_ILP32_OFFBIG ...
>
> determine values for configuration variables corresponding to the POSIX_V8_ILP32_OFFBIG compilation environment specified in [*c17*](../utilities/c17.html#), the EXTENDED DESCRIPTION.
>
> If the command:
>
>
>     getconf _POSIX_V8_LP64_OFF64
>
> does not write `"-1\n"` or `"undefined\n"` to standard output, then commands of the form:
>
>
>     getconf -v POSIX_V8_LP64_OFF64 ...
>
> determine values for configuration variables corresponding to the POSIX_V8_LP64_OFF64 compilation environment specified in [*c17*](../utilities/c17.html#), the EXTENDED DESCRIPTION.
>
> If the command:
>
>
>     getconf _POSIX_V8_LPBIG_OFFBIG
>
> does not write `"-1\n"` or `"undefined\n"` to standard output, then commands of the form:
>
>
>     getconf -v POSIX_V8_LPBIG_OFFBIG ...
>
> determine values for configuration variables corresponding to the POSIX_V8_LPBIG_OFFBIG compilation environment specified in [*c17*](../utilities/c17.html#), the EXTENDED DESCRIPTION.

#### <span id="tag_20_52_05"></span>OPERANDS

> The following operands shall be supported:
>
> *path_var*
>
> A name of a configuration variable. All of the variables in the Variable column of the table in the DESCRIPTION of the [*fpathconf*()](../functions/fpathconf.html) function defined in the System Interfaces volume of POSIX.1-2024, without the enclosing braces, shall be supported. The implementation may add other local variables.
>
> *pathname*
>
> A pathname for which the variable specified by *path_var* is to be determined.
>
> *system_var*
>
> A name of a configuration variable. All of the following variables shall be supported:
>
> - The names, without the enclosing braces, in the Variable column of the table in the DESCRIPTION of the [*sysconf*()](../functions/sysconf.html) function in the System Interfaces volume of POSIX.1-2024, except for the entries corresponding to \_SC_CLK_TCK, \_SC_GETGR_R_SIZE_MAX, \_SC_GETPW_R_SIZE_MAX, \_SC_NPROCESSORS_CONF, \_SC_NPROCESSORS_ONLN, and \_SC_NSIG.
>
>   For compatibility with earlier versions, the following variable names shall also be supported: POSIX2_C_BIND POSIX2_C_DEV POSIX2_CHAR_TERM POSIX2_FORT_RUN POSIX2_LOCALEDEF POSIX2_SW_DEV POSIX2_UPE POSIX2_VERSION
>
>   and shall be equivalent to the same name prefixed with an \<underscore\>. This requirement may be removed in a future version.
>
> - The names NPROCESSORS_CONF and NPROCESSORS_ONLN. The values of these configuration variables shall be determined as if they were obtained by calling the function [*sysconf*()](../functions/sysconf.html) with the argument \_SC_NPROCESSORS_CONF or \_SC_NPROCESSORS_ONLN, respectively.
>
> - The names of the symbolic constants used as the *name* argument of the [*confstr*()](../functions/confstr.html) function in the System Interfaces volume of POSIX.1-2024, without the \_CS\_ prefix.
>
> - The names of the symbolic constants listed under the headings "Maximum Values" and "Minimum Values" in the description of the [*\<limits.h\>*](../basedefs/limits.h.html) header in the Base Definitions volume of POSIX.1-2024, without the enclosing braces.
>
>   For compatibility with earlier versions, the following variable names shall also be supported: POSIX2_BC_BASE_MAX POSIX2_BC_DIM_MAX POSIX2_BC_SCALE_MAX POSIX2_BC_STRING_MAX POSIX2_COLL_WEIGHTS_MAX POSIX2_EXPR_NEST_MAX POSIX2_LINE_MAX POSIX2_RE_DUP_MAX
>
>   and shall be equivalent to the same name prefixed with an \<underscore\>. This requirement may be removed in a future version.
>
> The implementation may add other local values.

#### <span id="tag_20_52_06"></span>STDIN

> Not used.

#### <span id="tag_20_52_07"></span>INPUT FILES

> None.

#### <span id="tag_20_52_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *getconf*:
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

#### <span id="tag_20_52_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_52_10"></span>STDOUT

> If the specified variable is defined on the system and its value is described to be available from the [*confstr*()](../functions/confstr.html) function defined in the System Interfaces volume of POSIX.1-2024, its value shall be written in the following format:
>
>
>     "%s\n", <value>
>
> Otherwise, if the specified variable is defined on the system, its value shall be written in the following format:
>
>
>     "%d\n", <value>
>
> If the specified variable is valid, but is undefined on the system, *getconf* shall write using the following format:
>
>
>     "undefined\n"
>
> If the variable name is invalid or an error occurs, nothing shall be written to standard output.

#### <span id="tag_20_52_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_52_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_52_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_52_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The specified variable is valid and information about its current state was written successfully.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_52_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_52_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_52_17"></span>EXAMPLES

> The following example illustrates the value of {NGROUPS_MAX}:
>
>
>     getconf NGROUPS_MAX
>
> The following example illustrates the value of {NAME_MAX} for a specific directory:
>
>
>     getconf NAME_MAX /usr
>
> The following example shows how to deal more carefully with results that might be unspecified:
>
>
>     if value=$(getconf PATH_MAX /usr); then
>         if [ "$value" = "undefined" ]; then
>             echo PATH_MAX in /usr is indeterminate.
>         else
>             echo PATH_MAX in /usr is $value.
>         fi
>     else
>         echo Error in getconf.
>     fi

#### <span id="tag_20_52_18"></span>RATIONALE

> The original need for this utility, and for the [*confstr*()](../functions/confstr.html) function, was to provide a way of finding the configuration-defined default value for the *PATH* environment variable. Since *PATH* can be modified by the user to include directories that could contain utilities replacing the standard utilities, shell scripts need a way to determine the system-supplied *PATH* environment variable value that contains the correct search path for the standard utilities. It was later suggested that access to the other variables described in this volume of POSIX.1-2024 could also be useful to applications.
>
> This functionality of *getconf* would not be adequately subsumed by another command such as:
>
>
>     grep var /etc/conf
>
> because such a strategy would provide correct values for neither those variables that can vary at runtime, nor those that can vary depending on the path.
>
> Early proposal versions of *getconf* specified exit status 1 when the specified variable was valid, but not defined on the system. The output string `"undefined"` is now used to specify this case with exit code 0 because so many things depend on an exit code of zero when an invoked utility is successful.

#### <span id="tag_20_52_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_52_20"></span>SEE ALSO

> [*c17*](../utilities/c17.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), [*\<limits.h\>*](../basedefs/limits.h.html)
>
> XSH [*confstr*()](../functions/confstr.html#), [*fpathconf*()](../functions/fpathconf.html#), [*sysconf*()](../functions/sysconf.html#), [*system*()](../functions/system.html#)

#### <span id="tag_20_52_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_52_22"></span>Issue 5

> In the OPERANDS section:
>
> - {NL_MAX} is changed to {NL_NMAX}.
>
> - Entries beginning NL\_ are deleted from the list of standard configuration variables.
>
> - The list of variables previously marked UX is merged with the list marked EX.
>
> - Operands are added to support new Option Groups.
>
> - Operands are added so that *getconf* can determine supported programming environments.

#### <span id="tag_20_52_23"></span>Issue 6

> The Open Group Corrigendum U029/4 is applied, correcting the example command in the last paragraph of the OPTIONS section.
>
> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - Operands are added to determine supported programming environments.
>
> This reference page is updated for alignment with the ISO/IEC 9899:1999 standard. Specifically, new macros for *c99* programming environments are introduced.
>
> XSI marked *system_var* (XBS5\_\*) values are marked LEGACY.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/27 is applied, correcting the descriptions of *path_var* and *system_var* in the OPERANDS section.

#### <span id="tag_20_52_24"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> The EXAMPLES section is corrected.\
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0091 \[125\] is applied.

#### <span id="tag_20_52_25"></span>Issue 8

> Austin Group Defect 339 is applied, adding the *system_var* names NPROCESSORS_CONF and NPROCESSORS_ONLN.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1330 is applied, removing obsolescent interfaces and changing "\_V7\_" to "\_V8\_".

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
