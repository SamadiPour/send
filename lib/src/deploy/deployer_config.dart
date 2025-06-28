enum OutputLevel {
  none,
  error,
  all,
}

enum VersionStrategy {
  none,
  auto,
  manual,
}

class DeployerConfig {
  final OutputLevel outputLevel;
  final VersionStrategy versionStrategy;
  final String? customVersion;
  final DeployerAndroidConfig? android;
  final DeployerIOSConfig? ios;
  final Map<String, dynamic>? additionalPlatforms;

  DeployerConfig({
    this.versionStrategy = VersionStrategy.none,
    this.outputLevel = OutputLevel.none,
    this.customVersion,
    this.android,
    this.ios,
    this.additionalPlatforms,
  });

  factory DeployerConfig.fromJson(Map<String, dynamic> json) {
    return DeployerConfig(
      versionStrategy:
          _parseVersionStrategy(json['version_strategy'] as String?),
      outputLevel: _parseOutputLevel(json['output_level'] as String?),
      customVersion: json['custom_version'] as String?,
      android: json['android'] == null
          ? null
          : DeployerAndroidConfig.fromJson(json['android']),
      ios: json['ios'] == null ? null : DeployerIOSConfig.fromJson(json['ios']),
      additionalPlatforms:
          json['additional_platforms'] as Map<String, dynamic>?,
    );
  }

  static VersionStrategy _parseVersionStrategy(String? value) {
    switch (value?.toLowerCase()) {
      case 'auto':
        return VersionStrategy.auto;
      case 'manual':
        return VersionStrategy.manual;
      case 'none':
      default:
        return VersionStrategy.none;
    }
  }

  static OutputLevel _parseOutputLevel(String? value) {
    switch (value?.toLowerCase()) {
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

class DeployerAndroidConfig {
  final String? credentialFilePath;
  final String? trackName;
  final String? releaseNote;
  final String? packageName;
  final String? flavor;
  final bool buildApk;
  final bool buildAppBundle;
  final Map<String, String>? additionalBuildArgs;

  DeployerAndroidConfig({
    this.credentialFilePath,
    this.trackName,
    this.releaseNote,
    this.packageName,
    this.flavor,
    this.buildApk = false,
    this.buildAppBundle = true,
    this.additionalBuildArgs,
  });

  factory DeployerAndroidConfig.fromJson(Map<String, dynamic> json) {
    return DeployerAndroidConfig(
      credentialFilePath: json['credential_file_path'] as String?,
      trackName: json['track_name'] as String?,
      releaseNote: json['release_note'] as String?,
      packageName: json['package_name'] as String?,
      flavor: json['flavor'] as String?,
      buildApk: json['build_apk'] as bool? ?? false,
      buildAppBundle: json['build_appbundle'] as bool? ?? true,
      additionalBuildArgs:
          (json['additional_build_args'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}

class DeployerIOSConfig {
  final String? apiKeyId;
  final String? apiKeyIssuer;
  final String? apiKeyPath;
  final String? teamId;
  final String? bundleId;
  final String? releaseNote;
  final String? exportMethod;
  final String? exportOptionsPlistPath;
  final Map<String, String>? additionalBuildArgs;

  DeployerIOSConfig({
    this.apiKeyId,
    this.apiKeyIssuer,
    this.apiKeyPath,
    this.teamId,
    this.bundleId,
    this.releaseNote,
    this.exportMethod = 'app-store',
    this.exportOptionsPlistPath,
    this.additionalBuildArgs,
  });

  factory DeployerIOSConfig.fromJson(Map<String, dynamic> json) {
    return DeployerIOSConfig(
      apiKeyId: json['api_key_id'] as String?,
      apiKeyIssuer: json['api_key_issuer'] as String?,
      apiKeyPath: json['api_key_path'] as String?,
      teamId: json['team_id'] as String?,
      bundleId: json['bundle_id'] as String?,
      releaseNote: json['release_note'] as String?,
      exportMethod: json['export_method'] as String? ?? 'app-store',
      exportOptionsPlistPath: json['export_options_plist_path'] as String?,
      additionalBuildArgs:
          (json['additional_build_args'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}
