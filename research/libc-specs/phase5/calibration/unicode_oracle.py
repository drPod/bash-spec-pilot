"""Unicode 16 Tables 3-6/3-7 plus gnulib's separately documented return API.

Table-driven first-character classification; not a transcription of C branches.
Full encodings take precedence over incomplete prefixes, and trailing bytes after
the first complete character are ignored. No round-trip decoder is used here.
"""
ROWS = (
    ((0x00, 0x7F),),
    ((0xC2, 0xDF), (0x80, 0xBF)),
    ((0xE0, 0xE0), (0xA0, 0xBF), (0x80, 0xBF)),
    ((0xE1, 0xEC), (0x80, 0xBF), (0x80, 0xBF)),
    ((0xED, 0xED), (0x80, 0x9F), (0x80, 0xBF)),
    ((0xEE, 0xEF), (0x80, 0xBF), (0x80, 0xBF)),
    ((0xF0, 0xF0), (0x90, 0xBF), (0x80, 0xBF), (0x80, 0xBF)),
    ((0xF1, 0xF3), (0x80, 0xBF), (0x80, 0xBF), (0x80, 0xBF)),
    ((0xF4, 0xF4), (0x80, 0x8F), (0x80, 0xBF), (0x80, 0xBF)),
)


def decode_first(data: bytes) -> tuple[int, int]:
    if not data:
        raise ValueError('gnulib API requires n > 0')
    candidates = [row for row in ROWS
                  if all(lo <= value <= hi for (lo, hi), value in zip(row, data))]
    for row in candidates:
        n = len(row)
        if len(data) >= n:
            # Remove the fixed leading prefix, then accumulate base-64 digits.
            scalar = data[0] - (0, 0, 0xC0, 0xE0, 0xF0)[n]
            for value in data[1:n]:
                scalar = 64 * scalar + value - 0x80
            return n, scalar
    return (-2 if candidates else -1), 0xFFFD
