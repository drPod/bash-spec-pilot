#include <stddef.h>
#include <unistd.h>

/* Restricted research subject. No retry after errors; zero write is a failure. */
int relay(void)
//@ requires true;
//@ ensures 0 <= result &*& result <= 2;
{
    unsigned char buf[32];
    ssize_t n;
    ssize_t w;
    size_t off;
    //@ uchars__to_chars_(buf);
    while (1)
    //@ invariant chars_((char *)buf, 32, _);
    {
        n = read(0, buf, 32);
        //@ if (n < 0) { chars__to_uchars_(buf); }
        if (n < 0) return 1;
        //@ if (n == 0) { chars_chars__join((char *)buf); chars__to_uchars_(buf); }
        if (n == 0) return 0;
        off = 0;
        while (off < (size_t)n)
        /*@ invariant 0 <= off &*& off <= n &*& 0 < n &*& n <= 32 &*&
            chars((char *)buf, n, ?bytes) &*& chars_((char *)buf + n, 32 - n, _); @*/
        {
            //@ chars_split((char *)buf, off);
            w = write(1, buf + off, (size_t)n - off);
            //@ chars_join((char *)buf);
            //@ if (w <= 0) { chars_chars__join((char *)buf); chars__to_uchars_(buf); }
            if (w <= 0) return 2;
            off = off + (size_t)w;
        }
        //@ chars_chars__join((char *)buf);
    }
}
