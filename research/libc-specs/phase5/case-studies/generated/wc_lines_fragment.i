# 0 "wc_lines_fragment.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "wc_lines_fragment.c"
# 9 "wc_lines_fragment.c"
# 1 "include/config.h" 1
# 10 "wc_lines_fragment.c" 2
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 67 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef unsigned long size_t;
# 76 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef signed long ptrdiff_t;
# 98 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef int wchar_t;
# 122 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef long long max_align_t;
# 11 "wc_lines_fragment.c" 2
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stdbool.h" 1
# 12 "wc_lines_fragment.c" 2
# 1 "include/errno.h" 1
# 9 "include/errno.h"
extern int errno;
# 13 "wc_lines_fragment.c" 2
# 1 "safe-read.h" 1
# 30 "safe-read.h"
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 31 "safe-read.h" 2
# 42 "safe-read.h"
extern size_t safe_read (int fd, void *buf, size_t count);
# 14 "wc_lines_fragment.c" 2





typedef unsigned long uintmax_t;



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

char *quotearg_n_style_colon (int n, enum quoting_style s, char const *arg);







void error (int status, int errnum, const char *format, const char *arg);





void *rawmemchr (const void *s, int c);

# 1 "wc_lines.frag.c" 1
static _Bool
wc_lines (char const *file, int fd, uintmax_t *lines_out, uintmax_t *bytes_out)
{
  size_t bytes_read;
  uintmax_t lines, bytes;
  char buf[(16 * 1024) + 1];
  _Bool long_lines = 0;

  if (!lines_out || !bytes_out)
    {
      return 0;
    }

  lines = bytes = 0;

  while ((bytes_read = safe_read (fd, buf, (16 * 1024))) > 0)
    {

      if (bytes_read == ((size_t) -1))
        {
          error (0, errno, "%s", quotearg_n_style_colon (0, shell_escape_quoting_style, file));
          return 0;
        }

      bytes += bytes_read;

      char *p = buf;
      char *end = buf + bytes_read;
      uintmax_t plines = lines;

      if (! long_lines)
        {

          while (p != end)
            lines += *p++ == '\n';
        }
      else
        {

          *end = '\n';
          while ((p = rawmemchr (p, '\n')) < end)
            {
              ++p;
              ++lines;
            }
        }







      if (lines - plines <= bytes_read / 15)
        long_lines = 1;
      else
        long_lines = 0;
    }

  *bytes_out = bytes;
  *lines_out = lines;

  return 1;
}
# 55 "wc_lines_fragment.c" 2





_Bool
wc_lines_entry (char const *file, int fd, uintmax_t *lines_out, uintmax_t *bytes_out)
{
  return wc_lines (file, fd, lines_out, bytes_out);
}
