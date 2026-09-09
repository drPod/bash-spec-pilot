#ifndef PHASE5_UR_ERRNO_H
#define PHASE5_UR_ERRNO_H
/* Declaration adapter, not glibc. errno is modeled as one plain int global.
   (C11 requires errno to be a macro for a modifiable int lvalue; glibc expands
   it to (*__errno_location ()). The plain-global form is the historical POSIX
   definition and gives VST a `gv _errno` cell.)
   Values are Linux asm-generic/errno-base.h; the Coq model (IOWorld.v) must
   use the same numbers. */
extern int errno;
#define EINTR 4
#define EINVAL 22
#define ENOSPC 28
#endif
