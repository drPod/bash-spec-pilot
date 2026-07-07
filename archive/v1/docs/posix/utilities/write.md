The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="write"></span> <span id="tag_20_151"></span>

#### <span id="tag_20_151_01"></span>NAME

> write — write to another user

#### <span id="tag_20_151_02"></span>SYNOPSIS

> `write`` `*`user_name`*` `**`[`***`terminal`***`]`**

#### <span id="tag_20_151_03"></span>DESCRIPTION

> The *write* utility shall read lines from the standard input and write them to the terminal of the specified user. When first invoked, it shall write the message:
>
>
>     Message from sender-login-id (sending-terminal) [date]...
>
> to *user_name*. When it has successfully completed the connection, the sender's terminal shall be alerted twice to indicate that what the sender is typing is being written to the recipient's terminal.
>
> If the recipient wants to reply, this can be accomplished by typing:
>
>
>     write sender-login-id [sending-terminal]
>
> upon receipt of the initial message. Whenever a line of input as delimited by an NL, EOF, or EOL special character (see XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11)) is accumulated while in canonical input mode, the accumulated data shall be written on the other user's terminal. Characters shall be processed as follows:
>
> - Typing \<alert\> shall write the \<alert\> character to the recipient's terminal.
>
> - Typing the erase and kill characters shall affect the sender's terminal in the manner described by the **termios** interface in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> - Typing the interrupt or end-of-file characters shall cause *write* to write an appropriate message (`"EOT\n"` in the POSIX locale) to the recipient's terminal and exit.
>
> - Typing characters from *LC_CTYPE* classifications **print** or **space** shall cause those characters to be sent to the recipient's terminal.
>
> - When and only when the [*stty*](../utilities/stty.html) **iexten** local mode is enabled, the existence and processing of additional special control characters and multi-byte or single-byte functions is implementation-defined.
>
> - Typing other non-printable characters shall cause implementation-defined sequences of printable characters to be written to the recipient's terminal.
>
> To write to a user who is logged in more than once, the *terminal* argument can be used to indicate which terminal to write to; otherwise, the recipient's terminal is selected in an implementation-defined manner and an informational message is written to the sender's standard output, indicating which terminal was chosen.
>
> Permission to be a recipient of a *write* message can be denied or granted by use of the [*mesg*](../utilities/mesg.html) utility. However, a user's privilege may further constrain the domain of accessibility of other users' terminals. The *write* utility shall fail when the user lacks appropriate privileges to perform the requested action.

#### <span id="tag_20_151_04"></span>OPTIONS

> None.

#### <span id="tag_20_151_05"></span>OPERANDS

> \
> The following operands shall be supported:
>
> *user_name*
>
> Login name of the person to whom the message shall be written. The application shall ensure that this operand is of the form returned by the [*who*](../utilities/who.html) utility.
>
> *terminal*
>
> Terminal identification in the same format provided by the [*who*](../utilities/who.html) utility.

#### <span id="tag_20_151_06"></span>STDIN

> Lines to be copied to the recipient's terminal are read from standard input.

#### <span id="tag_20_151_07"></span>INPUT FILES

> None.

#### <span id="tag_20_151_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *write*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files). If the recipient's locale does not use an *LC_CTYPE* equivalent to the sender's, the results are undefined.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_151_09"></span>ASYNCHRONOUS EVENTS

> If an interrupt signal is received, *write* shall write an appropriate message on the recipient's terminal and exit with a status of zero. It shall take the standard action for all other signals.

#### <span id="tag_20_151_10"></span>STDOUT

> An informational message shall be written to standard output if a recipient is logged in more than once.

#### <span id="tag_20_151_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_151_12"></span>OUTPUT FILES

> The recipient's terminal is used for output.

#### <span id="tag_20_151_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_151_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> The addressed user is not logged on or the addressed user denies permission.

#### <span id="tag_20_151_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_151_16"></span>APPLICATION USAGE

> The [*talk*](../utilities/talk.html) utility is considered by some users to be a more usable utility on full-screen terminals.

#### <span id="tag_20_151_17"></span>EXAMPLES

> None.

#### <span id="tag_20_151_18"></span>RATIONALE

> The *write* utility was included in this volume of POSIX.1-2024 since it can be implemented on all terminal types. The standard developers considered the [*talk*](../utilities/talk.html) utility, which cannot be implemented on certain terminals, to be a "better" communications interface. Both of these programs are in widespread use on historical implementations. Therefore, the standard developers decided that both utilities should be specified.
>
> The format of the terminal name is unspecified, but the descriptions of [*ps*](../utilities/ps.html), [*talk*](../utilities/talk.html), [*who*](../utilities/who.html), and *write* require that they all use or accept the same format.

#### <span id="tag_20_151_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_151_20"></span>SEE ALSO

> [*mesg*](../utilities/mesg.html#), [*talk*](../utilities/talk.html#), [*who*](../utilities/who.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11)

#### <span id="tag_20_151_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_151_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_151_23"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.

#### <span id="tag_20_151_24"></span>Issue 7

> The *write* utility is moved from the User Portability Utilities option to the Base. User Portability Utilities is now an option for interactive utilities.

#### <span id="tag_20_151_25"></span>Issue 8

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
