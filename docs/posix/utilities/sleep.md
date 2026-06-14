The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="sleep"></span> <span id="tag_20_111"></span>

#### <span id="tag_20_111_01"></span>NAME

> sleep — suspend execution for an interval

#### <span id="tag_20_111_02"></span>SYNOPSIS

> `sleep`` `*`time`*

#### <span id="tag_20_111_03"></span>DESCRIPTION

> The *sleep* utility shall suspend execution for at least the integral number of seconds specified by the *time* operand.

#### <span id="tag_20_111_04"></span>OPTIONS

> None.

#### <span id="tag_20_111_05"></span>OPERANDS

> The following operand shall be supported:
>
> *time*
>
> A non-negative decimal integer specifying the number of seconds for which to suspend execution.

#### <span id="tag_20_111_06"></span>STDIN

> Not used.

#### <span id="tag_20_111_07"></span>INPUT FILES

> None.

#### <span id="tag_20_111_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *sleep*:
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

#### <span id="tag_20_111_09"></span>ASYNCHRONOUS EVENTS

> If the *sleep* utility receives a SIGALRM signal, one of the following actions shall be taken:
>
> 1.  Terminate normally with a zero exit status.
>
> 2.  Effectively ignore the signal.
>
> 3.  Provide the default behavior for signals described in the ASYNCHRONOUS EVENTS section of [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04). This could include terminating with a non-zero exit status.
>
> The *sleep* utility shall take the standard action for all other signals.

#### <span id="tag_20_111_10"></span>STDOUT

> Not used.

#### <span id="tag_20_111_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_111_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_111_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_111_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The execution was successfully suspended for at least *time* seconds, or a SIGALRM signal was received. See the ASYNCHRONOUS EVENTS section.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_111_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_111_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_111_17"></span>EXAMPLES

> The *sleep* utility can be used to execute a command after a certain amount of time, as in:
>
>
>     (sleep 105; command) &
>
> or to execute a command every so often, as in:
>
>
>     while true
>     do
>         command
>         sleep 37
>     done

#### <span id="tag_20_111_18"></span>RATIONALE

> The exit status is allowed to be zero when *sleep* is interrupted by the SIGALRM signal because most implementations of this utility rely on the arrival of that signal to notify them that the requested finishing time has been successfully attained. Such implementations thus do not distinguish this situation from the successful completion case. Other implementations are allowed to catch the signal and go back to sleep until the requested time expires or to provide the normal signal termination procedures.
>
> As with all other utilities that take integral operands and do not specify subranges of allowed values, *sleep* is required by this volume of POSIX.1-2024 to deal with *time* requests of up to 2147483647 seconds. This may mean that some implementations have to make multiple calls to the delay mechanism of the underlying operating system if its argument range is less than this.

#### <span id="tag_20_111_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_111_20"></span>SEE ALSO

> [*wait*](../utilities/wait.html#tag_20_147)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)
>
> XSH [*alarm*()](../functions/alarm.html#), [*sleep*()](../functions/sleep.html#tag_17_562)

#### <span id="tag_20_111_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_111_22"></span>Issue 8

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
