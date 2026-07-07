The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="uucp"></span> <span id="tag_20_140"></span>

#### <span id="tag_20_140_01"></span>NAME

> uucp — system-to-system copy

#### <span id="tag_20_140_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`UU`](javascript:open_code('UU'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` uucp`` `**`[`**`-cCdfjmr`**`] [`**`-n`` `*`user`***`]`**` `*`source-file`*`...`` `*`destination-file`*` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_140_03"></span>DESCRIPTION

> The *uucp* utility shall copy files named by the *source-file* argument to the *destination-file* argument. The files named can be on local or remote systems.
>
> The *uucp* utility cannot guarantee support for all character encodings in all circumstances. For example, transmission data may be restricted to 7 bits by the underlying network, 8-bit data and filenames need not be portable to non-internationalized systems, and so on. Under these circumstances, it is recommended that only characters defined in the ISO/IEC 646:1991 standard International Reference Version (equivalent to ASCII) 7-bit range of characters be used, and that only characters defined in the portable filename character set be used for naming files. The protocol for transfer of files is unspecified by POSIX.1-2024.
>
> Typical implementations of this utility require a communications line configured to use XBD [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11), but other communications means may be used. On systems where there are no available communications means (either temporarily or permanently), this utility shall write an error message describing the problem and exit with a non-zero exit status.

#### <span id="tag_20_140_04"></span>OPTIONS

> The *uucp* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following options shall be supported:
>
> **-c**
>
> Do not copy local file to the spool directory for transfer to the remote machine (default).
>
> **-C**
>
> Force the copy of local files to the spool directory for transfer.
>
> **-d**
>
> Make all necessary directories for the file copy (default).
>
> **-f**
>
> Do not make intermediate directories for the file copy.
>
> **-j**
>
> Write the job identification string to standard output. This job identification can be used by [*uustat*](../utilities/uustat.html) to obtain the status or terminate a job.
>
> **-m**
>
> Send mail to the requester when the copy is completed.
>
> **-n ***user*
>
> Notify *user* on the remote system that a file was sent.
>
> **-r**
>
> Do not start the file transfer; just queue the job.

#### <span id="tag_20_140_05"></span>OPERANDS

> The following operands shall be supported:
>
> *destination-file*, *source-file*
>
> \
> A pathname of a file to be copied to, or from, respectively. Either name can be a pathname on the local machine, or can have the form:
>
>
>     system-name!pathname
>
> where *system-name* is taken from a list of system names that *uucp* knows about. The destination *system-name* can also be a list of names such as:
>
>
>     system-name!system-name!...!system-name!pathname
>
> in which case, an attempt is made to send the file via the specified route to the destination. Care should be taken to ensure that intermediate nodes in the route are willing to forward information.
>
> The shell pattern matching notation characters `'?'`, `'*'`, and `"[...]"` appearing in *pathname* shall be expanded on the appropriate system.
>
> Pathnames can be one of:
>
> 1.  An absolute pathname.
>
> 2.  A pathname preceded by ~*user* where *user* is a login name on the specified system and is replaced by that user's login directory. Note that if an invalid login is specified, the default is to the public directory (called *PUBDIR*; the actual location of *PUBDIR* is implementation-defined).
>
> 3.  A pathname preceded by ~/*destination* where *destination* is appended to *PUBDIR*.
>
>     **Note:**  
>     This destination is treated as a filename unless more than one file is being transferred by this request or the destination is already a directory. To ensure that it is a directory, follow the destination with a `'/'`. For example, **~/dan/** as the destination makes the directory **PUBDIR/dan** if it does not exist and puts the requested files in that directory.
>
> 4.  Anything else shall be prefixed by the current directory.
>
> If the result is an erroneous pathname for the remote system, the copy shall fail. If the *destination-file* is a directory, the last part of the *source-file* name shall be used.
>
> The read, write, and execute permissions given by *uucp* are implementation-defined.

#### <span id="tag_20_140_06"></span>STDIN

> Not used.

#### <span id="tag_20_140_07"></span>INPUT FILES

> The files to be copied are regular files.

#### <span id="tag_20_140_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *uucp*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) for the precedence of internationalization variables used to determine the values of locale categories.)
>
> *LC_ALL*
>
> If set to a non-empty string value, override the values of all the other internationalization variables.
>
> *LC_COLLATE*
>
> \
> Determine the locale for the behavior of ranges, equivalence classes, and multi-character collating elements within bracketed filename patterns.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments and input files) and the behavior of character classes within bracketed filename patterns (for example, `"'[[:lower:]]*'"`).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error, and informative messages written to standard output.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_140_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_140_10"></span>STDOUT

> Not used.

#### <span id="tag_20_140_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_140_12"></span>OUTPUT FILES

> The output files (which may be on other systems) are copies of the input files.
>
> If **-m** is used, mail files are modified.

#### <span id="tag_20_140_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_140_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_140_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_140_16"></span>APPLICATION USAGE

> This utility is part of the UUCP Utilities option and need not be supported by all implementations.
>
> The domain of remotely accessible files can (and for obvious security reasons usually should) be severely restricted.
>
> Note that the `'!'` character in addresses has to be escaped when using *csh* as a command interpreter because of its history substitution syntax. For *ksh* and [*sh*](../utilities/sh.html) the escape is not necessary, but may be used.
>
> As noted above, shell metacharacters appearing in pathnames are expanded on the appropriate system. On an internationalized system, this is done under the control of local settings of *LC_COLLATE* and *LC_CTYPE .* Thus, care should be taken when using bracketed filename patterns, as collation and typing rules may vary from one system to another. Also be aware that certain types of expression (that is, equivalence classes, character classes, and collating symbols) need not be supported on non-internationalized systems.

#### <span id="tag_20_140_17"></span>EXAMPLES

> None.

#### <span id="tag_20_140_18"></span>RATIONALE

> None.

#### <span id="tag_20_140_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_140_20"></span>SEE ALSO

> [*mailx*](../utilities/mailx.html#), [*uuencode*](../utilities/uuencode.html#), [*uustat*](../utilities/uustat.html#), [*uux*](../utilities/uux.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*11. General Terminal Interface*](../basedefs/V1_chap11.html#tag_11), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_140_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_140_22"></span>Issue 6

> The *LC_TIME* and *TZ* entries are removed from the ENVIRONMENT VARIABLES section.
>
> The UN margin codes and associated shading are removed from the **-C**, **-f**, **-j**, **-n**, and **-r** options in response to The Open Group Base Resolution bwg2001-003.

#### <span id="tag_20_140_23"></span>Issue 7

> SD5-XCU-ERN-46 is applied, moving this utility to the UUCP Utilities Option Group.
>
> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_140_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1516 is applied, adding XSI shading to text relating to *NLSPATH .*

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
