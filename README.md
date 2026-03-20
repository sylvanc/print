# `print`

`print` is a small output library for Verona.

Its job is deliberately narrow:

- provide global access to `stdout` and `stderr`
- make concurrent output to those streams serialize correctly
- support lightweight buffering
- support simple log-level-gated messages

It is **not** intended to be:

- a stdin or general input library
- an async I/O framework
- a string formatting library
- a comprehensive standard library

The design goal is a minimal, composable output stack.

## Overview

The library is split into a few small pieces:

- `print.v` provides the concrete file-descriptor-backed writers for `stdout` and `stderr`
- `async_writer.v` wraps a writer in a `cown` so writes are serialized correctly across concurrent use
- `buffer.v` batches small writes before forwarding them to another writer
- `log.v` defines log levels and their string prefixes
- `writer.v` defines the `writer` and `logger` shapes

In practice, the most important user-facing globals are:

- `out` for `stdout`
- `err` for `stderr`

Both are globally accessible and safe to use from concurrent code because they are backed by `async_writer`.

## Basic use

The common operations are:

- `print` for writing a string
- `println` for writing a string followed by a newline
- `write` for writing raw bytes

Typical usage looks like:

```
use print = "https://github.com/sylvanc/print" "main";

main(): i32
{
  print "hello, stdout";
  print::out "hello, stdout again";
  print::err "hello, stderr";
  0
}
```

The library also provides a top-level convenience `create(s: string): none` that prints a line to `out`, so code may also use the package itself as a simple print shortcut when that is desirable.

## Global `stdout` / `stderr`

Global access to `stdout` and `stderr` is a core feature of this library.

`out` and `err` are singleton-style capabilities that construct one shared writer each. Internally, those writers are wrapped in `async_writer`, which means writes from multiple concurrent callers are serialized through a `cown`.

That is the main reason this library exists as a separate component instead of being only a thin FFI wrapper around `write(2)`.

## Buffering

`buffer[A]` wraps another writer and accumulates small writes into a fixed-size byte buffer before forwarding them to the underlying writer.

This is useful when:

- many small prints would otherwise produce many tiny writes
- you want buffering without changing the underlying writer implementation

Example:

```
use print = "https://github.com/sylvanc/print" "main";

main(): i32
{
  let buf = print::buffer print::out;
  buf "first line";
  buf "second line";
  0
}
```

The buffer flushes when full, and it also flushes remaining data in its finalizer.

## Logging

`async_writer` also exposes simple log-level-gated output.

Available levels are:

- `log::error`
- `log::warning`
- `log::info`
- `log::debug`
- `log::trace`

By default, the file-descriptor writer starts at `log::info`.

Example:

```
use print = "https://github.com/sylvanc/print" "main";

main(): i32
{
  print::err.trace "not shown";
  print::err.set_log_level log::trace;
  print::err.trace "shown";
  0
}
```

Log messages are prefixed using `log::string(...)`, for example `"[info ] "` or `"[error] "`.

`log::from_string(...)` is also provided for code that needs to parse a log level from configuration.

## Terminal detection

Writers expose `terminal(): bool`.

For the standard file-descriptor-backed writers, this is based on `isatty`. The `async_writer` caches the terminal status when it is created.

This is intended as a small capability for higher-level libraries that may want different behavior for terminal vs non-terminal output.

## Shapes

The library defines two main shapes:

- `writer`
- `logger`

`writer` is the base output contract.

`logger` is for writers that support log-level-controlled output methods such as `error`, `warning`, and `trace`.

These shapes are intentionally small and structural so that other libraries can implement or wrap them without pulling in unrelated functionality.

## Non-goals

To keep the library small and modular, the following are intentionally out of scope:

- reading from stdin
- readiness polling, async file descriptors, or event loops
- formatting DSLs or interpolation frameworks
- rich terminal UI concerns
- broad filesystem or process I/O abstractions

Those can be built separately on top of this library or alongside it.
