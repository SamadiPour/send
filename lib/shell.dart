import 'package:send/src/cli/cli.dart';

Future<void> main(List<String> arguments) async {
  await CommandLineInterface.run(arguments);
}
