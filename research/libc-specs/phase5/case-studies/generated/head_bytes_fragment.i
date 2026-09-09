# 0 "head_bytes_fragment.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "head_bytes_fragment.c"





# 1 "include/config.h" 1
# 7 "head_bytes_fragment.c" 2
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 67 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef unsigned long size_t;
# 76 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef signed long ptrdiff_t;
# 98 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef int wchar_t;
# 122 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef long long max_align_t;
# 8 "head_bytes_fragment.c" 2
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stdbool.h" 1
# 9 "head_bytes_fragment.c" 2
# 1 "include/errno.h" 1
# 9 "include/errno.h"
extern int errno;
# 10 "head_bytes_fragment.c" 2
# 1 "safe-read.h" 1
# 30 "safe-read.h"
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 31 "safe-read.h" 2
# 42 "safe-read.h"
extern size_t safe_read (int fd, void *buf, size_t count);
# 11 "head_bytes_fragment.c" 2
# 22 "head_bytes_fragment.c"
typedef unsigned long uintmax_t;




char const *quoteaf (char const *arg);





void error (int status, int errnum, const char *format, const char *arg);
# 42 "head_bytes_fragment.c"
void xwrite_stdout (char const *buffer, size_t n_bytes);

# 1 "head_bytes.frag.c" 1
static _Bool
head_bytes (char const *filename, int fd, uintmax_t bytes_to_write)
{
  char buffer[8192];
  size_t bytes_to_read = 8192;

  while (bytes_to_write)
    {
      size_t bytes_read;
      if (bytes_to_write < bytes_to_read)
        bytes_to_read = bytes_to_write;
      bytes_read = safe_read (fd, buffer, bytes_to_read);
      if (bytes_read == ((size_t) -1))
        {
          error (0, errno, ("error reading %s"), quoteaf (filename));
          return 0;
        }
      if (bytes_read == 0)
        break;
      xwrite_stdout (buffer, bytes_read);
      bytes_to_write -= bytes_read;
    }
  return 1;
}
# 45 "head_bytes_fragment.c" 2






_Bool
head_bytes_entry (char const *filename, int fd, uintmax_t bytes_to_write)
{
  return head_bytes (filename, fd, bytes_to_write);
}
