The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_04"></span>4. General Concepts

For the purposes of POSIX.1-2024, the general concepts given in [4. General Concepts](#tag_04) apply.

**Note:**  
No shading to denote extensions or options occurs in this chapter. Where the terms and definitions given in this chapter are used elsewhere in text related to extensions and options, they are shaded as appropriate.

### <span id="tag_04_01"></span>4.1 Case Insensitive Comparisons

When a standard utility or function that uses regular expressions or pattern matching specifies that matching shall be case insensitive, then if a string would match the regular expression or pattern when doing a case-sensitive match, the same string with any of its characters replaced with their case counterparts, as defined by the **toupper** and **tolower** character mappings (see [*7.3.1 LC_CTYPE*](../basedefs/V1_chap07.html#tag_07_03_01)), shall also match when doing a case-insensitive match.

This definition of case-insensitive processing is intended to allow matching of multi-character collating elements as well as characters, as each character in the string is matched using both its cases. For example, in a locale with a `"Ch"` multi-character collating element (see [*7.3.2 LC_COLLATE*](../basedefs/V1_chap07.html#tag_07_03_02)), the bracket expression `"[[.Ch.]]"` (see [*9.3.5 RE Bracket Expression*](../basedefs/V1_chap09.html#tag_09_03_05) item 4) matches the strings `"ch"`, `"Ch"`, `"cH"`, and `"CH"` when matching without regard to case.

### <span id="tag_04_02"></span>4.2 Concurrent Execution

Functions that suspend the execution of the calling thread shall not cause the execution of other threads to be indefinitely suspended.

### <span id="tag_04_03"></span>4.3 Default Initialization

Default initialization causes an object to be initialized according to these rules:

- If it has pointer type, it is initialized to a null pointer.

- If it has arithmetic type, it is initialized to (positive or unsigned) zero.

- If it is an aggregate, every member is initialized (recursively) according to these rules.

- If it is a union, the first named member is initialized (recursively) according to these rules.

For an object of aggregate type with an explicit initializer, the initialization shall occur in initializer list order, each initializer provided for a particular subobject overriding any previously listed initializer for the same subobject; all subobjects that are not initialized explicitly shall be initialized implicitly according to the rules for default initialization.

Objects with static storage duration but no explicit initializer shall be initialized implicitly according to the rules for default initialization.

An explicit initializer of `{ 0 }` works to perform explicit default initialization for any object of scalar or aggregate type, and for any storage duration.

**Notes:**  
1.  The ISO C standard does not require a compiler to set any field alignment padding bits in a structure or array definition to a particular value. Because of this, a structure initialized using `{ 0 }` might not [*memcmp*()](../functions/memcmp.html) as equal to the same structure initialized using [*memset*()](../functions/memset.html) to zero. For consistent results, portable applications comparing structures should test each field individually.

2.  If an implementation treats the all-zero bit pattern of a floating-point object as equivalent to positive 0, then [*memset*()](../functions/memset.html) to zero and [*calloc*()](../functions/calloc.html) have the same effects as default initialization for all named members of a structure. Implementations that define \_\_STDC_IEC_559\_\_ guarantee that the all-zero bit pattern of a floating-point object represents 0.0.

### <span id="tag_04_04"></span>4.4 Directory Operations

All file system operations that read or search a directory or that modify the contents of a directory (for example creating, unlinking, or renaming a file) shall operate atomically. That is, each operation shall either have its entire effect and succeed, or shall not affect the file system and shall fail. Furthermore, these operations shall be serializable; that is, the state of the file system and of the results of each operation shall always be values that would be obtained if the operations were executed one after the other.

### <span id="tag_04_05"></span>4.5 Directory Protection

If a directory is writable and the mode bit S_ISVTX is set on the directory, a process may remove or rename files within that directory only if one or more of the following is true:

- The effective user ID of the process is the same as that of the owner ID of the file.

- The effective user ID of the process is the same as that of the owner ID of the directory.

- The process has appropriate privileges.

- Optionally, the file is writable by the process. Whether or not files that are writable by the process can be removed or renamed is implementation-defined.

If the S_ISVTX bit is set on a non-directory file, the behavior is unspecified.

### <span id="tag_04_06"></span>4.6 Extended Security Controls

An implementation may provide implementation-defined extended security controls (see [*3.135 Extended Security Controls*](../basedefs/V1_chap03.html#tag_03_135)). These permit an implementation to provide security mechanisms to implement different security policies than those described in POSIX.1-2024. These mechanisms shall not alter or override the defined semantics of any of the interfaces in POSIX.1-2024.

### <span id="tag_04_07"></span>4.7 File Access Permissions

The standard file access control mechanism uses the file permission bits, as described below.

Implementations may provide *additional* or *alternate* file access control mechanisms, or both. An additional access control mechanism shall only further restrict the access permissions defined by the file permission bits. An alternate file access control mechanism shall:

- Specify file permission bits for the file owner class, file group class, and file other class of that file, corresponding to the access permissions.

- Be enabled only by explicit user action, on a per-file basis by the file owner or a user with appropriate privileges.

- Be disabled for a file after the file permission bits are changed for that file with [*chmod*()](../functions/chmod.html). The disabling of the alternate mechanism need not disable any additional mechanisms supported by an implementation.

Whenever a process requests file access permission for read, write, or execute/search, if no additional mechanism denies access, access shall be determined as follows:

- If a process has appropriate privileges:

  - If read, write, or directory search permission is requested, access shall be granted.

  - If execute permission is requested, access shall be granted if execute permission is granted to at least one user by the file permission bits or by an alternate access control mechanism; otherwise, access shall be denied.

- Otherwise:

  - The file permission bits of a file contain read, write, and execute/search permissions for the file owner class, file group class, and file other class.

  - Access shall be granted if an alternate access control mechanism is not enabled and the requested access permission bit is set for the class (file owner class, file group class, or file other class) to which the process belongs, or if an alternate access control mechanism is enabled and it allows the requested access; otherwise, access shall be denied.

### <span id="tag_04_08"></span>4.8 File Hierarchy

Files in the system are organized in a hierarchical structure in which all of the non-terminal nodes are directories and all of the terminal nodes are any other type of file. Since multiple directory entries may refer to the same file, the hierarchy is properly described as a "directed graph".

### <span id="tag_04_09"></span>4.9 Filenames

Uppercase and lowercase letters shall retain their unique identities between conforming implementations.

### <span id="tag_04_10"></span>4.10 Filename Portability

For a filename to be portable across implementations conforming to POSIX.1-2024, it shall consist only of the portable filename character set as defined in [*3.265 Portable Filename Character Set*](../basedefs/V1_chap03.html#tag_03_265).

**Note:**  
Applications should avoid using filenames that have the \<hyphen-minus\> character as the first character since this may cause problems when filenames are passed as command line arguments.

### <span id="tag_04_11"></span>4.11 File System Cache

If the file system is accessed via a memory cache, file-related requirements stated in the rest of this standard shall apply to the cache, except where explicitly stated otherwise: this includes directory atomicity and serializability requirements (see [4.4 Directory Operations](#tag_04_04)), file times update requirements (see [4.12 File Times Update](#tag_04_12)), and read-write serializability requirements (see [*write*()](../functions/write.html#tag_17_699)). Cache entries shall be transferred to the underlying storage as the result of successful calls to [*fdatasync*()](../functions/fdatasync.html), [*fsync*()](../functions/fsync.html), or [*aio_fsync*()](../functions/aio_fsync.html), and may be transferred to storage automatically at other times. Such transfers shall be atomic, with minimum units being directory entries (for directory contents), aligned data blocks of the fundamental file system block size (for regular-file contents; see [*\<sys/statvfs.h\>*](../basedefs/sys_statvfs.h.html)), and all attributes of a single file (for file attributes).

**Note:**  
If the system crashes before the cache is fully transferred, later operations' effects may be present in storage with earlier effects missing.

<!-- -->

**Note:**  
Operations that create or modify multiple directory entries, aligned data blocks, or file attributes (e.g., [*mkdir*()](../functions/mkdir.html), [*rename*()](../functions/rename.html), [*write*()](../functions/write.html) with large buffer size, [*open*()](../functions/open.html) with O_CREAT) may have only part of their effects transferred to storage, and after a crash these operations may appear to have been only partly done, with the parts not necessarily done in any order. For example, only the second half of a [*write*()](../functions/write.html) may be transferred; or `rename("a","b")` may result in **b** being created without **a** being removed.

<!-- -->

**Note:**  
Although conforming file systems are required to perform all caching as described above, some file systems may support non-conforming configurations (for example via mount options) for which this is not the case. Applications that are used on non-conforming file systems cannot rely on files being synchronized properly.

### <span id="tag_04_12"></span>4.12 File Times Update

Many operations have requirements to update file timestamps. These requirements do not apply to streams that have no underlying file description (for example, memory streams created by [*open_memstream*()](../functions/open_memstream.html) have no underlying file description).

Each file has three distinct associated timestamps: the time of last data access, the time of last data modification, and the time the file status last changed. These values are returned in the file characteristics structure **struct stat**, as described in [*\<sys/stat.h\>*](../basedefs/sys_stat.h.html).

Each function or utility in POSIX.1-2024 that reads or writes data (even if the data does not change) or performs an operation to change file status (even if the file status does not change) indicates which of the appropriate timestamps shall be marked for update. If an implementation of such a function or utility marks for update one of these timestamps in a place or time not specified by POSIX.1-2024, this shall be documented, except that any changes caused by pathname resolution need not be documented. For the other functions or utilities in POSIX.1-2024 (those that are not explicitly required to read or write file data or change file status, but that in some implementations happen to do so), the effect is unspecified.

An implementation may update timestamps that are marked for update immediately, or it may update such timestamps periodically. At the point in time when an update occurs, any marked timestamps shall be set to the current time and the update marks shall be cleared. All timestamps that are marked for update shall be updated when the file ceases to be open by any process or before a [*fstat*()](../functions/fstat.html), [*fstatat*()](../functions/fstatat.html), [*fsync*()](../functions/fsync.html), [*futimens*()](../functions/futimens.html), [*lstat*()](../functions/lstat.html), [*stat*()](../functions/stat.html), [*utimensat*()](../functions/utimensat.html), or [*utimes*()](../functions/utimes.html) is successfully performed on the file. Other times at which updates are done are unspecified. Marks for update, and updates themselves, shall not be done for files on read-only file systems; see [*3.295 Read-Only File System*](../basedefs/V1_chap03.html#tag_03_295).

The resolution of timestamps of files in a file system is implementation-defined, but shall be no coarser than one-second resolution. The three timestamps shall always have values that are supported by the file system. Whenever any of a file's timestamps are to be set to a value *V* according to the rules of the preceding paragraphs of this section, the implementation shall immediately set the timestamp to the greatest value supported by the file system that is not greater than *V*.

### <span id="tag_04_13"></span>4.13 Host and Network Byte Orders

When data is transmitted over the network, it is sent as a sequence of octets (8-bit unsigned values). If an entity (such as an address or a port number) can be larger than 8 bits, it needs to be stored in several octets. The convention is that all such values are stored with 8 bits in each octet, and with the first (lowest-addressed) octet holding the most-significant bits. This is called "network byte order".

Network byte order may not be convenient for processing actual values. For this, it is more sensible for values to be stored as ordinary integers. This is known as "host byte order". In host byte order:

- The most significant bit might not be stored in the first byte in address order.

- Bits might not be allocated to bytes in any obvious order at all.

8-bit values stored in **uint8_t** objects do not require conversion to or from host byte order, as they have the same representation. 16 and 32-bit values can be converted using the [*htonl*()](../functions/htonl.html), [*htons*()](../functions/htons.html), [*ntohl*()](../functions/ntohl.html), and [*ntohs*()](../functions/ntohs.html) functions. When reading data that is to be converted to host byte order, it should either be received directly into a **uint16_t** or **uint32_t** object or should be copied from an array of bytes using [*memcpy*()](../functions/memcpy.html) or similar. Passing the data through other types could cause the byte order to be changed. Similar considerations apply when sending data.

### <span id="tag_04_14"></span>4.14 Measurement of Execution Time

The mechanism used to measure execution time shall be implementation-defined. The implementation shall also define to whom the CPU time that is consumed by interrupt handlers and system services on behalf of the operating system will be charged. See [*3.90 CPU Time (Execution Time)*](../basedefs/V1_chap03.html#tag_03_90).

### <span id="tag_04_15"></span>4.15 Memory Ordering and Synchronization

#### <span id="tag_04_15_01"></span>4.15.1 Memory Ordering

##### <span id="tag_04_15_01_01"></span>4.15.1.1 Data Races

The value of an object visible to a thread *T* at a particular point is the initial value of the object, a value stored in the object by *T*, or a value stored in the object by another thread, according to the rules below.

Two expression evaluations *conflict* if one of them modifies a memory location and the other one reads or modifies the same memory location.

This standard defines a number of atomic operations (see [*\<stdatomic.h\>*](../basedefs/stdatomic.h.html)) and operations on mutexes (see [*\<threads.h\>*](../basedefs/threads.h.html)) that are specially identified as synchronization operations. These operations play a special role in making assignments in one thread visible to another. A synchronization operation on one or more memory locations is either an *acquire operation*, a *release operation*, both an acquire and release operation, or a *consume operation*. A synchronization operation without an associated memory location is a *fence* and can be either an acquire fence, a release fence, or both an acquire and release fence. In addition, there are *relaxed atomic operations*, which are not synchronization operations, and atomic *read-modify-write operations*, which have special characteristics.

**Note:**  
For example, a call that acquires a mutex will perform an acquire operation on the locations composing the mutex. Correspondingly, a call that releases the same mutex will perform a release operation on those same locations. Informally, performing a release operation on *A* forces prior side effects on other memory locations to become visible to other threads that later perform an acquire or consume operation on *A*. Relaxed atomic operations are not included as synchronization operations although, like synchronization operations, they cannot contribute to data races.

All modifications to a particular atomic object *M* occur in some particular total order, called the modification order of *M*. If *A* and *B* are modifications of an atomic object *M*, and *A* happens before *B*, then *A* shall precede *B* in the modification order of *M*, which is defined below.

**Note:**  
This states that the modification orders must respect the "happens before" relation.

<!-- -->

**Note:**  
There is a separate order for each atomic object. There is no requirement that these can be combined into a single total order for all objects. In general this will be impossible since different threads may observe modifications to different variables in inconsistent orders.

A *release sequence* headed by a release operation *A* on an atomic object *M* is a maximal contiguous sub-sequence of side effects in the modification order of *M*, where the first operation is *A* and every subsequent operation either is performed by the same thread that performed the release or is an atomic read-modify-write operation.

Certain system interfaces *synchronize with* other system interfaces performed by another thread. In particular, an atomic operation *A* that performs a release operation on an object *M* shall synchronize with an atomic operation *B* that performs an acquire operation on *M* and reads a value written by any side effect in the release sequence headed by *A*.

**Note:**  
Except in the specified cases, reading a later value does not necessarily ensure visibility as described below. Such a requirement would sometimes interfere with efficient implementation.

<!-- -->

**Note:**  
The specifications of the synchronization operations define when one reads the value written by another. For atomic variables, the definition is clear. All operations on a given mutex occur in a single total order. Each mutex acquisition "reads the value written" by the last mutex release.

An evaluation *A* *carries a dependency* to an evaluation *B* if:

- the value of *A* is used as an operand of *B*, unless:

  - *B* is an invocation of the [*kill_dependency*()](../functions/kill_dependency.html) macro,

  - *A* is the left operand of a `&&` or `||` operator,

  - *A* is the left operand of a `?:` operator, or

  - *A* is the left operand of a `,` (comma) operator; or

- *A* writes a scalar object or bit-field *M*, *B* reads from *M* the value written by *A*, and *A* is sequenced before *B*, or

- for some evaluation *X*, *A* carries a dependency to *X* and *X* carries a dependency to *B*.

An evaluation *A* is *dependency-ordered before* an evaluation *B* if:

- *A* performs a release operation on an atomic object *M*, and, in another thread, *B* performs a consume operation on *M* and reads a value written by any side effect in the release sequence headed by *A*, or

- for some evaluation *X*, *A* is dependency-ordered before *X* and *X* carries a dependency to *B*.

An evaluation *A* *inter-thread happens before* an evaluation *B* if *A* synchronizes with *B*, *A* is dependency-ordered before *B*, or, for some evaluation *X*:

- *A* synchronizes with *X* and *X* is sequenced before *B*,

- *A* is sequenced before *X* and *X* inter-thread happens before *B*, or

- *A* inter-thread happens before *X* and *X* inter-thread happens before *B*.

**Note:**  
The "inter-thread happens before" relation describes arbitrary concatenations of "sequenced before", "synchronizes with", and "dependency-ordered before" relationships, with two exceptions. The first exception is that a concatenation is not permitted to end with "dependency-ordered before" followed by "sequenced before". The reason for this limitation is that a consume operation participating in a "dependency-ordered before" relationship provides ordering only with respect to operations to which this consume operation actually carries a dependency. The reason that this limitation applies only to the end of such a concatenation is that any subsequent release operation will provide the required ordering for a prior consume operation. The second exception is that a concatenation is not permitted to consist entirely of "sequenced before". The reasons for this limitation are (1) to permit "inter-thread happens before" to be transitively closed and (2) the "happens before" relation, defined below, provides for relationships consisting entirely of "sequenced before".

An evaluation *A* *happens before* an evaluation *B* if *A* is sequenced before *B* or *A* inter-thread happens before *B*. The implementation shall ensure that a cycle in the "happens before" relation never occurs.

**Note:**  
This cycle would otherwise be possible only through the use of consume operations.

A *visible side effect* *A* on an object *M* with respect to a value computation *B* of *M* satisfies the conditions:

- *A* happens before *B*, and

- there is no other side effect *X* to *M* such that *A* happens before *X* and *X* happens before *B*.

The value of a non-atomic scalar object *M*, as determined by evaluation *B*, shall be the value stored by the visible side effect *A*.

**Note:**  
If there is ambiguity about which side effect to a non-atomic object is visible, then there is a data race and the behavior is undefined.

<!-- -->

**Note:**  
This states that operations on ordinary variables are not visibly reordered. This is not actually detectable without data races, but it is necessary to ensure that data races, as defined here, and with suitable restrictions on the use of atomics, correspond to data races in a simple interleaved (sequentially consistent) execution.

The value of an atomic object *M*, as determined by evaluation *B*, shall be the value stored by some side effect *A* that modifies *M*, where *B* does not happen before *A*.

**Note:**  
The set of side effects from which a given evaluation might take its value is also restricted by the rest of the rules described here, and in particular, by the coherence requirements below.

If an operation *A* that modifies an atomic object *M* happens before an operation *B* that modifies *M*, then *A* shall be earlier than *B* in the modification order of *M*. (This is known as "write-write coherence".)

If a value computation *A* of an atomic object *M* happens before a value computation *B* of *M*, and *A* takes its value from a side effect *X* on *M*, then the value computed by *B* shall either be the value stored by *X* or the value stored by a side effect *Y* on *M*, where *Y* follows *X* in the modification order of *M*. (This is known as "read-read coherence".)

If a value computation *A* of an atomic object *M* happens before an operation *B* on *M*, then *A* shall take its value from a side effect *X* on *M*, where *X* precedes *B* in the modification order of *M*. (This is known as "read-write coherence".)

If a side effect *X* on an atomic object *M* happens before a value computation *B* of *M*, then the evaluation *B* shall take its value from *X* or from a side effect *Y* that follows *X* in the modification order of *M*. (This is known as "write-read coherence".)

**Note:**  
This effectively disallows implementation reordering of atomic operations to a single object, even if both operations are "relaxed" loads. By doing so, it effectively makes the "cache coherence" guarantee provided by most hardware available to POSIX atomic operations.

<!-- -->

**Note:**  
The value observed by a load of an atomic object depends on the "happens before" relation, which in turn depends on the values observed by loads of atomic objects. The intended reading is that there must exist an association of atomic loads with modifications they observe that, together with suitably chosen modification orders and the "happens before" relation derived as described above, satisfy the resulting constraints as imposed here.

An application contains a data race if it contains two conflicting actions in different threads, at least one of which is not atomic, and neither happens before the other. Any such data race results in undefined behavior.

##### <span id="tag_04_15_01_02"></span>4.15.1.2 Memory Order and Consistency

The enumerated type **memory_order**, defined in [*\<stdatomic.h\>*](../basedefs/stdatomic.h.html) (if supported), specifies the detailed regular (non-atomic) memory synchronization operations as defined in [4.15.1.1 Data Races](#tag_04_15_01_01) and may provide for operation ordering. Its enumeration constants specify memory order as follows:

For `memory_order_relaxed`, no operation orders memory.

For `memory_order_release`, `memory_order_acq_rel`, and `memory_order_seq_cst`, a store operation performs a release operation on the affected memory location.

For `memory_order_acquire`, `memory_order_acq_rel`, and `memory_order_seq_cst`, a load operation performs an acquire operation on the affected memory location.

For `memory_order_consume`, a load operation performs a consume operation on the affected memory location.

There shall be a single total order *S* on all `memory_order_seq_cst` operations, consistent with the "happens before" order and modification orders for all affected locations, such that each `memory_order_seq_cst` operation *B* that loads a value from an atomic object *M* observes one of the following values:

- the result of the last modification *A* of *M* that precedes *B* in *S*, if it exists, or

- if *A* exists, the result of some modification of *M* that is not `memory_order_seq_cst` and that does not happen before *A*, or

- if *A* does not exist, the result of some modification of *M* that is not `memory_order_seq_cst`.

**Note:**  
Although it is not explicitly required that *S* include lock operations, it can always be extended to an order that does include lock and unlock operations, since the ordering between those is already included in the "happens before" ordering.

<!-- -->

**Note:**  
Atomic operations specifying `memory_order_relaxed` are relaxed only with respect to memory ordering. Implementations must still guarantee that any given atomic access to a particular atomic object be indivisible with respect to all other atomic accesses to that object.

For an atomic operation *B* that reads the value of an atomic object *M*, if there is a `memory_order_seq_cst` fence *X* sequenced before *B*, then *B* observes either the last `memory_order_seq_cst` modification of *M* preceding *X* in the total order *S* or a later modification of *M* in its modification order.

For atomic operations *A* and *B* on an atomic object *M*, where *A* modifies *M* and *B* takes its value, if there is a `memory_order_seq_cst` fence *X* such that *A* is sequenced before *X* and *B* follows *X* in *S*, then *B* observes either the effects of *A* or a later modification of *M* in its modification order.

For atomic modifications *A* and *B* of an atomic object *M*, *B* occurs later than *A* in the modification order of *M* if:

- there is a `memory_order_seq_cst` fence *X* such that *A* is sequenced before *X*, and *X* precedes *B* in *S*, or

- there is a `memory_order_seq_cst` fence *Y* such that *Y* is sequenced before *B*, and *A* precedes *Y* in *S*, or

- there are `memory_order_seq_cst` fences *X* and *Y* such that *A* is sequenced before *X*, *Y* is sequenced before *B*, and *X* precedes *Y* in *S*.

Atomic read-modify-write operations shall always read the last value (in the modification order) stored before the write associated with the read-modify-write operation.

An atomic store shall only store a value that has been computed from constants and input values by a finite sequence of evaluations, such that each evaluation observes the values of variables as computed by the last prior assignment in the sequence. The ordering of evaluations in this sequence shall be such that:

- If an evaluation *B* observes a value computed by *A* in a different thread, then *B* does not happen before *A*.

- If an evaluation *A* is included in the sequence, then all evaluations that assign to the same variable and happen before *A* are also included.

**Note:**  
The second requirement disallows "out-of-thin-air", or "speculative" stores of atomics when relaxed atomics are used. Since unordered operations are involved, evaluations can appear in this sequence out of thread order.

#### <span id="tag_04_15_02"></span>4.15.2 Memory Synchronization

In order to avoid data races, applications shall ensure that non-lock-free access to any memory location by more than one thread of control (threads or processes) is restricted such that no thread of control can read or modify a memory location while another thread of control might be modifying it. Such access can be restricted using functions that synchronize thread execution and also synchronize memory with respect to other threads. The following functions shall synchronize memory with respect to other threads on all successful calls:

<table data-cellpadding="3">
<colgroup>
<col style="width: 33%" />
<col style="width: 33%" />
<col style="width: 33%" />
</colgroup>
<tbody>
<tr data-valign="top">
<td style="text-align: left;"><p><br />
<a href="../functions/cnd_broadcast.html"><em>cnd_broadcast</em>()</a><br />
<a href="../functions/cnd_signal.html"><em>cnd_signal</em>()</a><br />
<a href="../functions/fork.html"><em>fork</em>()</a><br />
<a href="../functions/pthread_barrier_wait.html"><em>pthread_barrier_wait</em>()</a><br />
<a href="../functions/pthread_cond_broadcast.html"><em>pthread_cond_broadcast</em>()</a><br />
<a href="../functions/pthread_cond_signal.html"><em>pthread_cond_signal</em>()</a><br />
<a href="../functions/pthread_create.html"><em>pthread_create</em>()</a><br />
<a href="../functions/pthread_join.html"><em>pthread_join</em>()</a><br />
<a href="../functions/pthread_spin_lock.html"><em>pthread_spin_lock</em>()</a><br />
<a href="../functions/pthread_spin_trylock.html"><em>pthread_spin_trylock</em>()</a><br />
<a href="../functions/pthread_spin_unlock.html"><em>pthread_spin_unlock</em>()</a><br />
 </p></td>
<td style="text-align: left;"><p><br />
<a href="../functions/pthread_rwlock_clockrdlock.html"><em>pthread_rwlock_clockrdlock</em>()</a><br />
<a href="../functions/pthread_rwlock_clockwrlock.html"><em>pthread_rwlock_clockwrlock</em>()</a><br />
<a href="../functions/pthread_rwlock_rdlock.html"><em>pthread_rwlock_rdlock</em>()</a><br />
<a href="../functions/pthread_rwlock_timedrdlock.html"><em>pthread_rwlock_timedrdlock</em>()</a><br />
<a href="../functions/pthread_rwlock_timedwrlock.html"><em>pthread_rwlock_timedwrlock</em>()</a><br />
<a href="../functions/pthread_rwlock_tryrdlock.html"><em>pthread_rwlock_tryrdlock</em>()</a><br />
<a href="../functions/pthread_rwlock_trywrlock.html"><em>pthread_rwlock_trywrlock</em>()</a><br />
<a href="../functions/pthread_rwlock_unlock.html"><em>pthread_rwlock_unlock</em>()</a><br />
<a href="../functions/pthread_rwlock_wrlock.html"><em>pthread_rwlock_wrlock</em>()</a><br />
<a href="../functions/sem_clockwait.html"><em>sem_clockwait</em>()</a><br />
<a href="../functions/sem_post.html"><em>sem_post</em>()</a><br />
 </p></td>
<td style="text-align: left;"><p><br />
<a href="../functions/sem_timedwait.html"><em>sem_timedwait</em>()</a><br />
<a href="../functions/sem_trywait.html"><em>sem_trywait</em>()</a><br />
<a href="../functions/sem_wait.html"><em>sem_wait</em>()</a><br />
<a href="../functions/semctl.html"><em>semctl</em>()</a><br />
<a href="../functions/semop.html"><em>semop</em>()</a><br />
<a href="../functions/thrd_create.html"><em>thrd_create</em>()</a><br />
<a href="../functions/thrd_join.html"><em>thrd_join</em>()</a><br />
<a href="../functions/wait.html"><em>wait</em>()</a><br />
<a href="../functions/waitid.html"><em>waitid</em>()</a><br />
<a href="../functions/waitpid.html"><em>waitpid</em>()</a><br />
 </p></td>
</tr>
</tbody>
</table>

The [*pthread_once*()](../functions/pthread_once.html) and [*call_once*()](../functions/call_once.html) functions shall synchronize memory for the first successful call in each thread for a given **pthread_once_t** or **once_flag** object, respectively. If the *init_routine* called by [*pthread_once*()](../functions/pthread_once.html) or [*call_once*()](../functions/call_once.html) is a cancellation point and is canceled, a successful call to [*pthread_once*()](../functions/pthread_once.html) for the same **pthread_once_t** object or to [*call_once*()](../functions/call_once.html) for the same **once_flag** object, made from a cancellation cleanup handler shall also synchronize memory.

The [*pthread_mutex_clocklock*()](../functions/pthread_mutex_clocklock.html), [*pthread_mutex_lock*()](../functions/pthread_mutex_lock.html), <sup>\[[RPP\|TPP](javascript:open_code('RPP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> [*pthread_mutex_setprioceiling*()](../functions/pthread_mutex_setprioceiling.html), <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> [*pthread_mutex_timedlock*()](../functions/pthread_mutex_timedlock.html), and [*pthread_mutex_trylock*()](../functions/pthread_mutex_trylock.html) functions shall synchronize memory on all calls that acquire the mutex, including those that return \[EOWNERDEAD\]. The [*pthread_mutex_unlock*()](../functions/pthread_mutex_unlock.html) function shall synchronize memory on all calls that release the mutex.

**Note:**  
If the mutex type is PTHREAD_MUTEX_RECURSIVE, calls to the locking functions do not acquire the mutex if the calling thread already owns it, and calls to [*pthread_mutex_unlock*()](../functions/pthread_mutex_unlock.html) do not release the mutex if it has a lock count greater than one.

The [*pthread_cond_clockwait*()](../functions/pthread_cond_clockwait.html), [*pthread_cond_wait*()](../functions/pthread_cond_wait.html), and [*pthread_cond_timedwait*()](../functions/pthread_cond_timedwait.html) functions shall synchronize memory on all calls that release and re-acquire the specified mutex, including calls that return \[EOWNERDEAD\], both when the mutex is released and when it is re-acquired.

**Note:**  
If the mutex type is PTHREAD_MUTEX_RECURSIVE, calls to [*pthread_cond_clockwait*()](../functions/pthread_cond_clockwait.html), [*pthread_cond_wait*()](../functions/pthread_cond_wait.html), and [*pthread_cond_timedwait*()](../functions/pthread_cond_timedwait.html) do not release and re-acquire the mutex if it has a lock count greater than one.

The [*mtx_lock*()](../functions/mtx_lock.html), [*mtx_timedlock*()](../functions/mtx_timedlock.html), and [*mtx_trylock*()](../functions/mtx_trylock.html) functions shall synchronize memory on all calls that acquire the mutex. The [*mtx_unlock*()](../functions/mtx_unlock.html) function shall synchronize memory on all calls that release the mutex.

**Note:**  
If the mutex is a recursive mutex, calls to the locking functions do not acquire the mutex if the calling thread already owns it, and calls to [*mtx_unlock*()](../functions/mtx_unlock.html) do not release the mutex if it has a lock count greater than one.

The [*cnd_wait*()](../functions/cnd_wait.html) and [*cnd_timedwait*()](../functions/cnd_timedwait.html) functions shall synchronize memory on all calls that release and re-acquire the specified mutex, both when the mutex is released and when it is re-acquired.

**Note:**  
If the mutex is a recursive mutex, calls to [*cnd_wait*()](../functions/cnd_wait.html) and [*cnd_timedwait*()](../functions/cnd_timedwait.html) do not release and re-acquire the mutex if it has a lock count greater than one.

Unless explicitly stated otherwise, if one of the functions named in this section returns an error, it is unspecified whether the invocation causes memory to be synchronized.

Applications can allow more than one thread of control to read a memory location simultaneously.

For purposes of determining the existence of a data race, all lock and unlock operations on a particular synchronization object that synchronize memory shall behave as atomic operations, and they shall occur in some particular total order (see [4.15.1 Memory Ordering](#tag_04_15_01)).

### <span id="tag_04_16"></span>4.16 Pathname Resolution

Pathname resolution is performed for a process to resolve a pathname to a particular directory entry for a file in the file hierarchy. There may be multiple pathnames that resolve to the same directory entry, and multiple directory entries for the same file. When a process resolves a pathname of an existing directory entry, the entire pathname shall be resolved as described below. When a process resolves a pathname of a directory entry that is to be created immediately after the pathname is resolved, pathname resolution terminates when all components of the path prefix of the last component have been resolved. It is then the responsibility of the process to create the final component.

Each filename in the pathname is located in the directory specified by its predecessor (for example, in the pathname fragment **a/b**, file **b** is located in the directory specified by **a**). Pathname resolution shall fail if this cannot be accomplished. If the pathname begins with a \<slash\>, the predecessor of the first filename in the pathname shall be taken to be the root directory of the process (such pathnames are referred to as "absolute pathnames"). If the pathname does not begin with a \<slash\>, the predecessor of the first filename of the pathname shall be taken to be either the current working directory of the process or for certain interfaces the directory identified by a file descriptor passed to the interface (such pathnames are referred to as "relative pathnames").

The interpretation of a pathname component is dependent on the value of {NAME_MAX} and \_POSIX_NO_TRUNC associated with the path prefix of that component. If any pathname component is longer than {NAME_MAX}, the implementation shall consider this an error.

A pathname that contains at least one non-\<slash\> character and that ends with one or more trailing \<slash\> characters shall not be resolved successfully unless the last pathname component before the trailing \<slash\> characters resolves (with symbolic links followed—see below) to an existing directory or a directory entry that is to be created for a directory immediately after the pathname is resolved. Interfaces using pathname resolution may specify additional constraints[<sup><span class="small">1</span></sup>](#tag_foot_1) when a pathname that does not name an existing directory contains at least one non-\<slash\> character and contains one or more trailing \<slash\> characters.

If a symbolic link is encountered during pathname resolution, the behavior shall depend on whether the pathname component is at the end of the pathname and on the function being performed. If all of the following are true, then pathname resolution is complete:

1.  This is the last pathname component of the pathname.
2.  The pathname has no trailing \<slash\>.
3.  The function is required to act on the symbolic link itself, or certain arguments direct that the function act on the symbolic link itself.

In all other cases, the system shall prefix the remaining pathname, if any, with the contents of the symbolic link, except that if the contents of the symbolic link is the empty string, then either pathname resolution shall fail with functions reporting an \[ENOENT\] error and utilities writing an equivalent diagnostic message, or the pathname of the directory containing the symbolic link shall be used in place of the contents of the symbolic link. If the contents of the symbolic link consist solely of \<slash\> characters, then all leading \<slash\> characters of the remaining pathname shall be omitted from the resulting combined pathname, leaving only the leading \<slash\> characters from the symbolic link contents. In the cases where prefixing occurs, if the combined length exceeds {PATH_MAX}, and the implementation considers this to be an error, pathname resolution shall fail with functions reporting an \[ENAMETOOLONG\] error and utilities writing an equivalent diagnostic message. Otherwise, the resolved pathname shall be the resolution of the pathname just created. If the resulting pathname does not begin with a \<slash\>, the predecessor of the first filename of the pathname is taken to be the directory containing the symbolic link.

If the system detects a loop in the pathname resolution process, pathname resolution shall fail with functions reporting an \[ELOOP\] error and utilities writing an equivalent diagnostic message. The same may happen if during the resolution process more symbolic links were followed than the implementation allows. This implementation-defined limit shall not be smaller than {SYMLOOP_MAX}.

The special filename dot shall refer to the directory specified by its predecessor. The special filename dot-dot shall refer to the parent directory of its predecessor directory. As a special case, in the root directory, dot-dot may refer to the root directory itself.

A pathname consisting of a single \<slash\> shall resolve to the root directory of the process. A null pathname shall not be successfully resolved. If a pathname begins with two successive \<slash\> characters, the first component following the leading \<slash\> characters may be interpreted in an implementation-defined manner, although more than two leading \<slash\> characters shall be treated as a single \<slash\> character.

Pathname resolution for a given pathname shall yield the same results when used by any interface in POSIX.1-2024 as long as there are no changes to any files evaluated during pathname resolution for the given pathname between resolutions.

### <span id="tag_04_17"></span>4.17 Process ID Reuse

A process group ID shall not be reused by the system until the process group lifetime ends.

A process ID shall not be reused by the system until the process lifetime ends. In addition, if there exists a process group whose process group ID is equal to that process ID, the process ID shall not be reused by the system until the process group lifetime ends. A process that is not a system process shall not have a process ID of 1.

### <span id="tag_04_18"></span>4.18 Scheduling Policy

A scheduling policy affects process or thread ordering:

- When a process or thread is a running thread and it becomes a blocked thread
- When a process or thread is a running thread and it becomes a preempted thread
- When a process or thread is a blocked thread and it becomes a runnable thread
- When a running thread calls a function that can change the priority or scheduling policy of a process or thread
- In other scheduling policy-defined circumstances

Conforming implementations shall define the manner in which each of the scheduling policies may modify the priorities or otherwise affect the ordering of processes or threads at each of the occurrences listed above. Additionally, conforming implementations shall define in what other circumstances and in what manner each scheduling policy may modify the priorities or affect the ordering of processes or threads.

### <span id="tag_04_19"></span>4.19 Seconds Since the Epoch

A value that approximates the number of seconds that have elapsed since the Epoch. A Coordinated Universal Time name (specified in terms of seconds (*tm_sec*), minutes (*tm_min*), hours (*tm_hour*), days since January 1 of the year (*tm_yday*), and calendar year minus 1900 (*tm_year*)) is related to a time represented as seconds since the Epoch, according to the expression below.

If the year is \<1970 or the value is negative, the relationship is undefined. If the year is \>=1970 and the value is non-negative, the value is related to a Coordinated Universal Time name according to the C-language expression, where *tm_sec*, *tm_min*, *tm_hour*, *tm_yday*, and *tm_year* are all integer types:


    tm_sec + tm_min*60 + tm_hour*3600 + tm_yday*86400 +
        (tm_year-70)*31536000 + ((tm_year-69)/4)*86400 -
        ((tm_year-1)/100)*86400 + ((tm_year+299)/400)*86400

The relationship between the actual date and time in Coordinated Universal Time, as determined by the International Earth Rotation Service, and the system's current value for seconds since the Epoch is unspecified.

How any changes to the value of seconds since the Epoch are made to align to a desired relationship with the current actual time is implementation-defined. As represented in seconds since the Epoch, each and every day shall be accounted for by exactly 86400 seconds.

**Note:**  
The last three terms of the expression add in a day for each year that follows a leap year starting with the first leap year since the Epoch. The first term adds a day every 4 years starting in 1973, the second subtracts a day back out every 100 years starting in 2001, and the third adds a day back in every 400 years starting in 2001. The divisions in the formula are integer divisions; that is, the remainder is discarded leaving only the integer quotient.

### <span id="tag_04_20"></span>4.20 Semaphore

A minimum synchronization primitive to serve as a basis for more complex synchronization mechanisms to be defined by the application program.

For the mandatory semaphores (those not associated with the X/Open System Interfaces (XSI) option), a semaphore is represented as a shareable resource that has a non-negative integer value. When the value is zero, there is a (possibly empty) set of threads awaiting the availability of the semaphore.

For the semaphores associated with the X/Open System Interfaces (XSI) option, a semaphore is an integer with minimum value 0 and an implementation-defined maximum value which shall be at least 32767. The [*semget*()](../functions/semget.html) function can be called to create a set or array of semaphores. A semaphore set can contain one or more semaphores up to an implementation-defined value.

##### <span id="tag_04_20_00_01"></span>Semaphore Lock Operation

An operation that is applied to a semaphore. If, prior to the operation, the value of the semaphore is zero, the semaphore lock operation shall cause the calling thread to be blocked and added to the set of threads awaiting the semaphore; otherwise, the value shall be decremented.

##### <span id="tag_04_20_00_02"></span>Semaphore Unlock Operation

An operation that is applied to a semaphore. If, prior to the operation, there are any threads in the set of threads awaiting the semaphore, then some thread from that set shall be removed from the set and becomes unblocked; otherwise, the semaphore value shall be incremented.

### <span id="tag_04_21"></span>4.21 Special Device Drivers

Some devices require control operations, other than the operations that are common to most devices (such as [*read*()](../functions/read.html), [*write*()](../functions/write.html), [*open*()](../functions/open.html), and [*close*()](../functions/close.html)), but because the device belongs to a class that is not present in the majority of systems, standardization of a device-specific application program interface (API) for controlling it has not been practical. The driver for such a device may respond to the [*write*()](../functions/write.html) function to transfer data to the device or the [*read*()](../functions/read.html) function to collect information from the device. The interpretation of the information is defined by the implementor of the driver.

The term *special device* refers to hardware, or an object that appears to the application as such; access to the driver for this hardware uses the file abstraction *character special file*. Implementations supporting the Device Control option shall provide the means to integrate a device driver into the system. The means available to integrate drivers into the system and the way character special files that refer to them are created are implementation defined. Character special files that have no structure defined by this standard can be accessed using the [*posix_devctl*()](../functions/posix_devctl.html) function defined in the System Interfaces volume of POSIX.1-2024.

### <span id="tag_04_22"></span>4.22 Thread-Safety

Refer to XSH [*2.9 Threads*](../functions/V2_chap02.html#tag_16_09).

### <span id="tag_04_23"></span>4.23 Treatment of Error Conditions for Mathematical Functions

For all the functions in the [*\<math.h\>*](../basedefs/math.h.html) header, an application wishing to check for error situations should set *errno* to 0 and call *feclearexcept*(FE_ALL_EXCEPT) before calling the function. On return, if *errno* is non-zero or *fetestexcept*(FE_INVALID \| FE_DIVBYZERO \| FE_OVERFLOW \| FE_UNDERFLOW) is non-zero, an error has occurred.

On implementations that support the IEC 60559 Floating-Point option, whether or when functions in the [*\<math.h\>*](../basedefs/math.h.html) header raise an undeserved underflow floating-point exception is unspecified. Otherwise, as implied by XSH [*feraiseexcept*()](../functions/feraiseexcept.html#), the [*\<math.h\>*](../basedefs/math.h.html) functions do not raise spurious floating-point exceptions (detectable by the user), other than the inexact floating-point exception.

The error conditions defined for all functions in the [*\<math.h\>*](../basedefs/math.h.html) header are domain, pole and range errors, described below. If a domain, pole, or range error occurs and the integer expression (math_errhandling & MATH_ERRNO) is zero, then *errno* shall either be set to the value corresponding to the error, as specified below, or be left unmodified. If no such error occurs, *errno* shall be left unmodified regardless of the setting of *math_errhandling*.

#### <span id="tag_04_23_01"></span>4.23.1 Domain Error

A "domain error" shall occur if an input argument is outside the domain over which the mathematical function is defined. The description of each function lists any required domain errors; an implementation may define additional domain errors, provided that such errors are consistent with the mathematical definition of the function.

On a domain error, the function shall return an implementation-defined value; if the integer expression (math_errhandling & MATH_ERRNO) is non-zero, *errno* shall be set to \[EDOM\]; if the integer expression (math_errhandling & MATH_ERREXCEPT) is non-zero, the "invalid" floating-point exception shall be raised.

#### <span id="tag_04_23_02"></span>4.23.2 Pole Error

A "pole error" shall occur if the mathematical result of the function has an exact infinite result as the finite input argument(s) are approached in the limit (for example, `log(0.0)`). The description of each function lists any required pole errors; an implementation may define additional pole errors, provided that such errors are consistent with the mathematical definition of the function.

On a pole error, the function shall return the value of the macro HUGE_VAL, HUGE_VALF, or HUGE_VALL according to the return type, with the same sign as the correct value of the function; if the integer expression (math_errhandling & MATH_ERRNO) is non-zero, *errno* shall be set to \[ERANGE\]; if the integer expression (math_errhandling & MATH_ERREXCEPT) is non-zero, the "divide-by-zero" floating-point exception shall be raised.

#### <span id="tag_04_23_03"></span>4.23.3 Range Error

A "range error" shall occur if the finite mathematical result of the function cannot be represented in an object of the specified type, due to extreme magnitude. The description of each function lists any required range errors; an implementation may define additional range errors, provided that such errors are consistent with the mathematical definition of the function and are the result of either overflow or underflow.

##### <span id="tag_04_23_03_01"></span>4.23.3.1 Result Overflows

A floating result overflows if the magnitude of the mathematical result is finite but so large that the mathematical result cannot be represented without extraordinary roundoff error in an object of the specified type. If a floating result overflows and default rounding is in effect, then the function shall return the value of the macro HUGE_VAL, HUGE_VALF, or HUGE_VALL according to the return type, with the same sign as the correct value of the function; if the integer expression (math_errhandling & MATH_ERRNO) is non-zero, *errno* shall be set to \[ERANGE\]; if the integer expression (math_errhandling & MATH_ERREXCEPT) is non-zero, the "overflow" floating-point exception shall be raised.

##### <span id="tag_04_23_03_02"></span>4.23.3.2 Result Underflows

The result underflows if the magnitude of the mathematical result is so small that the mathematical result cannot be represented, without extraordinary roundoff error, in an object of the specified type. If the result underflows, the function shall return an implementation-defined value whose magnitude is no greater than the smallest normalized positive number in the specified type; if the integer expression (math_errhandling & MATH_ERRNO) is non-zero, whether *errno* is set to \[ERANGE\] is implementation-defined; if the integer expression (math_errhandling & MATH_ERREXCEPT) is non-zero, whether the "underflow" floating-point exception is raised is implementation-defined.

### <span id="tag_04_24"></span>4.24 Treatment of NaN Arguments for the Mathematical Functions

For functions called with a NaN argument, no errors shall occur and a NaN shall be returned, except where stated otherwise.

If a function with one or more NaN arguments returns a NaN result, the result should be the same as one of the NaN arguments (after possible type conversion), except perhaps for the sign.

On implementations that support the IEC 60559:1989 standard floating point, functions with signaling NaN argument(s) shall be treated as if the function were called with an argument that is a required domain error and shall return a quiet NaN result, except where stated otherwise.

**Note:**  
The function might never see the signaling NaN, since it might trigger when the arguments are evaluated during the function call.

On implementations that support the IEC 60559:1989 standard floating point, for those functions that do not have a documented domain error, the following shall apply:

> These functions shall fail if:
>
> Domain Error
>
> Any argument is a signaling NaN.
>
> Either, the integer expression (math_errhandling & MATH_ERRNO) is non-zero and *errno* shall be set to \[EDOM\], or the integer expression (math_errhandling & MATH_ERREXCEPT) is non-zero and the invalid floating-point exception shall be raised.

### <span id="tag_04_25"></span>4.25 Utility

A utility program shall be either an executable file, such as might be produced by a compiler or linker system from computer source code, or a file of shell source code, directly interpreted by the shell. The program may have been produced by the user, provided by the system implementor, or acquired from an independent distributor.

The system may implement certain utilities as shell functions (see XCU [*2.9.5 Function Definition Command*](../utilities/V3_chap02.html#tag_19_09_05)) or built-in utilities, but only an application that is aware of the command search order (as described in XCU [*2.9.1.4 Command Search and Execution*](../utilities/V3_chap02.html#tag_19_09_01_04)) or of performance characteristics can discern differences between the behavior of such a function or built-in utility and that of an executable file.

### <span id="tag_04_26"></span>4.26 Variable Assignment

In the shell command language, a word consisting of the following parts:


    varname=value

When used in a context where assignment is defined to occur and at no other time, the *value* (representing a word or field) shall be assigned as the value of the variable denoted by *varname*. Assignment context occurs in the *cmd_prefix* portion of a shell simple command, as well as in arguments of a recognized declaration utility.

**Note:**  
For further information, see XCU [*2.9.1 Simple Commands*](../utilities/V3_chap02.html#tag_19_09_01).

The *varname* and *value* parts shall meet the requirements for a name and a word, respectively, except that they are delimited by the embedded unquoted \<equals-sign\>, in addition to other delimiters.

**Note:**  
Additional delimiters are described in XCU [*2.3 Token Recognition*](../utilities/V3_chap02.html#tag_19_03) .

When a variable assignment is done, the variable shall be created if it did not already exist. If *value* is not specified, the variable shall be given a null value.

**Note:**  
An alternative form of variable assignment:


    symbol=value

(where *symbol* is a valid word delimited by an \<equals-sign\>, but not a valid name) produces unspecified results. The form *symbol*=*value* is used by the KornShell *name*\[*expression*\]=*value* syntax.

------------------------------------------------------------------------

#### <span id="tag_04_26_01"></span>Footnotes

<span id="tag_foot_1"></span>1. The only interfaces that further constrain pathnames in POSIX.1-2024 are the [*rename*()](../functions/rename.html) and [*renameat*()](../functions/renameat.html) functions (see XSH [*rename*()](../functions/rename.html#)) and the [*mv*](../utilities/mv.html) utility (see XCU [*mv*](../utilities/mv.html#)).

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
