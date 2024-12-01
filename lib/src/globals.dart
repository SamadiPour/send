import 'base/context.dart';
import 'base/io.dart';
import 'base/logger.dart';
import 'base/platform.dart';
import 'base/terminal.dart';

Logger get logger => context.get<Logger>()!;

const Platform _kLocalPlatform = LocalPlatform();
Platform get platform => context.get<Platform>() ?? _kLocalPlatform;

final OutputPreferences _default = OutputPreferences(
  wrapText: stdio.hasTerminal,
  showColor:  platform.stdoutSupportsAnsi,
  stdio: stdio,
);
OutputPreferences get outputPreferences => context.get<OutputPreferences>() ?? _default;

/// Display an error level message to the user. Commands should use this if they
/// fail in some way.
///
/// Set [emphasis] to true to make the output bold if it's supported.
/// Set [color] to a [TerminalColor] to color the output, if the logger
/// supports it. The [color] defaults to [TerminalColor.red].
void printError(
    String message, {
      StackTrace? stackTrace,
      bool? emphasis,
      TerminalColor? color,
      int? indent,
      int? hangingIndent,
      bool? wrap,
    }) {
  logger.printError(
    message,
    stackTrace: stackTrace,
    emphasis: emphasis ?? false,
    color: color,
    indent: indent,
    hangingIndent: hangingIndent,
    wrap: wrap,
  );
}

/// Display a warning level message to the user. Commands should use this if they
/// have important warnings to convey that aren't fatal.
///
/// Set [emphasis] to true to make the output bold if it's supported.
/// Set [color] to a [TerminalColor] to color the output, if the logger
/// supports it. The [color] defaults to [TerminalColor.cyan].
void printWarning(
    String message, {
      bool? emphasis,
      TerminalColor? color,
      int? indent,
      int? hangingIndent,
      bool? wrap,
    }) {
  logger.printWarning(
    message,
    emphasis: emphasis ?? false,
    color: color,
    indent: indent,
    hangingIndent: hangingIndent,
    wrap: wrap,
  );
}

/// Display normal output of the command. This should be used for things like
/// progress messages, success messages, or just normal command output.
///
/// Set `emphasis` to true to make the output bold if it's supported.
///
/// Set `newline` to false to skip the trailing linefeed.
///
/// If `indent` is provided, each line of the message will be prepended by the
/// specified number of whitespaces.
void printStatus(
    String message, {
      bool? emphasis,
      bool? newline,
      TerminalColor? color,
      int? indent,
      int? hangingIndent,
      bool? wrap,
    }) {
  logger.printStatus(
    message,
    emphasis: emphasis ?? false,
    color: color,
    newline: newline ?? true,
    indent: indent,
    hangingIndent: hangingIndent,
    wrap: wrap,
  );
}

/// Display the [message] inside a box.
///
/// For example, this is the generated output:
///
///   ┌─ [title] ─┐
///   │ [message] │
///   └───────────┘
///
/// If a terminal is attached, the lines in [message] are automatically wrapped based on
/// the available columns.
void printBox(String message, {
  String? title,
}) {
  logger.printBox(message, title: title);
}

/// Use this for verbose tracing output. Users can turn this output on in order
/// to help diagnose issues with the toolchain or with their setup.
void printTrace(String message) => logger.printTrace(message);

AnsiTerminal get terminal {
  return context.get<AnsiTerminal>() ?? _defaultAnsiTerminal;
}

final AnsiTerminal _defaultAnsiTerminal = AnsiTerminal(
  stdio: stdio,
  platform: platform,
  now: DateTime.now(),
);

/// The global Stdio wrapper.
Stdio get stdio => context.get<Stdio>() ?? (_stdioInstance ??= Stdio());
Stdio? _stdioInstance;