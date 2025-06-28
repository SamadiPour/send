import 'dart:io';

import 'package:send/src/command_runner.dart';

import 'deployer.dart';
import 'deployer_config.dart';

class IOSDeployer extends Deployer {
  late final CommandRunner commandRunner;

  IOSDeployer(DeployerConfig config) : super(config) {
    commandRunner = CommandRunner(outputLevel: config.outputLevel);
  }

  @override
  Future<void> installDependencies() async {
    if (config.ios == null) {
      throw Exception('iOS configuration is missing');
    }

    // Check Flutter and iOS setup
    await commandRunner.flutterDoctor();

    // Check CocoaPods installation
    final podExists = await commandRunner.commandExists('pod');
    if (!podExists) {
      throw Exception(
          'CocoaPods is not installed. Please install it with: sudo gem install cocoapods');
    }

    // Check Xcode installation
    final xcodeExists = await commandRunner.commandExists('xcodebuild');
    if (!xcodeExists) {
      throw Exception(
          'Xcode is not installed or Xcode command line tools are missing');
    }

    // Install iOS pods
    final projectRoot = await _findProjectRoot();
    final podInstallResult = await commandRunner.run(
      'pod',
      ['install'],
      workingDirectory: '$projectRoot/ios',
    );

    if (!podInstallResult.$1) {
      throw Exception(
          'Failed to install CocoaPods dependencies: ${podInstallResult.$2}');
    }
  }

  @override
  Future<void> validate() async {
    if (config.ios == null) {
      throw Exception('iOS configuration is missing');
    }

    final iosConfig = config.ios!;

    // Validate required fields
    if (iosConfig.apiKeyId == null || iosConfig.apiKeyId!.isEmpty) {
      throw Exception(
          'iOS API Key ID is required for App Store Connect uploads');
    }

    if (iosConfig.apiKeyIssuer == null || iosConfig.apiKeyIssuer!.isEmpty) {
      throw Exception(
          'iOS API Key Issuer is required for App Store Connect uploads');
    }

    if (iosConfig.apiKeyPath == null || iosConfig.apiKeyPath!.isEmpty) {
      throw Exception(
          'iOS API Key Path is required for App Store Connect uploads');
    }

    // Validate that the API key file exists
    final keyFile = File(iosConfig.apiKeyPath!);
    if (!await keyFile.exists()) {
      throw Exception('iOS API Key file not found at: ${iosConfig.apiKeyPath}');
    }

    // Validate the build configuration
    final buildResult = await commandRunner.flutterBuildIos(release: false);
    if (!buildResult.$1) {
      throw Exception('iOS build validation failed: ${buildResult.$2}');
    }
  }

  @override
  Future<void> deploy() async {
    if (config.ios == null) {
      throw Exception('iOS configuration is missing');
    }

    final iosConfig = config.ios!;

    // Clean before build
    await commandRunner.flutterClean();

    // Create export options plist if not provided
    String exportOptionsPath =
        iosConfig.exportOptionsPlistPath ?? 'ios/exportOptions.plist';

    if (iosConfig.exportOptionsPlistPath == null) {
      await _createExportOptionsPlist(
        filePath: exportOptionsPath,
        method: iosConfig.exportMethod ?? 'app-store',
        teamId: iosConfig.teamId ?? '',
      );
    }

    // Build IPA
    final buildResult = await commandRunner.flutterBuildIpa(
      exportOptionsPlist: exportOptionsPath,
    );

    if (!buildResult.$1) {
      throw Exception('Failed to build IPA: ${buildResult.$2}');
    }

    // Find the generated IPA file
    final projectRoot = await _findProjectRoot();
    final ipaPath = await _findIpaPath(projectRoot);

    if (ipaPath == null) {
      throw Exception('Could not find generated IPA file');
    }

    // Upload to App Store Connect
    final uploadResult = await commandRunner.xcrunAltool(
      ipaPath: ipaPath,
      apiKeyId: iosConfig.apiKeyId!,
      apiKeyIssuer: iosConfig.apiKeyIssuer!,
      apiKeyPath: iosConfig.apiKeyPath!,
    );

    if (!uploadResult.$1) {
      throw Exception(
          'Failed to upload to App Store Connect: ${uploadResult.$2}');
    }

    print('✅ Successfully uploaded iOS app to App Store Connect');
  }

  Future<String> _findProjectRoot() async {
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

  Future<String?> _findIpaPath(String projectRoot) async {
    final buildDir = Directory('$projectRoot/build/ios/ipa');
    if (!await buildDir.exists()) {
      return null;
    }

    final files = await buildDir.list().toList();
    for (final file in files) {
      if (file.path.endsWith('.ipa')) {
        return file.path;
      }
    }
    return null;
  }

  Future<void> _createExportOptionsPlist({
    required String filePath,
    required String method,
    required String teamId,
  }) async {
    final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$method</string>
    <key>teamID</key>
    <string>$teamId</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>''';

    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(plistContent);
  }
}
