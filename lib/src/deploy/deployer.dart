import 'deployer_config.dart';

abstract class Deployer {
  DeployerConfig config;
  Deployer(this.config);

  Future<void> deploy();
  Future<void> validate();
  Future<void> installDependencies();
}