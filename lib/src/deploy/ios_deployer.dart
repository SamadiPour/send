import 'deployer.dart';

class IosDeployer extends Deployer {
  IosDeployer(DeployerConfig config) : super(config);

  @override
  Future<void> deploy() {
    // TODO: implement deploy
    throw UnimplementedError();
  }

  @override
  Future<void> installDependencies() {
    // TODO: implement installDependencies
    throw UnimplementedError();
  }

  @override
  Future<void> validate() {
    // TODO: implement validate
    throw UnimplementedError();
  }
}