// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:send/src/utils/config_reader.dart';

import 'src/base/context.dart';
import 'src/context_runner.dart';
import 'src/globals.dart' as globals;

/// Runs the Send with support for the specified list of [commands].
Future<int> run(
  List<String> args, {
  bool verbose = false,
  Map<Type, Generator>? overrides,
}) {
  return runInContext<int>(
    () async {
      return runZoned<Future<int>>(() async {
        try {
          await ConfigReader.read(configPath: 'example/deploy.yaml');
          return 1;
        } catch (error, stackTrace) {
          return await _handleToolError(error, stackTrace, verbose);
        }
      }, onError: (Object error, StackTrace stackTrace) async {
        return await _handleToolError(error, stackTrace, verbose);
      });
    },overrides: overrides,
  );
}

Future<int> _handleToolError(
  Object error,
  StackTrace? stackTrace,
  bool verbose,
) async {
  globals.printError('${error.toString()}\n');
  if (verbose) {
    globals.printError('\n$stackTrace\n');
  }
  return 1;
}
