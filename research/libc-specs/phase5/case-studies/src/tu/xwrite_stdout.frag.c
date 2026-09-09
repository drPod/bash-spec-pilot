   Exit immediately on error with a single diagnostic.  */

static void
xwrite_stdout (char const *buffer, size_t n_bytes)
{
  if (n_bytes > 0 && fwrite (buffer, 1, n_bytes, stdout) < n_bytes)
    {
      clearerr (stdout); /* To avoid redundant close_stdout diagnostic.  */
      fpurge (stdout);
      error (EXIT_FAILURE, errno, _("error writing %s"),
             quoteaf ("standard output"));
    }
}

