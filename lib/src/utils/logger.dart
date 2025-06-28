import 'dart:io';

import '../deploy/deployer_config.dart';

class Logger {
  final OutputLevel outputLevel;

  const Logger({this.outputLevel = OutputLevel.none});

  void info(String message) {
    if (outputLevel == OutputLevel.all) {
      stdout.writeln('[INFO] $message');
    }
  }

  void error(String message) {
    if (outputLevel == OutputLevel.error || outputLevel == OutputLevel.all) {
      stderr.writeln('[ERROR] $message');
    }
  }

  void warning(String message) {
    if (outputLevel == OutputLevel.all) {
      stdout.writeln('[WARNING] $message');
    }
  }

  void success(String message) {
    if (outputLevel == OutputLevel.all) {
      stdout.writeln('[SUCCESS] $message');
    }
  }

  void debug(String message) {
    if (outputLevel == OutputLevel.all) {
      stdout.writeln('[DEBUG] $message');
    }
  }
}
