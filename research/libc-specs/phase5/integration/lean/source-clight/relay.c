#include <stddef.h>
#include <unistd.h>

/* Restricted research subject. No retry after errors; zero write is a failure. */
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
