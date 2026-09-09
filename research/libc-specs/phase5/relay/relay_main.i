# 0 "relay_main.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "relay_main.c"



# 1 "relay.c" 1
# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 67 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef unsigned long size_t;
# 76 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef signed long ptrdiff_t;
# 98 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef int wchar_t;
# 122 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef long long max_align_t;
# 2 "relay.c" 2
# 1 "include/unistd.h" 1





# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 7 "include/unistd.h" 2
typedef signed long ssize_t;
ssize_t read(int fd, void *buffer, size_t count);
ssize_t write(int fd, const void *buffer, size_t count);
# 3 "relay.c" 2


int relay(void) {
    unsigned char buf[32];
    ssize_t n;
    ssize_t w;
    size_t off;
    while (1) {
        n = read(0, buf, 32);
        if (n < 0) return 1;
        if (n == 0) return 0;
        off = 0;
        while (off < (size_t)n) {
            w = write(1, buf + off, (size_t)n - off);
            if (w <= 0) return 2;
            off = off + (size_t)w;
        }
    }
}
# 5 "relay_main.c" 2

int main(void) {
    return relay();
}
