The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="make"></span> <span id="tag_20_76"></span>

#### <span id="tag_20_76_01"></span>NAME

> make — maintain, update, and regenerate files (**DEVELOPMENT**)

#### <span id="tag_20_76_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`SD`](javascript:open_code('SD'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` make`` `**`[`**`-einpqrst`**`] [`**`-f`` `*`makefile`***`]`**`...`` `**`[`**`-j`` `*`maxjobs`***`] [`**`-k|-S`**`]`\**
> ` ``      `` `**`[`***`macro`***`[`**`::`**`[`**`:`**`]]`**`=`*`value`*`...`**`] [`***`target_name`*`...`**`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_76_03"></span>DESCRIPTION

> The *make* utility shall update files that are derived from other files. A typical case is one where object files are derived from the corresponding source files. The *make* utility examines time relationships and shall update those derived files (called targets) that have modified times earlier than the modified times of the files (called prerequisites) from which they are derived. A description file (makefile) contains a description of the relationships between files, and the commands that need to be executed to update the targets to reflect changes in their prerequisites. Each specification, or rule, shall consist of a target, optional prerequisites, and optional commands to be executed when a prerequisite is newer than the target. There are two kinds of rule:
>
> 1.  *Inference rules*, which have one target name with at least one \<period\> (`'.'`) and no \<slash\> (`'/'`)
>
> 2.  *Target rules*, which can have more than one target name
>
> In addition, *make* shall have a collection of built-in macros and inference rules that infer prerequisite relationships to simplify maintenance of programs.
>
> To receive exactly the behavior described in this section, a portable makefile shall:
>
> - Include the special target **.POSIX**
>
> - Omit any special target reserved for implementations (a leading period followed by uppercase letters) that has not been specified by this section
>
> The behavior of *make* is unspecified if either or both of these conditions are not met.

#### <span id="tag_20_76_04"></span>OPTIONS

> The *make* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except for Guideline 9.
>
> The following options shall be supported:
>
> **-e**
>
> Cause environment variables, including those with null values, to override macro assignments within makefiles.
>
> **-f ***makefile*
>
> Specify a different makefile. The argument *makefile* is a pathname of a description file, which is also referred to as the *makefile*. A pathname of `'-'` shall denote the standard input. There can be multiple instances of this option, and they shall be processed in the order specified. The effect of specifying the same option-argument more than once is unspecified.
>
> **-i**
>
> Ignore error codes returned by invoked commands. This mode shall be the same as if the special target **.IGNORE** were specified without prerequisites.
>
> **-j ***maxjobs*
>
> Set the maximum number of targets that can be updated concurrently. If this option is specified multiple times, the last value of *maxjobs* specified shall take precedence. If this option is not specified, or if *maxjobs* is 1, only one target shall be updated at a time (no parallelization). If the value of *maxjobs* is non-positive, the behavior is unspecified. When *maxjobs* is greater than 1, *make* shall create a pool of up to *maxjobs* - 1 tokens. (Note that implementations are not required to create a pool of exactly *maxjobs* - 1 tokens. For example, an implementation could limit the pool size based on the number of processors available.) If the size of the token pool would be 0, *make* need not implement a token pool.
>
> When all of the following are true:
>
> - There is a target with commands that is not up-to-date
>
> - The target's prerequisites (if any) are up-to-date
>
> - *make* is not waiting to bring the target up-to-date (see **.WAIT**)
>
> - *make* is currently bringing a different target with commands up-to-date
>
> - *make* is not currently bringing *maxjobs* targets up-to-date in parallel
>
> - The special target **.NOTPARALLEL** is not specified
>
> - The token pool is not empty
>
> then *make* may attempt to remove one token from the pool. If a token is successfully removed, it shall attempt to bring this target up-to-date in parallel, and after this processing completes shall return the token to the pool. When *make* is bringing a target without commands up-to-date, it need not remove a token from the pool.
>
> If a rule invokes a sub-*make* either via the *MAKE* macro or via a command line that begins with `'+'`, the sub-*make* is the same implementation as the *make* that invoked the sub-*make*, and the **-j** option is passed to the sub-*make* via the *MAKEFLAGS* environment variable with the same *maxjobs* value and is not overridden by a *maxjobs* value from another source (even if it has the same value), the sub-*make* shall use the same token pool as its invoking *make* rather than create a new token pool. Otherwise, it is unspecified whether the sub-*make* uses the same token pool as its invoking *make* or creates a new token pool. If a rule executes multiple sub-*make* processes asynchronously the behavior is unspecified.
>
> **-k**
>
> Continue to update other targets that do not depend on the current target if a non-ignored error occurs while executing the commands to bring a target up-to-date.
>
> **-n**
>
> Write commands that would be executed on standard output, but do not execute them. However, lines with a \<plus-sign\> (`'+'`) prefix, lines that expand the *MAKE* macro, and lines being processed in order to create an include file or to bring it up-to-date (see **Include Lines** in the EXTENDED DESCRIPTION section) shall be executed. In this mode, lines with a \<commercial-at\> (`'@'`) character prefix shall be written to standard output.
>
> **-p**
>
> Write to standard output the complete set of macro definitions and target descriptions. The output format is unspecified.
>
> **-q**
>
> Return a zero exit value if the target file is up-to-date; otherwise, return an exit value of 1. Targets shall not be updated if this option is specified. However, a makefile command line (associated with the targets) with a \<plus-sign\> (`'+'`) prefix shall be executed and it is unspecified whether command lines that do not have a \<plus-sign\> prefix and either expand the *MAKE* macro or are being processed in order to create an include file or to bring it up-to-date (see **Include Lines** in the EXTENDED DESCRIPTION section) are executed.
>
> **-r**
>
> Clear the suffix list and do not use the built-in rules.
>
> **-S**
>
> Terminate *make* if an error occurs while executing the commands to bring a target up-to-date. This shall be the default and the opposite of **-k**.
>
> **-s**
>
> Do not write makefile *execution lines* (see [Makefile Execution](#tag_20_76_13_03)) or touch messages (see **-t**) to standard output before executing. This mode shall be the same as if the special target **.SILENT** were specified without prerequisites.
>
> **-t**
>
> Update the modification time of each target as though a [*touch*](../utilities/touch.html) *target* had been executed. Targets that have prerequisites but no commands (see [Target Rules](#tag_20_76_13_04)), or that are already up-to-date, shall not be touched in this manner. Write messages to standard output for each target file indicating the name of the file and that it was touched. Normally, the *makefile* command lines associated with each target are not executed. However, a command line with a \<plus-sign\> (`'+'`) prefix shall be executed and it is unspecified whether command lines that do not have a \<plus-sign\> prefix and either expand the *MAKE* macro or are being processed in order to create an include file or to bring it up-to-date (see **Include Lines** in the EXTENDED DESCRIPTION section) are executed.
>
> Any options specified in the *MAKEFLAGS* environment variable shall be evaluated before any options specified on the *make* utility command line. If the **-k** and **-S** options are both specified on the *make* utility command line or by the *MAKEFLAGS* environment variable, the last option specified shall take precedence. If the **-f** or **-p** options appear in the *MAKEFLAGS* environment variable, the result is undefined.

#### <span id="tag_20_76_05"></span>OPERANDS

> The following operands shall be supported:
>
> *target_name*
>
> Target names, as defined in the EXTENDED DESCRIPTION section. If no target is specified, while *make* is processing the makefiles, the first target that *make* encounters that is not a special target or an inference rule shall be used.
>
> *macro*=*value*
>
> *macro*::=*value*
>
> *macro*:::=*value*
>
> Delayed and immediate expansion macro definitions, as defined in [Macros](#tag_20_76_13_05).
>
> Delayed and immediate expansion macro definitions can be intermixed, and shall be processed in the order specified. If any macro definition appears after a *target_name* operand on the *make* utility command line, the results are unspecified.

#### <span id="tag_20_76_06"></span>STDIN

> The standard input shall be used only if the *makefile* option-argument is `'-'`. See the INPUT FILES section.

#### <span id="tag_20_76_07"></span>INPUT FILES

> The input file, otherwise known as the makefile, is a text file containing rules, macro definitions, include lines, and comments. See the EXTENDED DESCRIPTION section.

#### <span id="tag_20_76_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *make*:
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
> *MAKEFLAGS*
>
> \
> This variable shall be interpreted as a character string representing a series of option characters to be used as the default options. The implementation shall accept both of the following formats (but need not accept them when intermixed):
>
> - The characters are option letters without the leading \<hyphen-minus\> characters or \<blank\> separation used on a *make* utility command line.
>
> - The characters are formatted in a manner similar to the use of the *make* utility in shell commands: options are preceded by \<hyphen-minus\> characters and \<blank\>-separated as described in XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02). The *macro*=*value* macro definition operands can also be included. The difference between the contents of *MAKEFLAGS* and the use of the *make* utility in shell commands is that the contents of the variable shall not be subjected to the word expansions (see [*2.6 Word Expansions*](../utilities/V3_chap02.html#tag_19_06)) associated with parsing shell command lines.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *PROJECTDIR*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
> Provide a directory to be used to search for SCCS files not found in the current directory. In all of the following cases, the search for SCCS files is made in the directory **SCCS** in the identified directory. If the value of *PROJECTDIR* begins with a \<slash\>, it shall be considered an absolute pathname; otherwise, the value of *PROJECTDIR* is treated as a user name and that user's initial working directory shall be examined for a subdirectory **src** or **source**. If such a directory is found, it shall be used. Otherwise, the value is used as a relative pathname.
>
> If *PROJECTDIR* is not set or has a null value, the search for SCCS files shall be made in the directory **SCCS** in the current directory.
>
> The setting of *PROJECTDIR* affects all files listed in the remainder of this utility description for files with a component named **SCCS**. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> The value of the *SHELL* environment variable shall not be used as a macro and shall not be modified by defining the *SHELL* macro in a makefile or on the command line. All other environment variables, including those with null values, shall be used as macros, as defined in [Macros](#tag_20_76_13_05).

#### <span id="tag_20_76_09"></span>ASYNCHRONOUS EVENTS

> For SIGHUP, SIGINT, SIGQUIT, and SIGTERM signals, if the signal was not inherited as ignored, none of the **-n**, **-p**, or **-q** options was specified, *make* is currently processing a target or inference rule, and the current target is neither a directory nor a prerequisite of the special targets **.PHONY** or **.PRECIOUS**:
>
> - The *make* utility shall catch the signal and, if the time of last data modification of the current target has changed since make began processing the rule to bring that target up to date, remove that target; it may also remove that target if the time of last data modification has not changed. Any targets removed in this manner shall be reported in diagnostic or informational messages of unspecified format, written to standard error.
>
> - If *make* writes a diagnostic message to standard error, it shall exit with a status that indicates an error occurred; otherwise, it shall set the signal to default and re-signal itself.
>
> In all other circumstances, *make* shall take the standard action for all signals; see [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04).

#### <span id="tag_20_76_10"></span>STDOUT

> If *make* is invoked without any work needing to be done, it may write a message to standard output indicating that no action was taken. Otherwise, the *make* utility shall write all commands to be executed (and the filenames of files touched for the **-t** option in a message of unspecified format) to standard output unless the **-s** option was specified, the command is prefixed with a \<commercial-at\> (`'@'`), or the special target **.SILENT** has either the current target as a prerequisite or has no prerequisites.

#### <span id="tag_20_76_11"></span>STDERR

> The standard error shall be used for diagnostic messages and may be used for informational messages about target removals (see ASYNCHRONOUS EVENTS).

#### <span id="tag_20_76_12"></span>OUTPUT FILES

> Files can be created when the **-t** option is present. Additional files can also be created by the utilities invoked by *make*.

#### <span id="tag_20_76_13"></span>EXTENDED DESCRIPTION

> The *make* utility attempts to perform the actions, specified in one or more makefiles, required to ensure that specified targets are up-to-date. By default, the following files shall be tried in sequence: **./makefile** and **./Makefile**. If neither **./makefile** nor **./Makefile** is found, other implementation-defined files may also be tried. <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  On XSI-conformant systems, the additional files **./s.makefile**, **SCCS/s.makefile**, **./s.Makefile**, and **SCCS/s.Makefile** shall also be tried. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />  The **-f** option shall direct *make* to ignore any of these default files and use the specified option-argument as a makefile instead. If this option-argument is `'-'`, standard input shall be used.
>
> The term *makefile* is used to refer to any makefile contents provided by the user, whether in **./makefile** or its variants, or specified by the **-f** option.
>
> A target shall be considered up-to-date if it exists and is newer than all of its prerequisites, or if it has already been made up-to-date by the current invocation of *make* (regardless of the target's existence or age), except that targets that are made up-to-date in order for them to be processed as include line pathnames (see **Include Lines** below) need not be considered up-to-date during later processing. A target may also be considered up-to-date if it exists, is the same age as one or more of its prerequisites, and is newer than the remaining prerequisites (if any). The *make* utility shall treat all prerequisites as targets themselves and recursively ensure that they are up-to-date, processing them in the order in which they appear in the rule. The *make* utility shall use the modification times of files to determine whether the corresponding targets are out-of-date.
>
> To ensure that a target is up-to-date, *make* shall ensure that all of the prerequisites of the target are up-to-date, then check to see if the target itself is up-to-date. If the target is not up-to-date, the target shall be made up-to-date by executing the rule's commands (if any). If the target does not exist after the target has been successfully made up-to-date, the target shall be treated as being newer than any target for which it is a prerequisite.
>
> If a target exists and there is neither a target rule nor an inference rule for the target, the target shall be considered up-to-date. It shall be an error if *make* attempts to ensure that a target is up-to-date but the target does not exist and there is neither a target rule nor an inference rule for the target.
>
> ##### <span id="tag_20_76_13_01"></span>Makefile Syntax
>
> A makefile can contain rules, macro definitions (see [Macros](#tag_20_76_13_05)), include lines, and comments. There are two kinds of rules: *target rules*, including special targets (see [Target Rules](#tag_20_76_13_04)), and *inference rules* (see [Inference Rules](#tag_20_76_13_06)). The *make* utility shall contain a set of built-in inference rules. If the **-r** option is present, the built-in rules shall not be used and the suffix list shall be cleared. Additional rules of both kinds can be specified in a makefile. If a rule is defined more than once, the value of the rule shall be that of the last one specified. Macros can also be defined more than once, and the value of the macro is specified in [Macros](#tag_20_76_13_05). There are three kinds of comments: blank lines, empty lines, and a \<number-sign\> (`'#'`) and all following characters up to the first unescaped \<newline\> character. Blank lines, empty lines, and lines with \<number-sign\> (`'#'`) as the first character on the line are also known as comment lines.
>
> Target and inference rules can contain *command lines*. Command lines can have a prefix that shall be removed before execution (see [Makefile Execution](#tag_20_76_13_03)).
>
> When an escaped \<newline\> (one preceded by a \<backslash\>) is found anywhere in the makefile except in a command line after macro expansion, an include line, or a line immediately preceding an include line, it shall be replaced, along with any leading white space on the next line, with a single \<space\>. After all macro expansion is complete, when an escaped \<newline\> is found in a command line in a makefile, the command line that is executed shall contain the \<backslash\>, the \<newline\>, and the next line, except that the first character of the next line shall not be included if it is a \<tab\>. When an escaped \<newline\> is found in an include line or in a line immediately preceding an include line, the behavior is unspecified.
>
> ##### <span id="tag_20_76_13_02"></span>Include Lines
>
> If the word **include**, optionally prefixed with a \<hyphen-minus\> character, appears at the beginning of a line and is followed by one or more \<blank\> characters, the string formed by the remainder of the line shall be processed as follows to produce one or more pathnames:
>
> - The trailing \<newline\>, any \<blank\> characters immediately preceding a comment, and any comment shall be discarded. If the resulting string contains any double-quote characters (`'"'` ) the behavior is unspecified.
>
> - The resulting string shall be processed for macro expansion (see [Macros](#tag_20_76_13_05)).
>
> - Any \<blank\> characters that appear after the first non-\<blank\> shall be used as separators to divide the macro-expanded string into fields. It is unspecified whether pathname expansion (see [*2.14 Pattern Matching Notation*](../utilities/V3_chap02.html#tag_19_14)) is also performed.
>
> - If the processing of separators and optional pathname expansion results in zero non-empty fields, the behavior is unspecified. If it results in at least one non-empty field, these fields are taken as pathnames.
>
> For each pathname so identified, in the order specified:
>
> - If the pathname does not begin with a `'/'`, it shall be treated as relative to the current working directory of the process, not relative to the directory containing the makefile.
>
> - The *make* utility shall use one of the following two methods to attempt to create the file or bring it up-to-date:
>
>   1.  The "immediate remaking" method
>
>       If *make* uses this method, any target rules or inference rules for the pathname that were parsed before the include line was parsed shall be used to attempt to create the file or to bring it up-to-date before opening the file.
>
>   2.  The "delayed remaking" method
>
>       If *make* uses this method, no attempt shall be made to create the file or bring it up-to-date until after the makefile(s) have been read. During processing of the include line, *make* shall read the current contents of the file, if it exists, or treat it as an empty file if it does not exist. Once the makefile(s) have been read, *make* shall use any applicable target rule or inference rule for the pathname, regardless of whether it is parsed before or after the include line, when creating the file or bringing it up-to-date. Additionally in this case, the new contents of the file, if it is successfully created or updated, shall be used when processing rules for the following targets after the makefile(s) have been read:
>
>       - The *target_name* operands, if any.
>
>       - The first target *make* encounters that is not a special target or an inference rule, if no *target_name* operands are specified.
>
>       - All targets that are prerequisites, directly or recursively, of the above targets.
>
>   If the pathname is relative, the file does not exist, and an attempt to create it using a rule has not been made and will not be made, it is unspecified whether additional directories are searched for an existing file of the same relative pathname.
>
>   If, after proceeding as described above, the file still cannot be opened:
>
>   - If the word **include** was prefixed with a \<hyphen-minus\> character, the file shall be ignored.
>
>   - Otherwise, an error shall occur.
>
> - The contents of the file specified by the pathname shall be read and processed as if they appeared in the makefile in place of the include line. If the file ends with an escaped \<newline\> the behavior is unspecified.
>
> - The file may itself contain further include lines. Implementations shall support nesting of include files up to a depth of at least 16.
>
> ##### <span id="tag_20_76_13_03"></span>Makefile Execution
>
> Makefile command lines shall be processed one at a time.
>
> Makefile command lines can have one or more of the following prefixes: a \<hyphen-minus\> (`'-'`), a \<commercial-at\> (`'@'`), or a \<plus-sign\> (`'+'`). These shall modify the way in which *make* processes the command.
>
> `-`
>
> If the command prefix contains a \<hyphen-minus\>, or the **-i** option is present, or the special target **.IGNORE** has either the current target as a prerequisite or has no prerequisites, any error found while executing the command shall be ignored.
>
> `@`
>
> If the command prefix contains a \<commercial-at\> and the *make* utility command line **-n** option is not specified, or the **-s** option is present, or the special target **.SILENT** has either the current target as a prerequisite or has no prerequisites, the command shall not be written to standard output before it is executed.
>
> `+`
>
> If the command prefix contains a \<plus-sign\>, the command shall be executed even if **-n**, **-q**, or **-t** is specified.
>
> An *execution line* is built from the command line by removing any prefix characters. Except as described under the \<commercial-at\> (`'@'`) prefix, the execution line shall be written to the standard output, optionally preceded by a \<tab\>. The execution line shall then be executed by a shell as if it were passed as the argument to the [*system*()](../functions/system.html) interface, except that if errors are not being ignored then the shell **-e** option shall also be in effect. If errors are being ignored for the command (as a result of the **-i** option, a `'-'` command prefix, or a **.IGNORE** special target), the shell **-e** option shall not be in effect. The environment for the command being executed shall contain all of the variables in the environment of *make*.
>
> By default, when *make* receives a non-zero status from the execution of a command, it shall terminate with an error message to standard error.
>
> ##### <span id="tag_20_76_13_04"></span>Target Rules
>
> Target rules are formatted as follows:
>
>
>     target [target...]: [prerequisite...][;command]
>     [<tab>command
>     <tab>command
>     ...]
>
> Target entries are specified by a \<blank\>-separated, non-null list of targets, then a \<colon\>, then a \<blank\>-separated, possibly empty list of prerequisites. Text following a \<semicolon\>, if any, and all following lines that begin with a \<tab\>, are makefile command lines to be executed to update the target. The first non-empty line that does not begin with a \<tab\> or `'#'` shall begin a new entry. Any comment line may begin a new entry.
>
> Applications shall select target names from the set of characters consisting solely of slashes, hyphens, periods, underscores, digits, and alphabetics from the portable character set (see XBD [*6.1 Portable Character Set*](../basedefs/V1_chap06.html#tag_06_01)). Implementations may allow other characters in target names as extensions. The interpretation of targets containing the characters `'%'` and `'"'` is implementation-defined.
>
> A target that has prerequisites, but does not have any commands, can be used to add to the prerequisite list for that target. Only one target rule for any given target can contain commands.
>
> Lines that begin with one of the following are called *special targets* and control the operation of *make*:
>
> **.DEFAULT**
>
> If the makefile contains this special target, the application shall ensure that it is specified with commands, but without prerequisites. The commands shall be used by *make* if there are no other rules available to build a target.
>
> **.IGNORE**
>
> Prerequisites of this special target are targets themselves; this shall cause errors from commands associated with them to be ignored in the same manner as specified by the **-i** option. Subsequent occurrences of **.IGNORE** shall add to the list of targets ignoring command errors. If no prerequisites are specified, *make* shall behave as if the **-i** option had been specified and errors from all commands associated with all targets shall be ignored.
>
> **.NOTPARALLEL**
>
> \
> The application shall ensure that this special target is specified without prerequisites or commands. When specified, *make* shall update one target at a time, regardless of whether the **-j** *maxjobs* option is specified. If the **-j** *maxjobs* option is specified, the option shall continue to be passed unchanged to sub-*make* invocations via *MAKEFLAGS .*
>
> **.PHONY**
>
> Prerequisites of this special target are targets themselves; these targets (known as *phony targets*) shall be considered always out-of-date when the *make* utility begins executing. If a phony target's commands are executed, that phony target shall then be considered up-to-date until the execution of *make* completes. Subsequent occurrences of **.PHONY** shall add to the list of phony targets. A **.PHONY** special target with no prerequisites shall be ignored. If the **-t** option is specified, phony targets shall not be touched. Phony targets shall not be removed if *make* receives one of the asynchronous events explicitly described in the ASYNCHRONOUS EVENTS section.
>
> **.POSIX**
>
> The application shall ensure that this special target is specified without prerequisites or commands. If it appears as the first non-comment line in the makefile, *make* shall process the makefile as specified by this section; otherwise, the behavior of *make* is unspecified.
>
> **.PRECIOUS**
>
> Prerequisites of this special target shall not be removed if *make* receives one of the asynchronous events explicitly described in the ASYNCHRONOUS EVENTS section. Subsequent occurrences of **.PRECIOUS** shall add to the list of precious files. If no prerequisites are specified, all targets in the makefile shall be treated as if specified with **.PRECIOUS**.
>
> **.SCCS_GET**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The application shall ensure that this special target is specified without prerequisites. If this special target is included in a makefile, the commands specified with this target shall replace the default commands associated with this special target (see [Default Rules](#tag_20_76_13_09)). The commands specified with this target are used to get all SCCS files that are not found in the current directory.
>
> When source files are named in a list of prerequisites, *make* shall treat them just like any other target. Because the source file is presumed to be present in the directory, there is no need to add an entry for it to the makefile. When a target has no prerequisites, but is present in the directory, *make* shall assume that that file is up-to-date. If, however, an SCCS file named **SCCS/s.***source_file* is found for a target *source_file*, *make* compares the timestamp of the target file with that of the **SCCS/s.source_file** to ensure the target is up-to-date. If the target is missing, or if the SCCS file is newer, *make* shall automatically issue the commands specified for the **.SCCS_GET** special target to retrieve the most recent version. However, if the target is writable by anyone, *make* shall not retrieve a new version. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **.SILENT**
>
> Prerequisites of this special target are targets themselves; this shall cause commands associated with them not to be written to the standard output before they are executed. Subsequent occurrences of **.SILENT** shall add to the list of targets with silent commands. If no prerequisites are specified, *make* shall behave as if the **-s** option had been specified and no commands or touch messages associated with any target shall be written to standard output.
>
> **.SUFFIXES**
>
> Prerequisites of **.SUFFIXES** shall be appended to the list of known suffixes and are used in conjunction with the inference rules (see [Inference Rules](#tag_20_76_13_06)). If **.SUFFIXES** does not have any prerequisites, the list of known suffixes shall be cleared.
>
> **.WAIT**
>
> The application shall ensure that this special target, if specified as a target, is specified without prerequisites or commands. When **.WAIT** appears as a target, it shall have no effect. When **.WAIT** appears in a target rule as a prerequisite, it shall not itself be treated as a prerequisite; however, *make* shall not recursively process the prerequisites (if any) to the right of the **.WAIT** until the prerequisites (if any) to the left of it have been brought up-to-date. Implementations may also enforce the same ordering between the affected prerequisites while processing other target rules that have some or all of the same affected prerequisites.
>
> The special targets **.IGNORE**, **.NOTPARALLEL**, **.PHONY**, **.POSIX**, **.PRECIOUS**, **.SILENT**, **.SUFFIXES**, and **.WAIT** shall be specified without commands.
>
> Targets and prerequisites consisting of a leading \<period\> followed by the uppercase letters `"POSIX"` and then any other characters are reserved for future standardization. Targets and prerequisites consisting of a leading \<period\> followed by one or more uppercase letters, that are not described above, are reserved for implementation extensions.
>
> ##### <span id="tag_20_76_13_05"></span>Macros
>
> A macro can be one of two flavors, *delayed-expansion* or *immediate-expansion*.
>
> The following form defines a delayed-expansion macro (replacing any previous definition of the macro named by *string1*):
>
>
>     string1 = [string2]
>
> The following form defines an immediate-expansion macro (replacing any previous definition of the macro named by *string1*):
>
>
>     string1 ::= [string2]
>
> The following form defines a delayed-expansion macro (replacing any previous definition of the macro named by *string1*):
>
>
>     string1 :::= [string2]
>
> by immediately expanding macros in *string2*, if any, before assigning the value.
>
> The following form defines a delayed-expansion macro (replacing any previous definition of the macro named by *string1*):
>
>
>     string1 != [string2]
>
> by immediately expanding macros in *string2*, if any, and then executing the result as a shell command as if it were passed as the argument to the [*system*()](../functions/system.html) interface. The *make* utility shall capture the standard output from the shell execution and shall remove all white space at the beginning, remove a single trailing \<newline\> character (if there is one), and then replace all remaining \<newline\> characters with \<space\> characters to produce the value assigned to the macro named by *string1*. It shall not be an error if the shell command has non-zero exit status.
>
> The following form defines a delayed-expansion macro, but only if the macro named by *string1* is not already defined:
>
>
>     string1 ?= [string2]
>
> The following form (the *append* form) appends additional text to the value of a macro:
>
>
>     string1 += [string2]
>
> When using the append form:
>
> - If the macro named by *string1* does not exist, this form shall be equivalent to the delayed-expansion form
>
>
>       string1 = [string2]
>
> - If the macro named by *string1* exists and is an immediate-expansion macro, then a \<space\> or \<tab\> character followed by the evaluation of *string2* shall be appended to the value currently assigned to the macro named by *string1*.
>
> - If the macro named by *string1* exists and is a delayed-expansion macro, then a \<space\> or \<tab\> character followed by the unevaluated *string2* shall be appended to the value currently assigned to the macro named by *string1*.
>
> In all cases the value of *string1* is defined as all characters from the first non-\<blank\> character to the last non-\<blank\> character, inclusive, before the `=`, `::=`, `:::=`, `!=`, `?=`, or `+=`. Portable applications shall ensure that a \<blank\> precedes the `::=`, `:::=`, `!=`, `?=`, or `+=` in those forms to avoid any parsing ambiguity with implementations that permit \<colon\>, \<exclamation-mark\>, \<question-mark\>, or \<plus-sign\> in macro names as extensions. The value of *string2* is defined as all characters from the first non-\<blank\> character, if any, after the \<equals-sign\>, up to but not including a comment character (`'#'`) or an unescaped \<newline\>.
>
> Portable applications shall select macro names from the set of characters consisting solely of characters from the portable filename character set. Implementations may allow other characters in macro names as extensions; however, a macro name shall not contain an \<equals-sign\>, \<blank\>, or control character.
>
> Macro expansions in *string1* of macro definition lines shall be evaluated when read. Macro expansions in *string2* of macro definition lines shall be performed according to the form of macro definition used. In immediate-expansion forms (including appending to an existing immediate-expansion macro), they shall be expanded in the macro definition line and the result of the expansion shall not be scanned for further macros when the macro identified by *string1* is expanded. In delayed-expansion forms (including appending to an existing delayed-expansion macro, and conditional assignment to a macro not previously existing), they shall not be expanded in the macro definition line; they shall be expanded when the macro identified by *string1* is expanded, and the result of the expansion shall be scanned for further macros. Implementations shall support at least 100 levels of indirection.
>
> Macros can appear anywhere in the makefile. Macro expansions using the forms \$(*string1*) or \${*string1*} shall be replaced by *string2*, as follows:
>
> - Macros in target lines shall be evaluated when the target line is read.
>
> - Macros in makefile command lines shall be evaluated when the command is executed.
>
> - Macros in the string before the \<equals-sign\> in a macro definition shall be evaluated when the macro assignment is made.
>
> - Immediate-expansion macros shall be evaluated immediately when the macro assignment is made, and this value shall be used as the replacement until the immediate-expansion macro is redefined.
>
> - Delayed-expansion macros after the \<equals-sign\> in macro definitions other than the `:::=`, `!=`, and `+=` forms, and after the \<equals-sign\> in `+=` form macro definitions where the macro named by *string1* exists and is a delayed-expansion macro, shall only be evaluated when the defined macro is expanded.
>
> The parentheses or braces are optional if *string1* is a single character. The string `"$$"` shall be replaced by the single character `'$'`, except during the immediate expansion performed for the `:::=` operator, where it shall be left unmodified. If *string1* in a macro expansion contains a macro expansion, that inner macro expansion shall be performed first and the result substituted into *string1* to produce the macro name used for the outer macro expansion.
>
> Macro expansions using the forms \$(*string1***:***subst1***=\[***subst2***\]**) or \${*string1***:***subst1***=\[***subst2***\]**} can be used to replace all occurrences of *subst1* with *subst2* when the macro substitution is performed. The *subst1* to be replaced shall be recognized when it is a suffix at the end of a word in *string1* (where a *word*, in this context, is defined to be a string delimited by the beginning of the value, a \<blank\>, or a \<newline\>). If *string1* in a macro expansion contains a macro expansion, that inner macro expansion shall be performed as described above and the result substituted into *string1* to produce the macro name used for the outer macro expansion.
>
> Macro expansions using the forms \$(*string1***:\[***op***\]%\[***os***\]=\[***np***\]\[%\]\[***ns***\]**) or \${*string1***:\[***op***\]%\[***os***\]=\[***np***\]\[%\]\[***ns***\]**} are called pattern macro expansions, where *op* is the old prefix, *os* is the old suffix, *np* is the new prefix and *ns* is the new suffix. Any item inside square brackets is optional. With this form, when the macro *string1* is expanded each white-space-separated word that completely matches the **\[***op***\]%\[***os***\]** pattern on the left-hand side of the \<equals-sign\> (`'='`), where the \<percent\> (`'%'`) character matches zero or more characters, shall be replaced by the right-hand side of the \<equals-sign\> and shall then be further modified according to the use of \<percent\> characters as described below. Any words that do not match shall be unmodified in the expansion.
>
> If more than one \<percent\> character appears on the left-hand side of the \<equals-sign\> (`'='`), the second and subsequent \<percent\> characters shall be treated as literal characters in *os*.
>
> If no \<percent\> character appears on the right-hand side of the \<equals-sign\>, no further modification of the word shall be performed. If a single \<percent\> character appears on the right-hand side, the \<percent\> character in the word shall be replaced with the characters matched by the \<percent\> on the left-hand side. If more than one \<percent\> character appears on the right-hand side, it is unspecified whether the first \<percent\> character in the word is replaced with the characters matched by the \<percent\> on the left-hand side and all remaining \<percent\> characters are left unchanged, or each \<percent\> character is replaced with the characters matched by the \<percent\> on the left-hand side.
>
> In both macro expansion forms, any macro expansions on the right-hand side of the \<colon\> shall be recursively expanded before further examination. If this results in more than one \<equals-sign\> after the \<colon\>, the first one shall be the separator.
>
> In all forms of macro expansion, if the value of the macro named by *string1* is an empty string, or if the macro named by *string1* does not exist, the final result shall be an empty string.
>
> **Note:**  
> It is not safe to assume that a macro which has not intentionally been set to a specific value will not exist. See APPLICATION USAGE for more information.
>
> Macro definitions shall be taken from the following sources, in the following logical order, before the makefile(s) are read.
>
> 1.  Macros specified on the *make* utility command line, in the order specified on the command line. It is unspecified whether the internal macros defined in [Internal Macros](#tag_20_76_13_08) are accepted from this source.
>
> 2.  Macros defined by the *MAKEFLAGS* environment variable, in the order specified in the environment variable. It is unspecified whether the internal macros defined in [Internal Macros](#tag_20_76_13_08) are accepted from this source.
>
> 3.  The contents of the environment, excluding the *MAKEFLAGS* and *SHELL* variables and including the variables with null values.
>
> 4.  Macros defined in the inference rules built into *make*.
>
> Macro definitions from these sources shall not override macro definitions from a lower-numbered source. Macro definitions from a single source (for example, the *make* utility command line, the *MAKEFLAGS* environment variable, or the other environment variables) shall override previous macro definitions from the same source.
>
> Macros defined in the makefile(s) shall override macro definitions that occur before them in the makefile(s) and macro definitions from source 4. If the **-e** option is not specified, macros defined in the makefile(s) shall override macro definitions from source 3. Macros defined in the makefile(s) shall not override macro definitions from source 1 or source 2.
>
> Before the makefile(s) are read, all of the *make* utility command line options (except **-f** and **-p**) and *make* utility command line macro definitions (except any for the *MAKEFLAGS* macro), not already included in the *MAKEFLAGS* macro, shall be added to the *MAKEFLAGS* macro, quoted in an implementation-defined manner such that when *MAKEFLAGS* is read by another instance of the *make* command, the original macro's value is recovered. Other implementation-defined options and macros, with the exception of the *CURDIR* macro, may also be added to the *MAKEFLAGS* macro. If this modifies the value of the *MAKEFLAGS* macro, or, if the *MAKEFLAGS* macro is modified at any subsequent time, the *MAKEFLAGS* environment variable shall be modified to match the new value of the *MAKEFLAGS* macro. The result of setting *MAKEFLAGS* in the Makefile is unspecified.
>
> Before the makefile(s) are read, all of the *make* utility command line macro definitions (except the *MAKEFLAGS* macro or the *SHELL* macro) shall be added to the environment of *make*. Other implementation-defined variables may also be added to the environment of *make*. Macros defined by the *MAKEFLAGS* environment variable and macros defined in the makefile(s) shall not be added to the environment of *make* if they are not already in its environment. With the exception of *SHELL* (see below), it is unspecified whether macros defined in these ways update the value of an environment variable that already exists in the environment of *make*.
>
> The *MAKE* macro shall be treated specially. If *MAKE* is not defined in the environment, the *MAKE* macro shall be provided by *make* and set to the value of *argv*\[0\] passed to *main*() (or equivalent, if *make* is not a C program). If this value contains at least one \<slash\> and is a relative pathname, *make* shall convert it to an absolute pathname. If *MAKE* is defined in the makefile or is specified on the command line, it shall replace the original value of the *MAKE* macro.
>
> The *SHELL* macro shall be treated specially. It shall be provided by *make* and set to the pathname of the shell command language interpreter (see [*sh*](../utilities/sh.html#)). The *SHELL* environment variable shall not affect the value of the *SHELL* macro. If *SHELL* is defined in the makefile or is specified on the command line, it shall replace the original value of the *SHELL* macro, but shall not affect the *SHELL* environment variable. Other effects of defining *SHELL* in the makefile or on the command line are implementation-defined.
>
> The *CURDIR* macro shall be treated specially. It shall be provided by *make* and set to an absolute pathname of the current working directory when *make* is executed. The value shall be the same as the pathname that would be output by the [*pwd*](../utilities/pwd.html) utility with either the **-L** or **-P** option; if they differ, it is unspecified which value is used. The *CURDIR* environment variable shall not affect the value of the *CURDIR* macro unless the **-e** option is specified. If the **-e** option is not specified, there is a *CURDIR* environment variable set, and its value is different from the *CURDIR* macro value, the environment variable value shall be set to the macro value. If *CURDIR* is defined in the makefile, present in the *MAKEFLAGS* environment variable, or specified on the command line, it shall replace the original value of the *CURDIR* macro in accordance with the logical order described above, but shall not cause *make* to change its current working directory.
>
> ##### <span id="tag_20_76_13_06"></span>Inference Rules
>
> Inference rules are formatted as follows:
>
>
>     target:
>     <tab>command
>     [<tab>command]
>     ...
>
>
>     line that does not begin with <tab> or #
>
> The application shall ensure that the *target* portion is a valid target name (see [Target Rules](#tag_20_76_13_04)) of the form **.s2** or **.s1.s2** (where **.s1** and **.s2** are suffixes that have been given as prerequisites of the **.SUFFIXES** special target and s1 and s2 do not contain any \<slash\> or \<period\> characters.) If there is only one \<period\> in the target, it is a single-suffix inference rule. Targets with two periods are double-suffix inference rules. Inference rules can have only one target before the \<colon\>.
>
> The application shall ensure that the makefile does not specify prerequisites for inference rules; no characters other than white space shall follow the \<colon\> in the first line, except when creating the *empty rule,* described below. Prerequisites are inferred, as described below.
>
> Inference rules can be redefined. A target that matches an existing inference rule shall overwrite the old inference rule. An empty rule can be created with a command consisting of simply a \<semicolon\> (that is, the rule still exists and is found during inference rule search, but since it is empty, execution has no effect). The empty rule can also be formatted as follows:
>
>
>     rule: ;
>
> where zero or more \<blank\> characters separate the \<colon\> and \<semicolon\>.
>
> The *make* utility uses the suffixes of targets and their prerequisites to infer how a target can be made up-to-date. A list of inference rules defines the commands to be executed. By default, *make* contains a built-in set of inference rules. Additional rules can be specified in the makefile.
>
> The special target **.SUFFIXES** contains as its prerequisites a list of suffixes that shall be used by the inference rules. The order in which the suffixes are specified defines the order in which the inference rules for the suffixes are used. New suffixes shall be appended to the current list by specifying a **.SUFFIXES** special target in the makefile. A **.SUFFIXES** target with no prerequisites shall clear the list of suffixes. An empty **.SUFFIXES** target followed by a new **.SUFFIXES** list is required to change the order of the suffixes.
>
> Normally, the user would provide an inference rule for each suffix. The inference rule to update a target with a suffix **.s1** from a prerequisite with a suffix **.s2** is specified as a target **.s2.s1**. The internal macros provide the means to specify general inference rules (see [Internal Macros](#tag_20_76_13_08)).
>
> When no target rule with commands is found to update a target, the inference rules shall be checked. The suffix of the target (**.s1**) to be built shall be compared to the list of suffixes specified by the **.SUFFIXES** special targets. If the **.s1** suffix is found in **.SUFFIXES**, the inference rules shall be searched in the order defined for the first **.s2.s1** rule whose prerequisite file (**\$\*.s2**) exists. If the target is out-of-date with respect to this prerequisite, the commands for that inference rule shall be executed. Prerequisites added by target rules without commands shall not affect the selection of the applicable inference rule.
>
> If the target to be built does not contain a suffix and there is no rule for the target, the single-suffix inference rules shall be checked. The single-suffix inference rules define how to build a target if a file is found with a name that matches the target name with one of the single suffixes appended. A rule with one suffix **.s2** is the definition of how to build target from **target.s2**. The other suffix (**.s1**) is treated as null.
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> A \<tilde\> (`'~'`) in the above rules refers to an SCCS file in the current directory. Thus, the rule **.c~.o** would transform an SCCS C-language source file into an object file (**.o**). Because the **s.** of the SCCS files is a prefix, it is incompatible with *make*'s suffix point of view. Hence, the `'~'` is a way of changing any file reference into an SCCS file reference. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> ##### <span id="tag_20_76_13_07"></span>Libraries
>
> If a target or prerequisite contains parentheses, it shall be treated as a member of an archive library. For the *lib*(*member***.o**) expression *lib* refers to the name of the archive library and *member***.o** to the member name. The application shall ensure that the member is an object file with the **.o** suffix. The modification time of the expression is the modification time for the member as kept in the archive library; see [*ar*](../utilities/ar.html#). The **.a** suffix shall refer to an archive library. The **.s2.a** rule shall be used to update a member in the library from a file with a suffix **.s2**.
>
> ##### <span id="tag_20_76_13_08"></span>Internal Macros
>
> The *make* utility shall maintain a set of internal macros that can be used in the commands of target and inference rules, as described below. In order to clearly define the meaning of these macros, some clarification of the terms *target rule*, *inference rule*, *target*, and *prerequisite* is necessary.
>
> Target rules are specified by the user in a makefile for a particular target. Inference rules are user-specified or *make*-specified rules for a particular class of target name. Explicit prerequisites are those prerequisites specified in a makefile on target lines. Implicit prerequisites are those prerequisites that are generated when inference rules are used. Inference rules are applied to implicit prerequisites or to explicit prerequisites that do not have target rules defined for them in the makefile. Target rules are applied to targets specified in the makefile.
>
> Before any target in the makefile is updated, each of its prerequisites (both explicit and implicit) shall be updated. This shall be accomplished by recursively processing each prerequisite. Upon recursion, each prerequisite shall become a target itself. Its prerequisites in turn shall be processed recursively until a target is found that has no prerequisites, or further recursion would require applying two inference rules one immediately after the other, at which point the recursion shall stop. As an extension, implementations may continue recursion when two or more successive inference rules need to be applied; however, if there are multiple different chains of such rules that could be used to create the target, it is unspecified which chain is used. The recursion shall then back up, updating each target as it goes.
>
> In the definitions that follow, the word *target* refers to one of:
>
> - A target specified in the makefile
>
> - An explicit prerequisite specified in the makefile that becomes the target when *make* processes it during recursion
>
> - An implicit prerequisite that becomes a target when *make* processes it during recursion
>
> In the definitions that follow, the word *prerequisite* refers to one of:
>
> - An explicit prerequisite specified in the makefile for a particular target
>
> - An implicit prerequisite generated as a result of locating an appropriate inference rule and corresponding file that matches the suffix of the target
>
> The internal macros are:
>
> \$@
>
> The \$@ macro shall evaluate to the full target name of the current target, or the archive filename part of a library archive target. It shall be evaluated for both target and inference rules.
>
> For example, in the **.c.a** inference rule, \$@ represents the out-of-date **.a** file to be built. Similarly, in a makefile target rule to build **lib.a** from **file.c**, \$@ represents the out-of-date **lib.a**.
>
> \$%
>
> The \$% macro shall be evaluated only when the current target is an archive library member of the form *libname*(*member***.o**). In these cases, \$@ shall evaluate to *libname* and \$% shall evaluate to *member***.o**. The \$% macro shall be evaluated for both target and inference rules.
>
> For example, in a makefile target rule to build **lib.a**(**file.o**), \$% represents **file.o**, as opposed to \$@, which represents **lib.a**.
>
> \$^
>
> The \$^ macro shall evaluate to the list of prerequisites for the current target, with any duplicates (except the first) removed. It shall be evaluated for both target and inference rules. If the list of prerequisites of the target contains any **.WAIT** special targets, the results of expanding \$^ are unspecified.
>
> For example, in a makefile target rule to build *prog* from **file1.o**, **file2.o**, and **file3.o**, and regardless of which prerequisites *prog* is out-of-date with respect to, \$^ represents **file1.o**, **file2.o**, and **file3.o**.
>
> \$+
>
> The \$+ macro shall be equivalent to \$^, except that duplicates shall not be removed; all prerequisites shall appear in the order they were listed in the makefile.
>
> \$?
>
> The \$? macro shall evaluate to the list of prerequisites that are newer than the current target. It shall be evaluated for both target and inference rules.
>
> For example, in a makefile target rule to build *prog* from **file1.o**, **file2.o**, and **file3.o**, and where *prog* is not out-of-date with respect to **file1.o**, but is out-of-date with respect to **file2.o** and **file3.o**, \$? represents **file2.o** and **file3.o**.
>
> \$\<
>
> In an inference rule, the \$\< macro shall evaluate to the filename whose existence allowed the inference rule to be chosen for the target. In the **.DEFAULT** rule, the \$\< macro shall evaluate to the current target name. The meaning of the \$\< macro is otherwise unspecified.
>
> For example, in the **.c.a** inference rule, \$\< represents the prerequisite **.c** file.
>
> \$\*
>
> The \$\* macro shall evaluate to the current target name with its suffix deleted. It shall be evaluated at least for inference rules.
>
> For example, in the **.c.a** inference rule, \$\*.o represents the out-of-date **.o** file that corresponds to the prerequisite **.c** file.
>
> Each of the internal macros has an alternative form. When an uppercase `'D'` or `'F'` is appended to any of the macros, the meaning shall be changed to the *directory part* for `'D'` and *filename part* for `'F'`. The directory part is the path prefix of the file without a trailing \<slash\>; for the current directory, the directory part is `'.'`. When the \$? macro contains more than one prerequisite filename, the \$(?D) and \$(?F) (or \${?D} and \${?F}) macros expand to a list of directory name parts and filename parts respectively.
>
> For the target *lib*(*member***.o**) and the **.s2.a** rule, the internal macros shall be defined as:
>
> \$\<
>
> *member***.s2**
>
> \$\*
>
> *member*
>
> \$@
>
> *lib*
>
> \$^
>
> *member***.s2**
>
> \$?
>
> *member***.s2**
>
> \$%
>
> *member***.o**
>
> ##### <span id="tag_20_76_13_09"></span>Default Rules
>
> The default rules and macro values for *make* shall achieve results that are the same as if the following were used, except that where a result includes the literal value of a macro, this value may differ. Implementations that do not support the C-Language Development Utilities option may omit **CC**, **CFLAGS**, **YACC**, **YFLAGS**, **LEX**, **LFLAGS**, **LDFLAGS**, and the **.c**, **.y**, and **.l** inference rules. Implementations may provide additional macros and rules.
>
>
>     SPECIAL TARGETS
>
>
>     [XSI]
>     .SCCS_GET:
>         sccs $(SCCSFLAGS) get $(SCCSGETFLAGS) $@
>
>
>
>     [XSI]
>     .SUFFIXES: .o .c .y .l .a .sh .c~ .y~ .l~ .sh~
>
>
>     MACROS
>
>
>     AR=ar
>     ARFLAGS=-rv
>     YACC=yacc
>     YFLAGS=
>     LEX=lex
>     LFLAGS=
>     LDFLAGS=
>     CC=c17
>     CFLAGS=-O 1
>     [XSI]
>     GET=get
>     GFLAGS=
>     SCCSFLAGS=
>     SCCSGETFLAGS=-s
>
>
>
>     SINGLE-SUFFIX RULES
>
>
>     .c:
>         $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<
>
>
>     .sh:
>         cp $< $@
>         chmod a+x $@
>
>
>     [XSI]
>     .c~:
>         $(GET) $(GFLAGS) -p $< > $*.c
>         $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $*.c
>
>
>     .sh~:
>         $(GET) $(GFLAGS) -p $< > $*.sh
>         cp $*.sh $@
>         chmod a+x $@
>
>
>
>     DOUBLE-SUFFIX RULES
>
>
>     .c.o:
>         $(CC) $(CFLAGS) -c $<
>
>
>     .y.o:
>         $(YACC) $(YFLAGS) $<
>         $(CC) $(CFLAGS) -c y.tab.c
>         rm -f y.tab.c
>         mv y.tab.o $@
>
>
>     .l.o:
>         $(LEX) $(LFLAGS) $<
>         $(CC) $(CFLAGS) -c lex.yy.c
>         rm -f lex.yy.c
>         mv lex.yy.o $@
>
>
>     .y.c:
>         $(YACC) $(YFLAGS) $<
>         mv y.tab.c $@
>
>
>     .l.c:
>         $(LEX) $(LFLAGS) $<
>         mv lex.yy.c $@
>
>
>     [XSI]
>     .c~.o:
>         $(GET) $(GFLAGS) -p $< > $*.c
>         $(CC) $(CFLAGS) -c $*.c
>
>
>     .y~.o:
>         $(GET) $(GFLAGS) -p $< > $*.y
>         $(YACC) $(YFLAGS) $*.y
>         $(CC) $(CFLAGS) -c y.tab.c
>         rm -f y.tab.c
>         mv y.tab.o $@
>
>
>     .l~.o:
>         $(GET) $(GFLAGS) -p $< > $*.l
>         $(LEX) $(LFLAGS) $*.l
>         $(CC) $(CFLAGS) -c lex.yy.c
>         rm -f lex.yy.c
>         mv lex.yy.o $@
>
>
>     .y~.c:
>         $(GET) $(GFLAGS) -p $< > $*.y
>         $(YACC) $(YFLAGS) $*.y
>         mv y.tab.c $@
>
>
>     .l~.c:
>         $(GET) $(GFLAGS) -p $< > $*.l
>         $(LEX) $(LFLAGS) $*.l
>         mv lex.yy.c $@
>
>
>
>     .c.a:
>         $(CC) -c $(CFLAGS) $<
>         $(AR) $(ARFLAGS) $@ $*.o
>         rm -f $*.o

#### <span id="tag_20_76_14"></span>EXIT STATUS

> When the **-q** option is specified, the *make* utility shall exit with one of the following values:
>
>  0
>
> All specified targets were already up-to-date.
>
>  1
>
> One or more targets were not up-to-date.
>
> \>1
>
> An error occurred.
>
> When the **-q** option is not specified, the *make* utility shall exit with one of the following values:
>
>  0
>
> All specified targets were already up-to-date, or all commands executed to bring targets up-to-date either exited with status 0 or had a non-zero exit status that was specified (via the **-i** option, the special target **.IGNORE**, or a `'-'` command prefix) to be ignored.
>
> \>0
>
> An error occurred, or at least one command executed to bring a target up-to-date exited with a non-zero exit status that was not specified to be ignored.

#### <span id="tag_20_76_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_76_16"></span>APPLICATION USAGE

> If there is a source file (such as **./source.c**) and there are two SCCS files corresponding to it (**./s.source.c** and **./SCCS/s.source.c**), on XSI-conformant systems *make* uses the SCCS file in the current directory. However, users are advised to use the underlying SCCS utilities ([*admin*](../utilities/admin.html), [*delta*](../utilities/delta.html), [*get*](../utilities/get.html), and so on) or the [*sccs*](../utilities/sccs.html) utility for all source files in a given directory. If both forms are used for a given source file, future developers are very likely to be confused.
>
> It is incumbent upon portable makefiles to specify the **.POSIX** special target in order to guarantee that they are not affected by local extensions.
>
> The **-k** and **-S** options are both present so that the relationship between the command line, the *MAKEFLAGS* variable, and the makefile can be controlled precisely. If the **k** flag is passed in *MAKEFLAGS* and a command is of the form:
>
>
>     $(MAKE) -S foo
>
> then the default behavior is restored for the child *make*.
>
> When the **-n** option is specified, it is always added to *MAKEFLAGS .* This allows a recursive *make* **-n** *target* to be used to see all of the actions that would be taken to update *target*.
>
> Because of widespread historical practice, interpreting a \<number-sign\> (`'#'`) inside a variable as the start of a comment has the unfortunate side-effect of making it impossible to place a \<number-sign\> in a variable, thus forbidding something like:
>
>
>     CFLAGS = -D "COMMENT_CHAR='#'"
>
> Many historical *make* utilities stop chaining together inference rules when an intermediate target is nonexistent. For example, it might be possible for a *make* to determine that both **.y.c** and **.c.o** could be used to convert a **.y** to a **.o**. Instead, in this case, *make* requires the use of a **.y.o** rule.
>
> The standard set of default rules uses only features provided by other parts of this volume of POSIX.1-2024. They include rules for optional utilities in this volume of POSIX.1-2024, but only rules pertaining to utilities that are provided are needed in an implementation's default set.
>
> Although *make* expands macros that do not exist to an empty string, it is not safe to assume that a macro which has not intentionally been set to a specific value will expand to an empty string for everyone who uses the makefile. There are two reasons for this:
>
> 1.  When another user executes *make*, they might happen to have an environment variable of the same name (which they have set for some unrelated purpose) with a non-empty value.
>
> 2.  A different implementation of *make* (or a later version of the same implementation) might have a non-empty value for the macro in its default set.
>
> This is one aspect of a more general problem, which is that any macro that is not one for which this standard requires a default value, and is not explicitly set either in the makefile or on the *make* command line, can have an unexpected value (or unexpectedly not exist) when the makefile is used by a different user or with a different *make* implementation.
>
> For this reason, it is recommended that makefile authors do not design makefile schemes in which values for non-standard macros are obtained from the user's environment variables. Safer methods of allowing users to configure macro values include:
>
> - Setting the macros to default values in a *make* include file where the user can edit the values.
>
> - Executing *make* from one or more wrapper scripts which set macro values on the command line (and which do not obtain those values from environment variables).
>
> Makefile authors who follow this recommendation may wish to check for any macros they have overlooked by using a *make* implementation that provides, as an extension, a command-line option that causes *make* to report attempts to expand (or append to) macros that do not exist. Users of makefiles written by others can also benefit from the use of such an option to detect the opposite problem (where the author had a macro being set from an environment variable but the user does not have the variable set). This can avoid misbehaviors that would otherwise be hard to debug, such as a file-processing utility reading from standard input because it was not given any pathnames to process.
>
> Makefile authors who choose not to follow the recommendation can minimize the risk of misbehavior by ensuring all non-standard macros have names that begin with a suitable project-specific prefix.
>
> Use of the **-e** option is strongly discouraged, as it makes the problem discussed above even more likely by introducing the possibility of unexpected values occurring even for macros set in the makefile. If a specific macro needs a value from the environment to override a value set in the makefile, it is safer to set just that macro on the command line, using for example `make MYPROJ_FOO="$MYPROJ_FOO"`. Alternatively, the makefile can be modified to use the `?=` assignment operator for that macro.
>
> Delayed-expansion macros are evaluated when they are used rather than when they are defined. Therefore:
>
>
>     MACRO = value1
>     Immed ::= $(MACRO)
>     DELAY = $(MACRO)
>     MACRO = value2
>
>
>     target:
>         echo $(Immed) $(DELAY)
>
> would produce `"value1 value2"`, since **Immed** was expanded while **MACRO** was *value1*, but **DELAY** was not expanded until it was needed in the [*echo*](../utilities/echo.html) command line when **MACRO** was *value2*.
>
> Because the behavior of the `+=` assignment differs depending on whether the macro being appended to is a delayed-expansion macro or an immediate-expansion macro, it is recommended that when both macro types are used in a set of multiple makefiles and include files, a naming convention is adopted to distinguish the two macro types. This avoids any confusion about whether `+=` will append the expanded or unexpanded value. A suitable convention might be to name delayed-expansion macros using uppercase and underscore characters and immediate-expansion macros using a name that contains at least one lowercase character.
>
> Some historical applications have been known to intermix *target_name* and *macro=name* operands on the command line, expecting that all of the macros are processed before any of the targets are dealt with. Conforming applications do not do this, although some backwards-compatibility support may be included in some implementations.
>
> The following characters in filenames may give trouble: `'='`, `':'`, `` '`' ``, single-quote, and `'@'`. In include filenames, pattern matching characters and `'"'` should also be avoided, as they may be treated as special by some implementations.
>
> For inference rules, the descriptions of \$\< and \$? seem similar. However, an example shows the minor difference. In a makefile containing:
>
>
>     foo.o: foo.h
>
> if **foo.h** is newer than **foo.o**, yet **foo.c** is older than **foo.o**, the built-in rule to make **foo.o** from **foo.c** is used, with \$\< equal to **foo.c** and \$? equal to **foo.h**. If **foo.c** is also newer than **foo.o**, \$\< is equal to **foo.c** and \$? is equal to **foo.h foo.c**.
>
> As a consequence of the general rules for target updating, a useful special case is that if a target has no prerequisites and no commands, and the target of the rule is a nonexistent file, then *make* acts as if this target has been updated whenever its rule is run.
>
> **Note:**  
> This implies that all targets depending on this one will always have their commands run.
>
> Shell command sequences like `make; cp original copy; make` may have problems on filesystems where the timestamp resolution is the minimum (1 second) required by the standard and where *make* considers identical timestamps to be up-to-date. Conversely, rules like `copy: original; cp -p original copy` will result in redundant work on *make* implementations that consider identical timestamps to be out-of-date.
>
> The requirements relating to dynamic include files (ones that have rules to create or update them) allow two different methods of implementing them, as explained in RATIONALE below. In order to write a set of makefiles and include files (both dynamic and static) that work with both methods, applications need to ensure the following:
>
> - Rules containing commands for creating dynamic include files (and any prerequisites) precede the include line that will cause the file to be read.
>
> - Include lines and rules for creating dynamic include files do not depend on the contents of any earlier dynamic include file. For example, defining a macro in a dynamic include file and using that macro in a later include line should be avoided (unless the later include line is itself inside the dynamic include file).
>
> - One of the rules used in creating a dynamic include file, or a dynamic prerequisite of an include file, contains commands to create its target and does not ignore creation failure.
>
> Note that although the first point above appears at first sight to preclude a dynamic include file that defines its own prerequisites, this can be achieved by having two include lines that name the same file (provided the rules in the file do not contain command lines), as shown in EXAMPLES.
>
> This standard does not specify precedence between macro definition and include directives. Thus, the behavior of:
>
>
>     include =foo.mk
>
> is unspecified. To define a variable named include, either the white space before the \<equal-sign\> should be removed, or another macro should be used, as in:
>
>
>     INCLUDE_NAME = include
>     $(INCLUDE_NAME) =foo.mk
>
> On the other hand, if the intent is to include a file which starts with an \<equal-sign\>, either the filename should be changed to `./=foo.mk`, or the makefile should be written as:
>
>
>     INCLUDE_FILE = =foo.mk
>     include $(INCLUDE_FILE)
>
> It is important to be careful when using parallel execution (the **-j** option) and archives. If multiple `$(AR)` commands run at the same time on the same archive file, they will not know about each other and can corrupt the file. If the **-j** option is used, it is necessary to use **.WAIT** in between archive member prerequisites to prevent this (see EXAMPLES).

#### <span id="tag_20_76_17"></span>EXAMPLES

> 1.  The following command:
>
>
>         make
>
>     makes the first target found in the makefile.
>
> 2.  The following command:
>
>
>         make junk
>
>     makes the target **junk**.
>
> 3.  The following makefile says that **pgm** depends on two files, **a.o** and **b.o**, and that they in turn depend on their corresponding source files (**a.c** and **b.c**), and a common file **incl.h**:
>
>
>         .POSIX:
>         pgm: a.o b.o
>             c17 a.o b.o -o pgm
>         a.o: incl.h a.c
>             c17 -c a.c
>         b.o: incl.h b.c
>             c17 -c b.c
>
> 4.  The following is an extended version of the previous example that generates *make* include files containing the prerequisites for each object file. The include file also defines its own prerequisites, and the makefile arranges that these are used by including the file twice. With implementations of *make* that create include files during parsing, the first time *make* is run the file does not exist but the use of the \<hyphen-minus\> prefix on the first include line means it is ignored and is then generated by the rule preceding the second include line. On subsequent runs, if any of the source or header files previously identified has changed, the include file will be updated. There are other ways of updating the include file when headers change, but they involve recursive execution of *make*.
>
>
>         .POSIX:
>         .SUFFIXES: .c .d
>
>         OFILES = a.o b.o
>
>         pgm: $(OFILES)
>             c17 $(OFILES) -o pgm
>         a.o:
>             c17 -c a.c
>         b.o:
>             c17 -c b.c
>
>         -include $(OFILES:.o=.d)
>         .c.d:
>             +{ \
>               set -o pipefail; cfile=$<; ofile=$${cfile%.c}.o; \
>               printf '%s %s: %s ' "$$ofile" $@ $<; \
>               c17 -E $< | LC_ALL=C sed -n \
>                 '/^#[[:blank:]]*[[:digit:]]/s/.*"\([^"]*\.h\)".*/\1/p' | \
>                 LC_ALL=C sort -u | tr '\n' ' '; \
>               echo; \
>             } > $@
>         include $(OFILES:.o=.d)
>
>     This example does not cope with a header file being removed ([*make*](../utilities/make.html) will complain that it does not know how to make it), necessitating that **\*.d** be removed and the *make* run again. Alternatively, this can be handled by updating the commands which generate the **.d** file so that they add an empty target rule for each of its prerequisites.
>
> 5.  An example for making optimized **.o** files from **.c** files is:
>
>
>         .c.o:
>             c17 -c -O 1 $*.c
>
>     or:
>
>
>         .c.o:
>             c17 -c -O 1 $<
>
> 6.  The most common use of the archive interface follows. Here, it is assumed that the source files are all C-language source:
>
>
>         lib.a: lib.a(file1.o) .WAIT lib.a(file2.o) .WAIT lib.a(file3.o)
>             @echo lib.a is now up-to-date
>
>     The **.c.a** rule is used to make **file1.o**, **file2.o**, and **file3.o** and insert them into **lib.a**.
>
> 7.  The treatment of escaped \<newline\> characters throughout the makefile is historical practice. For example, the inference rule:
>
>
>         .c.o\
>         :
>
>     works, and the macro:
>
>
>         f=  bar baz\
>             biz
>         a:
>             echo ==$f==
>
>     echoes `"==bar baz biz=="`.
>
>     If \$? were:
>
>
>         /usr/include/stdio.h /usr/include/unistd.h foo.h
>
>     then \$(?D) would be:
>
>
>         /usr/include /usr/include .
>
>     and \$(?F) would be:
>
>
>         stdio.h unistd.h foo.h
>
> 8.  The contents of the built-in rules can be viewed by running:
>
>
>         make -p -f /dev/null 2>/dev/null
>
> 9.  With the following makefile, `make -j 10 all` may bring `one` and `two` up-to-date in parallel despite the **.WAIT** in the prerequisite list for `foo`. This is because the **.WAIT** does not stop *make* from recursively processing `bar` and its prerequisites in parallel. However, if only `foo` is specified (`make -j 10 foo`), *make* will wait for `one` to be brought up-to-date before bringing `two` up-to-date. Note also that the **.WAIT** does not create a prerequisite relationship between `one` and `two`, so `make -j 10 two` will not build `one`.
>
>
>         all: foo bar
>         foo: one .WAIT two
>         bar: one two
>         foo bar one two: ; @echo $@

#### <span id="tag_20_76_18"></span>RATIONALE

> The *make* utility described in this volume of POSIX.1-2024 is intended to provide the means for changing portable source code into executables that can be run on a POSIX.1-2024-conforming system. It reflects the most common features present in System V and BSD *make*s.
>
> Historically, the *make* utility has been an especially fertile ground for vendor and research organization-specific syntax modifications and extensions. Examples include:
>
> - Syntax supporting parallel execution (such as from various multi-processor vendors, GNU, and others)
>
> - Additional "operators" separating targets and their prerequisites (System V, BSD, and others)
>
> - Modifications of the meaning of internal macros when referencing libraries (BSD and others)
>
> - Using a single instance of the shell for all of the command lines of the target (BSD and others)
>
> - Allowing \<space\> characters as well as \<tab\> characters to delimit command lines (BSD)
>
> - Adding C preprocessor-style "include" and "ifdef" constructs (System V, GNU, BSD, and others)
>
> - Remote execution of command lines (Sprite and others)
>
> - Specifying additional special targets (BSD, System V, and most others)
>
> - Specifying an alternate shell to use to process commands.
>
> Additionally, many vendors and research organizations have rethought the basic concepts of *make*, creating vastly extended, as well as completely new, syntaxes. Each of these versions of *make* fulfills the needs of a different community of users; it is unreasonable for this volume of POSIX.1-2024 to require behavior that would be incompatible (and probably inferior) to historical practice for such a community.
>
> In similar circumstances, when the industry has enough sufficiently incompatible formats as to make them irreconcilable, this volume of POSIX.1-2024 has followed one or both of two courses of action. Commands have been renamed ([*cksum*](../utilities/cksum.html), [*echo*](../utilities/echo.html), and [*pax*](../utilities/pax.html)) and/or command line options have been provided to select the desired behavior ([*grep*](../utilities/grep.html), [*od*](../utilities/od.html), and [*pax*](../utilities/pax.html)).
>
> Because the syntax specified for the *make* utility was, by and large, a subset of the syntaxes accepted by almost all versions of *make* when the original IEEE Std 1003.2-1992 shell and utilities standard was being developed, it was decided that it would be counter-productive to change the name. And since the makefile itself is a basic unit of portability, it would not be completely effective to reserve a new option letter, such as *make* **-P**, to achieve the portable behavior. Therefore, the special target **.POSIX** was added to the makefile, allowing users to specify "standard" behavior. This special target does not preclude extensions in the *make* utility, nor does it preclude such extensions being used by the makefile specifying the target; it does, however, preclude any extensions from being applied that could alter the behavior of previously valid syntax; such extensions must be controlled via command line options or new special targets. It is incumbent upon portable makefiles to specify the **.POSIX** special target in order to guarantee that they are not affected by local extensions.
>
> The portable version of *make* described in this reference page is not intended to be the state-of-the-art software generation tool and, as such, some newer and more leading-edge features have not been included. An attempt has been made to describe the portable makefile in a manner that does not preclude such extensions as long as they do not disturb the portable behavior described here.
>
> When the **-n** option is specified, it is always added to *MAKEFLAGS .* This allows a recursive *make* **-n** *target* to be used to see all of the actions that would be taken to update *target*.
>
> The definition of *MAKEFLAGS* allows both the System V letter string and the BSD command line formats. The two formats are sufficiently different to allow implementations to support both without ambiguity.
>
> Early proposals stated that an "unquoted" \<number-sign\> was treated as the start of a comment. The *make* utility does not pay any attention to quotes. A \<number-sign\> starts a comment regardless of its surroundings.
>
> The text about "other implementation-defined pathnames may also be tried" in addition to **./makefile** and **./Makefile** is to allow such extensions as **SCCS/s.Makefile** and other variations. It was made an implementation-defined requirement (as opposed to unspecified behavior) to highlight surprising implementations that might select something unexpected like **/etc/Makefile**. XSI-conformant systems also try **./s.makefile**, **SCCS/s.makefile**, **./s.Makefile**, and **SCCS/s.Makefile**.
>
> The default rules are based on System V. The default **CC=** value is [*c17*](../utilities/c17.html) instead of *cc* because this volume of POSIX.1-2024 does not standardize the utility named *cc*. Thus, every conforming application would be required to define **CC=**[*c17*](../utilities/c17.html) to expect to run. There is no advantage conferred by the hope that the makefile might hit the "preferred" compiler because this cannot be guaranteed to work. Also, since the portable makescript can only use the [*c17*](../utilities/c17.html) options, no advantage is conferred in terms of what the script can do. It is a quality-of-implementation issue as to whether [*c17*](../utilities/c17.html) is as valuable as *cc*.
>
> Implementations are permitted to include any macro of their choosing in the default set. However, they are encouraged to keep such additions to a minimum in order to reduce the risk of name clashes with user macros.
>
> Implementations are encouraged to provide, as an extension, a command-line option that causes *make* to report attempts to expand (or append to) macros that do not exist. See APPLICATION USAGE for the intended use cases of such an option.
>
> The **-d** option to *make* is frequently used to produce debugging information, but is too implementation-defined to add to this volume of POSIX.1-2024.
>
> The **-p** option is not passed in *MAKEFLAGS* on most historical implementations and to change this would cause many implementations to break without sufficiently increased portability.
>
> Commands that begin with a \<plus-sign\> (`'+'`) are executed even if the **-n** option is present. Based on the GNU version of *make*, the behavior of **-n** when the \<plus-sign\> prefix is encountered has been extended to apply to **-q** and **-t** as well. The System V convention of forcing command execution with **-n** when the command line of a target expands the *MAKE* macro was not adopted in earlier versions of this standard, but it is now required because it has become widespread existing practice.
>
> The double \<colon\> in the target rule format is supported in BSD systems to allow more than one target line containing the same target name to have commands associated with it. Since this is not functionality described in the SVID or XPG3 it has been allowed as an extension, but not mandated.
>
> The default rules are provided with text specifying that the built-in rules shall be the same as if the listed set were used. The intent is that implementations should be able to use the rules without change, but will be allowed to alter them in ways that do not affect the primary behavior.
>
> One point of discussion was whether to drop the default rules list from this volume of POSIX.1-2024. They provide convenience, but do not enhance portability of applications. The prime benefit is in portability of users who wish to type *make* *command* and have the command build from a **command.c** file.
>
> The historical *MAKESHELL* feature, and related features provided by other *make* implementations, were omitted. In some implementations it is used to let a user override the shell to be used to run *make* commands. This was confusing; for a portable *make*, the shell should be chosen by the makefile writer. Further, a makefile writer cannot require an alternate shell to be used and still consider the makefile portable. While it would be possible to standardize a mechanism for specifying an alternate shell, existing implementations do not agree on such a mechanism, and makefile writers can already invoke an alternate shell by specifying the shell name in the rule for a target; for example:
>
>
>     python -c "foo"
>
> The *make* utilities in most historical implementations process the prerequisites of a target in left-to-right order, and the makefile format requires this. It supports the standard idiom used in many makefiles that produce [*yacc*](../utilities/yacc.html) programs; for example:
>
>
>     foo: y.tab.o lex.o main.o
>         $(CC) $(CFLAGS) -o $@ y.tab.o lex.o main.o
>
> In this example, if *make* chose any arbitrary order, the **lex.o** might not be made with the correct **y.tab.h**. Although there may be better ways to express this relationship, it is widely used historically. Implementations that desire to update prerequisites in parallel should require an explicit extension to *make* or the makefile format to accomplish it, as described previously.
>
> The algorithm for determining a new entry for target rules is partially unspecified. Some historical *make*s allow comment lines (including blank and empty lines) within the collection of commands marked by leading \<tab\> characters. A conforming makefile must ensure that each command starts with a \<tab\>, but implementations are free to ignore comments without triggering the start of a new entry.
>
> The ASYNCHRONOUS EVENTS section includes having SIGTERM and SIGHUP, along with the more traditional SIGINT and SIGQUIT, remove the current target unless directed not to do so. SIGTERM and SIGHUP were added to parallel other utilities that have historically cleaned up their work as a result of these signals. When *make* receives any signal other than SIGQUIT, it is required to resend itself the signal it received so that it exits with a status that reflects the signal. The results from SIGQUIT are partially unspecified because, on systems that create a file named **core** upon receipt of SIGQUIT, the **core** file from *make* would conflict with a **core** file from the command that was running when the SIGQUIT arrived. The main concern was to prevent damaged files from appearing up-to-date when *make* is rerun.
>
> The **.PRECIOUS** special target was extended to affect all targets globally (by specifying no prerequisites). The **.IGNORE** and **.SILENT** special targets were extended to allow prerequisites; it was judged to be more useful in some cases to be able to turn off errors or echoing for a list of targets than for the entire makefile. These extensions to *make* in System V were made to match historical practice from the BSD *make*.
>
> Macros are not exported to the environment of commands to be run. This was never the case in any historical *make* and would have serious consequences. The environment is the same as the environment to *make* except that *MAKEFLAGS* and macros defined on the *make* command line are added, and except that macros defined by the *MAKEFLAGS* environment variable and macros defined in the makefile(s) may update the value of an existing environment variable (other than *SHELL ).*
>
> Some implementations do not use [*system*()](../functions/system.html) for all command lines, as required by the portable makefile format; as a performance enhancement, they select lines without shell metacharacters for direct execution by [*execve*()](../functions/execve.html). There is no requirement that [*system*()](../functions/system.html) be used specifically, but merely that the same results be achieved. The metacharacters typically used to bypass the direct [*execve*()](../functions/execve.html) execution have been any of:
>
>
>     =  |  ^  (  )  ;  &  <  >  *  ?  [  ]  :  $  `  '  "  \  \n
>
> The default in some advanced versions of *make* is to group all the command lines for a target and execute them using a single shell invocation; the System V method is to pass each line individually to a separate shell. The single-shell method has the advantages in performance and the lack of a requirement for many continued lines. However, converting to this newer method has caused portability problems with many historical makefiles, so the behavior with the POSIX makefile is specified to be the same as that of System V. It is suggested that the special target **.ONESHELL** be used as an implementation extension to achieve the single-shell grouping for a target or group of targets.
>
> Novice users of *make* have had difficulty with the historical need to start commands with a \<tab\>. Since it is often difficult to discern differences between \<tab\> and \<space\> characters on terminals or printed listings, confusing bugs can arise. In early proposals, an attempt was made to correct this problem by allowing leading \<blank\> characters instead of \<tab\> characters. However, implementors reported many makefiles that failed in subtle ways following this change, and it is difficult to implement a *make* that unambiguously can differentiate between macro and command lines. There is extensive historical practice of allowing leading \<space\> characters before macro definitions. Forcing macro lines into column 1 would be a significant backwards-compatibility problem for some makefiles. Therefore, historical practice was restored.
>
> There is substantial variation in the handling of include lines by different implementations. However, there is enough commonality for the standard to be able to specify a minimum set of requirements that allow the feature to be used portably. Known variations have been explicitly called out as unspecified behavior in the description.
>
> The System V dynamic dependency feature was not included. It would support:
>
>
>     cat: $$@.c
>
> that would expand to;
>
>
>     cat: cat.c
>
> This feature exists only in the new version of System V *make* and, while useful, is not in wide usage. This means that macros are expanded twice for prerequisites: once at makefile parse time and once at target update time.
>
> Consideration was given to adding metarules to the POSIX *make*. This would make **%.o: %.c** the same as **.c.o:**. This is quite useful and available from some vendors, but it would cause too many changes to this *make* to support. It would have introduced rule chaining and new substitution rules. However, the rules for target names have been set to reserve the `'%'` and `'"'` characters. These are traditionally used to implement metarules and quoting of target names, respectively. Implementors are strongly encouraged to use these characters only for these purposes.
>
> A request was made to extend the suffix delimiter character from a \<period\> to any character. The metarules feature in newer *make*s solves this problem in a more general way. This volume of POSIX.1-2024 is staying with the more conservative historical definition.
>
> The standard output format for the **-p** option is not described because it is primarily a debugging option and because the format is not generally useful to programs. In historical implementations the output is not suitable for use in generating makefiles. The **-p** format has been variable across historical implementations. Therefore, the definition of **-p** was only to provide a consistently named option for obtaining *make* script debugging information.
>
> Some historical implementations have not cleared the suffix list with **-r**.
>
> Implementations should be aware that some historical applications have intermixed *target_name* and *macro*=*value* operands on the command line, expecting that all of the macros are processed before any of the targets are dealt with. Conforming applications do not do this, but some backwards-compatibility support may be warranted.
>
> Empty inference rules are specified with a \<semicolon\> command rather than omitting all commands, as described in an early proposal. The latter case has no traditional meaning and is reserved for implementation extensions, such as in GNU *make*.
>
> Earlier versions of this standard defined comment lines only as lines with `'#'` as the first character. Many places then talked about comments, blank lines, and empty lines; but some places inadvertently only mentioned comments when blank lines and empty lines had also been accepted in all known implementations. The standard now defines comment lines to be blank lines, empty lines, and lines starting with a `'#'` character and explicitly lists cases where blank lines and empty lines are not acceptable.
>
> On most historic systems, the *make* utility considered a target with a prerequisite that had an identical timestamp as up-to-date. One implementation of *make* treated it as out-of-date. Note that up-to-date and out-of-date are antonyms. The standard now allows either behavior, but implementations are encouraged to treat such targets as out-of-date. This is especially important on file systems where the timestamp resolution is the minimum (1 second) required by the standard. All implementations of *make* should make full use of the finest timestamp resolution available on the file systems holding targets and prerequisites to ensure that targets are up-to-date even for prerequisite files with timestamps that were updated within the same second. However, if the timestamp resolutions of the file systems containing a target and a prerequisite are different, the timestamp with the more precise resolution should be rounded down to the resolution of the less precise timestamp for the comparison.
>
> The traditional semantics of delayed-expansion macros have often been the source of subtle bugs for makefile writers not aware of those semantics. Furthermore, in implementations that support an extension of assigning the output of an arbitrary command to a macro definition, the use of delayed-expansion macros could result in an undesirable growth in execution time, as each use of the macro would re-run the arbitrary command. Historically, several implementations independently developed a form of immediate expansion, usually via the operator `":="`, so that execution of an arbitrary command happens once at the definition of the macro rather than each use of the macro; however, there are subtle differences in the expansion rules of those various implementations when the expanded value of *string2* contained a `'$'`. Other implementations used the operator `":="` for conditional expansion, altogether unrelated to immediate-expansion macro definition.
>
> The standard developers felt that immediate-expansion semantics were useful enough to standardize, but requiring the semantics of any one implementation of `":="` would cause confusion in makefiles written for other implementation semantics, necessitating a reader to determine if `.POSIX:` had been specified at the beginning of the file (or worse, at the beginning of some other file that then includes the fragment in question) to know which semantics would be in use. Therefore, the standard developers opted to require two new operators, `"::="` and `":::="`, with specific semantics; the `"::="` operator has semantics closest to the GNU *make* implementation of `":="`, where `'$'` characters occurring in the immediate expansion of *string2* are not further expanded in subsequent use of the macro, and the `":::="` operator has semantics closest to the BSD *make* and *smake* implementations of `":="`, where immediate expansion is performed when assigning to a delayed-expansion macro and `"$$"` is preserved. It was felt that other implementations could easily support the required semantics.
>
> Implementations that previously provided `":="` as an extension are encouraged to leave this extension intact, with no change in the implementation's particular semantics, to avoid breaking non-portable makefiles that had been targeting that particular implementation. A portable makefile, with `.POSIX:` specified at the beginning, should not use the `":="` operator.
>
> Traditionally, constructs such as
>
>
>     DIR: FORCE
>             (commands)
>     FORCE:
>
> were used to allow `make DIR` to always run `(commands)`; however, this depended on the user never creating a file named **FORCE**. The addition of the .B~.PHONY special target provides a more efficient manner of providing a target whose commands are always run, and where the user cannot create a file that influences the behavior in an unexpected manner.
>
> This standard allows two different methods of creating include files or bringing them up-to-date, reflecting established practice in SunPro *make* and GNU *make*. The former performs this action during parsing, before the include file is opened. The latter delays performing the action until after all makefiles have been read. Implementors who opt for the "delayed remaking" method should be aware of the following potential issues:
>
> - Diagnostic messages about missing include files must be deferred until the final exit status is known. Note that this is a conformance issue, not just a quality of implementation issue.
>
> - If the way *make* handles using updated include file contents is to start over after include files have been made up-to-date, it is possible for a poorly written makefile to cause *make* to enter a sequence of restarts where nothing changes each time, resulting in the sequence continuing indefinitely unless the situation is detected. Implementors are encouraged to include a mechanism for detecting and reporting this, rather than allowing *make* to consume an arbitrary amount of system resource until it is forcibly terminated.
>
> - If *make* uses this start-over method, makefile contents read from a pipe on standard input or from a FIFO must be copied to a temporary file, and when *make* starts over it must use this file instead.
>
> - If *make* starts over by executing itself using the *exec* family of functions, the need to replace `'-'` or the pathnames of FIFOs with the pathnames of temporary files can lead to the *exec* call failing with an \[E2BIG\] error if the original execution was close to the {ARG_MAX} limit. Although this is a quality of implementation issue, not a conformance issue (since the general rules for utility errors allow utilities to fail when they encounter a variety of internal errors - see [*1.4 Utility Description Defaults*](../utilities/V3_chap01.html#tag_18_04)), implementors are encouraged to explore ways to prevent it, such as passing information via a temporary file instead of on the command line when an \[E2BIG\] error has occurred. Another solution might be to jump (e.g. using [*siglongjmp*()](../functions/siglongjmp.html)) back to the start of *main*() as the way to start over. Making a recursive call to *main*() is not recommended, as that would run into the stack limit if sufficiently many restarts are needed.
>
> This standard specifies that a non-existent include file is first created if possible, and only if not possible can other directories be searched. Historical versions of GNU *make* first searched the include directories, then attempted to create the include file. This behavior was not considered suitable for standardization as it means writers of portable applications have to use absolute pathnames for all include files that need to be created via a rule (because they can never be sure what relative pathnames are safe to use, since a file with the same relative pathname might happen to exist in one of the searched directories when installing the application on a new system). Note, however, that this only applies to directories searched by default. If an application uses an extension to specify that one or more directories are searched, this standard does not place any constraints on when the specified directories are searched.
>
> This standard specifies a way for portable applications to request parallel updating of targets with commands by using the **-j** *maxjobs* option. This feature is described in terms of a token pool initially containing up to *maxjobs* - 1 tokens. Note that this is not intended to prescribe a particular implementation design; the usual "as if" rule applies.
>
> Implementations are permitted to silently limit the pool size for a few reasons, including:
>
> - Implementations that do not support parallelism can support the **-j** option by simply ignoring the option (other than passing it to sub-*make* invocations via the *MAKEFLAGS* environment variable). In effect, such an implementation silently restricts the size of the token pool to zero (and therefore need not create a token pool).
>
> - Some historical implementations dynamically limit the token pool size based on the current system load to avoid overloading the system.
>
> - Implementations may want to limit the token pool size based on the number of processors available.
>
> - Implementations may want to limit the token pool size based on resource limits.
>
> Limiting the pool size does not change the value of *maxjobs* that is passed to sub-*make* invocations via the *MAKEFLAGS* environment variable.
>
> When a different *maxjobs* value is passed to a sub-*make*, some historical *make* implementations created a separate pool of tokens while other historical *make* implementations continued to obtain tokens from the invoking *make* but limited the number of tokens held at a time to the new value of *maxjobs* - 1. Both behaviors are believed to have merit in different situations: the former gives a sub-*make* complete control the amount of parallelism, while the latter allows the user to control the overall system load. This standard permits either behavior.
>
> This standard calls for a token pool of size *maxjobs* - 1, and for removal from that pool only for the second and subsequent tasks in a set of parallel tasks. This design was chosen because this is effectively what existing implementations do, and also because the token consumed by a parallel task that invokes a sub-*make* is effectively lent to the sub-*make*. Lending the token to the sub-*make* has the following advantages:
>
> - It prevents the sub-*make* from being completely idle due to token starvation, allowing it to always make some progress regardless of how many tokens other sub-*make* invocations have consumed.
>
> - It prevents token pool exhaustion caused by a long chain of sub-*make* invocations. If the token consumed by the invoking rule was not effectively lent to the sub-*make*, then the pool would be exhausted by a chain of sub-*make* invocations that is *maxjobs* long. Such a chain would never accomplish any work, and would thus never complete.
>
> When a rule invokes multiple sub-*make* processes asynchronously (for example by using an asynchronous list in the shell), some implementations allow each sub-*make* to execute at least one rule even though this would cause the total number of parallel rule executions across all *make* instances to exceed *maxjobs* (after discounting the rules that execute sub-*make* processes). This behavior may not be ideal, but it is easier to implement and is unlikely to cause problems in practice because applications typically do not have any rules that invoke multiple sub-*make* processes asynchronously. For this reason the behavior is unspecified if a rule executes multiple sub-*make* processes asynchronously.
>
> When multiple sub-*make* processes are running in parallel there is no requirement placed on the ordering of output from these processes. Some implementations of *make* attempt to serialize output from each sub-*make*; others make no such attempt. If diagnostic messages from failed commands are intermixed, the usual way to deal with this is to repeat the *make* without **-j** (or with **-j** 1) so that intermixing will not occur.

#### <span id="tag_20_76_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> Some implementations of *make* include an *export* directive to add specified *make* variables to the environment. This may be considered for standardization in a future version.
>
> A future version of this standard may add a command-line option that causes *make* to report attempts to expand (or append to) macros that do not exist.
>
> A future version of this standard may require that a target with a prerequisite with an identical timestamp is considered out-of-date.

#### <span id="tag_20_76_20"></span>SEE ALSO

> [*2. Shell Command Language*](../utilities/V3_chap02.html#tag_19), [*ar*](../utilities/ar.html#), [*c17*](../utilities/c17.html#), [*get*](../utilities/get.html#), [*lex*](../utilities/lex.html#), [*sccs*](../utilities/sccs.html#), [*sh*](../utilities/sh.html#), [*yacc*](../utilities/yacc.html#)
>
> XBD [*6.1 Portable Character Set*](../basedefs/V1_chap06.html#tag_06_01), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*exec*](../functions/exec.html#tag_17_129), [*system*()](../functions/system.html#)

#### <span id="tag_20_76_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_76_22"></span>Issue 5

> The FUTURE DIRECTIONS section is added.

#### <span id="tag_20_76_23"></span>Issue 6

> This utility is marked as part of the Software Development Utilities option.
>
> The Open Group Corrigendum U029/1 is applied, correcting a typographical error in the SPECIAL TARGETS section.
>
> In the ENVIRONMENT VARIABLES section, the *PROJECTDIR* description is updated from "otherwise, the home directory of a user of that name is examined" to "otherwise, the value of *PROJECTDIR* is treated as a user name and that user's initial working directory is examined".
>
> It is specified whether the command line is related to the makefile or to the *make* command, and the macro processing rules are updated to align with the IEEE P1003.2b draft standard.
>
> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> PASC Interpretation 1003.2 \#193 is applied.

#### <span id="tag_20_76_24"></span>Issue 7

> SD5-XCU-ERN-6 is applied, clarifying that Guideline 9 of the Utility Syntax Guidelines does not apply.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> Include lines in makefiles are introduced.
>
> Austin Group Interpretation 1003.1-2001 \#131 is applied, changing the **Makefile Execution** section.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0121 \[257\] is applied.
>
> POSIX.1-2008, Technical Corrigendum 2, XCU/TC2-2008/0122 \[509\], XCU/TC2-2008/0123 \[584\], XCU/TC2-2008/0124 \[857\], XCU/TC2-2008/0125 \[505\], XCU/TC2-2008/0126 \[584\], XCU/TC2-2008/0127 \[505\], XCU/TC2-2008/0128 \[865\], XCU/TC2-2008/0129 \[693\], XCU/TC2-2008/0130 \[602\], XCU/TC2-2008/0131 \[848\], XCU/TC2-2008/0132 \[763\], XCU/TC2-2008/0133 \[857\], XCU/TC2-2008/0134 \[866\], XCU/TC2-2008/0135 \[525\], XCU/TC2-2008/0136 \[848\], XCU/TC2-2008/0137 \[769\], XCU/TC2-2008/0138 \[525\], XCU/TC2-2008/0139 \[769\], XCU/TC2-2008/0140 \[505\], XCU/TC2-2008/0141 \[693\], XCU/TC2-2008/0142 \[505\], XCU/TC2-2008/0143 \[857\], and XCU/TC2-2008/0144 \[693,865\] are applied.

#### <span id="tag_20_76_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defects 330, 1417, 1422, 1709, and 1710 are applied, adding new forms of macro assignment using the `"::="`, `"?="`, and `"+="` operators.
>
> Austin Group Defect 333 is applied, adding support for "silent includes" using **-include**.
>
> Austin Group Defects 336 and 1711 are applied, specifying the behavior when *string1* in a macro expansion contains a macro expansion.
>
> Austin Group Defect 337 is applied, adding a new form of macro assignment using the `"!="` operator.
>
> Austin Group Defects 373 and 1417 are applied, changing the set of characters that portable applications can use in macro names to the entire portable filename character set (thus adding \<hyphen-minus\> to the set that could previously be used).
>
> Austin Group Defects 514 and 1520 are applied, adding the \$+ and \$^ internal macros.
>
> Austin Group Defect 518 is applied, allowing multiple files to be specified on an **include** line.
>
> Austin Group Defects 519, 1712, and 1715 are applied, adding support for pattern macro expansions.
>
> Austin Group Defects 523, 1708, and 1749 are applied, adding the .B~.PHONY special target.
>
> Austin Group Defect 875 is applied, clarifying the requirements for inference rules.
>
> Austin Group Defect 1104 is applied, changing "**s2.a**" to "**.s2.a**".
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1141 is applied, changing "core files" to "a file named core".
>
> Austin Group Defect 1155 is applied, clarifying the handling of the *MAKE* macro.
>
> Austin Group Defect 1325 is applied, adding requirements relating to the creation of include files.
>
> Austin Group Defect 1330 is applied, removing obsolescent interfaces.
>
> Austin Group Defect 1419 is applied, updating the **.SCCS_GET** default rule.
>
> Austin Group Defect 1420 is applied, clarifying where internal macros can be used.
>
> Austin Group Defect 1421 is applied, changing the APPLICATION USAGE section.
>
> Austin Group Defects 1424, 1658, 1690, 1701, 1702, 1703, 1704, 1707, 1719, 1720, 1721, 1722, and 1750 are applied, making various minor editorial wording changes.
>
> Austin Group Defects 1436, 1437, 1652, 1660, 1661, and 1733 are applied, adding the **-j** *maxjobs* option and the **.NOTPARALLEL** and **.WAIT** special targets, and changing the **-n** option.
>
> Austin Group Defects 1471 and 1513 are applied, adding a new form of macro assignment using the `":::="` operator.
>
> Austin Group Defect 1479 is applied, clarifying the requirements for default rules and macro values.
>
> Austin Group Defect 1492 is applied, changing the EXIT STATUS section.
>
> Austin Group Defect 1505 is applied, clarifying the requirements for expansion of macros that do not exist.
>
> Austin Group Defect 1510 is applied, correcting a typographic error in the RATIONALE section.
>
> Austin Group Defect 1549 is applied, clarifying the requirements for an escaped \<newline\> in a command line.
>
> Austin Group Defect 1615 is applied, allowing target names to contain slashes and hyphens.
>
> Austin Group Defect 1626 is applied, adding the *CURDIR* macro.
>
> Austin Group Defect 1631 is applied, adding information about use of the **-j** option with the **.c.a** default rule to the APPLICATION USAGE and EXAMPLES sections.
>
> Austin Group Defect 1650 is applied, changing the few occurrences of "dependencies" to use the more common "prerequisites".
>
> Austin Group Defect 1653 is applied, clarifying the difference between how *MAKEFLAGS* is parsed compared to shell commands that use the *make* utility.
>
> Austin Group Defects 1654 and 1655 are applied, changing the APPLICATION USAGE section.
>
> Austin Group Defect 1656 is applied, changing the NAME section.
>
> Austin Group Defect 1657 is applied, moving some requirements unrelated to makefile syntax from the Makefile Syntax subsection to the beginning of the EXTENDED DESCRIPTION section.
>
> Austin Group Defect 1689 is applied, removing some redundant wording from the DESCRIPTION section.
>
> Austin Group Defect 1692 is applied, allowing *make*, when invoked with the **-q** or **-t** option, to execute command lines (without a \<plus-sign\> prefix) that expand the *MAKE* macro.
>
> Austin Group Defect 1693 is applied, changing "command lines" to "execution lines" in the description of the **-s** option.
>
> Austin Group Defect 1694 is applied, changing "in the order they appear" to "in the order specified" in the OPERANDS section.
>
> Austin Group Defect 1696 is applied, changing the STDOUT section.
>
> Austin Group Defect 1697 is applied, changing the RATIONALE and FUTURE DIRECTIONS sections.
>
> Austin Group Defect 1698 is applied, changing "of a target" to "of the target" in the EXTENDED DESCRIPTION section.
>
> Austin Group Defect 1699 is applied, addressing some inconsistencies in the use of the term "rules".
>
> Austin Group Defect 1706 is applied, removing a line from the format specified for target rules.
>
> Austin Group Defect 1714 is applied, changing "beginning of the line" to "beginning of the value".
>
> Austin Group Defect 1716 is applied, changing the typographic convention used for variable elements within target names, in particular the inference rule suffixes s1 and s2.
>
> Austin Group Defect 1723 is applied, adding historical context to a paragraph in the RATIONALE section.
>
> Austin Group Defect 1772 is applied, clarifying the ASYNCHRONOUS EVENTS section.

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
