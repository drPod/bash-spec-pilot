#ifndef PHASE5_CALIBRATION_UNISTR_H
#define PHASE5_CALIBRATION_UNISTR_H
#include <stddef.h>
#include <stdint.h>
/* Declaration/type adapter for the frozen gnulib translation unit. */
typedef uint32_t ucs4_t;
int u8_mbtoucr(ucs4_t *puc, const uint8_t *s, size_t n);
#endif
