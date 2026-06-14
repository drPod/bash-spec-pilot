The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="cal"></span> <span id="tag_20_12"></span>

#### <span id="tag_20_12_01"></span>NAME

> cal — print a calendar

#### <span id="tag_20_12_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` cal`` `**`[[`***`month`***`]`**` `*`year`***`]`**` `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>

#### <span id="tag_20_12_03"></span>DESCRIPTION

> The *cal* utility shall write a calendar to standard output using the Julian calendar for dates from January 1, 1 through September 2, 1752 and the Gregorian calendar for dates from September 14, 1752 through December 31, 9999 as though the Gregorian calendar had been adopted on September 14, 1752.
>
> If no operands are given, *cal* shall produce a one-month calendar for the current month in the current year. If only the *year* operand is given, *cal* shall produce a calendar for all twelve months in the given calendar year. If both *month* and *year* operands are given, *cal* shall produce a one-month calendar for the given month in the given year.

#### <span id="tag_20_12_04"></span>OPTIONS

> None.

#### <span id="tag_20_12_05"></span>OPERANDS

> The following operands shall be supported:
>
> *month*
>
> Specify the month to be displayed, represented as a decimal integer from 1 (January) to 12 (December).
>
> *year*
>
> Specify the year for which the calendar is displayed, represented as a decimal integer from 1 to 9999.

#### <span id="tag_20_12_06"></span>STDIN

> Not used.

#### <span id="tag_20_12_07"></span>INPUT FILES

> None.

#### <span id="tag_20_12_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *cal*:
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
> Determine the locale that should be used to affect the format and contents of diagnostic messages written to standard error, and informative messages written to standard output.
>
> *LC_TIME*
>
> Determine the format and contents of the calendar.
>
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.
>
> *TZ*
>
> Determine the timezone used to calculate the value of the current month.

#### <span id="tag_20_12_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_12_10"></span>STDOUT

> The standard output shall be used to display the calendar, in an unspecified format.

#### <span id="tag_20_12_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_12_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_12_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_12_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_12_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_12_16"></span>APPLICATION USAGE

> Note that:
>
>
>     cal 83
>
> refers to A.D. 83, not 1983.

#### <span id="tag_20_12_17"></span>EXAMPLES

> None.

#### <span id="tag_20_12_18"></span>RATIONALE

> Earlier versions of this standard incorrectly required that the command:
>
>
>     cal 2000
>
> write a one-month calendar for the current calendar month (no matter what the current year is) in the year 2000 to standard output. This did not match historic practice in any known version of the *cal* utility. The description has been updated to match historic practice. When only the *year* operand is given, *cal* writes a twelve-month calendar for the specified year.

#### <span id="tag_20_12_19"></span>FUTURE DIRECTIONS

> A future version of this standard may support locale-specific recognition of the date of adoption of the Gregorian calendar.

#### <span id="tag_20_12_20"></span>SEE ALSO

> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08)

#### <span id="tag_20_12_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_12_22"></span>Issue 6

> The DESCRIPTION is updated to allow for traditional behavior for years before the adoption of the Gregorian calendar.

#### <span id="tag_20_12_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> POSIX.1-2008, Technical Corrigendum 1, XCU/TC1-2008/0074 \[56\] and XCU/TC1-2008/0075 \[56\] are applied.

#### <span id="tag_20_12_24"></span>Issue 8

> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*

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
