import '../utils/logger.dart';
import '../utils/version_manager.dart';
import 'android_deployer.dart';
import 'deployer.dart';
import 'deployer_config.dart';
import 'ios_deployer.dart';

class DeploymentOrchestrator {
  final DeployerConfig config;
  final Logger logger;

  DeploymentOrchestrator(this.config)
      : logger = Logger(outputLevel: config.outputLevel);

  /// Deploy to specified platforms
  Future<void> deploy({
    bool android = false,
    bool ios = false,
    bool validateOnly = false,
    bool installDependencies = false,
  }) async {
    final deployers = <Deployer>[];

    // Create deployers based on configuration and flags
    if (android && config.android != null) {
      deployers.add(AndroidDeployer(config));
    }

    if (ios && config.ios != null) {
      deployers.add(IOSDeployer(config));
    }

    if (deployers.isEmpty) {
      throw Exception('No platforms configured or selected for deployment');
    }

    logger.info('Starting deployment process...');

    // Handle version management
    if (config.versionStrategy != VersionStrategy.none) {
      try {
        final newVersion = await VersionManager.handleVersionStrategy(
          config.versionStrategy,
          config.customVersion,
        );
        if (newVersion != null) {
          logger.success('Version updated to: $newVersion');
        }
      } catch (e) {
        logger.warning('Version management failed: $e');
      }
    }

    for (final deployer in deployers) {
      final platform =
          deployer.runtimeType.toString().replaceAll('Deployer', '');

      try {
        if (installDependencies) {
          logger.info('Installing dependencies for $platform...');
          await deployer.installDependencies();
          logger.success('Dependencies installed for $platform');
        }

        logger.info('Validating $platform configuration...');
        await deployer.validate();
        logger.success('$platform configuration validated');

        if (!validateOnly) {
          logger.info('Deploying to $platform...');
          await deployer.deploy();
          logger.success('Successfully deployed to $platform');
        }
      } catch (e) {
        logger.error('Deployment failed for $platform: $e');
        rethrow;
      }
    }

    if (validateOnly) {
      logger.success('All validations passed');
    } else {
      logger.success('All deployments completed successfully');
    }
  }

  /// Deploy to all configured platforms
  Future<void> deployAll({
    bool validateOnly = false,
    bool installDependencies = false,
  }) async {
    await deploy(
      android: config.android != null,
      ios: config.ios != null,
      validateOnly: validateOnly,
      installDependencies: installDependencies,
    );
  }

  /// Show configuration summary
  void showConfigSummary() {
    logger.info('=== Deployment Configuration ===');
    logger.info('Output Level: ${config.outputLevel}');
    logger.info('Version Strategy: ${config.versionStrategy}');

    if (config.customVersion != null) {
      logger.info('Custom Version: ${config.customVersion}');
    }

    if (config.android != null) {
      logger.info('');
      logger.info('Android Configuration:');
      logger.info('  - Build APK: ${config.android!.buildApk}');
      logger.info('  - Build App Bundle: ${config.android!.buildAppBundle}');
      if (config.android!.flavor != null) {
        logger.info('  - Flavor: ${config.android!.flavor}');
      }
      if (config.android!.trackName != null) {
        logger.info('  - Google Play Track: ${config.android!.trackName}');
      }
      if (config.android!.credentialFilePath != null) {
        logger.info(
            '  - Credentials File: ${config.android!.credentialFilePath}');
      }
    }

    if (config.ios != null) {
      logger.info('');
      logger.info('iOS Configuration:');
      logger.info('  - Export Method: ${config.ios!.exportMethod}');
      if (config.ios!.teamId != null) {
        logger.info('  - Team ID: ${config.ios!.teamId}');
      }
      if (config.ios!.bundleId != null) {
        logger.info('  - Bundle ID: ${config.ios!.bundleId}');
      }
      if (config.ios!.apiKeyId != null) {
        logger.info('  - API Key ID: ${config.ios!.apiKeyId}');
      }
    }

    logger.info('================================');
  }
}
