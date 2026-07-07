The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="timeout"></span> <span id="tag_20_123"></span>

#### <span id="tag_20_123_01"></span>NAME

> timeout — execute a utility with a time limit

#### <span id="tag_20_123_02"></span>SYNOPSIS

> `timeout`` `**`[`**`-fp`**`] [`**`-k`` `*`time`***`] [`**`-s`` `*`signal_name`***`]`**` `*`duration utility`*` `**`[`***`argument`*`...`**`]`**

#### <span id="tag_20_123_03"></span>DESCRIPTION

> The *timeout* utility shall execute the utility named by the *utility* operand, with arguments supplied as the *argument* operands (if any), in a child process. If the value of the *duration* operand is non-zero and the child process has not terminated after the specified time period, *timeout* shall send the signal specified by the **-s** option, or the SIGTERM signal if **-s** is not given.
>
> If the **-f** option is specified, the signal shall be sent only to the child process. Otherwise, it is implementation defined which one of the following methods is used to signal additional processes:
>
> - The *timeout* utility ensures it is a process group leader before creating the child process which executes the utility, in which case it shall send the signal to its process group.
>
> - The *timeout* utility arranges for any descendants of the child process that are orphaned to have their parent process changed to the *timeout* utility, in which case the signal shall be sent to the child process and all of its descendants.
>
> If the subsequent wait status of the child process shows that it was stopped by a signal, a SIGCONT signal shall also be sent in the same manner as the first signal; otherwise, a SIGCONT signal may be sent in the same manner.
>
> If the **-k** option is specified, and the child process created to execute the utility still has not terminated after the time period specified by the *time* option-argument has elapsed since the first signal was sent, *timeout* shall send a SIGKILL signal in the same manner as the first signal. If *timeout* receives a signal and propagates it to the child process (see ASYNCHRONOUS EVENTS below), this shall be treated as the first signal.

#### <span id="tag_20_123_04"></span>OPTIONS

> The *timeout* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-f**
>
> Only time out the utility itself, not its descendants.
>
> **-k ***time*
>
> Send a SIGKILL signal if the child process created to execute the utility has not terminated after the time period specified by *time* has elapsed since the first signal was sent. The value of *time* shall be interpreted as specified for the *duration* operand (see OPERANDS below).
>
> **-p**
>
> Always preserve (mimic) the wait status of the executed utility, even if the time limit was reached.
>
> **-s ***signal_name*
>
> \
> Specify the signal to send when the time limit is reached, using one of the symbolic names defined in the [*\<signal.h\>*](../basedefs/signal.h.html) header. Values of *signal_name* shall be recognized in a case-independent fashion, without the SIG prefix. By default, SIGTERM shall be sent.

#### <span id="tag_20_123_05"></span>OPERANDS

> The following operands shall be supported:
>
> *duration*
>
> The maximum amount of time to allow the utility to run, specified as a decimal number with an optional decimal fraction and an optional suffix, which can be:\
>
> **s**
>
> seconds
>
> **m**
>
> minutes
>
> **h**
>
> hours
>
> **d**
>
> days
>
> If a decimal fraction is present, the application shall ensure that it is separated from the units by a \<period\>. If no suffix is present, the value shall specify seconds.
>
> If the value is zero, *timeout* shall not enforce a time limit.
>
> *utility*
>
> The name of a utility that is to be executed. If the *utility* operand names any of the special built-in utilities in [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15), the results are undefined.
>
> *argument*
>
> Any string to be supplied as an argument when executing the utility named by the *utility* operand.

#### <span id="tag_20_123_06"></span>STDIN

> Not used.

#### <span id="tag_20_123_07"></span>INPUT FILES

> None.

#### <span id="tag_20_123_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *timeout*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *PATH*
>
> Determine the search path that is used to locate the utility to be executed. See XBD [*8.3 Other Environment Variables*](../basedefs/V1_chap08.html#tag_08_03).

#### <span id="tag_20_123_09"></span>ASYNCHRONOUS EVENTS

> The default behavior specified in [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04) shall apply, except that:
>
> - The *timeout* utility shall ignore SIGTTIN and SIGTTOU signals.
>
> - The *timeout* utility may alter the disposition of SIGALRM if the inherited disposition was for it to be ignored.
>
> - If the signal specified with the **-s** option, or any signal whose default action is to terminate the process, is delivered to the *timeout* utility, then unless the signal is SIGKILL or SIGSTOP, the *timeout* utility shall immediately send the same signal to the process or processes to which it would send a signal when the time limit is reached. If the delivered signal is SIGALRM, *timeout* may behave as if the time limit had been reached instead of sending SIGALRM.
>
> - If the **-f** option is not specified, then if *timeout* sends a signal to its process group, it shall briefly change the disposition of that signal to ignored while it sends the signal, so that it does not receive the signal itself.
>
> With the single exception of the signal specified with the **-s** option, or SIGTERM if **-s** is not used, all signal dispositions inherited by the utility specified by the *utility* operand shall be the same as the disposition that *timeout* inherited.

#### <span id="tag_20_123_10"></span>STDOUT

> Not used.

#### <span id="tag_20_123_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_123_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_123_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_123_14"></span>EXIT STATUS

> If the **-p** option is not specified and the time limit was reached:
>
> - If the **-k** option was not specified or the utility terminated before the time period specified by the *time* option-argument elapsed since the first signal was sent, the exit status shall be 124.
>
> - If the **-k** option was specified and the SIGKILL signal was sent, it is unspecified whether the exit status is 124 or the behavior is as if the **-p** option was specified.
>
> Otherwise, if the executed utility terminated by exiting, the exit status of *timeout* shall be that of the utility; if the utility was terminated by a signal, *timeout* shall terminate itself with the same signal while ensuring that a core image is not created.
>
> If an error occurs, the following exit values shall be returned:
>
> 125
>
> An error other than the two described below occurred.
>
> 126
>
> The utility specified by *utility* was found but could not be executed.
>
> 127
>
> The utility specified by *utility* could not be found.

#### <span id="tag_20_123_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_123_16"></span>APPLICATION USAGE

> Unlike the [*kill*](../utilities/kill.html) utility, the **-s** option of *timeout* is not required to accept the symbolic name 0 to represent signal value zero.
>
> When the value of *duration* is zero, *timeout* does not time out the utility, but it does still perform signal propagation (including to descendants of the utility if **-f** is not specified).
>
> Regardless of locale, the \<period\> character (the decimal-point character of the POSIX locale) is the decimal-point character recognized in the *duration* operand and the *time* option-argument.
>
> The [*command*](../utilities/command.html), [*env*](../utilities/env.html), [*nice*](../utilities/nice.html), [*nohup*](../utilities/nohup.html), [*time*](../utilities/time.html), *timeout*, and [*xargs*](../utilities/xargs.html) utilities have been specified to use exit code 127 if a utility to be invoked cannot be found, so that applications can distinguish "failure to find a utility" from "invoked utility exited with an error indication". The value 127 was chosen because it is not commonly used for other meanings; most utilities use small values for "normal error conditions" and the values above 128 can be confused with termination due to receipt of a signal. The value 126 was chosen in a similar manner to indicate that the utility could be found, but not invoked. Some scripts produce meaningful error messages differentiating the 126 and 127 cases. The distinction between exit codes 126 and 127 is based on KornShell practice that uses 127 when all attempts to *exec* the utility fail with \[ENOENT\], and uses 126 when any attempt to *exec* the utility fails for any other reason. The *timeout* utility extends these special exit codes to 125 and 124, with the meanings described in EXIT STATUS. A *timeout* exit status below 124 can only result from passing through the exit status of the executed utility.

#### <span id="tag_20_123_17"></span>EXAMPLES

> None.

#### <span id="tag_20_123_18"></span>RATIONALE

> Some *timeout* implementations make themselves a process group leader (when **-f** is not used) in order to be able to send signals to descendants of the child process. However, using this method means that any descendants which change their process group do not receive the signal. To ensure all descendants receive the signal, some implementations instead make use of a feature whereby descendants that are orphaned have their parent process changed to the *timeout* utility—that is, *timeout* becomes their "reaper"—together with the ability of a reaper to send a signal to all of its descendants.
>
> Some historical *timeout* implementations exited with status 128+*signal_number* when the child process was terminated by a signal before the time limit was reached (or when **-p** was used). This is reasonable when *timeout* is invoked from a shell which sets \$? to 128+*signal_number*, but not all shells do that. In particular, the KornShell sets \$? to 256+*signal_number* and so an exit status of 128+*signal_number* from *timeout* would be misleading. In order to avoid any possible ambiguity, this standard requires that *timeout* mimics the wait status of the child process by terminating itself with the same signal. When it does this it needs to ensure that it does not create a core image, otherwise it could overwrite one created by the invoked utility.
>
> The *timeout* utility ignores SIGTTIN and SIGTTOU so that if the utility it executes reads from or writes to the controlling terminal and this generates a SIGTTIN or SIGTTOU for the process group, *timeout* will not be stopped by the signal and can still time out the utility.
>
> Some historical *timeout* implementations always set the disposition for SIGTTIN and SIGTTOU in the child process to default, even if these signals were inherited as ignored. This could result in processes being stopped unexpectedly. Likewise, they did not ensure that for signals they caught, the disposition inherited by the executed utility was the same as the disposition that was inherited by *timeout*. This meant that, for example, if *timeout* was used in a script that was run with [*nohup*](../utilities/nohup.html), the utility executed by *timeout* would unexpectedly not be protected from SIGHUP. This standard requires that all signal dispositions inherited by the utility specified by the *utility* operand are the same as the disposition that *timeout* inherited, with the single exception of the signal that *timeout* sends when the time limit is reached, which needs to be inherited as default in order for the timeout to take effect (without resorting to SIGKILL if **-k** is specified).
>
> Some historical *timeout* implementations only propagated a subset of the signals whose default action is to terminate the process to the child process if one was delivered to the *timeout* utility. Propagating these signals is beneficial, as otherwise termination of the *timeout* utility by a signal results in the utility it executed being left running indefinitely (unless it also received the signal, for example a terminal-generated SIGINT). There is no reason to select a subset of these signals to be propagated, therefore this standard requires them all to be propagated (except SIGKILL, which cannot). In the event that a user wants to prevent the utility being timed out, sending *timeout* a SIGKILL can be used for this purpose.

#### <span id="tag_20_123_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_123_20"></span>SEE ALSO

> [*kill*](../utilities/kill.html#tag_20_64)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), [*\<signal.h\>*](../basedefs/signal.h.html)

#### <span id="tag_20_123_21"></span>CHANGE HISTORY

> First released in Issue 8.

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
