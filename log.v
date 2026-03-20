// Log level constants and formatting utilities.
log
{
  error { value(self: error): u8 { 0 } }
  warning { value(self: warning): u8 { 1 } }
  info { value(self: info): u8 { 2 } }
  debug { value(self: debug): u8 { 3 } }
  trace { value(self: trace): u8 { 4 } }

  use level = error | warning | info | debug | trace;

  string(log_level: level): string
  {
    match log_level
    {
      (error) -> "[error] ";
      (warning) -> "[warn ] ";
      (info) -> "[info ] ";
      (debug) -> "[debug] ";
      (trace) -> "[trace] ";
    }
    else
    {
      "[?????] "
    }
  }

  from_string(s: string): level | none
  {
    match s
    {
      ("error") -> error;
      ("warning") -> warning;
      ("info") -> info;
      ("debug") -> debug;
      ("trace") -> trace;
    }
    else
    {
      none
    }
  }
}
