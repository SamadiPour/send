# Send

**Idea:** Send is a comprehensive deployment automation tool specifically designed for Flutter
applications that streamlines the entire deployment process to both Android (Google Play) and iOS (
App Store). The core concept revolves around providing developers with a single, unified
command-line interface and YAML configuration that handles the complex orchestration of building,
validating, and deploying Flutter apps across multiple platforms. This tool can be used anywhere
such as Personal Device, Github Actions, GitLab CI, or any other CI/CD platform.

**Motivation:** The motivation behind Send stems from the complexity and repetitive nature of
deploying Flutter applications to app stores, which traditionally requires developers to manually
handle platform-specific build processes, credential management, and deployment workflows. By
automating these tedious tasks and providing a configuration-driven approach, Send eliminates human
error, reduces deployment time, and allows developers to focus on building features rather than
managing deployment pipelines.

**Features:** Send offers a robust feature set including multi-platform deployment support,
automated building of APKs, App Bundles, and IPAs, intelligent version management with automatic
incrementing, and flexible logging levels. The tool also provides extensive command-line options for
deployment validation, dependency installation, configuration management, and supports all-platform
deployments and platform-specific deployments through a modular, extensible architecture.

**Tech Stack:**

- **Programming Language:** Dart
- **Framework:** Flutter
- **Deployment Platforms:** Android (Google Play), iOS (App Store)
- **Configuration Format:** YAML
- **Command-Line Interface:** Dart CLI

**Rules:**

- Don't use fastlane or any other third-party deployment tools.
- Always consider a good structure for the codebase, including separation of concerns,
  modularity, and extensibility.
- Ensure that the tool is easy to use and well-documented, with clear instructions for
  installation, configuration, and usage.
- Don't write any tests, unless explicitly requested.
- The tool should be able to run on any platform (Windows, macOS, Linux). The iOS deployment
  should be able to run on macOS only.
- The tool should be able to run on any CI/CD platform (GitHub Actions, GitLab CI, etc.).
- The tool should be able to handle both Android and iOS deployments.
- The tool should be able to handle multiple environments/flavors (development, staging,
  production).
- The tool should be able to handle versioning and build number management.
- The tool should be able to handle signing and credentials management for both Android and iOS.
- The tool will not have any dry-run mode, as it is not needed.