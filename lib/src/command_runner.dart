import 'dart:convert';
import 'dart:io';

import 'deploy/deployer_config.dart';
import 'utils/logger.dart';

/// Command class
/// This class is used to run commands needed in OS level and get the output
/// of the command.
class CommandRunner {
  /// Logger for output management
  final Logger logger;

  /// Constructor
  /// This constructor is used to initialize the CommandRunner class.
  CommandRunner({
    OutputLevel outputLevel = OutputLevel.none,
  }) : logger = Logger(outputLevel: outputLevel);

  /// Flutter Doctor command
  Future<(bool, String)> flutterDoctor({
    OutputLevel? outputLevel,
  }) {
    return run(
      'flutter',
      ['doctor'],
      onStdout: (data) => _stdout(data, outputLevel: outputLevel),
      onStderr: (data) => _stderr(data, outputLevel: outputLevel),
    );
  }

  /// Flutter Clean command
  Future<(bool, String)> flutterClean({
    OutputLevel? outputLevel,
  }) {
    return run(
      'flutter',
      ['clean'],
      onStdout: (data) => _stdout(data, outputLevel: outputLevel),
      onStderr: (data) => _stderr(data, outputLevel: outputLevel),
    );
  }

  /// Build iOS app
  Future<(bool, String)> flutterBuildIos({
    bool release = true,
    OutputLevel? outputLevel,
  }) {
    var args = ['build', 'ios'];
    if (release) {
      args.add('--release');
    }

    return run(
      'flutter',
      args,
      onStdout: (data) => _stdout(data, outputLevel: outputLevel),
      onStderr: (data) => _stderr(data, outputLevel: outputLevel),
    );
  }

  /// Build iOS IPA
  Future<(bool, String)> flutterBuildIpa({
    bool release = true,
    String? exportOptionsPlist,
    OutputLevel? outputLevel,
  }) {
    var args = ['build', 'ipa'];
    if (release) {
      args.add('--release');
    }
    if (exportOptionsPlist != null) {
      args.addAll(['--export-options-plist', exportOptionsPlist]);
    }

    return run(
      'flutter',
      args,
      onStdout: (data) => _stdout(data, outputLevel: outputLevel),
      onStderr: (data) => _stderr(data, outputLevel: outputLevel),
    );
  }

  /// Build Android APK
  Future<(bool, String)> flutterBuildApk({
    bool release = true,
    String? flavor,
    OutputLevel? outputLevel,
  }) {
    var args = ['build', 'apk'];
    if (release) {
      args.add('--release');
    }
    if (flavor != null) {
      args.addAll(['--flavor', flavor]);
    }

    return run(
      'flutter',
      args,
      onStdout: (data) => _stdout(data, outputLevel: outputLevel),
      onStderr: (data) => _stderr(data, outputLevel: outputLevel),
    );
  }

  /// Build Android App Bundle
  Future<(bool, String)> flutterBuildAppbundle({
    bool release = true,
    String? flavor,
    OutputLevel? outputLevel,
  }) {
    var args = ['build', 'appbundle'];
    if (release) {
      args.add('--release');
    }
    if (flavor != null) {
      args.addAll(['--flavor', flavor]);
    }

    return run(
      'flutter',
      args,
      onStdout: (data) => _stdout(data, outputLevel: outputLevel),
      onStderr: (data) => _stderr(data, outputLevel: outputLevel),
    );
  }

  /// Upload IPA to App Store Connect using API Key
  Future<(bool, String)> xcrunAltool({
    required String ipaPath,
    required String apiKeyId,
    required String apiKeyIssuer,
    required String apiKeyPath,
    OutputLevel? outputLevel,
  }) {
    return run(
      'xcrun',
      [
        'altool',
        '--upload-app',
        '--type',
        'ios',
        '--file',
        ipaPath,
        '--apiKey',
        apiKeyId,
        '--apiIssuer',
        apiKeyIssuer,
        '--apiKeyPath',
        apiKeyPath,
      ],
      onStdout: (data) => _stdout(data, outputLevel: outputLevel),
      onStderr: (data) => _stderr(data, outputLevel: outputLevel),
    );
  }

  /// Check if a command exists on the system
  Future<bool> commandExists(String command) async {
    try {
      final result = await run('which', [command]);
      return result.$1;
    } catch (e) {
      return false;
    }
  }

  /// Wrapper for Process.run command with arguments
  /// This function is used to run the command and get the output of the command.
  /// The output is returned as a tuple of Result (boolean) and Output (string).
  Future<(bool result, String output)> run(
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
        onStderr?.call(data);
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
  void _stdout(
    String message, {
    OutputLevel? outputLevel,
  }) {
    outputLevel ??= logger.outputLevel;
    if (outputLevel == OutputLevel.all) {
      stdout.write(message);
    }
  }

  /// Stderr
  /// This function is used to write the message to stderr.
  /// The message is written only if the output level is all or error.
  void _stderr(
    String message, {
    OutputLevel? outputLevel,
  }) {
    outputLevel ??= logger.outputLevel;
    if (outputLevel == OutputLevel.all || outputLevel == OutputLevel.error) {
      stderr.write(message);
    }
  }
}
