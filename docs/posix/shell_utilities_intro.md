The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_18"></span>1. Introduction

The Shell and Utilities volume of POSIX.1-2024 describes the commands and utilities offered to application programs by POSIX-conformant systems.

### <span id="tag_18_01"></span>1.1 Relationship to Other Documents

#### <span id="tag_18_01_01"></span>1.1.1 System Interfaces

This subsection describes some of the features provided by the System Interfaces volume of POSIX.1-2024 that are assumed to be globally available on all systems conforming to this volume of POSIX.1-2024. This subsection does not attempt to detail all of the features defined in the System Interfaces volume of POSIX.1-2024 that are required by all of the utilities defined in this volume of POSIX.1-2024; the utility and function descriptions point out additional functionality required to provide the corresponding specific features needed by each.

The following subsections describe frequently used concepts. Many of these concepts are described in the Base Definitions volume of POSIX.1-2024. Utility and function description statements override these defaults when appropriate.

##### <span id="tag_18_01_01_01"></span>1.1.1.1 Process Attributes

The following process attributes, as described in the System Interfaces volume of POSIX.1-2024, are assumed to be supported for all processes in this volume of POSIX.1-2024:

<table data-cellpadding="3">
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr data-valign="top">
<td style="text-align: left;"><p><br />
Controlling Terminal<br />
Current Working Directory<br />
Effective Group ID<br />
Effective User ID<br />
File Descriptors<br />
File Mode Creation Mask<br />
Process Group ID<br />
Process ID<br />
</p></td>
<td style="text-align: left;"><p><br />
Real Group ID<br />
Real User ID<br />
Root Directory<br />
Saved Set-Group-ID<br />
Saved Set-User-ID<br />
Session Membership<br />
Supplementary Group IDs<br />
</p></td>
</tr>
</tbody>
</table>

A conforming implementation may include additional process attributes.

##### <span id="tag_18_01_01_02"></span>1.1.1.2 Concurrent Execution of Processes

The following functionality of the [*fork*()](../functions/fork.html) function defined in the System Interfaces volume of POSIX.1-2024 shall be available on all systems conforming to this volume of POSIX.1-2024:

1.  Independent processes shall be capable of executing independently without either process terminating.
2.  A process shall be able to create a new process with all of the attributes referenced in [1.1.1.1 Process Attributes](#tag_18_01_01_01), determined according to the semantics of a call to the [*fork*()](../functions/fork.html) function defined in the System Interfaces volume of POSIX.1-2024 followed by a call in the child process to one of the *exec* functions defined in the System Interfaces volume of POSIX.1-2024.

##### <span id="tag_18_01_01_03"></span>1.1.1.3 File Access Permissions

The file access control mechanism described by XBD [*4.7 File Access Permissions*](../basedefs/V1_chap04.html#tag_04_07) shall apply to all files on an implementation conforming to this volume of POSIX.1-2024.

##### <span id="tag_18_01_01_04"></span>1.1.1.4 File Read, Write, and Creation

If a file that does not exist is to be written, it shall be created as described below, unless the utility description states otherwise.

When a file that does not exist is created, the following features defined in the System Interfaces volume of POSIX.1-2024 shall apply unless the utility or function description states otherwise:

1.  The user ID of the file shall be set to the effective user ID of the calling process.

2.  The group ID of the file shall be set to the effective group ID of the calling process or the group ID of the directory in which the file is being created.

3.  If the file is a regular file, the permission bits of the file shall be set to: S_IROTH \| S_IWOTH \| S_IRGRP \| S_IWGRP \| S_IRUSR \| S_IWUSR

    (see the description of *File Modes* in XBD [*14. Headers*](../basedefs/V1_chap14.html#tag_14) , [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html)) except that the bits specified by the file mode creation mask of the process shall be cleared. If the file is a directory, the permission bits shall be set to: S_IRWXU \| S_IRWXG \| S_IRWXO

    except that the bits specified by the file mode creation mask of the process shall be cleared.

4.  The last data access, last data modification, and last file status change timestamps of the file shall be updated as specified in XBD [*4.12 File Times Update*](../basedefs/V1_chap04.html#tag_04_12).

5.  If the file is a directory, it shall be an empty directory; otherwise, the file shall have length zero.

6.  If the file is a symbolic link, the effect shall be undefined unless the {POSIX2_SYMLINKS} variable is in effect for the directory in which the symbolic link would be created.

7.  Unless otherwise specified, the file created shall be a regular file.

When an attempt is made to create a file that already exists, the utility shall take the action indicated in [Actions when Creating a File that Already Exists](#tagtcjh_9) corresponding to the type of the file the utility is trying to create and the type of the existing file, unless the utility description states otherwise.

<span id="tagtcjh_9"></span> Table: Actions when Creating a File that Already Exists

<table data-border="1" data-cellpadding="3" data-align="center">
<thead>
<tr data-valign="top">
<th colspan="2" style="text-align: center;"><p><strong> </strong></p></th>
<th colspan="11" style="text-align: center;"><p><strong>New Type</strong></p></th>
<th style="text-align: center;"><p><strong> </strong></p></th>
</tr>
</thead>
<tbody>
<tr data-valign="top">
<th colspan="2" style="text-align: center;"><p><strong>Existing Type</strong></p></th>
<th style="text-align: center;"><p><strong>B</strong></p></th>
<th style="text-align: center;"><p><strong>C</strong></p></th>
<th style="text-align: center;"><p><strong>D</strong></p></th>
<th style="text-align: center;"><p><strong>F</strong></p></th>
<th style="text-align: center;"><p><strong>L</strong></p></th>
<th style="text-align: center;"><p><strong>M</strong></p></th>
<th style="text-align: center;"><p><strong>P</strong></p></th>
<th style="text-align: center;"><p><strong>Q</strong></p></th>
<th style="text-align: center;"><p><strong>R</strong></p></th>
<th style="text-align: center;"><p><strong>S</strong></p></th>
<th style="text-align: center;"><p><strong>T</strong></p></th>
<th style="text-align: center;"><p><strong>Function Creating New</strong></p></th>
</tr>
&#10;<tr data-valign="top">
<td style="text-align: left;"><p>B</p></td>
<td style="text-align: left;"><p>Block Special</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>OF</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>mknod</em>()**</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>C</p></td>
<td style="text-align: left;"><p>Character Special</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>OF</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>mknod</em>()**</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>D</p></td>
<td style="text-align: left;"><p>Directory</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>mkdir</em>()</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>F</p></td>
<td style="text-align: left;"><p>FIFO Special File</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>O</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>mkfifo</em>()</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>L</p></td>
<td style="text-align: left;"><p>Symbolic Link</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>FL</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>symlink</em>()</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>M</p></td>
<td style="text-align: left;"><p>Shared Memory</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>shm_open</em>()</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>P</p></td>
<td style="text-align: left;"><p>Semaphore</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>sem_open</em>()</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>Q</p></td>
<td style="text-align: left;"><p>Message Queue</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>mq_open</em>()</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>R</p></td>
<td style="text-align: left;"><p>Regular File</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>RF</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>open</em>()</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>S</p></td>
<td style="text-align: left;"><p>Socket</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>—</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p><em>bind</em>()</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>T</p></td>
<td style="text-align: left;"><p>Typed Memory</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>F</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: center;"><p>U</p></td>
<td style="text-align: left;"><p>*</p></td>
</tr>
</tbody>
</table>

The following codes are used in [Actions when Creating a File that Already Exists](#tagtcjh_9):

F

Fail. The attempt to create the new file shall fail and the utility shall either continue with its operation or exit immediately with an exit status that indicates an error occurred, depending on the description of the utility.

FL

Follow link. Unless otherwise specified, the symbolic link shall be followed as specified for pathname resolution, and the operation performed shall be as if the target of the symbolic link (after all resolution) had been named. If the target of the symbolic link does not exist, it shall be as if that nonexistent target had been named directly.

O

Open FIFO. When attempting to create a regular file, and the existing file is a FIFO special file:

1.  If the FIFO is not already open for reading, the attempt shall block until the FIFO is opened for reading.
2.  Once the FIFO is open for reading, the utility shall open the FIFO for writing and continue with its operation.

OF

The named file shall be opened with the consequences defined for that file type.

RF

Regular file. When attempting to create a regular file, and the existing file is a regular file:

1.  The user ID, group ID, and permission bits of the file shall not be changed.
2.  The file shall be truncated to zero length.
3.  The last data modification and last file status change timestamps shall be marked for update.

—

The effect is implementation-defined unless specified by the utility description.

U

The effect is unspecified unless specified by the utility description.

\*

There is no portable way to create a file of this type.

\*\*

Not portable.

When a file is to be appended, the file shall be opened in a manner equivalent to using the O_APPEND flag, without the O_TRUNC flag, in the [*open*()](../functions/open.html) function defined in the System Interfaces volume of POSIX.1-2024.

When a file is to be read or written, the file shall be opened with an access mode corresponding to the operation to be performed. If file access permissions deny access, the requested operation shall fail.

##### <span id="tag_18_01_01_05"></span>1.1.1.5 File Removal

When a directory that is the root directory or current working directory of any process is removed, the effect is implementation-defined. If file access permissions deny access, the requested operation shall fail. Otherwise, when a file is removed:

1.  Its directory entry shall be removed from the file system.
2.  The link count of the file shall be decremented.
3.  If the file is an empty directory (see XBD [*3.119 Empty Directory*](../basedefs/V1_chap03.html#tag_03_119)):
    1.  If no process has the directory open, the space occupied by the directory shall be freed and the directory shall no longer be accessible.
    2.  If one or more processes have the directory open, the directory contents shall be preserved until all references to the file have been closed.
4.  If the file is a directory that is not empty, the last file status change timestamp shall be marked for update.
5.  If the file is not a directory:
    1.  If the link count becomes zero:
        1.  If no process has the file open, the space occupied by the file shall be freed and the file shall no longer be accessible.
        2.  If one or more processes have the file open, the file contents shall be preserved until all references to the file have been closed.
    2.  If the link count is not reduced to zero, the last file status change timestamp shall be marked for update.
6.  The last data modification and last file status change timestamps of the containing directory shall be marked for update.

##### <span id="tag_18_01_01_06"></span>1.1.1.6 File Time Values

All files shall have the three time values described by XBD [*4.12 File Times Update*](../basedefs/V1_chap04.html#tag_04_12).

##### <span id="tag_18_01_01_07"></span>1.1.1.7 File Contents

When a reference is made to the contents of a file, *pathname*, this means the equivalent of all of the data placed in the space pointed to by *buf* when performing the [*read*()](../functions/read.html) function calls in the following operations defined in the System Interfaces volume of POSIX.1-2024:


    while (read (fildes, buf, nbytes) > 0)
        ;

If the file is indicated by a pathname *pathname*, the file descriptor shall be determined by the equivalent of the following operation defined in the System Interfaces volume of POSIX.1-2024:


    fildes = open (pathname, O_RDONLY);

The value of *nbytes* in the above sequence is unspecified; if the file is of a type where the data returned by [*read*()](../functions/read.html) would vary with different values, the value shall be one that results in the most data being returned.

If the [*read*()](../functions/read.html) function calls would return an error, it is unspecified whether the contents of the file are considered to include any data from offsets in the file beyond where the error would be returned.

##### <span id="tag_18_01_01_08"></span>1.1.1.8 Pathname Resolution

The pathname resolution algorithm, described by XBD [*4.16 Pathname Resolution*](../basedefs/V1_chap04.html#tag_04_16), shall be used by implementations conforming to this volume of POSIX.1-2024; see also XBD [*4.8 File Hierarchy*](../basedefs/V1_chap04.html#tag_04_08).

##### <span id="tag_18_01_01_09"></span>1.1.1.9 Changing the Current Working Directory

When the current working directory (see XBD [*3.94 Current Working Directory*](../basedefs/V1_chap03.html#tag_03_94)) is to be changed, unless the utility or function description states otherwise, the operation shall succeed unless a call to the [*chdir*()](../functions/chdir.html) function defined in the System Interfaces volume of POSIX.1-2024 would fail when invoked with the new working directory pathname as its argument.

##### <span id="tag_18_01_01_10"></span>1.1.1.10 Establish the Locale

The functionality of the [*setlocale*()](../functions/setlocale.html) function defined in the System Interfaces volume of POSIX.1-2024 shall be available on all systems conforming to this volume of POSIX.1-2024; that is, utilities that require the capability of establishing an international operating environment shall be permitted to set the specified category of the international environment.

##### <span id="tag_18_01_01_11"></span>1.1.1.11 Actions Equivalent to Functions

Some utility descriptions specify that a utility performs actions equivalent to a function defined in the System Interfaces volume of POSIX.1-2024. Such specifications require only that the external effects be equivalent, not that any effect within the utility and visible only to the utility be equivalent.

#### <span id="tag_18_01_02"></span>1.1.2 Concepts Derived from the ISO C Standard

Some of the standard utilities perform complex data manipulation using their own procedure and arithmetic languages, as defined in their EXTENDED DESCRIPTION or OPERANDS sections. Unless otherwise noted, the arithmetic and semantic concepts (precision, type conversion, control flow, and so on) shall be equivalent to those defined in the ISO C standard, as described in the following sections. Note that there is no requirement that the standard utilities be implemented in any particular programming language.

##### <span id="tag_18_01_02_01"></span>1.1.2.1 Arithmetic Precision and Operations

Integer variables and constants, including the values of operands and option-arguments, used by the standard utilities listed in this volume of POSIX.1-2024 shall be implemented as equivalent to the ISO C standard **signed long** data type; floating point shall be implemented as equivalent to the ISO C standard **double** type. Conversions between types shall be as described in the ISO C standard. All variables shall be initialized to zero if they are not otherwise assigned by the input to the application.

Arithmetic operators and control flow keywords shall be implemented as equivalent to those in the cited ISO C standard section, as listed in [Selected ISO C Standard Operators and Control Flow Keywords](#tagtcjh_10).

**Note:**  
The comma operator (section 6.5.17 of the ISO C standard) is intentionally not included in the table. It need not be supported by implementations.

<span id="tagtcjh_10"></span> Table: Selected ISO C Standard Operators and Control Flow Keywords

<table data-border="1" data-cellpadding="3" data-align="center">
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr data-valign="top">
<th style="text-align: center;"><p><strong>Operation</strong></p></th>
<th style="text-align: center;"><p><strong>ISO C Standard Equivalent Reference</strong></p></th>
</tr>
</thead>
<tbody>
<tr data-valign="top">
<td style="text-align: left;"><p>()</p></td>
<td style="text-align: left;"><p>Section 6.5.1, Primary Expressions</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>postfix ++<br />
postfix --</p></td>
<td style="text-align: left;"><p>Section 6.5.2, Postfix Operators</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>unary +<br />
unary -<br />
prefix ++<br />
prefix --<br />
~<br />
!<br />
<em>sizeof</em>()</p></td>
<td style="text-align: left;"><p>Section 6.5.3, Unary Operators</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>*<br />
/<br />
%</p></td>
<td style="text-align: left;"><p>Section 6.5.5, Multiplicative Operators</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>+<br />
-</p></td>
<td style="text-align: left;"><p>Section 6.5.6, Additive Operators</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>&lt;&lt;<br />
&gt;&gt;</p></td>
<td style="text-align: left;"><p>Section 6.5.7, Bitwise Shift Operators</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>&lt;, &lt;=<br />
&gt;, &gt;=</p></td>
<td style="text-align: left;"><p>Section 6.5.8, Relational Operators</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>==<br />
!=</p></td>
<td style="text-align: left;"><p>Section 6.5.9, Equality Operators</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>&amp;</p></td>
<td style="text-align: left;"><p>Section 6.5.10, Bitwise AND Operator</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>^</p></td>
<td style="text-align: left;"><p>Section 6.5.11, Bitwise Exclusive OR Operator</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>|</p></td>
<td style="text-align: left;"><p>Section 6.5.12, Bitwise Inclusive OR Operator</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>&amp;&amp;</p></td>
<td style="text-align: left;"><p>Section 6.5.13, Logical AND Operator</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>||</p></td>
<td style="text-align: left;"><p>Section 6.5.14, Logical OR Operator</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><em>expr</em>?<em>expr</em>:<em>expr</em></p></td>
<td style="text-align: left;"><p>Section 6.5.15, Conditional Operator</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p>=, *=, /=, %=, +=, -=<br />
&lt;&lt;=, &gt;&gt;=, &amp;=, ^=, |=</p></td>
<td style="text-align: left;"><p>Section 6.5.16, Assignment Operators</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>if</strong> ()<br />
<strong>if</strong> () ... <strong>else</strong><br />
<strong>switch</strong> ()</p></td>
<td style="text-align: left;"><p>Section 6.8.4, Selection Statements</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>while</strong> ()<br />
<strong>do</strong> ... <strong>while</strong> ()<br />
<strong>for</strong> ()</p></td>
<td style="text-align: left;"><p>Section 6.8.5, Iteration Statements</p></td>
</tr>
<tr data-valign="top">
<td style="text-align: left;"><p><strong>goto</strong><br />
<strong>continue</strong><br />
<strong>break</strong><br />
<strong>return</strong></p></td>
<td style="text-align: left;"><p>Section 6.8.6, Jump Statements</p></td>
</tr>
</tbody>
</table>

\

The evaluation of arithmetic expressions shall be equivalent to that described in Section 6.5, Expressions, of the ISO C standard.

##### <span id="tag_18_01_02_02"></span>1.1.2.2 Mathematical Functions

Any mathematical functions with the same names as those in the following sections of the ISO C standard:

- Section 7.12, Mathematics, `<math.h>`
- Section 7.22.2, Pseudo-Random Sequence Generation Functions

shall be implemented to return the results equivalent to those returned from a call to the corresponding function described in the ISO C standard.

### <span id="tag_18_02"></span>1.2 Utility Limits

This section lists magnitude limitations imposed by a specific implementation. The braces notation, {LIMIT}, is used in this volume of POSIX.1-2024 to indicate these values, but the braces are not part of the name.\

<span id="tagtcjh_11"></span> Table: Utility Limit Minimum Values

| **Name** | **Description** | **Value** |
|:---|:---|:---|
| {POSIX2_BC_BASE_MAX} | The maximum *obase* value allowed by the [*bc*](../utilities/bc.html) utility. | 99 |
| {POSIX2_BC_DIM_MAX} | The maximum number of elements permitted in an array by the [*bc*](../utilities/bc.html) utility. | 2048 |
| {POSIX2_BC_SCALE_MAX} | The maximum *scale* value allowed by the [*bc*](../utilities/bc.html) utility. | 99 |
| {POSIX2_BC_STRING_MAX} | The maximum length of a string constant accepted by the [*bc*](../utilities/bc.html) utility. | 1000 |
| {POSIX2_COLL_WEIGHTS_MAX} | The maximum number of weights that can be assigned to an entry of the *LC_COLLATE* **order** keyword in the locale definition file; see the **border_start** keyword in XBD [*7.3.2 LC_COLLATE*](../basedefs/V1_chap07.html#tag_07_03_02). | 2 |
| {POSIX2_EXPR_NEST_MAX} | The maximum number of expressions that can be nested within parentheses by the [*expr*](../utilities/expr.html) utility. | 32 |
| {POSIX2_LINE_MAX} | Unless otherwise noted, the maximum length, in bytes, of the input line of a utility (either standard input or another file), when the utility is described as processing text files. The length includes room for the trailing \<newline\>. | 2048 |
| {POSIX_RE_DUP_MAX} | Maximum number of repeated occurrences of a BRE or ERE interval expression; see XBD [*9.3.6 BREs Matching Multiple Characters*](../basedefs/V1_chap09.html#tag_09_03_06) and [*9.4.6 EREs Matching Multiple Characters*](../basedefs/V1_chap09.html#tag_09_04_06). | 255 |

The values specified in [Utility Limit Minimum Values](#tagtcjh_11) represent the lowest values conforming implementations shall provide and, consequently, the largest values on which an application can rely without further enquiries, as described below. These values shall be accessible to applications via the [*getconf*](../utilities/getconf.html) utility (see [*getconf*](../utilities/getconf.html#)).

Implementations may provide more liberal, or less restrictive, values than shown in [Utility Limit Minimum Values](#tagtcjh_11). These possibly more liberal values are accessible using the symbols in [Symbolic Utility Limits](#tagtcjh_12).

The [*sysconf*()](../functions/sysconf.html) function defined in the System Interfaces volume of POSIX.1-2024 or the [*getconf*](../utilities/getconf.html) utility return the value of each symbol on each specific implementation. The value so retrieved is the largest, or most liberal, value that is available throughout the session lifetime, as determined at session creation. The literal names shown in the table apply only to the [*getconf*](../utilities/getconf.html) utility; the high-level language binding describes the exact form of each name to be used by the interfaces in that binding.

All numeric limits defined by the System Interfaces volume of POSIX.1-2024, such as {PATH_MAX}, shall also apply to this volume of POSIX.1-2024. All the utilities defined by this volume of POSIX.1-2024 are implicitly limited by these values, unless otherwise noted in the utility descriptions.

It is not guaranteed that the application can actually reach the specified limit of an implementation in any given case, or at all, as a lack of virtual memory or other resources may prevent this. The limit value indicates only that the implementation does not specifically impose any arbitrary, more restrictive limit.\

<span id="tagtcjh_12"></span> Table: Symbolic Utility Limits

| **Name** | **Description** | **Minimum Value** |
|:---|:---|:---|
| {BC_BASE_MAX} | The maximum *obase* value allowed by the [*bc*](../utilities/bc.html) utility. | {POSIX2_BC_BASE_MAX} |
| {BC_DIM_MAX} | The maximum number of elements permitted in an array by the [*bc*](../utilities/bc.html) utility. | {POSIX2_BC_DIM_MAX} |
| {BC_SCALE_MAX} | The maximum *scale* value allowed by the [*bc*](../utilities/bc.html) utility. | {POSIX2_BC_SCALE_MAX} |
| {BC_STRING_MAX} | The maximum length of a string constant accepted by the [*bc*](../utilities/bc.html) utility. | {POSIX2_BC_STRING_MAX} |
| {COLL_WEIGHTS_MAX} | The maximum number of weights that can be assigned to an entry of the *LC_COLLATE* **order** keyword in the locale definition file; see the **order_start** keyword in XBD [*7.3.2 LC_COLLATE*](../basedefs/V1_chap07.html#tag_07_03_02). | {POSIX2_COLL_WEIGHTS_MAX} |
| {EXPR_NEST_MAX} | The maximum number of expressions that can be nested within parentheses by the [*expr*](../utilities/expr.html) utility. | {POSIX2_EXPR_NEST_MAX} |
| {LINE_MAX} | Unless otherwise noted, the maximum length, in bytes, of the input line of a utility (either standard input or another file), when the utility is described as processing text files. The length includes room for the trailing \<newline\>. | {POSIX2_LINE_MAX} |
| {RE_DUP_MAX} | Maximum number of repeated occurrences of a BRE or ERE interval expression; see XBD [*9.3.6 BREs Matching Multiple Characters*](../basedefs/V1_chap09.html#tag_09_03_06) and [*9.4.6 EREs Matching Multiple Characters*](../basedefs/V1_chap09.html#tag_09_04_06). | {POSIX_RE_DUP_MAX} |

The following value may be a constant within an implementation or may vary from one pathname to another.

{POSIX2_SYMLINKS}

\
When referring to a directory, the system supports the creation of symbolic links within that directory; for non-directory files, the meaning of {POSIX2_SYMLINKS} is undefined.

### <span id="tag_18_03"></span>1.3 Grammar Conventions

Portions of this volume of POSIX.1-2024 are expressed in terms of a special grammar notation. It is used to portray the complex syntax of certain program input. The grammar is based on the syntax used by the [*yacc*](../utilities/yacc.html) utility. However, it does not represent fully functional [*yacc*](../utilities/yacc.html) input, suitable for program use; the lexical processing and all semantic requirements are described only in textual form. The grammar is not based on source used in any traditional implementation and has not been tested with the semantic code that would normally be required to accompany it. Furthermore, there is no implication that the partial [*yacc*](../utilities/yacc.html) code presented represents the most efficient, or only, means of supporting the complex syntax within the utility. Implementations may use other programming languages or algorithms, as long as the syntax supported is the same as that represented by the grammar.

The following typographical conventions are used in the grammar; they have no significance except to aid in reading.

- The identifiers for the reserved words of the language are shown with a leading capital letter. (These are terminals in the grammar; for example, **While**, **Case**.)
- The identifiers for terminals in the grammar are all named with uppercase letters and underscores; for example, **NEWLINE**, **ASSIGN_OP**, **NAME**.
- The identifiers for non-terminals are all lowercase.

### <span id="tag_18_04"></span>1.4 Utility Description Defaults

This section describes all of the subsections used within the utility descriptions, including:

- Intended usage of the section
- Global defaults that affect all the standard utilities
- The meanings of notations used in this volume of POSIX.1-2024 that are specific to individual utility sections

**NAME**

\
This section gives the name or names of the utility and briefly states its purpose.

**SYNOPSIS**

\
The SYNOPSIS section summarizes the syntax of the calling sequence for the utility, including options, option-arguments, and operands. Standards for utility naming are described in XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02); for describing the utility's arguments in XBD [*12.1 Utility Argument Syntax*](../basedefs/V1_chap12.html#tag_12_01).

**DESCRIPTION**

\
The DESCRIPTION section describes the actions of the utility. If the utility has a very complex set of subcommands or its own procedural language, an EXTENDED DESCRIPTION section is also provided. Most explanations of optional functionality are omitted here, as they are usually explained in the OPTIONS section.

As stated in [1.1.1.11 Actions Equivalent to Functions](#tag_18_01_01_11), some functions are described in terms of equivalent functionality. When specific functions are cited, the implementation shall provide equivalent functionality including side-effects associated with successful execution of the function. The treatment of errors and intermediate results from the individual functions cited is generally not specified by this volume of POSIX.1-2024. See the utility's EXIT STATUS and CONSEQUENCES OF ERRORS sections for all actions associated with errors encountered by the utility.

A standard utility shall not be treated as a declaration utility unless explicitly stated in this section.

**OPTIONS**

\
The OPTIONS section describes the utility options and option-arguments, and how they modify the actions of the utility. Standard utilities that have options either fully comply with XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02) or describe all deviations. Apparent disagreements between functionality descriptions in the OPTIONS and DESCRIPTION (or EXTENDED DESCRIPTION) sections are always resolved in favor of the OPTIONS section.

Each OPTIONS section that uses the phrase "The ... utility shall conform to the Utility Syntax Guidelines ..." refers only to the use of the utility as specified by this volume of POSIX.1-2024; implementation extensions should also conform to the guidelines, but may allow exceptions for historical practice.

Unless otherwise stated in the utility description, when given an option unrecognized by the implementation, or when a required option-argument is not provided, standard utilities shall issue a diagnostic message to standard error and exit with an exit status that indicates an error occurred.

All utilities in this volume of POSIX.1-2024 shall be capable of processing arguments using eight-bit transparency.

**Default Behavior:** When this section is listed as "None.", it means that the implementation need not support any options. Standard utilities that do not accept options, but that do accept operands, shall recognize `"--"` as a first argument to be discarded.

The requirement for recognizing `"--"` is because conforming applications need a way to shield their operands from any arbitrary options that the implementation may provide as an extension. For example, if the standard utility *foo* is listed as taking no options, and the application needed to give it a pathname with a leading \<hyphen-minus\>, it could safely do it as:


    foo -- -myfile

and avoid any problems with **-m** used as an extension.

**OPERANDS**

\
The OPERANDS section describes the utility operands, and how they affect the actions of the utility. Apparent disagreements between functionality descriptions in the OPERANDS and DESCRIPTION (or EXTENDED DESCRIPTION) sections shall be resolved in favor of the OPERANDS section.

If an operand naming a file can be specified as `'-'`, which means to use the standard input instead of a named file, this is explicitly stated in this section. Unless otherwise stated, the use of multiple instances of `'-'` to mean standard input in a single command produces unspecified results.

Unless otherwise stated, the standard utilities that accept operands shall process those operands in the order specified in the command line.

**Default Behavior:** When this section is listed as "None.", it means that the implementation need not support any operands.

**STDIN**

\
The STDIN section describes the standard input of the utility. This section is frequently merely a reference to the following section, as many utilities treat standard input and input files in the same manner. Unless otherwise stated, all restrictions described in the INPUT FILES section shall apply to this section as well.

Use of a terminal for standard input can cause any of the standard utilities that read standard input to stop when used in the background. For this reason, applications should not use interactive features in scripts to be placed in the background.

The specified standard input format of the standard utilities shall not depend on the existence or value of the environment variables defined in this volume of POSIX.1-2024, except as provided by this volume of POSIX.1-2024.

**Default Behavior:** When this section is listed as "Not used.", it means that the standard input shall not be read when the utility is used as described by this volume of POSIX.1-2024.

**INPUT FILES**

\
The INPUT FILES section describes the files, other than the standard input, used as input by the utility. It includes files named as operands and option-arguments as well as other files that are referred to, such as start-up and initialization files, databases, and so on. Commonly-used files are generally described in one place and cross-referenced by other utilities.

All utilities in this volume of POSIX.1-2024 shall be capable of processing input files using eight-bit transparency.

When a standard utility reads a seekable input file and terminates without an error before it reaches end-of-file, the utility shall ensure that the file offset in the open file description is properly positioned just past the last byte processed by the utility. For files that are not seekable, the state of the file offset in the open file description for that file is unspecified. A conforming application shall not assume that the following three commands are equivalent:


    tail -n +2 file
    (sed -n 1q; cat) < file
    cat file | (sed -n 1q; cat)

The second command is equivalent to the first only when the file is seekable. The third command leaves the file offset in the open file description in an unspecified state. Other utilities, such as [*head*](../utilities/head.html), [*read*](../utilities/read.html), and [*sh*](../utilities/sh.html), have similar properties.

Some of the standard utilities, such as filters, process input files a line or a block at a time and have no restrictions on the maximum input file size. Some utilities may have size limitations that are not as obvious as file space or memory limitations. Such limitations should reflect resource limitations of some sort, not arbitrary limits set by implementors. Implementations shall document those utilities that are limited by constraints other than file system space, available memory, and other limits specifically cited by this volume of POSIX.1-2024, and identify what the constraint is and indicate a way of estimating when the constraint would be reached. Similarly, some utilities descend the directory tree (recursively). Implementations shall also document any limits that they may have in descending the directory tree that are beyond limits cited by this volume of POSIX.1-2024.

When an input file is described as a "text file", the utility produces undefined results if given input that is not from a text file, unless otherwise stated. Some utilities (for example, [*make*](../utilities/make.html), [*read*](../utilities/read.html), [*sh*](../utilities/sh.html)) allow for continued input lines using an escaped \<newline\> convention; unless otherwise stated, the utility need not be able to accumulate more than {LINE_MAX} bytes from a set of multiple, continued input lines. Thus, for a conforming application the total of all the continued lines in a set cannot exceed {LINE_MAX}. If a utility using the escaped \<newline\> convention detects an end-of-file condition immediately after an escaped \<newline\>, the results are unspecified.

Record formats are described in a notation similar to that used by the C-language function, [*printf*()](../functions/printf.html). See XBD [*5. File Format Notation*](../basedefs/V1_chap05.html#tag_05) for a description of this notation. The format description is intended to be sufficiently rigorous to allow other applications to generate these input files. However, since \<blank\>s can legitimately be included in some of the fields described by the standard utilities, particularly in locales other than the POSIX locale, this intent is not always realized.

**Default Behavior:** When this section is listed as "None.", it means that no input files are required to be supplied when the utility is used as described by this volume of POSIX.1-2024.

**ENVIRONMENT VARIABLES**

\
The ENVIRONMENT VARIABLES section lists what variables affect the utility's execution.

The entire manner in which environment variables described in this volume of POSIX.1-2024 affect the behavior of each utility is described in the ENVIRONMENT VARIABLES section for that utility, in conjunction with the global effects of the *LANG ,* *LC_ALL ,* and <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> *NLSPATH* <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> environment variables described in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08). The existence or value of environment variables described in this volume of POSIX.1-2024 shall not otherwise affect the specified behavior of the standard utilities. Any effects of the existence or value of environment variables not described by this volume of POSIX.1-2024 upon the standard utilities are unspecified.

For those standard utilities that use environment variables as a means for selecting a utility to execute (such as *CC* in [*make*](../utilities/make.html)), the string provided to the utility is subjected to the path search described for *PATH* in XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08).

All utilities in this volume of POSIX.1-2024 shall be capable of processing environment variable names and values using eight-bit transparency.

**Default Behavior:** When this section is listed as "None.", it means that the behavior of the utility is not directly affected by environment variables described by this volume of POSIX.1-2024 when the utility is used as described by this volume of POSIX.1-2024.

**ASYNCHRONOUS EVENTS**

\
The ASYNCHRONOUS EVENTS section lists how the utility reacts to such events as signals and what signals are caught.

**Default Behavior:** When this section is listed as "Default.", or it refers to "the standard action" for any signal, it means that the action taken as a result of the signal shall be as follows:

- If the action inherited from the invoking process, according to the rules of inheritance of signal actions defined in the System Interfaces volume of POSIX.1-2024, is for the signal to be ignored, the utility shall ignore the signal.
- If the action inherited from the invoking process, according to the rules of inheritance of signal actions defined in System Interfaces volume of POSIX.1-2024, is the default signal action, the result of the utility's execution shall be as if the default signal action had been taken.

When the required action is for the signal to terminate the utility, the utility may catch the signal, perform some additional processing (such as deleting temporary files), restore the default signal action, and resignal itself.

**STDOUT**

\
The STDOUT section completely describes the standard output of the utility. This section is frequently merely a reference to the following section, OUTPUT FILES, because many utilities treat standard output and output files in the same manner.

Use of a terminal for standard output may cause any of the standard utilities that write standard output to stop when used in the background. For this reason, applications should not use interactive features in scripts to be placed in the background.

Record formats are described in a notation similar to that used by the C-language function, [*printf*()](../functions/printf.html). See XBD [*5. File Format Notation*](../basedefs/V1_chap05.html#tag_05) for a description of this notation.

The specified standard output of the standard utilities shall not depend on the existence or value of the environment variables defined in this volume of POSIX.1-2024, except as provided by this volume of POSIX.1-2024.

Some of the standard utilities describe their output using the verb *display*, defined in XBD [*3.107 Display*](../basedefs/V1_chap03.html#tag_03_107). Output described in the STDOUT sections of such utilities may be produced using means other than standard output. When standard output is directed to a terminal, the output described shall be written directly to the terminal. Otherwise, the results are undefined.

**Default Behavior:** When this section is listed as "Not used.", it means that the standard output shall not be written when the utility is used as described by this volume of POSIX.1-2024.

**STDERR**

\
The STDERR section describes the standard error output of the utility. Only those messages that are purposely sent by the utility are described.

Use of a terminal for standard error may cause any of the standard utilities that write standard error output to stop when used in the background. For this reason, applications should not use interactive features in scripts to be placed in the background.

The format of diagnostic messages for most utilities is unspecified, but the language and cultural conventions of diagnostic and informative messages whose format is unspecified by this volume of POSIX.1-2024 should be affected by the setting of *LC_MESSAGES* and <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> *NLSPATH .* <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

The specified standard error output of standard utilities shall not depend on the existence or value of the environment variables defined in this volume of POSIX.1-2024, except as provided by this volume of POSIX.1-2024.

**Default Behavior:** When this section is listed as "The standard error shall be used only for diagnostic messages.", it means that, unless otherwise stated, the diagnostic messages shall be sent to the standard error only when the exit status indicates that an error occurred and the utility is used as described by this volume of POSIX.1-2024.

When this section is listed as "Not used.", it means that the standard error shall not be used when the utility is used as described in this volume of POSIX.1-2024.

**OUTPUT FILES**

\
The OUTPUT FILES section completely describes the files created or modified by the utility. Temporary or system files that are created for internal usage by this utility or other parts of the implementation (for example, spool, log, and audit files) are not described in this, or any, section. The utilities creating such files and the names of such files are unspecified. If applications are written to use temporary or intermediate files, they should use the *TMPDIR* environment variable, if it is set and represents an accessible directory, to select the location of temporary files.

Implementations shall ensure that temporary files, when used by the standard utilities, are named so that different utilities or multiple instances of the same utility can operate simultaneously without regard to their working directories, or any other process characteristic other than process ID. There are two exceptions to this rule:

1.  Resources for temporary files other than the name space (for example, disk space, available directory entries, or number of processes allowed) are not guaranteed.
2.  Certain standard utilities generate output files that are intended as input for other utilities (for example, [*lex*](../utilities/lex.html) generates **lex.yy.c**), and these cannot have unique names. These cases are explicitly identified in the descriptions of the respective utilities.

Any temporary file created by the implementation shall be removed by the implementation upon a utility's successful exit, exit because of errors, or before termination by any of the SIGHUP, SIGINT, or SIGTERM signals, unless specified otherwise by the utility description.

Receipt of the SIGQUIT signal should generally cause termination (unless in some debugging mode) that would bypass any attempted recovery actions.

Record formats are described in a notation similar to that used by the C-language function, [*printf*()](../functions/printf.html); see XBD [*5. File Format Notation*](../basedefs/V1_chap05.html#tag_05) for a description of this notation.

**Default Behavior:** When this section is listed as "None.", it means that no files are created or modified as a consequence of direct action on the part of the utility when the utility is used as described by this volume of POSIX.1-2024. However, the utility may create or modify system files, such as log files, that are outside the utility's normal execution environment.

**EXTENDED DESCRIPTION**

\
The EXTENDED DESCRIPTION section provides a place for describing the actions of very complicated utilities, such as text editors or language processors, which typically have elaborate command languages.

**Default Behavior:** When this section is listed as "None.", no further description is necessary.

**EXIT STATUS**

\
The EXIT STATUS section describes the values the utility shall return to the calling program, or shell, and the conditions that cause these values to be returned. Usually, utilities return zero for successful completion and values greater than zero for various error conditions. If specific numeric values are listed in this section, the system shall use those values for the errors described. In some cases, status values are listed more loosely, such as \>0. A strictly conforming application shall not rely on any specific value in the range shown and shall be prepared to receive any value in the range.

For example, a utility may list zero as a successful return, 1 as a failure for a specific reason, and \>1 as "an error occurred". In this case, unspecified conditions may cause a 2 or 3, or other value, to be returned. A conforming application should be written so that it tests for successful exit status values (zero in this case), rather than relying upon the single specific error value listed in this volume of POSIX.1-2024. In that way, it has maximum portability, even on implementations with extensions.

Unspecified error conditions may be represented by specific values not listed in this volume of POSIX.1-2024.

**Default Behavior:** When the description of exit status 0 is "Successful completion", it means that exit status 0 shall indicate that all of the actions the utility is required to perform were completed successfully.

**CONSEQUENCES OF ERRORS**

\
The CONSEQUENCES OF ERRORS section describes the effects on the environment, file systems, process state, and so on, when error conditions occur. It does not describe error messages produced or exit status values used.

The many reasons for failure of a utility are generally not specified by the utility descriptions. Utilities may terminate prematurely if they encounter: invalid usage of options, arguments, or environment variables; invalid usage of the complex syntaxes expressed in EXTENDED DESCRIPTION sections; resource exhaustion; difficulties accessing, creating, reading, or writing files; or difficulties associated with the privileges of the process.

The following shall apply to each utility, unless otherwise stated:

- If the requested action cannot be performed on an operand representing a file, directory, user, process, and so on, the utility shall issue a diagnostic message to standard error and continue processing the next operand in sequence, but the final exit status shall be one that indicates an error occurred.

  For a utility that recursively traverses a file hierarchy (such as [*find*](../utilities/find.html) or [*chown*](../utilities/chown.html) **-R**), if the requested action cannot be performed on a file or directory encountered in the hierarchy, the utility shall issue a diagnostic message to standard error and continue processing the remaining files in the hierarchy, but the final exit status shall be one that indicates an error occurred.

  **Note:**  
  If the requested action is to write one or more pathnames in a format that has \<newline\> as a terminator or separator, and a pathname to be written contains any bytes that have the encoded value of a \<newline\> character, this should be treated as an action that cannot be performed. A future version of this standard may require that utilities treat this as an error.

- If the requested action characterized by an option or option-argument cannot be performed, the utility shall issue a diagnostic message to standard error and the exit status returned shall be one that indicates an error occurred.

- When an unrecoverable error condition is encountered, the utility shall exit with an exit status that indicates an error occurred.

- A diagnostic message shall be written to standard error whenever an error condition occurs.

When a utility encounters an error condition several actions are possible, depending on the severity of the error and the state of the utility. Included in the possible actions of various utilities are: deletion of temporary or intermediate work files; deletion of incomplete files; validity checking of the file system or directory.

**Default Behavior:** When this section is listed as "Default.", it means that any changes to the environment, file systems, process state, and so on are unspecified.

**APPLICATION USAGE**

\
This section is informative.

The APPLICATION USAGE section gives advice to the application programmer or user about the way the utility should be used.

**EXAMPLES**

\
This section is informative.

The EXAMPLES section gives one or more examples of usage, where appropriate. In the event of conflict between an example and a normative part of the specification, the normative material is to be taken as correct.

In all examples, quoting has been used, showing how sample commands (utility names combined with arguments) could be passed correctly to a shell (see [*sh*](../utilities/sh.html)) or as a string to the [*system*()](../functions/system.html) function defined in the System Interfaces volume of POSIX.1-2024. Such quoting would not be used if the utility is invoked using one of the *exec* functions defined in the System Interfaces volume of POSIX.1-2024.

**RATIONALE**

\
This section is informative.

This section contains historical information concerning the contents of this volume of POSIX.1-2024 and why features were included or discarded by the standard developers.

**FUTURE DIRECTIONS**

\
This section is informative.

The FUTURE DIRECTIONS section should be used as a guide to current thinking; there is not necessarily a commitment to implement all of these future directions in their entirety.

**SEE ALSO**

\
This section is informative.

The SEE ALSO section lists related entries.

**CHANGE HISTORY**

\
This section is informative.

This section shows the derivation of the entry and any significant changes that have been made to it.

Certain of the standard utilities describe how they can invoke other utilities or applications, such as by passing a command string to the command interpreter. The external influences (STDIN, ENVIRONMENT VARIABLES, and so on) and external effects (STDOUT, CONSEQUENCES OF ERRORS, and so on) of such invoked utilities are not described in the section concerning the standard utility that invokes them.

### <span id="tag_18_05"></span>1.5 Considerations for Utilities in Support of Files of Arbitrary Size

The following utilities support files of any size up to the maximum that can be created by the implementation. This support includes correct writing of file size-related values (such as file sizes and offsets, line numbers, and block counts) and correct interpretation of command line arguments that contain such values.

*basename*

Return non-directory portion of pathname.

*cat*

Concatenate and print files.

*cd*

Change working directory.

*chgrp*

Change file group ownership.

*chmod*

Change file modes.

*chown*

Change file ownership.

*cksum*

Write file checksums and sizes.

*cmp*

Compare two files.

*cp*

Copy files.

*dd*

Convert and copy a file.

*df*

Report free disk space.

*dirname*

Return directory portion of pathname.

*du*

Estimate file space usage.

*find*

Find files.

*ln*

Link files.

*ls*

List directory contents.

*mkdir*

Make directories.

*mv*

Move files.

*pathchk*

Check pathnames.

*pwd*

Return working directory name.

*rm*

Remove directory entries.

*rmdir*

Remove directories.

*sh*

Shell, the standard command language interpreter.

*test*

Evaluate expression.

*touch*

Change file access and modification times.

*ulimit*

Set or report file size limit.

\

Exceptions to the requirement that utilities support files of any size up to the maximum are as follows:

1.  Uses of files as command scripts, or for configuration or control, are exempt. For example, it is not required that [*sh*](../utilities/sh.html) be able to read an arbitrarily large **.profile**.
2.  Shell input and output redirection are exempt. For example, it is not required that the redirections *sum* \< *file* or *echo foo* \> *file* succeed for an arbitrarily large existing file.

### <span id="tag_18_06"></span>1.6 Built-In Utilities

Any of the standard utilities may be implemented as regular built-in utilities within the command language interpreter. This is usually done to increase the performance of frequently used utilities or to achieve functionality that would be more difficult in a separate environment. The intrinsic utilities described in [1.7 Intrinsic Utilities](#tag_18_07) below are frequently provided as regular built-ins.

However, all of the standard utilities other than:

- The special built-ins described in [*2.15 Special Built-In Utilities*](../utilities/V3_chap02.html#tag_19_15)
- The intrinsic utilities named in [Intrinsic Utilities](#tagtcjh_13), except for [*kill*](../utilities/kill.html)

shall be implemented, regardless of whether they are also implemented as regular built-ins, in a manner so that they can be accessed via the *exec* family of functions as defined in the System Interfaces volume of POSIX.1-2024 and can be invoked directly by those standard utilities that require it ([*env*](../utilities/env.html), [*find*](../utilities/find.html), [*nice*](../utilities/nice.html), [*nohup*](../utilities/nohup.html), [*time*](../utilities/time.html), [*xargs*](../utilities/xargs.html)).

### <span id="tag_18_07"></span>1.7 Intrinsic Utilities

As described in [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04), intrinsic utilities are not subject to a *PATH* search during command search and execution. The utilities named in [Intrinsic Utilities](#tagtcjh_13) shall be intrinsic utilities.\

<span id="tagtcjh_13"></span> Table: Intrinsic Utilities

<table style="width:100%;" data-cellpadding="3" data-align="center">
<colgroup>
<col style="width: 16%" />
<col style="width: 16%" />
<col style="width: 16%" />
<col style="width: 16%" />
<col style="width: 16%" />
<col style="width: 16%" />
</colgroup>
<tbody>
<tr data-valign="top">
<td style="text-align: left;"><p><br />
<a href="../utilities/alias.html"><em>alias</em></a><br />
<a href="../utilities/bg.html"><em>bg</em></a><br />
<a href="../utilities/cd.html"><em>cd</em></a><br />
 </p></td>
<td style="text-align: left;"><p><br />
<a href="../utilities/command.html"><em>command</em></a><br />
<a href="../utilities/fc.html"><em>fc</em></a><br />
<a href="../utilities/fg.html"><em>fg</em></a><br />
 </p></td>
<td style="text-align: left;"><p><br />
<a href="../utilities/getopts.html"><em>getopts</em></a><br />
<a href="../utilities/hash.html"><em>hash</em></a><br />
<a href="../utilities/jobs.html"><em>jobs</em></a><br />
 </p></td>
<td style="text-align: left;"><p><br />
<a href="../utilities/kill.html"><em>kill</em></a><br />
<a href="../utilities/read.html"><em>read</em></a><br />
<a href="../utilities/type.html"><em>type</em></a><br />
 </p></td>
<td style="text-align: left;"><p><br />
<a href="../utilities/ulimit.html"><em>ulimit</em></a><br />
<a href="../utilities/umask.html"><em>umask</em></a><br />
<a href="../utilities/unalias.html"><em>unalias</em></a><br />
 </p></td>
<td style="text-align: left;"><p><br />
<a href="../utilities/wait.html"><em>wait</em></a><br />
 </p></td>
</tr>
</tbody>
</table>

Whether any additional utility is considered an intrinsic utility is implementation-defined. Because applications are unable to override an intrinsic utility with a utility from *PATH ,* implementations should not make any utility an intrinsic utility beyond the utilities in [Intrinsic Utilities](#tagtcjh_13).

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
