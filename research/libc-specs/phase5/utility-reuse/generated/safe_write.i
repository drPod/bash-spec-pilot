# 0 "safe_write.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "safe_write.c"


# 1 "safe-write.c" 1
# 18 "safe-write.c"
# 1 "safe-read.c" 1
# 19 "safe-read.c"
# 1 "include/config.h" 1
# 20 "safe-read.c" 2



# 1 "safe-write.h" 1
# 30 "safe-write.h"
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 67 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef unsigned long size_t;
# 76 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef signed long ptrdiff_t;
# 98 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef int wchar_t;
# 122 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef long long max_align_t;
# 31 "safe-write.h" 2






extern size_t safe_write (int fd, const void *buf, size_t count);
# 24 "safe-read.c" 2





# 1 "include/sys/types.h" 1




# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 6 "include/sys/types.h" 2


typedef signed long ssize_t;
# 30 "safe-read.c" 2
# 1 "include/unistd.h" 1







# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 9 "include/unistd.h" 2

ssize_t read(int fd, void *buffer, size_t count);
ssize_t write(int fd, const void *buffer, size_t count);
# 31 "safe-read.c" 2

# 1 "include/errno.h" 1
# 9 "include/errno.h"
extern int errno;
# 33 "safe-read.c" 2







# 1 "sys-limits.h" 1
# 21 "sys-limits.h"
# 1 "include/limits.h" 1
# 22 "sys-limits.h" 2
# 40 "sys-limits.h"
enum { SYS_BUFSIZE_MAX = 2147483647 >> 20 << 20 };
# 41 "safe-read.c" 2
# 55 "safe-read.c"
size_t
safe_write (int fd, void const *buf, size_t count)
{
  for (;;)
    {
      ssize_t result = write (fd, buf, count);

      if (0 <= result)
        return result;
      else if (((errno) == 4))
        continue;
      else if (errno == 22 && SYS_BUFSIZE_MAX < count)
        count = SYS_BUFSIZE_MAX;
      else
        return result;
    }
}
# 19 "safe-write.c" 2
# 4 "safe_write.c" 2
