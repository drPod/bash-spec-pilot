The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_02"></span>2. Conformance

### <span id="tag_02_01"></span>2.1 Implementation Conformance

For the purposes of POSIX.1-2024, the implementation conformance requirements given in this section apply.

#### <span id="tag_02_01_01"></span>2.1.1 Requirements

A *conforming implementation* shall meet all of the following criteria:

1.  The system shall support all utilities, functions, and facilities defined within POSIX.1-2024 that are required for POSIX conformance (see [2.1.3 POSIX Conformance](#tag_02_01_03)). These interfaces shall support the functional behavior described herein.

2.  The system may support the X/Open System Interfaces (XSI) option as described in [2.1.4 XSI Conformance](#tag_02_01_04).

3.  The system may support one or more options as described under [2.1.5 Option Groups](#tag_02_01_05). When an implementation claims that an option is supported, all of its constituent parts shall be provided.

4.  The system may provide non-standard extensions. These are features not required by POSIX.1-2024 and may include, but are not limited to:

    - Additional functions

    - Additional headers

    - Additional symbols in standard headers

    - Additional utilities

    - Additional options for standard utilities

    - Additional environment variables

    - Additional file types

    - Non-conforming file systems (for example, legacy file systems for which \_POSIX_NO_TRUNC is false, case-insensitive file systems, or network file systems)

    - Dynamically populated file systems (for example, **/proc**)

    - Additional character special files with special properties (for example, **/dev/stdin**, **/dev/stdout**, and **/dev/stderr**)

    Non-standard extensions of the utilities, functions, or facilities specified in POSIX.1-2024 should be identified as such in the system documentation. Non-standard extensions, when used, may change the behavior of utilities, functions, or facilities defined by POSIX.1-2024. The conformance document shall define an environment in which an application can be run with the behavior specified by POSIX.1-2024. In no case shall such an environment require modification of a Strictly Conforming POSIX Application (see [2.2.1 Strictly Conforming POSIX Application](#tag_02_02_01)).

**Note:**  
If the documented method of setting up a conforming environment includes the need to set one or more environment variables, then the values of those environment variables cannot include any \<space\> characters, since the [*confstr*()](../functions/confstr.html) function has to be able to return them in a \<space\>-separated list of variable=value pairs. See XSH [*confstr*()](../functions/confstr.html#).

#### <span id="tag_02_01_02"></span>2.1.2 Documentation

A conformance document with the following information shall be available for an implementation claiming conformance to POSIX.1-2024. The conformance document shall have the same structure as POSIX.1-2024, with the information presented in the appropriate sections and subsections. Sections and subsections that consist solely of subordinate section titles, with no other information, are not required. The conformance document shall not contain information about extended facilities or capabilities outside the scope of POSIX.1-2024.

The conformance document shall contain a statement that indicates the full name, number, and date of the standard that applies. The conformance document may also list international software standards that are available for use by a Conforming POSIX Application. Applicable characteristics where documentation is required by one of these standards, or by standards of government bodies, may also be included.

The conformance document shall describe the limit values found in the headers [*\<limits.h\>*](../basedefs/limits.h.html) and [*\<unistd.h\>*](../basedefs/unistd.h.html), stating values, the conditions under which those values may change, and the limits of such variations, if any.

The conformance document shall describe the behavior of the implementation for all implementation-defined features defined in POSIX.1-2024. This requirement shall be met by listing these features and providing either a specific reference to the system documentation or providing full syntax and semantics of these features. When the value or behavior in the implementation is designed to be variable or customized on each instantiation of the system, the implementation provider shall document the nature and permissible ranges of this variation.

The conformance document may specify the behavior of the implementation for those features where POSIX.1-2024 states that implementations may vary or where features are identified as undefined or unspecified.

The conformance document shall not contain documentation other than that specified in the preceding paragraphs except where such documentation is specifically allowed or required by other provisions of POSIX.1-2024.

The phrases "shall document" or "shall be documented" in POSIX.1-2024 mean that documentation of the feature shall appear in the conformance document, as described previously, unless there is an explicit reference in the conformance document to show where the information can be found in the system documentation.

The system documentation should also contain the information found in the conformance document.

#### <span id="tag_02_01_03"></span>2.1.3 POSIX Conformance

A conforming implementation shall meet the following criteria for POSIX conformance.

##### <span id="tag_02_01_03_01"></span>2.1.3.1 POSIX System Interfaces

The following requirements apply to the system interfaces (functions and headers):

- The system shall support all the mandatory functions and headers defined in POSIX.1-2024, and shall set the symbolic constant \_POSIX_VERSION to the value 202405L.

- Although all implementations conforming to POSIX.1-2024 support all the features described below, there may be system-dependent or file system-dependent configuration procedures that can remove or modify any or all of these features. Such configurations should not be made if strict compliance is required.

  The following symbolic constants shall be defined with a value other than -1. If a constant is defined with the value zero, applications should use the [*sysconf*()](../functions/sysconf.html), [*pathconf*()](../functions/pathconf.html), or [*fpathconf*()](../functions/fpathconf.html) functions, or the [*getconf*](../utilities/getconf.html) utility, to determine which features are present on the system at that time or for the particular pathname in question.

  - \_POSIX_CHOWN_RESTRICTED

    The use of [*chown*()](../functions/chown.html) is restricted to a process with appropriate privileges, and to changing the group ID of a file only to the effective group ID of the process or to one of its supplementary group IDs.

  - \_POSIX_NO_TRUNC

    Pathname components longer than {NAME_MAX} generate an error.

- The following symbolic constants shall be defined by the implementation as follows:

  - Symbolic constants defined with the value 202405L:

    > 
    >     _POSIX_ASYNCHRONOUS_IO
    >     _POSIX_BARRIERS
    >     _POSIX_CLOCK_SELECTION
    >     _POSIX_MAPPED_FILES
    >     _POSIX_MEMORY_PROTECTION
    >     _POSIX_MONOTONIC_CLOCK
    >     _POSIX_READER_WRITER_LOCKS
    >     _POSIX_REALTIME_SIGNALS
    >     _POSIX_SEMAPHORES
    >     _POSIX_SPIN_LOCKS
    >     _POSIX_THREAD_SAFE_FUNCTIONS
    >     _POSIX_THREADS
    >     _POSIX_TIMEOUTS
    >     _POSIX_TIMERS
    >     _POSIX2_C_BIND

  - Symbolic constants defined with a value greater than zero:

    > 
    >     _POSIX_JOB_CONTROL
    >     _POSIX_REGEXP
    >     _POSIX_SAVED_IDS
    >     _POSIX_SHELL

  - Symbolic constants defined with a value other than -1.

    > 
    >     _POSIX_VDISABLE

  **Note:**  
  The symbols above represent historical options that are no longer allowed as options, but are retained here for backwards-compatibility of applications.

  \

- The system may support one or more options (see [2.1.6 Options](#tag_02_01_06)) denoted by the following symbolic constants:

  > 
  >     _POSIX_ADVISORY_INFO
  >     _POSIX_CPUTIME
  >     _POSIX_DEVICE_CONTROL
  >     _POSIX_FSYNC
  >     _POSIX_IPV6
  >     _POSIX_MEMLOCK
  >     _POSIX_MEMLOCK_RANGE
  >     _POSIX_MESSAGE_PASSING
  >     _POSIX_PRIORITIZED_IO
  >     _POSIX_PRIORITY_SCHEDULING
  >     _POSIX_RAW_SOCKETS
  >     _POSIX_SHARED_MEMORY_OBJECTS
  >     _POSIX_SPAWN
  >     _POSIX_SPORADIC_SERVER
  >     _POSIX_SYNCHRONIZED_IO
  >     _POSIX_THREAD_ATTR_STACKADDR
  >     _POSIX_THREAD_CPUTIME
  >     _POSIX_THREAD_ATTR_STACKSIZE
  >     _POSIX_THREAD_PRIO_INHERIT
  >     _POSIX_THREAD_PRIO_PROTECT
  >     _POSIX_THREAD_PRIORITY_SCHEDULING
  >     _POSIX_THREAD_PROCESS_SHARED
  >     _POSIX_THREAD_SPORADIC_SERVER
  >     _POSIX_TYPED_MEMORY_OBJECTS
  >     _XOPEN_CRYPT
  >     _XOPEN_REALTIME
  >     _XOPEN_REALTIME_THREADS
  >     _XOPEN_UNIX

  If the Advisory Information option is supported, there shall be at least one file system that supports the functionality.

##### <span id="tag_02_01_03_02"></span>2.1.3.2 POSIX Shell and Utilities

The following requirements apply to the shell and utilities:

- The system shall provide all the mandatory utilities in the Shell and Utilities volume of POSIX.1-2024 with all the functional behavior described therein.

- The system shall support the Large File capabilities described in the Shell and Utilities volume of POSIX.1-2024.

- The system may support one or more options (see [2.1.6 Options](#tag_02_01_06)) denoted by the following symbolic constants. (The literal names below apply to the [*getconf*](../utilities/getconf.html) utility.)

  > 
  >     POSIX2_C_DEV
  >     POSIX2_CHAR_TERM
  >     POSIX2_FORT_RUN
  >     POSIX2_LOCALEDEF
  >     POSIX2_SW_DEV
  >     POSIX2_UPE
  >     XOPEN_UNIX
  >     XOPEN_UUCP

Additional language bindings and development utility options may be provided in other related standards or in a future version of this standard. In the former case, additional symbolic constants of the same general form as shown in this subsection should be defined by the related standard document and made available to the application without requiring POSIX.1-2024 to be updated.

#### <span id="tag_02_01_04"></span>2.1.4 XSI Conformance

<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> This section describes the criteria for implementations providing conformance to the X/Open System Interfaces (XSI) option (see [*3.424 XSI*](../basedefs/V1_chap03.html#tag_03_424)). The functionality described in this section shall be provided on implementations that support the XSI option (and the rest of this section is not further marked). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

POSIX.1-2024 describes utilities, functions, and facilities offered to application programs by the X/Open System Interfaces (XSI) option. An XSI-conforming implementation shall meet the criteria for POSIX conformance and the following requirements listed in this section.

XSI-conforming implementations shall set the symbolic constant \_XOPEN_UNIX to a value other than -1 and shall set the symbolic constant \_XOPEN_VERSION to the value 800.

##### <span id="tag_02_01_04_01"></span>2.1.4.1 XSI System Interfaces

The following requirements apply to the system interfaces when the XSI option is supported:

- The system shall support all the functions and headers defined in POSIX.1-2024 as part of the XSI option denoted by the XSI marking in the SYNOPSIS section, and any extensions marked with the XSI option marking (see [*1.8.1 Codes*](../basedefs/V1_chap01.html#tag_01_08_01)) within the text.

- The system shall support the following options defined within POSIX.1-2024 (see [2.1.6 Options](#tag_02_01_06)):

  > 
  >     _POSIX_FSYNC
  >     _POSIX_THREAD_ATTR_STACKADDR
  >     _POSIX_THREAD_ATTR_STACKSIZE
  >     _POSIX_THREAD_PROCESS_SHARED

- The system may support the following XSI Option Groups (see [2.1.5.2 XSI Option Groups](#tag_02_01_05_02)) defined within POSIX.1-2024:

  - Encryption

  - Realtime

  - Advanced Realtime

  - Realtime Threads

  - Advanced Realtime Threads

##### <span id="tag_02_01_04_02"></span>2.1.4.2 XSI Shell and Utilities Conformance

The following requirements apply to the shell and utilities when the XSI option is supported:

- The system shall support all the utilities defined in the Shell and Utilities volume of POSIX.1-2024 as part of the XSI option denoted by the XSI marking in the SYNOPSIS section, and any extensions marked with the XSI option marking (see [*1.8.1 Codes*](../basedefs/V1_chap01.html#tag_01_08_01)) within the text.

- The system shall support the User Portability Utilities option and the Terminal Characteristics option.

- The system shall support creation of locales (see [*7. Locale*](../basedefs/V1_chap07.html#tag_07)).

- The C-language Development utility [*c17*](../utilities/c17.html) shall be supported.

- The XSI Development Utilities option may be supported. It consists of the following software development utilities:

  > 
  >
  > <table data-cellpadding="3">
  > <colgroup>
  > <col style="width: 25%" />
  > <col style="width: 25%" />
  > <col style="width: 25%" />
  > <col style="width: 25%" />
  > </colgroup>
  > <tbody>
  > <tr data-valign="top">
  > <td style="text-align: left;"><p><br />
  > <a href="../utilities/admin.html"><em>admin</em></a><br />
  > <a href="../utilities/cflow.html"><em>cflow</em></a><br />
  > <a href="../utilities/ctags.html"><em>ctags</em></a><br />
  > <a href="../utilities/cxref.html"><em>cxref</em></a><br />
  >  </p></td>
  > <td style="text-align: left;"><p><br />
  > <a href="../utilities/delta.html"><em>delta</em></a><br />
  > <a href="../utilities/get.html"><em>get</em></a><br />
  > <a href="../utilities/nm.html"><em>nm</em></a><br />
  > <a href="../utilities/prs.html"><em>prs</em></a><br />
  >  </p></td>
  > <td style="text-align: left;"><p><br />
  > <a href="../utilities/rmdel.html"><em>rmdel</em></a><br />
  > <a href="../utilities/sact.html"><em>sact</em></a><br />
  > <a href="../utilities/sccs.html"><em>sccs</em></a><br />
  > <a href="../utilities/unget.html"><em>unget</em></a><br />
  >  </p></td>
  > <td style="text-align: left;"><p><br />
  > <a href="../utilities/val.html"><em>val</em></a><br />
  > <a href="../utilities/what.html"><em>what</em></a><br />
  >  </p></td>
  > </tr>
  > </tbody>
  > </table>

#### <span id="tag_02_01_05"></span>2.1.5 Option Groups

An Option Group is a group of related functions or options defined within the System Interfaces volume of POSIX.1-2024.

If an implementation supports an Option Group, then the system shall support the functional behavior described herein.

If an implementation does not support an Option Group, then the system need not support the functional behavior described herein.

##### <span id="tag_02_01_05_01"></span>2.1.5.1 Subprofiling Considerations

Profiling standards supporting functional requirements less than that required in POSIX.1-2024 may subset both mandatory and optional functionality required for POSIX Conformance (see [2.1.3 POSIX Conformance](#tag_02_01_03)) or XSI Conformance (see [2.1.4 XSI Conformance](#tag_02_01_04)). Such profiles shall organize the subsets into Subprofiling Option Groups.

XRAT [*E. Subprofiling Considerations (Informative)*](../xrat/V4_subprofiles.html#tag_25) describes a representative set of such Subprofiling Option Groups for use by profiles applicable to specialized realtime systems. POSIX.1-2024 does not require that the presence of Subprofiling Option Groups be testable at compile-time (as symbols defined in any header) or at runtime (via [*sysconf*()](../functions/sysconf.html) or [*getconf*](../utilities/getconf.html)).

A Subprofiling Option Group may provide basic system functionality that other Subprofiling Option Groups and other options depend upon.[<sup><span class="small">1</span></sup>](#tag_foot_1) If a profile of POSIX.1-2024 does not require an implementation to provide a Subprofiling Option Group that provides features utilized by a required Subprofiling Option Group (or option),[<sup><span class="small">2</span></sup>](#tag_foot_2) the profile shall specify[<sup><span class="small">3</span></sup>](#tag_foot_3) all of the following:

- Restricted or altered behavior of interfaces defined in POSIX.1-2024 that may differ on an implementation of the profile
- Additional behaviors that may produce undefined or unspecified results
- Additional implementation-defined behavior that implementations shall be required to document in the profile's conformance document

if any of the above is a result of the profile not requiring an interface required by POSIX.1-2024.

The following additional rules shall apply to all profiles of POSIX.1-2024:

- Any application that conforms to that profile shall also conform to POSIX.1-2024, unless the application depends on the definition of a profile support indicator macro in [*\<unistd.h\>*](../basedefs/unistd.h.html) (that is, a profile shall not require restricted, altered, or extended behaviors of an implementation of POSIX.1-2024).

- Profiles are permitted to require the definition of a *profile support indicator macro* with a name beginning \_POSIX_AEP\_ in [*\<unistd.h\>*](../basedefs/unistd.h.html).

- Profiles shall require the definition of the macro \_POSIX_SUBPROFILE in [*\<unistd.h\>*](../basedefs/unistd.h.html) on implementations that do not meet all of the requirements of a POSIX.1-conforming implementation.

- Profiles are permitted to add additional requirements to the limits defined in [*\<limits.h\>*](../basedefs/limits.h.html) and [*\<stdint.h\>*](../basedefs/stdint.h.html), subject to the following:

  For the limits in [*\<limits.h\>*](../basedefs/limits.h.html) and [*\<stdint.h\>*](../basedefs/stdint.h.html):

  - If the limit is specified as having a fixed value, it shall not be changed by a profile.
  - If a limit is specified as having a minimum or maximum acceptable value, it may be changed by a profile as follows:
    - A profile may increase a minimum acceptable value, but shall not make a minimum acceptable value smaller.
    - A profile may reduce a maximum acceptable value, but shall not make a maximum acceptable value larger.

- A profile shall not change a limit specified as having a minimum or maximum value into a limit specified as having a fixed value.

- A profile shall not create new limits.

- Any implementation that conforms to POSIX.1-2024 (including all options and extended limits required by the profile) shall also conform to that profile, except for the possible omission from [*\<unistd.h\>*](../basedefs/unistd.h.html) of a profile support indicator macro required by the profile.

##### <span id="tag_02_01_05_02"></span>2.1.5.2 XSI Option Groups

<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> This section describes Option Groups to support the definition of XSI conformance within the System Interfaces volume of POSIX.1-2024. The functionality described in this section shall be provided on implementations that support the XSI option and the appropriate Option Group (and the rest of this section is not further marked). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

The following Option Groups are defined.

##### <span id="tag_02_01_05_03"></span>Encryption

The Encryption Option Group is denoted by the symbolic constant \_XOPEN_CRYPT. It includes the following functions:

[*crypt*()](../functions/crypt.html), <sup>\[[OB](javascript:open_code('OB'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  [*encrypt*()](../functions/encrypt.html), [*setkey*()](../functions/setkey.html) <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

These functions are marked CRYPT.

Due to export restrictions on the cryptographic algorithm in some countries, implementations may be restricted in making these functions available. All the functions in the Encryption Option Group may therefore return \[ENOSYS\] or, alternatively, [*encrypt*()](../functions/encrypt.html) shall return \[ENOSYS\] for the decryption operation.

An implementation that claims conformance to this Option Group shall set \_XOPEN_CRYPT to a value other than -1.

##### <span id="tag_02_01_05_04"></span>Realtime

The Realtime Option Group is denoted by the symbolic constant \_XOPEN_REALTIME.

This Option Group includes a set of realtime functions drawn from options within POSIX.1-2024 (see [2.1.6 Options](#tag_02_01_06)).

Where entire functions are included in the Option Group, the NAME section is marked with REALTIME. Where additional semantics have been added to existing pages, the new material is identified by use of the appropriate margin legend for the underlying option defined within POSIX.1-2024.

An implementation that claims conformance to this Option Group shall set \_XOPEN_REALTIME to a value other than -1.

This Option Group consists of the set of the following options from within POSIX.1-2024 (see [2.1.6 Options](#tag_02_01_06)):

> 
>     _POSIX_FSYNC
>     _POSIX_MEMLOCK
>     _POSIX_MEMLOCK_RANGE
>     _POSIX_MESSAGE_PASSING
>     _POSIX_PRIORITIZED_IO
>     _POSIX_PRIORITY_SCHEDULING
>     _POSIX_SHARED_MEMORY_OBJECTS
>     _POSIX_SYNCHRONIZED_IO

If the symbolic constant \_XOPEN_REALTIME is defined to have a value other than -1, then the following symbolic constants shall be defined by the implementation to have the value 202405L:

> 
>     _POSIX_MEMLOCK
>     _POSIX_MEMLOCK_RANGE
>     _POSIX_MESSAGE_PASSING
>     _POSIX_PRIORITY_SCHEDULING
>     _POSIX_SHARED_MEMORY_OBJECTS
>     _POSIX_SYNCHRONIZED_IO

The functionality associated with \_POSIX_FSYNC shall always be supported on XSI-conformant systems.

Support of \_POSIX_PRIORITIZED_IO on XSI-conformant systems is optional. If \_POSIX_PRIORITIZED_IO is supported, then asynchronous I/O operations performed by [*aio_read*()](../functions/aio_read.html), [*aio_write*()](../functions/aio_write.html), and [*lio_listio*()](../functions/lio_listio.html) shall be submitted at a priority equal to the scheduling priority equal to a base scheduling priority minus *aiocbp*-\>*aio_reqprio*. If Thread Execution Scheduling is not supported, then the base scheduling priority is that of the calling process; otherwise, the base scheduling priority is that of the calling thread. The implementation shall also document for which files I/O prioritization is supported.

##### <span id="tag_02_01_05_05"></span>Advanced Realtime

An implementation that claims conformance to this Option Group shall also support the Realtime Option Group.

Where entire functions are included in the Option Group, the NAME section is marked with ADVANCED REALTIME. Where additional semantics have been added to existing pages, the new material is identified by use of the appropriate margin legend for the underlying option defined within POSIX.1-2024.

This Option Group consists of the set of the following options from within POSIX.1-2024 (see [2.1.6 Options](#tag_02_01_06)):

> 
>     _POSIX_ADVISORY_INFO
>     _POSIX_CPUTIME
>     _POSIX_SPAWN
>     _POSIX_SPORADIC_SERVER
>     _POSIX_TYPED_MEMORY_OBJECTS

If the implementation supports the Advanced Realtime Option Group, then the following symbolic constants shall be defined by the implementation to have the value 202405L:

> 
>     _POSIX_ADVISORY_INFO
>     _POSIX_CPUTIME
>     _POSIX_SPAWN
>     _POSIX_SPORADIC_SERVER
>     _POSIX_TYPED_MEMORY_OBJECTS

If the symbolic constant \_POSIX_SPORADIC_SERVER is defined, then the symbolic constant \_POSIX_PRIORITY_SCHEDULING shall also be defined by the implementation to have the value 202405L.

##### <span id="tag_02_01_05_06"></span>Realtime Threads

The Realtime Threads Option Group is denoted by the symbolic constant \_XOPEN_REALTIME_THREADS.

This Option Group consists of the set of the following options from within POSIX.1-2024 (see [2.1.6 Options](#tag_02_01_06)):

> 
>     _POSIX_THREAD_PRIO_INHERIT
>     _POSIX_THREAD_PRIO_PROTECT
>     _POSIX_THREAD_PRIORITY_SCHEDULING
>     _POSIX_THREAD_ROBUST_PRIO_INHERIT
>     _POSIX_THREAD_ROBUST_PRIO_PROTECT

Where applicable, whole pages are marked REALTIME THREADS, together with the appropriate option margin legend for the SYNOPSIS section (see [*1.8.1 Codes*](../basedefs/V1_chap01.html#tag_01_08_01)).

An implementation that claims conformance to this Option Group shall set \_XOPEN_REALTIME_THREADS to a value other than -1.

If the symbol \_XOPEN_REALTIME_THREADS is defined to have a value other than -1, then the following options shall also be defined by the implementation to have the value 202405L:

> 
>     _POSIX_THREAD_PRIO_INHERIT
>     _POSIX_THREAD_PRIO_PROTECT
>     _POSIX_THREAD_PRIORITY_SCHEDULING
>     _POSIX_THREAD_ROBUST_PRIO_INHERIT
>     _POSIX_THREAD_ROBUST_PRIO_PROTECT

##### <span id="tag_02_01_05_07"></span>Advanced Realtime Threads

An implementation that claims conformance to this Option Group shall also support the Realtime Threads Option Group.

Where entire functions are included in the Option Group, the NAME section is marked with ADVANCED REALTIME THREADS. Where additional semantics have been added to existing pages, the new material is identified by use of the appropriate margin legend for the underlying option defined within POSIX.1-2024.

This Option Group consists of the set of the following options from within POSIX.1-2024 (see [2.1.6 Options](#tag_02_01_06)):

> 
>     _POSIX_THREAD_CPUTIME
>     _POSIX_THREAD_SPORADIC_SERVER

If the symbolic constant \_POSIX_THREAD_SPORADIC_SERVER is defined to have the value 202405L, then the symbolic constant \_POSIX_THREAD_PRIORITY_SCHEDULING shall also be defined by the implementation to have the value 202405L.

If the implementation supports the Advanced Realtime Threads Option Group, then the following symbolic constants shall be defined by the implementation to have the value 202405L:

> 
>     _POSIX_THREAD_CPUTIME
>     _POSIX_THREAD_SPORADIC_SERVER

#### <span id="tag_02_01_06"></span>2.1.6 Options

The symbolic constants defined in [*\<unistd.h\>*](../basedefs/unistd.h.html), [*Constants for Options and Option Groups*](../basedefs/unistd.h.html) reflect implementation options for POSIX.1-2024. These symbols can be used by the application to determine which of three categories of support for optional facilities are provided by the implementation.

1.  Option not supported for compilation.

    The implementation advertises at compile time (by defining the constant in [*\<unistd.h\>*](../basedefs/unistd.h.html) with value -1, or by leaving it undefined) that the option is not supported for compilation and, at the time of compilation, is not supported for runtime use. In this case, the headers, data types, function interfaces, and utilities required only for the option need not be present. A later runtime check using the [*fpathconf*()](../functions/fpathconf.html), [*pathconf*()](../functions/pathconf.html), or sysconf functions defined in the System Interfaces volume of POSIX.1-2024 or the [*getconf*](../utilities/getconf.html) utility defined in the Shell and Utilities volume of POSIX.1-2024 can in some circumstances indicate that the option is supported at runtime. (For example, an old application binary might be run on a newer implementation to which support for the option has been added.)

2.  Option always supported.

    The implementation advertises at compile time (by defining the constant in [*\<unistd.h\>*](../basedefs/unistd.h.html) with a value greater than zero) that the option is supported both for compilation and for use at runtime. In this case, all headers, data types, function interfaces, and utilities required only for the option shall be available and shall operate as specified. Runtime checks with [*fpathconf*()](../functions/fpathconf.html), [*pathconf*()](../functions/pathconf.html), or sysconf shall indicate that the option is supported.

3.  Option might or might not be supported at runtime.

    The implementation advertises at compile time (by defining the constant in [*\<unistd.h\>*](../basedefs/unistd.h.html) with value zero) that the option is supported for compilation and might or might not be supported at runtime. In this case, the [*fpathconf*()](../functions/fpathconf.html), [*pathconf*()](../functions/pathconf.html), or [*sysconf*()](../functions/sysconf.html) functions defined in the System Interfaces volume of POSIX.1-2024 or the [*getconf*](../utilities/getconf.html) utility defined in the Shell and Utilities volume of POSIX.1-2024 can be used to retrieve the value of each symbol on each specific implementation to determine whether the option is supported at runtime. All headers, data types, and function interfaces required to compile and execute applications which use the option at runtime (after checking at runtime that the option is supported) shall be provided, but if the option is not supported at runtime they need not operate as specified. Utilities or other facilities required only for the option, but not needed to compile and execute such applications, need not be present.

If an option is not supported for compilation, an application that attempts to use anything associated only with the option is considered to be requiring an extension. Unless explicitly specified otherwise, the behavior of functions associated with an option that is not supported at runtime is unspecified, and an application that uses such functions without first checking [*fpathconf*()](../functions/fpathconf.html), [*pathconf*()](../functions/pathconf.html), or sysconf is considered to be requiring an extension.

Margin codes are defined for each option (see [*1.8.1 Codes*](../basedefs/V1_chap01.html#tag_01_08_01)).

##### <span id="tag_02_01_06_01"></span>2.1.6.1 System Interfaces

Refer to [*\<unistd.h\>*](../basedefs/unistd.h.html), [*Constants for Options and Option Groups*](../basedefs/unistd.h.html) for the list of options.

##### <span id="tag_02_01_06_02"></span>2.1.6.2 Shell and Utilities

Each of these symbols shall be considered valid names by the implementation. Refer to [*\<unistd.h\>*](../basedefs/unistd.h.html), [*Constants for Options and Option Groups*](../basedefs/unistd.h.html).

The literal names shown below apply only to the [*getconf*](../utilities/getconf.html) utility.

POSIX2_C_DEV

<sup>\[[CD](javascript:open_code('CD'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
The system supports the C-Language Development Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

The utilities in the C-Language Development Utilities option are used for the development of C-language applications, including compilation or translation of C source code and complex program generators for simple lexical tasks and processing of context-free grammars.

The utilities listed below may be provided by a conforming system; however, any system claiming conformance to the C-Language Development Utilities option shall provide all of the utilities listed.

> 
>     c17
>     lex
>     yacc

POSIX2_CHAR_TERM

\
The system supports the Terminal Characteristics option. This value need not be present on a system not supporting the User Portability Utilities option.

Where applicable, the dependency is noted within the description of the utility.

This option applies only to systems supporting the User Portability Utilities option. If supported, then the system supports at least one terminal type capable of all operations described in POSIX.1-2024; see [*10.2 Output Devices and Terminal Types*](../basedefs/V1_chap10.html#tag_10_02).

POSIX2_FORT_RUN

<sup>\[[FR](javascript:open_code('FR'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
The system supports the FORTRAN Runtime Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

The [*asa*](../utilities/asa.html) utility is the only utility in the FORTRAN Runtime Utilities option.

The [*asa*](../utilities/asa.html) utility may be provided by a conforming system; however, any system claiming conformance to the FORTRAN Runtime Utilities option shall provide the [*asa*](../utilities/asa.html) utility.

POSIX2_LOCALEDEF

\
The system supports the Locale Creation Utilities option.

If supported, the system supports the creation of locales as described in the [*localedef*](../utilities/localedef.html) utility.

The [*localedef*](../utilities/localedef.html) utility may be provided by a conforming system; however, any system claiming conformance to the Locale Creation Utilities option shall provide the [*localedef*](../utilities/localedef.html) utility.

POSIX2_SW_DEV

<sup>\[[SD](javascript:open_code('SD'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
The system supports the Software Development Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

The utilities in the Software Development Utilities option are used for the development of applications, including compilation or translation of source code, the creation and maintenance of library archives, and the maintenance of groups of inter-dependent programs.

The utilities listed below may be provided by the conforming system; however, any system claiming conformance to the Software Development Utilities option shall provide all of the utilities listed here.

> 
>     ar
>     make
>     nm
>     strip

POSIX2_UPE

<sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
The system supports the User Portability Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

The utilities in the User Portability Utilities option shall be implemented on all systems that claim conformance to this option, except for the [*vi*](../utilities/vi.html) utility which is noted as having features that cannot be implemented on all terminal types; if the POSIX2_CHAR_TERM option is supported, the system shall support all such features on at least one terminal type; see [*10.2 Output Devices and Terminal Types*](../basedefs/V1_chap10.html#tag_10_02).

The list of utilities in the User Portability Utilities option is as follows:

> 
>
> <table data-cellpadding="3">
> <colgroup>
> <col style="width: 20%" />
> <col style="width: 20%" />
> <col style="width: 20%" />
> <col style="width: 20%" />
> <col style="width: 20%" />
> </colgroup>
> <tbody>
> <tr data-valign="top">
> <td style="text-align: left;"><p><br />
> <a href="../utilities/bg.html"><em>bg</em></a><br />
> <a href="../utilities/ex.html"><em>ex</em></a><br />
>  </p></td>
> <td style="text-align: left;"><p><br />
> <a href="../utilities/fc.html"><em>fc</em></a><br />
> <a href="../utilities/fg.html"><em>fg</em></a><br />
>  </p></td>
> <td style="text-align: left;"><p><br />
> <a href="../utilities/jobs.html"><em>jobs</em></a><br />
> <a href="../utilities/man.html"><em>man</em></a><br />
>  </p></td>
> <td style="text-align: left;"><p><br />
> <a href="../utilities/more.html"><em>more</em></a><br />
> <a href="../utilities/talk.html"><em>talk</em></a><br />
>  </p></td>
> <td style="text-align: left;"><p><br />
> <a href="../utilities/vi.html"><em>vi</em></a><br />
>  </p></td>
> </tr>
> </tbody>
> </table>

XOPEN_UNIX

<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
The system supports the X/Open System Interfaces (XSI) option (see [2.1.4 XSI Conformance](#tag_02_01_04)). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

XOPEN_UUCP

<sup>\[[UU](javascript:open_code('UU'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
The system supports the UUCP Utilities option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

The list of utilities in the UUCP Utilities option is as follows:

> 
>     uucp
>     uustat
>     uux

### <span id="tag_02_02"></span>2.2 Application Conformance

For the purposes of POSIX.1-2024, the application conformance requirements given in this section apply.

All applications claiming conformance to POSIX.1-2024 shall use only language-dependent services for the C programming language described in [2.3 Language-Dependent Services for the C Programming Language](#tag_02_03), shall use only the utilities and facilities defined in the Shell and Utilities volume of POSIX.1-2024, and shall fall within one of the following categories.

#### <span id="tag_02_02_01"></span>2.2.1 Strictly Conforming POSIX Application

A Strictly Conforming POSIX Application is an application that requires only the facilities described in POSIX.1-2024. Such an application:

1.  Shall accept any implementation behavior that results from actions it takes in areas described in POSIX.1-2024 as *implementation-defined* or *unspecified*, or where POSIX.1-2024 indicates that implementations may vary
2.  Shall not perform any actions that are described as producing *undefined* results
3.  For symbolic constants, shall accept any value in the range permitted by POSIX.1-2024, but shall not rely on any value in the range being greater than the minimums listed or being less than the maximums listed in POSIX.1-2024
4.  Shall not use facilities designated as *obsolescent*
5.  Is required to tolerate and permitted to adapt to the presence or absence of optional facilities whose availability is indicated by [2.1.3 POSIX Conformance](#tag_02_01_03)
6.  For the C programming language, shall not produce any output dependent on any behavior described in the ISO C standard as *unspecified*, *undefined*, or *implementation-defined*, unless the System Interfaces volume of POSIX.1-2024 specifies the behavior
7.  For the C programming language, shall not exceed any minimum implementation limit defined in the ISO C standard, unless the System Interfaces volume of POSIX.1-2024 specifies a higher minimum implementation limit
8.  For the C programming language, shall define \_POSIX_C_SOURCE to be 202405L before any header is included

Within POSIX.1-2024, any restrictions placed upon a Conforming POSIX Application shall restrict a Strictly Conforming POSIX Application.

#### <span id="tag_02_02_02"></span>2.2.2 Conforming POSIX Application

##### <span id="tag_02_02_02_01"></span>2.2.2.1 ISO/IEC Conforming POSIX Application

An ISO/IEC Conforming POSIX Application is an application that uses only the facilities described in POSIX.1-2024 and approved Conforming Language bindings for any ISO or IEC standard. Such an application shall include a statement of conformance that documents all options and limit dependencies, and all other ISO or IEC standards used.

##### <span id="tag_02_02_02_02"></span>2.2.2.2 \<National Body\> Conforming POSIX Application

A \<National Body\> Conforming POSIX Application differs from an ISO/IEC Conforming POSIX Application in that it also may use specific standards of a single ISO/IEC member body referred to here as \<*National Body*\>. Such an application shall include a statement of conformance that documents all options and limit dependencies, and all other \<National Body\> standards used.

#### <span id="tag_02_02_03"></span>2.2.3 Conforming POSIX Application Using Extensions

A Conforming POSIX Application Using Extensions is an application that differs from a Conforming POSIX Application only in that it uses non-standard facilities that are consistent with POSIX.1-2024. Such an application shall fully document its requirements for these extended facilities, in addition to the documentation required of a Conforming POSIX Application. A Conforming POSIX Application Using Extensions shall be either an ISO/IEC Conforming POSIX Application Using Extensions or a \<National Body\> Conforming POSIX Application Using Extensions (see [2.2.2.1 ISO/IEC Conforming POSIX Application](#tag_02_02_02_01) and [2.2.2.2 \<National Body\> Conforming POSIX Application](#tag_02_02_02_02)).

#### <span id="tag_02_02_04"></span>2.2.4 Strictly Conforming XSI Application

A Strictly Conforming XSI Application is an application that requires only the facilities described in POSIX.1-2024. Such an application:

1.  Shall accept any implementation behavior that results from actions it takes in areas described in POSIX.1-2024 as *implementation-defined* or *unspecified*, or where POSIX.1-2024 indicates that implementations may vary
2.  Shall not perform any actions that are described as producing *undefined* results
3.  For symbolic constants, shall accept any value in the range permitted by POSIX.1-2024, but shall not rely on any value in the range being greater than the minimums listed or being less than the maximums listed in POSIX.1-2024
4.  Shall not use facilities designated as *obsolescent*
5.  Is required to tolerate and permitted to adapt to the presence or absence of optional facilities whose availability is indicated by [2.1.4 XSI Conformance](#tag_02_01_04)
6.  For the C programming language, shall not produce any output dependent on any behavior described in the ISO C standard as *unspecified*, *undefined*, or *implementation-defined*, unless the System Interfaces volume of POSIX.1-2024 specifies the behavior
7.  For the C programming language, shall not exceed any minimum implementation limit defined in the ISO C standard, unless the System Interfaces volume of POSIX.1-2024 specifies a higher minimum implementation limit
8.  For the C programming language, shall define \_XOPEN_SOURCE to be 800 before any header is included

Within POSIX.1-2024, any restrictions placed upon a Conforming POSIX Application shall restrict a Strictly Conforming XSI Application.

#### <span id="tag_02_02_05"></span>2.2.5 Conforming XSI Application Using Extensions

A Conforming XSI Application Using Extensions is an application that differs from a Strictly Conforming XSI Application only in that it uses non-standard facilities that are consistent with POSIX.1-2024. Such an application shall fully document its requirements for these extended facilities, in addition to the documentation required of a Strictly Conforming XSI Application.

### <span id="tag_02_03"></span>2.3 Language-Dependent Services for the C Programming Language

Implementors seeking to claim conformance using the ISO C standard shall claim POSIX conformance as described in [2.1.3 POSIX Conformance](#tag_02_01_03).

### <span id="tag_02_04"></span>2.4 Other Language-Related Specifications

POSIX.1-2024 is currently specified in terms of the shell command language and ISO C. Bindings to other programming languages are being developed.

If conformance to POSIX.1-2024 is claimed for implementation of any programming language, the implementation of that language shall support the use of external symbols distinct to at least 31 bytes in length in the source program text. (That is, identifiers that differ at or before the thirty-first byte shall be distinct.) If a national or international standard governing a language defines a maximum length that is less than this value, the language-defined maximum shall be supported. External symbols that differ only by case shall be distinct when the character set in use distinguishes uppercase and lowercase characters and the language permits (or requires) uppercase and lowercase characters to be distinct in external symbols.

------------------------------------------------------------------------

#### <span id="tag_02_04_01"></span>Footnotes

<span id="tag_foot_1"></span>1. As an example, the File System profiling option group provides underlying support for pathname resolution and file creation which are needed by any interface in POSIX.1-2024 that parses a *path* argument. If a profile requires support for the Device Input and Output profiling option group but does not require support for the File System profiling option group, the profile needs to specify how pathname resolution is to behave in that profile, how the O_CREAT flag to [*open*()](../functions/open.html) is to be handled (and the use of the character `'a'` in the *mode* argument of [*fopen*()](../functions/fopen.html) when a pathname argument names a file that does not exist), and specify lots of other details.

<span id="tag_foot_2"></span>2. As an example, POSIX.1-2024 requires that implementations claiming to support the Range Memory Locking option also support the Process Memory Locking option. A profile could require that the Range Memory Locking option had to be supplied without requiring that the Process Memory Locking option be supplied as long as the profile specifies everything an application developer or system implementor would have to know to build an application or implementation conforming to the profile.

<span id="tag_foot_3"></span>3. Note that the profile could just specify that any use of the features not specified by the profile would produce undefined or unspecified results.

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
