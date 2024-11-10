import 'dart:io';

Future<String> findProjectRoot() async {
  var directory = Directory.current;
  while (!await File('${directory.path}/pubspec.yaml').exists()) {
    final parent = directory.parent;
    if (parent.path == directory.path) {
      throw Exception('Project root not found');
    }
    directory = parent;
  }
  return directory.path;
}
