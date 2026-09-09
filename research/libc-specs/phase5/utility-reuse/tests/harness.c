/* Differential test harness: runs the frozen gnulib safe_read/safe_write/
   full_write and the byte-extracted coreutils simple_cat (linked from the
   frozen translation units in ../src/tu) against mock read/write syscalls
   driven by a schedule with exactly the semantics of IOWorld.v (read_n /
   write_n), then prints the observable outcome for comparison with the Python
   transliteration of the Coq model (run_tests.py).

   Input (stdin, one case): line 1: bufsize; line 2: read schedule (ints);
   line 3: write schedule (ints); line 4: input bytes as hex.
   Output: one JSON object. This tests the *model*, it is not the theorem. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <stddef.h>

typedef long ssize_t;
int model_errno;

extern _Bool simple_cat_entry (char *buf, ptrdiff_t bufsize);

#define MAXB 65536
static unsigned char unread[MAXB]; static size_t unread_len;
static unsigned char delivered[MAXB]; static size_t delivered_len;
static long rsched[256]; static int rn, rpos;
static long wsched[256]; static int wn, wpos;
static int diag[256]; static int ndiag;
static int read_fds[1024]; static int nread_calls;
static int write_fds[1024]; static int nwrite_calls;
static int write_error_called;
static jmp_buf out;

static long zmin (long a, long b) { return a < b ? a : b; }
static long zmax (long a, long b) { return a > b ? a : b; }

ssize_t read (int fd, void *buf, size_t count)
{
  if (nread_calls < 1024) read_fds[nread_calls] = fd;
  nread_calls++;
  long q = rpos < rn ? rsched[rpos++] : (long) count;   /* action n (reads s) */
  if (q < 0) { model_errno = (int) -q; return -1; }
  long k = zmin (zmax (1, q), zmin ((long) count, (long) unread_len));
  memcpy (buf, unread, (size_t) k);
  memmove (unread, unread + k, unread_len - (size_t) k);
  unread_len -= (size_t) k;
  return k;
}

ssize_t write (int fd, const void *buf, size_t count)
{
  if (nwrite_calls < 1024) write_fds[nwrite_calls] = fd;
  nwrite_calls++;
  long q = wpos < wn ? wsched[wpos++] : (long) count;   /* action |bs| (writes s) */
  if (q < 0) { model_errno = (int) -q; return -1; }
  long k = zmin (q, (long) count);
  memcpy (delivered + delivered_len, buf, (size_t) k);
  delivered_len += (size_t) k;
  return k;
}

char *quotearg_n_style_colon (int n, int s, char const *arg) { (void) n; (void) s; return (char *) arg; }
void error (int status, int errnum, const char *fmt, const char *arg)
{ (void) fmt; (void) arg; if (status != 0) abort (); if (ndiag < 256) diag[ndiag++] = errnum; }
void write_error (void) { write_error_called = 1; longjmp (out, 1); }

static void hex (const unsigned char *b, size_t n) { for (size_t i = 0; i < n; i++) printf ("%02x", b[i]); }

int main (void)
{
  long bufsize; if (scanf ("%ld", &bufsize) != 1) return 2;
  char line[8192];
  if (!fgets (line, sizeof line, stdin)) return 2;   /* rest of line 1 */
  if (!fgets (line, sizeof line, stdin)) return 2;
  for (char *t = strtok (line, " \n"); t; t = strtok (NULL, " \n")) rsched[rn++] = atol (t);
  if (!fgets (line, sizeof line, stdin)) return 2;
  for (char *t = strtok (line, " \n"); t; t = strtok (NULL, " \n")) wsched[wn++] = atol (t);
  if (!fgets (line, sizeof line, stdin)) return 2;
  for (char *t = line; t[0] && t[1] && t[0] != '\n'; t += 2)
    { unsigned v; sscanf (t, "%2x", &v); unread[unread_len++] = (unsigned char) v; }
  model_errno = 12345;   /* arbitrary initial errno */
  char *buf = malloc ((size_t) bufsize + 1);
  int result = -1;
  if (setjmp (out) == 0)
    result = simple_cat_entry (buf, (ptrdiff_t) bufsize);
  printf ("{\"result\": %d, \"write_error\": %d, \"errno\": %d, \"delivered\": \"", result, write_error_called, model_errno);
  hex (delivered, delivered_len);
  printf ("\", \"unread\": \""); hex (unread, unread_len);
  printf ("\", \"diag\": [");
  for (int i = 0; i < ndiag; i++) printf ("%s%d", i ? ", " : "", diag[i]);
  printf ("], \"read_calls\": %d, \"write_calls\": %d, \"read_fds_ok\": %d, \"write_fds_ok\": %d}\n",
          nread_calls, nwrite_calls,
          ({ int ok = 1; for (int i = 0; i < nread_calls && i < 1024; i++) ok &= read_fds[i] == 0; ok; }),
          ({ int ok = 1; for (int i = 0; i < nwrite_calls && i < 1024; i++) ok &= write_fds[i] == 1; ok; }));
  return 0;
}
