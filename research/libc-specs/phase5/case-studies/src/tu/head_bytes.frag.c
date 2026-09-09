static bool
head_bytes (char const *filename, int fd, uintmax_t bytes_to_write)
{
  char buffer[BUFSIZ];
  size_t bytes_to_read = BUFSIZ;

  while (bytes_to_write)
    {
      size_t bytes_read;
      if (bytes_to_write < bytes_to_read)
        bytes_to_read = bytes_to_write;
      bytes_read = safe_read (fd, buffer, bytes_to_read);
      if (bytes_read == SAFE_READ_ERROR)
        {
          error (0, errno, _("error reading %s"), quoteaf (filename));
          return false;
        }
      if (bytes_read == 0)
        break;
      xwrite_stdout (buffer, bytes_read);
      bytes_to_write -= bytes_read;
    }
  return true;
}
