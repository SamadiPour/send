import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../deploy/deployer_config.dart';

class VersionManager {
  /// Get the current version from pubspec.yaml
  static Future<String?> getCurrentVersion() async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!await pubspecFile.exists()) {
        throw Exception('pubspec.yaml not found');
      }

      final content = await pubspecFile.readAsString();
      final pubspec = loadYaml(content);
      return pubspec['version'] as String?;
    } catch (e) {
      print('Warning: Could not read version from pubspec.yaml: $e');
      return null;
    }
  }

  /// Update the version in pubspec.yaml
  static Future<void> updateVersion(String newVersion) async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!await pubspecFile.exists()) {
        throw Exception('pubspec.yaml not found');
      }

      final content = await pubspecFile.readAsString();
      final yamlEditor = YamlEditor(content);
      yamlEditor.update(['version'], newVersion);

      await pubspecFile.writeAsString(yamlEditor.toString());
      print('✅ Updated version to $newVersion in pubspec.yaml');
    } catch (e) {
      throw Exception('Failed to update version in pubspec.yaml: $e');
    }
  }

  /// Increment version based on strategy
  static String incrementVersion(String currentVersion,
      {String strategy = 'patch'}) {
    final versionParts = currentVersion.split('+');
    final versionNumbers = versionParts[0].split('.');

    if (versionNumbers.length < 3) {
      throw Exception(
          'Invalid version format. Expected format: major.minor.patch[+build]');
    }

    int major = int.parse(versionNumbers[0]);
    int minor = int.parse(versionNumbers[1]);
    int patch = int.parse(versionNumbers[2]);

    switch (strategy.toLowerCase()) {
      case 'major':
        major++;
        minor = 0;
        patch = 0;
        break;
      case 'minor':
        minor++;
        patch = 0;
        break;
      case 'patch':
      default:
        patch++;
        break;
    }

    String newVersion = '$major.$minor.$patch';

    // Preserve build number if it exists
    if (versionParts.length > 1) {
      final buildNumber = int.parse(versionParts[1]) + 1;
      newVersion += '+$buildNumber';
    }

    return newVersion;
  }

  /// Handle version strategy
  static Future<String?> handleVersionStrategy(
      VersionStrategy strategy, String? customVersion) async {
    switch (strategy) {
      case VersionStrategy.manual:
        if (customVersion == null || customVersion.isEmpty) {
          throw Exception(
              'Custom version is required when using manual version strategy');
        }
        await updateVersion(customVersion);
        return customVersion;

      case VersionStrategy.auto:
        final currentVersion = await getCurrentVersion();
        if (currentVersion == null) {
          throw Exception('Could not read current version for auto increment');
        }
        final newVersion = incrementVersion(currentVersion);
        await updateVersion(newVersion);
        return newVersion;

      case VersionStrategy.none:
        return await getCurrentVersion();
    }
  }
}
