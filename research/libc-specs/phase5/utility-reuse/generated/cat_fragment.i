# 0 "cat_fragment.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "cat_fragment.c"





# 1 "include/config.h" 1
# 7 "cat_fragment.c" 2
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 67 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef unsigned long size_t;
# 76 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef signed long ptrdiff_t;
# 98 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef int wchar_t;
# 122 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef long long max_align_t;
# 8 "cat_fragment.c" 2
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stdbool.h" 1
# 9 "cat_fragment.c" 2
# 1 "include/errno.h" 1
# 9 "include/errno.h"
extern int errno;
# 10 "cat_fragment.c" 2
# 1 "include/unistd.h" 1







# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 9 "include/unistd.h" 2
# 1 "include/sys/types.h" 1




# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 6 "include/sys/types.h" 2


typedef signed long ssize_t;
# 10 "include/unistd.h" 2
ssize_t read(int fd, void *buffer, size_t count);
ssize_t write(int fd, const void *buffer, size_t count);
# 11 "cat_fragment.c" 2
# 1 "full-write.h" 1
# 18 "full-write.h"
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 19 "full-write.h" 2
# 29 "full-write.h"
extern size_t full_write (int fd, const void *buf, size_t count);
# 12 "cat_fragment.c" 2
# 1 "safe-read.h" 1
# 30 "safe-read.h"
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 31 "safe-read.h" 2
# 42 "safe-read.h"
extern size_t safe_read (int fd, void *buf, size_t count);
# 13 "cat_fragment.c" 2


typedef ptrdiff_t idx_t;


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
# 44 "cat_fragment.c"
void error (int status, int errnum, const char *format, const char *arg);
# 53 "cat_fragment.c"
void write_error (void);



static char const *infile;


static int input_desc;

# 1 "simple_cat.frag.c" 1




static _Bool
simple_cat (char *buf, idx_t bufsize)
{


  while (1)
    {


      size_t n_read = safe_read (input_desc, buf, bufsize);
      if (n_read == ((size_t) -1))
        {
          error (0, errno, "%s", quotearg_n_style_colon (0, shell_escape_quoting_style, infile));
          return 0;
        }



      if (n_read == 0)
        return 1;



      if (full_write (1, buf, n_read) != n_read)
        write_error ();
    }
}
# 63 "cat_fragment.c" 2





_Bool
simple_cat_entry (char *buf, idx_t bufsize)
{
  return simple_cat (buf, bufsize);
}
