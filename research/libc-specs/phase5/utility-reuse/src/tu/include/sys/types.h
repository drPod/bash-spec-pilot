#ifndef PHASE5_UR_SYS_TYPES_H
#define PHASE5_UR_SYS_TYPES_H
/* Declaration adapter: ssize_t for the CompCert x86-64 Linux LP64 target,
   identical to the phase5 relay adapter's definition. */
#include <stddef.h>
#ifndef PHASE5_UR_SSIZE_T
#define PHASE5_UR_SSIZE_T
typedef signed long ssize_t;
#endif
#endif
