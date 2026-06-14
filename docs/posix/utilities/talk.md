The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="talk"></span> <span id="tag_20_119"></span>

#### <span id="tag_20_119_01"></span>NAME

> talk — talk to another user

#### <span id="tag_20_119_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`UP`](javascript:open_code('UP'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` talk`` `*`address`*` `**`[`***`terminal`***`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_119_03"></span>DESCRIPTION

> The *talk* utility is a two-way, screen-oriented communication program.
>
> When first invoked, *talk* shall send a message similar to:
>
>
>     Message from <unspecified string>
>     talk: connection requested by your_address
>     talk: respond with: talk your_address
>
> to the specified *address*. At this point, the recipient of the message can reply by typing:
>
>
>     talk your_address
>
> Once communication is established, the two parties can type simultaneously, with their output displayed in separate regions of the screen. Characters shall be processed as follows:
>
> - Typing the \<alert\> character shall alert the recipient's terminal.
>
> - Typing \<control\>-L shall cause the sender's screen regions to be refreshed.
>
> - Typing the erase and kill characters shall affect the sender's terminal in the manner described by the **termios** interface in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> - Typing the interrupt or end-of-file characters shall terminate the local *talk* utility. Once the *talk* session has been terminated on one side, the other side of the *talk* session shall be notified that the *talk* session has been terminated and shall be able to do nothing except exit.
>
> - Typing characters from *LC_CTYPE* classifications **print** or **space** shall cause those characters to be sent to the recipient's terminal.
>
> - When and only when the [*stty*](../utilities/stty.html) **iexten** local mode is enabled, the existence and processing of additional special control characters and multi-byte or single-byte functions shall be implementation-defined.
>
> - Typing other non-printable characters shall cause implementation-defined sequences of printable characters to be sent to the recipient's terminal.
>
> Permission to be a recipient of a *talk* message can be denied or granted by use of the [*mesg*](../utilities/mesg.html) utility. However, a user's privilege may further constrain the domain of accessibility of other users' terminals. The *talk* utility shall fail when the user lacks appropriate privileges to perform the requested action.
>
> Certain block-mode terminals do not have all the capabilities necessary to support the simultaneous exchange of messages required for *talk*. When this type of exchange cannot be supported on such terminals, the implementation may support an exchange with reduced levels of simultaneous interaction or it may report an error describing the terminal-related deficiency.

#### <span id="tag_20_119_04"></span>OPTIONS

> None.

#### <span id="tag_20_119_05"></span>OPERANDS

> The following operands shall be supported:
>
> *address*
>
> The recipient of the *talk* session. One form of *address* is the \<*user name*\>, as returned by the [*who*](../utilities/who.html) utility. Other address formats and how they are handled are unspecified.
>
> *terminal*
>
> If the recipient is logged in more than once, the *terminal* argument can be used to indicate the appropriate terminal name. If *terminal* is not specified, the *talk* message shall be displayed on one or more accessible terminals in use by the recipient. The format of *terminal* shall be the same as that returned by the [*who*](../utilities/who.html) utility.

#### <span id="tag_20_119_06"></span>STDIN

> Characters read from standard input shall be copied to the recipient's terminal in an unspecified manner. If standard input is not a terminal, talk shall write a diagnostic message and exit with a non-zero status.

#### <span id="tag_20_119_07"></span>INPUT FILES

> None.

#### <span id="tag_20_119_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *talk*:
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
>
> *TERM*
>
> Determine the name of the invoker's terminal type. If this variable is unset or null, an unspecified default terminal type shall be used.

#### <span id="tag_20_119_09"></span>ASYNCHRONOUS EVENTS

> When the *talk* utility receives a SIGINT signal, the utility shall terminate and exit with a zero status. It shall take the standard action for all other signals.

#### <span id="tag_20_119_10"></span>STDOUT

> If standard output is a terminal, characters copied from the recipient's standard input may be written to standard output. Standard output also may be used for diagnostic messages. If standard output is not a terminal, *talk* shall exit with a non-zero status.

#### <span id="tag_20_119_11"></span>STDERR

> None.

#### <span id="tag_20_119_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_119_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_119_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred or *talk* was invoked on a terminal incapable of supporting it.

#### <span id="tag_20_119_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_119_16"></span>APPLICATION USAGE

> Because the handling of non-printable, non-\<space\> characters is tied to the [*stty*](../utilities/stty.html) description of **iexten**, implementation extensions within the terminal driver can be accessed. For example, some implementations provide line editing functions with certain control character sequences.

#### <span id="tag_20_119_17"></span>EXAMPLES

> None.

#### <span id="tag_20_119_18"></span>RATIONALE

> The [*write*](../utilities/write.html) utility was included in this volume of POSIX.1-2024 since it can be implemented on all terminal types. The *talk* utility, which cannot be implemented on certain terminals, was considered to be a "better" communications interface. Both of these programs are in widespread use on historical implementations. Therefore, both utilities have been specified.
>
> All references to networking abilities (*talk*ing to a user on another system) were removed as being outside the scope of this volume of POSIX.1-2024.
>
> Historical BSD and System V versions of *talk* terminate both of the conversations when either user breaks out of the session. This can lead to adverse consequences if a user unwittingly continues to enter text that is interpreted by the shell when the other terminates the session. Therefore, the version of *talk* specified by this volume of POSIX.1-2024 requires both users to terminate their end of the session explicitly.
>
> Only messages sent to the terminal of the invoking user can be internationalized in any way:
>
> - The original "Message from \<*unspecified string*\> ..." message sent to the terminal of the recipient cannot be internationalized because the environment of the recipient is as yet inaccessible to the *talk* utility. The environment of the invoking party is irrelevant.
>
> - Subsequent communication between the two parties cannot be internationalized because the two parties may specify different languages in their environment (and non-portable characters cannot be mapped from one language to another).
>
> - Neither party can be required to communicate in a language other than C and/or the one specified by their environment because unavailable terminal hardware support (for example, fonts) may be required.
>
> The text in the STDOUT section reflects the usage of the verb "display" in this section; some *talk* implementations actually use standard output to write to the terminal, but this volume of POSIX.1-2024 does not require that to be the case.
>
> The format of the terminal name is unspecified, but the descriptions of [*ps*](../utilities/ps.html), *talk*, [*who*](../utilities/who.html), and [*write*](../utilities/write.html) require that they all use or accept the same format.
>
> The handling of non-printable characters is partially implementation-defined because the details of mapping them to printable sequences is not needed by the user. Historical implementations, for security reasons, disallow the transmission of non-printable characters that may send commands to the other terminal.

#### <span id="tag_20_119_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_119_20"></span>SEE ALSO

> [*mesg*](../utilities/mesg.html#), [*stty*](../utilities/stty.html#), [*who*](../utilities/who.html#), [*write*](../utilities/write.html#tag_20_151)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11)

#### <span id="tag_20_119_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_119_22"></span>Issue 6

> This utility is marked as part of the User Portability Utilities option.

#### <span id="tag_20_119_23"></span>Issue 8

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
