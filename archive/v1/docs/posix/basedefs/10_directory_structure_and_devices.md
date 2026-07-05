The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_10"></span>10. Directory Structure and Devices

### <span id="tag_10_01"></span>10.1 Directory Structure and Files

The following directories shall exist on conforming systems and conforming applications shall make use of them only as described. Strictly conforming applications shall not assume the ability to create files in any of these directories, unless specified below.

**/**

The root directory.

**/dev**

Contains **/dev/console**, **/dev/null**, and **/dev/tty**, described below.

The following directory shall exist on conforming systems and shall be used as described:

**/tmp**

A directory made available for applications that need a place to create temporary files. Applications shall be allowed to create files in this directory, but shall not assume that such files are preserved between invocations of the application.

The following files shall exist on conforming systems and shall be both readable and writable:

**/dev/null**

An empty data source and infinite data sink. Data written to **/dev/null** shall be discarded. Reads from **/dev/null** shall always return end-of-file (EOF).

**/dev/tty**

In each process, a synonym for the controlling terminal associated with the process group of that process, if any. It is useful for programs or shell procedures that wish to be sure of writing messages to or reading data from the terminal no matter how output has been redirected. It can also be used for applications that demand the name of a file for output, when typed output is desired and it is tiresome to find out what terminal is currently in use.

The following file shall exist on conforming systems and need not be readable or writable:

**/dev/console**

The **/dev/console** file is a generic name given to the system console (see [*3.376 System Console*](../basedefs/V1_chap03.html#tag_03_376)). It is usually linked to an implementation-defined special file. It shall provide an interface to the system console conforming to the requirements of [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11).

### <span id="tag_10_02"></span>10.2 Output Devices and Terminal Types

The utilities in the Shell and Utilities volume of POSIX.1-2024 historically have been implemented on a wide range of terminal types, but a conforming implementation need not support all features of all utilities on every conceivable terminal. POSIX.1-2024 states which features are optional for certain classes of terminals in the individual utility description sections. The implementation shall document in the system documentation which terminal types it supports and which of these features and utilities are not supported by each terminal.

When a feature or utility is not supported on a specific terminal type, as allowed by POSIX.1-2024, and the implementation considers such a condition to be an error preventing use of the feature or utility, the implementation shall indicate such conditions through diagnostic messages or exit status values or both (as appropriate to the specific utility description) that inform the user that the terminal type lacks the appropriate capability.

POSIX.1-2024 uses a notational convention based on historical practice that identifies some of the control characters defined in [*7.3.1 LC_CTYPE*](../basedefs/V1_chap07.html#tag_07_03_01) in a manner easily remembered by users on many terminals. The correspondence between this "\<control\>-*char*" notation and the actual control characters is shown in the following table. When POSIX.1-2024 refers to a character by its \<control\>-*name*, it is referring to the actual control character shown in the Value column of the table, which is not necessarily the exact control key sequence on all terminals. Some terminals have keyboards that do not allow the direct transmission of all the non-alphanumeric characters shown. In such cases, the system documentation shall describe which data sequences transmitted by the terminal are interpreted by the system as representing the special characters.\

<span id="tagtcjh_6"></span> Table: Control Character Names

| **Name**      | **Value** | **Name**       | **Value** |
|:--------------|:----------|:---------------|:----------|
| \<control\>-A | \<SOH\>   | \<control\>-Q  | \<DC1\>   |
| \<control\>-B | \<STX\>   | \<control\>-R  | \<DC2\>   |
| \<control\>-C | \<ETX\>   | \<control\>-S  | \<DC3\>   |
| \<control\>-D | \<EOT\>   | \<control\>-T  | \<DC4\>   |
| \<control\>-E | \<ENQ\>   | \<control\>-U  | \<NAK\>   |
| \<control\>-F | \<ACK\>   | \<control\>-V  | \<SYN\>   |
| \<control\>-G | \<BEL\>   | \<control\>-W  | \<ETB\>   |
| \<control\>-H | \<BS\>    | \<control\>-X  | \<CAN\>   |
| \<control\>-I | \<HT\>    | \<control\>-Y  | \<EM\>    |
| \<control\>-J | \<LF\>    | \<control\>-Z  | \<SUB\>   |
| \<control\>-K | \<VT\>    | \<control\>-\[ | \<ESC\>   |
| \<control\>-L | \<FF\>    | \<control\>-\\ | \<FS\>    |
| \<control\>-M | \<CR\>    | \<control\>-\] | \<GS\>    |
| \<control\>-N | \<SO\>    | \<control\>-^  | \<RS\>    |
| \<control\>-O | \<SI\>    | \<control\>-\_ | \<US\>    |
| \<control\>-P | \<DLE\>   | \<control\>-?  | \<DEL\>   |

**Note:**  
The notation uses uppercase letters for arbitrary editorial reasons. There is no implication that the keystrokes represent control-shift-letter sequences.

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
