import 'package:args/args.dart';

import '../deploy/deployment_orchestrator.dart';
import '../deploy/deployer_config.dart';
import '../utils/config_reader.dart';

class CommandLineInterface {
  static final ArgParser _parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show usage information',
      negatable: false,
    )
    ..addOption(
      'config',
      abbr: 'c',
      help: 'Path to the deployment configuration file',
      defaultsTo: 'deploy.yaml',
    )
    ..addFlag(
      'android',
      abbr: 'a',
      help: 'Deploy to Android (Google Play)',
      negatable: false,
    )
    ..addFlag(
      'ios',
      abbr: 'i',
      help: 'Deploy to iOS (App Store)',
      negatable: false,
    )
    ..addFlag(
      'all',
      help: 'Deploy to all configured platforms',
      negatable: false,
    )
    ..addFlag(
      'validate',
      abbr: 'v',
      help: 'Validate configuration and dependencies without deploying',
      negatable: false,
    )
    ..addFlag(
      'install-deps',
      abbr: 'd',
      help: 'Install platform dependencies before deployment',
      negatable: false,
    )
    ..addFlag(
      'show-config',
      abbr: 's',
      help: 'Show deployment configuration summary',
      negatable: false,
    )
    ..addOption(
      'output-level',
      abbr: 'o',
      help: 'Output verbosity level',
      allowed: ['none', 'error', 'all'],
      defaultsTo: 'none',
    );

  static Future<void> run(List<String> arguments) async {
    try {
      final argResults = _parser.parse(arguments);

      if (argResults['help'] as bool) {
        _showHelp();
        return;
      }

      final configPath = argResults['config'] as String;
      final config = await ConfigReader.read(configPath: configPath);

      if (config == null) {
        print('❌ Failed to load configuration from $configPath');
        return;
      }

      // Override output level if specified
      final outputLevelStr = argResults['output-level'] as String;
      final outputLevel = _parseOutputLevel(outputLevelStr);
      final updatedConfig = config.copyWith(outputLevel: outputLevel);

      final orchestrator = DeploymentOrchestrator(updatedConfig);

      if (argResults['show-config'] as bool) {
        orchestrator.showConfigSummary();
        return;
      }

      final android = argResults['android'] as bool;
      final ios = argResults['ios'] as bool;
      final all = argResults['all'] as bool;
      final validate = argResults['validate'] as bool;
      final installDeps = argResults['install-deps'] as bool;

      if (!android && !ios && !all) {
        print(
            '❌ Please specify at least one platform: --android, --ios, or --all');
        _showUsage();
        return;
      }

      if (all) {
        await orchestrator.deployAll(
          validateOnly: validate,
          installDependencies: installDeps,
        );
      } else {
        await orchestrator.deploy(
          android: android,
          ios: ios,
          validateOnly: validate,
          installDependencies: installDeps,
        );
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  static void _showHelp() {
    print('Send - Flutter App Deployment Tool');
    print('');
    print(
        'A tool to automate deployment of Flutter applications to various app stores.');
    print('');
    print('Usage: send [options]');
    print('');
    print('Options:');
    print(_parser.usage);
    print('');
    print('Examples:');
    print(
        '  send --all --install-deps         Deploy to all configured platforms with dependency installation');
    print(
        '  send --android --validate         Validate Android configuration without deploying');
    print(
        '  send --ios --config my-config.yaml  Deploy iOS using custom configuration file');
    print(
        '  send --show-config                Show current configuration summary');
    print('');
    print('Configuration:');
    print(
        '  Create a deploy.yaml file in your project root with platform-specific settings.');
    print('  See the example configuration in the documentation.');
  }

  static void _showUsage() {
    print('Usage: send [options]');
    print('Run "send --help" for detailed information.');
  }

  static OutputLevel _parseOutputLevel(String value) {
    switch (value.toLowerCase()) {
      case 'error':
        return OutputLevel.error;
      case 'all':
        return OutputLevel.all;
      case 'none':
      default:
        return OutputLevel.none;
    }
  }
}

extension DeployerConfigCopyWith on DeployerConfig {
  DeployerConfig copyWith({
    VersionStrategy? versionStrategy,
    OutputLevel? outputLevel,
    String? customVersion,
    DeployerAndroidConfig? android,
    DeployerIOSConfig? ios,
    Map<String, dynamic>? additionalPlatforms,
  }) {
    return DeployerConfig(
      versionStrategy: versionStrategy ?? this.versionStrategy,
      outputLevel: outputLevel ?? this.outputLevel,
      customVersion: customVersion ?? this.customVersion,
      android: android ?? this.android,
      ios: ios ?? this.ios,
      additionalPlatforms: additionalPlatforms ?? this.additionalPlatforms,
    );
  }
}
