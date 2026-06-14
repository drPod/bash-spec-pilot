The Open Group Base Specifications Issue 8\
IEEE Std 1003.1-2024\
Copyright © 2001-2024 The IEEE and The Open Group

------------------------------------------------------------------------

<span id="top"></span> <span id="compress"></span> <span id="tag_20_23"></span>

#### <span id="tag_20_23_01"></span>NAME

> compress, uncompress, zcat — compress and decompress data

#### <span id="tag_20_23_02"></span>SYNOPSIS

> <div class="box">
>
> <sup>\[[XSI](javascript:open_code('XSI'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> compress **\[**`-fv`**\] \[**`-b `*value***\] \[**`-g | -m `*algo***\] \[***file*`...`**\]**\
> \
> `compress -c `**\[**`-fv`**\] \[**`-b `*value***\] \[**`-g | -m `*algo***\] \[***file***\]**\
> \
> `compress -d `**\[**`-cfv`**\] \[***file*`...`**\]**\
> \
> `uncompress `**\[**`-cfv`**\] \[***file*`...`**\]**\
> \
> `zcat `**\[***file*`...`**\]**
>
> <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />
>
> </div>
>
> \

#### <span id="tag_20_23_03"></span>DESCRIPTION

> The *compress* utility, when the **-d** option is not specified, shall apply the compression algorithm identified by the **-g** option or the **-m** *algo* option to the named files to attempt to reduce their size without loss of information. The compress utility with the **-d** option shall apply the appropriate decompression algorithm to the named files to restore the data to their original state.
>
> The *uncompress* utility shall be equivalent to *compress* **-d**. The *zcat* utility shall be equivalent to *compress* **-c -d**. If multiple *file* operands are specified, the decompressed data from each input file shall be concatenated to standard output.
>
> When compressing data, unless the **-c** option is specified, after an input file other than standard input has been compressed, the compressed data from the input file shall be stored in a file with the same pathname as the input file but with an added suffix. The added suffix shall be the suffix associated with the algorithm (see the algorithms in [Compression algorithms, algo option-argument values, and suffixes](#tagtcjh_17) ). If appending the suffix would make the size of the last component of the output file's pathname exceed {NAME_MAX} bytes, the command shall fail. If appending the suffix would make the size of the pathname exceed {PATH_MAX} bytes, the command may fail.
>
> When decompressing data, unless the **-c** option is specified, after an input file other than standard input has been decompressed, the decompressed data from the input file shall be stored in a file with the same pathname as the input file but with the suffix associated with the algorithm removed. <sup>\[[OB](javascript:open_code('OB'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" />  If *file* has no suffix associated with a known compression algorithm or *file* does not exist and does not have a **.Z** suffix, *file* shall be used as the name of the output file, and the default suffix **.Z** shall be appended to *file* to form the input pathname. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" /> The behavior is unspecified if the input pathname ends with a suffix other than the suffix associated with the algorithm used to compress the data. When the **-c** option is specified, *file* can have any suffix, or no suffix, and the utility shall use *file* as the input file and examine the file's contents to determine which algorithm to use to decompress the data (it is not an error if *file* does not have a suffix that matches the suffix associated with the compression algorithm).
>
> When compressing or decompressing a file other than standard input and the **-c** option is not specified, if the invoking process has sufficient privilege, the ownership, modes, access time, and modification time of the output file shall match the ownership, modes, access time, and modification time of the input file. After the output file has been successfully created, the input file shall be removed if the invoking process has sufficient privileges. If the invoking process does not have sufficient privileges to remove the input file (for example, if the directory has the S_ISVTX bit set) the behavior depends on whether the **-f** option is specified: if **-f** is not specified, the output file shall be removed, a diagnostic message shall be written and the utility shall continue processing other files but the final exit status shall be non-zero; if **-f** is specified, the output file shall not be removed and it is unspecified whether the inability to remove the input file is treated as an error. If it is not treated as an error, a warning message may be written to standard error
>
> If no *file* operands are specified, standard input shall be compressed or decompressed to standard output.
>
> <sup>\[[OB](javascript:open_code('OB'))\]</sup> <img src="../images/opt-start.gif" data-border="0" alt="[Option Start]" /> If an input file that is to be removed after processing has multiple hard links, the *compress* and *uncompress* utilities may write a diagnostic message to standard error and do nothing with the file; this behavior may depend on whether the **-f** option is specified. If a diagnostic message is written, the final exit status shall be non-zero. <img src="../images/opt-end.gif" data-border="0" alt="[Option End]" />

#### <span id="tag_20_23_04"></span>OPTIONS

> The *compress*, *uncompress*, and *zcat* utilities shall conform to XBD [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02) , except that Guideline 1 does not apply to *uncompress* since the utility name has ten letters.
>
> The following options shall be supported:
>
> **-b ***value*
>
> If the compression algorithm is LZW, *value* specifies the maximum number of bits to use in a code. For a conforming application, the *value* argument shall be:
>
>
>     9 <= value <= 16
>
> The implementation may allow values of greater than 16. The default shall be 14, 15, or 16.
>
> If the compression algorithm is DEFLATE, *value* specifies the compression level. For a conforming application, the *value* argument shall be:
>
>
>     1 <= value <= 9
>
> The default shall be 6.
>
> For other algorithms, value specifies implementation-defined tuning.
>
> **-c**
>
> Write to standard output; the input files shall not be changed, and no output files shall be created.
>
> **-d**
>
> Decompress files. When invoked with the **-d** option, the *compress* utility shall restore previously compressed files to their original state.
>
> **-f**
>
> Force compression or decompression of file, even if it does not (for compression) actually reduce the size of the file, or if the corresponding output file already exists. If the **-f** option is not given and the standard input is a terminal, the user shall be prompted as to whether an existing output file should be overwritten. If the response is affirmative, the existing file shall be overwritten. If the standard input is not a terminal and **-f** is not given, *compress* or *uncompress* shall write a diagnostic message to standard error, the existing file shall not be overwritten, and the utility shall exit with a status greater than zero. If the **-f** option is specified and an input file other than standard input has multiple hard links, it is implementation-defined whether the input file is unlinked after the corresponding output file is successfully written, or if processing of that file is skipped and a diagnostic message is written to standard error.
>
> **-g**
>
> Equivalent to **-m** *gzip*.
>
> **-m** *algo*
>
> Use the algorithm defined by *algo* to compress the files. The following algorithms shall be supported:\
>
> <span id="tagtcjh_17"></span> Table: Compression algorithms, algo option-argument values, and suffixes
>
> **Algorithm**

algo

**Filename Suffix**

Adaptive LZW

**lzw**

**.Z**

RFC1951 DEFLATE

**deflate**

**.gz**

Synonym for DEFLATE

**gzip**

**.gz**

Other implementation-defined algorithms may be supported.

If neither of the **-m** *algo* and **-g** options is specified, **lzw** shall be used as a default *algo* value. Specifying more than one of the mutually exclusive **-g** and **-m** *algo* options, or multiple **-m** *algo* options, shall not be considered an error. The last option specified shall determine the behavior of the utility.

On systems not supporting the selected algorithm, the input files shall not be changed and an exit status greater than two shall be returned.

**Note:**  
The Lempel-Ziv compression algorithm is described in the now-expired US Patent 4464650, which was issued to William Eastman, Abraham Lempel, Jacob Ziv, and Martin Cohn on August 7th, 1984 and assigned to Sperry Corporation.

The Lempel-Ziv-Welch compression algorithm is described in the now-expired US Patent 4558302, which was issued to Terry A. Welch on December 10th, 1985 and assigned to Sperry Corporation.

**-v**

For *compress*, write the percentage reduction of each file to standard error. For *uncompress*, write messages to standard error concerning the expansion of each file.

#### <span id="tag_20_23_05"></span>OPERANDS

> The following operand shall be supported:
>
> *file*
>
> A pathname of a file to be compressed or decompressed. If a *file* is `'-'`, the utility shall read from standard input at that point in the sequence and write to standard output. If more than one *file* operand is `'-'`, the behavior is unspecified.

#### <span id="tag_20_23_06"></span>STDIN

> The standard input shall be used only if no *file* operands are specified, or if a *file* operand is `'-'`.

#### <span id="tag_20_23_07"></span>INPUT FILES

> If *file* operands are specified, the corresponding input files contain the data to be compressed or decompressed.

#### <span id="tag_20_23_08"></span>ENVIRONMENT VARIABLES

> The following environment variables shall affect the execution of *compress*:
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
> Determine the locale for the behavior of ranges, equivalence classes, and multi-character collating elements used in the extended regular expression defined for the **yesexpr** locale keyword in the *LC_MESSAGES* category.
>
> *LC_CTYPE*
>
> Determine the locale for the interpretation of sequences of bytes of text data as characters (for example, single-byte as opposed to multi-byte characters in arguments), the behavior of character classes used in the extended regular expression defined for the **yesexpr** locale keyword in the *LC_MESSAGES* category.
>
> *LC_MESSAGES*
>
> \
> Determine the locale used to process affirmative responses, and the locale used to affect the format and contents of diagnostic messages, prompts, and the output from the **-v** option written to standard error.
>
> *NLSPATH*
>
> Determine the location of messages objects and message catalogs.

#### <span id="tag_20_23_09"></span>ASYNCHRONOUS EVENTS

> Default.

#### <span id="tag_20_23_10"></span>STDOUT

> For the *compress* and *uncompress* utilities, the standard output shall be used if no *file* operands are specified, if a *file* operand is `'-'`, or if the **-c** option is specified. Otherwise, the standard output shall not be used.
>
> The *zcat* utility shall write the decompressed data to the standard output.

#### <span id="tag_20_23_11"></span>STDERR

> The standard error shall be used only for diagnostic and prompt messages, the optional warning message described in DESCRIPTION, and the output from **-v**.

#### <span id="tag_20_23_12"></span>OUTPUT FILES

> When decompressing input files other than standard input, the corresponding output files shall contain the decompressed input data. When compressing input files other than standard input, the corresponding output files shall contain the compressed input data. If the selected *algo* is **deflate** or **gzip**, the compressed output shall be in the GZIP format described in RFC 1952. For other algorithms, the compressed output file format is implementation-defined and interchange of such files between implementations (including access via unspecified file sharing mechanisms) is not required by POSIX.1-2024.

#### <span id="tag_20_23_13"></span>EXTENDED DESCRIPTION

> None.

#### <span id="tag_20_23_14"></span>EXIT STATUS

> The following exit values shall be returned for *compress*:
>
>  0
>
> Successful completion.
>
>  1
>
> An error occurred.
>
>  2
>
> One or more files were not compressed because they would have increased in size (and the **-f** option was not specified).
>
> \>2
>
> An error occurred.
>
> The following exit values shall be returned for *uncompress* and *zcat*:
>
>  0
>
> Successful completion.
>
> \>0
>
> An error occurred.

#### <span id="tag_20_23_15"></span>CONSEQUENCES OF ERRORS

> If an error occurs while compressing or decompressing an input file other than standard input, the input file shall remain unmodified.

------------------------------------------------------------------------

<div class="box">

*The following sections are informative.*

</div>

> 

#### <span id="tag_20_23_16"></span>APPLICATION USAGE

> The amount of compression obtained depends on the size of the input, the number of bits per code, and the distribution of common substrings. Typically, text such as source code or English is reduced by 50-60%. Compression is generally much better than that achieved by Huffman coding or adaptive Huffman coding (*compact*), and takes less time to compute.
>
> Although *compress* strictly follows the default actions upon receipt of a signal or when an error occurs, some unexpected results may occur. In some implementations it is likely that a partially compressed file is left in place, alongside its uncompressed input file. Since the general operation of *compress* is to delete the uncompressed file only after the **.Z** file has been successfully filled, an application should always carefully check the exit status of *compress* before arbitrarily deleting files that have like-named neighbors with **.Z** suffixes.
>
> In addition to trying *file* and *file***.Z** when looking for a file to decompress, some implementations of *uncompress* and *zcat* also try suffixes for other known compression algorithms if neither *file* nor *file***.Z** is found. This version of the standard allows, but does not require this behavior. Portable applications should always specify the full pathname (including the suffix) of files to be decompressed.

#### <span id="tag_20_23_17"></span>EXAMPLES

> None.

#### <span id="tag_20_23_18"></span>RATIONALE

> Earlier versions of this standard limited the number of bits used by conforming applications for the **lzw** algorithm to 14 due to address space limitations on 16-bit architectures. Using 15 or 16 is a much more common default when using current hardware.
>
> Earlier versions of this standard only supported LZW compression. The standard developers noted that existing implementations added other compression utilities, such as *gzip*, and found it desirable to support this widespread usage. Some implementations had extended the *compress* utility to support such other schemes. The standard developers generalized this practice by the addition of the **-m** option, even though this was not previous practice.
>
> The *uncompress* **-d** option is added to match undocumented existing practice of tested implementations.

#### <span id="tag_20_23_19"></span>FUTURE DIRECTIONS

> If this utility is directed to create a new directory entry that contains any bytes that have the encoded value of a \<newline\> character, implementations are encouraged to treat this as an error. A future version of this standard may require implementations to treat this as an error.
>
> When decompressing a file, the requirement to add **.Z** to a *file* operand if the given pathname does not include a suffix associated with a known compression algorithm or if *file* does not exist and does not already have a **.Z** extension is an obsolescent feature and may be removed in a future version.

#### <span id="tag_20_23_20"></span>SEE ALSO

> XBD [*8. Environment Variables*](../basedefs/V1_chap08.html#tag_08) , [*12.2 Utility Syntax Guidelines*](../basedefs/V1_chap12.html#tag_12_02)

#### <span id="tag_20_23_21"></span>CHANGE HISTORY

> First released in Issue 4.

#### <span id="tag_20_23_22"></span>Issue 6

> The normative text is reworded to avoid use of the term "must" for application requirements.
>
> An error case is added for systems not supporting adaptive Lempel-Ziv coding.

#### <span id="tag_20_23_23"></span>Issue 7

> SD5-XCU-ERN-97 is applied, updating the SYNOPSIS.
>
> Austin Group Interpretation 1003.1-2001 \#125 is applied, revising the ENVIRONMENT VARIABLES section.

#### <span id="tag_20_23_24"></span>Issue 8

> Austin Group Defect 251 is applied, encouraging implementations to disallow the creation of filenames containing any bytes that have the encoded value of a \<newline\> character.
>
> Austin Group Defect 1041 is applied, combining the *compress*, *uncompress* and *zcat* pages into one and extensively modifying most sections.
>
> Austin Group Defect 1122 is applied, changing the description of *NLSPATH .*

<div class="box">

*End of informative text.*

</div>

------------------------------------------------------------------------

> 

 

[<span class="topOfPage">return to top of page</span>](#top)\

------------------------------------------------------------------------

UNIX® is a registered Trademark of The Open Group.\
POSIX™ is a Trademark of The IEEE.\
Copyright © 2001-2024 The IEEE and The Open Group, All Rights Reserved\
\[ [Main Index](../mindex.html) \| [XBD](../basedefs/contents.html) \| [XSH](../functions/contents.html) \| [XCU](../utilities/contents.html) \| [XRAT](../xrat/contents.html) \]

------------------------------------------------------------------------
