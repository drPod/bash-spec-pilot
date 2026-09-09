# 0 "u8_mbtoucr.c"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "u8_mbtoucr.c"
# 18 "u8_mbtoucr.c"
# 1 "include/config.h" 1
# 19 "u8_mbtoucr.c" 2


# 1 "include/unistr.h" 1


# 1 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h" 1
# 67 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef unsigned long size_t;
# 76 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef signed long ptrdiff_t;
# 98 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef int wchar_t;
# 122 "/home/coq/.opam/4.13.1+flambda/lib/compcert/include/stddef.h"
typedef long long max_align_t;
# 4 "include/unistr.h" 2
# 1 "include/stdint.h" 1




typedef unsigned char uint8_t;
typedef unsigned int uint32_t;
# 5 "include/unistr.h" 2

typedef uint32_t ucs4_t;
int u8_mbtoucr(ucs4_t *puc, const uint8_t *s, size_t n);
# 22 "u8_mbtoucr.c" 2

int
u8_mbtoucr (ucs4_t *puc, const uint8_t *s, size_t n)
{
  uint8_t c = *s;

  if (c < 0x80)
    {
      *puc = c;
      return 1;
    }
  else if (c >= 0xc2)
    {
      if (c < 0xe0)
        {
          if (n >= 2)
            {
              if ((s[1] ^ 0x80) < 0x40)
                {
                  *puc = ((unsigned int) (c & 0x1f) << 6)
                         | (unsigned int) (s[1] ^ 0x80);
                  return 2;
                }

            }
          else
            {

              *puc = 0xfffd;
              return -2;
            }
        }
      else if (c < 0xf0)
        {
          if (n >= 2)
            {
              if ((s[1] ^ 0x80) < 0x40
                  && (c >= 0xe1 || s[1] >= 0xa0)
                  && (c != 0xed || s[1] < 0xa0))
                {
                  if (n >= 3)
                    {
                      if ((s[2] ^ 0x80) < 0x40)
                        {
                          *puc = ((unsigned int) (c & 0x0f) << 12)
                                 | ((unsigned int) (s[1] ^ 0x80) << 6)
                                 | (unsigned int) (s[2] ^ 0x80);
                          return 3;
                        }

                    }
                  else
                    {

                      *puc = 0xfffd;
                      return -2;
                    }
                }

            }
          else
            {

              *puc = 0xfffd;
              return -2;
            }
        }
      else if (c <= 0xf4)
        {
          if (n >= 2)
            {
              if ((s[1] ^ 0x80) < 0x40
                  && (c >= 0xf1 || s[1] >= 0x90)
                  && (c < 0xf4 || ( s[1] < 0x90)))
                {
                  if (n >= 3)
                    {
                      if ((s[2] ^ 0x80) < 0x40)
                        {
                          if (n >= 4)
                            {
                              if ((s[3] ^ 0x80) < 0x40)
                                {
                                  *puc = ((unsigned int) (c & 0x07) << 18)
                                         | ((unsigned int) (s[1] ^ 0x80) << 12)
                                         | ((unsigned int) (s[2] ^ 0x80) << 6)
                                         | (unsigned int) (s[3] ^ 0x80);
                                  return 4;
                                }

                            }
                          else
                            {

                              *puc = 0xfffd;
                              return -2;
                            }
                        }

                    }
                  else
                    {

                      *puc = 0xfffd;
                      return -2;
                    }
                }

            }
          else
            {

              *puc = 0xfffd;
              return -2;
            }
        }
    }

  *puc = 0xfffd;
  return -1;
}
