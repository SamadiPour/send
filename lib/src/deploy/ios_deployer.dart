import 'deployer.dart';
import 'deployer_config.dart';

class IOSDeployer extends Deployer {
  IOSDeployer(DeployerConfig config) : super(config);

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
