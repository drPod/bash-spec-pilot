static bool
wc_lines (char const *file, int fd, uintmax_t *lines_out, uintmax_t *bytes_out)
{
  size_t bytes_read;
  uintmax_t lines, bytes;
  char buf[BUFFER_SIZE + 1];
  bool long_lines = false;

  if (!lines_out || !bytes_out)
    {
      return false;
    }

  lines = bytes = 0;

  while ((bytes_read = safe_read (fd, buf, BUFFER_SIZE)) > 0)
    {

      if (bytes_read == SAFE_READ_ERROR)
        {
          error (0, errno, "%s", quotef (file));
          return false;
        }

      bytes += bytes_read;

      char *p = buf;
      char *end = buf + bytes_read;
      uintmax_t plines = lines;

      if (! long_lines)
        {
          /* Avoid function call overhead for shorter lines.  */
          while (p != end)
            lines += *p++ == '\n';
        }
      else
        {
          /* rawmemchr is more efficient with longer lines.  */
          *end = '\n';
          while ((p = rawmemchr (p, '\n')) < end)
            {
              ++p;
              ++lines;
            }
        }

      /* If the average line length in the block is >= 15, then use
          memchr for the next block, where system specific optimizations
          may outweigh function call overhead.
          FIXME: This line length was determined in 2015, on both
          x86_64 and ppc64, but it's worth re-evaluating in future with
          newer compilers, CPUs, or memchr() implementations etc.  */
      if (lines - plines <= bytes_read / 15)
        long_lines = true;
      else
        long_lines = false;
    }

  *bytes_out = bytes;
  *lines_out = lines;

  return true;
}

