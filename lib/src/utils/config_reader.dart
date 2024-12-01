import 'dart:convert';
import 'dart:io';

import '../globals.dart' as globals;
import 'package:send/src/deploy/deployer_config.dart';
import 'package:send/src/utils/utils.dart';
import 'package:yaml/yaml.dart';

// todo: we might need to change this since we may need the same thing for pubspec.yaml
class ConfigReader {
  ConfigReader._();

  static Future<DeployerConfig?> read({
    String? configPath,
  }) async {
    final logger = globals.logger;
    logger.printBox('Welcome to Send!');
    // get the config file
    final File configFile;
    if (configPath == null) {
      final rootDirectory = await findProjectRoot(logger);
      configFile = File('$rootDirectory/deploy.yaml');
    } else {
      configFile = File(configPath);
    }

    // check if the config file exists
    logger.printStatus('Reading config from ${configFile.path}');
    if (!await configFile.exists()) {
      // todo: better error output
      logger.printError('Error: Config file not found');
      return null;
    }

    // Convert it to config object
    // todo: verify if yaml is valid
    final config = loadYaml(await configFile.readAsString());
    final configJson = jsonDecode(jsonEncode(config));
    return DeployerConfig.fromJson(configJson);
  }
}
