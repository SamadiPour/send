// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io show Platform, stdout;

/// Provides API parity with the `Platform` class in `dart:io`, but using
/// instance properties rather than static properties. This difference enables
/// the use of these APIs in tests, where you can provide mock implementations.
abstract class Platform {
  /// Creates a new [Platform].
  const Platform();

  /// A string (`linux`, `macos`, `windows`, `android`, `ios`, or `fuchsia`)
  /// representing the operating system.
  String get operatingSystem;

  /// True if the operating system is Linux.
  bool get isLinux => operatingSystem == 'linux';

  /// True if the operating system is OS X.
  bool get isMacOS => operatingSystem == 'macos';

  /// True if the operating system is Windows.
  bool get isWindows => operatingSystem == 'windows';

  /// True if the operating system is Android.
  bool get isAndroid => operatingSystem == 'android';

  /// True if the operating system is iOS.
  bool get isIOS => operatingSystem == 'ios';

  /// True if the operating system is Fuchsia.
  bool get isFuchsia => operatingSystem == 'fuchsia';

  /// The environment for this process.
  ///
  /// The returned environment is an unmodifiable map whose content is
  /// retrieved from the operating system on its first use.
  ///
  /// Environment variables on Windows are case-insensitive. The map
  /// returned on Windows is therefore case-insensitive and will convert
  /// all keys to upper case. On other platforms the returned map is
  /// a standard case-sensitive map.
  Map<String, String> get environment;

  /// When stdout is connected to a terminal, whether ANSI codes are supported.
  bool get stdoutSupportsAnsi;
}

/// `Platform` implementation that delegates directly to `dart:io`.
class LocalPlatform extends Platform {
  /// Creates a new [LocalPlatform].
  const LocalPlatform();

  @override
  String get operatingSystem => io.Platform.operatingSystem;

  @override
  Map<String, String> get environment => io.Platform.environment;

  @override
  bool get stdoutSupportsAnsi => io.stdout.supportsAnsiEscapes;
}