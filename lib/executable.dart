import 'package:send/src/base/logger.dart';
import 'package:send/src/base/terminal.dart';

import 'runner.dart' as runner;
import 'src/base/io.dart';
import 'src/globals.dart' as globals;


import 'src/base/context.dart';

/// Main entry point for commands.
///
/// This function is intended to be used from the `send` command line tool.
Future<void> main(List<String> args) async {
  final bool verbose = args.contains('-v') || args.contains('--verbose');
  final bool prefixedErrors = args.contains('--prefixed-errors');

  await runner.run(
    args,
    verbose: verbose,
    overrides: <Type, Generator>{
    Logger: () {
      final LoggerFactory loggerFactory = LoggerFactory(
        outputPreferences: globals.outputPreferences,
        terminal: globals.terminal,
        stdio: globals.stdio,
      );
      return loggerFactory.createLogger(
        verbose: verbose,
        prefixedErrors: prefixedErrors,
        windows: globals.platform.isWindows,
      );
    },
    AnsiTerminal: () {
      return AnsiTerminal(
        stdio: globals.stdio,
        platform: globals.platform,
        now: DateTime.now(),
        defaultCliAnimationEnabled: false,
      );
    },
  });
}

/// An abstraction for instantiation of the correct logger type.
///
/// Our logger class hierarchy and runtime requirements are overly complicated.
class LoggerFactory {
  LoggerFactory({
    required Terminal terminal,
    required Stdio stdio,
    required OutputPreferences outputPreferences,
    StopwatchFactory stopwatchFactory = const StopwatchFactory(),
  })  : _terminal = terminal,
        _stdio = stdio,
        _stopwatchFactory = stopwatchFactory,
        _outputPreferences = outputPreferences;

  final Terminal _terminal;
  final Stdio _stdio;
  final StopwatchFactory _stopwatchFactory;
  final OutputPreferences _outputPreferences;

  /// Create the appropriate logger for the current platform and configuration.
  Logger createLogger({
    required bool verbose,
    required bool prefixedErrors,
    required bool windows,
  }) {
    Logger logger;
    if (windows) {
      logger = WindowsStdoutLogger(
        terminal: _terminal,
        stdio: _stdio,
        outputPreferences: _outputPreferences,
        stopwatchFactory: _stopwatchFactory,
      );
    } else {
      logger = StdoutLogger(
          terminal: _terminal,
          stdio: _stdio,
          outputPreferences: _outputPreferences,
          stopwatchFactory: _stopwatchFactory);
    }
    if (verbose) {
      logger = VerboseLogger(logger, stopwatchFactory: _stopwatchFactory);
    }
    if (prefixedErrors) {
      logger = PrefixedErrorLogger(logger);
    }
    return logger;
  }
}
