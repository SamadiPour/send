class DeployerConfig {
  final String? outputLevel;
  final String? versionStrategy;
  final DeployerAndroidConfig? android;
  final DeployerIOSConfig? ios;

  DeployerConfig({
    this.versionStrategy,
    this.outputLevel,
    this.android,
    this.ios,
  });

  factory DeployerConfig.fromJson(Map<String, dynamic> json) {
    return DeployerConfig(
      versionStrategy: json['version_strategy'] as String,
      outputLevel: json['output_level'] as String,
      android: json['android'] == null
          ? null
          : DeployerAndroidConfig.fromJson(json['android']),
      ios: json['ios'] == null
          ? null
          : DeployerIOSConfig.fromJson(json['ios']),
    );
  }
}

class DeployerAndroidConfig {
  final String? credentialFilePath;
  final String? trackName;
  final String? releaseNote;

  DeployerAndroidConfig({
    this.credentialFilePath,
    this.trackName,
    this.releaseNote,
  });

  factory DeployerAndroidConfig.fromJson(Map<String, dynamic> json) {
    return DeployerAndroidConfig(
      credentialFilePath: json['credential_file_path'] as String,
      trackName: json['track_name'] as String,
      releaseNote: json['release_note'] as String,
    );
  }
}

class DeployerIOSConfig {
  final String? teamKeyId;
  final String? developerId;
  final String? releaseNote;

  DeployerIOSConfig({
    this.teamKeyId,
    this.developerId,
    this.releaseNote,
  });

  factory DeployerIOSConfig.fromJson(Map<String, dynamic> json) {
    return DeployerIOSConfig(
      teamKeyId: json['team_key_id'] as String,
      developerId: json['developer_id'] as String,
      releaseNote: json['release_note'] as String,
    );
  }
}
