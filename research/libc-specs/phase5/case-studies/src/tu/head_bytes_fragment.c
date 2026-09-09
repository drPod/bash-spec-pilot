/* Adapter translation unit around the byte-extracted GNU coreutils head_bytes
   fragment (head_bytes.frag.c = head.c lines 774-796 of commit 9530a144...,
   see PROVENANCE.md). Everything above the final #include is declaration
   context reconstructed from the pinned headers; the fragment itself is not
   edited. Deviations from the original headers are marked ADAPTER DEVIATION. */
#include <config.h>
#include <stddef.h>
#include <stdbool.h>
#include <errno.h>
#include "safe-read.h"    /* head.c:35 (pinned) */

/* glibc/POSIX <stdio.h> constant (CompCert ships no stdio.h); value fixed for
   the Linux x86-64 target this experiment targets, same as gnulib's use. */
#define BUFSIZ 8192

/* gnulib config.h + gettext.h fallback used when ENABLE_NLS is undefined:
   "#define _(String) (String)". */
#define _(msgid) (msgid)

/* LP64 stdint.h reconstruction (gnulib/glibc: uintmax_t = unsigned long on
   this target), same convention as utility-reuse's idx_t/ssize_t adapters. */
typedef unsigned long uintmax_t;

/* gnulib quote.h (declaration only): returns a quoted copy of arg. Treated as
   pure w.r.t. our footprint, same convention as cat_fragment.c's
   quotearg_n_style_colon. */
char const *quoteaf (char const *arg);

/* ADAPTER DEVIATION 1: error() is variadic in glibc/gnulib error.h; VST 2.15
   cannot reason about variadic calls. head_bytes's only call site is
   error (0, errno, _("error reading %s"), quoteaf (filename)), fixed arity 4
   (same technique as utility-reuse/src/tu/cat_fragment.c ADAPTER DEVIATION 1). */
void error (int status, int errnum, const char *format, const char *arg);

/* ADAPTER DEVIATION 2: xwrite_stdout (head.c:176-189, extracted verbatim to
   xwrite_stdout.frag.c for provenance only) is a buffered-stdio (fwrite)
   helper that either writes every requested byte and returns, or calls
   error (EXIT_FAILURE, ...) and never returns. Its body (fwrite / clearerr /
   fpurge / FILE *) is NOT modeled or verified here -- it is an assumed
   external, the same trust-boundary treatment CatBody.v gave gnulib's
   write_error. See ../coq/CaseSpecs.v's xwrite_stdout_spec and RESULTS.md. */
void xwrite_stdout (char const *buffer, size_t n_bytes);

#include "head_bytes.frag.c"

/* ADAPTER DEVIATION 3: head_bytes is `static`; CompCert's frontend drops an
   unreferenced static function (same issue utility-reuse hit with
   simple_cat, see its ADAPTER DEVIATION 3). This exported one-call wrapper is
   the only reference; the theorem is stated about f_head_bytes itself, not
   about this wrapper. */
bool
head_bytes_entry (char const *filename, int fd, uintmax_t bytes_to_write)
{
  return head_bytes (filename, fd, bytes_to_write);
}
