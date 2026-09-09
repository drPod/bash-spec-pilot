/* Adapter translation unit around the byte-extracted GNU coreutils wc_lines
   fragment (wc_lines.frag.c = wc.c lines 266-330 of commit 9530a144...,
   see PROVENANCE.md). Everything above the final #include is declaration
   context reconstructed from the pinned headers; the fragment itself is not
   edited. Deviations from the original headers are marked ADAPTER DEVIATION.
   This proof targets only the `!long_lines` (short-line) body, as recorded
   in CASE-BRIEF.md's "Honest slice" -- the `long_lines`/rawmemchr arm is
   declared so the fragment compiles unedited but is out of scope. */
#include <config.h>
#include <stddef.h>
#include <stdbool.h>
#include <errno.h>
#include "safe-read.h"    /* wc.c:34 (pinned) */

#define BUFFER_SIZE (16 * 1024)   /* wc.c:47 (pinned) */

/* LP64 stdint.h reconstruction (gnulib/glibc: uintmax_t = unsigned long on
   this target), same convention as head_bytes_fragment.c. */
typedef unsigned long uintmax_t;

/* gnulib quotearg.h (pinned): enumerator order unchanged, comments removed,
   same reconstruction as utility-reuse/src/tu/cat_fragment.c. */
enum quoting_style
  {
    literal_quoting_style,
    shell_quoting_style,
    shell_always_quoting_style,
    shell_escape_quoting_style,
    shell_escape_always_quoting_style,
    c_quoting_style,
    c_maybe_quoting_style,
    escape_quoting_style,
    locale_quoting_style,
    clocale_quoting_style,
    custom_quoting_style
  };
/* gnulib quotearg.h:408 (pinned) */
char *quotearg_n_style_colon (int n, enum quoting_style s, char const *arg);
/* coreutils system.h (pinned, matches utility-reuse's cat_fragment.c) */
#define quotef(arg) \
  quotearg_n_style_colon (0, shell_escape_quoting_style, arg)

/* ADAPTER DEVIATION 1: error() is variadic; VST 2.15 cannot reason about
   variadic calls. wc_lines's only call site is
   error (0, errno, "%s", quotef (file)), fixed arity 4. */
void error (int status, int errnum, const char *format, const char *arg);

/* ADAPTER DEVIATION 2: rawmemchr (glibc/string.h extension) is only reached
   on the `long_lines` arm, which this proof's precondition excludes (see
   CASE-BRIEF.md). Declared only so the fragment compiles unedited; never
   called under the `!long_lines` hypothesis this proof assumes throughout. */
void *rawmemchr (const void *s, int c);

#include "wc_lines.frag.c"

/* ADAPTER DEVIATION 3: wc_lines is `static`; CompCert's frontend drops an
   unreferenced static function (same issue as head_bytes_entry above and
   utility-reuse's simple_cat_entry). This exported one-call wrapper is the
   only reference; the theorem is stated about f_wc_lines itself. */
bool
wc_lines_entry (char const *file, int fd, uintmax_t *lines_out, uintmax_t *bytes_out)
{
  return wc_lines (file, fd, lines_out, bytes_out);
}
