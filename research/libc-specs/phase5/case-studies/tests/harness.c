/* Differential harness: includes pinned fragments unedited.
   Mocks: scripted safe_read; xwrite_stdout capture for head_bytes;
   rawmemchr for wc_lines; error records status. Not a C proof. */
#include <errno.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SAFE_READ_ERROR ((size_t) -1)
#define BUFSIZ 8192
#define BUFFER_SIZE (16 * 1024)
#define _(msgid) (msgid)
typedef unsigned long uintmax_t;

enum quoting_style {
  literal_quoting_style, shell_quoting_style, shell_always_quoting_style,
  shell_escape_quoting_style, shell_escape_always_quoting_style,
  c_quoting_style, c_maybe_quoting_style, escape_quoting_style,
  locale_quoting_style, clocale_quoting_style, custom_quoting_style
};
#define quotef(arg) quotearg_n_style_colon (0, shell_escape_quoting_style, arg)

static int g_error_status;
static int g_error_errnum;
static char g_error_arg[256];
static int g_error_calls;

void error (int status, int errnum, const char *format, const char *arg)
{
  (void)format;
  g_error_calls++;
  g_error_status = status;
  g_error_errnum = errnum;
  if (arg)
    snprintf (g_error_arg, sizeof g_error_arg, "%s", arg);
  if (status)
    exit (status);
}

char const *quoteaf (char const *arg) { return arg ? arg : ""; }
char *quotearg_n_style_colon (int n, enum quoting_style s, char const *arg)
{
  (void)n; (void)s;
  return (char *)(arg ? arg : "");
}

#define MAX_READ_STEPS 64
#define MAX_SRC 65536
static unsigned char g_src[MAX_SRC];
static size_t g_src_len;
static size_t g_src_off;
static size_t g_forced_n[MAX_READ_STEPS];
static int g_forced_kind[MAX_READ_STEPS]; /* 0=min(n,remain), 1=short, 2=eof, 3=error */
static size_t g_forced_short[MAX_READ_STEPS];
static int g_nforced;
static int g_istep;
static int g_read_calls;

size_t safe_read (int fd, void *buf, size_t count)
{
  (void)fd;
  g_read_calls++;
  int i = g_istep;
  if (i < g_nforced)
    g_istep++;
  int kind = (i < g_nforced) ? g_forced_kind[i] : 0;
  if (kind == 3)
    return SAFE_READ_ERROR;
  if (kind == 2 || g_src_off >= g_src_len)
    return 0;
  size_t remain = g_src_len - g_src_off;
  size_t n = count < remain ? count : remain;
  if (kind == 1 && i < g_nforced && g_forced_short[i] < n)
    n = g_forced_short[i];
  memcpy (buf, g_src + g_src_off, n);
  g_src_off += n;
  return n;
}

static unsigned char g_out[MAX_SRC];
static size_t g_out_len;
static int g_xwrite_calls;
static int g_xwrite_fail;

void xwrite_stdout (char const *buffer, size_t n_bytes)
{
  g_xwrite_calls++;
  if (g_xwrite_fail)
    {
      error (1, EIO, "error writing %s", "standard output");
      return;
    }
  if (g_out_len + n_bytes > MAX_SRC)
    n_bytes = MAX_SRC - g_out_len;
  memcpy (g_out + g_out_len, buffer, n_bytes);
  g_out_len += n_bytes;
}

void *rawmemchr (const void *s, int c)
{
  const unsigned char *p = s;
  unsigned char ch = (unsigned char)c;
  for (;;)
    {
      if (*p == ch)
        return (void *)p;
      p++;
    }
}

#include "head_bytes.frag.c"
#include "wc_lines.frag.c"

static void reset_io (void)
{
  g_src_off = 0;
  g_istep = 0;
  g_read_calls = 0;
  g_out_len = 0;
  g_xwrite_calls = 0;
  g_xwrite_fail = 0;
  g_error_calls = 0;
  g_error_status = 0;
  g_error_errnum = 0;
  g_error_arg[0] = 0;
}

static uint32_t rng = 0xC0FFEE01u;
static uint32_t rnd (void) { rng = rng * 1664525u + 1013904223u; return rng; }

static int failures;
static int passed;

static void expect (int cond, const char *name)
{
  if (cond) { passed++; printf ("PASS %s\n", name); }
  else { failures++; printf ("FAIL %s\n", name); }
}

/* Independent oracles (not the fragment). */
static size_t oracle_prefix (size_t req)
{
  return req < g_src_len ? req : g_src_len;
}

static uintmax_t oracle_nl (const unsigned char *p, size_t n)
{
  uintmax_t c = 0;
  for (size_t i = 0; i < n; i++)
    if (p[i] == '\n')
      c++;
  return c;
}

static void set_src (const void *p, size_t n)
{
  memcpy (g_src, p, n);
  g_src_len = n;
}

static void force_clear (void) { g_nforced = 0; }

static void force_add (int kind, size_t sh)
{
  if (g_nforced >= MAX_READ_STEPS)
    return;
  g_forced_kind[g_nforced] = kind;
  g_forced_short[g_nforced] = sh;
  g_nforced++;
}

static bool
head_bytes_entry (char const *filename, int fd, uintmax_t bytes_to_write)
{
  return head_bytes (filename, fd, bytes_to_write);
}

static bool
wc_lines_entry (char const *file, int fd, uintmax_t *lines_out, uintmax_t *bytes_out)
{
  return wc_lines (file, fd, lines_out, bytes_out);
}

static void test_head (void)
{
  /* zero request */
  reset_io ();
  set_src ("abc", 3);
  force_clear ();
  bool ok = head_bytes_entry ("f", 3, 0);
  expect (ok && g_out_len == 0 && g_read_calls == 0, "head_zero_request");

  /* exact small */
  reset_io ();
  set_src ("hello", 5);
  force_clear ();
  ok = head_bytes_entry ("f", 3, 5);
  expect (ok && g_out_len == 5 && memcmp (g_out, "hello", 5) == 0, "head_exact5");

  /* request > available, EOF */
  reset_io ();
  set_src ("xy", 2);
  force_clear ();
  ok = head_bytes_entry ("f", 3, 100);
  expect (ok && g_out_len == 2 && g_out[0] == 'x', "head_eof_short_file");

  /* request 8192 boundary */
  reset_io ();
  g_src_len = 8192;
  memset (g_src, 'A', 8192);
  force_clear ();
  ok = head_bytes_entry ("f", 3, 8192);
  expect (ok && g_out_len == 8192 && g_read_calls == 1, "head_8192_one_block");

  /* 8193: two reads, second 1 byte */
  reset_io ();
  g_src_len = 9000;
  memset (g_src, 'B', 9000);
  force_clear ();
  ok = head_bytes_entry ("f", 3, 8193);
  expect (ok && g_out_len == 8193 && g_read_calls == 2, "head_8193_two_reads");

  /* short reads */
  reset_io ();
  g_src_len = 100;
  memset (g_src, 'C', 100);
  force_clear ();
  force_add (1, 10);
  force_add (1, 10);
  force_add (0, 0);
  ok = head_bytes_entry ("f", 3, 25);
  expect (ok && g_out_len == 25, "head_short_reads");

  /* read error */
  reset_io ();
  g_src_len = 10;
  memset (g_src, 'D', 10);
  force_clear ();
  force_add (3, 0);
  ok = head_bytes_entry ("f", 3, 10);
  expect (!ok && g_error_calls >= 1 && g_out_len == 0, "head_read_error");

  /* mid-stream error after partial */
  reset_io ();
  g_src_len = 50;
  memset (g_src, 'E', 50);
  force_clear ();
  force_add (1, 8);
  force_add (3, 0);
  ok = head_bytes_entry ("f", 3, 40);
  expect (!ok && g_out_len == 8, "head_error_after_partial");
}

static void test_wc (void)
{
  uintmax_t lines, bytes;
  const char *s;

  /* empty / immediate EOF */
  reset_io ();
  g_src_len = 0;
  force_clear ();
  bool ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (ok && lines == 0 && bytes == 0, "wc_empty");

  /* dense newlines (short-line / !long_lines stays false) */
  reset_io ();
  s = "a\nb\nc\n";
  set_src (s, 6);
  force_clear ();
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (ok && lines == 3 && bytes == 6, "wc_dense_small");

  /* no newline */
  reset_io ();
  set_src ("xyz", 3);
  force_clear ();
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (ok && lines == 0 && bytes == 3, "wc_no_nl");

  /* sentinel: block ending with newline */
  reset_io ();
  set_src ("ab\n", 3);
  force_clear ();
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (ok && lines == 1 && bytes == 3, "wc_trailing_nl");

  /* BUFFER_SIZE 16384 one full block dense */
  reset_io ();
  g_src_len = 16384;
  memset (g_src, '\n', 16384);
  force_clear ();
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (ok && lines == 16384 && bytes == 16384, "wc_16384_all_nl");

  /* sparse: 16384 bytes one newline at end -> long_lines true next */
  reset_io ();
  g_src_len = 16384 + 20;
  memset (g_src, 'x', g_src_len);
  g_src[16383] = '\n';
  memcpy (g_src + 16384, "a\nb\n", 4);
  g_src_len = 16388;
  force_clear ();
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  {
    uintmax_t exp_l = oracle_nl (g_src, g_src_len);
    expect (ok && bytes == g_src_len && lines == exp_l, "wc_sparse_then_second_block");
  }

  /* previous-block dense then sparse transition */
  reset_io ();
  g_src_len = 16384 * 2;
  memset (g_src, '\n', 16384); /* dense -> long_lines false */
  memset (g_src + 16384, 'z', 16384);
  g_src[16384 + 16383] = '\n'; /* one nl in second -> long_lines true after */
  force_clear ();
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (ok && bytes == g_src_len && lines == oracle_nl (g_src, g_src_len),
          "wc_dense_then_sparse");

  /* sparse then dense (long_lines arm then back) */
  reset_io ();
  g_src_len = 16384 * 2;
  memset (g_src, 'q', 16384);
  g_src[100] = '\n';
  memset (g_src + 16384, '\n', 16384);
  force_clear ();
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (ok && bytes == g_src_len && lines == oracle_nl (g_src, g_src_len),
          "wc_sparse_then_dense_rawmemchr");

  /* short reads */
  reset_io ();
  set_src ("12\n34\n", 6);
  force_clear ();
  force_add (1, 2);
  force_add (1, 2);
  force_add (1, 2);
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (ok && lines == 2 && bytes == 6, "wc_short_reads");

  /* read error: size_t -1 is > 0 so body sees SAFE_READ_ERROR */
  reset_io ();
  g_src_len = 4;
  memset (g_src, 'e', 4);
  force_clear ();
  force_add (3, 0);
  ok = wc_lines_entry ("f", 3, &lines, &bytes);
  expect (!ok && g_error_calls >= 1, "wc_read_error");

  /* null out pointers */
  reset_io ();
  g_src_len = 1;
  g_src[0] = 'a';
  ok = wc_lines_entry ("f", 3, NULL, &bytes);
  expect (!ok, "wc_null_lines_out");
  ok = wc_lines_entry ("f", 3, &lines, NULL);
  expect (!ok, "wc_null_bytes_out");
}

static void test_random (uint32_t seed, int n)
{
  rng = seed;
  for (int t = 0; t < n; t++)
    {
      size_t len = (rnd () % 4000) + 1;
      for (size_t i = 0; i < len; i++)
        g_src[i] = (unsigned char)(rnd () % 17 == 0 ? '\n' : (rnd () & 255));
      g_src_len = len;
      reset_io ();
      force_clear ();
      uintmax_t lines, bytes;
      bool ok = wc_lines_entry ("r", 3, &lines, &bytes);
      uintmax_t exp = oracle_nl (g_src, len);
      if (!(ok && bytes == len && lines == exp))
        {
          failures++;
          printf ("FAIL wc_rand_%d\n", t);
        }
      else
        passed++;

      reset_io ();
      uintmax_t req = rnd () % (len + 50);
      ok = head_bytes_entry ("r", 3, req);
      size_t expn = oracle_prefix (req);
      if (!(ok && g_out_len == expn && memcmp (g_out, g_src, expn) == 0))
        {
          failures++;
          printf ("FAIL head_rand_%d\n", t);
        }
      else
        passed++;
    }
  printf ("RANDOM seed=%u n=%d done\n", seed, n);
}

int main (void)
{
  test_head ();
  test_wc ();
  test_random (20260907u, 40);
  printf ("SUMMARY passed=%d failed=%d\n", passed, failures);
  return failures ? 1 : 0;
}
