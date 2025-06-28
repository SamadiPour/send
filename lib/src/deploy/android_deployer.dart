import 'dart:io';

import 'package:send/src/command_runner.dart';
import 'package:send/src/services/google_play_service.dart';

import 'deployer.dart';
import 'deployer_config.dart';

class AndroidDeployer extends Deployer {
  late final CommandRunner commandRunner;

  AndroidDeployer(DeployerConfig config) : super(config) {
    commandRunner = CommandRunner(outputLevel: config.outputLevel);
  }

  @override
  Future<void> installDependencies() async {
    if (config.android == null) {
      throw Exception('Android configuration is missing');
    }

    // Check Flutter and Android setup
    await commandRunner.flutterDoctor();

    // Check if Android SDK is available
    final adbExists = await commandRunner.commandExists('adb');
    if (!adbExists) {
      throw Exception('Android SDK is not installed or not in PATH');
    }

    print('✅ Android dependencies validated');
  }

  @override
  Future<void> validate() async {
    if (config.android == null) {
      throw Exception('Android configuration is missing');
    }

    final androidConfig = config.android!;

    // Validate required fields for Google Play uploads
    if (androidConfig.credentialFilePath != null &&
        androidConfig.credentialFilePath!.isNotEmpty) {
      final credentialsFile = File(androidConfig.credentialFilePath!);
      if (!await credentialsFile.exists()) {
        throw Exception(
            'Google Play service account credentials file not found at: ${androidConfig.credentialFilePath}');
      }
    }

    if (androidConfig.trackName != null &&
        androidConfig.trackName!.isNotEmpty) {
      if (!GooglePlayService.isValidTrack(androidConfig.trackName!)) {
        throw Exception(
            'Invalid track name: ${androidConfig.trackName}. Valid tracks are: internal, alpha, beta, production');
      }
    }

    if (androidConfig.packageName == null ||
        androidConfig.packageName!.isEmpty) {
      throw Exception('Package name is required for Google Play uploads');
    }

    // Validate the build configuration
    final buildResult =
        await commandRunner.run('flutter', ['build', 'apk', '--debug']);
    if (!buildResult.$1) {
      throw Exception('Android build validation failed: ${buildResult.$2}');
    }

    print('✅ Android configuration validated');
  }

  @override
  Future<void> deploy() async {
    if (config.android == null) {
      throw Exception('Android configuration is missing');
    }

    final androidConfig = config.android!;

    // Clean before build
    await commandRunner.flutterClean();

    // Build APK and/or App Bundle
    final List<String> builtFiles = [];

    if (androidConfig.buildApk) {
      final apkResult = await commandRunner.flutterBuildApk(
        flavor: androidConfig.flavor,
      );

      if (!apkResult.$1) {
        throw Exception('Failed to build APK: ${apkResult.$2}');
      }

      final apkPath = await _findApkPath();
      if (apkPath != null) {
        builtFiles.add(apkPath);
        print('✅ Successfully built APK: $apkPath');
      }
    }

    if (androidConfig.buildAppBundle) {
      final bundleResult = await commandRunner.flutterBuildAppbundle(
        flavor: androidConfig.flavor,
      );

      if (!bundleResult.$1) {
        throw Exception('Failed to build App Bundle: ${bundleResult.$2}');
      }

      final bundlePath = await _findAppBundlePath();
      if (bundlePath != null) {
        builtFiles.add(bundlePath);
        print('✅ Successfully built App Bundle: $bundlePath');
      }
    }

    // Upload to Google Play if credentials are provided
    if (androidConfig.credentialFilePath != null &&
        androidConfig.credentialFilePath!.isNotEmpty &&
        androidConfig.trackName != null &&
        androidConfig.trackName!.isNotEmpty &&
        androidConfig.packageName != null &&
        androidConfig.packageName!.isNotEmpty) {
      await _uploadToGooglePlay(androidConfig, builtFiles);
    } else {
      print(
          'ℹ️  Skipping Google Play upload - credentials, track, or package name not configured');
      print('Built files:');
      for (final file in builtFiles) {
        print('  - $file');
      }
    }
  }

  Future<String?> _findApkPath() async {
    final projectRoot = await _findProjectRoot();
    final buildDir = Directory('$projectRoot/build/app/outputs/flutter-apk');

    if (!await buildDir.exists()) {
      return null;
    }

    final files = await buildDir.list().toList();
    for (final file in files) {
      if (file.path.endsWith('.apk') && !file.path.contains('debug')) {
        return file.path;
      }
    }
    return null;
  }

  Future<String?> _findAppBundlePath() async {
    final projectRoot = await _findProjectRoot();
    final buildDir = Directory('$projectRoot/build/app/outputs/bundle');

    if (!await buildDir.exists()) {
      return null;
    }

    final files = await buildDir.list(recursive: true).toList();
    for (final file in files) {
      if (file.path.endsWith('.aab')) {
        return file.path;
      }
    }
    return null;
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

  Future<void> _uploadToGooglePlay(
      DeployerAndroidConfig androidConfig, List<String> builtFiles) async {
    // Initialize Google Play service
    final googlePlayService = GooglePlayService(androidConfig.packageName!);

    try {
      await googlePlayService.initialize(androidConfig.credentialFilePath!);
    } catch (e) {
      throw Exception('Failed to initialize Google Play service: $e');
    }

    // Prefer App Bundle over APK for Google Play uploads
    String? uploadFile;
    bool isBundle = false;

    for (final file in builtFiles) {
      if (file.endsWith('.aab')) {
        uploadFile = file;
        isBundle = true;
        break;
      }
    }

    // Fallback to APK if no app bundle
    if (uploadFile == null) {
      for (final file in builtFiles) {
        if (file.endsWith('.apk')) {
          uploadFile = file;
          isBundle = false;
          break;
        }
      }
    }

    if (uploadFile == null) {
      throw Exception('No suitable file found for Google Play upload');
    }

    try {
      if (isBundle) {
        await googlePlayService.uploadBundle(
          bundlePath: uploadFile,
          track: androidConfig.trackName!,
          releaseNotes: androidConfig.releaseNote,
        );
      } else {
        await googlePlayService.uploadApk(
          apkPath: uploadFile,
          track: androidConfig.trackName!,
          releaseNotes: androidConfig.releaseNote,
        );
      }

      print(
          '✅ Successfully uploaded to Google Play (${androidConfig.trackName} track)');
    } catch (e) {
      throw Exception('Failed to upload to Google Play: $e');
    }
  }
}
