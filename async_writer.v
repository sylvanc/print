use string_thunk = to_string | ()->string;

// Thread-safe writer. Wraps any A in a cown so all writes are serialized.
// Logging methods (error, warning, etc.) require A to have a log_level
// field — if A doesn't, calling them produces a compile error.
async_writer[A]
{
  c: cown[A];
  terminal: bool;

  // Caches terminal status at creation time (before the cown takes ownership).
  create(w: A)
  {
    let t = w.terminal;
    new {c = cown w, terminal = t}
  }

  write(self: async_writer, s: array[u8]): none
  {
    self.write(s, s.size)
  }

  write(self: async_writer, s: array[u8], len: usize): none
  {
    when self.c w ->
    {
      (*w).write(s, len)
    }
  }

  print(self: async_writer, s: string): none
  {
    self.write(s.data, s.size)
  }

  println(self: async_writer, s: string): none
  {
    when self.c w ->
    {
      (*w).print(s);
      // (*w).write("\n".data, usize 1)
      (*w).write("\n".data, 1)
    }
  }

  apply(self: async_writer, s: string): none
  {
    self.println(s)
  }

  set_log_level(self: async_writer, log_level: log::level): none
  {
    when self.c w ->
    {
      (*w).set_log_level log_level
    }
  }

  // Logging methods. The level check and write happen in a single `when`
  // block, so there's no race between checking the level and writing.
  // Lazy messages (()->string) are only evaluated if the level passes.
  error(self: async_writer, msg: string_thunk): none
  {
    self.log(log::error, msg)
  }

  warning(self: async_writer, msg: string_thunk): none
  {
    self.log(log::warning, msg)
  }

  info(self: async_writer, msg: string_thunk): none
  {
    self.log(log::info, msg)
  }

  debug(self: async_writer, msg: string_thunk): none
  {
    self.log(log::debug, msg)
  }

  trace(self: async_writer, msg: string_thunk): none
  {
    self.log(log::trace, msg)
  }

  log(self: async_writer, log_level: log::level, msg: string_thunk): none
  {
    when self.c w ->
    {
      if log_level.value <= (*w).log_level.value
      {
        (*w).print(log::string log_level);

        match msg
        {
          (s: to_string) -> (*w).print(s.string);
          (s: ()->string) -> (*w).print(s());
        }
      }
    }
  }
}
