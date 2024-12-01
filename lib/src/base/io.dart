// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This file serves as the single point of entry into the `dart:io` APIs
/// within Flutter tools.
///
/// In order to make Flutter tools more testable, we use the `FileSystem` APIs
/// in `package:file` rather than using the `dart:io` file APIs directly (see
/// `file_system.dart`). Doing so allows us to swap out local file system
/// access with mockable (or in-memory) file systems, making our tests hermetic
/// vis-a-vis file system access.
///
/// We also use `package:platform` to provide an abstraction away from the
/// static methods in the `dart:io` `Platform` class (see `platform.dart`). As
/// such, do not export Platform from this file!
///
/// To ensure that all file system and platform API access within Flutter tools
/// goes through the proper APIs, we forbid direct imports of `dart:io` (via a
/// test), forcing all callers to instead import this file, which exports the
/// blessed subset of `dart:io` that is legal to use in Flutter tools.
///
/// Because of the nature of this file, it is important that **platform and file
/// APIs not be exported from `dart:io` in this file**! Moreover, be careful
/// about any additional exports that you add to this file, as doing so will
/// increase the API surface that we have to test in Flutter tools, and the APIs
/// in `dart:io` can sometimes be hard to use in tests.
library;

// We allow `print()` in this file as a fallback for writing to the terminal via
// regular stdout/stderr/stdio paths. Everything else in the flutter_tools
// library should route terminal I/O through the [Stdio] class defined below.
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io' as io
    show
    IOSink,
    Stdin,
    StdinException,
    Stdout,
    StdoutException,
    stderr,
    stdin,
    stdout;

import 'package:meta/meta.dart';

import 'async_guard.dart';

export 'dart:io'
    show
    Stdin,
    StdinException,
    Stdout;

/// A class that wraps stdout, stderr, and stdin, and exposes the allowed
/// operations.
///
/// In particular, there are three ways that writing to stdout and stderr
/// can fail. A call to stdout.write() can fail:
///   * by throwing a regular synchronous exception,
///   * by throwing an exception asynchronously, and
///   * by completing the Future stdout.done with an error.
///
/// This class encapsulates all three so that we don't have to worry about it
/// anywhere else.
class Stdio {
  Stdio();

  /// Tests can provide overrides to use instead of the stdout and stderr from
  /// dart:io.
  @visibleForTesting
  Stdio.test({
    required io.Stdout stdout,
    required io.IOSink stderr,
  }) : _stdoutOverride = stdout, _stderrOverride = stderr;

  io.Stdout? _stdoutOverride;
  io.IOSink? _stderrOverride;

  // These flags exist to remember when the done Futures on stdout and stderr
  // complete to avoid trying to write to a closed stream sink, which would
  // generate a [StateError].
  bool _stdoutDone = false;
  bool _stderrDone = false;

  Stream<List<int>> get stdin => io.stdin;

  io.Stdout get stdout {
    if (_stdout != null) {
      return _stdout!;
    }
    _stdout = _stdoutOverride ?? io.stdout;
    _stdout!.done.then(
          (void _) { _stdoutDone = true; },
      onError: (Object err, StackTrace st) { _stdoutDone = true; },
    );
    return _stdout!;
  }
  io.Stdout? _stdout;

  io.IOSink get stderr {
    if (_stderr != null) {
      return _stderr!;
    }
    _stderr = _stderrOverride ?? io.stderr;
    _stderr!.done.then(
          (void _) { _stderrDone = true; },
      onError: (Object err, StackTrace st) { _stderrDone = true; },
    );
    return _stderr!;
  }
  io.IOSink? _stderr;

  bool get hasTerminal => io.stdout.hasTerminal;

  static bool? _stdinHasTerminal;

  /// Determines whether there is a terminal attached.
  ///
  /// [io.Stdin.hasTerminal] only covers a subset of cases. In this check the
  /// echoMode is toggled on and off to catch cases where the tool running in
  /// a docker container thinks there is an attached terminal. This can cause
  /// runtime errors such as "inappropriate ioctl for device" if not handled.
  bool get stdinHasTerminal {
    if (_stdinHasTerminal != null) {
      return _stdinHasTerminal!;
    }
    if (stdin is! io.Stdin) {
      return _stdinHasTerminal = false;
    }
    final io.Stdin ioStdin = stdin as io.Stdin;
    if (!ioStdin.hasTerminal) {
      return _stdinHasTerminal = false;
    }
    try {
      final bool currentEchoMode = ioStdin.echoMode;
      ioStdin.echoMode = !currentEchoMode;
      ioStdin.echoMode = currentEchoMode;
    } on io.StdinException {
      return _stdinHasTerminal = false;
    }
    return _stdinHasTerminal = true;
  }

  int? get terminalColumns => hasTerminal ? stdout.terminalColumns : null;
  int? get terminalLines => hasTerminal ? stdout.terminalLines : null;
  bool get supportsAnsiEscapes => hasTerminal && stdout.supportsAnsiEscapes;

  /// Writes [message] to [stderr], falling back on [fallback] if the write
  /// throws any exception. The default fallback calls [print] on [message].
  void stderrWrite(
      String message, {
        void Function(String, dynamic, StackTrace)? fallback,
      }) {
    if (!_stderrDone) {
      _stdioWrite(stderr, message, fallback: fallback);
      return;
    }
    fallback == null ? print(message) : fallback(
      message,
      const io.StdoutException('stderr is done'),
      StackTrace.current,
    );
  }

  /// Writes [message] to [stdout], falling back on [fallback] if the write
  /// throws any exception. The default fallback calls [print] on [message].
  void stdoutWrite(
      String message, {
        void Function(String, dynamic, StackTrace)? fallback,
      }) {
    if (!_stdoutDone) {
      _stdioWrite(stdout, message, fallback: fallback);
      return;
    }
    fallback == null ? print(message) : fallback(
      message,
      const io.StdoutException('stdout is done'),
      StackTrace.current,
    );
  }

  // Helper for [stderrWrite] and [stdoutWrite].
  void _stdioWrite(io.IOSink sink, String message, {
    void Function(String, dynamic, StackTrace)? fallback,
  }) {
    asyncGuard<void>(() async {
      sink.write(message);
    }, onError: (Object error, StackTrace stackTrace) {
      if (fallback == null) {
        print(message);
      } else {
        fallback(message, error, stackTrace);
      }
    });
  }

  /// Adds [stream] to [stdout].
  Future<void> addStdoutStream(Stream<List<int>> stream) => stdout.addStream(stream);

  /// Adds [stream] to [stderr].
  Future<void> addStderrStream(Stream<List<int>> stream) => stderr.addStream(stream);
}