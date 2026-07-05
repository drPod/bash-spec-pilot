The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="pathchk"></span> <span id="tag_20_93"></span>

#### <span id="tag_20_93_01"></span>NAME

> pathchk — check pathnames

#### <span id="tag_20_93_02"></span>SYNOPSIS

> `pathchk`` `**`[`**`-p`**`] [`**`-P`**`]`**` `*`pathname`*`...`

#### <span id="tag_20_93_03"></span>DESCRIPTION

> The *pathchk* utility shall check that one or more pathnames are valid (that is, they could be used to access or create a file without causing syntax errors) and portable (that is, no filename truncation results). More extensive portability checks are provided by the **-p** and **-P** options.
>
> By default, the *pathchk* utility shall check each component of each *pathname* operand based on the underlying file system. A diagnostic shall be written for each *pathname* operand that:
>
> - Is longer than {PATH_MAX} bytes (see **Pathname Variable Values** in XBD [*\<limits.h\>*](../basedefs/limits.h.html))
>
> - Contains any component longer than {NAME_MAX} bytes in its containing directory
>
> - Contains any component in a directory that is not searchable
>
> - Contains any byte sequence that is not valid in its containing directory
>
> The format of the diagnostic message is not specified, but shall indicate the error detected and the corresponding *pathname* operand.
>
> It shall not be considered an error if one or more components of a *pathname* operand do not exist as long as a file matching the pathname specified by the missing components could be created that does not violate any of the checks specified above.

#### <span id="tag_20_93_04"></span>OPTIONS

> The *pathchk* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-p**
>
> Instead of performing checks based on the underlying file system, write a diagnostic for each *pathname* operand that:
>
> - Is longer than {\_POSIX_PATH_MAX} bytes (see **Minimum Values** in XBD [*\<limits.h\>*](../basedefs/limits.h.html))
>
> - Contains any component longer than {\_POSIX_NAME_MAX} bytes
>
> - Contains any character in any component that is not in the portable filename character set
>
> **-P**
>
> Write a diagnostic for each *pathname* operand that:
>
> - Contains a component whose first character is the \<hyphen-minus\> character
>
> - Is empty

#### <span id="tag_20_93_05"></span>OPERANDS

> The following operand shall be supported:
>
> *pathname*
>
> A pathname to be checked.

#### <span id="tag_20_93_06"></span>STDIN

> Not used.

#### <span id="tag_20_93_07"></span>INPUT FILES

> None.

#### <span id="tag_20_93_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *pathchk*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) the precedence of internationalization variables used to determine the values of locale categories.)
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

#### <span id="tag_20_93_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_93_10"></span>STDOUT

> Not used.

#### <span id="tag_20_93_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_93_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_93_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_93_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> All *pathname* operands passed all of the checks.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_93_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_93_16"></span>APPLICATION USAGE

> The [*test*](../utilities/test.html) utility can be used to determine whether a given pathname names an existing file; it does not, however, give any indication of whether or not any component of the pathname was truncated in a directory where the \_POSIX_NO_TRUNC feature is not in effect. The *pathchk* utility does not check for file existence; it performs checks to determine whether a pathname does exist or could be created with no pathname component truncation.
>
> The *noclobber* option in the shell (see the [*set*](../utilities/V3_chap02.html#tag_19_26) special built-in) can be used to atomically create a file. As with all file creation semantics in the System Interfaces volume of POSIX.1-2024, it guarantees atomic creation, but still depends on applications to agree on conventions and cooperate on the use of files after they have been created.
>
> To verify that a pathname meets the requirements of filename portability, applications should use both the **-p** and **-P** options together.

#### <span id="tag_20_93_17"></span>EXAMPLES

> To verify that all pathnames in an imported data interchange archive are legitimate and unambiguous on the current system:
>
>
>     # This example assumes that no pathnames in the archive
>     # contain <newline> characters.
>     pax -f archive | sed -e 's/[^[:alnum:]]/\\&/g' | xargs pathchk --
>     if [ $? -eq 0 ]
>     then
>         pax -r -f archive
>     else
>         echo Investigate problems before importing files.
>         exit 1
>     fi
>
> To verify that all files in the current directory hierarchy could be moved to any system conforming to the System Interfaces volume of POSIX.1-2024 that also supports the [*pax*](../utilities/pax.html) utility:
>
>
>     find . -exec pathchk -p -P {} +
>     if [ $? -eq 0 ]
>     then
>         pax -w -f ../archive .
>     else
>         echo Portable archive cannot be created.
>         exit 1
>     fi
>
> To verify that a user-supplied pathname names a readable file and that the application can create a file extending the given path without truncation and without overwriting any existing file:
>
>
>     case $- in
>         *C*)    reset="";;
>         *)      reset="set +C"
>                 set -C;;
>     esac
>     test -r "$path" && pathchk "$path.out" &&
>         rm "$path.out" > "$path.out"
>     if [ $? -ne 0 ]; then
>         printf "%s: %s not found or %s.out fails \
>     creation checks.\n" $0 "$path" "$path"
>         $reset    # Reset the noclobber option in case a trap
>                   # on EXIT depends on it.
>         exit 1
>     fi
>     $reset
>     PROCESSING < "$path" > "$path.out"
>
> The following assumptions are made in this example:
>
> 1.  **PROCESSING** represents the code that is used by the application to use **\$path** once it is verified that **\$path.out** works as intended.
>
> 2.  The state of the *noclobber* option is unknown when this code is invoked and should be set on exit to the state it was in when this code was invoked. (The **reset** variable is used in this example to restore the initial state.)
>
> 3.  Note the usage of:
>
>
>         rm "$path.out" > "$path.out"
>
>     1.  The *pathchk* command has already verified, at this point, that **\$path.out** is not truncated.
>
>     2.  With the *noclobber* option set, the shell verifies that **\$path.out** does not already exist before invoking [*rm*](../utilities/rm.html).
>
>     3.  If the shell succeeded in creating **\$path.out**, [*rm*](../utilities/rm.html) removes it so that the application can create the file again in the **PROCESSING** step.
>
>     4.  If the **PROCESSING** step wants the file to exist already when it is invoked, the:
>
>
>             rm "$path.out" > "$path.out"
>
>         should be replaced with:
>
>
>             > "$path.out"
>
>         which verifies that the file did not already exist, but leaves **\$path.out** in place for use by **PROCESSING**.

#### <span id="tag_20_93_18"></span>RATIONALE

> The *pathchk* utility was new for the ISO POSIX-2:1993 standard. It, along with the [*set*](../utilities/V3_chap02.html#set) **-C**(*noclobber*) option added to the shell, replaces the *mktemp*, *validfnam*, and *create* utilities that appeared in early proposals. All of these utilities were attempts to solve several common problems:
>
> - Verify the validity (for several different definitions of "valid") of a pathname supplied by a user, generated by an application, or imported from an external source.
>
> - Atomically create a file.
>
> - Perform various string handling functions to generate a temporary filename.
>
> The *create* utility, included in an early proposal, provided checking and atomic creation in a single invocation of the utility; these are orthogonal issues and need not be grouped into a single utility. Note that the *noclobber* option also provides a way of creating a lock for process synchronization; since it provides an atomic *create*, there is no race between a test for existence and the following creation if it did not exist.
>
> Having a function like [*tmpnam*()](../functions/tmpnam.html) in the ISO C standard is important in many high-level languages. The shell programming language, however, has built-in string manipulation facilities, making it very easy to construct temporary filenames. The names needed obviously depend on the application, but are frequently of a form similar to:
>
>
>     $TMPDIR/application_abbreviation$$.suffix
>
> In cases where there is likely to be contention for a given suffix, a simple shell **for** or **while** loop can be used with the shell *noclobber* option to create a file without risk of collisions, as long as applications trying to use the same filename name space are cooperating on the use of files after they have been created.
>
> For historical purposes, **-p** does not check for the use of the \<hyphen-minus\> character as the first character in a component of the pathname, or for an empty *pathname* operand.

#### <span id="tag_20_93_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_93_20"></span>SEE ALSO

> [*2.7 Redirection*](../utilities/V3_chap02.html#tag_19_07), [*set*](../utilities/V3_chap02.html#tag_19_26), [*test*](../utilities/test.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), [*\<limits.h\>*](../basedefs/limits.h.html)

#### <span id="tag_20_93_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_93_22"></span>Issue 7

> Austin Group Interpretations 1003.1-2001 \#039, \#040, and \#094 are applied.
>
> SD5-XCU-ERN-121 is applied, updating the EXAMPLES section.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0127 \[291\] is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0150 \[584\] and XCU/TC2-2008/0151 \[584\] are applied.

#### <span id="tag_20_93_23"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*

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
