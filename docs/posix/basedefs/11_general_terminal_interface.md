The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_11"></span>11. General Terminal Interface

This chapter describes a general terminal interface that shall be provided. It shall be supported on any asynchronous communications ports if the implementation provides them. It is implementation-defined whether it supports network connections or synchronous ports, or both.

### <span id="tag_11_01"></span>11.1 Interface Characteristics

#### <span id="tag_11_01_01"></span>11.1.1 Opening a Terminal Device File

When a terminal device file is opened, it normally causes the thread to wait until a connection is established. In practice, application programs seldom open these files; they are opened by special programs and become an application's standard input, output, and error files.

Cases where applications do open a terminal device are as follows:

1.  Opening **/dev/tty**, or the pathname returned by [*ctermid*()](../functions/ctermid.html), in order to obtain a file descriptor for the controlling terminal; see [11.1.3 The Controlling Terminal](#tag_11_01_03).

2.  Opening the subsidiary side of a pseudo-terminal; see XSH [*ptsname*()](../functions/ptsname.html#).

3.  Opening a modem or similar piece of equipment connected by a serial line. In this case, the terminal parameters (see [11.2 Parameters that Can be Set](#tag_11_02)) may be initialized to default settings by the implementation in between the last close of the device by any process and the next open of the device, or they may persist from one use to the next. The terminal parameters can be set to values that ensure the terminal behaves in a conforming manner by means of the O_TTY_INIT open flag when opening a terminal device that is not already open in any process, or by executing the [*stty*](../utilities/stty.html) utility with the operand **sane**.

As described in [*open*()](../functions/open.html), opening a terminal device file with the O_NONBLOCK flag clear shall cause the thread to block until the terminal device is ready and available. If CLOCAL mode is not set, this means blocking until a connection is established. If CLOCAL mode is set in the terminal, or the O_NONBLOCK flag is specified in the [*open*()](../functions/open.html), the [*open*()](../functions/open.html) function shall return a file descriptor without waiting for a connection to be established.

#### <span id="tag_11_01_02"></span>11.1.2 Process Groups

A terminal may have a foreground process group associated with it. This foreground process group plays a special role in handling signal-generating input characters, as discussed in [11.1.9 Special Characters](#tag_11_01_09).

A command interpreter process supporting job control can allocate the terminal to different jobs, or process groups, by placing related processes in a single process group and associating this process group with the terminal. A terminal's foreground process group may be set or examined by a process, assuming the permission requirements are met; see [*tcgetpgrp*()](../functions/tcgetpgrp.html) and [*tcsetpgrp*()](../functions/tcsetpgrp.html). The terminal interface aids in this allocation by restricting access to the terminal by processes that are not in the current process group; see [11.1.4 Terminal Access Control](#tag_11_01_04).

When there is no longer any process whose process ID or process group ID matches the foreground process group ID, the terminal shall have no foreground process group. It is unspecified whether the terminal has a foreground process group when there is a process whose process ID matches the foreground process group ID, but whose process group ID does not. No actions defined in POSIX.1-2024, other than allocation of a controlling terminal or a successful call to [*tcsetpgrp*()](../functions/tcsetpgrp.html), shall cause a process group to become the foreground process group of the terminal.

#### <span id="tag_11_01_03"></span>11.1.3 The Controlling Terminal

A terminal may belong to a process as its controlling terminal. Each process of a session that has a controlling terminal has the same controlling terminal. A terminal may be the controlling terminal for at most one session. The controlling terminal for a session is allocated by the session leader in an implementation-defined manner. If a session leader has no controlling terminal, and opens a terminal device file that is not already associated with a session without using the O_NOCTTY option (see [*open*()](../functions/open.html)), it is implementation-defined whether the terminal becomes the controlling terminal of the session leader. If a process which is not a session leader opens a terminal file, or the O_NOCTTY option is used on [*open*()](../functions/open.html), then that terminal shall not become the controlling terminal of the calling process. When a controlling terminal becomes associated with a session, its foreground process group shall be set to the process group of the session leader.

The controlling terminal is inherited by a child process during a [*fork*()](../functions/fork.html) function call. A process relinquishes its controlling terminal when it creates a new session with the [*setsid*()](../functions/setsid.html) function; other processes remaining in the old session that had this terminal as their controlling terminal continue to have it. Upon the close of the last file descriptor in the system (whether or not it is in the current session) associated with the controlling terminal, it is unspecified whether all processes that had that terminal as their controlling terminal cease to have any controlling terminal. Whether and how a session leader can reacquire a controlling terminal after the controlling terminal has been relinquished in this fashion is unspecified. A process does not relinquish its controlling terminal simply by closing all of its file descriptors associated with the controlling terminal if other processes continue to have it open.

When a controlling process terminates, the controlling terminal is dissociated from the current session, allowing it to be acquired by a new session leader. Subsequent access to the terminal by other processes in the earlier session may be denied, with attempts to access the terminal treated as if a modem disconnect had been sensed.

#### <span id="tag_11_01_04"></span>11.1.4 Terminal Access Control

If a process is in the foreground process group of its controlling terminal, read operations shall be allowed, as described in [11.1.5 Input Processing and Reading Data](#tag_11_01_05). Any attempts by a process in a background process group to read from its controlling terminal cause its process group to be sent a SIGTTIN signal unless one of the following special cases applies: if the reading process is ignoring the SIGTTIN signal or the reading thread is blocking the SIGTTIN signal, or if the process group of the reading process is orphaned, the [*read*()](../functions/read.html) shall return -1, with *errno* set to \[EIO\] and no signal shall be sent. The default action of the SIGTTIN signal shall be to stop the process to which it is sent. See [*\<signal.h\>*](../basedefs/signal.h.html).

If a process is in the foreground process group of its controlling terminal, write operations shall be allowed as described in [11.1.8 Writing Data and Output Processing](#tag_11_01_08). Attempts by a process in a background process group to write to its controlling terminal shall cause the process group to be sent a SIGTTOU signal unless one of the following special cases applies: if TOSTOP is not set, or if TOSTOP is set and the process is ignoring the SIGTTOU signal or the writing thread is blocking the SIGTTOU signal, the process is allowed to write to the terminal and the SIGTTOU signal is not sent. If TOSTOP is set, the process group of the writing process is orphaned, the writing process is not ignoring the SIGTTOU signal, and the writing thread is not blocking the SIGTTOU signal, the [*write*()](../functions/write.html) shall return -1, with *errno* set to \[EIO\] and no signal shall be sent.

Certain calls that set terminal parameters are treated in the same fashion as [*write*()](../functions/write.html), except that TOSTOP is ignored; that is, the effect is identical to that of terminal writes when TOSTOP is set (see [11.2.5 Local Modes](#tag_11_02_05), [*tcdrain*()](../functions/tcdrain.html), [*tcflow*()](../functions/tcflow.html), [*tcflush*()](../functions/tcflush.html), [*tcsendbreak*()](../functions/tcsendbreak.html), [*tcsetattr*()](../functions/tcsetattr.html), [*tcsetpgrp*()](../functions/tcsetpgrp.html), and [*tcsetwinsize*()](../functions/tcsetwinsize.html)).

#### <span id="tag_11_01_05"></span>11.1.5 Input Processing and Reading Data

A terminal device associated with a terminal device file may operate in full-duplex mode, so that data may arrive even while output is occurring. Each terminal device file has an input queue associated with it, into which incoming data is stored by the system before being read by a process. The system may impose a limit, {MAX_INPUT}, on the number of bytes that may be stored in the input queue. The behavior of the system when this limit is exceeded is implementation-defined.

Two general kinds of input processing are available, determined by whether the terminal device file is in canonical mode or non-canonical mode. These modes are described in [11.1.6 Canonical Mode Input Processing](#tag_11_01_06) and [11.1.7 Non-Canonical Mode Input Processing](#tag_11_01_07). Additionally, input characters are processed according to the *c_iflag* (see [11.2.2 Input Modes](#tag_11_02_02)) and *c_lflag* (see [11.2.5 Local Modes](#tag_11_02_05)) fields. Such processing can include "echoing", which in general means transmitting input characters immediately back to the terminal when they are received from the terminal. This is useful for terminals that can operate in full-duplex mode.

The manner in which data is provided to a process reading from a terminal device file is dependent on whether the terminal file is in canonical or non-canonical mode, and on whether or not the O_NONBLOCK flag is set by [*open*()](../functions/open.html) or [*fcntl*()](../functions/fcntl.html).

If the O_NONBLOCK flag is clear, then the read request shall be blocked until data is available or a signal has been received. If the O_NONBLOCK flag is set, then the read request shall be completed, without blocking, in one of three ways:

1.  If there is enough data available to satisfy the entire request, the [*read*()](../functions/read.html) shall complete successfully and shall return the number of bytes read.

2.  If there is not enough data available to satisfy the entire request, the [*read*()](../functions/read.html) shall complete successfully, having read as much data as possible, and shall return the number of bytes it was able to read.

3.  If there is no data available, the [*read*()](../functions/read.html) shall return -1, with *errno* set to \[EAGAIN\].

When data is available depends on whether the input processing mode is canonical or non-canonical. [11.1.6 Canonical Mode Input Processing](#tag_11_01_06) and [11.1.7 Non-Canonical Mode Input Processing](#tag_11_01_07) describe each of these input processing modes.

#### <span id="tag_11_01_06"></span>11.1.6 Canonical Mode Input Processing

In canonical mode input processing, terminal input is processed in units of lines. A line is delimited by a \<newline\> character (NL), an end-of-file character (EOF), or an end-of-line (EOL) character. See [11.1.9 Special Characters](#tag_11_01_09) for more information on EOF and EOL. This means that a read request shall not return until an entire line has been typed or a signal has been received. Also, no matter how many bytes are requested in the [*read*()](../functions/read.html) call, at most one line shall be returned. It is not, however, necessary to read a whole line at once; any number of bytes, even one, may be requested in a [*read*()](../functions/read.html) without losing information.

If {MAX_CANON} is defined for this terminal device, it shall be a limit on the number of bytes in a line. The behavior of the system when this limit is exceeded is implementation-defined. If {MAX_CANON} is not defined, there shall be no such limit; see [*pathconf*()](../functions/pathconf.html).

Erase and kill processing occur when either of two special characters, the ERASE and KILL characters (see [11.1.9 Special Characters](#tag_11_01_09)), is received. This processing shall affect data in the input queue that has not yet been delimited by an NL, EOF, or EOL character. This un-delimited data makes up the current line. The ERASE character shall delete the last character in the current line, if there is one. The KILL character shall delete all data in the current line, if there is any. The ERASE and KILL characters shall have no effect if there is no data in the current line. The ERASE and KILL characters themselves shall not be placed in the input queue.

#### <span id="tag_11_01_07"></span>11.1.7 Non-Canonical Mode Input Processing

In non-canonical mode input processing, input bytes are not assembled into lines, and erase and kill processing shall not occur. The values of the MIN and TIME members of the *c_cc* array are used to determine how to process the bytes received. POSIX.1-2024 does not specify whether the setting of O_NONBLOCK takes precedence over MIN or TIME settings. Therefore, if O_NONBLOCK is set, [*read*()](../functions/read.html) may return immediately, regardless of the setting of MIN or TIME. Also, if no data is available, [*read*()](../functions/read.html) may either return 0, or return -1 with *errno* set to \[EAGAIN\].

MIN represents the minimum number of bytes that should be received when the [*read*()](../functions/read.html) function returns successfully. TIME is a timer of 0.1 second granularity that is used to time out bursty and short-term data transmissions. If MIN is greater than {MAX_INPUT}, the response to the request is undefined. The four possible values for MIN and TIME and their interactions are described below.

##### <span id="tag_11_01_07_01"></span>Case A: MIN\>0, TIME\>0

In case A, TIME serves as an inter-byte timer which shall be activated after the first byte is received. Since it is an inter-byte timer, it shall be reset after a byte is received. The interaction between MIN and TIME is as follows. As soon as one byte is received, the inter-byte timer shall be started. If MIN bytes are received before the inter-byte timer expires (remember that the timer is reset upon receipt of each byte), the read shall be satisfied. If the timer expires before MIN bytes are received, the characters received to that point shall be returned to the user. Note that if TIME expires at least one byte shall be returned because the timer would not have been enabled unless a byte was received. In this case (MIN\>0, TIME\>0) the read shall block until the MIN and TIME mechanisms are activated by the receipt of the first byte, or a signal is received. If data is in the buffer at the time of the [*read*()](../functions/read.html), the result shall be as if data has been received immediately after the [*read*()](../functions/read.html).

##### <span id="tag_11_01_07_02"></span>Case B: MIN\>0, TIME=0

In case B, since the value of TIME is zero, the timer plays no role and only MIN is significant. A pending read shall not be satisfied until MIN bytes are received (that is, the pending read shall block until MIN bytes are received), or a signal is received. A program that uses case B to read record-based terminal I/O may block indefinitely in the read operation.

##### <span id="tag_11_01_07_03"></span>Case C: MIN=0, TIME\>0

In case C, since MIN=0, TIME no longer represents an inter-byte timer. It now serves as a read timer that shall be activated as soon as the [*read*()](../functions/read.html) function is processed. A read shall be satisfied as soon as a single byte is received or the read timer expires. Note that in case C if the timer expires, no bytes shall be returned. If the timer does not expire, the only way the read can be satisfied is if a byte is received. If bytes are not received, the read shall not block indefinitely waiting for a byte; if no byte is received within TIME\*0.1 seconds after the read is initiated, the [*read*()](../functions/read.html) shall return a value of zero, having read no data. If data is in the buffer at the time of the [*read*()](../functions/read.html), the timer shall be started as if data has been received immediately after the [*read*()](../functions/read.html).

##### <span id="tag_11_01_07_04"></span>Case D: MIN=0, TIME=0

The minimum of either the number of bytes requested or the number of bytes currently available shall be returned without waiting for more bytes to be input. If no characters are available, [*read*()](../functions/read.html) shall return a value of zero, having read no data.

#### <span id="tag_11_01_08"></span>11.1.8 Writing Data and Output Processing

When a process writes one or more bytes to a terminal device file, they are processed according to the *c_oflag* field (see [11.2.3 Output Modes](#tag_11_02_03)). The implementation may provide a buffering mechanism; as such, when a call to [*write*()](../functions/write.html) completes, all of the bytes written have been scheduled for transmission to the device, but the transmission has not necessarily completed. See [*write*()](../functions/write.html) for the effects of O_NONBLOCK on [*write*()](../functions/write.html).

#### <span id="tag_11_01_09"></span>11.1.9 Special Characters

Certain characters have special functions on input or output or both. These functions are summarized as follows:

INTR

Special character on input, which is recognized if the ISIG flag is set. Generates a SIGINT signal which is sent to all processes in the foreground process group for which the terminal is the controlling terminal. If ISIG is set, the INTR character shall be discarded when processed.

QUIT

Special character on input, which is recognized if the ISIG flag is set. Generates a SIGQUIT signal which is sent to all processes in the foreground process group for which the terminal is the controlling terminal. If ISIG is set, the QUIT character shall be discarded when processed.

ERASE

Special character on input, which is recognized if the ICANON flag is set. Erases the last character in the current line; see [11.1.6 Canonical Mode Input Processing](#tag_11_01_06). It shall not erase beyond the start of a line, as delimited by an NL, EOF, or EOL character. If ICANON is set, the ERASE character shall be discarded when processed.

KILL

Special character on input, which is recognized if the ICANON flag is set. Deletes the entire line, as delimited by an NL, EOF, or EOL character. If ICANON is set, the KILL character shall be discarded when processed.

EOF

Special character on input, which is recognized if the ICANON flag is set. When received, all the bytes waiting to be read are immediately passed to the process without waiting for a \<newline\>, and the EOF is discarded. Thus, if there are no bytes waiting (that is, the EOF occurred at the beginning of a line), a byte count of zero shall be returned from the [*read*()](../functions/read.html), representing an end-of-file indication. If ICANON is set, the EOF character shall be discarded when processed.

NL

Special character on input, which is recognized if the ICANON flag is set. It is the line delimiter \<newline\>. It cannot be changed.

EOL

Special character on input, which is recognized if the ICANON flag is set. It is an additional line delimiter, like NL.

SUSP

If the ISIG flag is set, receipt of the SUSP character shall cause a SIGTSTP signal to be sent to all processes in the foreground process group for which the terminal is the controlling terminal, and the SUSP character shall be discarded when processed.

STOP

Special character on both input and output, which is recognized if the IXON (output control) or IXOFF (input control) flag is set. Can be used to suspend output temporarily. It is useful with CRT terminals to prevent output from disappearing before it can be read. If IXON is set, the STOP character shall be discarded when processed.

START

Special character on both input and output, which is recognized if the IXON (output control) or IXOFF (input control) flag is set. Can be used to resume output that has been suspended by a STOP character. If IXON is set, the START character shall be discarded when processed.

CR

Special character on input, which is recognized if the ICANON flag is set; it is the \<carriage-return\> character. When ICANON and ICRNL are set and IGNCR is not set, this character shall be translated into an NL, and shall have the same effect as an NL character. It cannot be changed.

The NL and CR characters cannot be changed. It is implementation-defined whether the START and STOP characters can be changed. The values for INTR, QUIT, ERASE, KILL, EOF, EOL, and SUSP shall be changeable to suit individual tastes. Special character functions associated with changeable special control characters can be disabled individually.

If two or more special characters have the same value, the function performed when that character is received is undefined.

A special character is recognized not only by its value, but also by its context; for example, an implementation may support multi-byte sequences that have a meaning different from the meaning of the bytes when considered individually. Implementations may also support additional single-byte functions. These implementation-defined multi-byte or single-byte functions shall be recognized only if the IEXTEN flag is set; otherwise, data is received without interpretation, except as required to recognize the special characters defined in this section.

<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If IEXTEN is set, the ERASE, KILL, and EOF characters can be escaped by a preceding \<backslash\> character, in which case no special function shall occur. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_11_01_10"></span>11.1.10 Modem Disconnect

If a modem disconnect is detected by the terminal interface for a controlling terminal, and if CLOCAL is not set in the *c_cflag* field for the terminal (see [11.2.4 Control Modes](#tag_11_02_04)), the SIGHUP signal shall be sent to the controlling process for which the terminal is the controlling terminal. Unless other arrangements have been made, this shall cause the controlling process to terminate (see [*exit*()](../functions/exit.html)). Any subsequent read from the terminal device shall return the value of zero, indicating end-of-file; see [*read*()](../functions/read.html). Thus, processes that read a terminal file and test for end-of-file can terminate appropriately after a disconnect. If the EIO condition as specified in [*read*()](../functions/read.html) also exists, it is unspecified whether on EOF condition or \[EIO\] is returned. Any subsequent [*write*()](../functions/write.html) to the terminal device shall return -1, with *errno* set to \[EIO\], until the device is closed.

#### <span id="tag_11_01_11"></span>11.1.11 Closing a Terminal Device File

The last process to close a terminal device file shall cause any output to be sent to the device and shall cause any input to be discarded. If HUPCL is set in the control modes and the communications port supports a disconnect function, the terminal device shall perform a disconnect.

### <span id="tag_11_02"></span>11.2 Parameters that Can be Set

#### <span id="tag_11_02_01"></span>11.2.1 The termios Structure

Routines that need to control certain terminal I/O characteristics shall do so by using the **termios** structure as defined in the [*\<termios.h\>*](../basedefs/termios.h.html) header.

Since the **termios** structure may include additional members, and the standard members may include both standard and non-standard modes, the structure should never be initialized directly by the application as this may cause the terminal to behave in a non-conforming manner. When opening a terminal device (other than a pseudo-terminal) that is not already open in any process, it should be opened with the O_TTY_INIT flag before initializing the structure using [*tcgetattr*()](../functions/tcgetattr.html) to ensure that any non-standard elements of the **termios** structure are set to values that result in conforming behavior of the terminal interface.

The members of the **termios** structure include (but are not limited to):

| **Member Type** | **Array Size** | **Member Name** | **Description**     |
|:----------------|:---------------|:----------------|:--------------------|
| **tcflag_t**    |                | *c_iflag*       | Input modes.        |
| **tcflag_t**    |                | *c_oflag*       | Output modes.       |
| **tcflag_t**    |                | *c_cflag*       | Control modes.      |
| **tcflag_t**    |                | *c_lflag*       | Local modes.        |
| **cc_t**        | NCCS           | *c_cc\[\]*      | Control characters. |

The **tcflag_t** and **cc_t** types are defined in the [*\<termios.h\>*](../basedefs/termios.h.html) header. They shall be unsigned integer types.

#### <span id="tag_11_02_02"></span>11.2.2 Input Modes

Values of the *c_iflag* field describe the basic terminal input control, and are composed of the bitwise-inclusive OR of the masks shown, which shall be bitwise-distinct. The mask name symbols in this table are defined in [*\<termios.h\>*](../basedefs/termios.h.html):

| **Mask Name** | **Description**                         |
|:--------------|:----------------------------------------|
| BRKINT        | Signal interrupt on break.              |
| ICRNL         | Map CR to NL on input.                  |
| IGNBRK        | Ignore break condition.                 |
| IGNCR         | Ignore CR.                              |
| IGNPAR        | Ignore characters with parity errors.   |
| INLCR         | Map NL to CR on input.                  |
| INPCK         | Enable input parity check.              |
| ISTRIP        | Strip character.                        |
| IXANY         | Enable any character to restart output. |
| IXOFF         | Enable start/stop input control.        |
| IXON          | Enable start/stop output control.       |
| PARMRK        | Mark parity errors.                     |

In the context of asynchronous serial data transmission, a break condition shall be defined as a sequence of zero-valued bits that continues for more than the time to send one byte. The entire sequence of zero-valued bits is interpreted as a single break condition, even if it continues for a time equivalent to more than one byte. In contexts other than asynchronous serial data transmission, the definition of a break condition is implementation-defined.

If IGNBRK is set, a break condition detected on input shall be ignored; that is, not put on the input queue and therefore not read by any process. If IGNBRK is not set and BRKINT is set, the break condition shall flush the input and output queues, and if the terminal is the controlling terminal of a foreground process group, the break condition shall generate a single SIGINT signal to that foreground process group. If neither IGNBRK nor BRKINT is set, a break condition shall be read as a single 0x00, or if PARMRK is set, as 0xff 0x00 0x00.

If IGNPAR is set, a byte with a framing or parity error (other than break) shall be ignored.

If PARMRK is set, and IGNPAR is not set, a byte with a framing or parity error (other than break) shall be given to the application as the three-byte sequence 0xff 0x00 X, where 0xff 0x00 is a two-byte flag preceding each sequence and X is the data of the byte received in error. To avoid ambiguity in this case, if ISTRIP is not set, a valid byte of 0xff is given to the application as 0xff 0xff. If neither PARMRK nor IGNPAR is set, a framing or parity error (other than break) shall be given to the application as a single byte 0x00.

If INPCK is set, input parity checking shall be enabled. If INPCK is not set, input parity checking shall be disabled, allowing output parity generation without input parity errors. Note that whether input parity checking is enabled or disabled is independent of whether parity detection is enabled or disabled (see [11.2.4 Control Modes](#tag_11_02_04)). If parity detection is enabled but input parity checking is disabled, the hardware to which the terminal is connected shall recognize the parity bit, but the terminal special file shall not check whether or not this bit is correctly set.

If ISTRIP is set, valid input bytes shall first be stripped to seven bits; otherwise, all eight bits shall be processed.

If INLCR is set, a received NL character shall be translated into a CR character. If IGNCR is set, a received CR character shall be ignored (not read). If IGNCR is not set and ICRNL is set, a received CR character shall be translated into an NL character.

If IXANY is set, any input character shall restart output that has been suspended.

If IXON is set, start/stop output control shall be enabled. A received STOP character shall suspend output and a received START character shall restart output. When IXON is set, START and STOP characters are not read, but merely perform flow control functions. When IXON is not set, the START and STOP characters shall be read.

If IXOFF is set, start/stop input control shall be enabled. The system shall transmit STOP characters, which are intended to cause the terminal device to stop transmitting data, as needed to prevent the input queue from overflowing and causing implementation-defined behavior, and shall transmit START characters, which are intended to cause the terminal device to resume transmitting data, as soon as the device can continue transmitting data without risk of overflowing the input queue. The precise conditions under which STOP and START characters are transmitted are implementation-defined.

The initial input control value after [*open*()](../functions/open.html) is implementation-defined.

#### <span id="tag_11_02_03"></span>11.2.3 Output Modes

The *c_oflag* field specifies the terminal interface's treatment of output, and is composed of the bitwise-inclusive OR of the masks shown, which shall be bitwise-distinct. The mask name symbols in the following table are defined in [*\<termios.h\>*](../basedefs/termios.h.html):

| **Mask Name** | **Description** |
|:---|:---|
| OPOST | Perform output processing. |
| <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> ONLCR | Map NL to CR-NL on output. |
| OCRNL | Map CR to NL on output. |
| ONOCR | No CR output at column 0. |
| ONLRET | NL performs CR function. |
| OFILL | Use fill characters for delay. |
| OFDEL | Fill is DEL, else NUL. |
| NLDLY | Select newline delays: |
|     NL0 | Newline character type 0. |
|     NL1 | Newline character type 1. |
| CRDLY | Select carriage-return delays: |
|     CR0 | Carriage-return delay type 0. |
|     CR1 | Carriage-return delay type 1. |
|     CR2 | Carriage-return delay type 2. |
|     CR3 | Carriage-return delay type 3. |
| TABDLY | Select horizontal-tab delays: |
|     TAB0 | Horizontal-tab delay type 0. |
|     TAB1 | Horizontal-tab delay type 1. |
|     TAB2 | Horizontal-tab delay type 2. |
|     TAB3 | Expand tabs to spaces. |
| BSDLY | Select backspace delays: |
|     BS0 | Backspace-delay type 0. |
|     BS1 | Backspace-delay type 1. |
| VTDLY | Select vertical-tab delays: |
|     VT0 | Vertical-tab delay type 0. |
|     VT1 | Vertical-tab delay type 1. |
| FFDLY | Select form-feed delays: |
|     FF0 | Form-feed delay type 0. |
|     FF1 | Form-feed delay type 1. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> |

If OPOST is set, output data shall be post-processed as described below, so that lines of text are modified to appear appropriately on the terminal device; otherwise, characters shall be transmitted without change.

<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If ONLCR is set, the NL character shall be transmitted as the CR-NL character pair. If OCRNL is set, the CR character shall be transmitted as the NL character. If ONOCR is set, no CR character shall be transmitted when at column 0 (first position). If ONLRET is set, the NL character is assumed to do the carriage-return function; the column pointer shall be set to 0 and the delays specified for CR shall be used. Otherwise, the NL character is assumed to do just the line-feed function; the column pointer remains unchanged. The column pointer shall also be set to 0 if the CR character is actually transmitted.

The delay bits specify how long transmission stops to allow for mechanical or other movement when certain characters are sent to the terminal. In all cases a value of 0 shall indicate no delay. If OFILL is set, fill characters shall be transmitted for delay instead of a timed delay. This is useful for high baud rate terminals which need only a minimal delay. If OFDEL is set, the fill character shall be DEL; otherwise, NUL.

If a \<form-feed\> or \<vertical-tab\> delay is specified, it shall last for about 2 seconds.

Newline delay shall last about 0.10 seconds. If ONLRET is set, the carriage-return delays shall be used instead of the newline delays. If OFILL is set, two fill characters shall be transmitted.

Carriage-return delay type 1 shall be dependent on the current column position, type 2 shall be about 0.10 seconds, and type 3 shall be about 0.15 seconds. If OFILL is set, delay type 1 shall transmit two fill characters, and type 2 four fill characters.

Horizontal-tab delay type 1 shall be dependent on the current column position. Type 2 shall be about 0.10 seconds. Type 3 specifies that \<tab\> characters shall be expanded into \<space\> characters. If OFILL is set, two fill characters shall be transmitted for any delay.

Backspace delay shall last about 0.05 seconds. If OFILL is set, one fill character shall be transmitted.

The actual delays depend on line speed and system load. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

The initial output control value after [*open*()](../functions/open.html) is implementation-defined.

#### <span id="tag_11_02_04"></span>11.2.4 Control Modes

The *c_cflag* field describes the hardware control of the terminal, and is composed of the bitwise-inclusive OR of the masks shown, which shall be bitwise-distinct. The mask name symbols in this table are defined in [*\<termios.h\>*](../basedefs/termios.h.html); not all values specified are required to be supported by the underlying hardware (if any). If the terminal is a pseudo-terminal, it is unspecified whether non-default values are unsupported, or are supported and emulated in software, or are handled by [*tcsetattr*()](../functions/tcsetattr.html), [*tcgetattr*()](../functions/tcgetattr.html), and the [*stty*](../utilities/stty.html) utility as if they are supported but have no effect on the behavior of the terminal interface.

| **Mask Name** | **Description**                                  |
|:--------------|:-------------------------------------------------|
| CLOCAL        | Ignore modem status lines.                       |
| CREAD         | Enable receiver.                                 |
| CSIZE         | Number of bits transmitted or received per byte: |
|    CS5        |    5 bits                                        |
|    CS6        |    6 bits                                        |
|    CS7        |    7 bits                                        |
|    CS8        |    8 bits.                                       |
| CSTOPB        | Send two stop bits, else one.                    |
| HUPCL         | Hang up on last close.                           |
| PARENB        | Parity enable.                                   |
| PARODD        | Odd parity, else even.                           |

In addition, the input and output baud rates are stored in the **termios** structure. The symbols in the following table are defined in [*\<termios.h\>*](../basedefs/termios.h.html). Not all values specified are required to be supported by the underlying hardware (if any). For pseudo-terminals, the input and output baud rates set in the **termios** structure need not affect the speed of data transmission through the terminal interface.

**Note:**  
The term "baud" is used historically here, but is not technically correct. This is properly "bits per second", which may not be the same as baud. However, the term is used because of the historical usage and understanding.

| **Name** | **Description** | **Name** | **Description** |
|:---------|:----------------|:---------|:----------------|
| B0       | Hang up         | B600     | 600 baud        |
| B50      | 50 baud         | B1200    | 1200 baud       |
| B75      | 75 baud         | B1800    | 1800 baud       |
| B110     | 110 baud        | B2400    | 2400 baud       |
| B134     | 134.5 baud      | B4800    | 4800 baud       |
| B150     | 150 baud        | B9600    | 9600 baud       |
| B200     | 200 baud        | B19200   | 19200 baud      |
| B300     | 300 baud        | B38400   | 38400 baud      |

The following functions are provided for getting and setting the values of the input and output baud rates in the **termios** structure: [*cfgetispeed*()](../functions/cfgetispeed.html), [*cfgetospeed*()](../functions/cfgetospeed.html), [*cfsetispeed*()](../functions/cfsetispeed.html), and [*cfsetospeed*()](../functions/cfsetospeed.html). The effects on the terminal device shall not become effective and not all errors need be detected until the [*tcsetattr*()](../functions/tcsetattr.html) function is successfully called.

The CSIZE bits shall specify the number of transmitted or received bits per byte. If ISTRIP is not set, the value of all the other bits is unspecified. If ISTRIP is set, the value of all but the 7 low-order bits shall be zero, but the value of any other bits beyond CSIZE is unspecified when read. CSIZE shall not include the parity bit, if any. If CSTOPB is set, two stop bits shall be used; otherwise, one stop bit. For example, at 110 baud, two stop bits are normally used.

If CREAD is set, the receiver shall be enabled; otherwise, no characters shall be received.

If PARENB is set, parity generation and detection shall be enabled and a parity bit is added to each byte. If parity is enabled, PARODD shall specify odd parity if set; otherwise, even parity shall be used.

If HUPCL is set, the modem control lines for the port shall be lowered when the last process with the port open closes the port or the process terminates. The modem connection shall be broken.

If CLOCAL is set, a connection shall not depend on the state of the modem status lines. If CLOCAL is clear, the modem status lines shall be monitored.

Under normal circumstances, a call to the [*open*()](../functions/open.html) function shall wait for the modem connection to complete. However, if the O_NONBLOCK flag is set (see [*open*()](../functions/open.html)) or if CLOCAL has been set, the [*open*()](../functions/open.html) function shall return immediately without waiting for the connection.

If the object for which the control modes are set is not an asynchronous serial connection, some of the modes may be ignored; for example, if an attempt is made to set the baud rate on a network connection to a terminal on another host, the baud rate need not be set on the connection between that terminal and the machine to which it is directly connected.

The initial hardware control value after [*open*()](../functions/open.html) is implementation-defined.

#### <span id="tag_11_02_05"></span>11.2.5 Local Modes

The *c_lflag* field of the argument structure is used to control various functions. It is composed of the bitwise-inclusive OR of the masks shown, which shall be bitwise-distinct. The mask name symbols in this table are defined in [*\<termios.h\>*](../basedefs/termios.h.html).

| **Mask Name** | **Description**                                     |
|:--------------|:----------------------------------------------------|
| ECHO          | Enable echo.                                        |
| ECHOE         | Echo ERASE as an error correcting backspace.        |
| ECHOK         | Echo KILL.                                          |
| ECHONL        | Echo \<newline\>.                                   |
| ICANON        | Canonical input (erase and kill processing).        |
| IEXTEN        | Enable extended (implementation-defined) functions. |
| ISIG          | Enable signals.                                     |
| NOFLSH        | Disable flush after interrupt, quit, or suspend.    |
| TOSTOP        | Send SIGTTOU for background output.                 |

If ECHO is set, input characters shall be echoed back to the terminal. If ECHO is clear, input characters shall not be echoed.

If ECHOE and ICANON are set, the ERASE character shall cause the terminal to erase, if possible, the last character in the current line from the display. If there is no character to erase, an implementation may echo an indication that this was the case, or do nothing.

If ECHOK and ICANON are set, the KILL character shall either cause the terminal to erase the line from the display or shall echo the \<newline\> character after the KILL character.

If ECHONL and ICANON are set, the \<newline\> character shall be echoed even if ECHO is not set.

If ICANON is set, canonical processing shall be enabled. This enables the erase and kill edit functions, and the assembly of input characters into lines delimited by NL, EOF, and EOL, as described in [11.1.6 Canonical Mode Input Processing](#tag_11_01_06).\

If ICANON is not set, read requests shall be satisfied directly from the input queue. A read shall not be satisfied until at least MIN bytes have been received or the timeout value TIME expired between bytes. The time value represents tenths of a second. See [11.1.7 Non-Canonical Mode Input Processing](#tag_11_01_07) for more details.

If IEXTEN is set, implementation-defined functions shall be recognized from the input data. It is implementation-defined how IEXTEN being set interacts with ICANON, ISIG, IXON, or IXOFF. If IEXTEN is not set, implementation-defined functions shall not be recognized and the corresponding input characters are processed as described for ICANON, ISIG, IXON, and IXOFF.

If ISIG is set, each input character shall be checked against the special control characters INTR, QUIT, and SUSP. If an input character matches one of these control characters, the function associated with that character shall be performed. If ISIG is not set, no checking shall be done. Thus these special input functions are possible only if ISIG is set.

If NOFLSH is set, the normal flush of the input and output queues associated with the INTR, QUIT, and SUSP characters shall not be done.

If TOSTOP is set, the signal SIGTTOU shall be sent to the process group of a process that tries to write to its controlling terminal if it is not in the foreground process group for that terminal. This signal, by default, stops the members of the process group. Otherwise, the output generated by that process shall be output to the current output stream. If the writing process is ignoring the SIGTTOU signal or the writing thread is blocking the SIGTTOU signal, the process is allowed to produce output, and the SIGTTOU signal shall not be sent.

The initial local control value after [*open*()](../functions/open.html) is implementation-defined.

#### <span id="tag_11_02_06"></span>11.2.6 Special Control Characters

The special control character values shall be defined by the array *c_cc*. The subscript name and description for each element in both canonical and non-canonical modes are as follows:

<table data-border="1" data-cellpadding="3" data-align="center">
<thead>
<tr data-valign="top">
<th colspan="2" style="text-align: center;"><p><strong>Subscript Usage</strong></p></th>
<th style="text-align: center;"><p><strong> </strong></p></th>
</tr>
</thead>
<tbody>
<tr data-valign="top">
<th style="text-align: center;"><p><strong>Canonical Mode</strong></p></th>
<th style="text-align: center;"><p><strong>Non-Canonical Mode</strong></p></th>
<th style="text-align: center;"><p>Description</p></th>
</tr>
&#10;<tr data-valign="top">
<td style="text-align: left;"><p>VEOF</p></td>
<td style="text-align: left;"><p> </p></td>
<td style="text-align: left;"><p>EOF character</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>VEOL</p></td>
<td style="text-align: left;"><p> </p></td>
<td style="text-align: left;"><p>EOL character</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>VERASE</p></td>
<td style="text-align: left;"><p> </p></td>
<td style="text-align: left;"><p>ERASE character</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>VINTR</p></td>
<td style="text-align: left;"><p>VINTR</p></td>
<td style="text-align: left;"><p>INTR character</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>VKILL</p></td>
<td style="text-align: left;"><p> </p></td>
<td style="text-align: left;"><p>KILL character</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p> </p></td>
<td style="text-align: left;"><p>VMIN</p></td>
<td style="text-align: left;"><p>MIN value</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>VQUIT</p></td>
<td style="text-align: left;"><p>VQUIT</p></td>
<td style="text-align: left;"><p>QUIT character</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>VSUSP</p></td>
<td style="text-align: left;"><p>VSUSP</p></td>
<td style="text-align: left;"><p>SUSP character</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p> </p></td>
<td style="text-align: left;"><p>VTIME</p></td>
<td style="text-align: left;"><p>TIME value</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>VSTART</p></td>
<td style="text-align: left;"><p>VSTART</p></td>
<td style="text-align: left;"><p>START character</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>VSTOP</p></td>
<td style="text-align: left;"><p>VSTOP</p></td>
<td style="text-align: left;"><p>STOP character</p></td>
</tr>
</tbody>
</table>

The subscript values are unique, except that the VMIN and VTIME subscripts may have the same values as the VEOF and VEOL subscripts, respectively.

Implementations that do not support changing the START and STOP characters may ignore the character values in the *c_cc* array indexed by the VSTART and VSTOP subscripts when [*tcsetattr*()](../functions/tcsetattr.html) is called, but shall return the value in use when [*tcgetattr*()](../functions/tcgetattr.html) is called.

The initial values of all control characters are implementation-defined.

If the value of one of the changeable special control characters (see [11.1.9 Special Characters](#tag_11_01_09)) is \_POSIX_VDISABLE, that function shall be disabled; that is, no input data is recognized as the disabled special character. If ICANON is not set, the value of \_POSIX_VDISABLE has no special meaning for the VMIN and VTIME entries of the *c_cc* array.

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
