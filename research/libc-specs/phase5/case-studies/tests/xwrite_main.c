/* Driver for concatenated xwrite body (comment opener + pinned fragment). */
#include <errno.h>
#include <stdio.h>
#include <stdio_ext.h>
#include <stdlib.h>
#include <string.h>

#define fpurge(fp) __fpurge(fp)
#define EXIT_FAILURE 1
#define _(msgid) (msgid)

char const *quoteaf (char const *arg) { return arg ? arg : ""; }

static int g_error_calls;
void error (int status, int errnum, const char *format, const char *arg)
{
  (void)format; (void)arg;
  g_error_calls++;
  fprintf (stderr, "XWRITE_ERROR status=%d errnum=%d calls=%d\n",
           status, errnum, g_error_calls);
  if (status)
    exit (status);
}

#include "xwrite_body.c"

int main (int argc, char **argv)
{
  if (argc < 2)
    return 2;
  if (strcmp (argv[1], "ok") == 0)
    {
      xwrite_stdout ("hello\n", 6);
      return 0;
    }
  if (strcmp (argv[1], "zero") == 0)
    {
      xwrite_stdout ("x", 0);
      return 0;
    }
  if (strcmp (argv[1], "full") == 0)
    {
      if (!freopen ("/dev/full", "w", stdout))
        {
          perror ("freopen /dev/full");
          return 3;
        }
      /* Test setup: unbuffered so fwrite reports ENOSPC without relying on
         a later fflush the fragment does not perform. */
      setvbuf (stdout, NULL, _IONBF, 0);
      xwrite_stdout ("will-fail", 9);
      return 4;
    }
  return 2;
}
