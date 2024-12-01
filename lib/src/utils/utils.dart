import 'dart:io';

import 'package:send/src/base/logger.dart';

Future<String> findProjectRoot(Logger logger) async {
  var directory = Directory.current;
  while (!await File('${directory.path}/pubspec.yaml').exists()) {
    final parent = directory.parent;
    if (parent.path == directory.path) {
      logger.printTrace('Project root not found');
      throw Exception('Project root not found');
    }
    directory = parent;
  }
  return directory.path;
}
