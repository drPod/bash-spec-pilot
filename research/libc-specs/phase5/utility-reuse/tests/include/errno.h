#ifndef PHASE5_UR_TEST_ERRNO_H
#define PHASE5_UR_TEST_ERRNO_H
/* Test-harness variant of the errno adapter: the frozen sources are compiled
   against a plain int global named model_errno so the harness (compiled with
   glibc headers) can own it without colliding with glibc's TLS errno. Same
   Linux values as src/tu/include/errno.h. */
extern int model_errno;
#define errno model_errno
#define EINTR 4
#define EINVAL 22
#define ENOSPC 28
#endif
