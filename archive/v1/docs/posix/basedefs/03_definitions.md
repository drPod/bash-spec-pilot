The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_03"></span>3. Definitions

For the purposes of POSIX.1-2024, the following terms and definitions apply. The Authoritative Dictionary of IEEE Standards Terms, Seventh Edition should be referenced for terms not defined in this section.

**Note:**  
No shading to denote extensions or options occurs in this chapter. Where the terms and definitions given in this chapter are used elsewhere in text related to extensions and options, they are shaded as appropriate.

### <span id="tag_03_01"></span>3.1 Abortive Release

An abrupt termination of a network connection that may result in the loss of data.

### <span id="tag_03_02"></span>3.2 Absolute Pathname

A pathname beginning with a single or more than two \<slash\> characters; see also [3.254 Pathname](#tag_03_254) .

**Note:**  
Pathname Resolution is defined in detail in [*4.16 Pathname Resolution*](../basedefs/V1_chap04.html#tag_04_16) .

### <span id="tag_03_03"></span>3.3 Access Mode

A particular form of access permitted to a file.

### <span id="tag_03_04"></span>3.4 Additional File Access Control Mechanism

An implementation-defined mechanism that is layered upon the access control mechanisms defined here, but which do not grant permissions beyond those defined herein, although they may further restrict them.

**Note:**  
File Access Permissions are defined in detail in [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07).

### <span id="tag_03_05"></span>3.5 Address Space

The memory locations that can be referenced by a process or the threads of a process.

### <span id="tag_03_06"></span>3.6 Advisory Information

An interface that advises the implementation on (portable) application behavior so that it can optimize the system.

### <span id="tag_03_07"></span>3.7 Affirmative Response

An input string that matches one of the responses acceptable to the *LC_MESSAGES* category keyword **yesexpr**, matching an extended regular expression in the current locale.

**Note:**  
The *LC_MESSAGES* category is defined in detail in [*7.3.6 LC_MESSAGES*](../basedefs/V1_chap07.html#tag_07_03_06).

### <span id="tag_03_08"></span>3.8 Alert

To cause the user's terminal to give some audible or visual indication that an error or some other event has occurred. When the standard output is directed to a terminal device, the method for alerting the terminal user is unspecified. When the standard output is not directed to a terminal device, the alert is accomplished by writing the alert to standard output (unless the utility description indicates that the use of standard output produces undefined results in this case).

### <span id="tag_03_09"></span>3.9 Alert Character (\<alert\>)

A character that in the output stream should cause a terminal to alert its user via a visual or audible notification. It is the character designated by `'\a'` in the C language. It is unspecified whether this character is the exact sequence transmitted to an output device by the system to accomplish the alert function.

### <span id="tag_03_10"></span>3.10 Alias Name

In the shell command language, a word consisting solely of alphabetics and digits from the portable character set and any of the following characters: `'!'`, `'%'`, `','`, `'-'`, `'@'`, `'_'`.

Implementations may allow other characters within alias names as an extension.

**Note:**  
The Portable Character Set is defined in detail in [*6.1 Portable Character Set*](../basedefs/V1_chap06.html#tag_06_01).

### <span id="tag_03_11"></span>3.11 Alignment

A requirement that objects of a particular type be located on storage boundaries with addresses that are particular multiples of a byte address.

**Note:**  
See also the ISO C standard, Section 6.2.8.

### <span id="tag_03_12"></span>3.12 Alternate File Access Control Mechanism

An implementation-defined mechanism that is independent of the access control mechanisms defined herein, and which if enabled on a file may either restrict or extend the permissions of a given user. POSIX.1-2024 defines when such mechanisms can be enabled and when they are disabled.

**Note:**  
File Access Permissions are defined in detail in [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07).

### <span id="tag_03_13"></span>3.13 Alternate Signal Stack

Memory associated with a thread, established upon request by the implementation for a thread, separate from the thread signal stack, in which signal handlers responding to signals sent to that thread may be executed.

### <span id="tag_03_14"></span>3.14 Ancillary Data

Protocol-specific, local system-specific, or optional information. The information can be both local or end-to-end significant, header information, part of a data portion, protocol-specific, and implementation or system-specific.

### <span id="tag_03_15"></span>3.15 Angle Brackets

The characters `'<'` (left-angle-bracket) and `'>'` (right-angle-bracket). When used in the phrase "enclosed in angle brackets", the symbol `'<'` immediately precedes the object to be enclosed, and `'>'` immediately follows it. When describing these characters in the portable character set, the names \<less-than-sign\> and \<greater-than-sign\> are used.

### <span id="tag_03_16"></span>3.16 Anonymous Memory Object

An object that represents memory not associated with any other memory objects.

### <span id="tag_03_17"></span>3.17 Apostrophe Character (\<apostrophe\>)

The character designated by `'\''` in the C language, also known as the single-quote character.

### <span id="tag_03_18"></span>3.18 Application

A computer program that performs some desired function.

When the User Portability Utilities option is supported, requirements placed on applications relating to the use of standard utilities shall also apply to the actions of a user who is entering shell command language statements into an interactive shell.

### <span id="tag_03_19"></span>3.19 Application Address

Endpoint address of a specific application.

### <span id="tag_03_20"></span>3.20 Application Program Interface (API)

The definition of syntax and semantics for providing computer system services.

### <span id="tag_03_21"></span>3.21 Appropriate Privileges

An implementation-defined means of associating privileges with a process with regard to the function calls, function call options, and the commands that need special privileges. There may be zero or more such means. These means (or lack thereof) are described in the conformance document.

**Note:**  
Function calls are defined in the System Interfaces volume of POSIX.1-2024, and commands are defined in the Shell and Utilities volume of POSIX.1-2024.

### <span id="tag_03_22"></span>3.22 Argument

In the shell command language, a parameter passed to a utility as the equivalent of a single string in the *argv* array created by one of the *exec* functions. An argument is one of the options, option-arguments, or operands following the command name.

**Note:**  
The Utility Argument Syntax is defined in detail in [*12.1 Utility Argument Syntax*](../basedefs/V1_chap12.html#tag_12_01) and XCU [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04).

In the C language, an expression in a function call expression or a sequence of preprocessing tokens in a function-like macro invocation.

### <span id="tag_03_23"></span>3.23 Arm (a Timer)

To start a timer measuring the passage of time, enabling notifying a process when the specified time or time interval has passed.

### <span id="tag_03_24"></span>3.24 Asterisk Character (\<asterisk\>)

The character `'*'`.

### <span id="tag_03_25"></span>3.25 Async-Cancel-Safe Function

A function that may be safely invoked by an application while the asynchronous form of cancellation is enabled. No function is async-cancel-safe unless explicitly described as such.

### <span id="tag_03_26"></span>3.26 Asynchronous Events

Events that occur independently of the execution of the application.

### <span id="tag_03_27"></span>3.27 Asynchronous Input and Output

A functionality enhancement to allow an application process to queue data input and output commands with asynchronous notification of completion.

### <span id="tag_03_28"></span>3.28 Async-Signal-Safe Function

A function that can be called, without restriction, from signal-catching functions. Note that, although there is no restriction on the calls themselves, for certain functions there are restrictions on subsequent behavior after the function is called from a signal-catching function. No function is async-signal-safe unless explicitly described as such.

**Note:**  
Async-signal-safety is defined in detail in XSH [*2.4.3 Signal Actions*](../functions/V2_chap02.html#tag_16_04_03).

### <span id="tag_03_29"></span>3.29 Asynchronously-Generated Signal

A signal that is not attributable to a specific thread. Examples are signals sent via [*kill*()](../functions/kill.html), signals sent from the keyboard, and signals delivered to process groups. Being asynchronous is a property of how the signal was generated and not a property of the signal number. All signals may be generated asynchronously.

**Note:**  
The [*kill*()](../functions/kill.html) function is defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_30"></span>3.30 Asynchronous I/O Completion

For an asynchronous read or write operation, when a corresponding synchronous read or write would have completed and when any associated status fields have been updated.

### <span id="tag_03_31"></span>3.31 Asynchronous I/O Operation

An I/O operation that does not of itself cause the thread requesting the I/O to be blocked from further use of the processor.

This implies that the process and the I/O operation may be running concurrently.

### <span id="tag_03_32"></span>3.32 Atomic Operation

An operation that cannot be broken up into smaller parts that could be performed separately. An atomic operation is guaranteed to complete either fully or not at all. In the context of the functionality provided by the [*\<stdatomic.h\>*](../basedefs/stdatomic.h.html) header, there are different types of atomic operation that are defined in detail in [*4.15.1 Memory Ordering*](../basedefs/V1_chap04.html#tag_04_15_01).

### <span id="tag_03_33"></span>3.33 Authentication

The process of validating a user or process to verify that the user or process is not a counterfeit.

### <span id="tag_03_34"></span>3.34 Authorization

The process of verifying that a user or process has permission to use a resource in the manner requested.

To assure security, the user or process would also need to be authenticated before granting access.

### <span id="tag_03_35"></span>3.35 Background Job

In the context of the System Interfaces volume of POSIX.1-2024, a background process group (see [3.37 Background Process Group](#tag_03_37)).

In the context of the shell, a job that the shell is not waiting for before it executes further commands or, if interactive, prompts for further commands. A background job can be a job-control background job or a non-job-control background job. A job-control background job is a job that started execution (either in the background or the foreground) while job control was enabled and is currently in the background. A non-job-control background job is an asynchronous AND-OR list that started execution while job control was disabled and was assigned a job number. An implementation need not support non-job-control background jobs; that is, the shell may, but need not, assign job numbers to asynchronous AND-OR lists that start execution while job control is disabled.

**Note:**  
Asynchronous AND-OR lists are defined in detail in XCU [*2.9.3.1 Asynchronous AND-OR Lists*](../utilities/V3_chap02.html#tag_19_09_03_02).

<!-- -->

**Note:**  
See also [3.158 Foreground Job](#tag_03_158), [3.180 Job](#tag_03_180), [3.181 Job Control](#tag_03_181), and [3.362 Suspended Job](#tag_03_362).

### <span id="tag_03_36"></span>3.36 Background Process

A process that is a member of a background process group.

### <span id="tag_03_37"></span>3.37 Background Process Group

Any process group, other than a foreground process group, that is a member of a session that has established a connection with a controlling terminal.

**Note:**  
See also [3.35 Background Job](#tag_03_35).

### <span id="tag_03_38"></span>3.38 Backquote Character

The character `` '`' ``, also known as \<grave-accent\>.

### <span id="tag_03_39"></span>3.39 Backslash Character (\<backslash\>)

The character designated by `'\\'` in the C language, also known as reverse solidus.

### <span id="tag_03_40"></span>3.40 Backspace Character (\<backspace\>)

A character that, in the output stream, should cause printing (or displaying) to occur one column position previous to the position about to be printed. If the position about to be printed is at the beginning of the current line, the behavior is unspecified. It is the character designated by `'\b'` in the C language. It is unspecified whether this character is the exact sequence transmitted to an output device by the system to accomplish the backspace function. The backspace defined here is not necessarily the ERASE special character.

**Note:**  
Special Characters are defined in detail in [*11.1.9 Special Characters*](../basedefs/V1_chap11.html#tag_11_01_09).

### <span id="tag_03_41"></span>3.41 Barrier

A synchronization object that allows multiple threads to synchronize at a particular point in their execution.

### <span id="tag_03_42"></span>3.42 Basename

For pathnames containing at least one filename: the final, or only, filename in the pathname. For pathnames consisting only of \<slash\> characters: either `'/'` or `"//"` if the pathname consists of exactly two \<slash\> characters, and `'/'` otherwise.

### <span id="tag_03_43"></span>3.43 Basic Regular Expression (BRE)

A regular expression (see [3.308 Regular Expression](#tag_03_308)) used by the majority of utilities that select strings from a set of character strings.

**Note:**  
Basic Regular Expressions are described in detail in [*9.3 Basic Regular Expressions*](../basedefs/V1_chap09.html#tag_09_03).

### <span id="tag_03_44"></span>3.44 Bind

The process of assigning a network address to an endpoint.

### <span id="tag_03_45"></span>3.45 Blank Character (\<blank\>)

One of the characters that belong to the **blank** character class as defined via the *LC_CTYPE* category in the current locale. In the POSIX locale, a \<blank\> character is either a \<tab\> or a \<space\>.

### <span id="tag_03_46"></span>3.46 Blank Line

A line consisting solely of zero or more \<blank\> characters terminated by a \<newline\>; see also [3.120 Empty Line](#tag_03_120).

### <span id="tag_03_47"></span>3.47 Blocked Process (or Thread)

A process (or thread) that is waiting for some condition (other than the availability of a processor) to be satisfied before it can continue execution.

### <span id="tag_03_48"></span>3.48 Blocking

A property of an open file description that causes function calls associated with it to wait for the requested action to be performed before returning.

### <span id="tag_03_49"></span>3.49 Block-Mode Terminal

A terminal device operating in a mode incapable of the character-at-a-time input and output operations described by some of the standard utilities.

**Note:**  
Output Devices and Terminal Types are defined in detail in [*10.2 Output Devices and Terminal Types*](../basedefs/V1_chap10.html#tag_10_02).

### <span id="tag_03_50"></span>3.50 Block Special File

A file that refers to a device. A block special file is normally distinguished from a character special file by providing access to the device in a manner such that the hardware characteristics of the device are not visible.

### <span id="tag_03_51"></span>3.51 Braces

The characters `'{'` (left-curly-bracket) and `'}'` (right-curly-bracket). When used in the phrase "enclosed in (curly) braces" the symbol `'{'` immediately precedes the object to be enclosed, and `'}'` immediately follows it. When describing these characters in the portable character set, the names \<left-curly-bracket\> and \<left-brace\> are used for `'{'`, and \<right-curly-bracket\> and \<right-brace\> are used for `'}'`.

### <span id="tag_03_52"></span>3.52 Brackets

The characters `'['` (left-square-bracket) and `']'` (right-square-bracket). When used in the phrase "enclosed in (square) brackets" the symbol `'['` immediately precedes the object to be enclosed, and `']'` immediately follows it. When describing these characters in the portable character set, the names \<left-square-bracket\> and \<right-square-bracket\> are used.

### <span id="tag_03_53"></span>3.53 Broadcast

The transfer of data from one endpoint to several endpoints, as described in RFC 919 and RFC 922.

### <span id="tag_03_54"></span>3.54 Built-In Utility (or Built-In)

A utility implemented within a shell. There are two main types of built-in utilities: special built-ins and regular built-ins. Unless qualified, the term "built-in" includes both types. The utilities referred to as special built-ins have special qualities. Regular built-ins are not required to be actually built into the shell on the implementation, but they usually have special command-search qualities, or affect the current execution environment.

**Note:**  
Special Built-In Utilities are defined in detail in XCU [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15).

Regular Built-In Utilities are defined in detail in XCU [*1.6 Built-In Utilities*](../utilities/V3_chap01.html#tag_18_06).

### <span id="tag_03_55"></span>3.55 Byte

An individually addressable unit of data storage that is exactly an octet, used to store a character or a portion of a character; see also [3.58 Character](#tag_03_58). A byte is composed of a contiguous sequence of 8 bits. The least significant bit is called the "low-order" bit; the most significant is called the "high-order" bit.

**Note:**  
The definition of byte from the ISO C standard is broader than the above and might accommodate hardware architectures with different sized addressable units than octets.

### <span id="tag_03_56"></span>3.56 Byte Input/Output Functions

The functions that perform byte-oriented input from streams or byte-oriented output to streams: [*fgetc*()](../functions/fgetc.html), [*fgets*()](../functions/fgets.html), [*fprintf*()](../functions/fprintf.html), [*fputc*()](../functions/fputc.html), [*fputs*()](../functions/fputs.html), [*fread*()](../functions/fread.html), [*fscanf*()](../functions/fscanf.html), [*fwrite*()](../functions/fwrite.html), [*getc*()](../functions/getc.html), [*getchar*()](../functions/getchar.html), [*getdelim*()](../functions/getdelim.html), [*getline*()](../functions/getline.html), [*printf*()](../functions/printf.html), [*putc*()](../functions/putc.html), [*putchar*()](../functions/putchar.html), [*puts*()](../functions/puts.html), [*scanf*()](../functions/scanf.html), [*ungetc*()](../functions/ungetc.html), [*vfprintf*()](../functions/vfprintf.html), and [*vprintf*()](../functions/vprintf.html).

**Note:**  
Functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_57"></span>3.57 Carriage-Return Character (\<carriage-return\>)

A character that in the output stream indicates that printing should start at the beginning of the same physical line in which the carriage-return occurred. It is the character designated by `'\r'` in the C language. It is unspecified whether this character is the exact sequence transmitted to an output device by the system to accomplish the movement to the beginning of the line.

### <span id="tag_03_58"></span>3.58 Character

A sequence of one or more bytes representing a member of a character set.

**Note:**  
This term corresponds to the ISO C standard term multi-byte character, where a single-byte character is a special case of a multi-byte character. Unlike the usage in the ISO C standard, *character* here has no necessary relationship with storage space, and *byte* is used when storage space is discussed.

See the definition of the portable character set in [*6.1 Portable Character Set*](../basedefs/V1_chap06.html#tag_06_01) for a further explanation of the graphical representations of (abstract) characters, as opposed to character encodings.

### <span id="tag_03_59"></span>3.59 Character Array

An array of elements of type **char**.

### <span id="tag_03_60"></span>3.60 Character Class

A named set of characters sharing an attribute associated with the name of the class. The classes and the characters that they contain are dependent on the value of the *LC_CTYPE* category in the current locale.

**Note:**  
The *LC_CTYPE* category is defined in detail in [*7.3.1 LC_CTYPE*](../basedefs/V1_chap07.html#tag_07_03_01).

### <span id="tag_03_61"></span>3.61 Character Set

A finite set of different characters used for the representation, organization, or control of data.

### <span id="tag_03_62"></span>3.62 Character Special File

A file that refers to a device (such as a terminal device file) or that has special properties (such as **/dev/null**).

**Note:**  
The General Terminal Interface is defined in detail in [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).

### <span id="tag_03_63"></span>3.63 Character String

A contiguous sequence of characters terminated by and including the first null byte.

### <span id="tag_03_64"></span>3.64 Child Process

A new process created (by [*fork*()](../functions/fork.html), [*posix_spawn*()](../functions/posix_spawn.html), or [*posix_spawnp*()](../functions/posix_spawnp.html)) by a given process. A child process remains the child of the creating process as long as both processes continue to exist.

**Note:**  
The [*fork*()](../functions/fork.html), [*posix_spawn*()](../functions/posix_spawn.html), and [*posix_spawnp*()](../functions/posix_spawnp.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_65"></span>3.65 Circumflex Character (\<circumflex\>)

The character `'^'`.

### <span id="tag_03_66"></span>3.66 Clock

A software or hardware object that can be used to measure the apparent or actual passage of time.

The current value of the time measured by a clock can be queried and, possibly, set to a value within the legal range of the clock.

### <span id="tag_03_67"></span>3.67 Clock Jump

The difference between two successive distinct values of a clock, as observed from the application via one of the "get time" operations.

### <span id="tag_03_68"></span>3.68 Clock Tick

An interval of time; an implementation-defined number of these occur each second. Clock ticks are one of the units that may be used to express a value found in type **clock_t**.

### <span id="tag_03_69"></span>3.69 Code Block

In the context of the System Interfaces volume of POSIX.1-2024, a *block* as defined in the ISO C standard.

### <span id="tag_03_70"></span>3.70 Coded Character Set

A set of unambiguous rules that establishes a character set and the one-to-one relationship between each character of the set and its bit representation.

### <span id="tag_03_71"></span>3.71 Codeset

The result of applying rules that map a numeric code value to each element of a character set. An element of a character set may be related to more than one numeric code value but the reverse is not true. However, for state-dependent encodings the relationship between numeric code values and elements of a character set may be further controlled by state information. The character set may contain fewer elements than the total number of possible numeric code values; that is, some code values may be unassigned.

**Note:**  
Character Encoding is defined in detail in [*6.2 Character Encoding*](../basedefs/V1_chap06.html#tag_06_02) .

### <span id="tag_03_72"></span>3.72 Collating Element

The smallest entity used to determine the logical ordering of character or wide-character strings; see also [3.74 Collation Sequence](#tag_03_74). A collating element consists of either a single character, or two or more characters collating as a single entity. The value of the *LC_COLLATE* category in the current locale determines the current set of collating elements.

### <span id="tag_03_73"></span>3.73 Collation

The logical ordering of character or wide-character strings according to defined precedence rules. These rules identify a collation sequence between the collating elements, and such additional rules that can be used to order strings consisting of multiple collating elements.

### <span id="tag_03_74"></span>3.74 Collation Sequence

The relative order of collating elements as determined by the setting of the *LC_COLLATE* category in the current locale. The collation sequence is used for sorting and is determined from the collating weights assigned to each collating element. In the absence of weights, the collation sequence is the order in which collating elements are specified between **order_start** and **order_end** keywords in the *LC_COLLATE* category.

Multi-level sorting is accomplished by assigning elements one or more collation weights, up to the limit {COLL_WEIGHTS_MAX}. On each level, elements may be given the same weight (at the primary level, called an equivalence class; see also [3.126 Equivalence Class](#tag_03_126)) or be omitted from the sequence. Strings that collate equally using the first assigned weight (primary ordering) are then compared using the next assigned weight (secondary ordering), and so on.

**Note:**  
{COLL_WEIGHTS_MAX} is defined in detail in [*\<limits.h\>*](../basedefs/limits.h.html).

### <span id="tag_03_75"></span>3.75 Column Position

A unit of horizontal measure related to characters in a line.

It is assumed that each character in a character set has an intrinsic column width independent of any output device. Each printable character in the portable character set has a column width of one. The standard utilities, when used as described in POSIX.1-2024, assume that all characters have integral column widths. The column width of a character is not necessarily related to the internal representation of the character (numbers of bits or bytes).

The column position of a character in a line is defined as one plus the sum of the column widths of the preceding characters in the line. Column positions are numbered starting from 1.

### <span id="tag_03_76"></span>3.76 Command

A directive to the shell to perform a particular task.

**Note:**  
Shell Commands are defined in detail in XCU [*2.9 Shell Commands*](../utilities/V3_chap02.html#tag_19_09) .

### <span id="tag_03_77"></span>3.77 Command Language Interpreter

An interface that interprets sequences of text input as commands. It may operate on an input stream or it may interactively prompt and read commands from a terminal. It is possible for applications to invoke utilities through a number of interfaces, which are collectively considered to act as command interpreters. The most obvious of these are the [*sh*](../utilities/sh.html) utility and the [*system*()](../functions/system.html) function, although [*popen*()](../functions/popen.html) and the various forms of *exec* may also be considered to behave as interpreters.

**Note:**  
The [*sh*](../utilities/sh.html) utility is defined in detail in the Shell and Utilities volume of POSIX.1-2024.

The [*system*()](../functions/system.html), [*popen*()](../functions/popen.html), and *exec* functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_78"></span>3.78 Composite Graphic Symbol

A graphic symbol consisting of a combination of two or more other graphic symbols in a single character position, such as a diacritical mark and a base character.

### <span id="tag_03_79"></span>3.79 Condition Variable

A synchronization object which allows a thread to suspend execution, repeatedly, until some associated predicate becomes true. A thread whose execution is suspended on a condition variable is said to be blocked on the condition variable.

There are two types of condition variable: those of type **pthread_cond_t** which are initialized using [*pthread_cond_init*()](../functions/pthread_cond_init.html) and those of type **cnd_t** which are initialized using [*cnd_init*()](../functions/cnd_init.html). If an application attempts to use the two types interchangeably (that is, pass a condition variable of type **pthread_cond_t** to a function that takes a **cnd_t**, or vice versa), the behavior is undefined.

**Note:**  
The [*pthread_cond_init*()](../functions/pthread_cond_init.html) and [*cnd_init*()](../functions/cnd_init.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_80"></span>3.80 Connected Socket

A connection-mode socket for which a connection has been established, or a connectionless-mode socket for which a peer address has been set. See also [3.81 Connection](#tag_03_81), [3.82 Connection Mode](#tag_03_82), [3.83 Connectionless Mode](#tag_03_83), and [3.342 Socket](#tag_03_342).

### <span id="tag_03_81"></span>3.81 Connection

An association established between two or more endpoints for the transfer of data

### <span id="tag_03_82"></span>3.82 Connection Mode

The transfer of data in the context of a connection; see also [3.83 Connectionless Mode](#tag_03_83).

### <span id="tag_03_83"></span>3.83 Connectionless Mode

The transfer of data other than in the context of a connection; see also [3.82 Connection Mode](#tag_03_82) and [3.96 Datagram](#tag_03_96).

### <span id="tag_03_84"></span>3.84 Control Character

A character, other than a graphic character, that affects the recording, processing, transmission, or interpretation of text.

### <span id="tag_03_85"></span>3.85 Control Operator

In the shell command language, a token that performs a control function. It is one of the following symbols:


    &   &&   (   )   ;   ;;   ;&   newline   |   ||

The end-of-input indicator used internally by the shell is also considered a control operator.

**Note:**  
Token Recognition is defined in detail in XCU [*2.3 Token Recognition*](../utilities/V3_chap02.html#tag_19_03) .

### <span id="tag_03_86"></span>3.86 Controlling Process

The session leader that established the connection to the controlling terminal. If the terminal subsequently ceases to be a controlling terminal for this session, the session leader ceases to be the controlling process.

### <span id="tag_03_87"></span>3.87 Controlling Terminal

A terminal that is associated with a session. Each session may have at most one controlling terminal associated with it, and a controlling terminal is associated with exactly one session. Certain input sequences from the controlling terminal cause signals to be sent to all processes in the foreground process group associated with the controlling terminal.

**Note:**  
The General Terminal Interface is defined in detail in [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).

### <span id="tag_03_88"></span>3.88 Conversion Descriptor

A per-process unique value used to identify an open codeset conversion.

### <span id="tag_03_89"></span>3.89 Core Image

An unspecified object of unspecified format that may be generated when a process terminates abnormally.

### <span id="tag_03_90"></span>3.90 CPU Time (Execution Time)

The time spent executing a process or thread, including the time spent executing system services on behalf of that process or thread. The value of the CPU-time clock for a process is implementation-defined. With this definition the sum of all the execution times of all the threads in a process might not equal the process execution time, even in a single-threaded process, because implementations may differ in how they account for time during context switches or for other reasons.

### <span id="tag_03_91"></span>3.91 CPU-Time Clock

A clock that measures the execution time of a particular process or thread.

### <span id="tag_03_92"></span>3.92 CPU-Time Timer

A timer attached to a CPU-time clock.

### <span id="tag_03_93"></span>3.93 Current Job

In the context of job control, the job that will be used as the default for the [*fg*](../utilities/fg.html) or [*bg*](../utilities/bg.html) utilities. There is at most one current job; see also [3.182 Job ID](#tag_03_182).

### <span id="tag_03_94"></span>3.94 Current Working Directory

See *Working Directory* in [3.421 Working Directory (or Current Working Directory)](#tag_03_421).

### <span id="tag_03_95"></span>3.95 Cursor Position

The line and column position on the screen denoted by the terminal's cursor.

### <span id="tag_03_96"></span>3.96 Datagram

A unit of data transferred from one endpoint to another in connectionless mode service.

### <span id="tag_03_97"></span>3.97 Data Race

A situation in which there are two conflicting actions in different threads, at least one of which is not atomic, and neither "happens before" the other, where the "happens before" relation is defined formally in [*4.15.1 Memory Ordering*](../basedefs/V1_chap04.html#tag_04_15_01).

### <span id="tag_03_98"></span>3.98 Data Segment

Memory associated with a process, that can contain dynamically allocated data.

### <span id="tag_03_99"></span>3.99 Decimal-Point Character

See *Radix Character* in [3.294 Radix Character (or Decimal-Point Character)](#tag_03_294).

### <span id="tag_03_100"></span>3.100 Declaration Utility

A utility which can take arguments that cause variable assignments (of the form *varname*=*value*) which will persist in the current shell environment. When the shell recognizes a declaration utility as the command name, subsequent arguments that would be a valid variable assignment in isolation are subject to different expansion rules (field splitting and pathname expansion are suppressed, and tilde expansion occurs after the \<equals-sign\> and any unquoted \<colon\>). Arguments which are not a valid variable assignment in isolation are processed according to normal argument expansion rules.

The following standard utilities are declaration utilities: [*export*](../utilities/export.html), [*readonly*](../utilities/readonly.html), and, under certain conditions, [*command*](../utilities/command.html). An implementation may provide other declaration utilities.

### <span id="tag_03_101"></span>3.101 Device

A computer peripheral or an object that appears to the application as such.

### <span id="tag_03_102"></span>3.102 Device ID

A non-negative integer used to identify a device.

### <span id="tag_03_103"></span>3.103 Directory

A file that contains directory entries. No two directory entries in the same directory have the same name.

### <span id="tag_03_104"></span>3.104 Directory Entry (or Hard Link)

An object that associates a filename with a file. Several directory entries can associate names with the same file.

### <span id="tag_03_105"></span>3.105 Directory Stream

A sequence of all the directory entries in a particular directory. An open directory stream may be implemented using a file descriptor.

### <span id="tag_03_106"></span>3.106 Disarm (a Timer)

To stop a timer from measuring the passage of time, disabling any future process notifications (until the timer is armed again).

### <span id="tag_03_107"></span>3.107 Display

To output to the user's terminal. If the output is not directed to a terminal, the results are undefined.

### <span id="tag_03_108"></span>3.108 Display Line

A line of text on a physical device or an emulation thereof. Such a line has a maximum number of characters which can be presented.

**Note:**  
This may also be written as "line on the display".

### <span id="tag_03_109"></span>3.109 Dollar-Sign Character (\<dollar-sign\>)

The character `'$'`.

### <span id="tag_03_110"></span>3.110 Dot

In the context of naming files, the filename consisting of a single \<period\> character (`'.'`).

**Note:**  
In the context of shell special built-in utilities, see [*dot*](../utilities/V3_chap02.html#dot) in XCU [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15).

Pathname Resolution is defined in detail in [*4.16 Pathname Resolution*](../basedefs/V1_chap04.html#tag_04_16) .

### <span id="tag_03_111"></span>3.111 Dot-Dot

The filename consisting solely of two \<period\> characters (`".."`).

**Note:**  
Pathname Resolution is defined in detail in [*4.16 Pathname Resolution*](../basedefs/V1_chap04.html#tag_04_16) .

### <span id="tag_03_112"></span>3.112 Dot-Po File

See *Portable Messages Object Source File* in [3.266 Portable Messages Object Source File (or Dot-Po File)](#tag_03_266).

### <span id="tag_03_113"></span>3.113 Double-Quote Character

The character `'"'` , also known as \<quotation-mark\>.

**Note:**  
The "double" adjective in this term refers to the two strokes in the character glyph. POSIX.1-2024 never uses the term "double-quote" to refer to two apostrophes or quotation-marks.

### <span id="tag_03_114"></span>3.114 Downshifting

The conversion of an uppercase character that has a single-character lowercase representation into this lowercase representation.

### <span id="tag_03_115"></span>3.115 Driver

A module that controls data transferred to and received from devices.

**Note:**  
Drivers are traditionally written to be a part of the system implementation, although they are frequently written separately from the writing of the implementation. A driver may contain processor-specific code, and therefore be non-portable.

### <span id="tag_03_116"></span>3.116 Effective Group ID

An attribute of a process that is used in determining various permissions, including file access permissions; see also [3.165 Group ID](#tag_03_165).

### <span id="tag_03_117"></span>3.117 Effective User ID

An attribute of a process that is used in determining various permissions, including file access permissions; see also [3.408 User ID](#tag_03_408).

### <span id="tag_03_118"></span>3.118 Eight-Bit Transparency

The ability of a software component to process 8-bit characters without modifying or utilizing any part of the character in a way that is inconsistent with the rules of the current coded character set.

### <span id="tag_03_119"></span>3.119 Empty Directory

A directory that contains, at most, directory entries for dot and dot-dot, and has exactly one hard link to it other than its own dot entry (if one exists), in dot-dot. No other hard links to the directory can exist. It is unspecified whether an implementation can ever consider the root directory to be empty.

### <span id="tag_03_120"></span>3.120 Empty Line

A line consisting of only a \<newline\>; see also [3.46 Blank Line](#tag_03_46).

### <span id="tag_03_121"></span>3.121 Empty String (or Null String)

A string whose first byte is a null byte.

### <span id="tag_03_122"></span>3.122 Empty Wide-Character String

A wide-character string whose first element is a null wide-character code.

### <span id="tag_03_123"></span>3.123 Encoding Rule

The rules used to convert between wide-character codes and multi-byte character codes.

**Note:**  
Stream Orientation and Encoding Rules are defined in detail in XSH [*2.5.2 Stream Orientation and Encoding Rules*](../functions/V2_chap02.html#tag_16_05_02).

### <span id="tag_03_124"></span>3.124 Entire Regular Expression

The concatenated set of one or more basic regular expressions or extended regular expressions that make up the pattern specified for string selection.

**Note:**  
Regular Expressions are defined in detail in [*9. Regular Expressions*](../basedefs/V1_chap09.html#tag_09) .

### <span id="tag_03_125"></span>3.125 Epoch

The time zero hours, zero minutes, zero seconds, on January 1, 1970 Coordinated Universal Time (UTC).

**Note:**  
See also *Seconds Since the Epoch* defined in [*4.19 Seconds Since the Epoch*](../basedefs/V1_chap04.html#tag_04_19).

### <span id="tag_03_126"></span>3.126 Equivalence Class

A set of collating elements with the same primary collation weight.

Elements in an equivalence class are typically elements that naturally group together, such as all accented letters based on the same base letter.

The collation order of elements within an equivalence class is determined by the weights assigned on any subsequent levels after the primary weight.

### <span id="tag_03_127"></span>3.127 Era

A locale-specific method for counting and displaying years.

**Note:**  
The *LC_TIME* category is defined in detail in [*7.3.5 LC_TIME*](../basedefs/V1_chap07.html#tag_07_03_05) .

### <span id="tag_03_128"></span>3.128 Event Management

The mechanism that enables applications to register for and be made aware of external events such as data becoming available for reading.

### <span id="tag_03_129"></span>3.129 Executable File

A regular file acceptable as a new process image file by the equivalent of the *exec* family of functions, and thus usable as one form of a utility. The standard utilities described as compilers can produce executable files, but other unspecified methods of producing executable files may also be provided. The internal format of an executable file is unspecified, but a conforming application cannot assume an executable file is a text file.

### <span id="tag_03_130"></span>3.130 Execute

To perform command search and execution actions, as defined in the Shell and Utilities volume of POSIX.1-2024; see also [3.179 Invoke](#tag_03_179).

**Note:**  
Command Search and Execution is defined in detail in XCU [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04).

### <span id="tag_03_131"></span>3.131 Execution Time

See *CPU Time* in [3.90 CPU Time (Execution Time)](#tag_03_90).

### <span id="tag_03_132"></span>3.132 Execution Time Monitoring

A set of execution time monitoring primitives that allow online measuring of thread and process execution times.

### <span id="tag_03_133"></span>3.133 Expand

In the shell command language, when not qualified, the act of applying word expansions.

**Note:**  
Word Expansions are defined in detail in XCU [*2.6 Word Expansions*](../utilities/V3_chap02.html#tag_19_06) .

### <span id="tag_03_134"></span>3.134 Extended Regular Expression (ERE)

A regular expression (see also [3.308 Regular Expression](#tag_03_308)) that is an alternative to the Basic Regular Expression using a more extensive syntax, occasionally used by some utilities.

**Note:**  
Extended Regular Expressions are described in detail in [*9.4 Extended Regular Expressions*](../basedefs/V1_chap09.html#tag_09_04).

### <span id="tag_03_135"></span>3.135 Extended Security Controls

Implementation-defined security controls allowed by the file access permission and appropriate privileges (see also [3.21 Appropriate Privileges](#tag_03_21)) mechanisms, through which an implementation can support different security policies from those described in POSIX.1-2024.

**Note:**  
See also *Extended Security Controls* defined in [*4.6 Extended Security Controls*](../basedefs/V1_chap04.html#tag_04_06).

File Access Permissions are defined in detail in [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07).

### <span id="tag_03_136"></span>3.136 Feature Test Macro

A macro used to determine whether a particular set of features is included from a header.

**Note:**  
See also XSH [*2.2 The Compilation Environment*](../functions/V2_chap02.html#tag_16_02).

### <span id="tag_03_137"></span>3.137 Field

In the shell command language, a unit of text that is the result of parameter expansion, arithmetic expansion, command substitution, or field splitting. During command processing, the resulting fields are used as the command name and its arguments.

**Note:**  
Parameter Expansion is defined in detail in XCU [*2.6.2 Parameter Expansion*](../utilities/V3_chap02.html#tag_19_06_02).

Arithmetic Expansion is defined in detail in XCU [*2.6.4 Arithmetic Expansion*](../utilities/V3_chap02.html#tag_19_06_04).

Command Substitution is defined in detail in XCU [*2.6.3 Command Substitution*](../utilities/V3_chap02.html#tag_19_06_03).

Field Splitting is defined in detail in XCU [*2.6.5 Field Splitting*](../utilities/V3_chap02.html#tag_19_06_05) .

For further information on command processing, see XCU [*2.9.1 Simple Commands*](../utilities/V3_chap02.html#tag_19_09_01).

### <span id="tag_03_138"></span>3.138 FIFO Special File (or FIFO)

A type of file with the property that data written to such a file is read on a first-in-first-out basis.

**Note:**  
Other characteristics of FIFOs are described in the System Interfaces volume of POSIX.1-2024, [*lseek*()](../functions/lseek.html), [*open*()](../functions/open.html), [*read*()](../functions/read.html), and [*write*()](../functions/write.html).

### <span id="tag_03_139"></span>3.139 File

An object that can be written to, or read from, or both. A file has certain attributes, including access permissions and type. File types include regular file, character special file, block special file, FIFO special file, symbolic link, socket, and directory. Other types of files may be supported by the implementation.

### <span id="tag_03_140"></span>3.140 File Description

See *Open File Description* in [3.241 Open File Description](#tag_03_241).

### <span id="tag_03_141"></span>3.141 File Descriptor

A per-process unique, non-negative integer used to identify an open file for the purpose of file access. The values 0, 1, and 2 have special meaning and conventional uses, and are referred to as *standard input*, *standard output*, and *standard error*, respectively. Programs usually take their input from standard input, and write output on standard output. Diagnostic messages are usually written on standard error. The value of a newly-created file descriptor is from zero to {OPEN_MAX}-1. A file descriptor can have a value greater than or equal to {OPEN_MAX} if the value of {OPEN_MAX} has decreased (see [*sysconf*()](../functions/sysconf.html#)) since the file descriptor was opened. File descriptors may also be used to implement message catalog descriptors and directory streams; see also [3.241 Open File Description](#tag_03_241).

**Note:**  
{OPEN_MAX} is defined in detail in [*\<limits.h\>*](../basedefs/limits.h.html).

### <span id="tag_03_142"></span>3.142 File Group Class

The property of a file indicating access permissions for a process related to the group identification of a process. A process is in the file group class of a file if the process is not in the file owner class and if the effective group ID or one of the supplementary group IDs of the process matches the group ID associated with the file. Other members of the class may be implementation-defined.

### <span id="tag_03_143"></span>3.143 File Lock

Any advisory lock, including a record lock (see [3.302 Record Lock](#tag_03_302)), obtained on a file for the purpose of coordinating transactions among cooperating processes accessing the same file with the same lock type. See also [3.237 OFD-Owned File Lock](#tag_03_237) and [3.289 Process-Owned File Lock](#tag_03_289).

**Note:**  
All file locks created by interfaces defined in this standard are record locks; however, implementations commonly also support a file lock extension interface named *flock*(), which creates non-record locks (that is, a file lock that can only be held on the whole file).

<!-- -->

**Note:**  
Advisory locks do not prevent a process with sufficient access permissions from modifying the file without taking locks.

### <span id="tag_03_144"></span>3.144 File Mode

An object containing the file mode bits and some information about the file type of a file.

**Note:**  
File mode bits and file types are defined in detail in [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html) .

### <span id="tag_03_145"></span>3.145 File Mode Bits

A file's file permission bits, set-user-ID-on-execution bit (S_ISUID), set-group-ID-on-execution bit (S_ISGID), and, on directories, the restricted deletion flag bit (S_ISVTX).

**Note:**  
File Mode Bits are defined in detail in [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html).

### <span id="tag_03_146"></span>3.146 Filename

A sequence of bytes consisting of 1 to {NAME_MAX} bytes used to name a file. The bytes composing the name shall not contain the \<NUL\> or \<slash\> characters. In the context of a pathname, each filename shall be followed by a \<slash\> or a \<NUL\> character; elsewhere, a filename followed by a \<NUL\> character forms a string (but not necessarily a character string). The filenames **dot** and **dot-dot** have special meaning. A filename is sometimes referred to as a "pathname component". See also [3.254 Pathname](#tag_03_254).

**Note:**  
Pathname Resolution is defined in detail in [*4.16 Pathname Resolution*](../basedefs/V1_chap04.html#tag_04_16) .

### <span id="tag_03_147"></span>3.147 Filename String

A string consisting of a filename followed by a \<NUL\> character.

### <span id="tag_03_148"></span>3.148 File Offset

The byte position in the file where the next I/O operation begins. Each open file description associated with a regular file, block special file, or directory has a file offset. A character special file that does not refer to a terminal device may have a file offset. There is no file offset specified for a pipe or FIFO.

### <span id="tag_03_149"></span>3.149 File Other Class

The property of a file indicating access permissions for a process related to the user and group identification of a process. A process is in the file other class of a file if the process is not in the file owner class or file group class.

### <span id="tag_03_150"></span>3.150 File Owner Class

The property of a file indicating access permissions for a process related to the user identification of a process. A process is in the file owner class of a file if the effective user ID of the process matches the user ID of the file.

### <span id="tag_03_151"></span>3.151 File Permission Bits

Information about a file that is used, along with other information, to determine whether a process has read, write, or execute/search permission to a file. The bits are divided into three parts: owner, group, and other. Each part is used with the corresponding file class of processes. These bits are contained in the file mode.

**Note:**  
File modes are defined in detail in [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html).

File Access Permissions are defined in detail in [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07).

### <span id="tag_03_152"></span>3.152 File Serial Number

A per-file system unique identifier for a file.

### <span id="tag_03_153"></span>3.153 File System

A collection of files and certain of their attributes. It provides a name space for file serial numbers referring to those files.

### <span id="tag_03_154"></span>3.154 File Type

See *File* in [3.139 File](#tag_03_139).

### <span id="tag_03_155"></span>3.155 Filter

A command whose operation consists of reading data from standard input or a list of input files and writing data to standard output. Typically, its function is to perform some transformation on the data stream.

### <span id="tag_03_156"></span>3.156 First Open (of a File)

When a process opens a file that is not currently an open file within any process.

### <span id="tag_03_157"></span>3.157 Flow Control

The mechanism employed by a communications provider that constrains a sending entity to wait until the receiving entities can safely receive additional data without loss.

### <span id="tag_03_158"></span>3.158 Foreground Job

In the context of the System Interfaces volume of POSIX.1-2024, a foreground process group (see [3.160 Foreground Process Group](#tag_03_160)).

In the context of the shell, a job that the shell is waiting for before it executes further commands or, if interactive, prompts for further commands.

**Note:**  
See also [3.35 Background Job](#tag_03_35), [3.180 Job](#tag_03_180), and [3.362 Suspended Job](#tag_03_362).

### <span id="tag_03_159"></span>3.159 Foreground Process

A process that is a member of a foreground process group.

### <span id="tag_03_160"></span>3.160 Foreground Process Group

A process group whose member processes have certain privileges, denied to processes in background process groups, when accessing their controlling terminal. Each session that has established a connection with a controlling terminal has at most one process group of the session as the foreground process group of that controlling terminal.

**Note:**  
The General Terminal Interface is defined in detail in [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).

<!-- -->

**Note:**  
See also [3.158 Foreground Job](#tag_03_158).

### <span id="tag_03_161"></span>3.161 Foreground Process Group ID

The process group ID of the foreground process group.

### <span id="tag_03_162"></span>3.162 Form-Feed Character (\<form-feed\>)

A character that in the output stream indicates that printing should start on the next page of an output device. It is the character designated by `'\f'` in the C language. If the form-feed is not the first character of an output line, the result is unspecified. It is unspecified whether this character is the exact sequence transmitted to an output device by the system to accomplish the movement to the next page.

### <span id="tag_03_163"></span>3.163 Graphic Character

A member of the **graph** character class of the current locale.

**Note:**  
The **graph** character class is defined in detail in [*7.3.1 LC_CTYPE*](../basedefs/V1_chap07.html#tag_07_03_01).

### <span id="tag_03_164"></span>3.164 Group Database

A system database that contains at least the following information for each group ID:

- Group name

- Numerical group ID

- List of users allowed in the group

The list of users allowed in the group is used by the [*newgrp*](../utilities/newgrp.html) utility.

**Note:**  
The [*newgrp*](../utilities/newgrp.html) utility is defined in detail in the Shell and Utilities volume of POSIX.1-2024.

### <span id="tag_03_165"></span>3.165 Group ID

A non-negative integer, which can be contained in an object of type **gid_t**, that is used to identify a group of system users. Each system user is a member of at least one group. When the identity of a group is associated with a process, a group ID value is referred to as a real group ID, an effective group ID, one of the supplementary group IDs, or a saved set-group-ID. The value (**gid_t**)-1 shall not be a valid group ID, but does have a defined use in some interfaces defined in this standard.

### <span id="tag_03_166"></span>3.166 Group Name

A string that is used to identify a group; see also [3.164 Group Database](#tag_03_164). To be portable across conforming systems, the value is composed of characters from the portable filename character set. The \<hyphen-minus\> should not be used as the first character of a portable group name.

### <span id="tag_03_167"></span>3.167 Hard Limit

A system resource limitation that may be reset to a lesser or greater limit by a privileged process. A non-privileged process is restricted to only lowering its hard limit.

### <span id="tag_03_168"></span>3.168 Hard Link

See Directory Entry in [3.104 Directory Entry (or Hard Link)](#tag_03_104). A file can have multiple hard links as a result of an execution of the [*ln*](../utilities/ln.html) utility (without the **-s** option) or the [*link*()](../functions/link.html) function. This term is contrasted against symbolic link; see also [3.364 Symbolic Link](#tag_03_364).

### <span id="tag_03_169"></span>3.169 Hole

A contiguous region of bytes within a file, all having the value of zero. Not all bytes with the value zero need belong to a hole; however, all seekable files shall have a virtual hole starting at the current size of the file. A hole is typically created via [*truncate*()](../functions/truncate.html), or if an [*lseek*()](../functions/lseek.html) call has been made to position beyond the end of a file and data subsequently written at that point, although it is up to the implementation to define when sparse files can be created and with what granularity for the size of holes.

### <span id="tag_03_170"></span>3.170 Home Directory

The directory specified by the *HOME* environment variable.

### <span id="tag_03_171"></span>3.171 Host Byte Order

The arrangement of bytes in any integer type when using a specific machine architecture.

**Note:**  
Two common methods of byte ordering are big-endian and little-endian. Big-endian is a format for storage of binary data in which the most significant byte is placed first, with the rest in descending order. Little-endian is a format for storage or transmission of binary data in which the least significant byte is placed first, with the rest in ascending order. See also [*4.13 Host and Network Byte Orders*](../basedefs/V1_chap04.html#tag_04_13).

### <span id="tag_03_172"></span>3.172 Incomplete Line

A sequence of one or more non-\<newline\> characters at the end of the file.

### <span id="tag_03_173"></span>3.173 Inf

A value representing +infinity or a value representing -infinity that can be stored in a floating type. Not all systems support the Inf values.

### <span id="tag_03_174"></span>3.174 Interactive Device

A terminal device.

**Note:**  
This definition is intended to align with the ISO C standard's use of "interactive device".

### <span id="tag_03_175"></span>3.175 Interactive Shell

A processing mode of the shell that is suitable for direct user interaction.

### <span id="tag_03_176"></span>3.176 Internationalization

The provision within a computer program of the capability of making itself adaptable to the requirements of different native languages, local customs, and coded character sets.

### <span id="tag_03_177"></span>3.177 Interprocess Communication

A functionality enhancement to add a high-performance, deterministic interprocess communication facility for local communication.

### <span id="tag_03_178"></span>3.178 Intrinsic Utility

A utility that is not subject to a *PATH* search during command search, usually implemented as a regular built-in utility.

**Note:**  
Intrinsic Utilities are defined in detail in XCU [*1.7 Intrinsic Utilities*](../utilities/V3_chap01.html#tag_18_07).

### <span id="tag_03_179"></span>3.179 Invoke

To perform command search and execution actions, except that searching for shell functions and special built-in utilities is suppressed; see also [3.130 Execute](#tag_03_130).

**Note:**  
Command Search and Execution is defined in detail in XCU [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04).

### <span id="tag_03_180"></span>3.180 Job

A background job, a foreground job, or a suspended job.

In the context of the shell, jobs are created when a list (see XCU [*2.9.3 Lists*](../utilities/V3_chap02.html#tag_19_09_03)) is executed while job control is enabled, and may be created when an asynchronous AND-OR list is executed while job control is disabled.

**Note:**  
Job control in the shell is defined in detail in XCU [*2.11 Job Control*](../utilities/V3_chap02.html#tag_19_11).

<!-- -->

**Note:**  
See also [3.35 Background Job](#tag_03_35), [3.158 Foreground Job](#tag_03_158), and [3.362 Suspended Job](#tag_03_362).

### <span id="tag_03_181"></span>3.181 Job Control

A facility that allows users selectively to stop (suspend) the execution of processes and continue (resume) their execution at a later point. The user typically employs this facility via the interactive interface jointly supplied by the terminal I/O driver and a command interpreter.

The term is also used in connection with system interfaces that can be used by a command interpreter to implement job control (see for example [*setpgid*()](../functions/setpgid.html#)).

**Note:**  
Job control in the shell is defined in detail in XCU [*2.11 Job Control*](../utilities/V3_chap02.html#tag_19_11).

### <span id="tag_03_182"></span>3.182 Job ID

A handle that is used to refer to a job. The job ID can be any of the forms shown in the following table:\

<span id="tagtcjh_1"></span> Table: Job ID Formats

| **Job ID** | **Meaning**                             |
|:-----------|:----------------------------------------|
| %%         | Current job.                            |
| %+         | Current job.                            |
| %-         | Previous job.                           |
| %*n*       | Job number *n*.                         |
| %*string*  | Job whose command begins with *string*. |
| %?*string* | Job whose command contains *string*.    |

### <span id="tag_03_183"></span>3.183 Joinable Thread

A thread that was created either using [*pthread_create*()](../functions/pthread_create.html) with the *detachstate* attribute not set to PTHREAD_CREATE_DETACHED or using [*thrd_create*()](../functions/thrd_create.html), and for which neither [*pthread_detach*()](../functions/pthread_detach.html) nor [*pthread_join*()](../functions/pthread_join.html) has been called and returned zero, and neither [*thrd_detach*()](../functions/thrd_detach.html) nor [*thrd_join*()](../functions/thrd_join.html) has been called and returned `thrd_success`.

**Note:**  
The [*pthread_attr_setdetachstate*()](../functions/pthread_attr_setdetachstate.html), [*pthread_create*()](../functions/pthread_create.html), [*pthread_detach*()](../functions/pthread_detach.html), [*pthread_join*()](../functions/pthread_join.html), [*thrd_create*()](../functions/thrd_create.html), [*thrd_detach*()](../functions/thrd_detach.html), and [*thrd_join*()](../functions/thrd_join.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_184"></span>3.184 Last Close (of a File)

When a process closes a file, resulting in the file not being an open file within any process.

### <span id="tag_03_185"></span>3.185 Line

A sequence of zero or more non-\<newline\> characters plus a terminating \<newline\> character.

### <span id="tag_03_186"></span>3.186 Linger

The period of time before terminating a connection, to allow outstanding data to be transferred.

### <span id="tag_03_187"></span>3.187 Link

In the context of the file hierarchy, either a hard link or a symbolic link.

In the context of the [*c17*](../utilities/c17.html) utility, the action performed by the link editor (or linker).

**Note:**  
The [*c17*](../utilities/c17.html) utility is defined in detail in the Shell and Utilities volume of POSIX.1-2024.

### <span id="tag_03_188"></span>3.188 Link Count

The number of directory entries that refer to a particular file.

### <span id="tag_03_189"></span>3.189 Live Process

An address space with one or more threads executing within that address space, and the required system resources for those threads.

**Note:**  
Many of the system resources defined by POSIX.1-2024 are shared among all of the threads within a process. These include the process ID, the parent process ID, process group ID, session membership, real, effective, and saved set-user-ID, real, effective, and saved set-group-ID, supplementary group IDs, current working directory, root directory, file mode creation mask, and file descriptors.

### <span id="tag_03_190"></span>3.190 Live Thread

A single flow of control within a process. Each thread has its own thread ID, scheduling priority and policy, *errno* value, floating point environment, thread-specific key/value bindings, and the required system resources to support a flow of control. Anything whose address can be determined by a thread, including but not limited to static variables, storage obtained via [*malloc*()](../functions/malloc.html), directly addressable storage obtained through implementation-defined functions, and automatic variables, are accessible to all live threads in the same process.

**Note:**  
The [*malloc*()](../functions/malloc.html) function is defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_191"></span>3.191 Local Customs

The conventions of a geographical area or territory for such things as date, time, and currency formats.

### <span id="tag_03_192"></span>3.192 Local Interprocess Communication (Local IPC)

The transfer of data between processes in the same system.

### <span id="tag_03_193"></span>3.193 Locale

The definition of the subset of a user's environment that depends on language and cultural conventions.

**Note:**  
Locales are defined in detail in [*7. Locale*](../basedefs/V1_chap07.html#tag_07).

### <span id="tag_03_194"></span>3.194 Localization

The process of establishing information within a computer system specific to the operation of particular native languages, local customs, and coded character sets.

### <span id="tag_03_195"></span>3.195 Lock-Free Operation

An operation that does not require the use of a lock such as a mutex in order to avoid data races.

### <span id="tag_03_196"></span>3.196 Login

The unspecified activity by which a user gains access to the system. Each login is associated with exactly one login name.

### <span id="tag_03_197"></span>3.197 Login Name

A user name that is associated with a login.

### <span id="tag_03_198"></span>3.198 Map

To create an association between a page-aligned range of the address space of a process and some memory object, such that a reference to an address in that range of the address space results in a reference to the associated memory object. The mapped memory object is not necessarily memory-resident.

### <span id="tag_03_199"></span>3.199 Matched

A state applying to a sequence of zero or more characters when the characters in the sequence correspond to a sequence of characters defined by a basic regular expression or extended regular expression pattern.

**Note:**  
Regular Expressions are defined in detail in [*9. Regular Expressions*](../basedefs/V1_chap09.html#tag_09) .

### <span id="tag_03_200"></span>3.200 Memory Mapped Files

A facility to allow applications to access files as part of the address space.

### <span id="tag_03_201"></span>3.201 Memory Object

One of:

- A file (see [3.139 File](#tag_03_139))
- An anonymous memory object (see [3.16 Anonymous Memory Object](#tag_03_16))
- A shared memory object (see [3.332 Shared Memory Object](#tag_03_332))
- A typed memory object (see [3.401 Typed Memory Object](#tag_03_401))

When used in conjunction with [*mmap*()](../functions/mmap.html), a memory object appears in the address space of the calling process.

**Note:**  
The [*mmap*()](../functions/mmap.html) function is defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_202"></span>3.202 Memory-Resident

The process of managing the implementation in such a way as to provide an upper bound on memory access times.

### <span id="tag_03_203"></span>3.203 Message

In the context of programmatic message passing, information that can be transferred between processes or threads by being added to and removed from a message queue. A message consists of a fixed-size message buffer.

### <span id="tag_03_204"></span>3.204 Message Catalog

In the context of providing natural language messages to the user, a file or storage area containing program messages, command prompts, and responses to prompts for a particular native language, territory, and codeset.

### <span id="tag_03_205"></span>3.205 Message Catalog Descriptor

In the context of providing natural language messages to the user, a per-process unique value used to identify an open message catalog. A message catalog descriptor may be implemented using a file descriptor.

### <span id="tag_03_206"></span>3.206 Message Queue

In the context of programmatic message passing, an object to which messages can be added and removed. Messages may be removed in the order in which they were added or in priority order.

### <span id="tag_03_207"></span>3.207 Messages Object

A file containing message identifiers and translations in an unspecified format. Used by the *gettext* family of functions and the [*gettext*](../utilities/gettext.html) and [*ngettext*](../utilities/ngettext.html) utilities for internationalization and localization of programs and scripts. Messages objects have the filename suffix **.mo**, and can be created by the [*msgfmt*](../utilities/msgfmt.html) utility.

See also [3.386 Text Domain](#tag_03_386).

### <span id="tag_03_208"></span>3.208 Mode

A collection of attributes that specifies a file's type and its access permissions.

**Note:**  
File Access Permissions are defined in detail in [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07).

### <span id="tag_03_209"></span>3.209 Monotonic Clock

A clock measuring real time, whose value cannot be set via [*clock_settime*()](../functions/clock_settime.html) and which cannot have negative clock jumps.

### <span id="tag_03_210"></span>3.210 Mount Point

Either the system root directory or a directory for which the *st_dev* field of structure **stat** differs from that of its parent directory.

**Note:**  
The **stat** structure is defined in detail in [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html).

### <span id="tag_03_211"></span>3.211 Multi-Character Collating Element

A sequence of two or more characters that collate as an entity. For example, in some coded character sets, an accented character is represented by a non-spacing accent, followed by the letter. Other examples are the Spanish elements *ch* and *ll*.

### <span id="tag_03_212"></span>3.212 Multi-Threaded Library

A library containing object files that were produced by compiling with [*c17*](../utilities/c17.html) using the flags output by [*getconf*](../utilities/getconf.html) POSIX_V8_THREADS_CFLAGS, or by compiling using a non-standard utility with equivalent flags, and which makes use of interfaces that are only made available by [*c17*](../utilities/c17.html) when the **-l pthread** option is used or makes use of SIGEV_THREAD notifications.

### <span id="tag_03_213"></span>3.213 Multi-Threaded Process

A process that contains more than one thread.

### <span id="tag_03_214"></span>3.214 Multi-Threaded Program

A program whose executable file was produced by compiling with [*c17*](../utilities/c17.html) using the flags output by [*getconf*](../utilities/getconf.html) POSIX_V8_THREADS_CFLAGS, and linking with [*c17*](../utilities/c17.html) using the flags output by [*getconf*](../utilities/getconf.html) POSIX_V8_THREADS_LDFLAGS and the **-l pthread** option, or by compiling and linking using a non-standard utility with equivalent flags. Execution of a multi-threaded program initially creates a single-threaded process; the process can create additional threads using [*pthread_create*()](../functions/pthread_create.html), [*thrd_create*()](../functions/thrd_create.html), or SIGEV_THREAD notifications.

### <span id="tag_03_215"></span>3.215 Mutex

A synchronization object used to allow multiple threads to serialize their access to shared data. The name derives from the capability it provides; namely, mutual-exclusion. The thread that has locked a mutex becomes its owner and remains the owner until that same thread unlocks the mutex.

There are two types of mutex: those of type **pthread_mutex_t** which are initialized using [*pthread_mutex_init*()](../functions/pthread_mutex_init.html) and those of type **mtx_t** which are initialized using [*mtx_init*()](../functions/mtx_init.html). If an application attempts to use the two types interchangeably (that is, pass a mutex of type **pthread_mutex_t** to a function that takes a **mtx_t**, or vice versa), the behavior is undefined.

**Note:**  
The [*pthread_mutex_init*()](../functions/pthread_mutex_init.html) and [*mtx_init*()](../functions/mtx_init.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_216"></span>3.216 Name

In the shell command language, a word consisting solely of underscores, digits, and alphabetics from the portable character set. The first character of a name is not a digit.

**Note:**  
The Portable Character Set is defined in detail in [*6.1 Portable Character Set*](../basedefs/V1_chap06.html#tag_06_01).

### <span id="tag_03_217"></span>3.217 NaN (Not a Number)

A set of values that may be stored in a floating type but that are neither Inf nor valid floating-point numbers. Not all systems support NaN values.

### <span id="tag_03_218"></span>3.218 Native Language

A computer user's spoken or written language, such as American English, British English, Danish, Dutch, French, German, Italian, Japanese, Norwegian, or Swedish.

### <span id="tag_03_219"></span>3.219 Negative

When describing a value (not a sign), less than zero. Note that in the phrase "negative zero" it describes a sign, and therefore negative zero (also represented as -0.0) is not a negative value.

### <span id="tag_03_220"></span>3.220 Negative Response

An input string that matches one of the responses acceptable to the *LC_MESSAGES* category keyword **noexpr**, matching an extended regular expression in the current locale.

**Note:**  
The *LC_MESSAGES* category is defined in detail in [*7.3.6 LC_MESSAGES*](../basedefs/V1_chap07.html#tag_07_03_06).

### <span id="tag_03_221"></span>3.221 Network

A collection of interconnected hosts.

**Note:**  
The term "network" in POSIX.1-2024 is used to refer to the network of hosts. The term "batch system" is used to refer to the network of batch servers.

### <span id="tag_03_222"></span>3.222 Network Address

A network-visible identifier used to designate specific endpoints in a network. Specific endpoints on host systems have addresses, and host systems may also have addresses.

### <span id="tag_03_223"></span>3.223 Network Byte Order

The way of representing any integer type such that, when transmitted over a network via a network endpoint, the **int** type is transmitted as an appropriate number of octets with the most significant octet first, followed by any other octets in descending order of significance.

**Note:**  
This order is more commonly known as big-endian ordering. See also [*4.13 Host and Network Byte Orders*](../basedefs/V1_chap04.html#tag_04_13).

### <span id="tag_03_224"></span>3.224 Newline Character (\<newline\>)

A character that in the output stream indicates that printing should start at the beginning of the next line. It is the character designated by `'\n'` in the C language. It is unspecified whether this character is the exact sequence transmitted to an output device by the system to accomplish the movement to the next line.

### <span id="tag_03_225"></span>3.225 Nice Value

A number used as advice to the system to alter process scheduling. Numerically smaller values give a process additional preference when scheduling a process to run. Numerically larger values reduce the preference and make a process less likely to run. Typically, a process with a smaller nice value runs to completion more quickly than an equivalent process with a higher nice value. The symbol {NZERO} specifies the default nice value of the system.

### <span id="tag_03_226"></span>3.226 Non-Blocking

A property of an open file description that causes function calls involving it to return without delay when it is detected that the requested action associated with the function call cannot be completed without unknown delay.

**Note:**  
The exact semantics are dependent on the type of file associated with the open file description. For data reads from devices such as ttys and FIFOs, this property causes the read to return immediately when no data was available. Similarly, for writes, it causes the call to return immediately when the thread would otherwise be delayed in the write operation; for example, because no space was available. For networking, it causes functions not to await protocol events (for example, acknowledgements) to occur. See also XSH [*2.10.7 Socket I/O Mode*](../functions/V2_chap02.html#tag_16_10_07).

### <span id="tag_03_227"></span>3.227 Non-Spacing Characters

A character, such as a character representing a diacritical mark in the ISO/IEC 6937:2001 standard coded graphic character set, which is used in combination with other characters to form composite graphic symbols.

### <span id="tag_03_228"></span>3.228 NUL

A character with all bits set to zero.

### <span id="tag_03_229"></span>3.229 Null Byte

A byte with all bits set to zero.

### <span id="tag_03_230"></span>3.230 Null Pointer

A pointer obtained by converting an integer constant expression with the value 0, or such an expression cast to type **void \***, to a pointer type; for example, (**char \***)0. The C language guarantees that a null pointer compares unequal to a pointer to any object or function, so it is used by many functions that return pointers to indicate an error. POSIX.1-2024 additionally guarantees that any pointer object whose representation has all bits set to zero, perhaps by [*memset*()](../functions/memset.html) to 0 or by [*calloc*()](../functions/calloc.html), is interpreted as a null pointer.

### <span id="tag_03_231"></span>3.231 Null String

See *Empty String* in [3.121 Empty String (or Null String)](#tag_03_121).

### <span id="tag_03_232"></span>3.232 Null Terminator

A term used for the null byte when used as a terminator for a string.

### <span id="tag_03_233"></span>3.233 Null Wide-Character Code

A wide-character code with all bits set to zero.

### <span id="tag_03_234"></span>3.234 Number-Sign Character (\<number-sign\>)

The character `'#'`, also known as hash sign.

### <span id="tag_03_235"></span>3.235 Object File

A regular file containing the output of a compiler, formatted as input to a linkage editor for linking with other object files into an executable form. The methods of linking are unspecified and may involve the dynamic linking of objects at runtime. The internal format of an object file is unspecified, but a conforming application cannot assume an object file is a text file.

### <span id="tag_03_236"></span>3.236 Octet

Unit of data representation that consists of eight contiguous bits.

### <span id="tag_03_237"></span>3.237 OFD-Owned File Lock

A record lock owned by an open file description. OFD-owned file locks are obtained through the use of [*fcntl*()](../functions/fcntl.html) with F_OFD_SETLK or F_OFD_SETLKW. Whenever a file descriptor associated with the owning open file description is inherited these locks remain in effect. OFD-owned file locks are automatically released on the last close of the open file description. These locks are only shared among file descriptors associated with the same open file description. Thus, a multi-threaded process can use multiple open file descriptions (such as by [*open*()](../functions/open.html)) to create independent OFD-owned locks that can then be used to coordinate access patterns to the same file, while multiple file descriptors associated with the same open file description (such as by [*dup*()](../functions/dup.html)) share lock actions among all other descriptors associated with the same open file description.

### <span id="tag_03_238"></span>3.238 Offset Maximum

An attribute of an open file description representing the largest value that can be used as a file offset.

### <span id="tag_03_239"></span>3.239 Opaque Address

An address such that the entity making use of it requires no details about its contents or format.

### <span id="tag_03_240"></span>3.240 Open File

A file that is currently associated with a file descriptor.

### <span id="tag_03_241"></span>3.241 Open File Description

A record of how a process or group of processes is accessing a file. Each file descriptor refers to exactly one open file description, but an open file description can be referred to by more than one file descriptor. The file offset, file status, and file access modes are attributes of an open file description.

### <span id="tag_03_242"></span>3.242 Operand

An argument to a command that is generally used as an object supplying information to a utility necessary to complete its processing. Operands generally follow the options in a command line.

**Note:**  
Utility Argument Syntax is defined in detail in [*12.1 Utility Argument Syntax*](../basedefs/V1_chap12.html#tag_12_01).

### <span id="tag_03_243"></span>3.243 Operator

In the shell command language, either a control operator or a redirection operator.

### <span id="tag_03_244"></span>3.244 Option

An argument to a command that is generally used to specify changes in the utility's default behavior.

**Note:**  
Utility Argument Syntax is defined in detail in [*12.1 Utility Argument Syntax*](../basedefs/V1_chap12.html#tag_12_01).

### <span id="tag_03_245"></span>3.245 Option-Argument

A parameter that follows certain options. In some cases an option-argument immediately follows the option character within the same argument string as the option; otherwise the option-argument is the next argument string.

**Note:**  
Utility Argument Syntax is defined in detail in [*12.1 Utility Argument Syntax*](../basedefs/V1_chap12.html#tag_12_01).

### <span id="tag_03_246"></span>3.246 Orientation

A stream has one of three orientations: unoriented, byte-oriented, or wide-oriented.

**Note:**  
For further information, see XSH [*2.5.2 Stream Orientation and Encoding Rules*](../functions/V2_chap02.html#tag_16_05_02).

### <span id="tag_03_247"></span>3.247 Orphaned Process Group

A process group in which the parent of every member is either itself a member of the group or is not a member of the group's session.

### <span id="tag_03_248"></span>3.248 Page

The granularity of process memory mapping or locking.

Physical memory and memory objects can be mapped into the address space of a process on page boundaries and in integral multiples of pages. Process address space can be locked into memory (made memory-resident) on page boundaries and in integral multiples of pages.

### <span id="tag_03_249"></span>3.249 Page Size

The size, in bytes, of the system unit of memory allocation, protection, and mapping. On systems that have segment rather than page-based memory architectures, the term "page" means a segment.

### <span id="tag_03_250"></span>3.250 Parameter

In the shell command language, an entity that stores values. There are three types of parameters: variables (named parameters), positional parameters, and special parameters. Parameter expansion is accomplished by introducing a parameter with the `'$'` character.

**Note:**  
See also XCU [*2.5 Parameters and Variables*](../utilities/V3_chap02.html#tag_19_05).

In the C language, an object declared as part of a function declaration or definition that acquires a value on entry to the function, or an identifier following the macro name in a function-like macro definition.

### <span id="tag_03_251"></span>3.251 Parent Directory

When discussing a given directory, the directory that both contains a directory entry for the given directory and is represented by the pathname dot-dot in the given directory.

When discussing other types of files, a directory containing a directory entry for the file under discussion.

This concept does not apply to dot and dot-dot.

### <span id="tag_03_252"></span>3.252 Parent Process

The process which created (or inherited) the process under discussion.

### <span id="tag_03_253"></span>3.253 Parent Process ID

An attribute of a new process identifying the parent of the process. The parent process ID of a process is the process ID of its creator, for the lifetime of the creator. After the creator's lifetime has ended, the parent process ID is the process ID of an implementation-defined system process.

### <span id="tag_03_254"></span>3.254 Pathname

A string that is used to identify a file. In the context of POSIX.1-2024, a pathname may be limited to {PATH_MAX} bytes, including the terminating null byte. It has optional beginning \<slash\> characters, followed by zero or more filenames separated by \<slash\> characters. A pathname can optionally contain one or more trailing \<slash\> characters. Multiple successive \<slash\> characters are considered to be the same as one \<slash\>, except it is implementation-defined whether the case of exactly two leading \<slash\> characters is treated specially.

**Note:**  
If a pathname consists of only bytes corresponding to characters from the portable filename character set (see [3.265 Portable Filename Character Set](#tag_03_265)), \<slash\> characters, and a single terminating \<NUL\> character, the pathname will be usable as a character string in all supported locales; otherwise, the pathname might only be a string (rather than a character string). Additionally, since the single-byte encoding of the \<slash\> character is required to be the same across all locales and to not occur within a multi-byte character, references to a \<slash\> character within a pathname are well-defined even when the pathname is not a character string. However, this property does not necessarily hold for the remaining characters within the portable filename character set.

Pathname Resolution is defined in detail in [*4.16 Pathname Resolution*](../basedefs/V1_chap04.html#tag_04_16).

### <span id="tag_03_255"></span>3.255 Pathname Component

See *Filename* in [3.146 Filename](#tag_03_146).

### <span id="tag_03_256"></span>3.256 Path Prefix

The part of a pathname up to, but not including, the last component and any trailing \<slash\> characters, unless the pathname consists entirely of \<slash\> characters, in which case the path prefix is `'/'` for a pathname containing either a single \<slash\> or three or more \<slash\> characters, and `'//'` for the pathname **//**. The path prefix of a pathname containing no \<slash\> characters is empty, but is treated as referring to the current working directory.

**Note:**  
The term is used both in the sense of identifying part of a pathname that forms the prefix and of joining a non-empty path prefix to a filename to form a pathname. In the latter case, the path prefix need not have a trailing \<slash\> (in which case the joining is done with a \<slash\> character).

### <span id="tag_03_257"></span>3.257 Pattern

A sequence of characters used either with regular expression notation or with shell pattern matching notation.

**Note:**  
Regular Expressions are defined in detail in [*9. Regular Expressions*](../basedefs/V1_chap09.html#tag_09).

Shell pattern matching notation is defined in detail in [*2.14 Pattern Matching Notation*](../utilities/V3_chap02.html#tag_19_14).

The syntaxes of the two types of patterns are similar, but not identical; POSIX.1-2024 always indicates the type of pattern being referred to in the immediate context of the use of the term.

### <span id="tag_03_258"></span>3.258 Period Character (\<period\>)

The character `'.'`. The term "period" is contrasted with dot (see also [3.110 Dot](#tag_03_110)), which is used to describe a specific directory entry.

### <span id="tag_03_259"></span>3.259 Permissions

Attributes of an object that determine the privilege necessary to access or manipulate the object.

**Note:**  
File Access Permissions are defined in detail in [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07).

### <span id="tag_03_260"></span>3.260 Persistence

A mode for semaphores, shared memory, and message queues requiring that the object and its state (including data, if any) are preserved after the object is no longer referenced by any process.

Persistence of an object does not imply that the state of the object is maintained across a system crash or a system reboot.

### <span id="tag_03_261"></span>3.261 Pipe

An object identical to a FIFO which has no links in the file hierarchy.

**Note:**  
The [*pipe*()](../functions/pipe.html) function is defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_262"></span>3.262 Polling

A scheduling scheme whereby the local process periodically checks until the pre-specified events (for example, read, write) have occurred.

### <span id="tag_03_263"></span>3.263 Portable Character Set

The collection of characters that are required to be present in all locales supported by conforming systems.

**Note:**  
The Portable Character Set is defined in detail in [*6.1 Portable Character Set*](../basedefs/V1_chap06.html#tag_06_01).

This term is contrasted against the smaller portable filename character set; see also [3.265 Portable Filename Character Set](#tag_03_265).

### <span id="tag_03_264"></span>3.264 Portable Filename

A filename consisting only of characters from the portable filename character set.

**Note:**  
Applications should avoid using filenames that have the \<hyphen-minus\> character as the first character since this may cause problems when filenames are passed as command line arguments.

### <span id="tag_03_265"></span>3.265 Portable Filename Character Set

The set of characters from which portable filenames are constructed.


    A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    a b c d e f g h i j k l m n o p q r s t u v w x y z
    0 1 2 3 4 5 6 7 8 9 . _ -

The last three characters are the \<period\>, \<underscore\>, and \<hyphen-minus\> characters, respectively. See also [3.254 Pathname](#tag_03_254).

### <span id="tag_03_266"></span>3.266 Portable Messages Object Source File (or Dot-Po File)

A text file containing messages and directives. A portable messages object source file can be compiled into a messages object by the [*msgfmt*](../utilities/msgfmt.html) utility.

**Note:**  
By convention, portable messages object source files have filenames ending with the **.po** suffix. Utility descriptions in this standard frequently use dot-po file as a shorthand for portable messages object source file (even though the **.po** suffix need not be included in the filename). Template portable messages object source files can be created from C-language source files by the [*xgettext*](../utilities/xgettext.html) utility.

### <span id="tag_03_267"></span>3.267 Positional Parameter

In the shell command language, a parameter denoted by a decimal representation of a positive integer.

**Note:**  
For further information, see XCU [*2.5.1 Positional Parameters*](../utilities/V3_chap02.html#tag_19_05_01) .

### <span id="tag_03_268"></span>3.268 Positive

When describing a value (not a sign), greater than zero. Note that in the common phrase "positive zero" (which is not used in this standard, although the representation +0.0 is) it describes a sign, and therefore positive zero (+0.0) is not a positive value.

### <span id="tag_03_269"></span>3.269 Preallocation

The reservation of resources in a system for a particular use.

Preallocation does not imply that the resources are immediately allocated to that use, but merely indicates that they are guaranteed to be available in bounded time when needed.

### <span id="tag_03_270"></span>3.270 Preempted Process (or Thread)

A running thread whose execution is suspended due to another thread becoming runnable at a higher priority.

### <span id="tag_03_271"></span>3.271 Previous Job

In the context of job control, the job used as the default for the [*fg*](../utilities/fg.html) or [*bg*](../utilities/bg.html) utilities if the current job exits. There is at most one previous job; see also [3.182 Job ID](#tag_03_182).

### <span id="tag_03_272"></span>3.272 Printable Character

One of the characters included in the **print** character classification of the *LC_CTYPE* category in the current locale.

**Note:**  
The *LC_CTYPE* category is defined in detail in [*7.3.1 LC_CTYPE*](../basedefs/V1_chap07.html#tag_07_03_01).

### <span id="tag_03_273"></span>3.273 Printable File

A text file consisting only of the characters included in the **print** and **space** character classifications of the *LC_CTYPE* category and the \<backspace\>, all in the current locale.

**Note:**  
The *LC_CTYPE* category is defined in detail in [*7.3.1 LC_CTYPE*](../basedefs/V1_chap07.html#tag_07_03_01).

### <span id="tag_03_274"></span>3.274 Priority

A non-negative integer associated with processes or threads whose value is constrained to a range defined by the applicable scheduling policy. Numerically higher values represent higher priorities.

### <span id="tag_03_275"></span>3.275 Priority Inversion

A condition in which a thread that is not voluntarily suspended (waiting for an event or time delay) is not running while a lower priority thread is running. Such blocking of the higher priority thread is often caused by contention for a shared resource.

### <span id="tag_03_276"></span>3.276 Priority Scheduling

A performance and determinism improvement facility to allow applications to determine the order in which threads that are ready to run are granted access to processor resources.

### <span id="tag_03_277"></span>3.277 Priority-Based Scheduling

Scheduling in which the selection of a running thread is determined by the priorities of the runnable processes or threads.

### <span id="tag_03_278"></span>3.278 Privilege

See *Appropriate Privileges* in [3.21 Appropriate Privileges](#tag_03_21).

### <span id="tag_03_279"></span>3.279 Process

A live process (see [3.189 Live Process](#tag_03_189)) or a zombie process (see [3.426 Zombie Process](#tag_03_426)). The lifetime of a process is described in [3.285 Process Lifetime](#tag_03_285).

### <span id="tag_03_280"></span>3.280 Process Group

A collection of processes that permits the signaling of related processes. Each process in the system is a member of a process group that is identified by a process group ID. A newly created process joins the process group of its creator.

### <span id="tag_03_281"></span>3.281 Process Group ID

The unique positive integer identifier representing a process group during its lifetime.

**Note:**  
See also *Process Group ID Reuse* defined in [*4.17 Process ID Reuse*](../basedefs/V1_chap04.html#tag_04_17).

### <span id="tag_03_282"></span>3.282 Process Group Leader

A process whose process ID is the same as its process group ID.

### <span id="tag_03_283"></span>3.283 Process Group Lifetime

The period of time that begins when a process group is created and ends when the last remaining process in the group leaves the group, due either to the end of the lifetime of the last process or to the last remaining process calling the [*setsid*()](../functions/setsid.html) or [*setpgid*()](../functions/setpgid.html) functions.

**Note:**  
The [*setsid*()](../functions/setsid.html) and [*setpgid*()](../functions/setpgid.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_284"></span>3.284 Process ID

The unique positive integer identifier representing a process during its lifetime.

**Note:**  
See also *Process ID Reuse* defined in [*4.17 Process ID Reuse*](../basedefs/V1_chap04.html#tag_04_17) .

### <span id="tag_03_285"></span>3.285 Process Lifetime

The period of time that begins when a process is created and ends when its process ID is returned to the system.

See also [3.189 Live Process](#tag_03_189), [3.287 Process Termination](#tag_03_287), and [3.426 Zombie Process](#tag_03_426).

**Note:**  
Process creation is defined in detail in the descriptions of the [*fork*()](../functions/fork.html), [*posix_spawn*()](../functions/posix_spawn.html), and [*posix_spawnp*()](../functions/posix_spawnp.html) functions in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_286"></span>3.286 Process Memory Locking

A performance improvement facility to bind application programs into the high-performance random access memory of a computer system. This avoids potential latencies introduced by the operating system in storing parts of a program that were not recently referenced on secondary memory devices.

### <span id="tag_03_287"></span>3.287 Process Termination

There are two kinds of process termination:

1.  Normal termination occurs by a return from *main*(), when requested with the [*exit*()](../functions/exit.html), [*\_exit*()](../functions/_exit.html), or [*\_Exit*()](../functions/_Exit.html) functions; or when the last thread in the process terminates by returning from its start function, by calling the [*pthread_exit*()](../functions/pthread_exit.html) or [*thrd_exit*()](../functions/thrd_exit.html) function, or through cancellation.
2.  Abnormal termination occurs when requested by the [*abort*()](../functions/abort.html) function or when some signals are received.

**Note:**  
The consequences of process termination can be found in the description of the [*\_Exit*()](../functions/_Exit.html) function in the System Interfaces volume of POSIX.1-2024. The [*\_exit*()](../functions/_exit.html), [*\_Exit*()](../functions/_Exit.html), [*abort*()](../functions/abort.html), and [*exit*()](../functions/exit.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_288"></span>3.288 Process Virtual Time

The measurement of time in units elapsed by the system clock while a process is executing.

### <span id="tag_03_289"></span>3.289 Process-Owned File Lock

A record lock owned by a process. Process-owned file locks are obtained through the use of [*fcntl*()](../functions/fcntl.html) with F_SETLK or F_SETLKW, or the use of [*lockf*()](../functions/lockf.html). Process-owned file locks are not inherited by child processes, but are preserved across the *exec* family of functions. A process-owned file lock is released when the process exits, or when any file descriptor in the process referring to the same file is closed (even if via a different open file description). These locks are shared among all open file descriptions referring to the same file in the process, making the use of process-owned file locks unsuitable for use for coordination of record access among multiple threads in a process.

### <span id="tag_03_290"></span>3.290 Process-To-Process Communication

The transfer of data between processes.

### <span id="tag_03_291"></span>3.291 Program

A prepared sequence of instructions to the system to accomplish a defined task. The term "program" in POSIX.1-2024 encompasses applications written in the Shell Command Language, complex utility input languages (for example, [*awk*](../utilities/awk.html), [*lex*](../utilities/lex.html), [*sed*](../utilities/sed.html), and so on), and high-level languages.

### <span id="tag_03_292"></span>3.292 Protocol

A set of semantic and syntactic rules for exchanging information.

### <span id="tag_03_293"></span>3.293 Pseudo-Terminal

A facility that provides an interface that is identical to the terminal subsystem, except where noted otherwise in POSIX.1-2024. A pseudo-terminal is composed of two devices: the "manager device" and a "subsidiary device". The subsidiary device provides processes with an interface that is identical to the terminal interface, although there need not be hardware behind that interface. Anything written on the manager device is presented to the subsidiary as an input and anything written on the subsidiary device is presented as an input on the manager side.

### <span id="tag_03_294"></span>3.294 Radix Character (or Decimal-Point Character)

The character that separates the integer part of a number from the fractional part.

### <span id="tag_03_295"></span>3.295 Read-Only File System

A file system that has implementation-defined characteristics restricting modifications.

**Note:**  
File Times Update is described in detail in [*4.12 File Times Update*](../basedefs/V1_chap04.html#tag_04_12) .

### <span id="tag_03_296"></span>3.296 Read-Write Lock

Multiple readers, single writer (read-write) locks allow many threads to have simultaneous read-only access to data while allowing only one thread to have write access at any given time. They are typically used to protect data that is read-only more frequently than it is changed.

Read-write locks can be used to synchronize threads in the current process and other processes if they are allocated in memory that is writable and shared among the cooperating processes and have been initialized for this behavior.

### <span id="tag_03_297"></span>3.297 Real Group ID

The attribute of a process that, at the time of process creation, identifies the group of the user who created the process; see also [3.165 Group ID](#tag_03_165).

### <span id="tag_03_298"></span>3.298 Real Time

Time measured as total units elapsed by the system clock without regard to which thread is executing.

### <span id="tag_03_299"></span>3.299 Realtime Signal Extension

A determinism improvement facility to enable asynchronous signal notifications to an application to be queued without impacting compatibility with the existing signal functions.

### <span id="tag_03_300"></span>3.300 Real User ID

The attribute of a process that, at the time of process creation, identifies the user who created the process; see also [3.408 User ID](#tag_03_408).

### <span id="tag_03_301"></span>3.301 Record

A collection of related data units or words which is treated as a unit.

### <span id="tag_03_302"></span>3.302 Record Lock

A file lock held on a record within a file. A record lock can be used to lock a whole file by specifying a special record with starting offset zero and length zero. (This special record extends to any future end-of-file, not just the current end-of-file.) This includes an OFD-owned file lock (see [3.237 OFD-Owned File Lock](#tag_03_237)) or a process-owned file lock (see [3.289 Process-Owned File Lock](#tag_03_289)). It is unspecified whether an implementation will detect and prevent deadlocks caused by two competing lock owners holding separate locks where each tries to obtain a lock that is blocked by the other's lock.

### <span id="tag_03_303"></span>3.303 Redirection

In the shell command language, a method of associating files with the input or output of commands.

**Note:**  
For further information, see XCU [*2.7 Redirection*](../utilities/V3_chap02.html#tag_19_07).

### <span id="tag_03_304"></span>3.304 Redirection Operator

In the shell command language, a token that performs a redirection function. It is one of the following symbols:


    <     >     >|     <<     >>     <&     >&     <<-     <>

### <span id="tag_03_305"></span>3.305 Referenced Shared Memory Object

A shared memory object that is open or has one or more mappings defined on it.

### <span id="tag_03_306"></span>3.306 Refresh

Make the information on the user's terminal screen up-to-date.

### <span id="tag_03_307"></span>3.307 Regular Built-In Utility (or Regular Built-In)

See *Built-In Utility* in [3.54 Built-In Utility (or Built-In)](#tag_03_54).

### <span id="tag_03_308"></span>3.308 Regular Expression

A pattern that selects specific strings from a set of character strings.

**Note:**  
Regular Expressions are described in detail in [*9. Regular Expressions*](../basedefs/V1_chap09.html#tag_09) .

### <span id="tag_03_309"></span>3.309 Region

In the context of the address space of a process, a sequence of addresses.

In the context of a file, a sequence of offsets.

### <span id="tag_03_310"></span>3.310 Regular File

A file that is a randomly accessible sequence of bytes, with no further structure imposed by the system.

### <span id="tag_03_311"></span>3.311 Relative Pathname

A pathname not beginning with a \<slash\> character.

**Note:**  
Pathname Resolution is defined in detail in [*4.16 Pathname Resolution*](../basedefs/V1_chap04.html#tag_04_16) .

### <span id="tag_03_312"></span>3.312 Relocatable File

A file holding code or data suitable for linking with other object files to create an executable or a shared object file.

### <span id="tag_03_313"></span>3.313 Relocation

The process of connecting symbolic references with symbolic definitions. For example, when a program calls a function, the associated call instruction transfers control to the proper destination address at execution.

### <span id="tag_03_314"></span>3.314 (Time) Resolution

The minimum time interval that a clock can measure or whose passage a timer can detect.

### <span id="tag_03_315"></span>3.315 Robust Mutex

A mutex with the *robust* attribute set.

**Note:**  
The *robust* attribute is defined in detail by the [*pthread_mutexattr_getrobust*()](../functions/pthread_mutexattr_getrobust.html) function.

### <span id="tag_03_316"></span>3.316 Root Directory

A directory, associated with a process, that is used in pathname resolution for pathnames that begin with a \<slash\> character.

### <span id="tag_03_317"></span>3.317 Runnable Process (or Thread)

A thread that is capable of being a running thread, but for which no processor is available.

### <span id="tag_03_318"></span>3.318 Running Process (or Thread)

A thread currently executing on a processor. On multi-processor systems there may be more than one such thread in a system at a time.

### <span id="tag_03_319"></span>3.319 Saved Resource Limits

An attribute of a process that provides some flexibility in the handling of unrepresentable resource limits, as described in the *exec* family of functions and [*setrlimit*()](../functions/setrlimit.html).

**Note:**  
The *exec* and [*setrlimit*()](../functions/setrlimit.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_320"></span>3.320 Saved Set-Group-ID

An attribute of a process that allows some flexibility in the assignment of the effective group ID attribute, as described in the *exec* family of functions and [*setgid*()](../functions/setgid.html).

**Note:**  
The *exec* and [*setgid*()](../functions/setgid.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_321"></span>3.321 Saved Set-User-ID

An attribute of a process that allows some flexibility in the assignment of the effective user ID attribute, as described in the *exec* family of functions and [*setuid*()](../functions/setuid.html).

**Note:**  
The *exec* and [*setuid*()](../functions/setuid.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_322"></span>3.322 Scheduling

The application of a policy to select a runnable process or thread to become a running process or thread, or to alter one or more of the thread lists.

### <span id="tag_03_323"></span>3.323 Scheduling Allocation Domain

The set of processors on which an individual thread can be scheduled at any given time.

### <span id="tag_03_324"></span>3.324 Scheduling Contention Scope

A property of a thread that defines the set of threads against which that thread competes for resources.

For example, in a scheduling decision, threads sharing scheduling contention scope compete for processor resources. In POSIX.1-2024, a thread has scheduling contention scope of either PTHREAD_SCOPE_SYSTEM or PTHREAD_SCOPE_PROCESS.

### <span id="tag_03_325"></span>3.325 Scheduling Policy

A set of rules that is used to determine the order of execution of processes or threads to achieve some goal.

**Note:**  
Scheduling Policy is defined in detail in [*4.18 Scheduling Policy*](../basedefs/V1_chap04.html#tag_04_18) .

### <span id="tag_03_326"></span>3.326 Screen

A rectangular region of columns and lines on a terminal display. A screen may be a portion of a physical display device or may occupy the entire physical area of the display device.

### <span id="tag_03_327"></span>3.327 Scroll

To move the representation of data vertically or horizontally relative to the terminal screen. There are two types of scrolling:

1.  The cursor moves with the data.
2.  The cursor remains stationary while the data moves.

### <span id="tag_03_328"></span>3.328 Semaphore

A minimum synchronization primitive to serve as a basis for more complex synchronization mechanisms to be defined by the application program.

**Note:**  
Semaphores are defined in detail in [*4.20 Semaphore*](../basedefs/V1_chap04.html#tag_04_20).

### <span id="tag_03_329"></span>3.329 Session

A collection of process groups established for job control purposes. Each process group is a member of a session. A process is considered to be a member of the session of which its process group is a member. A newly created process joins the session of its creator. A process can alter its session membership; see [*setsid*()](../functions/setsid.html). There can be multiple process groups in the same session.

**Note:**  
The [*setsid*()](../functions/setsid.html) function is defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_330"></span>3.330 Session Leader

A process that has created a session.

**Note:**  
For further information, see the [*setsid*()](../functions/setsid.html) function defined in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_331"></span>3.331 Session Lifetime

The period between when a session is created and the end of the lifetime of all the process groups that remain as members of the session.

### <span id="tag_03_332"></span>3.332 Shared Memory Object

An object that represents memory that can be mapped concurrently into the address space of more than one process.

### <span id="tag_03_333"></span>3.333 Shell

A program that interprets sequences of text input as commands. It may operate on an input stream or it may interactively prompt and read commands from a terminal.

### <span id="tag_03_334"></span>3.334 Shell, the

The Shell Command Language Interpreter; a specific instance of a shell.

**Note:**  
For further information, see the [*sh*](../utilities/sh.html) utility defined in the Shell and Utilities volume of POSIX.1-2024.

### <span id="tag_03_335"></span>3.335 Shell Script

A file containing shell commands. If the file is made executable, it can be executed by specifying its name as a simple command. Execution of a shell script causes a shell to execute the commands within the script. Alternatively, a shell can be requested to execute the commands in a shell script by specifying the name of the shell script as the operand to the [*sh*](../utilities/sh.html) utility.

**Note:**  
Simple Commands are defined in detail in XCU [*2.9.1 Simple Commands*](../utilities/V3_chap02.html#tag_19_09_01).

The [*sh*](../utilities/sh.html) utility is defined in detail in the Shell and Utilities volume of POSIX.1-2024.

### <span id="tag_03_336"></span>3.336 Signal

A mechanism by which a process or thread may be notified of, or affected by, an event occurring in the system. Examples of such events include hardware exceptions and specific actions by processes. The term signal is also used to refer to the event itself.

### <span id="tag_03_337"></span>3.337 Signal Stack

Memory established for a thread, in which signal handlers catching signals sent to that thread are executed.

### <span id="tag_03_338"></span>3.338 Single-Quote Character

The character designated by `'\''` in the C language, also known as \<apostrophe\>.

### <span id="tag_03_339"></span>3.339 Single-Threaded Process

A process that contains a single thread.

### <span id="tag_03_340"></span>3.340 Single-Threaded Program

A program whose executable file was produced by compiling with [*c17*](../utilities/c17.html) without using the flags output by [*getconf*](../utilities/getconf.html) POSIX_V8_THREADS_CFLAGS and linking with [*c17*](../utilities/c17.html) using neither the flags output by [*getconf*](../utilities/getconf.html) POSIX_V8_THREADS_LDFLAGS nor the **-l pthread** option, or by compiling and linking using a non-standard utility with equivalent flags. Execution of a single-threaded program creates a single-threaded process; if the process attempts to create additional threads using [*pthread_create*()](../functions/pthread_create.html), [*thrd_create*()](../functions/thrd_create.html), or SIGEV_THREAD notifications, the behavior is undefined. If the process uses [*dlopen*()](../functions/dlopen.html) to load a multi-threaded library, the behavior is undefined.

### <span id="tag_03_341"></span>3.341 Slash Character (\<slash\>)

The character `'/'`, also known as solidus.

### <span id="tag_03_342"></span>3.342 Socket

A file of a particular type that is used as a communications endpoint for process-to-process communication as described in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_343"></span>3.343 Socket Address

An address associated with a socket or remote endpoint, including an address family identifier and addressing information specific to that address family. The address may include multiple parts, such as a network address associated with a host system and an identifier for a specific endpoint.

### <span id="tag_03_344"></span>3.344 Soft Limit

A resource limitation established for each process that the process may set to any value less than or equal to the hard limit.

### <span id="tag_03_345"></span>3.345 Source Code

When dealing with the Shell Command Language, input to the command language interpreter. The term "shell script" is synonymous with this meaning.

When dealing with an ISO/IEC-conforming programming language, source code is input to a compiler conforming to that ISO/IEC standard.

Source code also refers to the input statements prepared for the following standard utilities: [*awk*](../utilities/awk.html), [*bc*](../utilities/bc.html), [*ed*](../utilities/ed.html), [*ex*](../utilities/ex.html), [*lex*](../utilities/lex.html), [*localedef*](../utilities/localedef.html), [*make*](../utilities/make.html), [*sed*](../utilities/sed.html), and [*yacc*](../utilities/yacc.html).

Source code can also refer to a collection of sources meeting any or all of these meanings.

**Note:**  
The [*awk*](../utilities/awk.html), [*bc*](../utilities/bc.html), [*ed*](../utilities/ed.html), [*ex*](../utilities/ex.html), [*lex*](../utilities/lex.html), [*localedef*](../utilities/localedef.html), [*make*](../utilities/make.html), [*sed*](../utilities/sed.html), and [*yacc*](../utilities/yacc.html) utilities are defined in detail in the Shell and Utilities volume of POSIX.1-2024.

### <span id="tag_03_346"></span>3.346 Space Character (\<space\>)

The character defined in the portable character set as \<space\>. The \<space\> character is a member of the **space** character class of the current locale, but represents the single character, and not all of the possible members of the class; see also [3.413 White Space](#tag_03_413).

### <span id="tag_03_347"></span>3.347 Sparse File

A file that contains more holes than just the virtual hole at the end of the file.

### <span id="tag_03_348"></span>3.348 Spawn

A process creation primitive useful for systems that have difficulty with [*fork*()](../functions/fork.html) and as an efficient replacement for [*fork*()](../functions/fork.html)/*exec*.

### <span id="tag_03_349"></span>3.349 Special Built-In Utility (or Special Built-In)

See *Built-In Utility* in [3.54 Built-In Utility (or Built-In)](#tag_03_54).

### <span id="tag_03_350"></span>3.350 Special Parameter

In the shell command language, a parameter named by a single character from the following list:


    *   @   #   ?   !   -   $   0

**Note:**  
For further information, see XCU [*2.5.2 Special Parameters*](../utilities/V3_chap02.html#tag_19_05_02).

### <span id="tag_03_351"></span>3.351 Spin Lock

A synchronization object used to allow multiple threads to serialize their access to shared data.

### <span id="tag_03_352"></span>3.352 Sporadic Server

A scheduling policy for threads and processes that reserves a certain amount of execution capacity for processing aperiodic events at a given priority level.

### <span id="tag_03_353"></span>3.353 Standard Error

In the context of file descriptors (see [3.141 File Descriptor](#tag_03_141)), file descriptor number 2.

In the context of standard I/O streams (see XSH [*2.5 Standard I/O Streams*](../functions/V2_chap02.html#tag_16_05)), an output stream usually intended to be used for diagnostic messages, and accessed using the global variable *stderr*.

**Note:**  
The file descriptor underlying *stderr* is initially 2, but it can be changed by [*freopen*()](../functions/freopen.html) to 0 or 1 (and implementations may have extensions that allow it to be changed to other numbers). Therefore, writing to the standard error stream does not always produce output on the standard error file descriptor.

### <span id="tag_03_354"></span>3.354 Standard Input

In the context of file descriptors (see [3.141 File Descriptor](#tag_03_141)), file descriptor number 0.

In the context of standard I/O streams (see XSH [*2.5 Standard I/O Streams*](../functions/V2_chap02.html#tag_16_05)), an input stream usually intended to be used for primary data input, and accessed using the global variable *stdin*.

**Note:**  
The file descriptor underlying *stdin* is initially 0; this cannot change through the use of interfaces defined in this standard, but implementations may have extensions that allow it to be changed. Therefore, in conforming applications using extensions, reading from the standard input stream does not always obtain input from the standard input file descriptor.

### <span id="tag_03_355"></span>3.355 Standard Output

In the context of file descriptors (see [3.141 File Descriptor](#tag_03_141)), file descriptor number 1.

In the context of standard I/O streams (see XSH [*2.5 Standard I/O Streams*](../functions/V2_chap02.html#tag_16_05)), an output stream usually intended to be used for primary data output, and accessed using the global variable *stdout*.

**Note:**  
The file descriptor underlying *stdout* is initially 1, but it can be changed by [*freopen*()](../functions/freopen.html) to 0 (and implementations may have extensions that allow it to be changed to other numbers). Therefore, writing to the standard output stream does not always produce output on the standard output file descriptor.

### <span id="tag_03_356"></span>3.356 Standard Utilities

The utilities described in the Shell and Utilities volume of POSIX.1-2024.

### <span id="tag_03_357"></span>3.357 Stream

Appearing in lowercase, a stream is an ordered sequence of bytes, as described by the ISO C standard.

In the shell command language, each stream is associated with a file descriptor. These can be opened using redirection operators.

**Note:**  
Redirection is defined in detail in XCU [*2.7 Redirection*](../utilities/V3_chap02.html#tag_19_07).

In the C language, each stream is accessed via a file access object and is either a stream associated with a file descriptor or a memory stream. A file access object associated with a file descriptor can be created by the [*fdopen*()](../functions/fdopen.html), [*fopen*()](../functions/fopen.html), or [*popen*()](../functions/popen.html) functions. A file access object for a memory stream can be created by the [*fmemopen*()](../functions/fmemopen.html) or [*open_memstream*()](../functions/open_memstream.html) functions. A stream provides the additional services of user-selectable buffering and formatted input and output.

**Note:**  
For further information, see XSH [*2.5 Standard I/O Streams*](../functions/V2_chap02.html#tag_16_05).

The [*fdopen*()](../functions/fdopen.html), [*fmemopen*()](../functions/fmemopen.html), [*fopen*()](../functions/fopen.html), [*open_memstream*()](../functions/open_memstream.html), and [*popen*()](../functions/popen.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_358"></span>3.358 String

A contiguous sequence of bytes terminated by and including the first null byte.

### <span id="tag_03_359"></span>3.359 Subshell

A shell execution environment, distinguished from the main or current shell execution environment.

**Note:**  
For further information, see XCU [*2.13 Shell Execution Environment*](../utilities/V3_chap02.html#tag_19_13) .

### <span id="tag_03_360"></span>3.360 Successfully Transferred

For a write operation to a regular file, when the system ensures that all data written is readable on any subsequent open of the file (even one that follows a system or power failure) in the absence of a failure of the physical storage medium.

For a read operation, when an image of the data on the physical storage medium is available to the requesting process.

### <span id="tag_03_361"></span>3.361 Supplementary Group ID

An attribute of a process used in determining file access permissions. A process has up to {NGROUPS_MAX} supplementary group IDs in addition to the effective group ID. The supplementary group IDs of a process are set to the supplementary group IDs of the parent process when the process is created.

### <span id="tag_03_362"></span>3.362 Suspended Job

In the context of the System Interfaces volume of POSIX.1-2024, a job that has received a SIGSTOP, SIGTSTP, SIGTTIN, or SIGTTOU signal that caused the process group to stop.

In the context of the shell, a job, other than a non-job-control background job, that became suspended when a process returned a wait status to the shell indicating that the process was stopped by a SIGSTOP, SIGTSTP, SIGTTIN, or SIGTTOU signal.

A suspended job is a job-control background job, but a job-control background job is not necessarily a suspended job. A non-job-control background job is never a suspended job, even if it includes processes that have been stopped by a SIGSTOP, SIGTSTP, SIGTTIN, or SIGTTOU signal.

**Note:**  
See also [3.35 Background Job](#tag_03_35), [3.180 Job](#tag_03_180), and [3.158 Foreground Job](#tag_03_158).

### <span id="tag_03_363"></span>3.363 Symbolic Constant

An object-like macro defined with a constant value.

Unless stated otherwise, the following shall apply to every symbolic constant:

- It expands to a compile-time constant expression with an integer type.
- It may be defined as another type of constant—e.g., an enumeration constant—as well as being a macro.
- It need not be usable in **\#if** preprocessing directives.

### <span id="tag_03_364"></span>3.364 Symbolic Link

A type of file with the property that when the file is encountered during pathname resolution, a string stored by the file is used to modify the pathname resolution. The stored string has a length of {SYMLINK_MAX} bytes or fewer.

**Note:**  
Pathname Resolution is defined in detail in [*4.16 Pathname Resolution*](../basedefs/V1_chap04.html#tag_04_16) .

### <span id="tag_03_365"></span>3.365 Synchronization Operation

An operation that synchronizes memory. See [*4.15 Memory Ordering and Synchronization*](../basedefs/V1_chap04.html#tag_04_15).

### <span id="tag_03_366"></span>3.366 Synchronized Input and Output

A determinism and robustness improvement mechanism to enhance the data input and output mechanisms, so that an application can be assured that the data being manipulated is physically present on secondary mass storage devices.

### <span id="tag_03_367"></span>3.367 Synchronized I/O Completion

The state of an I/O operation that has either been successfully transferred or diagnosed as unsuccessful.

### <span id="tag_03_368"></span>3.368 Synchronized I/O Data Integrity Completion

For read, when the operation has been completed or diagnosed if unsuccessful. The read is complete only when an image of the data has been successfully transferred to the requesting process. If there were any pending write requests affecting the data to be read at the time that the synchronized read operation was requested, these write requests are successfully transferred prior to reading the data.

For write, when the operation has been completed or diagnosed if unsuccessful. The write is complete only when the data specified in the write request is successfully transferred and all file system information required to retrieve the data is successfully transferred.

For the purpose of this definition, an operation that reads or searches a directory is considered to be a read operation, an operation that modifies a directory is considered to be a write operation, and a directory's entries are considered to be the data read or written.

This standard provides no way to synchronize the contents or attributes of a symbolic link.

File attributes that are not necessary for data retrieval (access time, modification time, status change time) need not be successfully transferred prior to returning to the calling process.

### <span id="tag_03_369"></span>3.369 Synchronized I/O File Integrity Completion

Identical to a synchronized I/O data integrity completion with the addition that all file attributes relative to the I/O operation (including access time, modification time, status change time) are successfully transferred prior to returning to the calling process.

### <span id="tag_03_370"></span>3.370 Synchronized I/O Operation

An I/O operation performed on a file that provides the application assurance of the integrity of its data and files.

### <span id="tag_03_371"></span>3.371 Synchronous I/O Operation

An I/O operation that causes the thread requesting the I/O to be blocked from further use of the processor until that I/O operation completes.

**Note:**  
A synchronous I/O operation does not imply synchronized I/O data integrity completion or synchronized I/O file integrity completion.

### <span id="tag_03_372"></span>3.372 Synchronously-Generated Signal

A signal that is attributable to a specific thread.

For example, a thread executing an illegal instruction or touching invalid memory causes a synchronously-generated signal. Being synchronous is a property of how the signal was generated and not a property of the signal number.

### <span id="tag_03_373"></span>3.373 System

An implementation of POSIX.1-2024.

### <span id="tag_03_374"></span>3.374 System Boot

An unspecified sequence of events that may result in the loss of transitory data; that is, data that is not saved in permanent storage. For example, message queues, shared memory, semaphores, and processes.

### <span id="tag_03_375"></span>3.375 System Clock

A clock with at least one second resolution that contains seconds since the Epoch.

### <span id="tag_03_376"></span>3.376 System Console

A device that receives messages sent by the [*syslog*()](../functions/syslog.html) function, and the [*fmtmsg*()](../functions/fmtmsg.html) function when the MM_CONSOLE flag is set.

**Note:**  
The [*syslog*()](../functions/syslog.html) and [*fmtmsg*()](../functions/fmtmsg.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_377"></span>3.377 System Crash

An interval initiated by an unspecified circumstance that causes all processes (possibly other than special system processes) to be terminated in an undefined manner, after which any changes to the state and contents of files created or written to by an application prior to the interval are undefined, except as required elsewhere in POSIX.1-2024.

### <span id="tag_03_378"></span>3.378 System Databases

An implementation provides two system databases: the "group database" (see also [3.164 Group Database](#tag_03_164)) and the "user database" (see also [3.407 User Database](#tag_03_407)).

### <span id="tag_03_379"></span>3.379 System Documentation

All documentation provided with an implementation except for the conformance document. Electronically distributed documents for an implementation are considered part of the system documentation.

### <span id="tag_03_380"></span>3.380 System Process

An object other than a process executing an application, that is provided by the system and has a process ID.

### <span id="tag_03_381"></span>3.381 System Reboot

See *System Boot* defined in [3.374 System Boot](#tag_03_374).

### <span id="tag_03_382"></span>3.382 System-Wide

Pertaining to events occurring in all processes existing in an implementation at a given point in time.

### <span id="tag_03_383"></span>3.383 Tab Character (\<tab\>)

A character that in the output stream indicates that printing or displaying should start at the next horizontal tabulation position on the current line. It is the character designated by `'\t'` in the C language. If the current position is at or past the last defined horizontal tabulation position, the behavior is unspecified. It is unspecified whether this character is the exact sequence transmitted to an output device by the system to accomplish the tabulation.

### <span id="tag_03_384"></span>3.384 Terminal (or Terminal Device)

A character special file that obeys the specifications of the general terminal interface.

**Note:**  
The General Terminal Interface is defined in detail in [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).

### <span id="tag_03_385"></span>3.385 Text Column

A roughly rectangular block of characters capable of being laid out side-by-side next to other text columns on an output page or terminal screen. The widths of text columns are measured in column positions.

### <span id="tag_03_386"></span>3.386 Text Domain

A named collection of messages objects (one messages object per supported language) for internationalization and localization purposes. A text domain is often named after the application or library that provides the collection, but may have a more general name if it is intended to be shared by multiple applications or libraries.

**Note:**  
The use of text domains is defined in detail in the descriptions of the [*bindtextdomain*()](../functions/bindtextdomain.html#) and [*gettext*()](../functions/gettext.html#tag_17_238) family of functions in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_387"></span>3.387 Text File

A file that contains characters organized into zero or more lines. The lines do not contain NUL characters and none can exceed {LINE_MAX} bytes in length, including the \<newline\> character. Although POSIX.1-2024 does not distinguish between text files and binary files (see the ISO C standard), many utilities only produce predictable or meaningful output when operating on text files. The standard utilities that have such restrictions always specify "text files" in their STDIN or INPUT FILES sections.

### <span id="tag_03_388"></span>3.388 Thread

A live thread (see [3.190 Live Thread](#tag_03_190)) or a zombie thread (see [3.427 Zombie Thread](#tag_03_427)). The lifetime of a thread is described in [3.390 Thread Lifetime](#tag_03_390) .

### <span id="tag_03_389"></span>3.389 Thread ID

A value that uniquely identifies each thread in a process during the thread's lifetime. The value shall be unique across all threads in a process, regardless of whether the thread is:

- The initial thread
- A thread created using [*pthread_create*()](../functions/pthread_create.html)
- A thread created using [*thrd_create*()](../functions/thrd_create.html)
- A thread created via a SIGEV_THREAD notification

**Note:**  
Since [*pthread_create*()](../functions/pthread_create.html) returns an ID of type **pthread_t** and [*thrd_create*()](../functions/thrd_create.html) returns an ID of type **thrd_t**, this uniqueness requirement necessitates that these two types are defined as the same underlying type because calls to [*pthread_self*()](../functions/pthread_self.html) and [*thrd_current*()](../functions/thrd_current.html) from the initial thread need to return the same thread ID. The [*pthread_create*()](../functions/pthread_create.html), [*pthread_self*()](../functions/pthread_self.html), [*thrd_create*()](../functions/thrd_create.html), and [*thrd_current*()](../functions/thrd_current.html) functions and SIGEV_THREAD notifications are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_390"></span>3.390 Thread Lifetime

The period of time that begins when a thread is created and ends when its thread ID is returned to the process.

See also *Live Thread* in [3.190 Live Thread](#tag_03_190), *Thread Termination* in [3.392 Thread Termination](#tag_03_392), and *Zombie Thread* in [3.427 Zombie Thread](#tag_03_427).

**Note:**  
Thread creation is defined in detail in the descriptions of the [*pthread_create*()](../functions/pthread_create.html) and [*thrd_create*()](../functions/thrd_create.html) functions in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_391"></span>3.391 Thread List

An ordered set of runnable threads that all have the same ordinal value for their priority.

The ordering of threads on the list is determined by a scheduling policy or policies. The set of thread lists includes all runnable threads in the system.

### <span id="tag_03_392"></span>3.392 Thread Termination

Thread termination occurs when a thread executes [*pthread_exit*()](../functions/pthread_exit.html) or [*thrd_exit*()](../functions/thrd_exit.html), when it returns from the *start_routine* function passed to [*pthread_create*()](../functions/pthread_create.html) or from the *func* function passed to [*thrd_create*()](../functions/thrd_create.html), or when it acts on a cancellation request initiated by [*pthread_cancel*()](../functions/pthread_cancel.html).

**Note:**  
The [*pthread_cancel*()](../functions/pthread_cancel.html), [*pthread_create*()](../functions/pthread_create.html), [*pthread_exit*()](../functions/pthread_exit.html), [*thrd_create*()](../functions/thrd_create.html), and [*thrd_exit*()](../functions/thrd_exit.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_393"></span>3.393 Thread-Safe

A thread-safe function shall avoid data races with other calls to the same function, and with calls to any other thread-safe functions, by multiple threads. Each function defined in the System Interfaces volume of POSIX.1-2024 is thread-safe unless explicitly stated otherwise. Examples are any "pure" function, a function which holds a mutex locked while it is accessing static storage, or objects shared among threads.

A function that is not required to be thread-safe need not avoid data races with other calls to the same function, nor with calls to any other function (including thread-safe functions), by multiple threads, unless explicitly stated otherwise.

### <span id="tag_03_394"></span>3.394 Thread-Specific Data Key

A process global handle which is used for naming thread-specific data. There are two types of key: those of type **pthread_key_t** which are created using [*pthread_key_create*()](../functions/pthread_key_create.html) and those of type **tss_t** which are created using [*tss_create*()](../functions/tss_create.html). If an application attempts to use the two types of key interchangeably (that is, pass a key of type **pthread_key_t** to a function that takes a **tss_t**, or vice versa), the behavior is undefined.

Although the same key value can be used by different threads, the values bound to the key by [*pthread_setspecific*()](../functions/pthread_setspecific.html) for keys of type **pthread_key_t**, and by [*tss_set*()](../functions/tss_set.html) for keys of type **tss_t**, are maintained on a per-thread basis and persist for the life of the calling thread.

**Note:**  
The [*pthread_getspecific*()](../functions/pthread_getspecific.html), [*pthread_setspecific*()](../functions/pthread_setspecific.html), [*tss_create*()](../functions/tss_create.html), and [*tss_set*()](../functions/tss_set.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_395"></span>3.395 Tilde Character (\<tilde\>)

The character `'~'`.

### <span id="tag_03_396"></span>3.396 Timeouts

A method of limiting the length of time an interface will block; see also [3.47 Blocked Process (or Thread)](#tag_03_47).

### <span id="tag_03_397"></span>3.397 Timer

A mechanism that can notify a thread when the time as measured by a particular clock has reached or passed a specified value, or when a specified amount of time has passed.

### <span id="tag_03_398"></span>3.398 Timer Overrun

A condition that occurs each time a timer, for which there is already an expiration signal queued to the process, expires.

### <span id="tag_03_399"></span>3.399 Token

In the shell command language, a sequence of characters that the shell considers as a single unit when reading input. A token is either an operator or a word.

**Note:**  
The rules for reading input are defined in detail in XCU [*2.3 Token Recognition*](../utilities/V3_chap02.html#tag_19_03).

### <span id="tag_03_400"></span>3.400 Typed Memory Name Space

A system-wide name space that contains the names of the typed memory objects present in the system. It is configurable for a given implementation.

### <span id="tag_03_401"></span>3.401 Typed Memory Object

A combination of a typed memory pool and a typed memory port. The entire contents of the pool are accessible from the port. The typed memory object is identified through a name that belongs to the typed memory name space.

### <span id="tag_03_402"></span>3.402 Typed Memory Pool

An extent of memory with the same operational characteristics. Typed memory pools may be contained within each other.

### <span id="tag_03_403"></span>3.403 Typed Memory Port

A hardware access path to one or more typed memory pools.

### <span id="tag_03_404"></span>3.404 Unbind

Remove the association between a network address and an endpoint.

### <span id="tag_03_405"></span>3.405 Unit Data

See *Datagram* in [3.96 Datagram](#tag_03_96).

### <span id="tag_03_406"></span>3.406 Upshifting

The conversion of a lowercase character that has a single-character uppercase representation into this uppercase representation.

### <span id="tag_03_407"></span>3.407 User Database

A system database that contains at least the following information for each user ID:

- User name
- Numerical user ID
- Initial numerical group ID
- Initial working directory
- Initial user program

The initial numerical group ID is used by the [*newgrp*](../utilities/newgrp.html) utility. Any other circumstances under which the initial values are operative are implementation-defined.

If the initial user program field is null, an implementation-defined program is used.

If the initial working directory field is null, the interpretation of that field is implementation-defined.

**Note:**  
The [*newgrp*](../utilities/newgrp.html) utility is defined in detail in the Shell and Utilities volume of POSIX.1-2024.

### <span id="tag_03_408"></span>3.408 User ID

A non-negative integer that is used to identify a system user. When the identity of a user is associated with a process, a user ID value is referred to as a real user ID, an effective user ID, or a saved set-user-ID. The value (**uid_t**)-1 shall not be a valid user ID, but does have a defined use in some interfaces defined in this standard.

### <span id="tag_03_409"></span>3.409 User Name

A string that is used to identify a user; see also [3.407 User Database](#tag_03_407). To be portable across systems conforming to POSIX.1-2024, the value is composed of characters from the portable filename character set. The \<hyphen-minus\> character should not be used as the first character of a portable user name.

### <span id="tag_03_410"></span>3.410 Utility

A program, excluding special built-in utilities provided as part of the Shell Command Language, that can be called by name from a shell to perform a specific task, or related set of tasks.

**Note:**  
For further information on special built-in utilities, see XCU [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15).

### <span id="tag_03_411"></span>3.411 Variable

In the shell command language, a named parameter.

**Note:**  
For further information, see XCU [*2.5 Parameters and Variables*](../utilities/V3_chap02.html#tag_19_05).

### <span id="tag_03_412"></span>3.412 Vertical-Tab Character (\<vertical-tab\>)

A character that in the output stream indicates that printing should start at the next vertical tabulation position. It is the character designated by `'\v'` in the C language. If the current position is at or past the last defined vertical tabulation position, the behavior is unspecified. It is unspecified whether this character is the exact sequence transmitted to an output device by the system to accomplish the tabulation.

### <span id="tag_03_413"></span>3.413 White Space

A sequence of one or more characters that belong to the **space** character class as defined via the *LC_CTYPE* category in the current locale or a specified locale.

In the POSIX locale, white space consists of one or more \<blank\> (\<space\> and \<tab\> characters), \<newline\>, \<carriage-return\>, \<form-feed\>, and \<vertical-tab\> characters.

### <span id="tag_03_414"></span>3.414 White-Space Byte

A single-byte white-space character; that is, a character for which the [*isspace*()](../functions/isspace.html) or [*isspace_l*()](../functions/isspace_l.html) function returns a non-zero value.

### <span id="tag_03_415"></span>3.415 White-Space Character

A character that belongs to the **space** character class as defined via the *LC_CTYPE* category in the current locale or a specified locale.

### <span id="tag_03_416"></span>3.416 White-Space Wide Character

A wide-character code that belongs to the **space** character class as defined via the *LC_CTYPE* category in the current locale or a specified locale.

### <span id="tag_03_417"></span>3.417 Wide-Character Code (C Language)

An integer value corresponding to a single graphic symbol or control code.

**Note:**  
C Language Wide-Character Codes are defined in detail in [*6.3 C Language Wide-Character Codes*](../basedefs/V1_chap06.html#tag_06_03).

### <span id="tag_03_418"></span>3.418 Wide-Character Input/Output Functions

The functions that perform wide-oriented input from streams or wide-oriented output to streams: [*fgetwc*()](../functions/fgetwc.html), [*fgetws*()](../functions/fgetws.html), [*fputwc*()](../functions/fputwc.html), [*fputws*()](../functions/fputws.html), [*fwprintf*()](../functions/fwprintf.html), [*fwscanf*()](../functions/fwscanf.html), [*getwc*()](../functions/getwc.html), [*getwchar*()](../functions/getwchar.html), [*putwc*()](../functions/putwc.html), [*putwchar*()](../functions/putwchar.html), [*ungetwc*()](../functions/ungetwc.html), [*vfwprintf*()](../functions/vfwprintf.html), [*vfwscanf*()](../functions/vfwscanf.html), [*vwprintf*()](../functions/vwprintf.html), [*vwscanf*()](../functions/vwscanf.html), [*wprintf*()](../functions/wprintf.html), and [*wscanf*()](../functions/wscanf.html).

**Note:**  
These functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_419"></span>3.419 Wide-Character String

A contiguous sequence of wide-character codes terminated by and including the first null wide-character code.

### <span id="tag_03_420"></span>3.420 Word

In the shell command language, a token other than an operator. In some cases a word is also a portion of a word token: in the various forms of parameter expansion, such as \${*name*-*word*}, and variable assignment, such as *name*=*word*, the word is the portion of the token depicted by *word*. The concept of a word is no longer applicable following word expansions—only fields remain.

**Note:**  
For further information, see XCU [*2.6.2 Parameter Expansion*](../utilities/V3_chap02.html#tag_19_06_02) and [*2.6 Word Expansions*](../utilities/V3_chap02.html#tag_19_06).

### <span id="tag_03_421"></span>3.421 Working Directory (or Current Working Directory)

A directory, associated with a process, that is used in pathname resolution for pathnames that do not begin with a \<slash\> character.

### <span id="tag_03_422"></span>3.422 Worldwide Portability Interface

Functions for handling characters in a codeset-independent manner.

### <span id="tag_03_423"></span>3.423 Write

To output characters to a file, such as standard output or standard error. Unless otherwise stated, standard output is the default output destination for all uses of the term "write"; see the distinction between display and write in [3.107 Display](#tag_03_107).

### <span id="tag_03_424"></span>3.424 XSI

The X/Open System Interfaces (XSI) option is the core application programming interface for C and [*sh*](../utilities/sh.html) programming for systems conforming to the Single UNIX Specification. This is a superset of the mandatory requirements for conformance to POSIX.1-2024.

### <span id="tag_03_425"></span>3.425 XSI-Conformant

A system which allows an application to be built using a set of services that are consistent across all systems that conform to POSIX.1-2024 and that support the XSI option.

**Note:**  
See also [*2. Conformance*](../basedefs/V1_chap02.html#tag_02).

### <span id="tag_03_426"></span>3.426 Zombie Process

The remains of a live process (see [3.189 Live Process](#tag_03_189)) after it terminates (see [3.287 Process Termination](#tag_03_287)) and before its status information (see XSH [*2.12 Status Information*](../functions/V2_chap02.html#tag_16_12)) is consumed by its parent process.

### <span id="tag_03_427"></span>3.427 Zombie Thread

The remains of a joinable live thread (see [3.183 Joinable Thread](#tag_03_183) and [3.190 Live Thread](#tag_03_190)) after it terminates (see [3.392 Thread Termination](#tag_03_392)) and before it has been joined with [*pthread_join*()](../functions/pthread_join.html) or [*thrd_join*()](../functions/thrd_join.html) or detached with [*pthread_detach*()](../functions/pthread_detach.html) or [*thrd_detach*()](../functions/thrd_detach.html).

**Note:**  
The [*pthread_detach*()](../functions/pthread_detach.html), [*pthread_join*()](../functions/pthread_join.html), [*thrd_detach*()](../functions/thrd_detach.html), and [*thrd_join*()](../functions/thrd_join.html) functions are defined in detail in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_03_428"></span>3.428 ±0

The algebraic sign provides additional information about any variable that has the value zero when the representation allows the sign to be determined.

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
