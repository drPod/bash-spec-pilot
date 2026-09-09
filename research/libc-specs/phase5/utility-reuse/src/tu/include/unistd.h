#ifndef PHASE5_UR_UNISTD_H
#define PHASE5_UR_UNISTD_H

/* Declaration adapter, not a libc implementation or a verified POSIX model.
   Same two syscall-shaped declarations as research/libc-specs/phase5/relay/
   include/unistd.h, plus the descriptor macros the cat fragment uses.
   This experiment fixes the CompCert x86-64 Linux LP64 target. */
#include <stddef.h>
#include <sys/types.h>
ssize_t read(int fd, void *buffer, size_t count);
ssize_t write(int fd, const void *buffer, size_t count);
#define STDIN_FILENO 0
#define STDOUT_FILENO 1

#endif
