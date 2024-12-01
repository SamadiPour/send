import 'dart:async';

import 'package:send/src/base/context.dart';
import 'package:send/src/base/logger.dart';
import 'globals.dart' as globals;

Future<T> runInContext<T>(
  FutureOr<T> Function() runner, {
  Map<Type, Generator>? overrides,
}) async {

  // Wrap runner with any asynchronous initialization that should run with the
  // overrides and callbacks.
  FutureOr<T> runnerWrapper() async {
    return runner();
  }

  return context.run<T>(
    name: 'global fallbacks',
    body: runnerWrapper,
    overrides: overrides,
    fallbacks: <Type, Generator>{
      Logger: () => globals.platform.isWindows
          ? WindowsStdoutLogger(
        terminal: globals.terminal,
        stdio: globals.stdio,
        outputPreferences: globals.outputPreferences,
      )
          : StdoutLogger(
        terminal: globals.terminal,
        stdio: globals.stdio,
        outputPreferences: globals.outputPreferences,
      ),
    },
  );
}
