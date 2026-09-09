/* Adapter translation unit around the byte-extracted GNU coreutils simple_cat
   fragment (simple_cat.frag.c = cat.c lines 152-182 of commit 9530a144…,
   see PROVENANCE.md). Everything above the final #include is declaration
   context reconstructed from the pinned headers; the fragment itself is not
   edited. Deviations from the original headers are marked ADAPTER DEVIATION. */
#include <config.h>
#include <stddef.h>
#include <stdbool.h>
#include <errno.h>
#include <unistd.h>
#include "full-write.h"   /* cat.c:40 */
#include "safe-read.h"    /* cat.c:41 */

/* gnulib idx.h:125 (pinned) */
typedef ptrdiff_t idx_t;

/* gnulib quotearg.h:37-… (pinned): enumerator order unchanged, comments removed. */
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

/* coreutils system.h:813-814 (pinned) */
#define quotef(arg) \
  quotearg_n_style_colon (0, shell_escape_quoting_style, arg)

/* ADAPTER DEVIATION 1: glibc/gnulib error.h declares
     void error (int status, int errnum, const char *format, ...);
   VST 2.15 cannot reason about variadic calls. The fragment has exactly one
   call site, error (0, errno, "%s", quotef (infile)), so the prototype is
   declared with that fixed arity. The fragment's tokens are unchanged. */
void error (int status, int errnum, const char *format, const char *arg);

/* ADAPTER DEVIATION 2: coreutils system.h:767-775 defines
     static inline void write_error (void)
     { int saved_errno = errno; fflush (stdout); fpurge (stdout);
       clearerr (stdout); error (EXIT_FAILURE, saved_errno, _("write error")); }
   which never returns (error with nonzero status exits). It is declared as an
   external function here and given a non-returning funspec instead of
   verifying its stdio-dependent body. */
void write_error (void);

/* cat.c:51-55 (pinned): the two file-scope variables the fragment reads. */
/* Name of input file.  May be "-".  */
static char const *infile;

/* Descriptor on which input file is open.  */
static int input_desc;

#include "simple_cat.frag.c"

/* ADAPTER DEVIATION 3: simple_cat is `static`; with no caller in this
   translation unit CompCert's frontend drops it (run utility-clightgen-1
   produced an AST without f_simple_cat). This exported one-call wrapper is the
   only reference to it. The theorem is stated about f_simple_cat itself. */
bool
simple_cat_entry (char *buf, idx_t bufsize)
{
  return simple_cat (buf, bufsize);
}
