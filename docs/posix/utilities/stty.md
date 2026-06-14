The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="stty"></span> <span id="tag_20_116"></span>

#### <span id="tag_20_116_01"></span>NAME

> stty — set the options for a terminal

#### <span id="tag_20_116_02"></span>SYNOPSIS

> `stty`` `**`[`**`-a|-g`**`]`**\
> \
> `stty`` `*`operand`*`...`\

#### <span id="tag_20_116_03"></span>DESCRIPTION

> The *stty* utility shall set or report on terminal I/O characteristics for the device that is its standard input. Without options or operands specified, it shall report the settings of certain characteristics, usually those that differ from implementation-defined defaults. Otherwise, it shall modify the terminal state according to the specified operands. Detailed information about the modes listed in the first five groups below are described in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). Operands in the Combination Modes group (see [Combination Modes](#tag_20_116_05_06)) are implemented using operands in the previous groups. Some combinations of operands are mutually-exclusive on some terminal types; the results of using such combinations are unspecified.
>
> Typical implementations of this utility require a communications line configured to use the **termios** interface defined in the System Interfaces volume of POSIX.1-2024. On systems where none of these lines are available, and on lines not currently configured to support the **termios** interface, some of the operands need not affect terminal characteristics.

#### <span id="tag_20_116_04"></span>OPTIONS

> The *stty* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-a**
>
> Write to standard output all the current settings for the terminal.
>
> **-g**
>
> Write to standard output all the current settings, optionally excluding the terminal window size, in an unspecified form that, when stripped of trailing \<newline\> characters, and used as the one and only argument to another invocation of the *stty* utility on the same system, attempts to apply those settings to the terminal. The form used shall not contain any sequence that would form an Informational Query, and shall consist of one line of text consisting of only printable characters from the portable character set, excluding white-space characters (other than the terminating \<newline\>) and these characters that could be altered by pathname expansion performed by the shell: `'*'`, `'?'`, and `'['`.

#### <span id="tag_20_116_05"></span>OPERANDS

> The following operands shall be supported.
>
> ##### <span id="tag_20_116_05_01"></span>Control Modes
>
> **parenb **(**-parenb**)
>
> Enable (disable) parity generation and detection. This shall have the effect of setting (not setting) PARENB in the **termios** *c_cflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **parodd **(**-parodd**)
>
> \
> Select odd (even) parity. This shall have the effect of setting (not setting) PARODD in the **termios** *c_cflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **cs5 cs6 cs7 cs8**
>
> Select character size, if possible. This shall have the effect of setting CS5, CS6, CS7, and CS8, respectively, in the **termios** *c_cflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> *number*
>
> Set terminal baud rate to the number given, if possible. If the baud rate is set to zero, the modem control lines shall no longer be asserted. This shall have the effect of setting the input and output **termios** baud rate values as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **ispeed ***number*
>
> Set terminal input baud rate to the number given, if possible. If the input baud rate is set to zero, the input baud rate shall be specified by the value of the output baud rate. This shall have the effect of setting the input **termios** baud rate value as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **ospeed ***number*
>
> Set terminal output baud rate to the number given, if possible. If the output baud rate is set to zero, the modem control lines shall no longer be asserted. This shall have the effect of setting the output **termios** baud rate value as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **hupcl **(**-hupcl**)
>
> Stop asserting modem control lines (do not stop asserting modem control lines) on last close. This shall have the effect of setting (not setting) HUPCL in the **termios** *c_cflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **hup **(**-hup**)
>
> Equivalent to **hupcl**(**-hupcl**).
>
> **cstopb **(**-cstopb**)
>
> Use two (one) stop bits per character. This shall have the effect of setting (not setting) CSTOPB in the **termios** *c_cflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **cread **(**-cread**)
>
> Enable (disable) the receiver. This shall have the effect of setting (not setting) CREAD in the **termios** *c_cflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **clocal **(**-clocal**)
>
> Assume a line without (with) modem control. This shall have the effect of setting (not setting) CLOCAL in the **termios** *c_cflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> It is unspecified whether *stty* shall report an error if an attempt to set a Control Mode fails.
>
> ##### <span id="tag_20_116_05_02"></span>Input Modes
>
> **ignbrk **(**-ignbrk**)
>
> Ignore (do not ignore) break on input. This shall have the effect of setting (not setting) IGNBRK in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **brkint **(**-brkint**)
>
> Signal (do not signal) INTR on break. This shall have the effect of setting (not setting) BRKINT in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **ignpar **(**-ignpar**)
>
> Ignore (do not ignore) bytes with parity errors. This shall have the effect of setting (not setting) IGNPAR in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **parmrk **(**-parmrk**)
>
> \
> Mark (do not mark) parity errors. This shall have the effect of setting (not setting) PARMRK in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **inpck **(**-inpck**)
>
> Enable (disable) input parity checking. This shall have the effect of setting (not setting) INPCK in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **istrip **(**-istrip**)
>
> Strip (do not strip) input characters to seven bits. This shall have the effect of setting (not setting) ISTRIP in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **inlcr **(**-inlcr**)
>
> Map (do not map) NL to CR on input. This shall have the effect of setting (not setting) INLCR in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **igncr (-igncr)**
>
> Ignore (do not ignore) CR on input. This shall have the effect of setting (not setting) IGNCR in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **icrnl **(**-icrnl**)
>
> Map (do not map) CR to NL on input. This shall have the effect of setting (not setting) ICRNL in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **ixon **(**-ixon**)
>
> Enable (disable) START/STOP output control. Output from the system is stopped when the system receives STOP and started when the system receives START. This shall have the effect of setting (not setting) IXON in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **ixany **(**-ixany**)
>
> Allow any character to restart output. This shall have the effect of setting (not setting) IXANY in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **ixoff **(**-ixoff**)
>
> Request that the system send (not send) STOP characters when the input queue is nearly full and START characters to resume data transmission. This shall have the effect of setting (not setting) IXOFF in the **termios** *c_iflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> ##### <span id="tag_20_116_05_03"></span>Output Modes
>
> **opost **(**-opost**)
>
> Post-process output (do not post-process output; ignore all other output modes). This shall have the effect of setting (not setting) OPOST in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **onlcr **(**-onlcr**)
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Map (do not map) NL to CR-NL on output. This shall have the effect of setting (not setting) ONLCR in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **ocrnl **(**-ocrnl**)
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Map (do not map) CR to NL on output. This shall have the effect of setting (not setting) OCRNL in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **onocr **(**-onocr**)
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Do not (do) output CR at column zero. This shall have the effect of setting (not setting) ONOCR in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **onlret **(**-onlret**)
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The terminal newline key performs (does not perform) the CR function. This shall have the effect of setting (not setting) ONLRET in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **ofill **(**-ofill**)
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Use fill characters (use timing) for delays. This shall have the effect of setting (not setting) OFILL in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **ofdel **(**-ofdel**)
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Fill characters are DELs (NULs). This shall have the effect of setting (not setting) OFDEL in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **cr0 cr1 cr2 cr3**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Select the style of delay for CRs. This shall have the effect of setting CRDLY to CR0, CR1, CR2, or CR3, respectively, in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **nl0 nl1**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Select the style of delay for NL. This shall have the effect of setting NLDLY to NL0 or NL1, respectively, in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **tab0 tab1 tab2 tab3**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
> Select the style of delay for horizontal tabs. This shall have the effect of setting TABDLY to TAB0, TAB1, TAB2, or TAB3, respectively, in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). Note that TAB3 has the effect of expanding \<tab\> characters to \<space\> characters. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **tabs **(**-tabs**)
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Synonym for **tab0** (**tab3**). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **bs0 bs1**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Select the style of delay for \<backspace\> characters. This shall have the effect of setting BSDLY to BS0 or BS1, respectively, in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **ff0 ff1**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Select the style of delay for \<form-feed\> characters. This shall have the effect of setting FFDLY to FF0 or FF1, respectively, in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **vt0 vt1**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Select the style of delay for \<vertical-tab\> characters. This shall have the effect of setting VTDLY to VT0 or VT1, respectively, in the **termios** *c_oflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> ##### <span id="tag_20_116_05_04"></span>Local Modes
>
> **isig **(**-isig**)
>
> Enable (disable) the checking of characters against the special control characters INTR, QUIT, and SUSP. This shall have the effect of setting (not setting) ISIG in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **icanon **(**-icanon**)
>
> Enable (disable) canonical input (ERASE and KILL processing). This shall have the effect of setting (not setting) ICANON in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **iexten **(**-iexten**)
>
> Enable (disable) any implementation-defined special control characters not currently controlled by **icanon**, **isig**, **ixon**, or **ixoff**. This shall have the effect of setting (not setting) IEXTEN in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **echo **(**-echo**)
>
> Echo back (do not echo back) every character typed. This shall have the effect of setting (not setting) ECHO in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **echoe **(**-echoe**)
>
> The ERASE character visually erases (does not erase) the last character in the current line from the display, if possible. This shall have the effect of setting (not setting) ECHOE in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **echok **(**-echok**)
>
> Echo (do not echo) NL after KILL character. This shall have the effect of setting (not setting) ECHOK in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **echonl **(**-echonl**)
>
> Echo (do not echo) NL, even if **echo** is disabled. This shall have the effect of setting (not setting) ECHONL in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).
>
> **noflsh **(**-noflsh**)
>
> Disable (enable) flush after INTR, QUIT, SUSP. This shall have the effect of setting (not setting) NOFLSH in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> **tostop **(**-tostop**)
>
> Send SIGTTOU for background output. This shall have the effect of setting (not setting) TOSTOP in the **termios** *c_lflag* field, as defined in XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) .
>
> ##### <span id="tag_20_116_05_05"></span>Special Control Character Assignments
>
> \<*control*\>-*character string*
>
> \
> Set \<*control*\>-*character* to *string*. If \<*control*\>-*character* is one of the character sequences in the first column of the following table, the corresponding XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11) control character from the second column shall be recognized. This has the effect of setting the corresponding element of the **termios** *c_cc* array (see XBD [*14. Headers*](../basedefs/V1_chap14.html#tag_14), [*\<termios.h\>*](../basedefs/termios.h.html)).\
>
> Table: Control Character Names in *stty*
>
> | **Control Character** | **c_cc Subscript** | **Description** |
> |:----------------------|:-------------------|:----------------|
> | **eof**               | VEOF               | EOF character   |
> | **eol**               | VEOL               | EOL character   |
> | **erase**             | VERASE             | ERASE character |
> | **intr**              | VINTR              | INTR character  |
> | **kill**              | VKILL              | KILL character  |
> | **quit**              | VQUIT              | QUIT character  |
> | **susp**              | VSUSP              | SUSP character  |
> | **start**             | VSTART             | START character |
> | **stop**              | VSTOP              | STOP character  |
>
> If *string* is a single character, the control character shall be set to that character. If *string* is the two-character sequence `"^-"` or the string *undef*, the control character shall be set to \_POSIX_VDISABLE , if it is in effect for the device; if \_POSIX_VDISABLE is not in effect for the device, it shall be treated as an error. In the POSIX locale, if *string* is a two-character sequence beginning with \<circumflex\> (`'^'`), and the second character is one of those listed in the `"^c"` column of the following table, the control character shall be set to the corresponding character value in the Value column of the table.\
>
> Table: Circumflex Control Characters in *stty*
>
> | **^c** | **Value** | **^c** | **Value** | **^c** | **Value** |
> |:-------|:----------|:-------|:----------|:-------|:----------|
> | a, A   | \<SOH\>   | l, L   | \<FF\>    | w, W   | \<ETB\>   |
> | b, B   | \<STX\>   | m, M   | \<CR\>    | x, X   | \<CAN\>   |
> | c, C   | \<ETX\>   | n, N   | \<SO\>    | y, Y   | \<EM\>    |
> | d, D   | \<EOT\>   | o, O   | \<SI\>    | z, Z   | \<SUB\>   |
> | e, E   | \<ENQ\>   | p, P   | \<DLE\>   | \[     | \<ESC\>   |
> | f, F   | \<ACK\>   | q, Q   | \<DC1\>   | \\     | \<FS\>    |
> | g, G   | \<BEL\>   | r, R   | \<DC2\>   | \]     | \<GS\>    |
> | h, H   | \<BS\>    | s, S   | \<DC3\>   | ^      | \<RS\>    |
> | i, I   | \<HT\>    | t, T   | \<DC4\>   | \_     | \<US\>    |
> | j, J   | \<LF\>    | u, U   | \<NAK\>   | ?      | \<DEL\>   |
> | k, K   | \<VT\>    | v, V   | \<SYN\>   |        |           |
>
> **min ***number*
>
> \
> Set the value of MIN to *number*. MIN is used in non-canonical mode input processing (**-icanon**).
>
> **time ***number*
>
> \
> Set the value of TIME to *number*. TIME is used in non-canonical mode input processing (**-icanon**).
>
> ##### <span id="tag_20_116_05_06"></span>Combination Modes
>
> *saved settings*
>
> \
> Set the current terminal characteristics to the saved settings produced by the **-g** option.
>
> **evenp** or **parity**
>
> \
> Enable **parenb** and **cs7**; disable **parodd**.
>
> **oddp**
>
> \
> Enable **parenb**, **cs7**, and **parodd**.
>
> **-parity**, **-evenp**, or **-oddp**
>
> \
> Disable **parenb**, and set **cs8**.
>
> **raw **(**-raw** or **cooked**)
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
> Enable (disable) raw input and output. Raw mode shall be equivalent to setting:
>
>
>     stty cs8 erase ^- kill ^- intr ^- \
>         quit ^- eof ^- eol ^- -post -inpck
>
> <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **nl **(**-nl**)
>
> \
> Disable (enable) **icrnl**. In addition, **-nl** unsets **inlcr** and **igncr**.
>
> **ek**
>
> Reset ERASE and KILL characters back to system defaults.
>
> **sane**
>
> \
> Reset all modes to some reasonable, unspecified, values.
>
> ##### <span id="tag_20_116_05_07"></span>Terminal Window Size
>
> **rows ***number*
>
> \
> Set the number of rows in the terminal window size to the number given.
>
> **cols ***number*
>
> \
> Set the number of columns in the terminal window size to the number given.
>
> The terminal window size shall be updated as if the *stty* utility calls [*tcgetwinsize*()](../functions/tcgetwinsize.html) to populate a **winsize** structure, updates one or both of the *ws_row* and *ws_col* members according to the **rows** and **cols** numbers specified, and then calls [*tcsetwinsize*()](../functions/tcsetwinsize.html) with the updated structure (see XSH [*tcgetwinsize*()](../functions/tcgetwinsize.html#) and [*tcsetwinsize*()](../functions/tcsetwinsize.html#) ).
>
> ##### <span id="tag_20_116_05_08"></span>Informational Queries
>
> **size**
>
> \
> Write the current terminal window size to standard output.

#### <span id="tag_20_116_06"></span>STDIN

> Although no input is read from standard input, standard input shall be used to get the current terminal I/O characteristics and to set new terminal I/O characteristics.

#### <span id="tag_20_116_07"></span>INPUT FILES

> None.

#### <span id="tag_20_116_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *stty*:
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
> This variable determines the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments) and which characters are in the class **print**.
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_116_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_116_10"></span>STDOUT

> If operands are specified and they do not include any Informational Queries, no output shall be produced.
>
> If the **size** operand is specified, *stty* shall write to standard output the terminal window size as follows:
>
>
>     "%1dΔ%1d\n", <rows>, <columns>
>
> where \<*rows*\> and \<*columns*\> are the number of rows and columns in the terminal window size, respectively.
>
> If the **-g** option is specified, *stty* shall write to standard output the current settings in a form that can be used as arguments to another instance of *stty* on the same system.
>
> If the **-a** option is specified, all of the information as described in the OPERANDS section shall be written to standard output. Unless otherwise specified, this information shall be written as \<space\>-separated tokens in an unspecified format, on one or more lines, with an unspecified number of tokens per line. Additional information may be written.
>
> If no options or operands are specified, an unspecified subset of the information written for the **-a** option shall be written.
>
> If speed information is written as part of the default output, or if the **-a** option is specified and if the terminal input speed and output speed are the same, the speed information shall be written as follows:
>
>
>     "speed %d baud;", <speed>
>
> Otherwise, speeds shall be written as:
>
>
>     "ispeed %d baud; ospeed %d baud;", <ispeed>, <ospeed>
>
> In locales other than the POSIX locale, the word **baud** may be changed to something more appropriate in those locales.
>
> If control characters are written as part of the default output, or if the **-a** option is specified, control characters shall be written as:
>
>
>     "%s = %s;", <control-character name>, <value>
>
> where \<*value*\> is either the character, or some visual representation of the character if it is non-printable, or the string `"<undef>"` if the character is disabled.

#### <span id="tag_20_116_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_116_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_116_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_116_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_116_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_116_16"></span>APPLICATION USAGE

> The **-g** flag is designed to facilitate the saving and restoring of terminal state from the shell level. For example, a program may:
>
>
>     saveterm=$(stty -g)                      # save terminal state
>     restoresize=$(
>         printf "stty rows %d cols %d" $(stty size)
>     )                                        # save terminal size
>     stty new settings                        # set new state
>     ...
>     [ -n "$saveterm" ] && stty "$saveterm"   # restore terminal state
>     eval "$restoresize"                      # restore terminal size
>
> Since the format is unspecified, the saved value is not portable across systems.
>
> Since the **-a** format is so loosely specified, scripts that save and restore terminal settings should use the **-g** option.

#### <span id="tag_20_116_17"></span>EXAMPLES

> None.

#### <span id="tag_20_116_18"></span>RATIONALE

> The original *stty* description was taken directly from System V and reflected the System V terminal driver **termio**. It has been modified to correspond to the terminal driver **termios**.
>
> Output modes are specified only for XSI-conformant systems. All implementations are expected to provide *stty* operands corresponding to all of the output modes they support.
>
> The *stty* utility is primarily used to tailor the user interface of the terminal, such as selecting the preferred ERASE and KILL characters. As an application programming utility, *stty* can be used within shell scripts to alter the terminal settings for the duration of the script.
>
> The **termios** section states that individual disabling of control characters is possible through the option \_POSIX_VDISABLE. If enabled, two conventions currently exist for specifying this: System V uses `"^-"`, and BSD uses *undef*. Both are accepted by *stty* in this volume of POSIX.1-2024. The other BSD convention of using the letter `'u'` was rejected because it conflicts with the actual letter `'u'`, which is an acceptable value for a control character.
>
> Early proposals did not specify the mapping of `"^c"` to control characters because the control characters were not specified in the POSIX locale character set description file requirements. The control character set is now specified in XBD [*3. Definitions*](../basedefs/V1_chap03.html#tag_03), so the historical mapping is specified. Note that although the mapping corresponds to control-character key assignments on many terminals that use the ISO/IEC 646:1991 standard (or ASCII) character encodings, the mapping specified here is to the control characters, not their keyboard encodings.
>
> Since **termios** supports separate speeds for input and output, two new options were added to specify each distinctly.
>
> Some historical implementations use standard input to get and set terminal characteristics; others use standard output. Since input from a login TTY is usually restricted to the owner while output to a TTY is frequently open to anyone, using standard input provides fewer chances of accidentally (or maliciously) altering the terminal settings of other users. Using standard input also allows *stty* **-a** and *stty* **-g** output to be redirected for later use. Therefore, usage of standard input is required by this volume of POSIX.1-2024.

#### <span id="tag_20_116_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_116_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), [*\<termios.h\>*](../basedefs/termios.h.html)

#### <span id="tag_20_116_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_116_22"></span>Issue 5

> The description of **tabs** is clarified.
>
> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_116_23"></span>Issue 6

> The LEGACY items **iuclc** (-**iuclc**), **xcase** (-**xcase**), **olcuc** (-**olcuc**), **lcase** (-**lcase**), and **LCASE** (-**LCASE**) are removed.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/37 is applied, applying IEEE PASC Interpretation 1003.2 \#133, fixing an error in the OPERANDS section for the Combination Modes **nl** (**-nl**).

#### <span id="tag_20_116_24"></span>Issue 7

> Austin Group Interpretation 1003.1-2001 \#144 is applied, moving functionality relating to the IXANY symbol from the XSI option to the Base.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0189 \[908\] is applied.

#### <span id="tag_20_116_25"></span>Issue 8

> Austin Group Defects 1053, 1532, and 1687 are applied, changing the **-g** option and adding the **rows** *number*, **cols** *number*, and **size** operands.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1508 is applied, changing the EXIT STATUS section.
>
> Austin Group Defect 1604 is applied, changing *undef* to `"<undef>"` in the STDOUT section, and changing **icanon** to **-icanon** in the descriptions of **min** and **time**.

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
