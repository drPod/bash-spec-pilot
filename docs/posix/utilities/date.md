The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="date"></span> <span id="tag_20_30"></span>

#### <span id="tag_20_30_01"></span>NAME

> date — write the date and time

#### <span id="tag_20_30_02"></span>SYNOPSIS

> `date`` `**`[`**`-u`**`] [`**`+`*`format`***`]`**\
> \
>
> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` date`` `**`[`**`-u`**`]`**` `*`mmddhhmm`***`[[`***`cc`***`]`***`yy`***`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_30_03"></span>DESCRIPTION

> The *date* utility shall write the date and time to standard output <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  or attempt to set the system date and time. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> By default, the current date and time shall be written. If an operand beginning with `'+'` is specified, the output format of *date* shall be controlled by the conversion specifications and other text in the operand.

#### <span id="tag_20_30_04"></span>OPTIONS

> The *date* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02).
>
> The following option shall be supported:
>
> **-u**
>
> Perform operations as if the *TZ* environment variable was set to the string `"UTC0"`, or its equivalent historical value of `"GMT0"`. Otherwise, *date* shall use the timezone indicated by the *TZ* environment variable or the system default if that variable is unset or null.

#### <span id="tag_20_30_05"></span>OPERANDS

> The following operands shall be supported:
>
> \+*format*
>
> When the format is specified, the output shall be formatted as if by [*strftime*()](../functions/strftime.html) with the specified format string, and a *timeptr* argument that is the equivalent of *localtime*(&*now*) if **-u** is not specified or *gmtime*(&*now*) if **-u** is specified, where *now* is an object of type **time_t** containing the return value of *time*(0).
>
> A \<newline\> shall always be appended to the output of [*strftime*()](../functions/strftime.html).
>
> *mmddhhmm***\[\[***cc***\]***yy***\]**
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />\
> Attempt to set the system date and time from the value given in the operand. This is only possible if the user has appropriate privileges and the system permits the setting of the system date and time. The first *mm* is the month (number); *dd* is the day (number); *hh* is the hour (number, 24-hour system); the second *mm* is the minute (number); *cc* is the century and is the first two digits of the year (this is optional); *yy* is the last two digits of the year and is optional. If century is not specified, then values in the range \[69,99\] shall refer to years 1969 to 1999 inclusive, and values in the range \[00,68\] shall refer to years 2000 to 2068 inclusive. The current year is the default if *yy* is omitted. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> **Note:**  
> It is expected that in a future version of this standard the default century inferred from a 2-digit year will change. (This would apply to all commands accepting a 2-digit year as input.)

#### <span id="tag_20_30_06"></span>STDIN

> Not used.

#### <span id="tag_20_30_07"></span>INPUT FILES

> None.

#### <span id="tag_20_30_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *date*:
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
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments).
>
> *LC_MESSAGES*
>
> \
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error.
>
> *LC_TIME*
>
> Determine the format and contents of date and time strings written by *date*.
>
> *NLSPATH*
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> Determine the location of messages objects and message catalogs. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> *TZ*
>
> Determine the timezone in which the time and date are written, unless the **-u** option is specified. If the *TZ* variable is unset or null and **-u** is not specified, an unspecified system default timezone is used.

#### <span id="tag_20_30_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_30_10"></span>STDOUT

> When no formatting operand is specified, the output in the POSIX locale shall be equivalent to specifying:
>
>
>     date "+%a %b %e %H:%M:%S %Z %Y"

#### <span id="tag_20_30_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_30_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_30_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_30_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> The date was written successfully.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_30_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_30_16"></span>APPLICATION USAGE

> Conversion specifiers are of unspecified format when not in the POSIX locale. Some of them can contain \<newline\> characters in some locales, so it may be difficult to use the format shown in standard output for parsing the output of *date* in those locales.
>
> Since the default *date* utility format for locales other than the POSIX or C locale is not required to include anything beyond the date and time, whereas for the POSIX or C locale it also includes the day name and time zone, it may be necessary to specify a format (or override the locale-selection environment variables) to ensure this information is included when desired.
>
> The range of values for `%S` extends from 0 to 60 seconds to accommodate the occasional leap second.
>
> Although certain of the conversion specifiers in the POSIX locale (such as the name of the month) are shown with initial capital letters, this need not be the case in other locales. Programs using these fields may need to adjust the capitalization if the output is going to be used at the beginning of a sentence.
>
> The date string formatting capabilities are intended for use in Gregorian-style calendars, possibly with a different starting year (or years). The `%x` and `%c` conversion specifications, however, are intended for local representation; these may be based on a different, non-Gregorian calendar.
>
> The `%C` conversion specification was introduced to allow a fallback for the `%EC` (alternative year format base year); it can be viewed as the base of the current subdivision in the Gregorian calendar. The century number is calculated as the year divided by 100 and truncated to an integer; it should not be confused with the use of ordinal numbers for centuries (for example, "twenty-first century".) Both the `%Ey` and `%y` can then be viewed as the offset from `%EC` and `%C`, respectively.
>
> The `E` and `O` modifiers modify the traditional conversion specifiers, so that they can always be used, even if the implementation (or the current locale) does not support the modifier.
>
> The `E` modifier supports alternative date formats, such as the Japanese Emperor's Era, as long as these are based on the Gregorian calendar system. Extending the `E` modifiers to other date elements may provide an implementation-defined extension capable of supporting other calendar systems, especially in combination with the `O` modifier.
>
> The `O` modifier supports time and date formats using the locale's alternative numerical symbols, such as Kanji or Hindi digits or ordinal number representation.
>
> Non-European locales, whether they use Latin digits in computational items or not, often have local forms of the digits for use in date formats. This is not totally unknown even in Europe; a variant of dates uses Roman numerals for the months: the third day of September 1991 would be written as 3.IX.1991. In Japan, Kanji digits are regularly used for dates; in Arabic-speaking countries, Hindi digits are used. The `%d`, `%e`, `%H`, `%I`, `%m`, `%S`, `%U`, `%w`, `%W`, and `%y` conversion specifications always return the date and time field in Latin digits (that is, 0 to 9). The `%O` modifier was introduced to support the use for display purposes of non-Latin digits. In the *LC_TIME* category in [*localedef*](../utilities/localedef.html), the optional **alt_digits** keyword is intended for this purpose. As an example, assume the following (partial) [*localedef*](../utilities/localedef.html) source:
>
>
>     alt_digits  "";"I";"II";"III";"IV";"V";"VI";"VII";"VIII" \
>                 "IX";"X";"XI";"XII"
>     d_fmt       "%e.%Om.%Y"
>
> With the above date, the command:
>
>
>     date "+%x"
>
> would yield 3.IX.1991. With the same **d_fmt**, but without the **alt_digits**, the command would yield 3.9.1991.

#### <span id="tag_20_30_17"></span>EXAMPLES

> 1.  The following are input/output examples of *date* used at arbitrary times in the POSIX locale:
>
>
>         $ date
>         Tue Jun 26 09:58:10 PDT 1990
>
>
>         $ date "+DATE: %m/%d/%y%nTIME: %H:%M:%S"
>         DATE: 11/02/91
>         TIME: 13:36:16
>
>
>         $ date "+TIME: %r"
>         TIME: 01:36:32 PM
>
> 2.  Examples for Denmark, where the default date and time format is `%a` `%d` `%b` `%Y` `%T` `%Z`:
>
>
>         $ LANG=da_DK.iso_8859-1 date
>         ons 02 okt 1991 15:03:32 CET
>
>
>         $ LANG=da_DK.iso_8859-1 \
>             date "+DATO: %A den %e. %B %Y%nKLOKKEN: %H:%M:%S"
>         DATO: onsdag den 2. oktober 1991
>         KLOKKEN: 15:03:56
>
> 3.  Examples for Germany, where the default date and time format is `%a` `%d`.`%h`.`%Y`, `%T` `%Z`:
>
>
>         $ LANG=De_DE.88591 date
>         Mi 02.Okt.1991, 15:01:21 MEZ
>
>
>         $ LANG=De_DE.88591 date "+DATUM: %A, %d. %B %Y%nZEIT: %H:%M:%S"
>         DATUM: Mittwoch, 02. Oktober 1991
>         ZEIT: 15:02:02
>
> 4.  Examples for France, where the default date and time format is `%a` `%d` `%h` `%Y` `%Z` `%T`:
>
>
>         $ LANG=Fr_FR.88591 date
>         Mer 02 oct 1991 MET 15:03:32
>
>
>         $ LANG=Fr_FR.88591 date "+JOUR: %A %d %B %Y%nHEURE: %H:%M:%S"
>         JOUR: Mercredi 02 octobre 1991
>         HEURE: 15:03:56

#### <span id="tag_20_30_18"></span>RATIONALE

> Some of the new options for formatting are from the ISO C standard. The **-u** option was introduced to allow portable access to Coordinated Universal Time (UTC). The string `"GMT0"` is allowed as an equivalent *TZ* value to be compatible with all of the systems using the BSD implementation, where this option originated.
>
> The `%e` format conversion specification (adopted from System V) was added because the ISO C standard conversion specifications did not provide any way to produce the historical default *date* output during the first nine days of any month.
>
> There are two varieties of day and week numbering supported (in addition to any others created with the locale-dependent `%E` and `%O` modifier characters):
>
> - The historical variety in which Sunday is the first day of the week and the weekdays preceding the first Sunday of the year are considered week 0. These are represented by `%w` and `%U`. A variant of this is `%W`, using Monday as the first day of the week, but still referring to week 0. This view of the calendar was retained because so many historical applications depend on it and the ISO C standard [*strftime*()](../functions/strftime.html) function, on which many *date* implementations are based, was defined in this way.
>
> - The international standard, based on the ISO 8601:2019 standard where Monday is the first weekday and the algorithm for the first week number is more complex: If the week (Monday to Sunday) containing January 1 has four or more days in the new year, then it is week 1; otherwise, it is week 53 of the previous year, and the next week is week 1. These are represented by the new conversion specifications `%u` and `%V`, added as a result of international comments.
>
> Although this standard only requires the default *date* utility format, for locales other than the POSIX or C locale, to include the date and time, it is common for implementations to include day name and time zone information as well. (For the POSIX locale this is required, with the day name in `%a` format at the beginning and the time zone in `%Z` format before the year.) Implementations are encouraged to include the day name (in `%a` or `%A` format) and the time zone (in `%Z` or `%z` format) in the default *date* utility format for all of the locales they provide.
>
> Some implementations have a **date_fmt** locale keyword (see [*7.3.5 LC_TIME*](../basedefs/V1_chap07.html#tag_07_03_05)) as an extension, to specify the default *date* utility format for each locale. On such implementations, if the [*localedef*](../utilities/localedef.html) utility is used to create a locale that does not have this information, the *date* utility must by default still produce output for that locale that includes both the time and the date.

#### <span id="tag_20_30_19"></span>FUTURE DIRECTIONS

> None.

#### <span id="tag_20_30_20"></span>SEE ALSO

> XBD [*7.3.5 LC_TIME*](../basedefs/V1_chap07.html#tag_07_03_05), [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)
>
> XSH [*fprintf*()](../functions/fprintf.html#), [*strftime*()](../functions/strftime.html#)

#### <span id="tag_20_30_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_30_22"></span>Issue 5

> Changes are made for Year 2000 alignment.

#### <span id="tag_20_30_23"></span>Issue 6

> The following new requirements on POSIX implementations derive from alignment with the Single UNIX Specification:
>
> - The `%EX` modified conversion specification is added.
>
> The Open Group Corrigendum U048/2 is applied, correcting the examples.
>
> The DESCRIPTION is updated to refer to conversion specifications, instead of field descriptors for consistency with the *LC_TIME* category.
>
> A clarification is made such that the current year is the default if the *yy* argument is omitted when setting the system date and time.
>
> IEEE Std 1003.1-2001/Cor 1-2002, item XCU/TC1/D6/19 is applied, correcting the CHANGE HISTORY section.

#### <span id="tag_20_30_24"></span>Issue 8

> Austin Group Defect 466 is applied, replacing the list of conversion specifications for the +*format* operand with a requirement that the output is formatted as if by a call to [*strftime*()](../functions/strftime.html) with specific arguments.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1345 is applied, adding paragraphs to APPLICATION USAGE and RATIONALE about the default *date* utility format.

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
