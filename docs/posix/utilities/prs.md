The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="prs"></span> <span id="tag_20_97"></span>

#### <span id="tag_20_97_01"></span>NAME

> prs — print an SCCS file (**DEVELOPMENT**)

#### <span id="tag_20_97_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>`[`[`XSI`](javascript:open_code('XSI'))`]`</sup>` `<img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />` prs`` `**`[`**`-a`**`] [`**`-d`` `*`dataspec`***`] [`**`-r`**`[`***`SID`***`]]`**` `*`file`*`...`\
> \
> `prs`` `**`[`**`-e|-l`**`]`**` ``-c`` `*`cutoff`*` `**`[`**`-d`` `*`dataspec`***`]`**` `*`file`*`...`\
> \
> `prs`` `**`[`**`-e|-l`**`]`**` ``-r`**`[`***`SID`***`] [`**`-d`` `*`dataspec`***`]`**` `*`file`*`... `<img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_97_03"></span>DESCRIPTION

> The *prs* utility shall write to standard output parts or all of an SCCS file in a user-supplied format.

#### <span id="tag_20_97_04"></span>OPTIONS

> The *prs* utility shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02), except that the **-r** option has an optional option-argument. This optional option-argument cannot be presented as a separate argument. The following options shall be supported:
>
> **-d ***dataspec*
>
> Specify the output data specification. The *dataspec* shall be a string consisting of SCCS file *data* *keywords* (see [Data Keywords](#tag_20_97_10_01)) interspersed with optional user-supplied text.
>
> **-r\[***SID***\]**
>
> Specify the SCCS identification string (SID) of a delta for which information is desired. If no *SID* option-argument is specified, the SID of the most recently created delta shall be assumed.
>
> **-e**
>
> Request information for all deltas created earlier than and including the delta designated via the **-r** option or the date-time given by the **-c** option.
>
> **-l**
>
> Request information for all deltas created later than and including the delta designated via the **-r** option or the date-time given by the **-c** option.
>
> **-c ***cutoff*
>
> Indicate the *cutoff* date-time, in the form:
>
>
>     YY[MM[DD[HH[MM[SS]]]]]
>
> For the *YY* component, values in the range \[69,99\] shall refer to years 1969 to 1999 inclusive, and values in the range \[00,68\] shall refer to years 2000 to 2068 inclusive.
>
> **Note:**  
> It is expected that in a future version of this standard the default century inferred from a 2-digit year will change. (This would apply to all commands accepting a 2-digit year as input.)
>
> No changes (deltas) to the SCCS file that were created after the specified *cutoff* date-time shall be included in the output. Units omitted from the date-time default to their maximum possible values; for example, **-c 7502** is equivalent to **-c 750228235959**.
>
> **-a**
>
> Request writing of information for both removed—that is, [*delta*](../utilities/delta.html) *type*=*R* (see [*rmdel*](../utilities/rmdel.html#))—and existing—that is, [*delta*](../utilities/delta.html) *type*=*D*,—deltas. If the **-a** option is not specified, information for existing deltas only shall be provided.

#### <span id="tag_20_97_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of an existing SCCS file or a directory. If *file* is a directory, the *prs* utility shall behave as though each file in the directory were specified as a named file, except that non-SCCS files (last component of the pathname does not begin with **s.**) and unreadable files shall be silently ignored.
>
> If exactly one *file* operand appears, and it is `'-'`, the standard input shall be read; each line of the standard input shall be taken to be the name of an SCCS file to be processed. Non-SCCS files and unreadable files shall be silently ignored.

#### <span id="tag_20_97_06"></span>STDIN

> The standard input shall be a text file used only when the *file* operand is specified as `'-'`. Each line of the text file shall be interpreted as an SCCS pathname.

#### <span id="tag_20_97_07"></span>INPUT FILES

> Any SCCS files displayed are files of an unspecified format.

#### <span id="tag_20_97_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *prs*:
>
> *LANG*
>
> Provide a default value for the internationalization variables that are unset or null. (See XBD [*8.2 Internationalization Variables*](../basedefs/V1_chap08.html#tag_08_02) the precedence of internationalization variables used to determine the values of locale categories.)
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
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_97_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_97_10"></span>STDOUT

> The standard output shall be a text file whose format is dependent on the data keywords specified with the **-d** option.
>
> ##### <span id="tag_20_97_10_01"></span>Data Keywords
>
> Data keywords specify which parts of an SCCS file shall be retrieved and output. All parts of an SCCS file have an associated data keyword. A data keyword may appear in a *dataspec* multiple times.
>
> The information written by *prs* shall consist of:
>
> 1.  The user-supplied text
>
> 2.  Appropriate values (extracted from the SCCS file) substituted for the recognized data keywords in the order of appearance in the *dataspec*
>
> The format of a data keyword value shall either be simple (`'S'`), in which keyword substitution is direct, or multi-line (`'M'`).
>
> User-supplied text shall be any text other than recognized data keywords. A \<tab\> shall be specified by `'\t'` and \<newline\> by `'\n'`. When the **-r** option is not specified, the default *dataspec* shall be:
>
>
>     :PN::\n\n
>
> and the following *dataspec* shall be used for each selected delta:
>
>
>     :Dt:\t:DL:\nMRs:\n:MR:COMMENTS:\n:C:
>
> <table data-border="1" data-cellpadding="3" data-align="center">
> <thead>
> <tr data-valign="top">
> <th colspan="5" style="text-align: center;"><p><strong>SCCS File Data Keywords</strong></p></th>
> </tr>
> </thead>
> <tbody>
> <tr data-valign="top">
> <th style="text-align: center;"><p><strong>Keyword</strong></p></th>
> <th style="text-align: center;"><p><strong>Data Item</strong></p></th>
> <th style="text-align: center;"><p><strong>File Section</strong></p></th>
> <th style="text-align: center;"><p><strong>Value</strong></p></th>
> <th style="text-align: center;"><p><strong>Format</strong></p></th>
> </tr>
> &#10;<tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Dt:</strong></p></td>
> <td style="text-align: left;"><p>Delta information</p></td>
> <td style="text-align: center;"><p>Delta Table</p></td>
> <td style="text-align: left;"><p><strong>See below*</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:DL:</strong></p></td>
> <td style="text-align: left;"><p>Delta line statistics</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:Li:/:Ld:/:Lu:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Li:</strong></p></td>
> <td style="text-align: left;"><p>Lines inserted by Delta</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnnn</em>***</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Ld:</strong></p></td>
> <td style="text-align: left;"><p>Lines deleted by Delta</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnnn</em>***</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Lu:</strong></p></td>
> <td style="text-align: left;"><p>Lines unchanged by Delta</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnnn</em>***</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:DT:</strong></p></td>
> <td style="text-align: left;"><p>Delta type</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>D or R</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:I:</strong></p></td>
> <td style="text-align: left;"><p>SCCS ID string (SID)</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>See below**</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:R:</strong></p></td>
> <td style="text-align: left;"><p>Release number</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:L:</strong></p></td>
> <td style="text-align: left;"><p>Level number</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:B:</strong></p></td>
> <td style="text-align: left;"><p>Branch number</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:S:</strong></p></td>
> <td style="text-align: left;"><p>Sequence number</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:D:</strong></p></td>
> <td style="text-align: left;"><p>Date delta created</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:Dy:/:Dm:/:Dd:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Dy:</strong></p></td>
> <td style="text-align: left;"><p>Year delta created</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Dm:</strong></p></td>
> <td style="text-align: left;"><p>Month delta created</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Dd:</strong></p></td>
> <td style="text-align: left;"><p>Day delta created</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:T:</strong></p></td>
> <td style="text-align: left;"><p>Time delta created</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:Th:::Tm:::Ts:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Th:</strong></p></td>
> <td style="text-align: left;"><p>Hour delta created</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Tm:</strong></p></td>
> <td style="text-align: left;"><p>Minutes delta created</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Ts:</strong></p></td>
> <td style="text-align: left;"><p>Seconds delta created</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:P:</strong></p></td>
> <td style="text-align: left;"><p>Programmer who created Delta</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>logname</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:DS:</strong></p></td>
> <td style="text-align: left;"><p>Delta sequence number</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:DP:</strong></p></td>
> <td style="text-align: left;"><p>Predecessor Delta sequence number</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>nnnn</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:DI:</strong></p></td>
> <td style="text-align: left;"><p>Sequence number of deltas included, excluded, or ignored</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:Dn:/:Dx:/:Dg:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Dn:</strong></p></td>
> <td style="text-align: left;"><p>Deltas included (sequence #)</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:DS: :DS: ...</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Dx:</strong></p></td>
> <td style="text-align: left;"><p>Deltas excluded (sequence #)</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:DS: :DS: ...</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Dg:</strong></p></td>
> <td style="text-align: left;"><p>Deltas ignored (sequence #)</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:DS: :DS: ...</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:MR:</strong></p></td>
> <td style="text-align: left;"><p>MR numbers for delta</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>M</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:C:</strong></p></td>
> <td style="text-align: left;"><p>Comments for delta</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>M</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:UN:</strong></p></td>
> <td style="text-align: left;"><p>User names</p></td>
> <td style="text-align: center;"><p>User Names</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>M</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:FL:</strong></p></td>
> <td style="text-align: left;"><p>Flag list</p></td>
> <td style="text-align: center;"><p>Flags</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>M</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Y:</strong></p></td>
> <td style="text-align: left;"><p>Module type flag</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:MF:</strong></p></td>
> <td style="text-align: left;"><p>MR validation flag</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>yes or no</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:MP:</strong></p></td>
> <td style="text-align: left;"><p>MR validation program name</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:KF:</strong></p></td>
> <td style="text-align: left;"><p>Keyword error, warning flag</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>yes or no</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:BF:</strong></p></td>
> <td style="text-align: left;"><p>Branch flag</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>yes or no</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:J:</strong></p></td>
> <td style="text-align: left;"><p>Joint edit flag</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>yes or no</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:LK:</strong></p></td>
> <td style="text-align: left;"><p>Locked releases</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:R: ...</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Q:</strong></p></td>
> <td style="text-align: left;"><p>User-defined keyword</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:M:</strong></p></td>
> <td style="text-align: left;"><p>Module name</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:FB:</strong></p></td>
> <td style="text-align: left;"><p>Floor boundary</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:R:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:CB:</strong></p></td>
> <td style="text-align: left;"><p>Ceiling boundary</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:R:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Ds:</strong></p></td>
> <td style="text-align: left;"><p>Default SID</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>:I:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:ND:</strong></p></td>
> <td style="text-align: left;"><p>Null delta flag</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong>yes or no</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:FD:</strong></p></td>
> <td style="text-align: left;"><p>File descriptive text</p></td>
> <td style="text-align: center;"><p>Comments</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>M</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:BD:</strong></p></td>
> <td style="text-align: left;"><p>Body</p></td>
> <td style="text-align: center;"><p>Body</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>M</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:GB:</strong></p></td>
> <td style="text-align: left;"><p>Gotten body</p></td>
> <td style="text-align: center;"><p>"</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>M</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:W:</strong></p></td>
> <td style="text-align: left;"><p>A form of <em>what</em> string</p></td>
> <td style="text-align: center;"><p>N/A</p></td>
> <td style="text-align: left;"><p><strong>:Z::M:\t:I:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:A:</strong></p></td>
> <td style="text-align: left;"><p>A form of <em>what</em> string</p></td>
> <td style="text-align: center;"><p>N/A</p></td>
> <td style="text-align: left;"><p><strong>:Z::Y: :M: :I::Z:</strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:Z:</strong></p></td>
> <td style="text-align: left;"><p><em>what</em> string delimiter</p></td>
> <td style="text-align: center;"><p>N/A</p></td>
> <td style="text-align: left;"><p><strong><code>@(#)</code></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:F:</strong></p></td>
> <td style="text-align: left;"><p>SCCS filename</p></td>
> <td style="text-align: center;"><p>N/A</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> <tr data-valign="top">
> <td style="text-align: left;"><p><strong>:PN:</strong></p></td>
> <td style="text-align: left;"><p>SCCS file pathname</p></td>
> <td style="text-align: center;"><p>N/A</p></td>
> <td style="text-align: left;"><p><strong><em>text</em></strong></p></td>
> <td style="text-align: center;"><p>S</p></td>
> </tr>
> </tbody>
> </table>
>
> \*
>
> **:Dt:**=**:DT: :I: :D: :T: :P: :DS: :DP:**
>
> \*\*
>
> **:R:.:L:.:B:.:S:** if the delta is a branch delta (**:BF:**==**yes**)\
> **:R:.:L:** if the delta is not a branch delta (**:BF:**==**no**)
>
> \*\*\*
>
> The line statistics are capped at 99999. For example, if 100000 lines were unchanged in a certain revision, **:Lu:** shall produce the value 99999.

#### <span id="tag_20_97_11"></span>STDERR

> The standard error shall be used only for diagnostic messages.

#### <span id="tag_20_97_12"></span>OUTPUT FILES

> None.

#### <span id="tag_20_97_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_97_14"></span>EXIT STATUS

> The following exit values shall be returned:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_97_15"></span>CONSEQUENCES OF ERRORS

> Default.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

#### <span id="tag_20_97_16"></span>APPLICATION USAGE

> None.

#### <span id="tag_20_97_17"></span>EXAMPLES

> 1.  The following example:
>
>
>         prs -d "User Names for :F: are:\n:UN:" s.file
>
>     might write to standard output:
>
>
>         User Names for s.file are:
>         xyz
>         131
>         abc
>
> 2.  The following example:
>
>
>         prs -d "Delta for pgm :M:: :I: - :D: By :P:" -r s.file
>
>     might write to standard output:
>
>
>         Delta for pgm main.c: 3.7 - 77/12/01 By cas
>
> 3.  As a special case:
>
>
>         prs s.file
>
>     might write to standard output:
>
>
>         s.file:
>         <blank line>
>         D 1.1 77/12/01 00:00:00 cas 1 000000/00000/00000
>         MRs:
>         bl78-12345
>         bl79-54321
>         COMMENTS:
>         this is the comment line for s.file initial delta
>         <blank line>
>
>     for each delta table entry of the **D** type. The only option allowed to be used with this special case is the **-a** option.

#### <span id="tag_20_97_18"></span>RATIONALE

> None.

#### <span id="tag_20_97_19"></span>FUTURE DIRECTIONS

> If this utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.

#### <span id="tag_20_97_20"></span>SEE ALSO

> [*admin*](../utilities/admin.html#), [*delta*](../utilities/delta.html#), [*get*](../utilities/get.html#), [*what*](../utilities/what.html#)
>
> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08), [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_97_21"></span>CHANGE HISTORY

> First released in Issue 2.

#### <span id="tag_20_97_22"></span>Issue 5

> The phrase "in which keyword substitution is followed by a \<newline\>" is deleted from the end of the second paragraph of [Data Keywords](#tag_20_97_10_01).
>
> The interpretation of the *YY* component of the **-c** *cutoff* argument is noted.

#### <span id="tag_20_97_23"></span>Issue 6

> The normative text is reworded to emphasize the term "shall" for implementation requirements.
>
> The Open Group Base Resolution bwg2001-007 is applied, updating the table in STDOUT with a note that line statistics are capped at 99999 for the **:Li:**, **:Ld:**, **:Lu:**, and **:DL:** keywords.
>
> The Open Group Interpretation PIN4C.00009 is applied.

#### <span id="tag_20_97_24"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.

#### <span id="tag_20_97_25"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to report an error if a utility is directed to display a pathname that contains any bytes that have the encoded value of a \<newline\> character when \<newline\> is a terminator or separator in the output format being used.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*
>
> Austin Group Defect 1452 is applied, deleting **:KV:** from the list of keywords.
>
> Austin Group Defect 1570 is applied, removing extra spacing in `"=="`.

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
