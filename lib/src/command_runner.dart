import 'dart:io';

/// Command class
/// This class is used to run commands needed in OS level and get the output
/// of the command.
class CommandRunner {
  /// Flutter Clean command
  /// This function is used to run the flutter clean command.
  static void flutterClean() {
    _run('flutter', ['clean']);
  }

  /// Wrapper for Process.run command with arguments
  /// This function is used to run the command and get the output of the command.
  /// The output is returned as a tuple of Result (boolean) and Output (string).
  static Future<(bool result, String output)> _run(
    String command,
    List<String>? arguments, {
    String? workingDirectory,
    bool runInShell = true,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
  }) async {
    try {
      var process = await Process.run(
        command,
        arguments ?? [],
        workingDirectory: workingDirectory,
        runInShell: runInShell,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
      );
      if (process.exitCode != 0) {
        return (false, process.stderr.toString());
      }
      return (true, process.stdout.toString());
    } catch (e) {
      return (false, e.toString());
    }
  }
}
