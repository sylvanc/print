// Accumulates small writes into a fixed-size buffer, flushing to the
// inner writer when full. Generic over A so it composes with any writer.
// The finalizer flushes remaining data when the buffer goes out of scope.
buffer[A]
{
  w: A;
  data: array[u8];
  cap: usize;
  len: usize;

  create(w: A, cap: usize = buffer::default_size): buffer
  {
    new {w, data = array[u8]::fill cap, cap, len = 0}
  }

  default_size(): usize
  {
    8192
  }

  write(self: buffer, s: array[u8], len: usize): none
  {
    let size = s.size min len;

    if (self.len + size) < self.cap
    {
      self._append(s, size);
      return
    }

    self.flush;

    if size < self.cap
    {
      self._append(s, size);
    }
    else
    {
      self.w.write(s, size)
    }
  }

  print(self: buffer, s: string): none
  {
    self.write(s.data, s.size)
  }

  println(self: buffer, s: string): none
  {
    self.print(s);
    self.write("\n".data, 1)
  }

  apply(self: buffer, s: string): none
  {
    self.println(s)
  }

  terminal(self: buffer): bool
  {
    self.w.terminal
  }

  // Replace the internal buffer with a fresh array, then freeze and send the
  // old one to the inner writer. We must allocate a new array (not reuse)
  // because the old one may still be in flight asynchronously.
  flush(self: buffer): none
  {
    if self.len > 0
    {
      let b = self.data = array[u8]::fill self.cap;
      let n = self.len = 0;
      mem::freeze b;
      self.w.write(b, n)
    }
  }

  _append(self: buffer, s: array[u8], len: usize): none
  {
    self.data().copy_from(self.len, s, 0, len);
    self.len = self.len + len
  }

  final(self: buffer): none
  {
    if self.len > 0
    {
      let b = self.data.copy(0, self.len);
      mem::freeze b;
      self.w.write(b, self.len)
    }
  }
}
