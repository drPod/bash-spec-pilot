The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="who"></span> <span id="tag_20_150"></span>

#### <span id="tag_20_150_01"></span>NAME

> who — display who is on the system

#### <span id="tag_20_150_02"></span>SYNOPSIS

> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` who`` `**`[`**`-mTu`**`] `<img src="../images/opt-start.gif" data-border="0" />`[`**`-abdHlprt`**`] [`***`file`***`]`**<img src="../images/opt-end.gif" data-border="0" />\
> \
>
> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` who`` `**`[`**`-mu`**`]`**` ``-s`` `**`[`**`-bHlprt`**`] [`***`file`***`]`**\
> \
> `who -q`` `**`[`***`file`***`]`**\
> \
> `who am i`\
> \
> `who am I `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_150_03"></span>DESCRIPTION

> The *who* utility shall list various pieces of information about accessible users. The domain of accessibility is implementation-defined.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Based on the options given, *who* can also list the user's name, terminal line, login time, elapsed time since activity occurred on the line, and the process ID of the command interpreter for each current system user. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_150_04"></span>OPTIONS

> The *who* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported. The metavariables, such as \<*line*\>, refer to fields described in the STDOUT section.
>
> **-a**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Process the implementation-defined database or named file with the **-b**, **-d**, **-l**, **-p**, **-r**, **-t**, **-T** and **-u** options turned on. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-b**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write the time and date of the last system reboot. The system reboot time is the time at which the implementation is able to commence running processes. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-d**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write a list of all processes that have expired and not been respawned by the *init* system process. The \<*exit*\> field shall appear for dead processes and contain the termination and exit values of the dead process. This can be useful in determining why a process terminated. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-H**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write column headings above the regular output. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-l**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> (The letter ell.) List only those lines on which the system is waiting for someone to login. The \<*name*\> field shall be **LOGIN** in such cases. Other fields shall be the same as for user entries except that the \<*state*\> field does not exist. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-m**
>
> Output only information about the current terminal.
>
> **-p**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> List any other process that is currently active and has been previously spawned by *init*. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-q**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> (Quick.) List only the names and the number of users currently logged on. When this option is used, all other options shall be ignored. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-r**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write the current *run-level* of the *init* process. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-s**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> List only the \<*name*\>, \<*line*\>, and \<*time*\> fields. This is the default case. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-t**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Indicate the last change to the system clock. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-T**
>
> Show the state of each terminal, as described in the STDOUT section.
>
> **-u**
>
> Write "idle time" for each displayed user in addition to any other information. The idle time is the time since any activity occurred on the user's terminal. The method of determining this is unspecified. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  This option shall list only those users who are currently logged in. The \<*name*\> is the user's login name. The \<*line*\> is the name of the line as found in the directory **/dev**. The \<*time*\> is the time that the user logged in. The \<*activity*\> is the number of hours and minutes since activity last occurred on that particular line. A dot indicates that the terminal has seen activity in the last minute and is therefore "current". If more than twenty-four hours have elapsed or the line has not been used since boot time, the entry shall be marked \<*old*\>. This field is useful when trying to determine whether a person is working at the terminal or not. The \<*pid*\> is the process ID of the user's login process. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_150_05"></span>OPERANDS

> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The following operands shall be supported:
>
> **am i**, **am I**
>
> In the POSIX locale, limit the output to describing the invoking user, equivalent to the **-m** option. The **am** and **i** or **I** need to be separate arguments.
>
> *file*
>
> Specify a pathname of a file to substitute for the implementation-defined database of logged-on users that *who* uses by default. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_150_06"></span>STDIN

> Not used.

#### <span id="tag_20_150_07"></span>INPUT FILES

> None.

#### <span id="tag_20_150_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *who*:
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
> *LC_TIME*
>
> Determine the locale used for the format and contents of the date and time strings.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *TZ*
>
> Determine the timezone used when writing date and time information. If *TZ* is unset or null, an unspecified default timezone shall be used.

#### <span id="tag_20_150_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_150_10"></span>STDOUT

> The *who* utility shall write its default format to the standard output in an implementation-defined format, subject only to the requirement of containing the information described above.
>
> <sup>\[[XSI OF](javascript:open_code('XSI%20OF'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> XSI-conformant systems shall write the default information to the standard output in the following general format:
>
>
>     <name>[<state>]<line><time>[<activity>][<pid>][<comment>][<exit>]
>
> For the **-b** option, \<*line*\> shall be `"system boot"`. The \<*name*\> is unspecified. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The following format shall be used for the **-T** option:
>
>
>     "%s %c %s %s\n" <name>, <terminal state>, <terminal name>,
>         <time of login>
>
> where \<*terminal state*\> is one of the following characters:
>
> `+`
>
> The terminal allows write access to other users.
>
> `-`
>
> The terminal denies write access to other users.
>
> `?`
>
> The terminal write-access state cannot be determined.
>
> `<space>`
>
> This entry is not associated with a terminal.
>
> In the POSIX locale, the \<*time of login*\> shall be equivalent in format to the output of:
>
>
>     date +"%b %e %H:%M"
>
> If the **-u** option is used with **-T**, the idle time shall be added to the end of the previous format in an unspecified format.

#### <span id="tag_20_150_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_150_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_150_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_150_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_150_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_150_16"></span>APPLICATION USAGE

> The name *init* used for the system process is the most commonly used on historical systems, but it may vary.
>
> The "domain of accessibility" referred to is a broad concept that permits interpretation either on a very secure basis or even to allow a network-wide implementation like the historical *rwho*.

#### <span id="tag_20_150_17"></span>EXAMPLES

> None.

#### <span id="tag_20_150_18"></span>RATIONALE

> Due to differences between historical implementations, the base options provided were a compromise to allow users to work with those functions. The standard developers also considered removing all the options, but felt that these options offered users valuable functionality. Additional options to match historical systems are available on XSI-conformant systems.
>
> It is recognized that the *who* command may be of limited usefulness, especially in a multi-level secure environment. The standard developers considered, however, that having some standard method of determining the "accessibility" of other users would aid user portability.
>
> No format was specified for the default *who* output for systems not supporting the XSI option. In such a user-oriented command, designed only for human use, this was not considered to be a deficiency.
>
> The format of the terminal name is unspecified, but the descriptions of [*ps*](../utilities/ps.html), [*talk*](../utilities/talk.html), and [*write*](../utilities/write.html) require that they use the same format.
>
> It is acceptable for an implementation to produce no output for an invocation of *who* **mil**.

#### <span id="tag_20_150_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_150_20"></span>SEE ALSO

> [*mesg*](../utilities/mesg.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_150_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_150_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The *TZ* entry is added to the ENVIRONMENT VARIABLES section.

#### <span id="tag_20_150_23"></span>Issue 7

> SD5-XCU-ERN-58 is applied, clarifying the **-b** option.
>
> The *who* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_150_24"></span>Issue 8

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
