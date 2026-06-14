The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span>

## <span id="tag_01"></span>1. Introduction

### <span id="tag_01_01"></span>1.1 Scope

POSIX.1-2024 defines a standard operating system interface and environment, including a command interpreter (or "shell"), and common utility programs to support applications portability at the source code level. It is intended to be used by both application developers and system implementors.

POSIX.1-2024 comprises four major components (each in an associated volume):

1.  General terms, concepts, and interfaces common to all volumes of POSIX.1-2024, including utility conventions and C-language header definitions, are included in the Base Definitions volume of POSIX.1-2024.

2.  Definitions for system service functions and subroutines, language-specific system services for the C programming language, function issues, including portability, error handling, and error recovery, are included in the System Interfaces volume of POSIX.1-2024.

3.  Definitions for a standard source code-level interface to command interpretation services (a "shell") and common utility programs for application programs are included in the Shell and Utilities volume of POSIX.1-2024.

4.  Extended rationale that did not fit well into the rest of the document structure, containing historical information concerning the contents of POSIX.1-2024 and why features were included or discarded by the standard developers, is included in the Rationale (Informative) volume of POSIX.1-2024.

The following areas are outside of the scope of POSIX.1-2024:

- Graphics interfaces

- Database management system interfaces

- Record I/O considerations

- Object or binary code portability

- System configuration and resource availability

POSIX.1-2024 describes the external characteristics and facilities that are of importance to application developers, rather than the internal construction techniques employed to achieve these capabilities. Special emphasis is placed on those functions and facilities that are needed in a wide variety of commercial applications.

The facilities provided in POSIX.1-2024 are drawn from the following base documents:

- IEEE Std 1003.1-2017 (POSIX.1-2017)

- IEEE Std 1003.26-2003 (POSIX.26-2003)

- ISO/IEC 9899:2018, Programming Languages — C (C17)

- ISO/IEC TR 24731-2:2010, Programming languages, their environments and system software interfaces — Extensions to the C library — Part 2: Dynamic Allocation Functions

- The Open Group Standard, 2021, Additional APIs for the Base Specifications Issue 8, Part 1

- The Open Group Standard, 2022, Additional APIs for the Base Specifications Issue 8, Part 2

Emphasis has been placed on standardizing existing practice for existing users, with changes and additions limited to correcting deficiencies in the following areas:

- Issues raised by Austin Group defect reports and IEEE Interpretations against IEEE Std 1003.1.

- Issues raised in corrigenda for The Open Group Standards and working group resolutions from The Open Group

- Changes to make the text self-consistent with the additional material merged

- Features, marked obsolescent in the base documents, have been considered for removal in this version

- Alignment with the ISO/IEC 9899:2018 standard

### <span id="tag_01_02"></span>1.2 Word Usage

The word *shall* indicates mandatory requirements strictly to be followed in order to conform to the standard and from which no deviation is permitted (*shall* equals *is required to*). [<sup><span class="small">1</span></sup>](#tag_foot_1)<span class="small"><sup>,</sup></span> [<sup><span class="small">2</span></sup>](#tag_foot_2)

The word *should* indicates that among several possibilities one is recommended as particularly suitable, without mentioning or excluding others; or that a certain course of action is preferred but not necessarily required (*should* equals *is recommended that*).

The word *may* is used to indicate a course of action permissible within the limits of the standard (*may* equals *is permitted to*).

The word *can* is used for statements of possibility and capability, whether material, physical, or causal (*can* equals *is able to*).

### <span id="tag_01_03"></span>1.3 Conformance

Conformance requirements for POSIX.1-2024 are defined in [*2. Conformance*](../basedefs/V1_chap02.html#tag_02) .

### <span id="tag_01_04"></span>1.4 Normative References

The following standards contain provisions which, through references in POSIX.1-2024, constitute provisions of POSIX.1-2024. At the time of publication, the editions indicated were valid. All standards are subject to revision, and parties to agreements based on POSIX.1-2024 are encouraged to investigate the possibility of applying the most recent editions of the standards listed below. Members of IEC and ISO maintain registers of currently valid International Standards.

ISO/IEC 646:1991

ISO/IEC 646:1991, Information Processing — ISO 7-Bit Coded Character Set for Information Interchange.[<sup><span class="small">3</span></sup>](#tag_foot_3)

ISO 4217:2015

ISO 4217:2015, Codes for the representation of currencies.

ISO 8601-1:2019

ISO 8601-1:2019, Date and time — Representations for information interchange — Part 1: Basic rules.

ISO C (C17)

ISO/IEC 9899:2018, Programming Languages — C.

ISO/IEC 10646:2020

ISO/IEC 10646:2020, Information Technology — Universal coded character set (UCS).

### <span id="tag_01_05"></span>1.5 Change History

Change history is described in the Rationale (Informative) volume of POSIX.1-2024, and in the CHANGE HISTORY section of reference pages.

### <span id="tag_01_06"></span>1.6 Terminology

For the purposes of POSIX.1-2024, the following terminology definitions apply:

#### <span id="tag_01_06_01"></span>can

Describes a permissible optional feature or behavior available to the user or application. The feature or behavior is mandatory for an implementation that conforms to POSIX.1-2024. An application can rely on the existence of the feature or behavior.

#### <span id="tag_01_06_02"></span>implementation-defined

Describes a value or behavior that is not defined by POSIX.1-2024 but is selected by an implementor. The value or behavior may vary among implementations that conform to POSIX.1-2024. An application should not rely on the existence of the value or behavior. An application that relies on such a value or behavior cannot be assured to be portable across conforming implementations.

The implementor shall document such a value or behavior so that it can be used correctly by an application.

#### <span id="tag_01_06_03"></span>legacy

Describes a feature or behavior that is being retained for compatibility with older applications, but which has limitations which make it inappropriate for developing portable applications. New applications should use alternative means of obtaining equivalent functionality.

#### <span id="tag_01_06_04"></span>may

Describes a feature or behavior that is optional for an implementation that conforms to POSIX.1-2024. An application should not rely on the existence of the feature or behavior. An application that relies on such a feature or behavior cannot be assured to be portable across conforming implementations.

To avoid ambiguity, the opposite of *may* is expressed as *need not*, instead of *may not*.

#### <span id="tag_01_06_05"></span>shall

For an implementation that conforms to POSIX.1-2024, describes a feature or behavior that is mandatory. An application can rely on the existence of the feature or behavior.

For an application or user, describes a behavior that is mandatory.

#### <span id="tag_01_06_06"></span>should

For an implementation that conforms to POSIX.1-2024, describes a feature or behavior that is recommended but not mandatory. An application should not rely on the existence of the feature or behavior. An application that relies on such a feature or behavior cannot be assured to be portable across conforming implementations.

For an application, describes a feature or behavior that is recommended programming practice for optimum portability.

#### <span id="tag_01_06_07"></span>undefined

Describes the nature of a value or behavior not defined by POSIX.1-2024 which results from use of an invalid program construct or invalid data input.

The value or behavior may vary among implementations that conform to POSIX.1-2024. An application should not rely on the existence or validity of the value or behavior. An application that relies on any particular value or behavior cannot be assured to be portable across conforming implementations.

#### <span id="tag_01_06_08"></span>unspecified

Describes the nature of a value or behavior not specified by POSIX.1-2024 which results from use of a valid program construct or valid data input.

The value or behavior may vary among implementations that conform to POSIX.1-2024. An application should not rely on the existence or validity of the value or behavior. An application that relies on any particular value or behavior cannot be assured to be portable across conforming implementations.

### <span id="tag_01_07"></span>1.7 Definitions and Concepts

Definitions and concepts are defined in [*3. Definitions*](../basedefs/V1_chap03.html#tag_03) and [*4. General Concepts*](../basedefs/V1_chap04.html#tag_04).

### <span id="tag_01_08"></span>1.8 Portability

Some of the utilities in the Shell and Utilities volume of POSIX.1-2024 and functions in the System Interfaces volume of POSIX.1-2024 describe functionality that might not be fully portable to systems meeting the requirements for POSIX conformance (see [*2. Conformance*](../basedefs/V1_chap02.html#tag_02)).

Where optional, enhanced, or reduced functionality is specified, the text is shaded and a code in the margin identifies the nature of the option, extension, or warning (see [1.8.1 Codes](#tag_01_08_01)). For maximum portability, an application should avoid such functionality.

Unless the primary task of a utility is to produce textual material on its standard output, application developers should not rely on the format or content of any such material that may be produced. Where the primary task *is* to provide such material, but the output format is incompletely specified, the description is marked with the OF margin code and shading. Application developers are warned not to expect that the output of such an interface on one system is any guide to its behavior on another system.

#### <span id="tag_01_08_01"></span>1.8.1 Codes

The codes and their meanings are as follows. See also [1.8.2 Margin Code Notation](#tag_01_08_02).

<sup>\[[ADV](javascript:open_code('ADV'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Advisory Information <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the ADV margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the ADV margin legend.

<sup>\[[CD](javascript:open_code('CD'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> C-Language Development Utilities <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional.

Where applicable, utilities are marked with the CD margin legend in the SYNOPSIS section. Where additional semantics apply to a utility, the material is identified by use of the CD margin legend.

<sup>\[[CPT](javascript:open_code('CPT'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Process CPU-Time Clocks <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the CPT margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the CPT margin legend.

<sup>\[[CX](javascript:open_code('CX'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Extension to the ISO C standard <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is an extension to the ISO C standard or a deviation from it. Application developers can make use of the functionality as it is supported on all POSIX.1-2024-conforming systems.

With each function or header from the ISO C standard, a statement is included to the effect that "any conflict is unintentional", or "any other conflict is unintentional" if there is an intentional conflict (deviation). That is intended to refer to a direct conflict. POSIX.1-2024 acts in part as a profile of the ISO C standard, and it may choose to further constrain behaviors allowed to vary by the ISO C standard. Such limitations and other compatible differences are not considered conflicts, even if a CX mark is missing. The markings are for information only.

Where additional semantics apply to a function or header, the material is identified by use of the CX margin legend.

<sup>\[[DC](javascript:open_code('DC'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Device Control <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the DC margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the DC margin legend.

<sup>\[[FR](javascript:open_code('FR'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> FORTRAN Runtime Utilities <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional.

Where applicable, utilities are marked with the FR margin legend in the SYNOPSIS section. Where additional semantics apply to a utility, the material is identified by use of the FR margin legend.

<sup>\[[FSC](javascript:open_code('FSC'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> File Synchronization <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the FSC margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the FSC margin legend.

<sup>\[[IP6](javascript:open_code('IP6'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> IPV6 <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the IP6 margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the IP6 margin legend.

<sup>\[[MC1](javascript:open_code('MC1'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Non-Robust Mutex Priority Protection or Non-Robust Mutex Priority Inheritance or Robust Mutex Priority Protection or Robust Mutex Priority Inheritance <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

This is a shorthand notation for combinations of multiple option codes.

Where applicable, functions are marked with the MC1 margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the MC1 margin legend.

Refer to [1.8.2 Margin Code Notation](#tag_01_08_02).

<sup>\[[ML](javascript:open_code('ML'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Process Memory Locking <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the ML margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the ML margin legend.

<sup>\[[MLR](javascript:open_code('MLR'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Range Memory Locking <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the MLR margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the MLR margin legend.

<sup>\[[MSG](javascript:open_code('MSG'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Message Passing <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the MSG margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the MSG margin legend.

<sup>\[[MX](javascript:open_code('MX'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> IEC 60559 Floating-Point <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is mandated by the ISO C standard only for implementations that define \_\_STDC_IEC_559\_\_.

<sup>\[[MXC](javascript:open_code('MXC'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> IEC 60559 Complex Floating-Point <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is mandated by the ISO C standard only for implementations that define \_\_STDC_IEC_559_COMPLEX\_\_.

<sup>\[[MXX](javascript:open_code('MXX'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> IEC 60559 Floating-Point Extension <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is part of the IEC 60559 Floating-Point option, but is an extension to the ISO C standard.

<sup>\[[OB](javascript:open_code('OB'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Obsolescent <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described may be removed in a future version of this volume of POSIX.1-2024. Strictly Conforming POSIX Applications and Strictly Conforming XSI Applications shall not use obsolescent features.

Where applicable, the material is identified by use of the OB margin legend.

<sup>\[[OF](javascript:open_code('OF'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Output Format Incompletely Specified <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is an XSI extension. The format of the output produced by the utility is not fully specified. It is therefore not possible to post-process this output in a consistent fashion. Typical problems include unknown length of strings and unspecified field delimiters.

Where applicable, the material is identified by use of the OF margin legend.

<sup>\[[OH](javascript:open_code('OH'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Optional Header <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
In the SYNOPSIS section of some interfaces in the System Interfaces volume of POSIX.1-2024 an included header is marked as in the following example:


    [OH]
    #include <sys/types.h>

    #include <fcntl.h>
    int open(const char *path, int oflag, ...);

The OH margin legend indicates that the optional header defines constants that will be needed if the function is called with certain flag arguments; thus it may be required for some of the functionality described, but is not needed otherwise.

<sup>\[[PIO](javascript:open_code('PIO'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Prioritized Input and Output <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the PIO margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the PIO margin legend.

<sup>\[[PS](javascript:open_code('PS'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Process Scheduling <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the PS margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the PS margin legend.

<sup>\[[RPI](javascript:open_code('RPI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Robust Mutex Priority Inheritance <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the RPI margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the RPI margin legend.

<sup>\[[RPP](javascript:open_code('RPP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Robust Mutex Priority Protection <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the RPP margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the RPP margin legend.

<sup>\[[RS](javascript:open_code('RS'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Raw Sockets <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the RS margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the RS margin legend.

<sup>\[[SD](javascript:open_code('SD'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Software Development Utilities <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional.

Where applicable, utilities are marked with the SD margin legend in the SYNOPSIS section. Where additional semantics apply to a utility, the material is identified by use of the SD margin legend.

<sup>\[[SHM](javascript:open_code('SHM'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Shared Memory Objects <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the SHM margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the SHM margin legend.

<sup>\[[SIO](javascript:open_code('SIO'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Synchronized Input and Output <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the SIO margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the SIO margin legend.

<sup>\[[SPN](javascript:open_code('SPN'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Spawn <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the SPN margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the SPN margin legend.

<sup>\[[SS](javascript:open_code('SS'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Process Sporadic Server <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the SS margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the SS margin legend.

<sup>\[[TCT](javascript:open_code('TCT'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Thread CPU-Time Clocks <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TCT margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TCT margin legend.

<sup>\[[TPI](javascript:open_code('TPI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Non-Robust Mutex Priority Inheritance <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TPI margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TPI margin legend.

<sup>\[[TPP](javascript:open_code('TPP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Non-Robust Mutex Priority Protection <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TPP margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TPP margin legend.

<sup>\[[TPS](javascript:open_code('TPS'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Thread Execution Scheduling <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TPS margin legend for the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TPS margin legend.

<sup>\[[TSA](javascript:open_code('TSA'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Thread Stack Address Attribute <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TSA margin legend for the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TSA margin legend.

<sup>\[[TSH](javascript:open_code('TSH'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Thread Process-Shared Synchronization <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TSH margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TSH margin legend.

<sup>\[[TSP](javascript:open_code('TSP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Thread Sporadic Server <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TSP margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TSP margin legend.

<sup>\[[TSS](javascript:open_code('TSS'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Thread Stack Size Attribute <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TSS margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TSS margin legend.

<sup>\[[TYM](javascript:open_code('TYM'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Typed Memory Objects <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the TYM margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the TYM margin legend.

<sup>\[[UP](javascript:open_code('UP'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> User Portability Utilities <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional.

Where applicable, utilities are marked with the UP margin legend in the SYNOPSIS section. Where additional semantics apply to a utility, the material is identified by use of the UP margin legend.

<sup>\[[UU](javascript:open_code('UU'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> UUCP Utilities <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is optional. The functionality described is also an extension to the ISO C standard.

Where applicable, functions are marked with the UU margin legend in the SYNOPSIS section. Where additional semantics apply to a function, the material is identified by use of the UU margin legend.

<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> X/Open System Interfaces <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />\
The functionality described is part of the X/Open Systems Interfaces option. Functionality marked XSI is an extension to the ISO C standard. Application developers may confidently make use of such extensions on all systems supporting the X/Open System Interfaces option.

If an entire SYNOPSIS section is shaded and marked XSI, all the functionality described in that reference page is an extension. See [*2.1.4 XSI Conformance*](../basedefs/V1_chap02.html#tag_02_01_04).

#### <span id="tag_01_08_02"></span>1.8.2 Margin Code Notation

Some of the functionality described in POSIX.1-2024 depends on support of more than one option, or independently may depend on several options. The following notation for margin codes is used to denote the following cases.

##### <span id="tag_01_08_02_01"></span>A Feature Dependent on One or Two Options

In this case, margin codes have a \<space\> separator; for example:

<sup>\[[SHM](javascript:open_code('SHM'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> This feature requires support for only the Shared Memory Objects option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

<sup>\[[SHM TYM](javascript:open_code('SHM%20TYM'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> This feature requires support for both the Shared Memory Objects option and the Typed Memory Objects option; that is, an application which uses this feature is portable only between implementations that provide both options. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

##### <span id="tag_01_08_02_02"></span>A Feature Dependent on Either of the Options Denoted

In this case, margin codes have a `'|'` separator to denote the logical OR; for example:

<sup>\[[SHM\|TYM](javascript:open_code('SHM'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> This feature is dependent on support for either the Shared Memory Objects option or the Typed Memory Objects option; that is, an application which uses this feature is portable between implementations that provide any (or all) of the options. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

##### <span id="tag_01_08_02_03"></span>A Feature Dependent on More than Two Options

The following shorthand notations are used:

<sup>\[[MC1](javascript:open_code('MC1'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> The MC1 margin code is shorthand for TPP\|TPI\|RPP\|RPI. Features which are shaded with this margin code require support of either the Non-Robust Mutex Priority Protection option or the Non-Robust Mutex Priority Inheritance option or the Robust Mutex Priority Protection option or the Robust Mutex Priority Inheritance option. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

##### <span id="tag_01_08_02_04"></span>Large Sections Dependent on an Option

Where large sections of text are dependent on support for an option, a lead-in text block is provided and shaded accordingly; for example:

<sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> This section describes extensions to support interprocess communication. The functionality described in this section shall be provided on implementations that support the XSI option (and the rest of this section is not further marked). <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

------------------------------------------------------------------------

#### <span id="tag_01_08_03"></span>Footnotes

<span id="tag_foot_1"></span>1. The use of the word *must* is deprecated and cannot be used when stating mandatory requirements; *must* is used only to describe unavoidable situations.

<span id="tag_foot_2"></span>2. The use of *will* is deprecated and cannot be used when stating mandatory requirements; *will* is only used in statements of fact.

<span id="tag_foot_3"></span>3. ISO/IEC documents can be obtained from <https://www.iso.org/store.html>.

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
