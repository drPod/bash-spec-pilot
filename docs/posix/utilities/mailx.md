The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="mailx"></span> <span id="tag_20_75"></span>

#### <span id="tag_20_75_01"></span>NAME

> mailx — process messages

#### <span id="tag_20_75_02"></span>SYNOPSIS

> ##### <span id="tag_20_75_02_01"></span>Send Mode
>
> `mailx`` `**`[`**`-E`**`] [`**`-s`` `*`subject`***`]`**` `*`address`*`...`
>
> ##### <span id="tag_20_75_02_02"></span>Receive Mode
>
>
>     [UP]
>     mailx -e
>     mailx [-HiNn] [-F] [-u user]
>     mailx -f [-HiNn] [-F] [file]

#### <span id="tag_20_75_03"></span>DESCRIPTION

> The *mailx* utility provides a message sending and receiving facility. It has two major modes, selected by the options used: Send Mode and Receive Mode.
>
> On systems that do not support the User Portability Utilities option, an application using *mailx* shall have the ability to send messages in an unspecified manner (Send Mode). Unless the first character of one or more lines is \<tilde\> (`'~'`), all characters in the input message shall appear in the delivered message, but additional characters may be inserted in the message before it is retrieved.
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> On systems supporting the User Portability Utilities option, mail-receiving capabilities and other interactive features, Receive Mode, described below, also shall be enabled. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> ##### <span id="tag_20_75_03_01"></span>Send Mode
>
> Send Mode can be used by applications or users to send messages from the text in standard input. The message shall be passed to the mail delivery software. The mail delivery software shall process passed messages according to the rules of IETF RFC 5322.
>
> ##### <span id="tag_20_75_03_02"></span>Receive Mode
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />
>
> Receive Mode is more oriented towards interactive users. Mail can be read and sent in this interactive mode.
>
> When reading mail, *mailx* provides commands to facilitate saving, deleting, and responding to messages. When sending mail, *mailx* allows editing, reviewing, and other modification of the message as it is entered.
>
> Incoming mail shall be stored in one or more unspecified locations for each user, collectively called the system *mailbox* for that user. When *mailx* is invoked in Receive Mode, the system mailbox shall be the default place to find new mail. As messages are read, they shall be marked to be moved to a secondary file for storage, unless specific action is taken. This secondary file is called the **mbox** and is normally located in the directory referred to by the *HOME* environment variable (see *MBOX* in the ENVIRONMENT VARIABLES section for a description of this file). Messages shall remain in this file until explicitly removed. When the **-f** option is used to read mail messages from secondary files, messages shall be retained in those files unless specifically removed. All three of these locations—system mailbox, **mbox**, and secondary file—are referred to in this section as simply "mailboxes", unless more specific identification is required. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_75_04"></span>OPTIONS

> The *mailx* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported. (Only the **-E** and **-s** *subject* options are required on all systems. The other options are required only on systems supporting the User Portability Utilities option.)
>
> **-E**
>
> Discard messages with an empty message body.
>
> **-e**
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Test for the presence of mail in the system mailbox. The *mailx* utility shall write nothing and exit with a successful return code if there is mail to read. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-f**
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Read messages from the file named by the *file* operand instead of the system mailbox. (See also **folder**.) If no *file* operand is specified, read messages from **mbox** instead of the system mailbox. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-F**
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Record the message in a file named after the first recipient. The name is the login-name portion of the address found first in the **To** field in the message header. Overrides the **record** variable, if set (see [Internal Variables in mailx](#tag_20_75_13_02)). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-H**
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Write a header summary only. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-i**
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Ignore interrupts. (See also **ignore**.) <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-n**
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Do not initialize from the system default start-up file. See the EXTENDED DESCRIPTION section. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-N**
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Do not write an initial header summary. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **-s ***subject*
>
> Set the **Subject** header field to *subject*. All characters in the *subject* string shall appear in the delivered message. The results are unspecified if *subject* is longer than {LINE_MAX} - 10 bytes or contains a \<newline\>.
>
> **-u ***user*
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Read the system mailbox of the login name *user*. This shall only be successful if the invoking user has appropriate privileges to read the system mailbox of that user. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_75_05"></span>OPERANDS

> The following operands shall be supported:
>
> *address*
>
> Addressee of message. When **-n** is specified and no user start-up files are accessed (see the EXTENDED DESCRIPTION section), the user or application shall ensure this is an address to pass to the mail delivery system. Any system or user start-up files may enable aliases (see **alias** under [Commands in mailx](#tag_20_75_13_03)) that may modify the form of *address* before it is passed to the mail delivery system.
>
> *file*
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> A pathname of a file to be read instead of the system mailbox when **-f** is specified. The meaning of the *file* operand shall be affected by the contents of the **folder** internal variable; see [Internal Variables in mailx](#tag_20_75_13_02). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_75_06"></span>STDIN

> When *mailx* is invoked in Send Mode (the first synopsis line), standard input shall be the message to be delivered to the specified addresses. <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  When in Receive Mode, user commands shall be accepted from *stdin*. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  If the User Portability Utilities option is not supported, standard input lines beginning with a \<tilde\> (`'~'`) character produce unspecified results.
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If the User Portability Utilities option is supported, then in both Send and Receive Modes, standard input lines beginning with the escape character (usually \<tilde\> (`'~'`)) shall affect processing as described in [Command Escapes in mailx](#tag_20_75_13_48). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_75_07"></span>INPUT FILES

> When *mailx* is used as described by this volume of POSIX.1-2024, the *file* operand (see the **-f** option) and the **mbox** shall be text files containing mail messages, formatted as described in the OUTPUT FILES section. The nature of the system mailbox is unspecified; it need not be a file.

#### <span id="tag_20_75_08"></span>ENVIRONMENT VARIABLES

> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Some of the functionality described in this section shall be provided on implementations that support the User Portability Utilities option as described in the text, and is not further shaded for this option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The following environment variables shall affect the execution of *mailx*:
>
> *DEAD*
>
> Determine the pathname of the file in which to save partial messages in case of interrupts or delivery errors. The default shall be **dead.letter** in the directory named by the *HOME* variable. The behavior of *mailx* in saving partial messages is unspecified if the User Portability Utilities option is not supported and *DEAD* is not defined with the value **/dev/null**.
>
> *EDITOR*
>
> Determine the name of a utility to invoke when the **edit** (see [Commands in mailx](#tag_20_75_13_03)) or **~e** (see [Command Escapes in mailx](#tag_20_75_13_48)) command is used. The default editor is unspecified. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  On XSI-conformant systems it is [*ed*](../utilities/ed.html). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> The effects of this variable are unspecified if the User Portability Utilities option is not supported.
>
> *HOME*
>
> Determine the pathname of the user's home directory.
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and the handling of case-insensitive address and header field name comparisons.
>
> *LC_TIME*
>
> This variable may determine the format and contents of the date and time strings written by *mailx*. This volume of POSIX.1-2024 specifies the effects of this variable only for systems supporting the User Portability Utilities option.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error and informative messages written to standard output.
>
> *LISTER*
>
> Determine a string representing the command for writing the contents of the **folder** directory to standard output when the **folders** command is given (see **folders** in [Commands in mailx](#tag_20_75_13_03)). Any string acceptable as a *command_string* operand to the [*sh*](../utilities/sh.html) **-c** command shall be valid. If this variable is null or not set, the output command shall be [*ls*](../utilities/ls.html). The effects of this variable are unspecified if the User Portability Utilities option is not supported.
>
> *MAILRC*
>
> Determine the pathname of the user start-up file. The default shall be **.mailrc** in the directory referred to by the *HOME* environment variable. The behavior of *mailx* is unspecified if the User Portability Utilities option is not supported and *MAILRC* is not defined with the value **/dev/null**.
>
> *MBOX*
>
> Determine a pathname of the file to save messages from the system mailbox that have been read. The **exit** command shall override this function, as shall saving the message explicitly in another file. The default shall be **mbox** in the directory named by the *HOME* variable. The effects of this variable are unspecified if the User Portability Utilities option is not supported.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *PAGER*
>
> Determine a string representing an output filtering or pagination command for writing the output to the terminal. Any string acceptable as a *command_string* operand to the [*sh*](../utilities/sh.html) **-c** command shall be valid. When standard output is a terminal device, the message output shall be piped through the command if the *mailx* internal variable **crt** is set to a value less than the total number of lines in the message; see [Internal Variables in mailx](#tag_20_75_13_02). When standard output is not a terminal device, it is unspecified whether the message output is written directly to standard output or is subject to pagination. If the *PAGER* variable is null or not set, the paginator shall be either [*more*](../utilities/more.html) or another paginator utility documented in the system documentation. The effects of this variable are unspecified if the User Portability Utilities option is not supported.
>
> *SHELL*
>
> Determine the name of a preferred command interpreter. The default shall be [*sh*](../utilities/sh.html). The effects of this variable are unspecified if the User Portability Utilities option is not supported.
>
> *TERM*
>
> If the internal variable **screen** is not specified, determine the name of the terminal type to indicate in an unspecified manner the number of lines in a screenful of header summaries. If *TERM* is not set or is set to null, an unspecified default terminal type shall be used and the value of a screenful is unspecified. The effects of this variable are unspecified if the User Portability Utilities option is not supported.
>
> *TZ*
>
> This variable may determine the timezone used to calculate date and time strings written by *mailx*. If *TZ* is unset or null, an unspecified default timezone shall be used.
>
> *VISUAL*
>
> Determine a pathname of a utility to invoke when the **visual** command (see [Commands in mailx](#tag_20_75_13_03)) or **~v** command-escape (see [Command Escapes in mailx](#tag_20_75_13_48)) is used. If this variable is null or not set, the full-screen editor shall be [*vi*](../utilities/vi.html). The effects of this variable are unspecified if the User Portability Utilities option is not supported.

#### <span id="tag_20_75_09"></span>ASYNCHRONOUS EVENTS

> When *mailx* is in Send Mode and standard input is not a terminal, it shall take the standard action for all signals.
>
> In <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  Receive Mode, or in <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  Send Mode when standard input is a terminal, if a SIGINT signal is received:
>
> 1.  <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If in command mode, the current command, if there is one, shall be aborted, and a command-mode prompt shall be written. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> 2.  If in input mode:
>
>     1.  <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If **ignore** is set, *mailx* shall write `"@\n"`, discard the current input line, and continue processing, bypassing the message-abort mechanism described in item 2b. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
>     2.  If the interrupt was received while sending mail, either when in <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Receive Mode or in <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  Send Mode, a message shall be written, and another subsequent interrupt, with no other intervening characters typed, shall be required to abort the mail message. <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  If in Receive Mode and another interrupt is received, a command-mode prompt shall be written. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  If in Send Mode and another interrupt is received, *mailx* shall terminate with a non-zero status.
>
>         In both cases listed in item b, if the message is not empty:
>
>         1.  <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If **save** is enabled and the file named by *DEAD* can be created, the message shall be written to the file named by *DEAD .* If the file exists, the message shall be written to replace the contents of the file. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
>         2.  If <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> **save** is not enabled, or <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  the file named by *DEAD* cannot be created, the message shall not be saved.
>
> The *mailx* utility shall take the standard action for all other signals.

#### <span id="tag_20_75_10"></span>STDOUT

> In command and input modes, all output, including prompts and messages, shall be written to standard output.

#### <span id="tag_20_75_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_75_12"></span>OUTPUT FILES

> Various *mailx* commands and command escapes can create or add to files, including the **mbox**, the dead-letter file, and secondary mailboxes. When *mailx* is used as described in this volume of POSIX.1-2024, these files shall be text files, formatted as follows:
>
> > `line beginning with` **From\<space\>\
> > \[**`one or more` *header fields*; see [Commands in mailx](#tag_20_75_13_03) \]\
> > *empty line\*
> > **\[**`zero or more` *body lines\
> > empty line\]\*
> > **\[**`line beginning with` **From\<space\>...\]**
>
> where each message begins with the **From \<space\>** line shown, preceded by the beginning of the file or an empty line. (The **From \<space\>** line is considered to be part of the message header, but not one of the header fields referred to in [Commands in mailx](#tag_20_75_13_03); thus, it shall not be affected by the **discard**, **ignore**, or **retain** commands.) The formats of the remainder of the **From \<space\>** line and any additional header lines are unspecified, except that none shall be empty. The format of a message body line is also unspecified, except that no line following an empty line shall start with **From \<space\>**; *mailx* shall modify any such user-entered message body lines (following an empty line and beginning with **From \<space\>**) by adding one or more characters to precede the `'F'`; it may add these characters to **From \<space\>** lines that are not preceded by an empty line.
>
> When a message from the system mailbox or entered by the user is not a text file, it is implementation-defined how such a message is stored in files written by *mailx*.

#### <span id="tag_20_75_13"></span>EXTENDED DESCRIPTION

> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The functionality in the entire EXTENDED DESCRIPTION section shall be provided on implementations supporting the User Portability Utilities option. The functionality described in this section shall be provided on implementations that support the User Portability Utilities option (and the rest of this section is not further shaded for this option). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The *mailx* utility need not support for all character encodings in all circumstances. For example, inter-system mail may be restricted to 7-bit data by the underlying network, 8-bit data need not be portable to non-internationalized systems, and so on. Under these circumstances, it is recommended that only characters defined in the ISO/IEC 646:1991 standard International Reference Version (equivalent to ASCII) 7-bit range of characters be used.
>
> When *mailx* is invoked using one of the Receive Mode synopsis forms, it shall write a page of header-summary lines (if **-N** was not specified and there are messages, see below), followed by a prompt indicating that *mailx* can accept regular commands (see [Commands in mailx](#tag_20_75_13_03)); this is termed *command mode*. The page of header-summary lines shall contain the first new message if there are new messages, or the first unread message if there are unread messages, or the first message. When *mailx* is invoked using the Send Mode synopsis and standard input is a terminal, if no subject is specified on the command line and the **asksub** variable is set, a prompt for the subject shall be written. At this point, *mailx* shall be in input mode. This input mode shall also be entered when using one of the Receive Mode synopsis forms and a reply or new message is composed using the **reply**, **Reply**, **followup**, **Followup**, or **mail** commands and standard input is a terminal. When the message is typed and the end of the message is encountered, the message shall be passed to the mail delivery software. Commands can be entered by beginning a line with the escape character (by default, \<tilde\> (`'~'`)) followed by a single command letter and optional arguments. See [Commands in mailx](#tag_20_75_13_03) for a summary of these commands. It is unspecified what effect these commands will have if standard input is not a terminal when a message is entered using either the Send Mode synopsis, or the Read Mode commands **reply**, **Reply**, **followup**, **Followup**, or **mail**.
>
> **Note:**  
> For notational convenience, this section uses the default escape character, \<tilde\>, in all references and examples.
>
> At any time, the behavior of *mailx* shall be governed by a set of environmental and internal variables. These are flags and valued parameters that can be set and cleared via the *mailx* **set** and **unset** commands.
>
> Regular commands are of the form:
>
>
>     [command] [msglist] [argument ...]
>
> If no *command* is specified in command mode, **next** shall be assumed. In input mode, commands shall be recognized by the escape character, and lines not treated as commands shall be taken as input for the message.
>
> In command mode, each message shall be assigned a sequential number, starting with 1.
>
> All messages have a state that shall affect how they are displayed in the header summary and how they are retained or deleted upon termination of *mailx*. There is at any time the notion of a *current* message, which shall be marked by a `'>'` at the beginning of a line in the header summary. When *mailx* is invoked using one of the Receive Mode synopsis forms, the current message shall be the first new message, if there is a new message, or the first unread message if there is an unread message, or the first message if there are any messages, or unspecified if there are no messages in the mailbox. Each command that takes an optional list of messages (*msglist*) or an optional single message (*message*) on which to operate shall leave the current message set to the highest-numbered message of the messages specified, unless the command deletes messages, in which case the current message shall be set to the first undeleted message (that is, a message not in the deleted state) after the highest-numbered message deleted by the command, if one exists, or the first undeleted message before the highest-numbered message deleted by the command, if one exists, or to an unspecified value if there are no remaining undeleted messages. All messages shall be in one of the following states:
>
> *new*
>
> The message is present in the system mailbox and has not been viewed by the user or moved to any other state. Messages in state *new* when *mailx* quits shall be retained in the system mailbox.
>
> *unread*
>
> The message has been present in the system mailbox for more than one invocation of *mailx* and has not been viewed by the user or moved to any other state. Messages in state *unread* when *mailx* quits shall be retained in the system mailbox.
>
> *read*
>
> The message has been processed by one of the following commands: **~f**, **~m**, **~F**, **~M**, **copy**, **mbox**, **next**, **pipe**, **print**, **Print**, **top**, **type**, **Type**, **undelete**. The **dp** and **dt** commands shall also cause the message they write, if any, to be marked as *read*. If the **autoprint** variable is set, the **delete** command shall also cause the message it writes, if any, to be marked as *read*. Messages that are in the system mailbox and in state *read* when *mailx* quits shall be saved in the **mbox**, unless the internal variable **hold** was set. Messages that are in the **mbox** or in a secondary mailbox and in state *read* when *mailx* quits shall be retained in their current location.
>
> *deleted*
>
> The message has been processed by one of the following commands: **delete**, **dp**, **dt**. Messages in state *deleted* when *mailx* quits shall be deleted. Deleted messages shall be ignored until *mailx* quits or changes mailboxes or they are specified to the undelete command; for example, the message specification /*string* shall only search the **Subject** header fields of messages that have not yet been deleted, unless the command operating on the list of messages is **undelete**. No deleted message or deleted message header shall be displayed by any *mailx* command other than **undelete**.
>
> *preserved*
>
> The message has been processed by a **preserve** command. When *mailx* quits, the message shall be retained in its current location.
>
> *saved*
>
> The message has been processed by one of the following commands: **save** or **write**. If the current mailbox is the system mailbox, and the internal variable **keepsave** is set, messages in the state saved shall be saved to the file designated by the *MBOX* variable (see the ENVIRONMENT VARIABLES section). If the current mailbox is the system mailbox, messages in the state *saved* shall be deleted from the current mailbox, when the **quit** or **file** command is used to exit the current mailbox.
>
> The header-summary line for each message shall indicate the state of the message.
>
> Many commands take an optional list of messages (*msglist*) on which to operate, which defaults to the current message. A *msglist* is a list of message specifications separated by \<blank\> characters, which can include:
>
> `n`
>
> Message number *n*.
>
> `+`
>
> The next undeleted message, or the next deleted message for the **undelete** command.
>
> `-`
>
> The next previous undeleted message, or the next previous deleted message for the **undelete** command.
>
> `.`
>
> The current message.
>
> `^`
>
> The first undeleted message, or the first deleted message for the **undelete** command.
>
> `$`
>
> The last message.
>
> `*`
>
> All messages.
>
> `n-m`
>
> An inclusive range of message numbers.
>
> *address*
>
> All messages from *address*; any address as shown in a header summary shall be matchable in this form.
>
> /*string*
>
> All messages with *string* in the **Subject** header field (case ignored).
>
> `:c`
>
> All messages of type *c*, where *c* shall be one of:
>
> `d`
>
> Deleted messages.
>
> `n`
>
> New messages.
>
> `o`
>
> Old messages (any not in state *read* or *new*).
>
> `r`
>
> Read messages.
>
> `u`
>
> Unread messages.
>
> Other commands take an optional message (*message*) on which to operate, which defaults to the current message. All of the forms allowed for *msglist* are also allowed for *message*, but if more than one message is specified, only the first shall be operated on.
>
> Other arguments are usually arbitrary strings whose usage depends on the command involved.
>
> ##### <span id="tag_20_75_13_01"></span>Start-Up in mailx
>
> At start-up time, *mailx* shall take the following steps in sequence:
>
> 1.  Establish all variables at their stated default values.
>
> 2.  Process command line options, overriding corresponding default values.
>
> 3.  Import any of the *DEAD ,* *EDITOR ,* *MBOX ,* *LISTER ,* *PAGER ,* *SHELL ,* or *VISUAL* variables that are present in the environment, overriding the corresponding default values.
>
> 4.  Read *mailx* commands from an unspecified system start-up file, unless the **-n** option is given, to initialize any internal *mailx* variables and aliases.
>
> 5.  Process the user start-up file of *mailx* commands named in the user *MAILRC* variable.
>
> Most regular *mailx* commands are valid inside start-up files, the most common use being to set up initial display options and alias lists. The following commands shall be invalid in a start-up file: **!**, **edit**, **hold**, **mail**, **preserve**, **reply**, **Reply**, **Save**, **shell**, **visual**, **Copy**, **followup**, and **Followup**. Any errors in a start-up file shall either cause *mailx* to terminate with a diagnostic message and a non-zero status or to continue after writing a diagnostic message, ignoring the remainder of the lines in the file.
>
> A blank line in a start-up file shall be ignored.
>
> ##### <span id="tag_20_75_13_02"></span>Internal Variables in mailx
>
> The following variables are internal *mailx* variables. Each internal variable can be set via the *mailx* **set** command at any time. The **unset** and **set no***name* commands can be used to erase variables.
>
> In the following list, variables shown as:
>
>
>     variable
>
> represent Boolean values. Variables shown as:
>
>
>     variable=value
>
> shall be assigned string or numeric values. For string values, the rules in [Commands in mailx](#tag_20_75_13_03) concerning filenames and quoting shall also apply.
>
> The defaults specified here may be changed by the unspecified system start-up file unless the user specifies the **-n** option.
>
> **allnet**
>
> All network names whose login name components match shall be treated as identical. This shall cause the *msglist* message specifications to behave similarly. The default shall be **noallnet**. See also the **alternates** command and the **metoo** variable.
>
> **append**
>
> Append messages to the end of the **mbox** file upon termination instead of placing them at the beginning. The default shall be **noappend**. This variable shall not affect the **save** command when saving to **mbox**.
>
> **ask**, **asksub**
>
> Prompt for a value for the **Subject** header field on outgoing mail if one is not specified on the command line with the **-s** option. The **ask** and **asksub** forms are synonyms; the system shall refer to **asksub** and **noasksub** in its messages, but shall accept **ask** and **noask** as user input to mean **asksub** and **noasksub**. It shall not be possible to set both **ask** and **noasksub**, or **noask** and **asksub**. The default shall be **asksub**, but no prompting shall be done if standard input is not a terminal.
>
> **askbcc**
>
> Prompt for the blind copy list. The default shall be **noaskbcc**.
>
> **askcc**
>
> Prompt for the copy list. The default shall be **noaskcc**.
>
> **autoprint**
>
> Enable automatic writing of messages after **delete** and **undelete** commands. The default shall be **noautoprint**.
>
> **bang**
>
> Enable the special-case treatment of \<exclamation-mark\> characters (`'!'`) in **!** commands and **~!***command* escapes; see the **Invoke Shell Command** command and [Command Escapes in mailx](#tag_20_75_13_48). The default shall be **nobang**, disabling the expansion of `'!'` in the *command* argument to the **!** command and the **~!***command* escape.
>
> **cmd**=*command*
>
> \
> Set the default command to be invoked by the **pipe** command. The default shall be **nocmd**.
>
> **crt**=*number*
>
> Paginate message output as described for the *PAGER* variable. The default shall be **nocrt**, disabling this pagination. If it is set to null, the value used is implementation-defined.
>
> **debug**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Enable verbose diagnostics for debugging. Messages are not delivered. The default shall be **nodebug**. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **dot**
>
> When **dot** is set, a \<period\> on a line by itself during message input from a terminal shall also signify end-of-file (in addition to normal end-of-file). The default shall be **nodot**. If **ignoreeof** is set (see below), a setting of **nodot** shall be ignored and \<period\> and the **~.** command escape are the only methods to terminate input mode.
>
> **escape**=*c*
>
> Set the command escape character to be the character `'c'`. By default, the command escape character shall be \<tilde\>. If **escape** is unset, \<tilde\> shall be used; if it is set to null, command escaping shall be disabled.
>
> **flipr**
>
> Reverse the meanings of the **R** and **r** commands. The default shall be **noflipr**.
>
> **folder**=*directory*
>
> \
> The default directory for saving mail files. User-specified filenames beginning with a \<plus-sign\> (`'+'`) shall be expanded by preceding the filename with this directory name to obtain the real pathname. If *directory* does not start with a \<slash\> (`'/'`), the contents of *HOME* shall be prefixed to it. The default shall be **nofolder**. If **folder** is unset, user-specified filenames beginning with `'+'` shall refer to files in the current directory that begin with the literal `'+'` character. See also **outfolder** below. The **folder** value need not affect the processing of the files named in *MBOX* and *DEAD .*
>
> **header**
>
> Enable writing of the header summary when entering *mailx* in Receive Mode. The default shall be **header**.
>
> **hold**
>
> Disable message moving of read messages from the system mailbox to the **mbox** save file upon normal program termination or folder change. This automatic mail management is complemented with the commands **hold** (and **preserve**), **mbox**, and **touch**, which partially override the **hold** variable. The default shall be **nohold**.
>
> **ignore**
>
> Ignore interrupts while entering messages. The default shall be **noignore**.
>
> **ignoreeof**
>
> Ignore normal end-of-file during message input. Input can be terminated only by entering a \<period\> (`'.'`) on a line by itself or by the **~.** command escape. The default shall be **noignoreeof**. See also **dot** above.
>
> **indentprefix**=*string*
>
> \
> A string that shall be added as a prefix to each line that is inserted into the message by the **~m** command escape. This variable shall default to one \<tab\>.
>
> **keep**
>
> When a system mailbox, secondary mailbox, or **mbox** is empty, truncate it to zero length instead of removing it. The default shall be **nokeep**.
>
> **keepsave**
>
> Keep the messages that have been saved from the system mailbox into other files in the file designated by the variable *MBOX ,* instead of deleting them. The default shall be **nokeepsave**.
>
> **metoo**
>
> Suppress the deletion of the user's login name from the recipient list when replying to a message or sending to a group. The default shall be **nometoo**.
>
> **onehop**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> When responding to a message that was originally sent to several recipients, the other recipient addresses are normally forced to be relative to the originating author's machine for the response. This flag disables alteration of the recipients' addresses, improving efficiency in a network where all machines can send directly to all other machines (that is, one hop away). The default shall be **noonehop**. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **outfolder**
>
> Cause the files used to record outgoing messages to be located in the directory specified by the **folder** variable unless the pathname is absolute. The default shall be **nooutfolder**. See the **record** variable.
>
> **page**
>
> Insert a \<form-feed\> after each message sent through the pipe created by the **pipe** command. The default shall be **nopage**.
>
> **prompt**=*string*
>
> \
> Set the command-mode prompt to *string*. If *string* is null or if **noprompt** is set, no prompting shall occur. The default shall be to prompt with the string `"? "`.
>
> **quiet**
>
> Refrain from writing the opening message and version when entering *mailx*. The default shall be **noquiet**.
>
> **record**=*file*
>
> Record all outgoing mail in the file with the pathname *file*. The default shall be **norecord**. See also **outfolder** above.
>
> **save**
>
> Enable saving of messages in the dead-letter file on interrupt or delivery error. See the variable *DEAD* for the location of the dead-letter file. The default shall be **save**.
>
> **screen**=*number*
>
> \
> Set the number of lines in a screenful of headers for the **headers** and **z** commands. If **screen** is not specified, a value based on the terminal type identified by the *TERM* environment variable, the window size, the baud rate, or some combination of these shall be used. The default shall be **noscreen**.
>
> **sendwait**
>
> Wait for the background mailer to finish before returning. The default shall be **nosendwait**.
>
> **showto**
>
> When the sender of the message was the user who is invoking *mailx*, write the information from the **To** field instead of the **From** field in the header summary. The default shall be **noshowto**.
>
> **sign**=*string*
>
> Set the variable inserted into the text of a message when the **~a** command escape is given. The default shall be **nosign**. The character sequences `'\t'` and `'\n'` shall be recognized in the variable as \<tab\> and \<newline\> characters, respectively. (See also **~i** in [Command Escapes in mailx](#tag_20_75_13_48).)
>
> **Sign**=*string*
>
> Set the variable inserted into the text of a message when the **~A** command escape is given. The default shall be **noSign**. The character sequences `'\t'` and `'\n'` shall be recognized in the variable as \<tab\> and \<newline\> characters, respectively.
>
> **toplines**=*number*
>
> \
> Set the number of lines of the message to write with the **top** command. The default shall be 5.
>
> ##### <span id="tag_20_75_13_03"></span>Commands in mailx
>
> The following *mailx* commands shall be provided. In the following list, *header* refers to lines from the message header, as shown in the OUTPUT FILES section. *Header field* refers to a line or set of lines within the header that begins with one or more non-white-space characters immediately followed by a \<colon\> and white space, and continuing up to and including a \<newline\> that immediately precedes either the next line beginning with a non-white-space character or an empty line. *Field name* refers to the portion of a header field prior to the first \<colon\>.
>
> For each of the commands listed below, the command can be entered as the abbreviation (those characters in the Synopsis command word preceding the `'['`), the full command (all characters shown for the command word, omitting the `'['` and `']'`), or any truncation of the full command down to the abbreviation. For example, the **exit** command (shown as **ex\[it\]** in the Synopsis) can be entered as **ex**, **exi**, or **exit**.
>
> The arguments to commands can be quoted, using the following methods:
>
> - An argument can be enclosed between paired double-quotes (`""`) or single-quotes (`''`); any white space, shell word expansion, or \<backslash\> characters within the quotes shall be treated literally as part of the argument. A double-quote shall be treated literally within single-quotes and *vice versa*. These special properties of the \<quotation-mark\> characters shall occur only when they are paired at the beginning and end of the argument.
>
> - A \<backslash\> outside of the enclosing quotes shall be discarded and the following character treated literally as part of the argument.
>
> - An unquoted \<backslash\> at the end of a command line shall be discarded and the next line shall continue the command.
>
> \
>
> Filenames, where expected, shall be subjected to the following transformations, in sequence:
>
> - If the filename begins with an unquoted \<plus-sign\>, and the **folder** variable is defined (see the **folder** variable), the \<plus-sign\> shall be replaced by the value of the **folder** variable followed by a \<slash\>. If the **folder** variable is unset or is set to null, the filename shall be unchanged.
>
> - Shell word expansions shall be applied to the filename (see [*2.6 Word Expansions*](../utilities/V3_chap02.html#tag_19_06)). If more than a single pathname results from this expansion and the command is expecting one file, the effects are unspecified.
>
> ##### <span id="tag_20_75_13_04"></span>Declare Aliases
>
> *Synopsis*:
>
>
>     a[lias] [alias [address...]]
>     g[roup] [alias [address...]]
>
> Add the given addresses to the alias specified by *alias*. The names shall be substituted when *alias* is used as a recipient address specified by the user in an outgoing message (that is, other recipients addressed indirectly through the **reply** command shall not be substituted in this manner). Mail address alias substitution shall apply only when the alias string is used as a full address; for example, when **hlj** is an alias, *hlj@posix.com* does not trigger the alias substitution. Recursive expansion of an alias group member can be prevented by prefixing it with an unquoted \<backslash\>. If no arguments are given, write a listing of the current aliases to standard output. If only an *alias* argument is given, write a listing of the specified alias to standard output. These listings need not reflect the same order of addresses that were entered.
>
> ##### <span id="tag_20_75_13_05"></span>Declare Alternatives
>
> *Synopsis*:
>
>
>     alt[ernates] name...
>
> Declare a list of alternative addresses for the address consisting of the user's login name. When responding to a message, these alternative addresses shall be removed from the list of recipients. The comparison of addresses shall be performed in a case-insensitive manner. With no arguments, **alternates** shall write the current list of alternative addresses.
>
> ##### <span id="tag_20_75_13_06"></span>Change Current Directory
>
> *Synopsis*:
>
>
>     cd [directory]
>     ch[dir] [directory]
>
> Change directory. If *directory* is not specified, the contents of *HOME* shall be used.
>
> ##### <span id="tag_20_75_13_07"></span>Copy Messages
>
> *Synopsis*:
>
>
>     c[opy] [file]
>     c[opy] [msglist] file
>     C[opy] [msglist]
>
> Copy messages to the file named by the pathname *file* without marking the messages as saved. Otherwise, it shall be equivalent to the **save** command.
>
> In the capitalized form, save the specified messages in a file whose name is derived from the author of the message to be saved, without marking the messages as saved. Otherwise, it shall be equivalent to the **Save** command.
>
> ##### <span id="tag_20_75_13_08"></span>Delete Messages
>
> *Synopsis*:
>
>
>     d[elete] [msglist]
>
> Mark messages for deletion from the mailbox. The deletions shall not occur until *mailx* quits (see the **quit** command) or changes mailboxes (see the **folder** command). If **autoprint** is set and there are messages remaining after the **delete** command, the current message shall be written as described for the **print** command (see the **print** command); otherwise, the *mailx* prompt shall be written.
>
> ##### <span id="tag_20_75_13_09"></span>Discard Header Fields
>
> *Synopsis*:
>
>
>     di[scard] [field-name...]
>     ig[nore] [field-name...]
>
> Suppress header fields with the specified field names when writing messages. Specified *field-name* arguments shall be added to the list of suppressed field names. Examples of field names to ignore are **status** and **cc**. The header fields shall be included when the message is saved. The **Print** and **Type** commands shall override this command. The comparison of field names shall be performed in a case-insensitive manner. If no arguments are specified, write a list of the currently suppressed field names to standard output; the listing need not reflect the same order of field names that were entered.
>
> If both **retain** and **discard** commands are given, **discard** commands shall be ignored.
>
> ##### <span id="tag_20_75_13_10"></span>Delete Messages and Display
>
> *Synopsis*:
>
>
>     dp [msglist]
>     dt [msglist]
>
> Delete the specified messages as described for the **delete** command, except that the **autoprint** variable shall have no effect, and the current message shall be written only if it was set to a message after the last message deleted by the command. Otherwise, an informational message to the effect that there are no further messages in the mailbox shall be written, followed by the *mailx* prompt.
>
> ##### <span id="tag_20_75_13_11"></span>Echo a String
>
> *Synopsis*:
>
>
>     ec[ho] string ...
>
> Echo the given strings, equivalent to the shell [*echo*](../utilities/echo.html) utility.
>
> ##### <span id="tag_20_75_13_12"></span>Edit Messages
>
> *Synopsis*:
>
>
>     e[dit] [msglist]
>
> Edit the given messages. The messages shall be placed in a temporary file and the utility named by the *EDITOR* variable is invoked to edit each file in sequence. The default *EDITOR* is unspecified.
>
> The **edit** command does not modify the contents of those messages in the mailbox.
>
> ##### <span id="tag_20_75_13_13"></span>Exit
>
> *Synopsis*:
>
>
>     ex[it]
>     x[it]
>
> Exit from *mailx* without performing automatic message moving, or any other management tasks. See also **quit**.
>
> ##### <span id="tag_20_75_13_14"></span>Change Folder
>
> *Synopsis*:
>
>
>     fi[le] [file]
>     fold[er] [file]
>
> If no argument is given, write the name and status of the current mailbox. Otherwise, close the current file of messages after performing actions as specified for the **quit** command (except for terminating *mailx*) and then read in the file named by the pathname *file*. The behavior is unspecified if *file* is not a valid **mbox**.
>
> Several unquoted special characters shall be recognized when used as *file* names, with the following substitutions:
>
> `%`
>
> The system mailbox for the invoking user.
>
> `%`*user*
>
> The system mailbox for *user*.
>
> `#`
>
> The previous file.
>
> `&`
>
> The current **mbox**.
>
> `+`*file*
>
> The named file in the **folder** directory. (See the **folder** variable.)
>
> The default file shall be the current mailbox.
>
> ##### <span id="tag_20_75_13_15"></span>Display List of Folders
>
> *Synopsis*:
>
>
>     folders
>
> Write the names of the files in the directory set by the **folder** variable. The command specified by the *LISTER* environment variable shall be used (see the ENVIRONMENT VARIABLES section).
>
> ##### <span id="tag_20_75_13_16"></span>Follow Up Specified Messages
>
> *Synopsis*:
>
>
>     fo[llowup] [message]
>     F[ollowup] [msglist]
>
> The **followup** and **Followup** commands shall be equivalent to **reply** and **Reply**, respectively, except that:
>
> - They shall ignore the **record** variable.
>
> - The **followup** command shall record the response in a file whose name is derived from the author of the *message*.
>
> - The **Followup** command shall record the response in a file whose name is derived from the author of the first message in the *msglist*.
>
> See also the **save** and **copy** commands and **outfolder**.
>
> ##### <span id="tag_20_75_13_17"></span>Display Header Summary for Specified Messages
>
> *Synopsis*:
>
>
>     f[rom] [msglist]
>
> Write the header summary for the specified messages.
>
> ##### <span id="tag_20_75_13_18"></span>Display Header Summaries
>
> *Synopsis*:
>
>
>     h[eaders] [message]
>
> Write the page of header summaries that includes the message specified. If the *message* argument is not specified, the current message shall not change. However, if the *message* argument is specified, the current message shall become the message that appears at the top of the page of header summaries that includes the message specified. The **screen** variable sets the number of header summaries per page. See also the **z** command.
>
> ##### <span id="tag_20_75_13_19"></span>Help
>
> *Synopsis*:
>
>
>     hel[p]
>     ?
>
> Write a summary of commands.
>
> ##### <span id="tag_20_75_13_20"></span>Hold Messages
>
> *Synopsis*:
>
>
>     ho[ld] [msglist]
>     pre[serve] [msglist]
>
> Allowed only in the system mailbox. Mark the messages in *msglist* to be preserved, as if the **hold** variable were set, upon normal termination or when the folder is changed. This shall override any commands that might previously have marked the messages to be deleted, and only the **delete**, **dp**, or **dt**, as well as the **mbox** and **touch** commands, shall remove the *preserve* mark of a message.
>
> ##### <span id="tag_20_75_13_21"></span>Execute Commands Conditionally
>
> *Synopsis*:
>
>
>     i[f] s|r
>     mail-commands
>     el[se]
>     mail-commands
>     en[dif]
>
> Execute commands conditionally, where **if s** executes the following *mail-command*s, up to an **else** or **endif**, if the program is in Send Mode, and **if r** shall cause the *mail-command*s to be executed only in Receive Mode.
>
> ##### <span id="tag_20_75_13_22"></span>List Available Commands
>
> *Synopsis*:
>
>
>     l[ist]
>
> Write a list of all commands available. No explanation shall be given.
>
> ##### <span id="tag_20_75_13_23"></span>Mail a Message
>
> *Synopsis*:
>
>
>     m[ail] address...
>
> Mail a message to the specified addresses or aliases.
>
> ##### <span id="tag_20_75_13_24"></span>Direct Messages to mbox
>
> *Synopsis*:
>
>
>     mb[ox] [msglist]
>
> Allowed only in the system mailbox. Arrange for the given messages to end up in the secondary mailbox, overriding a possibly set **hold** variable, upon normal termination or when the folder is changed. Overrides a former **hold** or **preserve** request. See *MBOX* in the ENVIRONMENT VARIABLES section. See also the **exit** and **quit** commands.
>
> ##### <span id="tag_20_75_13_25"></span>Process Next Specified Message
>
> *Synopsis*:
>
>
>     n[ext] [message]
>
> If the current message has not been written (for example, by the **print** command) since *mailx* started or since any other message was the current message, behave as if the **print** command was entered. Otherwise, if there is an undeleted message after the current message, make it the current message and behave as if the **print** command was entered. Otherwise, an informational message to the effect that there are no further messages in the mailbox shall be written, followed by the *mailx* prompt. Should the current message location be the result of an immediately preceding **hold**, **mbox**, **preserve**, or **touch** command, **next** shall act as if the current message has already been written.
>
> ##### <span id="tag_20_75_13_26"></span>Pipe Message
>
> *Synopsis*:
>
>
>     pi[pe] [[msglist] command]
>     | [[msglist] command]
>
> Pipe the messages through the given *command* by invoking the command interpreter specified by *SHELL* with three arguments: `"-c"`, `"--"`, and *command*. (See also [*sh*](../utilities/sh.html) **-c**.) The application shall ensure that the command is given as a single argument. Quoting, described previously, can be used to accomplish this. If no arguments are given, the current message shall be piped through the command specified by the value of the **cmd** variable. If the **page** variable is set, a \<form-feed\> shall be inserted after each message.
>
> ##### <span id="tag_20_75_13_27"></span>Display Message with Header
>
> *Synopsis*:
>
>
>     P[rint] [msglist]
>     T[ype] [msglist]
>
> Write the specified messages, including all header fields, to standard output. This command shall override suppression of header fields by the **discard**, **ignore**, and **retain** commands. If **crt** is set, the output shall be paginated as described for the *PAGER* variable.
>
> ##### <span id="tag_20_75_13_28"></span>Display Message
>
> *Synopsis*:
>
>
>     p[rint] [msglist]
>     t[ype] [msglist]
>
> Write the specified messages to standard output. If **crt** is set, the output shall be paginated as described for the *PAGER* variable.
>
> ##### <span id="tag_20_75_13_29"></span>Quit
>
> *Synopsis*:
>
>
>     q[uit]
>     end-of-file
>
> Terminate *mailx* normally, performing automatic message moving as specified in the description of the variable **hold**, deleting messages that have been explicitly saved (unless **keepsave** is set), discarding messages that have been deleted, and saving all remaining messages in the mailbox.
>
> ##### <span id="tag_20_75_13_30"></span>Reply to a Message or a Message List
>
> *Synopsis*:
>
>
>     r[eply] [message]
>     r[espond] [message]
>     R[eply] [msglist]
>     R[espond] [msglist]
>
> Mail a reply message to one or more addresses taken from certain header fields in the specified message or message list. If the **flipr** variable is unset, these commands shall behave as described below. If the **flipr** variable is set, commands in the lowercase form shall behave as described below for commands in the capitalized form, and *vice versa*; the synopsis forms shown above shall also be swapped accordingly.
>
> The recipients of the reply message shall be determined by first constructing an initial list of recipients and then modifying it to form the list that is in effect when *mailx* enters input mode.
>
> In the capitalized form, the initial list of recipients shall be taken from the header of each message in the *msglist* as follows:
>
> - If the header contains a **Reply-To** field, the address or addresses in that field shall be added to the list.
>
> - Otherwise, the address or addresses in the **From** field of the header shall be added to the list.
>
> In the lowercase form, the initial list of recipients shall be taken from the header of the *message* as follows:
>
> - If the header does not contain a **Reply-To** field, all of the addresses in the **From**, **To**, and **Cc** fields shall be included in the list.
>
> - Otherwise, it is implementation-defined whether all of the addresses in the **Reply-To**, **To**, and **Cc** fields are included in the list or only the address or addresses in the **Reply-To** field.
>
> The initial list of recipients shall be marked for placement in the header fields of the reply message as follows. Recipient addresses taken from a **From** or **Reply-To** header field shall be marked for placement in the **To** field of the reply message. Recipient addresses taken from a **Cc** header field shall be marked for placement in the **Cc** field of the reply message. Recipient addresses taken from a **To** header field shall be marked for placement in either the **To** or the **Cc** field of the reply message. Implementations shall provide a way to place them in the **To** field. Implementations may, but need not, provide an implementation-defined way to place them in the **Cc** field.
>
> The modifications applied to the initial list of recipients shall be as follows:
>
> - If the **metoo** variable is unset, addresses consisting of the login name of the user and any alternative addresses declared using the **alternates** command shall be removed from the list.
>
> - The set of recipients marked for placement in the **To** header field of the reply message shall have duplicates within that set removed.
>
> - The set of recipients marked for placement in the **Cc** header field of the reply message shall have duplicates within that set removed and may have recipients that are also marked for placement in the **To** field removed.
>
> The values for the **To** and **Cc** header fields of the reply message shall be constructed from the addresses in the modified list of recipients that are marked for placement in each of those fields.
>
> The value for the **Subject** header field of the reply message shall be formed from the value of the **Subject** header field of the *message* or the first message in *msglist* by prefixing it with **Re:**\<space\>, unless it already begins with that string.
>
> The values of the **To**, **Cc**, and **Subject** header fields set as described above can be modified by the user after *mailx* enters input mode through the use of the **~t**, **~c**, **~s**, and **~h** command escapes.
>
> If **record** is set to a pathname, the response shall be saved at the end of that file.
>
> ##### <span id="tag_20_75_13_31"></span>Retain Header Fields
>
> *Synopsis*:
>
>
>     ret[ain] [field-name...]
>
> Retain header fields with the specified field names when writing messages. This command shall override all **discard** and **ignore** commands. The comparison of field names shall be performed in a case-insensitive manner. If no arguments are specified, write a list of the currently retained field names to standard output; the listing need not reflect the same order of field names that were entered.
>
> ##### <span id="tag_20_75_13_32"></span>Save Messages
>
> *Synopsis*:
>
>
>     s[ave] [file]
>     s[ave] [msglist] file
>     S[ave] [msglist]
>
> Save the specified messages in the file named by the pathname *file*, or the **mbox** if the *file* argument is omitted. The file shall be created if it does not exist; otherwise, the messages shall be appended to the file. The message shall be put in the state *saved*, and shall behave as specified in the description of the *saved* state when the current mailbox is exited by the **quit** or **file** command.
>
> In the capitalized form, save the specified messages in a file whose name is derived from the author of the first message. The name of the file shall be taken to be the author's name with all network addressing stripped off. See also the **Copy**, **followup**, and **Followup** commands and **outfolder** variable.
>
> ##### <span id="tag_20_75_13_33"></span>Set Variables
>
> *Synopsis*:
>
>
>     se[t] [name[=[string]] ...] [name=number ...] [noname ...]
>
> Define one or more variables called *name*. The variable can be given a null, string, or numeric value. Quoting and \<backslash\>-escapes can occur anywhere in *string*, as described previously, as if the *string* portion of the argument were the entire argument. The forms *name* and *name*= shall be equivalent to *name*="" for variables that take string values. The **set** command without arguments shall write a list of all defined variables and their values. The **no** *name* form shall be equivalent to **unset** *name*.
>
> ##### <span id="tag_20_75_13_34"></span>Invoke a Shell
>
> *Synopsis*:
>
>
>     sh[ell]
>
> Invoke an interactive command interpreter (see also *SHELL ).*
>
> ##### <span id="tag_20_75_13_35"></span>Display Message Size
>
> *Synopsis*:
>
>
>     si[ze] [msglist]
>
> Write the size in bytes of each of the specified messages.
>
> ##### <span id="tag_20_75_13_36"></span>Read mailx Commands From a File
>
> *Synopsis*:
>
>
>     so[urce] file
>
> Read and execute commands from the file named by the pathname *file* and return to command mode.
>
> ##### <span id="tag_20_75_13_37"></span>Display Beginning of Messages
>
> *Synopsis*:
>
>
>     to[p] [msglist]
>
> Write the top few lines of each of the specified messages. If the **toplines** variable is set, it is taken as the number of lines to write. The default shall be 5.
>
> ##### <span id="tag_20_75_13_38"></span>Touch Messages
>
> *Synopsis*:
>
>
>     tou[ch] [msglist]
>
> Allowed only in the system mailbox. Touch the specified messages. Unless overridden by the **hold** variable, any message in *msglist* that is not specifically deleted nor saved in a file shall be placed in the **mbox** upon normal termination or when the folder is changed. Overrides a former **hold** or **preserve** request.
>
> ##### <span id="tag_20_75_13_39"></span>Delete Aliases
>
> *Synopsis*:
>
>
>     una[lias] [alias]...
>
> Delete the specified alias names. If a specified alias does not exist, the results are unspecified.
>
> ##### <span id="tag_20_75_13_40"></span>Undelete Messages
>
> *Synopsis*:
>
>
>     u[ndelete] [msglist]
>
> Change the state of the specified messages from deleted to read. If **autoprint** is set, the last message of those restored shall be written. If *msglist* is not specified, the message shall be selected as follows:
>
> - If there are any deleted messages that follow the current message, the first of these shall be chosen.
>
> - Otherwise, the last deleted message that also precedes the current message shall be chosen.
>
> ##### <span id="tag_20_75_13_41"></span>Unset Variables
>
> *Synopsis*:
>
>
>     uns[et] name...
>
> Cause the specified variables to be erased.
>
> ##### <span id="tag_20_75_13_42"></span>Edit Message with Full-Screen Editor
>
> *Synopsis*:
>
>
>     v[isual] [msglist]
>
> Edit the given messages with a screen editor. Each message shall be placed in a temporary file, and the utility named by the *VISUAL* variable shall be invoked to edit each file in sequence. The default editor shall be [*vi*](../utilities/vi.html).
>
> The **visual** command does not modify the contents of those messages in the mailbox.
>
> ##### <span id="tag_20_75_13_43"></span>Write Messages to a File
>
> *Synopsis*:
>
>
>     w[rite] [msglist] file
>
> Write the given messages to the file specified by the pathname *file*, minus the message header. Otherwise, it shall be equivalent to the **save** command.
>
> ##### <span id="tag_20_75_13_44"></span>Scroll Header Display
>
> *Synopsis*:
>
>
>     z[+|-]
>
> Scroll the header display forward (if `'+'` is specified or if no option is specified) or backward (if `'-'` is specified) one screenful. The number of header summaries written shall be set by the **screen** variable.
>
> ##### <span id="tag_20_75_13_45"></span>Invoke Shell Command
>
> *Synopsis*:
>
>
>     !command
>
> Invoke the command interpreter specified by *SHELL* with three arguments: `"-c"`, `"--"`, and *command*. (See also [*sh*](../utilities/sh.html) **-c**.) If the **bang** variable is set, each unescaped occurrence of `'!'` in *command* shall be replaced with the command executed by the previous **!** command or **~!** command escape.
>
> ##### <span id="tag_20_75_13_46"></span>Null Command
>
> *Synopsis*:
>
>
>     # comment
>
> This null command (comment) shall be ignored by *mailx*.
>
> ##### <span id="tag_20_75_13_47"></span>Display Current Message Number
>
> *Synopsis*:
>
>
>     =
>
> Write the current message number.
>
> ##### <span id="tag_20_75_13_48"></span>Command Escapes in mailx
>
> The following commands can be entered only from input mode, by beginning a line with the escape character (by default, \<tilde\> (`'~'`)). See the **escape** variable description for changing this special character. The format for the commands shall be:
>
>
>     <escape-character><command-char><separator>[<arguments>]
>
> where the \<*separator*\> can be zero or more \<blank\> characters.
>
> In the following descriptions, the application shall ensure that the argument *command* (but not *mailx-command)* is a shell command string. Any string acceptable to the command interpreter specified by the *SHELL* variable when it is invoked as *SHELL* **-c** *command_string* shall be valid. The command can be presented as multiple arguments (that is, quoting is not required).
>
> Command escapes that are listed with *msglist* or *mailx-command* arguments are invalid in Send Mode and produce unspecified results.
>
> **~! ***command*
>
> Invoke the command interpreter specified by *SHELL* with three arguments: `"-c"`, `"--"`, and *command*; and then return to input mode. If the **bang** variable is set, each unescaped occurrence of `'!'` in *command* shall be replaced with the command executed by the previous **!** command or **~!** command escape.
>
> **~.**
>
> Simulate end-of-file (terminate message input).
>
> **~: ***mailx-command*, **~\_ ***mailx-command*
>
> \
> Perform the command-level request.
>
> **~?**
>
> Write a summary of command escapes.
>
> **~A**
>
> This shall be equivalent to **~i Sign**.
>
> **~a**
>
> This shall be equivalent to **~i sign**.
>
> **~b ***name*...
>
> Add the *name*s to the blind carbon copy (**Bcc**) list.
>
> **~c ***name*...
>
> Add the *name*s to the carbon copy (**Cc**) list.
>
> **~d**
>
> Read in the dead-letter file. See *DEAD* for a description of this file.
>
> **~e**
>
> Invoke the editor, as specified by the *EDITOR* environment variable, on the partial message.
>
> **~f \[***msglist***\]**
>
> Forward the specified messages. The specified messages, including their headers, shall be inserted into the current message without alteration. The header fields included in each header shall be affected by the **discard**, **ignore**, and **retain** commands.
>
> **~F \[***msglist***\]**
>
> This shall be the equivalent of the **~f** command escape, except that all header fields shall be included in the message headers, regardless of previous **discard**, **ignore**, and **retain** commands.
>
> **~h**
>
> If standard input is a terminal, prompt for values for the **Subject**, **To**, **Cc**, and **Bcc** header fields. Other implementation-defined header fields may also be presented for editing. If the header field is written with an initial value, it can be edited as if it had just been typed.
>
> **~i ***string*
>
> Insert the value of the named variable, followed by a \<newline\>, into the text of the message. If the string is unset or null, the message shall not be changed.
>
> **~m \[***msglist***\]**
>
> Insert the specified messages, including their headers, into the current message, prefixing non-empty lines with the string in the **indentprefix** variable. The header fields included in each header shall be affected by the **discard**, **ignore**, and **retain** commands.
>
> **~M \[***msglist***\]**
>
> This shall be the equivalent of the **~m** command escape, except that all header fields shall be included in the message headers, regardless of previous **discard**, **ignore**, and **retain** commands.
>
> **~p**
>
> Write the message being entered. If the message is longer than **crt** lines (see [Internal Variables in mailx](#tag_20_75_13_02)), the output shall be paginated as described for the *PAGER* variable.
>
> **~q**
>
> Quit (see the **quit** command) from input mode by simulating an interrupt. If the body of the message is not empty, the partial message shall be saved in the dead-letter file. See *DEAD* for a description of this file.
>
> **~r ***file*, **~\< ***file*, **~r !***command*, **~\< !***command*
>
> \
> Read in the file specified by the pathname *file*. If the argument begins with an \<exclamation-mark\> (`'!'`), the rest of the string shall be taken as an arbitrary system command; the command interpreter specified by *SHELL* shall be invoked with three arguments: `"-c"`, `"--"`, and *command*. The standard output of *command* shall be inserted into the message.
>
> **~s ***string*
>
> Set the value for the **Subject** header field to *string*.
>
> **~t ***name*...
>
> Add the given *name*s to the **To** list.
>
> **~v**
>
> Invoke the full-screen editor, as specified by the *VISUAL* environment variable, on the partial message.
>
> **~w ***file*
>
> Write the partial message, without the header, onto the file named by the pathname *file*. The file shall be created or the message shall be appended to it if the file exists.
>
> **~x**
>
> Exit as with **~q**, except the message shall not be saved in the dead-letter file.
>
> **~\| ***command*
>
> Pipe the body of the message through the given *command* by invoking the command interpreter specified by *SHELL* with three arguments: `"-c"`, `"--"`, and *command*. If the *command* returns a successful exit status, the standard output of the command shall replace the message. Otherwise, the message shall remain unchanged. If the *command* fails, an error message giving the exit status shall be written.
>
> \

#### <span id="tag_20_75_14"></span>EXIT STATUS

> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> When the **-e** option is specified, the following exit values are returned:
>
>  0
>
> Mail was found.
>
> \>0
>
> Mail was not found or an error occurred.
>
> <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> Otherwise, the following exit values are returned:
>
>  0
>
> Successful completion; note that this status implies that any messages that *mailx* was instructed to send were all successfully either *sent* or discarded (see **-E**), but it gives no assurances that any of them were actually *delivered*.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_75_15"></span>CONSEQUENCES OF ERRORS

> When in <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  input mode (Receive Mode) <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  or Send Mode:
>
> - If an error is encountered processing an input line beginning with a \<tilde\> (`'~'`) character, <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  (see [Command Escapes in mailx](#tag_20_75_13_48)), <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  a diagnostic message shall be written to standard error, and the message being composed may be modified, but this condition shall not prevent the message from being sent.
>
> - Other errors shall prevent the sending of the message.
>
> <sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> When in command mode:
>
> - Default.
>
> <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_75_16"></span>APPLICATION USAGE

> Delivery of messages to remote systems requires the existence of communication paths to such systems. These need not exist.
>
> Input lines are limited to {LINE_MAX} bytes, but mailers between systems may impose more severe line-length restrictions. This volume of POSIX.1-2024 does not place any restrictions on the length of messages handled by *mailx*, and for delivery of local messages the only limitations should be the normal problems of available disk space for the target mail file. When sending messages to external machines, applications are advised to limit messages to less than 100000 bytes because some mail gateways impose message-length restrictions.
>
> The format of the system mailbox is intentionally unspecified. Not all systems implement system mailboxes as flat files, particularly with the advent of multimedia mail messages. Some system mailboxes may be multiple files, others records in a database. The internal format of the messages themselves is specified with the historical format from Version 7, but only after the messages have been saved in some file other than the system mailbox. This was done so that many historical applications expecting text-file mailboxes are not broken.
>
> Some new formats for messages can be expected in the future, probably including binary data, bit maps, and various multimedia objects. As described here, *mailx* is not prohibited from handling such messages, but it must store them as text files in secondary mailboxes (unless some extension, such as a variable or command line option, is used to change the stored format). Its method of doing so is implementation-defined and might include translating the data into text file-compatible or readable form or omitting certain portions of the message from the stored output.
>
> The **discard** and **ignore** commands are not inverses of the **retain** command. The **retain** command discards all header fields except those explicitly retained. The **discard** command keeps all header fields except those explicitly discarded. If field names exist on the retained field names list, **discard** and **ignore** commands are ignored.

#### <span id="tag_20_75_17"></span>EXAMPLES

> None.

#### <span id="tag_20_75_18"></span>RATIONALE

> The standard developers felt strongly that a method for applications to send messages to specific users was necessary. The obvious example is a batch utility, running non-interactively, that wishes to communicate errors or results to a user. However, the actual format, delivery mechanism, and method of reading the message are clearly beyond the scope of this volume of POSIX.1-2024.
>
> The intent of this command is to provide a simple, portable interface for sending messages non-interactively. It merely defines a "front-end" to the historical mail system. It is suggested that implementations explicitly denote the sender and recipient in the body of the delivered message. Further specification of formats for either the message envelope or the message itself were deliberately not made, as the industry is in the midst of changing from the current standards to a more internationalized standard and it is probably incorrect, at this time, to require either one.
>
> Implementations are encouraged to conform to the various delivery mechanisms described in the CCITT X.400 standards or to the equivalent Internet standards, described in Internet Request for Comment (RFC) documents RFC 819, RFC 920, RFC 921, RFC 1123, and RFC 5322.
>
> Many historical systems modified each body line that started with **From ** by prefixing the `'F'` with `'>'`. It is unnecessary, but allowed, to do that when the string does not follow a blank line because it cannot be confused with the next header.
>
> The **edit** and **visual** commands merely edit the specified messages in a temporary file. They do not modify the contents of those messages in the mailbox; such a capability could be added as an extension, such as by using different command names.
>
> The restriction on the value for a **Subject** header field being {LINE_MAX}-10 bytes is based on the historical format that consumes 10 bytes for **Subject: ** and the trailing \<newline\>. Many historical mailers that a message may encounter on other systems are not able to handle lines that long, however.
>
> Like the utilities [*logger*](../utilities/logger.html) and [*lp*](../utilities/lp.html), *mailx* admittedly is difficult to test. This was not deemed sufficient justification to exclude this utility from this volume of POSIX.1-2024. It is also arguable that it is, in fact, testable, but that the tests themselves are not portable.
>
> When *mailx* is being used by an application that wishes to receive the results as if none of the User Portability Utilities option features were supported, the *DEAD* environment variable must be set to **/dev/null**. Otherwise, it may be subject to the file creations described in *mailx* ASYNCHRONOUS EVENTS. Similarly, if the *MAILRC* environment variable is not set to **/dev/null**, historical versions of *mailx* and *Mail* read initialization commands from a file before processing begins. Since the initialization that a user specifies could alter the contents of messages an application is trying to send, such applications must set *MAILRC* to **/dev/null**.
>
> The description of *LC_TIME* uses "may affect" because many historical implementations do not or cannot manipulate the date and time strings in the incoming mail headers. Some header fields found in incoming mail do not have enough information to determine the timezone in which the mail originated, and, therefore, *mailx* cannot convert the date and time strings into the internal form that then is parsed by routines like [*strftime*()](../functions/strftime.html) that can take *LC_TIME* settings into account. Changing all these times to a user-specified format is allowed, but not required.
>
> The paginator selected when *PAGER* is null or unset is partially unspecified to allow the System V historical practice of using *pg* as the default. Bypassing the pagination function, such as by declaring that [*cat*](../utilities/cat.html) is the paginator, would not meet with the intended meaning of this description. However, any "portable user" would have to set *PAGER* explicitly to get his or her preferred paginator on all systems. The paginator choice was made partially unspecified, unlike the *VISUAL* editor choice (mandated to be [*vi*](../utilities/vi.html)) because most historical pagers follow a common theme of user input, whereas editors differ dramatically.
>
> Options to specify addresses as **cc** (carbon copy) or **bcc** (blind carbon copy) were considered to be format details and were omitted.
>
> A zero exit status implies that all messages were *sent*, but it gives no assurances that any of them were actually *delivered*. The reliability of the delivery mechanism is unspecified and is an appropriate marketing distinction between systems.
>
> In order to conform to the Utility Syntax Guidelines, a solution was required to the optional *file* option-argument to **-f**. By making *file* an operand, the guidelines are satisfied and users remain portable. However, it does force implementations to support usage such as:
>
>
>     mailx -fin mymail.box
>
> The **no** *name* method of unsetting variables is not present in all historical systems, but it is in System V and provides a logical set of commands corresponding to the format of the display of options from the *mailx* [*set*](../utilities/V3_chap02.html#set) command without arguments.
>
> The **ask** and **asksub** variables are the names selected by BSD and System V, respectively, for the same feature. They are synonyms in this volume of POSIX.1-2024.
>
> The *mailx* [*echo*](../utilities/echo.html) command was not documented in the BSD version and has been omitted here because it is not obviously useful for interactive users.
>
> The default prompt on the System V *mailx* is a \<question-mark\>, on BSD *Mail* an \<ampersand\>. Since this volume of POSIX.1-2024 chose the *mailx* name, it kept the System V default, assuming that BSD users would not have difficulty with this minor incompatibility (that they can override).
>
> The meanings of **r** and **R** are reversed between System V *mailx* and SunOS *Mail*. Once again, since this volume of POSIX.1-2024 chose the *mailx* name, it kept the System V default, but allows the SunOS user to achieve the desired results using **flipr**, an internal variable in System V *mailx*, although it has not been documented in the SVID.
>
> The **indentprefix** variable, the **retain** and **unalias** commands, and the **~F** and **~M** command escapes were adopted from 4.3 BSD *Mail*.
>
> The **version** command was not included because no sufficiently general specification of the version information could be devised that would still be useful to a portable user. This command name should be used by suppliers who wish to provide version information about the *mailx* command.
>
> The "implementation-specific (unspecified) system start-up file" historically has been named **/etc/mailx.rc**, but this specific name and location are not required.
>
> The intent of the wording for the **next** command is that if any command has already displayed the current message it should display a following message, but, otherwise, it should display the current message. Consider the command sequence:
>
>
>     next 3
>     delete 3
>     next
>
> where the **autoprint** option was not set. The normative text specifies that the second **next** command should display a message following the third message, because even though the current message has not been displayed since it was set by the **delete** command, it has been displayed since the current message was anything other than message number 3. This does not always match historical practice in some implementations, where the command file address followed by **next** (or the default command) would skip the message for which the user had searched.

#### <span id="tag_20_75_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_75_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*ed*](../utilities/ed.html#), [*ls*](../utilities/ls.html#), [*more*](../utilities/more.html#), [*vi*](../utilities/vi.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_75_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_75_22"></span>Issue 5

> The description of the *EDITOR* environment variable is changed to indicate that [*ed*](../utilities/ed.html) is the default editor if this variable is not set. In previous issues, this default was not stated explicitly at this point but was implied further down in the text.
>
> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_75_23"></span>Issue 6

> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - The **-F** option is added.
>
> - The **allnet**, **debug**, and **sendwait** internal variables are added.
>
> - The **C**, **ec**, **fo**, **F**, and **S** *mailx* commands are added.
>
> In the DESCRIPTION and ENVIRONMENT VARIABLES sections, text stating "*HOME* directory" is replaced by "directory referred to by the *HOME* environment variable".
>
> The *mailx* utility is aligned with the IEEE P1003.2b draft standard, which includes various clarifications to resolve IEEE PASC Interpretations submitted for the ISO POSIX-2:1993 standard. In particular, the changes here address IEEE PASC Interpretations 1003.2 \#10, \#11, \#103, \#106, \#108, \#114, \#115, \#122, and \#129.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> The *TZ* entry is added to the ENVIRONMENT VARIABLES section.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/32 is applied, applying a change to the EXTENDED DESCRIPTION, raised by IEEE PASC Interpretation 1003.2 \#122, which was overlooked in the first version of this standard.
>
> IEEE Std 1003.1-2001/Cor 2-2004, item XCU/TC2/D6/17 is applied, updating the EXTENDED DESCRIPTION (Internal Variables in *mailx*). The system start-up file is changed from "implementation-defined" to "unspecified" for consistency with other text in the EXTENDED DESCRIPTION.

#### <span id="tag_20_75_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#089 is applied, clarifying the effect of the *LC_TIME* environment variable.
>
> Austin Group Interpretation 1003.1-2001 \#090 is applied, updating the description of the **next** command.
>
> SD5-XCU-ERN-69 is applied.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> Shading to indicate support for the User Portability Utilities option is added.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0120 \[855\] and XCU/TC2-2008/0121 \[619\] are applied.

#### <span id="tag_20_75_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 956 is applied, clarifying how the *PAGER* environment variable and the **crt** internal variable affect pagination.
>
> Austin Group Defects 990 and 991 are applied, changing the description of the **mbox** command.
>
> Austin Group Defect 999 is applied, adding **Save** to the list of commands that are invalid in a start-up file.
>
> Austin Group Defect 1034 is applied, clarifying that **~.** can be used to terminate input mode when **ignoreeof** is set.
>
> Austin Group Defect 1109 is applied, changing the description of the **bang** internal variable.
>
> Austin Group Defect 1113 is applied, changing the description of the *read* state.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1176 is applied, changing "option-argument" to "operand".
>
> Austin Group Defect 1306 is applied, changing the description of the **folder** internal variable.
>
> Austin Group Defect 1367 is applied, adding the **-E** option.
>
> Austin Group Defect 1401 is applied, changing the requirements for the **reply**, **Reply**, **followup**, and **Followup** commands.
>
> Austin Group Defect 1405 is applied, changing the terminology related to mail messages to match IETF RFC 5322.
>
> Austin Group Defect 1408 is applied, changing the description of Send Mode.
>
> Austin Group Defect 1507 is applied, changing the EXIT STATUS section.
>
> Austin Group Defect 1528 is applied, adding a `"--"` argument to be passed between `"-c"` and *command* when executing shell commands.
>
> Austin Group Defect 1634 is applied, clarifying handling of the system mailbox.
>
> Austin Group Defect 1685 is applied, updating RFC references.
>
> Austin Group Defect 1725 is applied, clarifying that the default for the **screen** internal variable is **noscreen**.
>
> Austin Group Defect 1743 is applied, changing the descriptions of the **metoo** internal variable and the **alternates** command.
>
> Austin Group Defect 1747 is applied, changing the description of the **alias** command.

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
