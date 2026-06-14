The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="ps"></span> <span id="tag_20_98"></span>

#### <span id="tag_20_98_01"></span>NAME

> ps — report process status

#### <span id="tag_20_98_02"></span>SYNOPSIS

> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` ps`` `**`[`**`-aAw`**`] [`**`-defl`**`] [`**`-g`` `*`grouplist`***`]`<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />` [`**`-G`` `*`grouplist`***`]`\**
> ` ``      `` `**`[`**`-n`` `*`namelist`***`]`<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />` [`**`-o`` `*`format`***`]`**`...`` `**`[`**`-p`` `*`proclist`***`] [`**`-t`` `*`termlist`***`]`\**
> ` ``      `` `**`[`**`-u`` `*`userlist`***`]`<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />` [`**`-U`` `*`userlist`***`]`**

#### <span id="tag_20_98_03"></span>DESCRIPTION

> The *ps* utility shall write information about processes, subject to having appropriate privileges to obtain information about those processes.
>
> By default, *ps* shall select all processes with the same effective user ID as the current user and the same controlling terminal as the invoker.

#### <span id="tag_20_98_04"></span>OPTIONS

> The *ps* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a**
>
> Write information for all processes associated with terminals. Implementations may omit session leaders from this list.
>
> **-A**
>
> Write information for all processes.
>
> **-d**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write information for all processes, except session leaders. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-e**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write information for all processes. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> (Equivalent to **-A**.)
>
> **-f**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Generate a **full** listing. (See the STDOUT section for the contents of a **full** listing.) <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-g ***grouplist*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write information for processes whose session leaders are given in *grouplist*. The application shall ensure that the *grouplist* is a single argument in the form of a \<blank\> or \<comma\>-separated list. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-G ***grouplist*
>
> Write information for processes whose real group ID numbers are given in *grouplist*. The application shall ensure that the *grouplist* is a single argument in the form of a \<blank\> or \<comma\>-separated list.
>
> **-l**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Generate a **long** listing. (See STDOUT for the contents of a **long** listing.) <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-n ***namelist*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Specify the name of an alternative system *namelist* file in place of the default. The name of the default file and the format of a *namelist* file are unspecified. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-o ***format*
>
> Write information according to the format specification given in *format*. This is fully described in the STDOUT section. Multiple **-o** options can be specified; the format specification shall be interpreted as the \<space\>-separated concatenation of all the *format* option-arguments.
>
> **-p ***proclist*
>
> Write information for processes whose process ID numbers are given in *proclist*. The application shall ensure that the *proclist* is a single argument in the form of a \<blank\> or \<comma\>-separated list.
>
> **-t ***termlist*
>
> Write information for processes associated with terminals given in *termlist*. The application shall ensure that the *termlist* is a single argument in the form of a \<blank\> or \<comma\>-separated list. Terminal identifiers shall be given in an implementation-defined format. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  On XSI-conformant systems, they shall be given in one of two forms: the device's filename (for example, **tty04**) or, if the device's filename starts with **tty**, just the identifier following the characters **tty** (for example, `"04"`). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-u ***userlist*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write information for processes whose user ID numbers or login names are given in *userlist*. The application shall ensure that the *userlist* is a single argument in the form of a \<blank\> or \<comma\>-separated list. In the listing, the numerical user ID shall be written unless the **-f** option is used, in which case the login name shall be written. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-U ***userlist*
>
> Write information for processes whose real user ID numbers or login names are given in *userlist*. The application shall ensure that the *userlist* is a single argument in the form of a \<blank\> or \<comma\>-separated list.
>
> **-w**
>
> Behave as if the *COLUMNS* environment variable had a value of at least 132. If the **-w** option is not specified or is specified exactly once, all output lines shall contain no more than the greater of {LINE_MAX} and *COLUMNS* bytes provided that no format name is specified multiple times.
>
> With the exception of <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **-f**, **-l**, **-n** *namelist*, <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  and **-o** *format*, all of the options shown are used to select processes. If any are specified, the default list shall be ignored and *ps* shall select the processes represented by the inclusive OR of all the selection-criteria options.

#### <span id="tag_20_98_05"></span>OPERANDS

> None.

#### <span id="tag_20_98_06"></span>STDIN

> Not used.

#### <span id="tag_20_98_07"></span>INPUT FILES

> None.

#### <span id="tag_20_98_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *ps*:
>
> *COLUMNS*
>
> Override the system-selected horizontal display line size, used to determine the number of text columns to display. See XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08) for valid values and results when it is unset or null.
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *LC_TIME*
>
> Determine the format and contents of the date and time strings displayed.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *TZ*
>
> Determine the timezone used to calculate date and time strings displayed. If *TZ* is unset or null, an unspecified default timezone shall be used.

#### <span id="tag_20_98_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_98_10"></span>STDOUT

> When the **-o** option is not specified, the standard output format is unspecified.\
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> On XSI-conformant systems, the output format shall be as follows. The column headings and descriptions of the columns in a *ps* listing are given below. The precise meanings of these fields are implementation-defined. The letters `'f'` and `'l'` (below) indicate the option (**full** or **long**) that shall cause the corresponding heading to appear; **all** means that the heading always appears. Note that these two options determine only what information is provided for a process; they do not determine which processes are listed.
>
> |  |  |  |
> |:---|:---|:---|
> | **F** | \(l\) | Flags (octal and additive) associated with the process. |
> | **S** | \(l\) | The state of the process. |
> | **UID** | (f,l) | The user ID number of the process owner; the login name is printed under the **-f** option. |
> | **PID** | (all) | The process ID of the process; it is possible to kill a process if this datum is known. |
> | **PPID** | (f,l) | The process ID of the parent process. |
> | **C** | (f,l) | Processor utilization for scheduling. |
> | **PRI** | \(l\) | The priority of the process; higher numbers mean lower priority. |
> | **NI** | \(l\) | Nice value; used in priority computation. |
> | **ADDR** | \(l\) | The address of the process. |
> | **SZ** | \(l\) | The size in pages of the total memory requirements of the process, including text, data, stack, mapped memory and other resources. |
> | **WCHAN** | \(l\) | The event for which the process is waiting or sleeping; if blank, the process is running. |
> | **STIME** | \(f\) | Starting time of the process. |
> | **TTY** | (all) | The controlling terminal for the process. |
> | **TIME** | (all) | The cumulative execution time for the process. |
> | **CMD** | (all) | The command name; the full command name and its arguments are written under the **-f** option. |
>
> A process that has exited and has a parent, but has not yet been waited for by the parent, shall be marked **defunct**.
>
> Under the option **-f**, *ps* tries to determine the command name and arguments given when the process was created by examining memory or the swap area. Failing this, the command name, as it would appear without the option **-f**, is written in square brackets. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The **-o** option allows the output format to be specified under user control.
>
> The application shall ensure that the format specification is a list of names presented as a single argument, \<blank\> or \<comma\>-separated. Each variable has a default header. The default header can be overridden by appending an \<equals-sign\> and the new text of the header. The rest of the characters in the argument shall be used as the header text. The fields specified shall be written in the order specified on the command line, and should be arranged in columns in the output. The field widths shall be selected by the system to be at least as wide as the header text (default or overridden value). If the header text is null, such as **-o** *user*=, the field width shall be at least as wide as the default header text. If all header text fields are null, no header line shall be written.
>
> The following names are recognized in the POSIX locale:
>
> **ruser**
>
> The real user ID of the process. This shall be the textual user ID, if it can be obtained and the field width permits, or a decimal representation otherwise.
>
> **user**
>
> The effective user ID of the process. This shall be the textual user ID, if it can be obtained and the field width permits, or a decimal representation otherwise.
>
> **rgroup**
>
> The real group ID of the process. This shall be the textual group ID, if it can be obtained and the field width permits, or a decimal representation otherwise.
>
> **group**
>
> The effective group ID of the process. This shall be the textual group ID, if it can be obtained and the field width permits, or a decimal representation otherwise.
>
> **pid**
>
> The decimal value of the process ID.
>
> **ppid**
>
> The decimal value of the parent process ID.
>
> **pgid**
>
> The decimal value of the process group ID.
>
> **pcpu**
>
> The ratio of CPU time used recently to CPU time available in the same period, expressed as a percentage. The meaning of "recently" in this context is unspecified. The CPU time available is determined in an unspecified manner.
>
> **vsz**
>
> The size of the process in (virtual) memory in 1024 byte units as a decimal integer.
>
> **nice**
>
> The decimal value of the nice value of the process; see [*nice*](../utilities/nice.html).
>
> **etime**
>
> In the POSIX locale, the elapsed time since the process was started, in the form:
>
>
>     [[dd-]hh:]mm:ss
>
> where *dd* shall represent the number of days, *hh* the number of hours, *mm* the number of minutes, and *ss* the number of seconds. The *dd* field shall be a decimal integer. The *hh*, *mm*, and *ss* fields shall be two-digit decimal integers padded on the left with zeros.
>
> **time**
>
> In the POSIX locale, the cumulative CPU time of the process in the form:
>
>
>     [dd-]hh:mm:ss
>
> The *dd*, *hh*, *mm*, and *ss* fields shall be as described in the **etime** specifier.
>
> **tty**
>
> The name of the controlling terminal of the process (if any) in the same format used by the [*who*](../utilities/who.html) utility.
>
> **comm**
>
> The name of the command being executed (*argv*\[0\] value) as a string.
>
> **args**
>
> The command with all its arguments as a string. The implementation may truncate this value to the field width; it is implementation-defined whether any further truncation occurs. It is unspecified whether the string represented is a version of the argument list as it was passed to the command when it started, or is a version of the arguments as they may have been modified by the application. Applications cannot depend on being able to modify their argument list and having that modification be reflected in the output of *ps*.
>
> Any field need not be meaningful in all implementations. In such a case a \<hyphen-minus\> (`'-'`) should be output in place of the field value.
>
> Only **comm** and **args** shall be allowed to contain \<blank\> characters; all others shall not. Any implementation-defined variables shall be specified in the system documentation along with the default header and indicating whether the field may contain \<blank\> characters.
>
> The following table specifies the default header to be used in the POSIX locale corresponding to each format specifier.\
>
> Table: Variable Names and Default Headers in *ps*
>
> | **Format Specifier** | **Default Header** | **Format Specifier** | **Default Header** |
> |:---|:---|:---|:---|
> | **args** | **COMMAND** | **ppid** | **PPID** |
> | **comm** | **COMMAND** | **rgroup** | **RGROUP** |
> | **etime** | **ELAPSED** | **ruser** | **RUSER** |
> | **group** | **GROUP** | **time** | **TIME** |
> | **nice** | **NI** | **tty** | **TT** |
> | **pcpu** | **%CPU** | **user** | **USER** |
> | **pgid** | **PGID** | **vsz** | **VSZ** |
> | **pid** | **PID** | ** ** | ** ** |

#### <span id="tag_20_98_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_98_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_98_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_98_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_98_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_98_16"></span>APPLICATION USAGE

> Things can change while *ps* is running; the snapshot it gives is only true for an instant, and might not be accurate by the time it is displayed.
>
> The **args** format specifier is allowed to produce a truncated version of the command arguments. In some implementations, this information is no longer available when the *ps* utility is executed.
>
> If the field width is too narrow to display a textual ID, the system may use a numeric version. Normally, the system would be expected to choose large enough field widths, but if a large number of fields were selected to write, it might squeeze fields to their minimum sizes to fit on one line. One way to ensure adequate width for the textual IDs is to override the default header for a field to make it larger than most or all user or group names.
>
> Portable applications should not set *COLUMNS* to a value greater than {LINE_MAX} and should not specify the **-w** option more than once if the output will be used as input for a utility that requires a text file as input because lines containing more than {LINE_MAX} bytes may cause undefined behavior in some implementations of the utility.
>
> There is no special quoting mechanism for header text. The header text is the rest of the argument. If multiple header changes are needed, multiple **-o** options can be used, such as:
>
>
>     ps -o "user=User Name" -o pid=Process\ ID
>
> On some implementations, especially multi-level secure systems, *ps* may be severely restricted and produce information only about child processes owned by the user.

#### <span id="tag_20_98_17"></span>EXAMPLES

> The command:
>
>
>     ps -o user,pid,ppid=MOM -o args
>
> writes at least the following in the POSIX locale:
>
>
>       USER   PID   MOM   COMMAND
>     helene    34    12   ps -o user,pid,ppid=MOM -o args
>
> The contents of the **COMMAND** field need not be the same in all implementations, due to possible truncation.

#### <span id="tag_20_98_18"></span>RATIONALE

> There is very little commonality between BSD and System V implementations of *ps*. Many options conflict or have subtly different usages. The standard developers attempted to select a set of options for the base standard that were useful on a wide range of systems and selected options that either can be implemented on both BSD and System V-based systems without breaking the current implementations or where the options are sufficiently similar that any changes would not be unduly problematic for users or implementors.
>
> It is recognized that on some implementations, especially multi-level secure systems, *ps* may be nearly useless. The default output has therefore been chosen such that it does not break historical implementations and also is likely to provide at least some useful information on most systems.
>
> The major change is the addition of the format specification capability. The motivation for this invention is to provide a mechanism for users to access a wider range of system information, if the system permits it, in a portable manner. The fields chosen to appear in this volume of POSIX.1-2024 were arrived at after considering what concepts were likely to be both reasonably useful to the "average" user and had a reasonable chance of being implemented on a wide range of systems. Again it is recognized that not all systems are able to provide all the information and, conversely, some may wish to provide more. It is hoped that the approach adopted will be sufficiently flexible and extensible to accommodate most systems. Implementations may be expected to introduce new format specifiers.
>
> The default output should consist of a short listing containing the process ID, terminal name, cumulative execution time, and command name of each process.
>
> The preference of the standard developers would have been to make the format specification an operand of the *ps* command. Unfortunately, BSD usage precluded this.
>
> At one time a format was included to display the environment array of the process. This was deleted because there is no portable way to display it.
>
> The **-A** option is equivalent to the BSD **-g** and the SVID **-e**. Because the two systems differed, a mnemonic compromise was selected.
>
> The **-a** option is described with some optional behavior because the SVID omits session leaders, but BSD does not.
>
> In an early proposal, format specifiers appeared for priority and start time. The former was not defined adequately in this volume of POSIX.1-2024 and was removed in deference to the defined nice value; the latter because elapsed time was considered to be more useful.
>
> In a new BSD version of *ps*, a **-O** option can be used to write all of the default information, followed by additional format specifiers. This was not adopted because the default output is implementation-defined. Nevertheless, this is a useful option that should be reserved for that purpose. In the **-o** option for the POSIX Shell and Utilities *ps*, the format is the concatenation of each **-o**. Therefore, the user can have an alias or function that defines the beginning of their desired format and add more fields to the end of the output in certain cases where that would be useful.
>
> The format of the terminal name is unspecified, but the descriptions of *ps*, [*talk*](../utilities/talk.html), [*who*](../utilities/who.html), and [*write*](../utilities/write.html) require that they all use the same format.
>
> The **pcpu** field indicates that the CPU time available is determined in an unspecified manner. This is because it is difficult to express an algorithm that is useful across all possible machine architectures. Historical counterparts to this value have attempted to show percentage of use in the recent past, such as the preceding minute. Frequently, these values for all processes did not add up to 100%. Implementations are encouraged to provide data in this field to users that will help them identify processes currently affecting the performance of the system.

#### <span id="tag_20_98_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_98_20"></span>SEE ALSO

> [*kill*](../utilities/kill.html#tag_20_64), [*nice*](../utilities/nice.html#tag_20_86), [*renice*](../utilities/renice.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_98_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_98_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> The *TZ* entry is added to the ENVIRONMENT VARIABLES section.

#### <span id="tag_20_98_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> SD5-XCU-ERN-148 is applied, updating the OPTIONS section.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0160 \[584\] is applied.

#### <span id="tag_20_98_24"></span>Issue 8

> Austin Group Defect 905 is applied, adding the **-w** option.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1141 is applied, changing the description of **SZ** in the STDOUT section.
>
> Austin Group Defect 1175 is applied, changing "uid" to "user" in the EXAMPLES section.

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
