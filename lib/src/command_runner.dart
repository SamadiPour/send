import 'dart:convert';
import 'dart:io';

enum CommandOutputLevel {
  none,
  error,
  all,
}

/// Command class
/// This class is used to run commands needed in OS level and get the output
/// of the command.
class CommandRunner {
  /// Raw output
  final CommandOutputLevel outputLevel;

  /// Constructor
  /// This constructor is used to initialize the CommandRunner class.
  CommandRunner({
    this.outputLevel = CommandOutputLevel.none,
  });

  /// Flutter Doctor command
  void flutterDoctor({
    CommandOutputLevel? outputLevel,
  }) {
    _run(
      'flutter',
      ['doctor'],
      onStdout: (data) => _stdout(data, outputLevel ?? this.outputLevel),
      onStderr: (data) => _stderr(data, outputLevel ?? this.outputLevel),
    );
  }

  /// Flutter Clean command
  void flutterClean({
    CommandOutputLevel? outputLevel,
  }) {
    _run(
      'flutter',
      ['clean'],
      onStdout: (data) => _stdout(data, outputLevel ?? this.outputLevel),
      onStderr: (data) => _stderr(data, outputLevel ?? this.outputLevel),
    );
  }

  /// Wrapper for Process.run command with arguments
  /// This function is used to run the command and get the output of the command.
  /// The output is returned as a tuple of Result (boolean) and Output (string).
  Future<(bool result, String output)> _run(
    String command,
    List<String>? arguments, {
    String? workingDirectory,
    bool runInShell = true,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    Function(String)? onStdout,
    Function(String)? onStderr,
  }) async {
    try {
      var process = await Process.start(
        command,
        arguments ?? [],
        workingDirectory: workingDirectory,
        runInShell: runInShell,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
      );

      var output = StringBuffer();
      var errorOutput = StringBuffer();

      process.stdout.transform(utf8.decoder).listen((data) {
        onStdout?.call(data);
        output.write(data);
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        onStdout?.call(data);
        errorOutput.write(data);
      });

      var exitCode = await process.exitCode;
      if (exitCode != 0) {
        return (false, errorOutput.toString());
      }
      return (true, output.toString());
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Stdout
  /// This function is used to write the message to stdout.
  /// The message is written only if the output level is all.
  void _stdout(String message, CommandOutputLevel outputLevel) {
    if (outputLevel == CommandOutputLevel.all) {
      stdout.write(message);
    }
  }

  /// Stderr
  /// This function is used to write the message to stderr.
  /// The message is written only if the output level is all or error.
  void _stderr(String message, CommandOutputLevel outputLevel) {
    if (outputLevel == CommandOutputLevel.all ||
        outputLevel == CommandOutputLevel.error) {
      stderr.write(message);
    }
  }
}
