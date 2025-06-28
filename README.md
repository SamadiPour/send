# Send - Flutter App Deployment Tool

Send is a comprehensive deployment automation library for Flutter applications that supports
deployment to Android (Google Play) and iOS (App Store). It streamlines the entire deployment
process with configuration-driven automation, dependency management, and intelligent version
handling.

## Features

- 🚀 **Multi-platform deployment**: Android (Google Play) and iOS (App Store)
- 📱 **Automated building**: APK, App Bundle (Android) and IPA (iOS)
- ⚙️ **Configuration-driven**: Simple YAML configuration
- 🔄 **Version management**: Automatic version incrementing
- 📦 **Dependency management**: Automatic installation of required tools
- 🛡️ **Validation**: Pre-deployment configuration and dependency validation
- 📊 **Flexible output**: Configurable logging levels
- 🔧 **Extensible**: Modular architecture for future platform additions

## Quick Start

### 1. Installation

Add Send to your Flutter project:

```yaml
dev_dependencies:
  send: ^1.0.0
```

Run:

```bash
flutter pub get
```

### 2. Configuration

Create a `deploy.yaml` file in your project root:

```yaml
# Send Deployment Configuration
output_level: all                    # none, error, all
version_strategy: auto              # none, auto, manual

# Android Configuration
android:
  credential_file_path: "android/service-account-key.json"
  track_name: "internal"             # internal, alpha, beta, production
  package_name: "com.example.myapp"
  build_appbundle: true
  release_note: "New version with bug fixes and improvements"

# iOS Configuration
ios:
  api_key_id: "ABC123DEF4"
  api_key_issuer: "12345678-1234-1234-1234-123456789abc"
  api_key_path: "ios/AuthKey_ABC123DEF4.p8"
  team_id: "ABCD123456"
  bundle_id: "com.example.myapp"
  release_note: "New version with bug fixes and improvements"
```

### 3. Usage

Deploy to all configured platforms:

```bash
dart run send --all
```

Deploy to specific platforms:

```bash
# Android only
dart run send --android

# iOS only
dart run send --ios

# With dependency installation
dart run send --all --install-deps

# Validate configuration without deploying
dart run send --all --validate
```

## Command Line Options

```
Usage: send [options]

Options:
  -h, --help              Show usage information
  -c, --config            Path to the deployment configuration file (default: "deploy.yaml")
  -a, --android           Deploy to Android (Google Play)
  -i, --ios               Deploy to iOS (App Store)
      --all               Deploy to all configured platforms
  -v, --validate          Validate configuration and dependencies without deploying
  -d, --install-deps      Install platform dependencies before deployment
  -s, --show-config       Show deployment configuration summary
  -o, --output-level      Output verbosity level [none, error, all] (default: "none")
```

### Examples

```bash
# Deploy to all platforms with dependency installation
dart run send --all --install-deps

# Validate Android configuration without deploying
dart run send --android --validate

# Deploy iOS using custom configuration file
dart run send --ios --config my-config.yaml

# Show current configuration summary
dart run send --show-config

# Deploy with full logging
dart run send --all --output-level all
```

## Prerequisites

### Android Deployment

- **Flutter SDK**: Latest stable version
- **Android SDK**: With command-line tools
- **Google Play Console**: Service account with API access and JSON credentials file

### iOS Deployment

- **macOS**: Required for iOS builds
- **Xcode**: Latest version with command-line tools (`xcrun` available)
- **CocoaPods**: `sudo gem install cocoapods`
- **App Store Connect API Key**: Create in App Store Connect (.p8 file)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.