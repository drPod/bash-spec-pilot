# 0 "full_write.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "full_write.c"

# 1 "full-write.c" 1
# 18 "full-write.c"
# 1 "include/config.h" 1
# 19 "full-write.c" 2





# 1 "full-write.h" 1
# 18 "full-write.h"
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 67 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef unsigned long size_t;
# 76 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef signed long ptrdiff_t;
# 98 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef int wchar_t;
# 122 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef long long max_align_t;
# 19 "full-write.h" 2
# 29 "full-write.h"
extern size_t full_write (int fd, const void *buf, size_t count);
# 25 "full-write.c" 2


# 1 "include/errno.h" 1
# 9 "include/errno.h"
extern int errno;
# 28 "full-write.c" 2
# 36 "full-write.c"
# 1 "safe-write.h" 1
# 30 "safe-write.h"
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 31 "safe-write.h" 2






extern size_t safe_write (int fd, const void *buf, size_t count);
# 37 "full-write.c" 2
# 57 "full-write.c"
size_t
full_write (int fd, const void *buf, size_t count)
{
  size_t total = 0;
  const char *ptr = (const char *) buf;

  while (count > 0)
    {
      size_t n_rw = safe_write (fd, ptr, count);
      if (n_rw == (size_t) -1)
        break;
      if (n_rw == 0)
        {
          errno = 28;
          break;
        }
      total += n_rw;
      ptr += n_rw;
      count -= n_rw;
    }

  return total;
}
# 3 "full_write.c" 2
