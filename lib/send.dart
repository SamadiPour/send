/// Send - Flutter App Deployment Tool
///
/// A comprehensive deployment automation library for Flutter applications
/// that supports deployment to Android (Google Play) and iOS (App Store).
library;

// Core deployment functionality
export 'src/deploy/deployer.dart';
export 'src/deploy/deployer_config.dart';
export 'src/deploy/android_deployer.dart';
export 'src/deploy/ios_deployer.dart';
export 'src/deploy/deployment_orchestrator.dart';

// Services
export 'src/services/google_play_service.dart';

// Command line interface
export 'src/cli/cli.dart';

// Utilities
export 'src/utils/config_reader.dart';
export 'src/utils/logger.dart';
export 'src/utils/utils.dart';
export 'src/utils/version_manager.dart';

// Command runner for external use
export 'src/command_runner.dart';
