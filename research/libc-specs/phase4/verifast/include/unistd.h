#ifndef RELAY_UNISTD_H
#define RELAY_UNISTD_H
#include <stddef.h>
ssize_t read(int fd, void *buf, size_t count);
/*@ requires fd == 0 &*& count == 32 &*& chars_(buf, 32, ?old); @*/
/*@ ensures result == -1 ? chars_(buf, 32, old) :
    0 <= result &*& result <= 32 &*& chars(buf, result, ?bytes) &*& chars_((char *)buf + result, 32 - result, _); @*/
ssize_t write(int fd, const void *buf, size_t count);
/*@ requires fd == 1 &*& 0 < count &*& count <= 32 &*& [?f]chars((void *)buf, count, ?bytes); @*/
/*@ ensures [f]chars((void *)buf, count, bytes) &*& -1 <= result &*& result <= count; @*/
#endif
