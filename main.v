main(): i32
{
  let buf = buffer out;
  buf "Hello, world 1!";
  out "Hello, world 2!";
  print "Hello, world 3!";
  buf "Hello, world 4!";
  err.trace "This won't print.\n";
  err.set_log_level log::trace;
  err.trace "This will print.\n";
  0
}
