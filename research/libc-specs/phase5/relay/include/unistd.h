#ifndef PHASE5_RELAY_UNISTD_H
#define PHASE5_RELAY_UNISTD_H

/* Declaration adapter, not a libc implementation or a verified POSIX model.
   This experiment fixes the CompCert x86-64 Linux LP64 target. */
#include <stddef.h>
typedef signed long ssize_t;
ssize_t read(int fd, void *buffer, size_t count);
ssize_t write(int fd, const void *buffer, size_t count);

#endif
