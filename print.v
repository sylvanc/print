use
{
  write_all = "write_all"(i32, array[u8], usize): bool;
  isatty = "isatty"(i32): i32;
}

_fd_writer
{
  fd: i32;
  log_level: log::level;

  create(capability: out | err): async_writer[_fd_writer]
  {
    let fd = match capability
    {
      out -> 1;
      err -> 2;
    }
    else
    {
      0
    }

    async_writer(new {fd, log_level = log::info})
  }

  write(self: _fd_writer, s: array[u8]): none
  {
    self.write(s, s.size)
  }

  write(self: _fd_writer, s: array[u8], len: usize): none
  {
    if len > 0
    {
      :::write_all(self.fd, s, len)
    }
  }

  print(self: _fd_writer, s: string): none
  {
    self.write(s.data, s.size)
  }

  println(self: _fd_writer, s: string): none
  {
    self.write(s.data, s.size);
    self.write("\n".data, 1);
  }

  apply(self: _fd_writer, s: string): none
  {
    self.println(s)
  }

  terminal(self: _fd_writer): bool
  {
    :::isatty(self.fd) != 0
  }

  set_log_level(self: _fd_writer, log_level: log::level): none
  {
    self.log_level = log_level
  }
}

// Singleton capabilities for stdout and stderr.
// Usage: `out.print "hello"` or `err.error "oops"`.
out
{
  once create(): async_writer[_fd_writer]
  {
    _fd_writer(new {})
  }

  create(s: string): none
  {
    out.println s
  }
}

err
{
  once create(): async_writer[_fd_writer]
  {
    _fd_writer(new {})
  }

  create(s: string): none
  {
    err.println s
  }
}

create(s: string): none
{
  out.println s
}
