import 'package:send/src/utils/config_reader.dart';

Future<void> main(List<String> arguments) async {
  ConfigReader.read(configPath: 'example/deploy.yaml');
}
