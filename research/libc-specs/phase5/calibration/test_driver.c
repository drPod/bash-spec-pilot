/* Differential-test harness only; not part of the verified translation unit.
   Exact malloc lengths let AddressSanitizer detect reads beyond supplied bytes. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "unistr.h"

static int digit(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    return -1;
}

int main(int argc, char **argv) {
    if (argc > 2) return 9;
    FILE *input = argc == 2 ? fopen(argv[1], "r") : stdin;
    if (!input) return 9;
    char line[80];
    while (fgets(line, sizeof line, input)) {
        size_t chars = strcspn(line, "\n");
        if (chars == 0 || chars % 2 != 0 || chars > 64) return 10;
        size_t n = chars / 2;
        uint8_t *data = malloc(n);
        uint8_t *saved = malloc(n);
        if (!data || !saved) return 11;
        for (size_t i = 0; i < n; ++i) {
            int a = digit(line[2*i]);
            int b = digit(line[2*i+1]);
            if (a < 0 || b < 0) return 12;
            data[i] = (uint8_t)(16*a+b);
        }
        memcpy(saved, data, n);
        ucs4_t scalar = 0xdeadbeef;
        int result = u8_mbtoucr(&scalar, data, n);
        if (memcmp(saved, data, n) != 0) return 13;
        printf("%d %u\n", result, scalar);
        free(saved);
        free(data);
    }
    int status = ferror(input) ? 14 : 0;
    if (input != stdin && fclose(input) != 0) return 14;
    return status;
}
