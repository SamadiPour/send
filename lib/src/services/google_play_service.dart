import 'dart:io';
import 'dart:convert';

import 'package:googleapis/androidpublisher/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

/// Google Play Service for uploading APKs and App Bundles
class GooglePlayService {
  late final AndroidPublisherApi _api;
  late final String _packageName;

  GooglePlayService(String packageName) : _packageName = packageName;

  /// Initialize the service with service account credentials
  Future<void> initialize(String credentialsPath) async {
    final credentialsFile = File(credentialsPath);
    if (!await credentialsFile.exists()) {
      throw Exception(
          'Service account credentials file not found: $credentialsPath');
    }

    final credentialsJson = await credentialsFile.readAsString();
    final credentials = json.decode(credentialsJson);

    final serviceAccountCredentials =
        ServiceAccountCredentials.fromJson(credentials);

    final client = await clientViaServiceAccount(
      serviceAccountCredentials,
      [AndroidPublisherApi.androidpublisherScope],
    );

    _api = AndroidPublisherApi(client);
  }

  /// Upload an APK to Google Play
  Future<void> uploadApk({
    required String apkPath,
    required String track,
    String? releaseNotes,
  }) async {
    final apkFile = File(apkPath);
    if (!await apkFile.exists()) {
      throw Exception('APK file not found: $apkPath');
    }

    print('🚀 Starting APK upload to Google Play...');

    // Create an edit
    final edit = await _api.edits.insert(
      AppEdit(),
      _packageName,
    );

    try {
      final editId = edit.id!;

      // Upload the APK
      final apkBytes = await apkFile.readAsBytes();
      final apkUpload = await _api.edits.apks.upload(
        _packageName,
        editId,
        uploadMedia: Media(Stream.fromIterable([apkBytes]), apkBytes.length),
      );

      print(
          '✅ APK uploaded successfully. Version code: ${apkUpload.versionCode}');

      // Assign to track
      await _assignToTrack(
        editId: editId,
        track: track,
        versionCode: apkUpload.versionCode!,
        releaseNotes: releaseNotes,
      );

      // Commit the edit
      await _api.edits.commit(_packageName, editId);
      print('✅ APK deployment completed successfully');
    } catch (e) {
      // Delete the edit if something goes wrong
      try {
        await _api.edits.delete(_packageName, edit.id!);
      } catch (_) {}
      rethrow;
    }
  }

  /// Upload an App Bundle to Google Play
  Future<void> uploadBundle({
    required String bundlePath,
    required String track,
    String? releaseNotes,
  }) async {
    final bundleFile = File(bundlePath);
    if (!await bundleFile.exists()) {
      throw Exception('App Bundle file not found: $bundlePath');
    }

    print('🚀 Starting App Bundle upload to Google Play...');

    // Create an edit
    final edit = await _api.edits.insert(
      AppEdit(),
      _packageName,
    );

    try {
      final editId = edit.id!;

      // Upload the bundle
      final bundleBytes = await bundleFile.readAsBytes();
      final bundleUpload = await _api.edits.bundles.upload(
        _packageName,
        editId,
        uploadMedia:
            Media(Stream.fromIterable([bundleBytes]), bundleBytes.length),
      );

      print(
          '✅ App Bundle uploaded successfully. Version code: ${bundleUpload.versionCode}');

      // Assign to track
      await _assignToTrack(
        editId: editId,
        track: track,
        versionCode: bundleUpload.versionCode!,
        releaseNotes: releaseNotes,
      );

      // Commit the edit
      await _api.edits.commit(_packageName, editId);
      print('✅ App Bundle deployment completed successfully');
    } catch (e) {
      // Delete the edit if something goes wrong
      try {
        await _api.edits.delete(_packageName, edit.id!);
      } catch (_) {}
      rethrow;
    }
  }

  /// Assign a version to a track
  Future<void> _assignToTrack({
    required String editId,
    required String track,
    required int versionCode,
    String? releaseNotes,
  }) async {
    final releasesList = <TrackRelease>[];

    final release = TrackRelease()
      ..name = 'Release v$versionCode'
      ..versionCodes = [versionCode.toString()]
      ..status = 'completed';

    if (releaseNotes != null && releaseNotes.isNotEmpty) {
      release.releaseNotes = [
        LocalizedText()
          ..language = 'en-US'
          ..text = releaseNotes,
      ];
    }

    releasesList.add(release);

    final trackUpdate = Track()
      ..track = track
      ..releases = releasesList;

    await _api.edits.tracks.update(
      trackUpdate,
      _packageName,
      editId,
      track,
    );

    print('✅ Assigned to $track track');
  }

  /// Validate track name
  static bool isValidTrack(String track) {
    const validTracks = ['internal', 'alpha', 'beta', 'production'];
    return validTracks.contains(track.toLowerCase());
  }
}
