// Contract for synchronous byte output.
shape writer
{
  write(self: self, s: array[u8]): none;
  write(self: self, s: array[u8], len: usize): none;
  print(self: self, s: string): none;
  println(self: self, s: string): none;
  apply(self: self, s: string): none;
  terminal(self: self): bool;
}

// Contract for log-level filtering.
shape logger
{
  set_log_level(self: self, log_level: log::level): none;
  error(self: self, msg: string_thunk): none;
  warning(self: self, msg: string_thunk): none;
  info(self: self, msg: string_thunk): none;
  debug(self: self, msg: string_thunk): none;
  trace(self: self, msg: string_thunk): none;
}
