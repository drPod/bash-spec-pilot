/* Plain cat.  Copy the file behind 'input_desc' to STDOUT_FILENO.
   BUF (of size BUFSIZE) is the I/O buffer, used by reads and writes.
   Return true if successful.  */

static bool
simple_cat (char *buf, idx_t bufsize)
{
  /* Loop until the end of the file.  */

  while (true)
    {
      /* Read a block of input.  */

      size_t n_read = safe_read (input_desc, buf, bufsize);
      if (n_read == SAFE_READ_ERROR)
        {
          error (0, errno, "%s", quotef (infile));
          return false;
        }

      /* End of this file?  */

      if (n_read == 0)
        return true;

      /* Write this block out.  */

      if (full_write (STDOUT_FILENO, buf, n_read) != n_read)
        write_error ();
    }
}
